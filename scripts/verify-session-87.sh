#!/usr/bin/env bash
# Session 87 verify — fills S76's 4 unfilled `## Execution` <sha> placeholders
# (prompts/76-task-dogfood-ride-along.md), content-matched to their real landing commits, not
# pattern-matched to the "(N/4)" commit-message numbering (which is scrambled relative to
# Plan-step order — verified by reading each candidate diff). Docs-only: one file changed.
#
# Proves, against THIS repo's real history (no synthetic fixture — S76 is real):
#   (1) no `<sha>` placeholder remains anywhere in the file
#   (2) `vajra next --check-exec 76` flips NOT READY -> READY
#   (3) `vajra next --stations 76` Coder flips ABSENT -> PASSED
#   (4) scope stays docs-only — no `src/` file touched
#   (5) the disclosed side effect is real and reproducible, not hand-waved: this same edit
#       flips session 76's Reviewer/Releaser PASSED -> ABSENT, because S86's
#       canonical_inputs_sha hashes the prompt file's LIVE bytes, not a review-time snapshot.
#       Recorded here so the finding stays verifiable, not just asserted in prose.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="87"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-38s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-38s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

cargo build --quiet --release --bin vajra
BIN="$ROOT/target/release/vajra"
TARGET="prompts/76-task-dogfood-ride-along.md"

# ── (1) no <sha> placeholder remains ────────────────────────────────────────
no_placeholder_remains() { ! grep -q '<sha>' "$TARGET"; }
run_check "no-sha-placeholder-remains" no_placeholder_remains

# ── (2) --check-exec 76: NOT READY -> READY ─────────────────────────────────
check_exec_ready() { "$BIN" next --check-exec 76 | grep -q '^verdict: READY$'; }
run_check "check-exec-76-ready" check_exec_ready

# ── (3) --stations 76: Coder ABSENT -> PASSED ───────────────────────────────
stations_coder_passed() { "$BIN" next --stations 76 | grep -q '\[PASSED\] Coder'; }
run_check "stations-76-coder-passed" stations_coder_passed

# ── (4) scope: docs-only holds — no src/ change ─────────────────────────────
# An earlier version of this check tried to assert "exactly one file changed" — that claim is
# FALSE for any real session: sessions/session-87-{summary,review}.md, this session's own
# ## Execution self-record, the next session's prompt, and the .ai/* closeout sync are ALL
# constitutionally mandatory (AGENTS.md steps 7/9), not scope creep. Re-scoped to the one claim
# the prompt's guardrails actually make unambiguous and load-bearing: no `src/` file changed
# (mirrors verify-session-76.sh's own precedented `no_src_change` check, same pattern).
scope_no_src_change() {
  ! git diff --name-only main..HEAD -- src 2>/dev/null | grep -q .
}
run_check "scope-no-src-change" scope_no_src_change

# ── (5) disclosed side effect: reproducible, not asserted ──────────────────
# The fix retroactively un-attests S76's own review (S86's canonical_inputs_sha hashes the
# prompt file's LIVE bytes). This is a KNOWN, disclosed, out-of-scope finding for a future
# session — this check documents it stays reproducible, it does not require it to be fixed.
regression_reproduced() {
  local out
  out=$(bash scripts/verify-closeout.sh --attest-only 76 2>&1) || true
  printf '%s' "$out" | grep -q "BLOCK: attestation MISMATCH"
}
run_check "disclosed-reviewer-regression-reproduced" regression_reproduced

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-38s %s\n' "STEP" "RESULT"
printf '%-38s %s\n' "--------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
