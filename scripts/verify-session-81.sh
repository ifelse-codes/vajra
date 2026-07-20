#!/usr/bin/env bash
# Session 81 verify — harden verify-closeout: catch <sha> placeholder execution shas.
# Proves all four ACs (AC-1 through AC-6) against the new check_execution_shas gate:
#   AC-1: <sha> placeholder → FAIL (exit 1)
#   AC-2: VAJRA_CLOSEOUT_WAIVER=N → PASS even with <sha>
#   AC-3: absent ## Execution section → WARN only (PASS, exit 0)
#   AC-4: no false positives on the existing prompt corpus
#   AC-5: fixed S79 prompt now PASSES (steps 2–4 have real shas)
#   AC-6: cargo test --lib stays green

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="81"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-52s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-52s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# ── helpers ─────────────────────────────────────────────────────────────────
FIXTURE="prompts/99-task-sha-verify-fixture.md"

make_fixture_fail() {
  cat > "$FIXTURE" << 'ENDFIX'
# Session 99 — verify-81 fixture (FAIL case)
## Plan
1. Do something concrete

## Execution (the Coder gate)
- step 1 — done: <sha>
ENDFIX
}

make_fixture_pass() {
  cat > "$FIXTURE" << 'ENDFIX'
# Session 99 — verify-81 fixture (PASS case — real sha)
## Plan
1. Do something concrete

## Execution (the Coder gate)
- step 1 — done: 079d27f
ENDFIX
}

make_fixture_no_exec() {
  cat > "$FIXTURE" << 'ENDFIX'
# Session 99 — verify-81 fixture (WARN case — no ## Execution)
## Plan
1. Do something concrete

## Guardrails
- one guardrail
ENDFIX
}

cleanup_fixture() { rm -f "$FIXTURE"; }

# ── AC-1: <sha> placeholder → FAIL ──────────────────────────────────────────
ac1_placeholder_blocks() {
  make_fixture_fail
  local out; out=$(bash scripts/verify-closeout.sh --check-exec-shas 99 2>&1)
  local ec=$?
  echo "$out"
  [ "$ec" -ne 0 ] && echo "$out" | grep -q "PLACEHOLDER"
}
run_check "ac1-placeholder-blocks" ac1_placeholder_blocks
cleanup_fixture

# ── AC-2: VAJRA_CLOSEOUT_WAIVER waives the check ────────────────────────────
ac2_waiver_passes() {
  make_fixture_fail
  local out; out=$(VAJRA_CLOSEOUT_WAIVER=99 bash scripts/verify-closeout.sh --check-exec-shas 99 2>&1)
  local ec=$?
  echo "$out"
  [ "$ec" -eq 0 ] && echo "$out" | grep -q "WAIVED"
}
run_check "ac2-waiver-passes" ac2_waiver_passes
cleanup_fixture

# ── AC-3: absent ## Execution → WARN only, exit 0 ───────────────────────────
ac3_absent_section_warns_not_blocks() {
  make_fixture_no_exec
  local out; out=$(bash scripts/verify-closeout.sh --check-exec-shas 99 2>&1)
  local ec=$?
  echo "$out"
  [ "$ec" -eq 0 ] && echo "$out" | grep -qi "WARN"
}
run_check "ac3-absent-section-warns-not-blocks" ac3_absent_section_warns_not_blocks
cleanup_fixture

# ── AC-4: real shas pass, corpus test ───────────────────────────────────────
ac4_real_shas_pass() {
  make_fixture_pass
  local out; out=$(bash scripts/verify-closeout.sh --check-exec-shas 99 2>&1)
  local ec=$?
  echo "$out"
  [ "$ec" -eq 0 ] && echo "$out" | grep -q "PASS"
}
run_check "ac4-real-shas-pass" ac4_real_shas_pass
cleanup_fixture

# Corpus scan: all CODE sessions (non-GT) with ## Execution should either PASS or be
# a true-positive (S76 found to also have <sha> — a separate historical debt, not S81 scope).
# GT sessions (70, 75, 80) are waivered. The key invariant: no session with REAL shas fails.
corpus_scan() {
  local ec; local had_false_positive=0
  for n in 68 69 71 72 73 74 77 78 79; do
    ec=0
    bash scripts/verify-closeout.sh --check-exec-shas "$n" > /dev/null 2>&1 || ec=$?
    if [ "$ec" -ne 0 ]; then
      echo "FALSE POSITIVE: session $n failed (has real shas or no Execution section)"
      had_false_positive=1
    fi
  done
  # GT sessions must pass when waivered
  for n in 70 75 80; do
    ec=0
    VAJRA_CLOSEOUT_WAIVER=$n bash scripts/verify-closeout.sh --check-exec-shas "$n" > /dev/null 2>&1 || ec=$?
    if [ "$ec" -ne 0 ]; then
      echo "FALSE POSITIVE (GT waiver): session $n failed despite waiver"
      had_false_positive=1
    fi
  done
  # S76 is a TRUE POSITIVE (also has <sha> — noted as separate debt)
  ec=0
  bash scripts/verify-closeout.sh --check-exec-shas 76 > /dev/null 2>&1 || ec=$?
  [ "$ec" -ne 0 ] && echo "TRUE POSITIVE: S76 also has <sha> placeholders (separate debt; not fixed by S81)"
  [ "$had_false_positive" -eq 0 ]
}
run_check "ac4-corpus-zero-false-positives" corpus_scan

# ── AC-5: fixed S79 prompt now passes ───────────────────────────────────────
ac5_s79_prompt_passes() {
  local out; out=$(bash scripts/verify-closeout.sh --check-exec-shas 79 2>&1)
  local ec=$?
  echo "$out"
  [ "$ec" -eq 0 ] && echo "$out" | grep -q "OK"
}
run_check "ac5-s79-fixed-passes" ac5_s79_prompt_passes

# ── AC-6: cargo test --lib stays green ──────────────────────────────────────
run_check "ac6-lib-suite-green" cargo test --quiet --lib

# ── report ──────────────────────────────────────────────────────────────────
{
  echo "Session ${SESSION} verify — execution-sha placeholder guard"
  echo "artifacts: $ARTIFACTS"
  echo
  for r in "${RESULTS[@]}"; do echo "  $r"; done
  echo
  echo "PASS=$PASS FAIL=$FAIL"
} | tee "$ARTIFACTS/summary.txt"

ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"
[ "$FAIL" -eq 0 ] || { echo "VERIFY FAILED ($FAIL red)"; exit 1; }
echo "VERIFY GREEN ($PASS/$PASS)"
