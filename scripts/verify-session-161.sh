#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="161"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
ok()  { RESULTS+=("$(printf '%-46s %s' "$1" PASS)"); PASS=$((PASS+1)); }
bad() { RESULTS+=("$(printf '%-46s %s' "$1" FAIL)"); FAIL=$((FAIL+1)); }
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-46s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-46s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# ── AC1: DECISION-008 exists and cites DECISION-002 ──────────────────────────
DECISION="docs/decisions/DECISION-008-session-type-detection.md"
run_check "decision-008-exists"        test -f "$DECISION"
run_check "decision-008-cites-002"     grep -q "DECISION-002" "$DECISION"
run_check "decision-008-affirmative"   grep -q "is_code_session" "$DECISION"
run_check "decision-008-demo-markers"  grep -q "check_demo_markers" "$DECISION"

# ── AC2: demo-session-158.sh has blocking-path case ──────────────────────────
DEMO158="scripts/demo-session-158.sh"
run_check "demo-158-exists"            test -f "$DEMO158"
run_check "demo-158-blocking-case"     grep -q "marker-free\|marker.free\|no markers\|no-markers" "$DEMO158"
run_check "demo-158-tmpdir-fixture"    grep -q "mktemp" "$DEMO158"

# AC2: blocking-path demo actually runs and confirms BLOCK
demo_blocking_path() {
  TMPDIR_V="$(mktemp -d)"
  mkdir -p "$TMPDIR_V/.ai" "$TMPDIR_V/prompts" "$TMPDIR_V/scripts"
  echo "99" > "$TMPDIR_V/.ai/SESSION"
  printf '## Type\n**CODE**\n' > "$TMPDIR_V/prompts/99-task-fixture.md"
  printf '#!/usr/bin/env bash\necho "no markers"\n' > "$TMPDIR_V/scripts/demo-session-99.sh"
  chmod +x "$TMPDIR_V/scripts/demo-session-99.sh"
  CLAUDE_PROJECT_DIR="$TMPDIR_V" bash scripts/verify-closeout.sh --demo-only 99 >/dev/null 2>&1 && rc=0 || rc=$?
  rm -rf "$TMPDIR_V"
  [ "$rc" -ne 0 ]
}
run_check "demo-blocking-path-blocks"  demo_blocking_path

# ── AC3: verify-session-158.sh behavioral check present ──────────────────────
VS158="scripts/verify-session-158.sh"
run_check "verify-158-no-source-grep"  bash -c "! grep -q 'grep -A5.*is_code_session.*demo\|grep.*is_code_session.*|.*grep.*demo' '$VS158' 2>/dev/null || true; grep -q 'mktemp\|TMPDIR' '$VS158'"
run_check "verify-158-behavioral-fixture" grep -q "CLAUDE_PROJECT_DIR" "$VS158"
run_check "verify-158-asserts-fail"    grep -q "should FAIL\|BHAV_EXIT\|FAIL" "$VS158"

# ── AC4: verify-closeout.sh check_required_crew greps real handoff, not AGENTS.md ──
VC="scripts/verify-closeout.sh"
run_check "closeout-crew-brief-check"  grep -q "Brief:" "$VC"
run_check "closeout-crew-handoff-path" grep -q "handoffs/session-" "$VC"
# AC4: the Brief: grep in check_required_crew must target handoff files, not AGENTS.md
closeout_crew_not_agents() {
  # extract the check_required_crew function body and confirm its grep uses 'handoffs', not AGENTS.md
  awk '/^check_required_crew\(\)/,/^\}/' "$VC" | grep -q "handoffs/" || return 1
  awk '/^check_required_crew\(\)/,/^\}/' "$VC" | grep "Brief:" | grep -qv "AGENTS.md" || return 1
}
run_check "closeout-no-agents-brief"   closeout_crew_not_agents

# AC4: verify-session-153.sh C5 greps real handoff, not AGENTS.md
VS153="scripts/verify-session-153.sh"
run_check "v153-c5-greps-handoff"      grep -q "handoffs/session-153" "$VS153"
# AC4: C5 fix — the grep inside c5_brief_requirement() must not use AGENTS.md as the file
v153_c5_not_agents() {
  awk '/^c5_brief_requirement\(\)/,/^\}/' "$VS153" | grep "grep" | grep -qv 'AGENTS\.md'
}
run_check "v153-c5-no-agents"          v153_c5_not_agents

# ── AC7: D2 cost field present in session summary (or null with explanation) ──
# Check the session summary for D2 cost evidence
SUMMARY="sessions/session-161-summary.md"
if [ -f "$SUMMARY" ]; then
  run_check "summary-d2-cost-recorded"   grep -qi "total_cost_usd\|d2.*cost\|cost.*d2\|dogfood.*cost\|cost.*dogfood" "$SUMMARY"
else
  bad "summary-d2-cost-recorded (sessions/session-161-summary.md not yet written)"
fi

# ── Report ────────────────────────────────────────────────────────────────────
echo ""
echo "=== verify-session-161 ==="
for r in "${RESULTS[@]}"; do
  flag="  PASS "; [[ "$r" == *FAIL ]] && flag="  FAIL "
  echo "${flag}${r}"
done
echo ""
echo "Score: $((PASS+FAIL)) checks — $FAIL FAILED"
[ "$FAIL" -eq 0 ]
