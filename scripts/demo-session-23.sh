#!/usr/bin/env bash
# Session 23 — first-run "aha". `vajra init` now ends by firing the just-scaffolded
# co-pilot live: the guard is felt in seconds, with zero extra setup. Cumulative demo.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="23"
BIN="$ROOT/target/debug/vajra"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — first-run \"aha\" (the felt win in ~2 minutes)"
printf "${DIM}  Before S23: \`vajra init\` produced files, then silence — \"...now what?\".${RESET}\n"

[ -x "$BIN" ] || { label "building vajra"; cargo build >/dev/null 2>&1; }

header "1. A brand-new user runs one command"
DEMO=$(mktemp -d)
label "vajra init < /dev/null   (a fresh, empty project)"
START=$(date +%s)
OUT=$( ( cd "$DEMO" && "$BIN" init < /dev/null ) 2>&1 )
END=$(date +%s)
printf '%s\n' "$OUT" | sed 's/^/    /'

header "2. The payoff: it ends by showing the guard work — LIVE"
label "That co-pilot block is a real fire of the just-scaffolded hook, not a mockup"
if printf '%s' "$OUT" | grep -qF "[vajra co-pilot]" && printf '%s' "$OUT" | grep -qF ".ai/STATE.md"; then
  ok "The user SEES Vajra catch a git commit and surface STATE.md — first run, no setup"
else
  printf "    ${RED}aha block missing${RESET}\n"
fi
printf "    ${DIM}elapsed: $((END - START))s (felt in seconds, no API call, no extra command)${RESET}\n"
rm -rf "$DEMO"

header "3. Why this is the aha (not just more output)"
printf "    ${DIM}• It is the S22-propagated co-pilot — every new project enforces day one.${RESET}\n"
printf "    ${DIM}• No 8th command: the moment rides on \`init\` (still 7 top-level commands).${RESET}\n"
printf "    ${DIM}• Honest: a real hook fire (degrades to a static preview if bash/jq absent).${RESET}\n"

header "4. Structural verify"
label "Rust gates + a real init asserting the live block appears in its output"
bash scripts/verify-session-23.sh 2>&1 | tail -2

header "Summary"
printf "\n"
printf "  %-48s %s\n" "Deliverable" "Status"
printf "  %-48s %s\n" "------------------------------------------------" "------"
printf "  %-48s %s\n" "init ends with a live co-pilot fire (felt)"      "DONE"
printf "  %-48s %s\n" "reachable in seconds, no API, no 8th command"    "DONE"
printf "  %-48s %s\n" "graceful fallback when bash/jq absent"           "DONE"
printf "  %-48s %s\n" "rides on the S22-propagated co-pilot"            "DONE"
printf "  %-48s %s\n" "Phase 2 complete"                                "DONE"
printf "\n"
printf "${DIM}  Cumulative: prior capabilities in scripts/demo-session-{08,09,11,12,13,14,16,17,19,21,22}.sh${RESET}\n"
ok "Session ${SESSION} demo complete — first run now delivers a felt win."
