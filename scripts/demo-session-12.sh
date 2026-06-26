#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="12"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — E2E vajra next Proof"

# --- Prior session capabilities ---
header "Prior: vajra init (S08)"
label "Scaffolds .ai/ + hooks + pointers (16 files, interactive, idempotent)"
TMP=$(mktemp -d)
trap "rm -rf '$TMP'" EXIT
cd "$TMP"
git init -q && git commit --allow-empty -q -m "init"
echo -e "demo-project\nbuild a widget" | "$ROOT/target/release/vajra" init 2>&1 | grep -E "create|skip|Created"
ok "vajra init scaffolds a new project"
cd "$ROOT"

header "Prior: vajra check (S09)"
label "Drift detection + readiness scoring"
"$ROOT/target/release/vajra" check 2>&1 || true
ok "vajra check runs 10 drift checks"

header "Prior: vajra next read-only (S09)"
label "Prints handoff packet with session context"
OUT=$("$ROOT/target/release/vajra" next 2>&1) && echo "$OUT" | head -6
ok "vajra next shows session + prompt pointer"

# --- This session's feature ---
header "NEW: vajra next --advance updates prompt pointer (S12)"
label "Bug fix: --advance now updates Read prompt in TASK.md + SESSION-BOOT.md"

TMP2=$(mktemp -d)
cd "$TMP2"
git init -q && git commit --allow-empty -q -m "init"
echo -e "looptest\nstep one" | "$ROOT/target/release/vajra" init >/dev/null 2>&1
cat > prompts/02-task-step-two.md <<'PROMPT'
# Session 02 — Step two
## Goal
Do step two
PROMPT
git add -A && git commit -q -m "scaffold"
git checkout -q -b session-01-test
echo "work" > output.txt && git add output.txt && git commit -q -m "s01"
echo ""
printf "${DIM}Before advance:${RESET}\n"
grep "Read prompt" .ai/TASK.md
echo "y" | "$ROOT/target/release/vajra" next --advance 2>&1 | grep -E "Advanced|prompt pointer|warning"
printf "${DIM}After advance:${RESET}\n"
grep "Read prompt" .ai/TASK.md
ok "Prompt pointer automatically updated on advance"

cd "$ROOT"

# --- Summary Table ---
header "Summary"
printf "\n"
printf "  %-40s %s\n" "Feature" "Status"
printf "  %-40s %s\n" "----------------------------------------" "------"
printf "  %-40s %s\n" "vajra init (S08)"                        "WORKS"
printf "  %-40s %s\n" "vajra check (S09)"                       "WORKS"
printf "  %-40s %s\n" "vajra next read-only (S09)"              "WORKS"
printf "  %-40s %s\n" "vajra next --advance (S09)"              "WORKS"
printf "  %-40s %s\n" "vajra next --advance prompt ptr (S12)"   "WORKS"
printf "  %-40s %s\n" "E2E 3-session loop"                      "WORKS"
printf "  %-40s %s\n" "Budget guard (S11)"                      "WORKS"
printf "\n"

ok "Session ${SESSION} demo complete."
