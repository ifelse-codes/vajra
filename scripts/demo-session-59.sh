#!/usr/bin/env bash
# demo-session-59.sh — S59: the attested-verdict delta ledger. A DERIVED, hash-chained
# view over sessions/*-review.md + git (no new store): each session contributes one
# record {N, verdict, input_sha}; the head hash fingerprints the whole ordered history.
# Editing any past verdict moves the head → tamper-EVIDENT. Cumulative: S55 reviewer
# brain · S56 gate teeth · S57 propagated · S58 verdict attested · S59 → verdicts chained
# into cross-session evidence (the moat's headline artifact, first code).
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
block()  { printf "${RED}⛔ %s${RESET}\n" "$1"; }

GATE="scripts/verify-closeout.sh"

header "Session 59 Demo — the attested-verdict delta ledger (the moat's first code)"

label "1) The real derived ledger over S54–S58 (verdict + attestation, hash-chained)"
bash "$GATE" --ledger

label "2) Clean tree — chain-verify: worktree matches committed HEAD"
if bash "$GATE" --ledger-verify; then ok "INTACT — every committed verdict record verifies"; fi

label "3) Tamper a PAST verdict (flip S54 REJECT→ACCEPT) — the chain catches it"
F="sessions/session-54-review.md"
restore(){ git checkout -q -- "$F" 2>/dev/null || true; rm -f "$F.bak"; }
trap restore EXIT
sed -i.bak 's/\*\*Verdict:\*\* REJECT/\*\*Verdict:\*\* ACCEPT/' "$F"
printf "${DIM}   (edited %s: **Verdict:** REJECT → ACCEPT)${RESET}\n" "$F"
if bash "$GATE" --ledger-verify; then
  block "chain did NOT catch the edit (unexpected)"
else
  block "TAMPER DETECTED — exit 1, first divergent session named above"
fi
restore
ok "S54 review restored to REJECT"

label "4) Honesty bar"
printf "   tamper-${GREEN}EVIDENT${RESET}: any past-verdict edit moves the head; git shows the diff.\n"
printf "   ${RED}NOT${RESET} tamper-proof: an in-repo editor can recompute the chain + rewrite history.\n"
printf "   No new store (derived view over sessions/*-review.md + git). No 8th command.\n"
printf "   Rides S57 include_str! → every ${BOLD}vajra init${RESET} scaffold inherits it. DECISION-004.\n"

header "Demo complete — run scripts/verify-session-59.sh for the full 22-check gate"
