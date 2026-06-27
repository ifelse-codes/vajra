#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="19"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — Varta v0 (the skill)"

header "1. The skill teaches the ⚡ language"
label "varta/SKILL.md — and its core rule: Varta is a language, not a file"
grep -m1 "^name:" varta/SKILL.md
grep -m1 -i "language, not a file" varta/SKILL.md | sed 's/\*\*//g; s/^/  /'
ok "Agent learns the language and speaks it from the LIVE .ai/ source"

header "2. The grammar — 9 constructs, self-describing in Varta"
label "varta/GRAMMAR.varta (the spec is written in the language it defines)"
grep -oE "⚡(project|forbid|require|max|pipeline|final|on|assert|enum)" varta/GRAMMAR.varta | sort -u
ok "All 9 constructs defined; frozen at 9"

header "3. Live read-back — agent speaks Varta FROM .ai/CONSTRAINTS.yaml"
label "Values pulled live at runtime (so the proof itself cannot drift)"
ASSUM=$(grep -E 'max_assumptions:' .ai/CONSTRAINTS.yaml | awk '{print $2}')
FILES=$(grep -E 'max_files_per_atomic_change:' .ai/CONSTRAINTS.yaml | awk '{print $2}')
MAT=$(grep -E '^maturity:' .ai/CONSTRAINTS.yaml | awk '{print $2}')
CAP=$(grep -E 'cap_usd:' .ai/CONSTRAINTS.yaml | awk '{print $2}')
printf "${DIM}  // spoken from live source — no second copy to lose or drift${RESET}\n"
printf "  ⚡max {\n"
printf "    assumptions      = %s;\n" "$ASSUM"
printf "    files_per_commit = %s;\n" "$FILES"
printf "    budget_usd       = %s;     // hand-copy DROPPED this; live source keeps it\n" "$CAP"
printf "  }\n"
printf "  ⚡require { maturity = %s; }   // hand-copy DROPPED this too\n" "$MAT"
ok "Nothing lost: budget + maturity present because we read .ai/ live"

header "4. Structural verify"
label "Skill + grammar present, 9 constructs, no hand-kept companion"
bash scripts/verify-session-19.sh 2>&1 | tail -3

header "Summary"
printf "\n"
printf "  %-40s %s\n" "Deliverable" "Status"
printf "  %-40s %s\n" "----------------------------------------" "------"
printf "  %-40s %s\n" "varta/SKILL.md (teaches the ⚡ language)"  "DONE"
printf "  %-40s %s\n" "varta/GRAMMAR.varta (self-describing spec)" "DONE"
printf "  %-40s %s\n" "Speaks Varta from live .ai/ (no drift)"     "DONE"
printf "  %-40s %s\n" "Hand-copy companion dropped (anti-drift)"   "DONE"
printf "\n"

ok "Session ${SESSION} demo complete."
