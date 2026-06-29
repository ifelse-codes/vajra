#!/usr/bin/env bash
# Session 24 — render `.ai/` → generated `vajra.varta`. The S19 follow-up: a persisted
# `.varta` returns ONLY as a one-way render of the live `.ai/`, drift-guarded so it can
# never silently drift or lose config. Cumulative demo (builds on S19/S21/S22/S23).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="24"
BIN="$ROOT/target/debug/vajra"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — render .ai/ → generated vajra.varta"
printf "${DIM}  S19 dropped the hand-written .varta (a 2nd copy drifts). It returns now —${RESET}\n"
printf "${DIM}  but ONLY because it can be generated. One source of truth: .ai/.${RESET}\n"

[ -x "$BIN" ] || { label "building vajra"; cargo build >/dev/null 2>&1; }

header "1. One command renders the live .ai/ into the ⚡ language"
label "vajra check --render"
"$BIN" check --render | sed 's/^/    /'

header "2. The artifact: all 9 locked constructs, glanceable"
label "head of vajra.varta"
head -28 vajra.varta | sed 's/^/    /'
printf "    ${DIM}...(⚡final, ⚡on, ⚡assert, ⚡enum next follow)${RESET}\n"

header "3. It is a RENDER, not a copy — change .ai/, it flows through"
if grep -qF "ADR_0005" vajra.varta && grep -qF "cmd:git commit" vajra.varta; then
  ok "ADR-0005 + the copilot.on rules came straight from .ai/ — nothing hand-typed"
fi

header "4. Drift guard: the on-disk file MUST equal a fresh render"
label "vajra check  (the new 'varta: matches render' gate)"
VAJRA_CHECK_RUNNING=1 "$BIN" check 2>&1 | grep -F "varta:" | sed 's/^/    /' || true
label "hand-edit it, and check CATCHES the drift"
cp vajra.varta "$ROOT/.ai/verify/.varta.demobak"
printf '\n// sneaky hand edit\n' >> vajra.varta
VAJRA_CHECK_RUNNING=1 "$BIN" check 2>&1 | grep -F "varta:" | sed 's/^/    /' || true
cp "$ROOT/.ai/verify/.varta.demobak" vajra.varta && rm -f "$ROOT/.ai/verify/.varta.demobak"
ok "restored — a 2nd copy can no longer silently drift from .ai/ (the S19 fear, solved)"

header "5. Why this matters (cumulative)"
printf "    ${DIM}• S19 the language · S21 it enforces · S22 propagated · S23 felt · S24 persisted-as-render.${RESET}\n"
printf "    ${DIM}• No 8th command: rides on \`vajra check\` (still 7 top-level commands).${RESET}\n"
printf "    ${DIM}• No serde_yaml dep: the few fields are hand-parsed, like the hooks.${RESET}\n"
printf "    ${DIM}• Same pattern as S22 include_str! / S23 live fire: one source, generated, drift-guarded.${RESET}\n"

header "Done"
ok "vajra.varta is now a first-class, generated, drift-guarded view of .ai/"
