#!/usr/bin/env bash
# verify-session-154.sh — CODER station: tighten check_execution_shas (S154)
# AC1: check_execution_shas BLOCKs when prompt has real plan steps + no ## Execution.
# AC2: check_execution_shas passes (WARN/N/A) when prompt has no real plan steps.
# AC3: check_execution_shas passes when ## Execution is filled (existing behavior preserved).
# AC4: AGENTS.md contains the ## Execution rule in step 4 of the Session Loop.
# AC5+: verified by verify-closeout.sh itself (exits 0).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="154"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
ok_check()  { RESULTS+=("$(printf '%-50s PASS' "$1")"); PASS=$((PASS+1)); }
bad_check() { RESULTS+=("$(printf '%-50s FAIL' "$1")"); FAIL=$((FAIL+1)); }
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then ok_check "$NAME"; else bad_check "$NAME"; fi
}

# ── Helper: isolate check_execution_shas from verify-closeout.sh ─────────────
# Sources only the waiver/ok/bad helpers + check_execution_shas itself,
# then calls it against a temp prompt file.
run_exec_sha_check() {
  local PROMPT_CONTENT="$1"
  local EXPECTED_EXIT="$2"  # 0 = pass, 1 = fail
  local LABEL="$3"
  local LOG="$ARTIFACTS/${LABEL}.log"

  local TMP; TMP="$(mktemp -d)"
  mkdir -p "$TMP/prompts" "$TMP/.ai/verify/session-154/t"
  printf '%s' "$PROMPT_CONTENT" > "$TMP/prompts/154-task-test.md"

  # Extract and run check_execution_shas in isolation.
  # We build a minimal harness: waiver_ok (always false for tests), ok/bad counters.
  local EXIT=0
  bash - <<HARNESS > "$LOG" 2>&1 || EXIT=$?
cd "$TMP"
N=154
ARTIFACTS=".ai/verify/session-154/t"
_PASS=0; _FAIL=0
ok()  { _PASS=\$((_PASS+1)); }
bad() { _FAIL=\$((_FAIL+1)); }
waiver_ok() { return 1; }  # no waiver in tests

$(sed -n '/^check_execution_shas()/,/^}/p' "$ROOT/scripts/verify-closeout.sh")

check_execution_shas
cat "\$ARTIFACTS/execution-shas-filled.log" 2>/dev/null || true
exit \$_FAIL
HARNESS

  if [ "$EXPECTED_EXIT" -eq 0 ] && [ "$EXIT" -eq 0 ]; then
    ok_check "$LABEL"
  elif [ "$EXPECTED_EXIT" -ne 0 ] && [ "$EXIT" -ne 0 ]; then
    ok_check "$LABEL"
  else
    echo "--- $LABEL (expected exit=$EXPECTED_EXIT, got exit=$EXIT) ---" >&2
    cat "$LOG" >&2
    bad_check "$LABEL"
  fi
  rm -rf "$TMP"
}

# ── AC1: real plan steps + no ## Execution → BLOCK ───────────────────────────
PROMPT_REAL_PLAN='# S154 test
> **Status:** APPROVED
## Plan
1. a real step that covers: 1
2. another real step covers: 2
## Guardrails
- test
'
run_exec_sha_check "$PROMPT_REAL_PLAN" 1 "ac1-real-plan-no-exec-blocks"

# ── AC2a: placeholder-only plan steps + no ## Execution → WARN (pass) ─────────
PROMPT_PLACEHOLDER_PLAN='# S154 test
> **Status:** APPROVED
## Plan
1. <first ordered step — replace me>
2. <next step>
'
run_exec_sha_check "$PROMPT_PLACEHOLDER_PLAN" 0 "ac2a-placeholder-plan-no-exec-passes"

# ── AC2b: no ## Plan section at all + no ## Execution → WARN (pass) ────────────
PROMPT_NO_PLAN='# S154 test
> **Status:** APPROVED
## Goal
No plan steps here.
'
run_exec_sha_check "$PROMPT_NO_PLAN" 0 "ac2b-no-plan-no-exec-passes"

# ── AC3: ## Execution filled (no done:<sha> placeholders) → pass ──────────────
PROMPT_FILLED='# S154 test
> **Status:** APPROVED
## Plan
1. a real step covers: 1
## Execution
- step 1 — done: abc1234def5678
'
run_exec_sha_check "$PROMPT_FILLED" 0 "ac3-execution-filled-passes"

# ── AC3b: ## Execution with placeholder → BLOCK (existing behavior) ───────────
PROMPT_PLACEHOLDER_EXEC='# S154 test
> **Status:** APPROVED
## Plan
1. a real step covers: 1
## Execution
- step 1 — done: <sha — replace me>
'
run_exec_sha_check "$PROMPT_PLACEHOLDER_EXEC" 1 "ac3b-execution-placeholder-blocks"

# ── AC4: AGENTS.md contains the ## Execution rule (structural) ────────────────
check_agents_rule() {
  grep -q '## Execution' .ai/AGENTS.md && \
  grep -q 'step N — done' .ai/AGENTS.md && \
  grep -q 'S154' .ai/AGENTS.md
}
run_check "ac4-agents-md-has-execution-rule" check_agents_rule

# ── verify-closeout.sh contains the S154 tightening (structural) ─────────────
check_closeout_tightened() {
  grep -q 'has_plan_steps' scripts/verify-closeout.sh && \
  grep -q 'S154' scripts/verify-closeout.sh
}
run_check "closeout-tightening-present" check_closeout_tightened

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "=== verify-session-154 ==="
for r in "${RESULTS[@]}"; do echo "  $r"; done
echo ""
echo "  PASS=$PASS  FAIL=$FAIL"
echo ""
[ "$FAIL" -eq 0 ]
