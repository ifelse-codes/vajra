#!/usr/bin/env bash
# Session 54 — The ANALYST stage (the pipeline's first governed specialist). Demo: a vague
# intent becomes the NEXT GOVERNED PROMPT (Vajra's own spec — prompts/NN-task-<slug>.md, NOT a
# foreign spec.md), and the advance gate BLOCKS starting a session whose prompt is missing,
# malformed, or still DRAFT — then lets it through once a human APPROVES. Rides `vajra next`
# (no 8th command); owns the .ai/+prompts/ spine (no second store).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="54"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — intent → a governed next prompt, with teeth"
printf "${DIM}  Vajra = a GOVERNED multi-agent SDLC pipeline. The Analyst is stage one.${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

# A throwaway Vajra repo mid-session 76, ready to hand off to 77.
SCRATCH=$(mktemp -d); trap 'rm -rf "$SCRATCH"' EXIT
mkdir -p "$SCRATCH/.ai" "$SCRATCH/prompts"
echo "76" > "$SCRATCH/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$SCRATCH/.ai/CONSTRAINTS.yaml"
printf '# Session Boot\n- **Number:** 76\n' > "$SCRATCH/.ai/SESSION-BOOT.md"
printf '# Task\nRead prompt: `prompts/76-task-x.md`\n' > "$SCRATCH/.ai/TASK.md"
( cd "$SCRATCH" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-76-x )

# ---------------------------------------------------------------------------
header "1. GENERATE — intent → the next prompt (Vajra's own format, no spec.md)"
label "vajra next --scaffold 77 ledger-extract"
( cd "$SCRATCH" && "$BIN" next --scaffold 77 ledger-extract ) | sed 's/^/    /'
PROMPT="$SCRATCH/prompts/77-task-ledger-extract.md"
for s in Goal Deliverables Acceptance Guardrails Delta; do
  grep -q "$s" "$PROMPT" && ok "prompt has a '$s' section (borrow-engine shape)" || bad "missing $s"
done
if ! test -e "$SCRATCH/spec.md" && ! test -d "$SCRATCH/specs"; then
  ok "no spec.md / specs/ created — the spec IS the prompt (one source of truth)"
else bad "a second store appeared"; fi

# ---------------------------------------------------------------------------
header "2. GATE — a DRAFT prompt BLOCKS the handoff (enforcement, not prose)"
label "vajra next --advance   (session 76 → 77, prompt still DRAFT)"
if ( cd "$SCRATCH" && "$BIN" next --advance ) 2>&1 | grep -Ei 'DRAFT|not ready|refusing' | sed 's/^/    /'; then :; fi
[ "$(cat "$SCRATCH/.ai/SESSION")" = "76" ] \
  && ok "BLOCKED — .ai/SESSION held at 76; you cannot start an un-approved session" \
  || bad "advanced despite DRAFT"

# ---------------------------------------------------------------------------
header "3. APPROVE — the human sign-off the gate waits for"
label "flip Status: DRAFT → APPROVED, then re-check"
sed -i.bak 's/DRAFT/APPROVED/' "$PROMPT" && rm -f "$PROMPT.bak"
( cd "$SCRATCH" && "$BIN" next --validate 77 ) | sed 's/^/    /'

# ---------------------------------------------------------------------------
header "4. ADVANCE — an approved, well-formed prompt passes the gate"
label "vajra next --advance"
( cd "$SCRATCH" && "$BIN" next --advance ) 2>&1 | grep -Ei 'Advanced|session' | sed 's/^/    /'
[ "$(cat "$SCRATCH/.ai/SESSION")" = "77" ] \
  && ok "ADVANCED — .ai/SESSION now 77, the governed handoff completed" \
  || bad "did not advance"

# ---------------------------------------------------------------------------
header "Scorecard"
ok "GENERATE: intent → prompts/77-task-ledger-extract.md (Vajra's format, no spec.md)"
ok "GATE: DRAFT/malformed/missing → BLOCKED; APPROVED + well-formed → advances"
ok "SPINE: .ai/ + prompts/ only · rides \`vajra next\` (7 commands, no 8th)"
printf "${DIM}  Honest edge: approval = a recorded Status: marker (commit-approval trust model);${RESET}\n"
printf "${DIM}  tamper-evidence is the later cross-stage ledger. One stage ≠ the whole pipeline.${RESET}\n"
