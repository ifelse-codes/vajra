#!/usr/bin/env bash
# Demo — Session 113: the pipeline's own progress counter can finally see the fleet.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after. Everything RUNS LIVE — a throwaway repo is created, a handoff is governed through
# the real writer, and `vajra next --stations` is shown before and after. Nothing is replayed.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="113"
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

# --- demo:header ---
header "Session ${SESSION} Demo — fleet work stops being invisible to the counter  [demo:header]"
label "One line: a session that dispatched a named agent, governed its findings and consumed them \
scored the SAME K of 8 as one that did none of it. Now the counter reports the fleet BESIDE K — \
so fleet work is visible and K still means exactly what it meant at S74."

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"
label "BEFORE — same repo, no handoff. AFTER — one governed handoff, same command."

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT
( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null 2>&1 ) || { no "vajra init failed"; exit 1; }
echo "113" > "$TMP/.ai/SESSION"

BEFORE="$(cd "$TMP" && "$VAJRA" next --stations 113 2>&1)"
printf "\n  ${BOLD}$ vajra next --stations 113${RESET}  ${DIM}(no fleet work)${RESET}\n"
echo "$BEFORE" | tail -4 | sed 's/^/  /'

printf 'ANSWER: ANTHROPIC_API_KEY is the only auth that survives a fresh no-TTY shell.\nclaude setup-token is the subscription alternative; interactive OAuth will not do.\n' \
  > "$TMP/findings.md"
printf "\n  ${BOLD}$ vajra next --role researcher --from findings.md${RESET}\n"
( cd "$TMP" && "$VAJRA" next --role researcher --from findings.md 2>&1 ) | sed 's/^/  /'

AFTER="$(cd "$TMP" && "$VAJRA" next --stations 113 2>&1)"
printf "\n  ${BOLD}$ vajra next --stations 113${RESET}  ${DIM}(same command, after)${RESET}\n"
echo "$AFTER" | tail -4 | sed 's/^/  /'

grep -q "fleet: 1 governed handoff(s) — researcher" <<<"$AFTER"
score $? "the counter now names the fleet's work — derived from the validated handoff on disk"

# --- demo:cases ---
header "Cases  [demo:cases]"

label "1. K of 8 did NOT move — and neither did any other byte. AFTER minus the fleet line is \
byte-identical to BEFORE, so S74's K and S113's K mean the same thing."
diff <(echo "$BEFORE") <(grep -v "fleet:" <<<"$AFTER") | sed 's/^/    /'
[ "$(grep -v "fleet:" <<<"$AFTER")" = "$BEFORE" ]
score $? "K stays comparable BY CONSTRUCTION (no 9th station, no folded verdict)"

label "2. Absence is silent — a session with no fleet work reads exactly as it did before S113"
dim "$(echo "$BEFORE" | tail -2 | sed 's/^/    /')"
! grep -qi "fleet" <<<"$BEFORE"
score $? "no handoff -> not one word about the fleet"

label "3. DERIVED, not merely present: a file at the handoff path that fails the contract is NAMED \
and never counts as fleet work done"
echo "just some notes, no frontmatter" > "$TMP/.ai/handoffs/session-113-researcher.md"
BROKEN="$(cd "$TMP" && "$VAJRA" next --stations 113 2>&1)"
echo "$BROKEN" | grep "not counted" | sed 's/^/    /'
grep -q "not counted" <<<"$BROKEN" && ! grep -q "governed handoff(s)" <<<"$BROKEN"
score $? "malformed handoff surfaced with its reason, counted as nothing"

label "4. REAL data — session 111's handoff came from an actual by-name subagent dispatch. THIS \
repo's counter shows it beside K; session 110, which had no fleet work, says nothing:"
REAL_111="$("$VAJRA" next --stations 111 2>&1)"; REAL_110="$("$VAJRA" next --stations 110 2>&1)"
echo "$REAL_111" | grep -E "of 8 stations passed|fleet:" | sed 's/^/    111> /'
echo "$REAL_110" | grep -E "of 8 stations passed" | sed 's/^/    110> /'
grep -q "fleet: 1 governed handoff(s) — researcher" <<<"$REAL_111" && ! grep -qi "fleet" <<<"$REAL_110"
score $? "real S111 fleet work visible; S110 unchanged"

label "5. The second fleet role is CHOSEN (the Reviewer) and recorded in DECISION-007 — not built"
grep -A 2 "S113 addendum" docs/decisions/DECISION-007-agent-fleet.md | sed 's/^/    /'
grep -q "S113 addendum" docs/decisions/DECISION-007-agent-fleet.md && [ ! -f ".claude/agents/reviewer.md" ]
score $? "chosen with evidence + rejected alternatives; no role code shipped"

label "6. Still 7 top-level commands — the fleet line rides \`next\`"
HELP="$("$VAJRA" --help 2>&1)"; grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$HELP"
score $? "no 8th command"

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf '%-52s %s\n' "CAPABILITY" "STATE"
printf '%-52s %s\n' "----------------------------------------------------" "------"
printf '%-52s %s\n' "govern a named agent's findings (S109)"            "SHIPPED"
printf '%-52s %s\n' "prove the by-name dispatch wire (S111)"            "SHIPPED"
printf '%-52s %s\n' "pipeline reads the handoff back (S112)"            "SHIPPED"
printf '%-52s %s\n' "counter reports fleet work beside K (S113)"        "SHIPPED"
printf '%-52s %s\n' "K of 8 unchanged in meaning (S113)"                "SHIPPED"
printf '%-52s %s\n' "malformed handoff never counts (S113)"             "SHIPPED"
printf '%-52s %s\n' "second role: the Reviewer"                         "CHOSEN, NOT BUILT (DECISION-007)"
printf '%-52s %s\n' "a gate that BLOCKS on unread findings"             "NOT BUILT (advisory by design)"

echo ""
if [ "$FAIL" -eq 0 ]; then
  printf "${GREEN}${BOLD}ALL GREEN (%d pass, 0 fail)${RESET}\n" "$PASS"; exit 0
else
  printf "${RED}${BOLD}RED (%d pass, %d fail)${RESET}\n" "$PASS" "$FAIL"; exit 1
fi
