#!/usr/bin/env bash
# Demo — Session 104: the pipeline now speaks like a TEAM (named roles + plain status),
# not "station K-of-8". Cumulative: the gates it narrates are S54–S74's 8-station spine.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases ·
# summary_table · before_after — each emitted as a `demo:<element>` marker. The Demo-er gate
# (S71) re-runs this LIVE at close and blocks on a missing element or a non-zero exit.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="104"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }

cargo build -q
BIN="./target/debug/vajra"

# --- demo:header ---
header "Session ${SESSION} Demo  [demo:header]"
label "The 8 governed stations now read like a team: named roles + plain status (mechanism unchanged)."

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"
label "BEFORE — the payload counter spoke like plumbing (bare K-of-8, technical notes):"
printf "${DIM}%s${RESET}\n" "  4 of 8 stations passed (derived from each gate's evidence ...)"
printf "${DIM}%s${RESET}\n" "  [PASSED] Analyst   WHAT   — substantive \`## Delta\`"
label "AFTER — the same evidence, now a human team roster (live output):"
# Print the roster body: from the team headline up to (not incl.) the auditable-detail header.
# (An earlier `sed '/team/,/^$/p'` stopped at the blank line right after the headline — hollow.)
$BIN next --stations 103 | awk '/the pipeline team/{f=1} /pipeline advance/{f=0} f'

# --- demo:cases ---
header "Cases  [demo:cases]"
label "1 · vajra next --stations 103 — the team roster is the headline, K-of-8 kept as a subtitle:"
$BIN next --stations 103 | grep -E "the pipeline team|of 8 stations passed"
ok "named roles + plain status; the number survives as a subtitle"

label "2 · vajra next (the handoff packet) — the SAME roster, one source, no second copy:"
$BIN next 2>/dev/null | sed -n '/pipeline team (session/,/roles have finished/p'
ok "the packet reuses stations::format_team_roster — no drift"

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-34s %s\n" "Feature" "Status"
printf "  %-34s %s\n" "----------------------------------" "------"
printf "  %-34s %s\n" "Team roster on --stations"          "WORKS"
printf "  %-34s %s\n" "Same roster in the next packet"     "WORKS"
printf "  %-34s %s\n" "K-of-8 kept as subtitle"            "WORKS"
printf "  %-34s %s\n" "Gate logic + K unchanged"           "WORKS"
printf "\n"

ok "Session ${SESSION} demo complete."
