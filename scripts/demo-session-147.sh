#!/usr/bin/env bash
# demo-session-147.sh — S147 Quiet Roles Audit demo.
#
# S147 delivers documents, not a runnable feature. The demo shows the audit's
# key finding: all 5 quiet roles returned Changed advice; the most critical
# course-correction was the demo-producer finding that test-runner heuristics
# already exist, reframing S148 from "implement" to "close the gaps."
#
# Elements: header, cases, summary_table, before_after

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

AUDIT="sessions/session-147-quiet-roles-audit.md"
S148_PROMPT=$(ls "$ROOT"/prompts/148-task-*.md 2>/dev/null | head -1 || echo "MISSING")

echo "demo:header"
echo "========================================"
echo "Session 147 — Quiet Roles Audit"
echo "Five under-dispatched fleet roles exercised on the S148 cost-cutting brief."
echo "All 5 returned Changed advice. Zero Hollow. Zero INCOMPLETE."
echo "========================================"
echo ""

echo "demo:cases"
echo "--- Case 1: plan-advisor — root cause (Changed) ---"
echo "Input: STATE.md cost data + session-144-summary.md profile"
echo "Finding: \$11.74 dominated by 129-turn main session context growth, NOT subagent tokens"
echo "S144: 875K subagent tokens vs S134: 19.2M — yet S144 cost 7× MORE → main session is the bill"
C1=0
# Live check: audit must contain the context-growth finding
grep -qi "context growth\|quadratic\|129-turn" "$AUDIT" || { echo "FAIL: plan-advisor context-growth finding missing from audit"; C1=1; }

echo ""
echo "--- Case 2: researcher — evidence check (Changed) ---"
echo "Input: STATE.md + session-144-summary.md"
echo "Finding: root cause is PLAUSIBLE but UNVERIFIED from available files"
echo "Rec: inspect S144 JSONL per-turn usage fields before claiming savings"
echo "Impact: AC6 in S148 requires measurement as a hard gate"
C2=0
# Live check: audit must contain the researcher's CANNOT-confirm finding
grep -qi "cannot confirm\|plausible but\|UNVERIFIED" "$AUDIT" || { echo "FAIL: researcher CANNOT-confirm finding missing from audit"; C2=1; }

echo ""
echo "--- Case 3: requirements-analyst — 8 ACs + 7 gaps (Changed) ---"
echo "Input: S147 prompt + plan-advisor handoff"
echo "Finding: plan-advisor's 3-sentence S148 description had 7 unresolved ambiguities"
echo "Gaps resolved: pattern spec | notice format | JSONL path | green-run cap | FAIL-line rule | floor | gate-vs-observation"
C3=0
# Live check: audit must contain the 7-gaps or 8-ACs finding
grep -qi "7 gaps\|8 ACs\|8 testable" "$AUDIT" || { echo "FAIL: requirements-analyst 7-gaps/8-ACs finding missing from audit"; C3=1; }

echo ""
echo "--- Case 4: demo-producer — SCOPE CORRECTION (Changed) ---"
echo "Input: plan-advisor handoff + demo-session-template.sh"
echo "CRITICAL: Existing heuristics already cover cargo test / pytest / npm test"
echo "Real gap A: bare 'jest' not in dispatch table"
echo "Real gap B: fail-path 30-399 lines passes through unchanged"
echo "S148 scope: CLOSE THE GAPS, not implement from scratch"
C4=0
# Live check: audit must contain the demo-producer's existing-heuristics finding
grep -qi "cargo\.rs\|heuristics.*exist\|CRITICAL.*heuristic\|heuristic.*cargo" "$AUDIT" || { echo "FAIL: demo-producer heuristics-exist finding missing from audit"; C4=1; }

echo ""
echo "--- Case 5: release-coordinator — missing deliverable (Changed) ---"
echo "Input: tech-lead handoff + CONSTRAINTS.yaml"
echo "Finding: scripts/demo-session-147.sh required by closeout gate (N%5 check, not AC list)"
echo "Impact: demo script added to S147 deliverables"
C5=0
# Live check: audit must contain the release-coordinator's demo-script finding
grep -qi "demo-session-147\|demo script.*gate\|gate.*demo script" "$AUDIT" || { echo "FAIL: release-coordinator demo-script-required finding missing from audit"; C5=1; }

echo ""
echo "demo:before_after"
echo "--- Before S147 ---"
echo "Dispatch count for 5 quiet roles across 147 sessions:"
echo "  researcher:         ~2 total dispatches"
echo "  plan-advisor:       ~2 total dispatches"
echo "  demo-producer:      ~2 total dispatches"
echo "  release-coordinator: ~2 total dispatches"
echo "  requirements-analyst: ~1 total dispatch"
echo "Open question: 'a bound dispatch ≠ good advice' — no evidence either way"
echo ""
echo "--- After S147 ---"
echo "5 dispatches in one session. All 5 returned signal. Key finds:"
echo "  - existing heuristics found (demo-producer) — scope corrected"
echo "  - 7 spec gaps found (requirements-analyst) — S148 can now be verified"
echo "  - measurement step added (researcher) — savings claims are now gated"
echo "  - demo script requirement found (release-coordinator) — close path unblocked"
echo "Phase 1b of DECISION-007 executed. Off switch remains deferred (n=1)."

echo ""
echo "demo:summary_table"
echo "Role                  | Judgment | Key Finding                        | S148 Updated?"
echo "----------------------|----------|------------------------------------|---------------"

# Compute from live case signals
C1_STATUS="PASS"; [ "$C1" -ne 0 ] && C1_STATUS="FAIL"
C2_STATUS="PASS"; [ "$C2" -ne 0 ] && C2_STATUS="FAIL"
C3_STATUS="PASS"; [ "$C3" -ne 0 ] && C3_STATUS="FAIL"
C4_STATUS="PASS"; [ "$C4" -ne 0 ] && C4_STATUS="FAIL"
C5_STATUS="PASS"; [ "$C5" -ne 0 ] && C5_STATUS="FAIL"

printf "%-22s| %-8s | %-34s | %s\n" "plan-advisor"        "Changed" "Context growth = cost driver"    "Yes — $C1_STATUS"
printf "%-22s| %-8s | %-34s | %s\n" "researcher"          "Changed" "Root cause unconfirmed; measure" "Yes — $C2_STATUS"
printf "%-22s| %-8s | %-34s | %s\n" "requirements-analyst" "Changed" "8 ACs + 7 gaps resolved"        "Yes — $C3_STATUS"
printf "%-22s| %-8s | %-34s | %s\n" "demo-producer"       "Changed" "Heuristics exist; close gaps"   "Yes — $C4_STATUS"
printf "%-22s| %-8s | %-34s | %s\n" "release-coordinator" "Changed" "Demo script required by gate"   "Yes — $C5_STATUS"

echo ""
TOTAL_FAIL=$((C1+C2+C3+C4+C5))
if [ "$TOTAL_FAIL" -gt 0 ]; then
  echo "DEMO FAIL: $TOTAL_FAIL case(s) failed"
  exit 1
fi
echo "All 5 cases: PASS"
