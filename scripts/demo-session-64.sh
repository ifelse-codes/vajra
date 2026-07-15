#!/usr/bin/env bash
# Session 64 — The PLANNER stage (the pipeline's 2nd governed specialist).
# Demo: the Analyst governs the WHAT (intent -> accepted prompt); the Planner governs the HOW —
# it SURFACES the prompt's acceptance criteria as the checklist to plan against, then ENFORCES that
# the `## Plan` COVERS every criterion (each cited `covers: N`) before execution can advance. The
# binary surfaces + enforces a recorded mapping; it never AUTHORS a plan step. Cumulative: one CLI,
# no 8th command, the .ai/+prompts/+sessions/ spine, the Analyst gate (S54+S61+S62).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session 64 Demo — the Planner: surface the criteria, enforce plan coverage"
printf "${DIM}  The Analyst produces the accepted prompt; the Planner checks the plan covers it, first.${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

# Throwaway Vajra repo at session 50, L3 (non-interactive advance). Prompt 51 is APPROVED +
# well-formed + substantive-delta so only the PLANNER gate is exercised; acceptance has 2 criteria.
E2E="$(mktemp -d)"; trap 'rm -rf "$E2E"' EXIT
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions"
echo "50" > "$E2E/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"
printf '# Session Boot\n- **Number:** 50\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/50-task-x.md`\n' > "$E2E/.ai/TASK.md"
printf '# Vajra — Working Roadmap\n' > "$E2E/.ai/ROADMAP.md"
{ printf '# S50 summary\n\n## Next — ranked candidates (S51)\n\n'
  printf -- '- **A — one.**\n- **B — two.**\n- **C — three.**\n'
} > "$E2E/sessions/session-50-summary.md"

P51_HEAD=$(cat <<'P'
# Session 51 — x: a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN run THEN it surfaces the criteria.
2. WHEN the plan is uncovered THEN it blocks.
## Deliverables
- a thing
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
)
write_p51() { printf '%s\n%s\n' "$P51_HEAD" "$1" > "$E2E/prompts/51-task-x.md"; }
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-51-x )

header "1 · SURFACE — the plan derives from the CONTRACT, not thin air"
write_p51 "## Plan"
label "vajra next --plan 51"
( cd "$E2E" && "$BIN" next --plan 51 ) | sed 's/^/    /'
if ( cd "$E2E" && "$BIN" next --plan 51 ) | grep -q '\[2\]'; then
  ok "the prompt's acceptance criteria are surfaced as the checklist to plan against"
else bad "criteria were not surfaced"; fi

header "2 · GATE — a placeholder plan is treated as absent-of-a-real-plan (BLOCK)"
write_p51 $'## Plan (ordered — cite `covers: N`)\n1. <first step — replace me>\n2. <next step>'
label "vajra next --check-plan 51   (placeholder \`<...>\` steps)"
( cd "$E2E" && "$BIN" next --check-plan 51 2>&1 || true ) | sed 's/^/    /'
if ( cd "$E2E" && ! "$BIN" next --check-plan 51 >/dev/null 2>&1 ); then
  ok "placeholder plan BLOCKS (exit 1) — mirrors the S61 Delta placeholder"
else bad "placeholder plan did not block"; fi

header "3 · GATE — an UNCOVERED plan (criterion 2 cited by no step) BLOCKS + names the gap"
write_p51 $'## Plan\n1. build the thing — covers: 1\n2. an unrelated step'
label "vajra next --check-plan 51"
( cd "$E2E" && "$BIN" next --check-plan 51 2>&1 || true ) | sed 's/^/    /'
if ( cd "$E2E" && "$BIN" next --check-plan 51 2>&1 || true ) | grep -q 'does not cover'; then
  ok "the plan does not cover acceptance criterion 2 — BLOCKED, and the reason says so"
else bad "uncovered plan did not block"; fi

header "4 · GATE — a COVERING plan (every criterion cited) PASSES"
write_p51 $'## Plan\n1. surface the criteria — covers: 1\n2. gate on coverage — covers: 2'
label "vajra next --check-plan 51"
( cd "$E2E" && "$BIN" next --check-plan 51 ) | sed 's/^/    /'
if ( cd "$E2E" && "$BIN" next --check-plan 51 ) | grep -q 'READY'; then
  ok "every acceptance criterion is covered — READY"
else bad "covering plan did not pass"; fi

header "5 · WIRED INTO --advance — a session cannot execute on an uncovered contract"
write_p51 $'## Plan\n1. only-one — covers: 1'
label "vajra next --advance   (plan for 51 leaves criterion 2 uncovered)"
( cd "$E2E" && "$BIN" next --advance 2>&1 || true ) | sed 's/^/    /'
if ( cd "$E2E" && ! "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "50" ]; then
  ok "advance REFUSED — SESSION stays 50 until the plan covers the contract (or override is set)"
else bad "advance was not blocked"; fi

echo ""
write_p51 $'## Plan\n1. surface — covers: 1\n2. gate — covers: 2'
label "vajra next --advance   (now the plan covers every criterion)"
( cd "$E2E" && "$BIN" next --advance 2>&1 || true ) | sed 's/^/    /'
if [ "$(cat "$E2E/.ai/SESSION")" = "51" ]; then
  ok "covered contract -> advanced 50 -> 51"
else bad "advance did not proceed on a covered plan"; fi

header "Honest limit"
printf "${DIM}  Coverage = a RECORDED number mapping (every acceptance criterion is cited by a step),${RESET}\n"
printf "${DIM}  NOT semantic proof that the step actually satisfies it. The binary enforces the mapping${RESET}\n"
printf "${DIM}  exists; the fidelity Validator (post-delivery) is what checks the work was really done.${RESET}\n"

header "Pipeline now: two governed stations"
printf "  ${GREEN}Analyst${RESET} (WHAT: intent -> accepted prompt)  ->  ${GREEN}Planner${RESET} (HOW: coverage-checked plan)\n"
