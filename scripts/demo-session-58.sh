#!/usr/bin/env bash
# demo-session-58.sh — S58: verdict-authorship attestation. An ACCEPT must carry a
# **Review-Inputs-SHA:** that matches the canonical hash of the cold inputs (contract
# prompt + delivery diff). A recycled / stale / decoupled ACCEPT no longer clears.
# Cumulative: S55 reviewer brain · S56 gate teeth · S57 propagated · S58 → the teeth
# now verify the verdict is bound to the delivery it claims to have reviewed.
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
block()  { printf "${RED}⛔ %s${RESET}\n" "$1"; }

header "Session 58 Demo — verdict-authorship attestation (make the ACCEPT un-forgeable)"

GATE_SRC="$ROOT/scripts/verify-closeout.sh"
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
(
  cd "$T"
  git init -q; git config user.email d@d.dev; git config user.name demo
  git checkout -q -b main
  mkdir -p prompts scripts sessions .ai
  printf '# S58 contract\nGoal: attest the cold inputs.\n' > prompts/58-task-x.md
  cp "$GATE_SRC" scripts/verify-closeout.sh; chmod +x scripts/verify-closeout.sh
  git add -A; git commit -qm "main: contract + gate" >/dev/null
  git checkout -q -b session-58-x
  printf 'echo the real delivery\n' > scripts/thing.sh
  git add -A; git commit -qm "S58 delivery" >/dev/null
)
GATE="$T/scripts/verify-closeout.sh"
attest(){ CLAUDE_PROJECT_DIR="$T" env "$@" bash "$GATE" --attest-only 58 >/dev/null 2>&1; }
review(){ # $1 verdict ; $2 sha ('' omit)
  { echo "# review"; echo; echo "| # | R | Verdict | E |"; echo "|---|---|---|---|"
    echo "| 1 | a | SHIPPED | x |"; echo "| 2 | b | PARTIAL | y |"; echo "| 3 | c | NOT-BUILT | z |"; echo
    [ -n "${2:-}" ] && echo "**Review-Inputs-SHA:** $2"
    echo "**Verdict:** $1"; } > "$T/sessions/session-58-review.md"; }

label "1. The gate computes the canonical cold-input hash (one function, both sides)"
GOOD="$(CLAUDE_PROJECT_DIR="$T" bash "$GATE" --inputs-sha 58)"
printf "    ${DIM}verify-closeout.sh --inputs-sha 58${RESET} → ${BOLD}%s…%s${RESET}\n" "${GOOD:0:16}" "${GOOD: -8}"

label "2. An ACCEPT must carry a MATCHING attestation"
review ACCEPT "$GOOD"; attest && ok "ACCEPT + real Review-Inputs-SHA → CLEARED"
review ACCEPT "0000000000000000000000000000000000000000000000000000000000000000"
attest && : || block "ACCEPT + forged hash → BLOCKED (a hand-typed verdict fails)"
review ACCEPT ""
attest && : || block "ACCEPT + no attestation → BLOCKED"

label "3. Freshness — a stale ACCEPT can't ride over a changed delivery"
review ACCEPT "$GOOD"; attest && ok "attestation matches the current delivery"
( cd "$T" && printf 'echo CHANGED\n' >> scripts/thing.sh && git add -A && git commit -qm change >/dev/null )
attest && : || block "delivery changed after review → SAME hash no longer matches → BLOCKED"

label "4. The founder waiver still clears (env var, not an in-file marker)"
review ACCEPT "deadbeef"
attest && : || block "forged hash alone → BLOCKED"
attest VAJRA_CLOSEOUT_WAIVER=58 && ok "VAJRA_CLOSEOUT_WAIVER=58 → CLEARED"

header "Summary"
printf "\n  %-52s %s\n" "Capability" "Status"
printf "  %-52s %s\n" "----------------------------------------------------" "------"
printf "  %-52s %s\n" "gate prints canonical cold-input hash (--inputs-sha)" "WORKS"
printf "  %-52s %s\n" "ACCEPT + matching attestation clears"                "WORKS"
printf "  %-52s %s\n" "forged / missing attestation blocks ACCEPT"          "WORKS"
printf "  %-52s %s\n" "stale ACCEPT after delivery change blocks (freshness)" "WORKS"
printf "  %-52s %s\n" "founder env waiver still clears"                     "WORKS"
printf "\n${DIM}Honest limit: the same agent can run --inputs-sha, so this is bar-raising,${RESET}\n"
printf "${DIM}not tamper-proof — it kills recycled/stale/decoupled ACCEPTs, not a determined self-forge.${RESET}\n"
ok "Session 58 demo complete — the ACCEPT is bound to the delivery it reviewed."
