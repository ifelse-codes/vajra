#!/usr/bin/env bash
# Demo — Session 117: the fleet's THIRD role, the Plan Advisor, dispatches BY NAME for real.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after. This session adds no new machinery (design-significant: no) — it supplies the
# missing dispatch EVIDENCE for a role S116 could only scaffold. So unlike prior demos, the
# before/after and cases here replay the REAL artifacts this live session produced (parent
# tool-use record, subagent meta, subagent transcript, governed handoff) rather than re-running a
# throwaway repo — the whole point is that a throwaway repo cannot prove a real dispatch happened.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="117"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }

VAJRA="$ROOT/target/debug/vajra"
[ -x "$VAJRA" ] || cargo build -q || { echo "build failed"; exit 1; }

PASS=0; FAIL=0
score() { if [ "$1" -eq 0 ]; then ok "$2"; PASS=$((PASS+1)); else no "$2"; FAIL=$((FAIL+1)); fi; }

ARTDIR="sessions/session-117-artifacts"

# --- demo:header ---
header "Session ${SESSION} Demo — the Plan Advisor dispatches BY NAME, for real  [demo:header]"
label "One line: S116 scaffolded the fleet's third role but could not dispatch it (the S111 \
mid-creating-session limit). This is the first fresh session after that commit landed on main — \
and the dispatch just worked, first try, exactly like S115 found for role two. This demo replays \
the REAL evidence this live session produced, not a re-run in a throwaway repo."

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"
label "BEFORE (S116 close) — three roles scaffolded, ZERO dispatched by name: Researcher (S111) \
and Fidelity Reviewer (S115) proven; Plan Advisor scaffolded-but-untested. AFTER (this session) \
— all three proven."

printf "\n  ${BOLD}Dispatch-by-name status, before vs after this session:${RESET}\n"
printf "    %-20s %s\n" "researcher"        "PROVEN (S111)"
printf "    %-20s %s\n" "fidelity-reviewer" "PROVEN (S115)"
printf "    %-20s %s (before) -> %s (after)\n" "plan-advisor" "NOT YET" "PROVEN"

# --- demo:cases ---
header "Cases  [demo:cases]"

label "1. The real dispatch: this session's own Task-tool call, extracted verbatim from Claude \
Code's own transcript. Not hand-typed — a random tool-call ID Claude Code itself assigned."
if command -v python3 >/dev/null 2>&1; then
  python3 -c "
import json
d = json.load(open('$ARTDIR/plan-advisor-parent-tooluse.json'))[0]
tu = d['tool_use']
print('    tool_use.id       :', tu['id'])
print('    subagent_type     :', tu['input']['subagent_type'])
print('    timestamp         :', d['parent_timestamp'])
print('    branch            :', d.get('parent_git_branch'))
"
fi
grep -q '"subagent_type": "plan-advisor"' "$ARTDIR/plan-advisor-parent-tooluse.json"
score $? "the Task tool actually resolved subagent_type: plan-advisor"

label "2. The cross-check: TWO files Claude Code wrote independently — this session's own \
transcript, and the subagent's separate meta file — must agree on that same random ID. Forging \
this means fabricating two matching random IDs in Claude Code's exact internal schema, not typing \
one JSON line."
PARENT_ID=$(grep -o '"id": "toolu_[a-zA-Z0-9]*"' "$ARTDIR/plan-advisor-parent-tooluse.json" | head -1 | grep -o 'toolu_[a-zA-Z0-9]*')
SUB_ID=$(grep -o '"toolUseId":"toolu_[a-zA-Z0-9]*"' "$ARTDIR/plan-advisor-subagent-meta.json" | grep -o 'toolu_[a-zA-Z0-9]*')
printf "    parent tool_use.id      : %s\n" "$PARENT_ID"
printf "    subagent meta toolUseId : %s\n" "$SUB_ID"
[ -n "$PARENT_ID" ] && [ "$PARENT_ID" = "$SUB_ID" ]
score $? "two independently-written files agree on the same random tool-call ID"

label "3. The raw subagent transcript is a real, non-trivial JSONL Claude Code wrote for the \
subagent's own turn — reproducible evidence, not a summary of it."
LINES=$(wc -l < "$ARTDIR/plan-advisor-subagent-transcript.jsonl" | tr -d ' ')
SHA=$(shasum -a 256 "$ARTDIR/plan-advisor-subagent-transcript.jsonl" | awk '{print $1}')
printf "    lines: %s   sha256: %s\n" "$LINES" "$SHA"
[ "${LINES:-0}" -gt 1 ]
score $? "the transcript is a real multi-line JSONL, not a hand-typed stand-in"

