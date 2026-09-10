#!/usr/bin/env bash
# verify-session-153.sh — S153: close 4 carry-forward items
#
# SUITE DECLARATION: 6 checks total.
#   Execute-based (EXEC): C3 (cargo test), C6 (verify-closeout.sh)
#   Structural (STRUCT): C1, C2, C4, C5 (AGENTS.md content checks)
#
# AC coverage:
#   C1 → AC1: handoff-condensation transparency note present in AGENTS.md
#   C2 → AC2: retirement-standard note present in AGENTS.md
#   C3 → AC3: execute-based cargo test proves FAIL_PASSTHROUGH_CAP governs cargo-build-fail
#   C4 → AC4: DOCUMENT-session verify script standard note present in AGENTS.md
#   C5 → AC4 (depth): note mentions "Brief:" requirement
#   C6 → AC5: verify-closeout.sh exits 0

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="153"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  if "$@" > "$ARTIFACTS/${NAME}.log" 2>&1; then
    echo "  PASS  $NAME"; PASS=$((PASS+1)); RESULTS+=("PASS $NAME")
  else
    echo "  FAIL  $NAME (see $ARTIFACTS/${NAME}.log)"; FAIL=$((FAIL+1)); RESULTS+=("FAIL $NAME")
  fi
}

AGENTS=".ai/AGENTS.md"

echo "=== verify-session-153 ==="

# C1: AGENTS.md contains the handoff-condensation transparency note (AC1)
c1_condensation_note() {
  grep -q "Handoff Condensation Transparency" "$AGENTS" || return 1
  grep -q "condensed\|paraphrased" "$AGENTS" || return 1
}
run_check "C1-condensation-note" c1_condensation_note

# C2: AGENTS.md contains the hollow-advice retirement-standard note (AC2)
c2_retirement_standard() {
  grep -q "Hollow-Advice Retirement Standard" "$AGENTS" || return 1
  grep -q "closed session.*build passing\|build passing.*closed session" "$AGENTS" || return 1
}
run_check "C2-retirement-standard" c2_retirement_standard

# C3: Execute-based — cargo test proves FAIL_PASSTHROUGH_CAP governs cargo-build-fail (AC3)
c3_cargo_threshold_test() {
  cargo test --lib cargo_build_fail_passthrough_cap_governs_threshold 2>&1 \
    | grep -q "test result: ok"
}
run_check "C3-cargo-threshold-test" c3_cargo_threshold_test

# C4: AGENTS.md contains the DOCUMENT-session verify script standard note (AC4)
c4_document_verify_standard() {
  grep -q "DOCUMENT-Session Verify Script Standard" "$AGENTS" || return 1
}
run_check "C4-document-verify-standard" c4_document_verify_standard

# C5: A real S153 handoff file contains "Brief:" (S161 fix — old check grepped AGENTS.md itself,
# which was circular: the rule text in AGENTS.md contains the word "Brief:")
c5_brief_requirement() {
  local handoff=".ai/handoffs/session-153-fidelity-reviewer.md"
  [ -f "$handoff" ] || return 1
  grep -q "Brief:" "$handoff" || return 1
}
run_check "C5-brief-requirement" c5_brief_requirement

# C6: verify-closeout.sh exits 0 (AC5)
c6_closeout() {
  bash scripts/verify-closeout.sh "$SESSION" 2>&1
}
run_check "C6-verify-closeout" c6_closeout

# ── report ────────────────────────────────────────────────────────────────────
ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"
echo ""
echo "Results: ${PASS} PASS  ${FAIL} FAIL  (of $((PASS+FAIL)) checks)"
for r in "${RESULTS[@]}"; do echo "  $r"; done
echo ""
if [ "$FAIL" -gt 0 ]; then
  echo "FAIL — $FAIL check(s) failed"; exit 1
fi
echo "PASS — all checks passed"
