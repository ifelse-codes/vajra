#!/usr/bin/env bash
# Session 67 — The ARCHITECT stage (the pipeline's DESIGN gate).
# Demo: the Analyst governs the WHAT; the Planner the HOW-plan; the Architect governs the DESIGN
# decision between them — it SURFACES the locked design spine (docs/adr/ + docs/decisions/) as the
# checklist a design-significant session's `## Design` rationale must cite from, then ENFORCES that
# the rationale is recorded (marker + non-placeholder + spine-citing) before execution can advance.
# The binary surfaces + enforces a recorded rationale; it never AUTHORS a design. Cumulative: one
# CLI, no 8th command, the .ai/+prompts/+docs/ spine, the Analyst (S54+S61+S62) + Planner (S64)
# gates riding the same `vajra next`.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session 67 Demo — the Architect: surface the design spine, enforce a recorded rationale"
printf "${DIM}  WHAT (Analyst) → DESIGN (Architect) → HOW-plan (Planner) → REVIEW (fidelity gate + ledger).${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

# Throwaway Vajra repo at session 50, L3 (non-interactive advance). Prompt 51 is APPROVED +
# well-formed + substantive-delta + covered-plan so only the ARCHITECT gate is exercised. The
# design spine has one ADR + one DECISION.
E2E="$(mktemp -d)"; trap 'rm -rf "$E2E"' EXIT
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions" "$E2E/docs/adr" "$E2E/docs/decisions"
echo "50" > "$E2E/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"
printf '# Session Boot\n- **Number:** 50\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/50-task-x.md`\n' > "$E2E/.ai/TASK.md"
printf '# Vajra — Working Roadmap\n' > "$E2E/.ai/ROADMAP.md"
printf '# ADR-0001: The engine contract\n' > "$E2E/docs/adr/0001-engine-contract.md"
printf '# DECISION-001: Governance as product\n' > "$E2E/docs/decisions/DECISION-001-governance.md"
{ printf '# S50 summary\n\n## Next — ranked candidates (S51)\n\n'
  printf -- '- **A — one.**\n- **B — two.**\n- **C — three.**\n'
} > "$E2E/sessions/session-50-summary.md"

P51_HEAD=$(cat <<'P'
# Session 51 — x: a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN run THEN it surfaces the spine.
2. WHEN significant + placeholder THEN it blocks.
## Deliverables
- a thing
## Plan
1. surface — covers: 1
2. gate — covers: 2
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
)
write_p51() { printf '%s\n%s\n' "$P51_HEAD" "$1" > "$E2E/prompts/51-task-x.md"; }
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-51-x )

# ---------------------------------------------------------------------------
header "1 · SURFACE — \`vajra next --design 51\` prints the locked spine, citations marked"
label "the rationale derives from the recorded design spine, not thin air"
write_p51 $'## Design\n- design-significant: yes — new interface\n- rests on ADR-0001.'
( cd "$E2E" && "$BIN" next --design 51 )
ok "spine surfaced — ADR-0001 cited ✓, DECISION-001 not yet"

# ---------------------------------------------------------------------------
header "2 · GATE — a design-significant prompt with NO recorded rationale BLOCKS (exit 1)"
label "significance is a RECORDED marker (design-significant: yes) — never guessed"
write_p51 $'## Design\n- design-significant: yes — new interface\n- <rationale — replace me>'
if ( cd "$E2E" && "$BIN" next --check-design 51 ); then
  bad "placeholder design was NOT blocked"
else
  ok "placeholder rationale BLOCKED (exit 1)"
fi
label "real text citing NO ADR/DECISION still blocks — the rationale must cite the spine"
write_p51 $'## Design\n- design-significant: yes — new interface\n- because it felt right.'
if ( cd "$E2E" && "$BIN" next --check-design 51 ); then
  bad "uncited design was NOT blocked"
else
  ok "spine-citing requirement enforced (exit 1)"
fi

# ---------------------------------------------------------------------------
header "3 · PASS — a substantive, spine-citing rationale is READY (exit 0)"
write_p51 $'## Design\n- design-significant: yes — new interface\n- mirrors DECISION-001; rides ADR-0001.'
( cd "$E2E" && "$BIN" next --check-design 51 )
ok "substantive rationale passes"

# ---------------------------------------------------------------------------
header "4 · NON-SIGNIFICANT — a pure fix (design-significant: no) never blocks"
write_p51 $'## Design\n- design-significant: no — pure fix'
( cd "$E2E" && "$BIN" next --check-design 51 )
ok "explicit 'no' passes clean; a legacy prompt only WARNS (backward-compatible)"

# ---------------------------------------------------------------------------
header "5 · WIRED INTO --advance — undesigned significant work cannot proceed"
write_p51 $'## Design\n- design-significant: yes — new interface\n- <rationale — replace me>'
if ( cd "$E2E" && "$BIN" next --advance ); then
  bad "advance was NOT blocked"
else
  ok "advance BLOCKED at L3 — SESSION stays $(cat "$E2E/.ai/SESSION")"
fi
label "the documented override is the Architect's OWN (each stage overrides alone)"
( cd "$E2E" && VAJRA_SKIP_ARCHITECT_GATE=1 "$BIN" next --advance >/dev/null 2>&1 ) \
  && ok "VAJRA_SKIP_ARCHITECT_GATE=1 → advanced to $(cat "$E2E/.ai/SESSION")"

# ---------------------------------------------------------------------------
header "6 · DOGFOOD — this repo's own S67 prompt passes its own gate"
"$BIN" next --check-design 67 | sed -n '1,4p'
ok "prompts/67-task-architect-stage.md records design-significant: yes + a spine-citing rationale"

# ---------------------------------------------------------------------------
header "Scorecard"
printf "${GREEN}${BOLD}"
cat <<'S'
  SURFACE   --design NN       locked ADRs/DECISIONs as the citation checklist   ✓
  GATE      --check-design NN missing/placeholder/uncited BLOCK (exit 1)        ✓
  PASS      substantive, spine-citing rationale                                 ✓
  LEGACY    non-significant / unmarked prompts WARN at most                     ✓
  ADVANCE   wired in (L2/L3 block · L1 advise · own override)                   ✓
  HONEST    enforces the FORM of the record, not design quality (stated)        ✓
S
printf "${RESET}"
printf "${DIM}  Pipeline: Analyst (WHAT) → Architect (DESIGN) → Planner (HOW) → Reviewer/ledger (REVIEW).${RESET}\n"
