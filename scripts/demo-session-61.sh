#!/usr/bin/env bash
# Session 61 — The Analyst's Generate + Delta half, made REAL. Demo: generating the next prompt
# now (J3) repoints `.ai/TASK.md` at it, and a placeholder `## Delta` (the scaffold's untouched
# `<...>`) now (J4) BLOCKS the advance — only a delta a human actually recorded lets it through.
# Cumulative: still one CLI, no 8th command, the .ai/+prompts/ spine, the DRAFT->APPROVED gate.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session 61 Demo — Generate repoints the spine · a placeholder Delta gets BLOCKED"
printf "${DIM}  The S54 Analyst shipped a gate + a static template. S61 makes Generate + Delta real.${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

# Throwaway Vajra repo at session 76, L3 (non-interactive advance).
E2E="$(mktemp -d)"; trap 'rm -rf "$E2E"' EXIT
mkdir -p "$E2E/.ai" "$E2E/prompts"
echo "76" > "$E2E/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"
printf '# Session Boot\n- **Number:** 76\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/76-task-x.md`\n' > "$E2E/.ai/TASK.md"
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-76-x )
PROMPT="$E2E/prompts/77-task-demo-stage.md"

header "1 · GENERATE — scaffold the next prompt (J3: it also repoints .ai/TASK.md)"
label "vajra next --scaffold 77 demo-stage"
( cd "$E2E" && "$BIN" next --scaffold 77 demo-stage )
printf "\n${DIM}  .ai/TASK.md pointer line now reads:${RESET}\n    "
grep -n 'Read prompt' "$E2E/.ai/TASK.md"
if grep -q '`prompts/77-task-demo-stage.md`' "$E2E/.ai/TASK.md"; then
  ok "J3: the spine points at the generated prompt (was only a println! in S54)"
else bad "TASK.md pointer NOT updated"; fi

header "2 · DELTA — approve the prompt, but its Delta is still the scaffold placeholder"
sed -i.bak 's/DRAFT/APPROVED/' "$PROMPT" && rm -f "$PROMPT.bak"
printf "${DIM}  the Delta block is untouched template text:${RESET}\n"
grep -A1 '## Delta' "$PROMPT" | sed 's/^/    /'
label "vajra next --advance   (expected: BLOCKED on the placeholder Delta)"
if ( cd "$E2E" && "$BIN" next --advance ); then
  bad "advanced on a placeholder Delta — the S54 fakest green survived"
else
  ok "J4: BLOCKED — a placeholder Delta no longer passes as 'delta recorded'"
fi
printf "${DIM}  SESSION stayed at: $(cat "$E2E/.ai/SESSION")${RESET}\n"

header "3 · RECORD a real Delta — then the advance goes through (76 → 77)"
sed -i.bak 's/<what this session ADDS that did not exist>/wires the Foo stage onto vajra next/' "$PROMPT"
rm -f "$PROMPT.bak"
printf "${DIM}  the first Delta entry is now real:${RESET}\n    "
grep '`+`' "$PROMPT" | head -1
label "vajra next --advance"
if ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "77" ]; then
  ok "a substantive Delta passes the gate — SESSION advanced to 77"
else bad "substantive Delta failed to advance"; fi

header "4 · LEGACY compat — a prompt with NO ## Delta only WARNS (never blocks)"
printf '# S78\n> Status: APPROVED\n## Goal\ng\n## Deliverables\n- d\n## Acceptance\n1. a\n## Guardrails\n- x\n' \
  > "$E2E/prompts/78-task-legacy.md"
label "vajra next --advance   (legacy prompt, no Delta section)"
if ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "78" ]; then
  ok "legacy prompts stay valid — only the Analyst's own placeholder is blocked"
else bad "legacy no-Delta prompt was wrongly blocked"; fi

header "Honest scope"
printf "${DIM}  Paid down: Generate (J3) + Delta (J4) now real. Gate was already real (S54).${RESET}\n"
printf "${DIM}  Still OPEN: Intake (J1) + Options (J2) — the intent->A/B/C front half = S62.${RESET}\n"
printf "${GREEN}${BOLD}  S54 Analyst REJECT: 1-of-5 → 3-of-5 core stage-steps real.${RESET}\n"
