#!/usr/bin/env bash
# Demo — Session 112: the fleet's findings now reach the pipeline that needs them.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after. Everything here RUNS LIVE — a throwaway repo is created, a handoff is governed
# through the real writer, and the consuming station's output is shown before and after. Nothing
# is replayed from a captured file.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="112"
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
header "Session ${SESSION} Demo — the researcher's findings stop being an orphan  [demo:header]"
label "One line: Vajra could WRITE a governed handoff (S109) and PROVE it came from a real named \
agent (S111) — but nothing ever read it back. Now three Analyst surfaces do, automatically."

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"
label "BEFORE — a governed handoff sat in .ai/handoffs/ and the pipeline never mentioned it. A \
human had to know to go open the file."
label "AFTER — same repo, same command. Watch the output change because of the handoff alone:"

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT
( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null 2>&1 ) || { no "vajra init failed"; exit 1; }
echo "112" > "$TMP/.ai/SESSION"

BEFORE="$(cd "$TMP" && "$VAJRA" next --intake 2>&1)"
printf "\n  ${BOLD}$ vajra next --intake${RESET}  ${DIM}(no handoff yet)${RESET}\n"
echo "$BEFORE" | sed 's/^/  /'

printf 'ANSWER: ANTHROPIC_API_KEY is the only auth that survives a fresh no-TTY shell.\nclaude setup-token is the subscription alternative; interactive OAuth will not do.\n' \
  > "$TMP/findings.md"
printf "\n  ${BOLD}$ vajra next --role researcher --from findings.md${RESET}\n"
( cd "$TMP" && "$VAJRA" next --role researcher --from findings.md 2>&1 ) | sed 's/^/  /'

AFTER="$(cd "$TMP" && "$VAJRA" next --intake 2>&1)"
printf "\n  ${BOLD}$ vajra next --intake${RESET}  ${DIM}(same command, after)${RESET}\n"
echo "$AFTER" | sed 's/^/  /'

[ "$BEFORE" != "$AFTER" ]; score $? "the consuming station's output changed — findings are INLINE, not just a path"

# --- demo:cases ---
header "Cases  [demo:cases]"

label "1. The packet an agent boots on carries it (this is the one that matters — the next agent \
sees the research without being told to look)"
PACKET="$(cd "$TMP" && "$VAJRA" next 2>&1)"
echo "$PACKET" | grep -A 4 "fleet handoffs (session 112)" | sed 's/^/    /'
grep -q "fleet handoffs (session 112)" <<<"$PACKET" && grep -q "ANTHROPIC_API_KEY is the only auth" <<<"$PACKET"
score $? "vajra next — packet carries the handoff AND its findings"

label "2. Absence is silent and harmless — a session with no fleet work reads exactly as before"
echo "113" > "$TMP/.ai/SESSION"
OTHER="$(cd "$TMP" && "$VAJRA" next --intake 2>&1)"
dim "$(echo "$OTHER" | sed 's/^/    /')"
! grep -qi "handoff" <<<"$OTHER"
score $? "no handoff -> not one word about handoffs"

label "3. A broken handoff is NAMED, never swallowed as 'nothing here' (no false green)"
echo "112" > "$TMP/.ai/SESSION"
echo "just some notes, no frontmatter" > "$TMP/.ai/handoffs/session-112-researcher.md"
BROKEN="$(cd "$TMP" && "$VAJRA" next --intake 2>&1)"
echo "$BROKEN" | grep "not used" | sed 's/^/    /'
grep -q "not used" <<<"$BROKEN"
score $? "off-contract handoff surfaced with its reason"

label "4. REAL data — session 111's handoff came from an actual by-name subagent dispatch (S111's \
evidence trail). The Analyst gate in THIS repo now surfaces it:"
REAL="$("$VAJRA" next --validate 111 2>&1)"
echo "$REAL" | grep -A 3 "researcher (agent:" | sed 's/^/    /'
grep -q ".ai/handoffs/session-111-researcher.md" <<<"$REAL" && grep -q "de-facto standard crate" <<<"$REAL"
score $? "vajra next --validate 111 — real handoff AND its findings surfaced at the WHAT gate"

label "5. Still 7 top-level commands — consumption rides \`next\`, like the writer did"
HELP="$("$VAJRA" --help 2>&1)"; grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$HELP"
score $? "no 8th command"

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf '%-52s %s\n' "CAPABILITY" "STATE"
printf '%-52s %s\n' "----------------------------------------------------" "------"
printf '%-52s %s\n' "govern a named agent's findings (S109)"            "SHIPPED"
printf '%-52s %s\n' "prove the by-name dispatch wire (S111)"            "SHIPPED"
printf '%-52s %s\n' "packet surfaces this session's handoff (S112)"     "SHIPPED"
printf '%-52s %s\n' "Analyst intake inlines the findings (S112)"        "SHIPPED"
printf '%-52s %s\n' "Analyst gate shows it beside the WHAT (S112)"      "SHIPPED"
printf '%-52s %s\n' "absent = silent · broken = named (S112)"           "SHIPPED"
printf '%-52s %s\n' "a gate that BLOCKS on unread findings"             "NOT BUILT (advisory by design)"
printf '%-52s %s\n' "a second fleet role"                               "DEFERRED (DECISION-007)"

echo ""
if [ "$FAIL" -eq 0 ]; then
  printf "${GREEN}${BOLD}ALL GREEN (%d pass, 0 fail)${RESET}\n" "$PASS"; exit 0
else
  printf "${RED}${BOLD}RED (%d pass, %d fail)${RESET}\n" "$PASS" "$FAIL"; exit 1
fi