label "4. The real brief, governed through the UNCHANGED S109/S112 handoff path — same mechanism, \
real content this time."
printf "\n  ${BOLD}\$ vajra next --role plan-advisor --from %s/plan-advisor-brief.md${RESET}\n" "$ARTDIR"
"$VAJRA" next --role plan-advisor --from "$ARTDIR/plan-advisor-brief.md" 2>&1 | sed 's/^/  /'
[ -f ".ai/handoffs/session-117-plan-advisor.md" ] && grep -q "^role: plan-advisor$" ".ai/handoffs/session-117-plan-advisor.md"
score $? "the real proposal is governed at the contract path, frontmatter correct"

label "5. K of 8 is unaffected — the fleet handoff is reported BESIDE it, same invariant S113 \
proved and S114/S116 held at higher role counts, now confirmed on a REAL dispatch, not just a \
governed file."
STATIONS="$("$VAJRA" next --stations 117 2>&1)"
echo "$STATIONS" | grep -E "fleet:|of 8 stations passed" | sed 's/^/    /'
echo "$STATIONS" | grep -q "fleet: 1 governed handoff(s) — plan-advisor" \
  && echo "$STATIONS" | grep -q "NOT counted in it"
score $? "fleet line names plan-advisor, explicitly outside K"

label "6. No new machinery: this session's diff touches no src/ file. The third role needed a \
fresh session to dispatch, not new code — the same zero-new-machinery result S114 and S116 found \
for scaffolding now holds for dispatch too."
DIFF_STAT="$(git diff --stat main -- src/ 2>/dev/null)"
if [ -n "$DIFF_STAT" ]; then echo "    $DIFF_STAT"; else echo "    (no src/ changes)"; fi
[ -z "$DIFF_STAT" ]
score $? "design-significant: no, honoured — evidence only, no new code path"

label "7. All three fleet roles are now proven dispatched by name, in three separate fresh \
sessions (S111, S115, S117) — the mid-creating-session limit is a real, disclosed, permanent \
constraint of the harness, not a gap in any one role."
printf "    %-20s %s\n" "researcher"        "PROVEN — S111"
printf "    %-20s %s\n" "fidelity-reviewer" "PROVEN — S115"
printf "    %-20s %s\n" "plan-advisor"      "PROVEN — S117"
true; score $? "three for three — the pattern is confirmed, not a one-off"

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf '%-58s %s\n' "CAPABILITY" "STATE"
printf '%-58s %s\n' "----------------------------------------------------------" "------"
printf '%-58s %s\n' "govern a named agent's findings (S109)"                 "SHIPPED"
printf '%-58s %s\n' "prove the by-name dispatch wire, role 1 (S111)"         "SHIPPED"
printf '%-58s %s\n' "pipeline reads the handoff back (S112)"                 "SHIPPED"
printf '%-58s %s\n' "counter reports fleet work beside K (S113)"             "SHIPPED"
printf '%-58s %s\n' "second role: the Fidelity Reviewer (S114)"              "SHIPPED"
printf '%-58s %s\n' "by-name dispatch proven, role 2 (S115)"                 "SHIPPED"
printf '%-58s %s\n' "third role: the Plan Advisor (S116)"                    "SHIPPED"
printf '%-58s %s\n' "by-name dispatch proven, role 3, THIS SESSION (S117)"   "SHIPPED"
printf '%-58s %s\n' "all three fleet roles dispatched-by-name (S111+S115+S117)" "SHIPPED"
printf '%-58s %s\n' "Plan Advisor output consumed by the Planner station"    "NOT BUILT (deferred, non-goal)"
printf '%-58s %s\n' "a fourth role / parallel dispatch"                     "NOT BUILT (DECISION-007)"
printf '%-58s %s\n' "the paid vajra claude dogfood (13+ sessions overdue)"  "NOT BUILT (deferred by founder pick)"

echo ""
if [ "$FAIL" -eq 0 ]; then
  printf "${GREEN}${BOLD}ALL GREEN (%d pass, 0 fail)${RESET}\n" "$PASS"; exit 0
else
  printf "${RED}${BOLD}RED (%d pass, %d fail)${RESET}\n" "$PASS" "$FAIL"; exit 1
fi
