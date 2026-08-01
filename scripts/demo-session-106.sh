#!/usr/bin/env bash
# Demo — Session 106: make it installable (v0.1) + the instrument that proves it.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after — each emitted as a `demo:<element>` marker. The Demo-er gate (S71) RE-RUNS this
# script LIVE at close and blocks on a non-zero exit or a missing element. When a user asks to SEE
# the demo, present it as an interactive HTML slide deck (terminal-styled, PASS/FAIL coloring,
# scorecard) — this bash script is for CI/verify.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="106"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }

# --- demo:header ---
header "Session ${SESSION} Demo — v0.1 is installable, and an instrument proves it  [demo:header]"
label "One line: a stranger can 'cargo install' vajra from a clean checkout, and scripts/install-smoke.sh proves it (fresh install -> init -> next), failing non-zero if broken."

# --- demo:before_after ---
header "Before -> After  [demo:before_after]"
label "BEFORE — the README said 'works today' but NOTHING measured it:"
printf "  ${DIM}S105 meta-check: 'vajra next --stations' read 7/8 on S101 while every install path was broken.${RESET}\n"
printf "  ${DIM}No script answered 'can a stranger install and run vajra?' — installability was a feeling.${RESET}\n"
label "AFTER — the falsifiable instrument, run live below:"
printf "  ${DIM}scripts/install-smoke.sh: cargo install (clean source) -> fresh-dir 'vajra init' -> 'vajra next', each asserted.${RESET}\n"

# --- demo:cases ---
header "Cases  [demo:cases]"

header "1 · The install instrument runs GREEN from a clean source"
label "Live: scripts/install-smoke.sh (path mode — installs THIS tree, hermetic/offline)"
if bash scripts/install-smoke.sh; then
  ok "a stranger can install and run vajra (exit 0)"
else
  no "install smoke failed — the install path is broken"; exit 1
fi

header "2 · The instrument can say NO (falsifiable — not a rubber stamp)"
label "Live: point it at an empty dir with no Cargo.toml; it MUST fail non-zero"
BROKEN="$(mktemp -d)"
if VAJRA_SMOKE_PATH="$BROKEN" bash scripts/install-smoke.sh >/tmp/vajra-demo-broken.log 2>&1; then
  no "instrument returned 0 on a broken install — it is NOT a real gate"; rm -rf "$BROKEN"; exit 1
else
  ok "broken install -> SMOKE FAIL, exit non-zero (this is the point)"
  printf "  ${DIM}%s${RESET}\n" "$(grep -m1 'SMOKE FAIL' /tmp/vajra-demo-broken.log || true)"
fi
rm -rf "$BROKEN"

header "3 · README truth-pass — only working paths are un-marked"
label "The working one-liner (now proven):"
grep -m1 "cargo install --git https://github.com/ifelse-codes/vajra" README.md | sed 's/^/  /'
label "The unshipped paths stay honestly marked (no faked green):"
grep -m1 "NOT YET PUBLISHED" README.md | sed 's/^/  /'

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-38s %s\n" "Deliverable" "Status"
printf "  %-38s %s\n" "--------------------------------------" "------"
printf "  %-38s %s\n" "cargo install (git/path) works today"   "WORKS"
printf "  %-38s %s\n" "install-smoke.sh instrument (7 checks)"  "GREEN"
printf "  %-38s %s\n" "instrument is falsifiable (fails broken)" "PROVEN"
printf "  %-38s %s\n" "README shows only working paths"          "TRUE"
printf "  %-38s %s\n" "unshipped paths still marked"             "HONEST"
printf "\n"

ok "Session ${SESSION} demo complete."
