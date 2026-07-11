#!/usr/bin/env bash
# Session 56 — The fidelity GATE (teeth). Demo: closeout can no longer pass by self-certifying.
# scripts/verify-closeout.sh now STRUCTURALLY REQUIRES an independent fidelity review and FAILS closeout
# on a missing / present-but-hollow / REJECT review — unless the founder records an UN-FORGEABLE waiver
# (an env var the agent cannot Write into a tracked file). First live act: block S54's real REJECT.
# Cumulative: rides the L4 closeout gate + the S54/S55 reviewer brain; no 8th command, no second store.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

CLO="scripts/verify-closeout.sh"

header "Session 56 Demo — the fidelity gate: closeout with teeth"
printf "${DIM}  DECISION-002: green tests prove DISCIPLINE, never FIDELITY. The gate makes an${RESET}\n"
printf "${DIM}  independent acceptance verdict structurally required to close a session.${RESET}\n"

# A throwaway session-N repo state we can feed the gate.
SCRATCH=$(mktemp -d); trap 'rm -rf "$SCRATCH"' EXIT
mkdir -p "$SCRATCH/sessions"
N=88

writerev() { # $1=verdict(ACCEPT|REJECT|NONE)  $2=optional extra line
  local f="$SCRATCH/sessions/session-${N}-review.md"
  { echo "# Session ${N} review"; echo
    echo "| # | Requirement | Verdict | Evidence |"; echo "|---|---|---|---|"
    echo "| 1 | a | SHIPPED | x |"; echo "| 2 | b | PARTIAL | x |"; echo "| 3 | c | NOT-BUILT | x |"
    echo; echo "${2:-}"
    if [ "$1" != NONE ]; then echo "**Verdict:** $1"; fi
  } > "$f"
}
run() { env "$@" CLAUDE_PROJECT_DIR="$SCRATCH" bash "$ROOT/$CLO" --fidelity-only "$N" >/dev/null 2>&1; }

# ---------------------------------------------------------------------------
header "1. MISSING review — a session that never got an independent pass"
label "verify-closeout.sh --fidelity-only $N   (no sessions/session-$N-review.md)"
if run; then bad "closeout PASSED (leak!)"; else ok "closeout BLOCKED — no self-certified close"; fi

# ---------------------------------------------------------------------------
header "2. PRESENT-BUT-HOLLOW review — a table but no real verdict (the S54 'fakest green')"
writerev NONE "## Overall verdict"
label "verify-closeout.sh --fidelity-only $N   (heading, no canonical **Verdict:** line)"
if run; then bad "closeout PASSED (present ≠ real)"; else ok "closeout BLOCKED — present is not proof"; fi

# ---------------------------------------------------------------------------
header "3. REJECT review — the auditor found 'shipped 1 of N'"
writerev REJECT ""
label "verify-closeout.sh --fidelity-only $N   (**Verdict:** REJECT)"
if run; then bad "closeout PASSED (leak!)"; else ok "closeout BLOCKED on REJECT"; fi

# ---------------------------------------------------------------------------
header "4. FORGED in-file waiver — the agent writes 'Waiver: APPROVED' into the review"
writerev REJECT "**Human-Waiver:** APPROVED by founder"
label "verify-closeout.sh --fidelity-only $N   (marker in the file, NO env var)"
if run; then bad "closeout PASSED — a text marker bypassed the gate!"; else ok "closeout STILL BLOCKED — a marker the agent can write is not a waiver"; fi

# ---------------------------------------------------------------------------
header "5. FOUNDER waiver — an env var the agent cannot set in the launch environment"
label "VAJRA_CLOSEOUT_WAIVER=$N verify-closeout.sh --fidelity-only $N"
if run VAJRA_CLOSEOUT_WAIVER="$N" VAJRA_CLOSEOUT_WAIVER_REASON="founder accepts, gaps tracked"; then
  ok "closeout PASSES — only the founder-controlled env var waives (recorded)"
else bad "waiver did not apply"; fi

# ---------------------------------------------------------------------------
header "6. ACCEPT review — a faithful build of the whole contract"
writerev ACCEPT ""
label "verify-closeout.sh --fidelity-only $N   (**Verdict:** ACCEPT, full table)"
if run; then ok "closeout PASSES on an independent ACCEPT"; else bad "ACCEPT was blocked"; fi

# ---------------------------------------------------------------------------
header "7. THE DOGFOOD — point the gate at S54's real REJECT (S56 prompt Q3)"
label "verify-closeout.sh --fidelity-only 54   (against sessions/session-54-review.md)"
if bash "$CLO" --fidelity-only 54 >/dev/null 2>&1; then
  bad "S54 REJECT slipped through"
else
  ok "the gate BLOCKS S54 live — closing S54 now needs the Analyst gaps fixed or a recorded waiver"
fi

header "Scorecard"
printf "  %-46s ${GREEN}enforced${RESET}\n" "missing / hollow / REJECT review"
printf "  %-46s ${GREEN}un-forgeable${RESET}\n" "waiver = founder env var, not a file marker"
printf "  %-46s ${GREEN}live${RESET}\n" "blocks S54's REJECT (not ceremony)"
printf "  %-46s ${GREEN}on-spine${RESET}\n" "rides verify-closeout.sh — no 8th command"
printf "\n${DIM}  Bash script is for CI/verify; the interactive HTML deck is the agent's job when asked.${RESET}\n"
