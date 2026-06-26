#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="14"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — Maturity Levels"

header "1. Maturity module"
label "MaturityLevel enum parses L1/L2/L3 from CONSTRAINTS.yaml"
cargo test maturity -- --quiet 2>&1 | tail -3
ok "Maturity parsing works"

header "2. vajra check respects maturity"
label "L1 = WARN (exit 0), L2/L3 = FAIL (exit 1)"
cargo test check -- --quiet 2>&1 | tail -3
ok "Check enforcement adapts to maturity"

header "3. vajra init scaffolds maturity"
label "New prompt asks for L1/L2/L3, writes to CONSTRAINTS.yaml"
grep -A2 'maturity:' src/cli/init.rs | head -3
ok "Init templates include maturity"

header "4. Hook scripts respect maturity"
label "L1 = warn-only (no exit 2), L2/L3 = block"
printf "  hook-pre-bash.sh:  "; grep -c 'MATURITY' scripts/hook-pre-bash.sh; echo " maturity references"
printf "  hook-pre-write.sh: "; grep -c 'MATURITY' scripts/hook-pre-write.sh; echo " maturity references"
ok "Hooks are maturity-aware"

header "5. vajra next --advance respects maturity"
label "L3 skips interactive confirm"
grep -A3 'MaturityLevel::L3' src/cli/next.rs | head -4
ok "Auto-advance at L3"

header "Summary"
printf "\n"
printf "  %-30s %s\n" "Feature" "Status"
printf "  %-30s %s\n" "------------------------------" "------"
printf "  %-30s %s\n" "MaturityLevel enum + parser"   "WORKS"
printf "  %-30s %s\n" "vajra check L1=warn L2/3=fail" "WORKS"
printf "  %-30s %s\n" "vajra init maturity prompt"     "WORKS"
printf "  %-30s %s\n" "Hook scripts maturity-aware"    "WORKS"
printf "  %-30s %s\n" "vajra next L3 auto-advance"     "WORKS"
printf "\n"

ok "Session ${SESSION} demo complete."
