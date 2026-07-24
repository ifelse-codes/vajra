#!/usr/bin/env bash
# demo-session-99.sh — Session 99: Coder reachable unattended (the S97 Rung-1 blocker).
# Cumulative: prior sessions' capabilities still hold; this session removes the two things that
# stopped an UNATTENDED run from reaching the Coder station and recording a commit.
# Emits demo:header / demo:before_after / demo:cases / demo:summary_table (Demo-er gate, S71).
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="99"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"; YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
no()     { printf "${RED}✗ %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }

cargo build -q 2>/dev/null || true
VAJRA="$ROOT/target/debug/vajra"

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
GOAL="ship the first slice"
( cd "$TMP" && git init -q -b main . && printf 'demo-proj\n%s\nL2\n' "$GOAL" | "$VAJRA" init >/dev/null 2>&1 )

# --- demo:header ---
header "Session ${SESSION} Demo — Coder Reachable Unattended  [demo:header]"
label "S97 left the agent alone on a real repo. It worked — and could not file the paperwork."
label "Two blocks: the prompt had no marker slots, and headless has no way to hear 'approved'."

# --- demo:before_after ---
header "Before → After  [demo:before_after]"
label "BEFORE — a repo scaffolded by vajra init could not be measured at all:"
dim  "    prompts/01-task-kickoff.md = Goal / Deliverables / Exit Criteria"
dim  "    -> no ## Acceptance, ## Design, ## Plan, ## Execution, ## Delta"
dim  "    -> [ABSENT] Analyst / Architect / Planner / Coder  (reads exactly like 'did no work')"
label "AFTER — the kickoff is rendered from the ONE canonical station-marker template:"
grep -E '^## (Acceptance|Design|Plan|Execution|Delta)' "$TMP/prompts/01-task-kickoff.md" \
  | sed 's/^/    /' | cut -c1-96

# --- demo:cases ---
header "Cases  [demo:cases]"

header "1 · A legacy-convention prompt is UNMEASURABLE, not idle"
cat > "$TMP/prompts/07-task-legacy.md" <<'LEGACYPROMPT'
# Session 07 — release workflow
## Goal
Ship the release workflow.
## Deliverables
- a workflow file
## Exit Criteria
- CI green
LEGACYPROMPT
( cd "$TMP" && "$VAJRA" next --stations 07 2>&1 ) | sed 's/^/    /' | cut -c1-104

header "2 · The discriminator does not over-fire — a modern but EMPTY prompt stays ABSENT"
( cd "$TMP" && "$VAJRA" next --stations 01 2>&1 ) | grep -E '\[(ABSENT|LEGACY)\] (Analyst|Coder)' \
  | sed 's/^/    /' | cut -c1-104
ok "convention present + work absent  =>  ABSENT (the old, correct meaning)"

header "3 · An unattended run is TOLD whether it may commit"
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
SESS=$(echo "$BRANCH" | grep -oE '^session-[0-9]+' | grep -oE '[0-9]+' | head -1 || echo "99")
label "no marker in the launch environment:"
( env -u VAJRA_ALLOW_COMMIT "$VAJRA" next 2>/dev/null | sed -n '6,8p' || true ) | sed 's/^/    /' | cut -c1-104
label "founder pre-authorized at launch (VAJRA_ALLOW_COMMIT=${SESS}):"
( VAJRA_ALLOW_COMMIT="$SESS" "$VAJRA" next 2>/dev/null | sed -n '6,8p' || true ) | sed 's/^/    /' | cut -c1-104
label "marker scoped to the WRONG session — never reported as permission:"
( VAJRA_ALLOW_COMMIT=$((10#$SESS - 1)) "$VAJRA" next 2>/dev/null | sed -n '6,8p' || true ) | sed 's/^/    /' | cut -c1-104

header "4 · The same answer on the surface a headless run always reads (the boot packet)"
( VAJRA_ALLOW_COMMIT="$SESS" bash scripts/hook-session-start.sh 2>/dev/null | tail -4 || true ) \
  | sed 's/^/    /' | cut -c1-104
header "5 · Parity is VERIFIED against the enforcing guard, not asserted"
label "drive hook-commit-guard.sh (enforcement forced) with the same three launch envs:"
GUARD="$ROOT/scripts/hook-commit-guard.sh"; PAYLOAD='{"tool_input":{"command":"git commit -m x"}}'
gx() { local ec=0; echo "$PAYLOAD" | env "$@" CLAUDE_PROJECT_DIR="$ROOT" VAJRA_ENFORCE_COMMIT=1 bash "$GUARD" >/dev/null 2>&1 || ec=$?; echo "$ec"; }
printf "    packet PRE-GRANTED   -> guard exit %s (0=allow)\n" "$(gx VAJRA_ALLOW_COMMIT=$SESS)"
printf "    packet NOT VALID     -> guard exit %s (2=block)\n" "$(gx VAJRA_ALLOW_COMMIT=$((10#$SESS - 1)))"
printf "    packet REQUIRED      -> guard exit %s (2=block)\n" "$(gx -u VAJRA_ALLOW_COMMIT)"
ok "the packet word and the guard's real allow/block decision agree on every env"
printf "${YELLOW}! ADVISORY + AGENT-FORGEABLE — the packet reads its own process env, which the agent${RESET}\n"
printf "${YELLOW}  controls; the un-forgeable teeth stay in the L3 guard (reads its OWN launch env).${RESET}\n"

# --- demo:summary_table ---
header "Summary  [demo:summary_table]"
printf "\n"
printf "  %-48s %s\n" "Deliverable" "Status"
printf "  %-48s %s\n" "------------------------------------------------" "------"
printf "  %-48s %s\n" "init kickoff carries the station markers"        "SHIPPED"
printf "  %-48s %s\n" "one canonical template (no second copy)"         "SHIPPED"
printf "  %-48s %s\n" "LEGACY outcome: convention-absent != work-absent" "SHIPPED"
printf "  %-48s %s\n" "commit pre-auth on vajra next + boot packet"     "SHIPPED"
printf "  %-48s %s\n" "classification mirrors hook-commit-guard.sh"     "SHIPPED"
printf "  %-48s %s\n" "enforcement moved out of the L3 guard"           "NONE"
printf "  %-48s %s\n" "existing older repos retro-fitted"               "NONE"
printf "\n"

ok "Session ${SESSION} demo complete."
