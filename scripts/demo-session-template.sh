#!/usr/bin/env bash
# Template — copy to scripts/demo-session-NN.sh and customize per session.
# Demo scripts are narrative — they show what was built with real/mock data.
# Demos are cumulative: each session's demo includes prior session capabilities.
#
# The sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): seeing the demo, the
# user knows what THIS session delivered, and the before-and-after. The demo must SHOW
#   header · cases · summary_table · before_after
# by emitting a `demo:<element>` marker for each. The Demo-er gate (S71) RE-RUNS this script
# LIVE at close (`vajra next --check-demo NN`) and blocks on a non-zero exit or on an element
# missing from the live output — a recorded green is never trusted, and a hollow exit-0 demo
# fails the element scan. Markers are recorded evidence, the same honesty class as `covers: N`:
# emit each where its section really happens; stacking them defeats only yourself.
#
# NOTE: This bash script is for CI/verify. When a user asks to see the demo,
# the agent should present results as an interactive HTML slide deck
# (terminal-styled, auto-play, PASS/FAIL coloring, scorecard summary).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# === EDIT PER SESSION ===
SESSION="NN"
# ========================

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

# --- demo:header — what this session delivered, in one line ---
header "Session ${SESSION} Demo  [demo:header]"
# label "One line: the capability this session added."

# --- demo:before_after — the sprint-demo core ---
header "Before → After  [demo:before_after]"
label "BEFORE — what the product could not do until this session:"
# echo "  show the old behavior (or its absence) with a real command"
label "AFTER — the same flow, now working:"
# echo "  run the real command here; the output IS the evidence"

# --- demo:cases — run the real thing; each case is live output, not a claim ---
header "Cases  [demo:cases]"
# header "1 · Feature Name"
# label "Description of what this demonstrates"
# Run commands, show output, display results
# ok "What this proves"

# --- demo:summary_table — the scorecard ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-30s %s\n" "Feature" "Status"
printf "  %-30s %s\n" "------------------------------" "------"
# printf "  %-30s %s\n" "Feature name"                  "WORKS"
printf "\n"

ok "Session ${SESSION} demo complete."
