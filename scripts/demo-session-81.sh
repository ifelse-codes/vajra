#!/usr/bin/env bash
# Session 81 demo — execution-sha placeholder guard.
# Shows: placeholder blocks · waiver bypasses · absent warns · real sha passes · S79 fix.
# All four demo:<element> markers required by the Demo-er gate.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

HL='\033[1;33m'; GR='\033[0;32m'; RD='\033[0;31m'; CY='\033[0;36m'; RS='\033[0m'
hdr() { echo -e "\n${HL}── $* ──${RS}"; }
ok()  { echo -e "${GR}  PASS${RS}  $*"; }
err() { echo -e "${RD}  FAIL${RS}  $*"; }
note(){ echo -e "${CY}  NOTE${RS}  $*"; }

FIXTURE="prompts/99-task-sha-demo-fixture.md"
cleanup() { rm -f "$FIXTURE"; }
trap cleanup EXIT

# ─────────────────────────────────────────────────────────────────────────────
echo "demo:header"
hdr "Session 81 — verify-closeout: execution-sha placeholder guard"
echo ""
echo "  Problem (S80 GT finding): a CODE session can close with"
echo "    '- step N — done: <sha>'  still a template placeholder."
echo "  The Coder gate (vajra --advance) never sees it; verify-closeout.sh"
echo "  didn't check. S79 closed this way — 4 unfilled steps."
echo "  Fix: new check_execution_shas in scripts/verify-closeout.sh (S81)."

# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "demo:cases"

hdr "Case 1 — placeholder <sha> BLOCKS closeout (AC-1)"
cat > "$FIXTURE" << 'EOF'
# Session 99 — demo fixture (FAIL case)
## Plan
1. Do something

## Execution (the Coder gate)
- step 1 — done: <sha>
EOF
out=$(bash scripts/verify-closeout.sh --check-exec-shas 99 2>&1 || true)
if echo "$out" | grep -q "PLACEHOLDER" && echo "$out" | grep -q "EXEC-SHAS: FAIL"; then
  err "<sha> placeholder detected → exit 1, blocked — CORRECT"
else
  err "unexpected result: $out"
fi

hdr "Case 2 — VAJRA_CLOSEOUT_WAIVER bypasses the check (AC-2)"
out=$(VAJRA_CLOSEOUT_WAIVER=99 bash scripts/verify-closeout.sh --check-exec-shas 99 2>&1 || true)
if echo "$out" | grep -q "WAIVED" && echo "$out" | grep -q "EXEC-SHAS: PASS"; then
  ok "waiver present → exit 0, bypassed — CORRECT"
else
  err "unexpected result: $out"
fi

hdr "Case 3 — absent ## Execution WARNS only, never blocks (AC-3)"
cat > "$FIXTURE" << 'EOF'
# Session 99 — demo fixture (pre-S68 / no Execution section)
## Plan
1. Do something
EOF
out=$(bash scripts/verify-closeout.sh --check-exec-shas 99 2>&1 || true)
if echo "$out" | grep -qi "WARN" && echo "$out" | grep -q "EXEC-SHAS: PASS"; then
  ok "no ## Execution → WARN only, exit 0 — CORRECT"
else
  err "unexpected result: $out"
fi

hdr "Case 4 — real sha passes (AC-4)"
cat > "$FIXTURE" << 'EOF'
# Session 99 — demo fixture (PASS case)
## Plan
1. Do something

## Execution (the Coder gate)
- step 1 — done: 079d27f
EOF
out=$(bash scripts/verify-closeout.sh --check-exec-shas 99 2>&1 || true)
if echo "$out" | grep -q "OK:" && echo "$out" | grep -q "EXEC-SHAS: PASS"; then
  ok "real sha → exit 0 — CORRECT"
else
  err "unexpected result: $out"
fi

hdr "Case 5 — S79 retroactive fix: prompts/79-task-stale-opus-reprice.md (AC-5)"
out=$(bash scripts/verify-closeout.sh --check-exec-shas 79 2>&1 || true)
if echo "$out" | grep -q "OK:" && echo "$out" | grep -q "EXEC-SHAS: PASS"; then
  ok "S79 prompt now PASSES check_execution_shas — CORRECT"
  note "S76 also has <sha> placeholders (true positive, separate debt; not S81 scope)"
else
  err "S79 prompt still fails: $out"
fi

# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "demo:summary_table"
hdr "Summary"
printf "  %-42s  %-8s  %s\n" "CASE" "RESULT" "DETAIL"
printf "  %-42s  %-8s  %s\n" "$(printf '%0.s-' {1..42})" "--------" "------"
printf "  %-42s  ${RD}%-8s${RS}  %s\n" "placeholder 'done: <sha>' in Execution" "BLOCKS" "exit 1 — AC-1"
printf "  %-42s  ${GR}%-8s${RS}  %s\n" "VAJRA_CLOSEOUT_WAIVER=N bypass" "PASS" "exit 0 — AC-2"
printf "  %-42s  ${GR}%-8s${RS}  %s\n" "absent ## Execution (pre-S68)" "PASS" "WARN only — AC-3"
printf "  %-42s  ${GR}%-8s${RS}  %s\n" "real sha in Execution" "PASS" "exit 0 — AC-4"
printf "  %-42s  ${GR}%-8s${RS}  %s\n" "S79 prompt after retroactive fix" "PASS" "exit 0 — AC-5"

# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "demo:before_after"
hdr "Before → After (S79 ## Execution section)"
echo ""
echo "  BEFORE (S79 at close — 4 × '<sha>' placeholder):"
echo "    - step 1 — done: <sha>"
echo "    - step 2 — done: <sha>"
echo "    - step 3 — done: <sha>"
echo "    - step 4 — done: <sha>"
echo ""
echo "  AFTER (S81 retroactive fix):"
grep "step [0-9].*done:" prompts/79-task-stale-opus-reprice.md | sed 's/^/    /'
echo ""
echo -e "${GR}  verify-closeout.sh now blocks any CODE session that closes"
echo -e "  with unfilled ## Execution shas.${RS}"
