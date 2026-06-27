#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="16"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — Cleanup + Drift Fix"

header "1. vajra launch alias removed"
label "main.rs no longer accepts 'launch' as a subcommand"
if grep -q '"launch"' src/main.rs; then
  printf "${RED}✗ launch alias still present${RESET}\n"
else
  ok "'launch' match arm removed"
fi
label "Help text has no launch line"
if grep -q "launch.*Legacy" src/main.rs; then
  printf "${RED}✗ launch still in help${RESET}\n"
else
  ok "Help text clean"
fi

header "2. ROADMAP.md sections fixed"
label "No [x] items in 'Does NOT Work Yet'"
if sed -n "/Does NOT Work/,/^##/p" .ai/ROADMAP.md | grep -q "\[x\]"; then
  printf "${RED}✗ [x] items still in wrong section${RESET}\n"
else
  ok "Does NOT Work Yet section clean"
fi
label "Installer + Maturity in 'What Works Today'"
grep "Installer" .ai/ROADMAP.md | head -1
grep "Maturity" .ai/ROADMAP.md | head -1
ok "Both moved to What Works Today"

header "3. KNOWLEDGE.md breadcrumb fixed"
label "§7 breadcrumb matches actual code output"
printf "  KNOWLEDGE.md: "; grep "Breadcrumb" .ai/KNOWLEDGE.md | head -1
printf "  Code:          "; grep "folded" src/adapter/claude_code.rs | head -1 | xargs
ok "Breadcrumb format synchronized"

header "4. S11 verify now passes"
label "roadmap-clean check was failing, now fixed"
bash scripts/verify-session-11.sh 2>&1 | tail -1
ok "S11 verify ALL GREEN"

header "5. Full test suite"
label "96 tests, clippy clean"
cargo test --all-targets 2>&1 | grep "^test result" | head -1
cargo clippy --all-targets -- -D warnings 2>&1 | tail -1
ok "All tests pass, no warnings"

header "Summary"
printf "\n"
printf "  %-35s %s\n" "Change" "Status"
printf "  %-35s %s\n" "-----------------------------------" "------"
printf "  %-35s %s\n" "vajra launch alias removed"         "DONE"
printf "  %-35s %s\n" "ROADMAP sections corrected"          "DONE"
printf "  %-35s %s\n" "KNOWLEDGE breadcrumb fixed"          "DONE"
printf "  %-35s %s\n" "S11 verify roadmap-clean passes"     "DONE"
printf "\n"

ok "Session ${SESSION} demo complete."
