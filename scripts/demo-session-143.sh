#!/usr/bin/env bash
# demo-session-143.sh — the sprint demo for S143: the constitution joins the smooth upgrade. The
# S141/S142 `vajra-render-sha:` stamp now covers `.ai/AGENTS.md` — split into a user-owned FILLED
# header + a byte-identical GOVERNED body divided by GOVERNED_BODY_SENTINEL. The SINGLE
# `vajra init --sync-fleet` upgrades ONLY the body (preserving the header verbatim), and a pre-S143
# boundaryless constitution is the fifth state, NeedsBoundary — refused even with --overwrite-drifted.
# Required elements (CONSTRAINTS.yaml#demo.required_elements): header, cases, summary_table,
# before_after — each an emitted `demo:<element>` marker the Demo-er gate re-runs live and scans for.
# Cumulative: roles (S141) + hooks (S142) + the constitution (S143) all upgrade under one command.
# The summary_table marks are COMPUTED from the live case signals, never hardcoded. Runs the REAL binary.
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
head_() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label() { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
mk() { [ "$1" -eq 0 ] 2>/dev/null && printf "${GREEN}✔${RESET}" || printf "${RED}✗${RESET}"; }

S='<!-- vajra:governed-body - do not edit below this line - vajra owns and upgrades these bytes -->'
W="$(mktemp -d "${TMPDIR:-/tmp}/vajra-demo143-XXXXXX")"
trap 'rm -rf "$W"' EXIT
A="$W/.ai/AGENTS.md"

echo "demo:header"
head_ "S143 — one command upgrades everything: the constitution joins the fleet's smooth upgrade"
printf "${DIM}S141 gave the smooth upgrade to the fleet ROLES; S142 to the HOOKS. The constitution was the\n"
printf "last add-only render: a per-install FILLED template sync could not safely rewrite. S143 splits it\n"
printf "into a user-owned header (your project's name, kept) + a governed body (vajra owns, upgrades),\n"
printf "divided by a boundary sentinel. Same single command; the header is never touched.${RESET}\n"

echo "demo:cases"

head_ "CASE 1 — fresh install: the constitution scaffolds with a filled header + a STAMPED governed body"
label "cd \$tmp && vajra init  (project: acme-app)"
( cd "$W" && printf 'acme-app\nlock the charts\nL2\n' | "$VAJRA" init >/dev/null 2>&1 )
printf "  header (user's, filled):   %s\n" "$(head -1 "$A")"
printf "  boundary sentinel:         %s\n" "$(grep -m1 -F "$S" "$A")"
printf "  governed-body stamp:       %s\n" "$(tail -1 "$A")"
C1=0
{ grep -qF "$S" "$A" && tail -1 "$A" | grep -q '^<!-- vajra-render-sha:' && head -1 "$A" | grep -q 'acme-app'; } || C1=1
printf "  → header filled + body bounded + stamped: %b\n" "$(mk $C1)"

head_ "CASE 2 — a stamped OLDER body under a CUSTOM header → auto-upgraded, header PRESERVED verbatim"
label "plant an older governed body under a hand-edited header, then: vajra init --sync-fleet"
printf '# ACME Corp \xe2\x80\x94 Our Own Constitution\n\n> a preamble we hand-wrote and care about\n\n' > "$W/hdr"
printf '%s\n\n## Mandatory Load Order\n\nAN OLDER GOVERNED BODY\n' "$S" > "$W/pre"
h="$(shasum -a 256 < "$W/pre" | awk '{print $1}')"
{ cat "$W/hdr" "$W/pre"; printf '<!-- vajra-render-sha: %s -->\n' "$h"; } > "$A"
OUT2="$( cd "$W" && "$VAJRA" init --sync-fleet 2>&1 )"
printf "${DIM}%s${RESET}\n" "$(grep -E 'upgrade .ai/AGENTS.md' <<<"$OUT2" | head -1 | sed 's/^/    /')"
C2=0
{ grep -q "upgrade .ai/AGENTS.md" <<<"$OUT2" \
  && ! grep -q "AN OLDER GOVERNED BODY" "$A" \
  && python3 - "$A" "$S" "$W/hdr" <<'PY'
import sys
d=open(sys.argv[1],'rb').read(); i=d.find(sys.argv[2].encode())
sys.exit(0 if d[:i]==open(sys.argv[3],'rb').read() else 1)
PY
} || C2=1
printf "  header above the sentinel (must be the user's bytes, untouched):\n"
printf "${DIM}    %s\n    %s${RESET}\n" "$(head -1 "$A")" "$(sed -n '3p' "$A")"
printf "  → body auto-upgraded (no --overwrite-drifted) AND header byte-for-byte preserved: %b\n" "$(mk $C2)"

head_ "CASE 3 — a pre-S143 constitution (no boundary) → REFUSED even with --overwrite-drifted"
label "a legacy constitution with no sentinel, then: vajra init --sync-fleet --overwrite-drifted"
printf '# acme-app \xe2\x80\x94 AI Agent Constitution\n\n## Mandatory Load Order\n\nour real hand-written content\n' > "$A"
LEG="$(cat "$A")"
OUT3="$( cd "$W" && "$VAJRA" init --sync-fleet --overwrite-drifted 2>&1 )"; RC3=$?
printf "${DIM}%s${RESET}\n" "$(grep -E 'BODY|needs-boundary' <<<"$OUT3" | head -2 | sed 's/^/    /')"
printf "  it prints the exact line to paste:\n${DIM}    %s${RESET}\n" "$(grep -m1 -F "$S" <<<"$OUT3")"
C3=0
{ [ "$RC3" -eq 1 ] && grep -q "needs-boundary" <<<"$OUT3" && [ "$(cat "$A")" = "$LEG" ]; } || C3=1
printf "  → refused (exit 1), header NOT clobbered — the fill is safe: %b\n" "$(mk $C3)"

head_ "CASE 4 — the one-time migration: paste the sentinel, then it upgrades smoothly forever"
label "paste the sentinel above the load-order heading, then: vajra init --sync-fleet --overwrite-drifted"
awk -v s="$S" '/^## Mandatory Load Order/ && !d {print s "\n"; d=1} {print}' "$A" > "$W/mig"; mv "$W/mig" "$A"
OUT4="$( cd "$W" && "$VAJRA" init --sync-fleet --overwrite-drifted 2>&1 )"
OUT4b="$( cd "$W" && "$VAJRA" init --sync-fleet 2>&1 )"   # idempotent thereafter
C4=0
{ ! grep -q "our real hand-written content" "$A" \
  && grep -q ".ai/AGENTS.md (up to date)" <<<"$OUT4b" \
  && head -1 "$A" | grep -q 'acme-app'; } || C4=1
printf "  after migration the body is canonical, the title kept, and a re-run is: %s\n" "$(grep -m1 'up to date' <<<"$OUT4b" | sed 's/^ *//')"
printf "  → migrated once, smooth every run after (header preserved): %b\n" "$(mk $C4)"

echo "demo:summary_table"
head_ "S143 acceptance → shown live"
printf "  # Criterion                                                        Case      Result\n"
printf "  ─────────────────────────────────────────────────────────────────────────────────\n"
printf "  1 scaffold: filled header + governed body + boundary sentinel + stamp   CASE 1    %b\n" "$(mk $C1)"
printf "  2 body-scoped classify; StaleRender body auto-upgrades                  CASE 2    %b\n" "$(mk $C2)"
printf "  3 upgrade preserves the user header BYTE-FOR-BYTE                       CASE 2    %b\n" "$(mk $C2)"
printf "  3 boundaryless is NeedsBoundary — refused even with --overwrite-drifted CASE 3    %b\n" "$(mk $C3)"
printf "  4 the one-time migration then upgrades smoothly + idempotent            CASE 4    %b\n" "$(mk $C4)"

echo "demo:before_after"
head_ "Before → after"
printf "${DIM}  BEFORE S143: the constitution was the last add-only render. When Vajra improved a rule, an\n"
printf "  existing project could not pick it up smoothly — a human hand-copied and risked clobbering\n"
printf "  their own project name. 'One command upgrades everything' was true for roles + hooks, not it.\n"
printf "  AFTER S143: 'vajra init --sync-fleet' upgrades the constitution's governed BODY in place while\n"
printf "  preserving the user's filled header verbatim — the last pure render Vajra owns now joins the\n"
printf "  smooth upgrade. Honest limit: a pre-S143 install needs the sentinel pasted ONCE (Vajra never\n"
printf "  guesses where your header ends); CONSTRAINTS.yaml stays user-owned by design.${RESET}\n"

echo ""
FAILS=$((C1 + C2 + C3 + C4))
[ "$FAILS" -eq 0 ] && printf "${GREEN}${BOLD}DEMO: all cases green${RESET}\n" || printf "${RED}${BOLD}DEMO: a case is red${RESET}\n"
[ "$FAILS" -eq 0 ]
