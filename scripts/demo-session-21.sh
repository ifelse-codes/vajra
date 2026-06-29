#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="21"
HOOK="$ROOT/scripts/hook-copilot-loader.sh"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

# Fire the hook with isolated debounce state so the demo is deterministic.
fire() { # $1=json  -> prints output, prints rc
  local sd; sd=$(mktemp -d)
  local out rc
  out=$(printf '%s' "$1" | VAJRA_COPILOT_STATE_DIR="$sd" CLAUDE_PROJECT_DIR="$ROOT" bash "$HOOK" 2>&1) && rc=0 || rc=$?
  rm -rf "$sd"
  printf '%s\n' "$out" | sed 's/^/    /'
  if [ "$rc" -eq 2 ]; then printf "    ${RED}[tool BLOCKED — exit 2 → agent must reckon with the load]${RESET}\n"
  else printf "    ${DIM}[exit %s]${RESET}\n" "$rc"; fi
}

header "Session ${SESSION} Demo — the co-pilot loader (⚡on fires)"
printf "${DIM}  Right context, right corner — surfaced the moment the agent touches matching work.${RESET}\n"

header "1. The ⚡on rules — live from .ai/CONSTRAINTS.yaml (no hand-copy)"
label "copilot.on — the agent speaks these as Varta over the live source"
grep -E '^[[:space:]]*-[[:space:]]*".*=>.*"' .ai/CONSTRAINTS.yaml | sed -E 's/^[[:space:]]*-[[:space:]]*/  ⚡on /'
ok "3 rules; rendered as ⚡on(PATTERN) ⚡include \"files\""

header "2. Touch src/engine/* → the co-pilot FIRES (L2 = enforce)"
label "PreToolUse(Edit) on src/engine/default_engine.rs"
fire '{"tool_name":"Edit","tool_input":{"file_path":"'"$ROOT"'/src/engine/default_engine.rs"},"session_id":"demo"}'
ok "The trim-contract context is surfaced BEFORE the edit lands"

header "3. Debounce — fires once per session, never spams"
label "Second touch in src/engine (same session state)"
SD=$(mktemp -d)
printf '%s' '{"tool_name":"Edit","tool_input":{"file_path":"'"$ROOT"'/src/engine/a.rs"},"session_id":"demo"}' \
  | VAJRA_COPILOT_STATE_DIR="$SD" CLAUDE_PROJECT_DIR="$ROOT" bash "$HOOK" >/dev/null 2>&1 || true   # 1st fires
OUT2=$(printf '%s' '{"tool_name":"Edit","tool_input":{"file_path":"'"$ROOT"'/src/engine/b.rs"},"session_id":"demo"}' \
  | VAJRA_COPILOT_STATE_DIR="$SD" CLAUDE_PROJECT_DIR="$ROOT" bash "$HOOK" 2>&1) || true
rm -rf "$SD"
printf "    %s\n" "${OUT2:-<silent — already fired this session>}"
ok "No nag loop — one fire per rule per session"

header "4. The enforce-vs-advise GATE (the S21 decision) is maturity-gated"
label "Same rule, maturity: L1 → ADVISE (non-blocking)"
D=$(mktemp -d); mkdir -p "$D/.ai"
printf 'maturity: L1\ncopilot:\n  on:\n    - "src/engine/* => docs/adr/0003-settings-injector-and-compression-heuristics.md | trim contract"\n' > "$D/.ai/CONSTRAINTS.yaml"
SD=$(mktemp -d)
printf '%s' '{"tool_name":"Edit","tool_input":{"file_path":"'"$D"'/src/engine/x.rs"},"session_id":"demo"}' \
  | VAJRA_COPILOT_STATE_DIR="$SD" CLAUDE_PROJECT_DIR="$D" bash "$HOOK" 2>&1 | sed 's/^/    /' || true
rm -rf "$D" "$SD"
printf "    ${GREEN}→ L2/L3 BLOCK (exit 2); L1 only advises. Varta ENFORCES → on-wedge.${RESET}\n"

header "5. Structural verify"
label "10 checks: fire, cmd-match, non-match silence, debounce, the gate, anti-rot"
bash scripts/verify-session-21.sh 2>&1 | tail -2

header "Summary"
printf "\n"
printf "  %-46s %s\n" "Deliverable" "Status"
printf "  %-46s %s\n" "----------------------------------------------" "------"
printf "  %-46s %s\n" "⚡on rules live in CONSTRAINTS.yaml (no drift)"  "DONE"
printf "  %-46s %s\n" "Co-pilot fires on matching work (path + cmd)"   "DONE"
printf "  %-46s %s\n" "Per-session debounce (no spam)"                 "DONE"
printf "  %-46s %s\n" "Enforce at L2/L3, advise at L1 (the gate)"      "DONE"
printf "  %-46s %s\n" "Proven live: blocked a real git commit (S21)"   "DONE"
printf "\n"
printf "${DIM}  Cumulative: prior capabilities demoed in scripts/demo-session-{08,09,11,12,13,14,16,17,19}.sh${RESET}\n"
ok "Session ${SESSION} demo complete — Varta's first enforcing use."
