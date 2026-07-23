#!/usr/bin/env bash
# demo-session-98.sh — Session 98: reposition to the autopilot trust layer (pipeline = engine).
# Cumulative: prior sessions' capabilities still hold; this session is a docs/direction lock —
# it re-leads VISION, records DECISION-005, and installs the 6-Month Autopilot Plan in ROADMAP.
# Emits demo:header / demo:before_after / demo:cases / demo:summary_table (Demo-er gate, S71).
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="98"
DECISION="docs/decisions/DECISION-005-autopilot-trust.md"
VISION="VISION.md"
ROADMAP=".ai/ROADMAP.md"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"; YELLOW="\033[33m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
no()     { printf "${RED}✗ %s${RESET}\n" "$1"; }
show()   { if grep -qiF "$2" "$1"; then ok "$3"; else no "MISSING: $3"; fi; }

# --- demo:header ---
header "Session ${SESSION} Demo — Autopilot-Trust Reposition  [demo:header]"
label "The pitch stops being the mechanism and becomes the outcome."
label "Vajra: 'a governed 8-station SDLC pipeline'  →  'the autopilot trust layer'."

# --- demo:before_after ---
header "Before → After  [demo:before_after]"
label "BEFORE — VISION led with the mechanism (pipeline = the pitch):"
echo  "  \"Vajra is a governed multi-agent SDLC pipeline...\""
label "AFTER — VISION leads with the outcome; the pipeline is the ENGINE:"
grep -m1 -F 'autopilot trust layer for AI coding agents' "$VISION" | sed 's/^[* ]*/  /' | cut -c1-100
echo  "  ... the 8 stations now EARN the trust; they are not the pitch."

# --- demo:cases ---
header "Cases  [demo:cases]"

header "1 · DECISION-005 records the direction lock"
show "$DECISION" 'AUTOPILOT TRUST LAYER'     "reframe: pipeline = engine, not pitch"
show "$DECISION" 'PAUSE TO PROVE'            "provenance: CTO audit verdict + founder interview"
show "$DECISION" 'machinery-freeze rule'     "the machinery-freeze rule"

header "2 · The Autopilot Ladder replaces the feelings-based release bar"
awk '/^### The Autopilot Ladder/{f=1} f&&/^\| \*\*[123]\*\*/{print "    "$0} /^### Release backstop/{f=0}' "$ROADMAP" \
  | sed -E 's/ +\|/ |/g' | cut -c1-110

header "3 · A dated backstop kills the moving bar"
grep -m1 -F 'v0.1 ships when Rung 3 passes once OR on 2026-09-15' "$ROADMAP" | sed 's/^[* ]*/    /' | cut -c1-100

header "4 · Two kill signals (technical + market)"
show "$ROADMAP" 'Kill A'                                        "Kill A (founder — trust loop keeps failing)"
show "$ROADMAP" 'standalone agent-PR acceptance checker'       "Kill B (auditor — pivot to acceptance checker)"

header "5 · Honesty rows preserved (no claim beyond evidence)"
show "$VISION" '0 cross-agent code'                            "cross-agent still 0 code"
show "$VISION" 'never in README/marketing until measured'     "compression never-claim"
show "$VISION" 'stated hypothesis'                             "'better work' stays a hypothesis"

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-46s %s\n" "Deliverable" "Status"
printf "  %-46s %s\n" "----------------------------------------------" "------"
printf "  %-46s %s\n" "DECISION-005 (reframe + Ladder + kills)"        "SHIPPED"
printf "  %-46s %s\n" "VISION lead = autopilot trust; pipeline=engine" "SHIPPED"
printf "  %-46s %s\n" "ROADMAP 6-Month Autopilot Plan"                 "SHIPPED"
printf "  %-46s %s\n" "Machinery-freeze rule in Rules"                 "SHIPPED"
printf "  %-46s %s\n" "Honesty rows preserved"                         "SHIPPED"
printf "  %-46s %s\n" "src/ touched"                                   "NONE"
printf "\n"

ok "Session ${SESSION} demo complete."
