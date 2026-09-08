#!/usr/bin/env bash
# demo-session-154.sh — CODER station: tighten check_execution_shas (S154)
# Shows before/after for the execution-sha guard tightening.
# Required elements: header · before_after · cases · summary_table
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

hdr()   { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label() { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()    { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bullet(){ printf "${DIM}  %s${RESET}\n" "$1"; }

run_harness() {
  local PROMPT_CONTENT="$1"
  local TMP; TMP="$(mktemp -d)"
  mkdir -p "$TMP/prompts" "$TMP/.ai/verify/session-154/demo"
  printf '%s' "$PROMPT_CONTENT" > "$TMP/prompts/154-task-test.md"
  local EXIT=0
  bash - <<HARNESS > /dev/null 2>&1 || EXIT=$?
cd "$TMP"
N=154
ARTIFACTS=".ai/verify/session-154/demo"
_PASS=0; _FAIL=0
ok()  { _PASS=\$((_PASS+1)); }
bad() { _FAIL=\$((_FAIL+1)); }
waiver_ok() { return 1; }
$(sed -n '/^check_execution_shas()/,/^}/p' "$ROOT/scripts/verify-closeout.sh")
check_execution_shas
exit \$_FAIL
HARNESS
  rm -rf "$TMP"
  echo "$EXIT"
}

# --- demo:header ---
hdr "Session 154 Demo — CODER station: step-sha traces  [demo:header]"
bullet "S154 is the first CODE session to pass the CODER station."
bullet "check_execution_shas now BLOCKs when real plan steps exist but ## Execution is absent."
bullet "Pre-existing placeholder grep bug fixed (dead code for all standard prompts)."

# --- demo:before_after ---
hdr "Before → After  [demo:before_after]"
label "BEFORE (pre-S154 behaviour)"
bullet "Prompt with real numbered ## Plan steps + no ## Execution section:"
bullet "  check_execution_shas → WARN (pass) — closeout stayed green silently"
bullet "Placeholder grep 'done: <sha>' never matched standard template 'done: <sha — …>'"
bullet "  → placeholder BLOCK was dead code for all real sessions"

label "AFTER (S154)"
bullet "Same prompt → check_execution_shas → BLOCK (non-zero exit)"
bullet "Placeholder grep widened to 'done: <' → catches standard template"

# --- demo:cases ---
hdr "Cases  [demo:cases]"

label "Case 1: real plan + no ## Execution → BLOCK"
PROMPT_1='## Plan
1. a real step covers: 1
2. another real step covers: 2
'
EXIT_1=$(run_harness "$PROMPT_1")
if [ "$EXIT_1" -ne 0 ]; then
  ok "exit=$EXIT_1 — BLOCK fired correctly ✓"
else
  echo "FAIL: expected non-zero, got 0" >&2; exit 1
fi

label "Case 2: placeholder-only plan + no ## Execution → WARN/pass"
PROMPT_2='## Plan
1. <first ordered step — replace me>
2. <next step>
'
EXIT_2=$(run_harness "$PROMPT_2")
if [ "$EXIT_2" -eq 0 ]; then
  ok "exit=0 — placeholder plan passes correctly ✓"
else
  echo "FAIL: expected 0, got $EXIT_2" >&2; exit 1
fi

label "Case 3: filled ## Execution → pass"
PROMPT_3='## Plan
1. a real step covers: 1
## Execution
- step 1 — done: abc1234def5678
'
EXIT_3=$(run_harness "$PROMPT_3")
if [ "$EXIT_3" -eq 0 ]; then
  ok "exit=0 — filled execution passes correctly ✓"
else
  echo "FAIL: expected 0, got $EXIT_3" >&2; exit 1
fi

label "Case 4: ## Execution with placeholder → BLOCK (pre-S154 bug fixed)"
PROMPT_4='## Plan
1. a real step covers: 1
## Execution
- step 1 — done: <sha — replace me>
'
EXIT_4=$(run_harness "$PROMPT_4")
if [ "$EXIT_4" -ne 0 ]; then
  ok "exit=$EXIT_4 — placeholder block fires ✓  (old grep missed this)"
else
  echo "FAIL: expected non-zero, got 0" >&2; exit 1
fi

label "Case 5: vajra next --exec 154 → RECORDED"
EXEC_OUT=$(vajra next --exec 154 2>&1)
if echo "$EXEC_OUT" | grep -q "RECORDED"; then
  ok "RECORDED — every plan step names a real commit sha ✓"
else
  echo "FAIL: expected RECORDED" >&2; exit 1
fi

# --- demo:summary_table ---
hdr "Summary  [demo:summary_table]"
printf '%-50s %s\n' "Check" "Result"
printf '%-50s %s\n' "$(printf '%0.s-' {1..50})" "------"
printf '%-50s %s\n' "real-plan + no ## Execution → BLOCK"       "PASS"
printf '%-50s %s\n' "placeholder-plan + no ## Execution → WARN"  "PASS"
printf '%-50s %s\n' "filled ## Execution → pass"                  "PASS"
printf '%-50s %s\n' "placeholder ## Execution → BLOCK"            "PASS"
printf '%-50s %s\n' "vajra next --exec 154 → RECORDED"            "PASS"
