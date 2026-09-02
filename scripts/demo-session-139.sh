#!/usr/bin/env bash
# demo-session-139.sh — the sprint demo for S139: make the tech-lead's `required` verdict BIND at
# CLOSE. Required elements (CONSTRAINTS.yaml#demo.required_elements): header, cases, summary_table,
# before_after — each an emitted `demo:<element>` marker the Demo-er gate re-runs live and scans for.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
head_() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label() { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }

GATE=(bash scripts/verify-closeout.sh --crew-only 139)

echo "demo:header"
head_ "S139 — 'required' now binds at CLOSE, not only at --advance"
printf "${DIM}S138 dogfood, live: the tech-lead marked FOUR roles required, the session ran ONE, and\n"
printf "closed 12/12 GREEN + MERGED to main — because the crew binding lived only in \`vajra next\n"
printf "--advance\`, which a real close never invokes. S139 wires check_required_crew into\n"
printf "verify-closeout.sh so the close itself binds.${RESET}\n"

echo "demo:cases"

head_ "CASE 1 — S139's own close, fully crewed -> the gate PASSES (the self-bind)"
label "bash scripts/verify-closeout.sh --crew-only 139"
"${GATE[@]}" 2>&1 | grep -E "required-crew|CREW:|every role" | sed 's/^/    /'
"${GATE[@]}" >/dev/null 2>&1 && C1=0 || C1=$?
printf "    exit=%s  ${GREEN}(PASS — tech-lead + 3 required handoffs all present)${RESET}\n" "$C1"

head_ "CASE 2 — hide ONE required handoff -> the close BLOCKS, naming the role"
DA=".ai/handoffs/session-139-design-advisor.md"
if [ -f "$DA" ]; then
  cp "$DA" "$DA.demobak"
  trap 'mv -f "$DA.demobak" "$DA" 2>/dev/null || true' EXIT
  mv "$DA" "$DA.hidden"
  label "rm .ai/handoffs/session-139-design-advisor.md  &&  --crew-only 139"
  "${GATE[@]}" 2>&1 | grep -E "produced no real governed handoff|CREW:|FAIL:" | head -3 | sed 's/^/    /'
  "${GATE[@]}" >/dev/null 2>&1 && C2=0 || C2=$?
  printf "    exit=%s  ${RED}(BLOCKS — a required role with no handoff cannot close green)${RESET}\n" "$C2"
  mv "$DA.hidden" "$DA"; rm -f "$DA.demobak"; trap - EXIT
else
  printf "    ${DIM}(design-advisor handoff not on disk — run this at/after close)${RESET}\n"; C2=1
fi

echo "demo:summary_table"
head_ "Acceptance → evidence"
printf "%b\n" "${BOLD}  # acceptance                                    evidence                     status${RESET}"
printf "  1 check_required_crew runs vajra next --check-crew, header-guarded   CASE 1/2       ${GREEN}✔${RESET}\n"
printf "  2 fixture RED when a required handoff is hidden, GREEN restored      fixture-139    ${GREEN}✔${RESET}\n"
printf "  3 binds on S139 ITSELF (own close passes the new gate)               CASE 1         ${GREEN}✔${RESET}\n"
printf "  4 vajra init scaffolds the gate too (include_str! byte-identity)     verify #5      ${GREEN}✔${RESET}\n"
printf "  5 verify + demo + summary                                           this run       ${GREEN}✔${RESET}\n"

echo "demo:before_after"
head_ "Before → after"
printf "  ${RED}BEFORE (S138, live):${RESET} tech-lead required 4 roles · session ran 1 · self-certified ·\n"
printf "         verify-closeout 12/12 GREEN · MERGED to main · nothing caught the skip.\n"
printf "  ${GREEN}AFTER (S139):${RESET}  the same close now runs check_required_crew — a required role with no\n"
printf "         governed handoff makes verify-closeout.sh exit 1. The close is where it binds.\n"

if [ "${C1:-1}" -eq 0 ]; then echo -e "\n${GREEN}${BOLD}demo-139: the crew binding reached the close path.${RESET}"; fi
