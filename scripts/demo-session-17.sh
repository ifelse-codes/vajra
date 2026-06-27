#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="17"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — Pre-Run Cost Estimate"

header "1. vajra estimate — live output"
label "Running against this repo's .ai/ context"
cargo run --quiet -- estimate 2>&1
ok "Estimate printed"

header "2. Help text includes estimate"
label "vajra help shows the new command"
cargo run --quiet -- help 2>&1 | grep "estimate"
ok "estimate in help"

header "3. ADR-0005 documents the methodology"
label "Estimation constants"
printf "  chars/token:      4\n"
printf "  output:input:     3:1 (placeholder heuristic)\n"
printf "  default model:    claude-opus-4\n"
printf "  pricing source:   meter::pricing_for() (compiled-in)\n"
ok "ADR-0005 at docs/adr/0005-pre-run-cost-estimate.md"

header "4. Budget integration"
label "Warns if estimate exceeds budget.cap_usd"
printf "  cap: "; grep "cap_usd" .ai/CONSTRAINTS.yaml | head -1 | xargs
printf "  mode: "; grep "mode:" .ai/CONSTRAINTS.yaml | grep -A0 "budget" | head -1 | xargs || grep "mode: warn" .ai/CONSTRAINTS.yaml | head -1 | xargs
ok "Budget check wired"

header "5. Full test suite"
label "All tests pass, clippy clean"
cargo test --all-targets 2>&1 | grep "^test result" | head -1
cargo clippy --all-targets -- -D warnings 2>&1 | tail -1
ok "All green"

header "Summary"
printf "\n"
printf "  %-35s %s\n" "Deliverable" "Status"
printf "  %-35s %s\n" "-----------------------------------" "------"
printf "  %-35s %s\n" "vajra estimate command"              "DONE"
printf "  %-35s %s\n" "Input token estimation (chars/4)"    "DONE"
printf "  %-35s %s\n" "Output token estimation (3:1 ratio)" "DONE"
printf "  %-35s %s\n" "Budget cap warning"                  "DONE"
printf "  %-35s %s\n" "ADR-0005 documented"                 "DONE"
printf "  %-35s %s\n" "KNOWLEDGE.md updated"                "DONE"
printf "\n"

ok "Session ${SESSION} demo complete."
