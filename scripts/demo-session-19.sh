#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="19"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — Varta v0 (the skill)"

header "1. The skill teaches the ⚡ grammar"
label "varta/SKILL.md — frontmatter + boot ritual"
grep -m1 "^name:" varta/SKILL.md
grep -m1 "READ" varta/SKILL.md | sed 's/^[0-9. ]*//' | head -1
ok "Skill loads at boot, drills read → internalize → speak"

header "2. The grammar — 9 constructs, self-describing in Varta"
label "varta/GRAMMAR.varta (dogfood: the spec is written in the language)"
grep -oE "⚡(project|forbid|require|max|pipeline|final|on|assert|enum)" varta/GRAMMAR.varta | sort -u
ok "All 9 constructs defined"

header "3. vajra.varta — Vajra's own .ai/ rendered in Varta"
label "The forbidden rules (⚡forbid)"
sed -n '/⚡forbid {/,/}/p' varta/vajra.varta | grep ";" | sed 's/^/  /'
label "The co-pilot loads (⚡on … ⚡include)"
grep "⚡on (" varta/vajra.varta | sed 's/^/  /'
ok "Real operating context carried by the grammar"

header "4. Read-back test — agent answers from the spec alone"
label "varta/READBACK.md — what loads when I touch compression?"
sed -n '/Q2\./,/co-pilot/p' varta/READBACK.md | sed 's/^/  /'
ok "6/6 answerable from vajra.varta"

header "5. Structural verify"
label "All Varta invariants hold"
bash scripts/verify-session-19.sh 2>&1 | tail -3

header "Summary"
printf "\n"
printf "  %-38s %s\n" "Deliverable" "Status"
printf "  %-38s %s\n" "--------------------------------------" "------"
printf "  %-38s %s\n" "varta/SKILL.md (teaches ⚡ grammar)"      "DONE"
printf "  %-38s %s\n" "varta/GRAMMAR.varta (self-describing)"   "DONE"
printf "  %-38s %s\n" "varta/vajra.varta (worked example)"      "DONE"
printf "  %-38s %s\n" "varta/READBACK.md (read-back proof)"     "DONE"
printf "  %-38s %s\n" "verify-session-19.sh (invariants)"       "DONE"
printf "\n"

ok "Session ${SESSION} demo complete."
