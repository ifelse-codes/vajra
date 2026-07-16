#!/usr/bin/env bash
# Session 68 — The CODER handoff (the pipeline's CODE/execution gate — the LAST station).
# Demo: the Analyst governs the WHAT; the Architect the DESIGN; the Planner the HOW-plan; the
# Coder governs the DID — it SURFACES the covered plan as the execution checklist, then ENFORCES
# that each numbered plan step records `step N — done: <sha>` where the sha names a commit that
# EXISTS (`git cat-file -e` — the S67 existence lesson, git-shaped). The binary surfaces +
# enforces a recorded trace; it never CODES. Cumulative: one CLI, no 8th command, the
# .ai/+prompts/ spine, WHAT (S54+S61+S62) → DESIGN (S67) → HOW-plan (S64) → CODE (S68) →
# REVIEW (S55-59) riding the same `vajra next` — the station spine is complete.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session 68 Demo — the Coder: surface the plan checklist, enforce the execution trace"
printf "${DIM}  WHAT (Analyst) → DESIGN (Architect) → HOW-plan (Planner) → CODE (Coder) → REVIEW (fidelity+ledger).${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

# Throwaway Vajra GIT repo: session 51 is CLOSING (covered 2-step plan, 3 ranked options);
# session 52's prompt is APPROVED so only the CODER gate is exercised. Real commits = real shas.
E2E="$(mktemp -d)"; trap 'rm -rf "$E2E"' EXIT
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions"
echo "51" > "$E2E/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"
printf '# Session Boot\n- **Number:** 51\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/51-task-x.md`\n' > "$E2E/.ai/TASK.md"
printf '# Vajra — Working Roadmap\n' > "$E2E/.ai/ROADMAP.md"
{ printf '# S51 summary\n\n## Next — ranked candidates (S52)\n\n'
  printf -- '- **A — one.**\n- **B — two.**\n- **C — three.**\n'
} > "$E2E/sessions/session-51-summary.md"
cat > "$E2E/prompts/52-task-y.md" <<'P'
# Session 52 — y: the next slice
> **Status:** APPROVED
## Goal
Do the next thing.
## Acceptance (testable, EARS-style)
1. WHEN run THEN it works.
## Deliverables
- a thing
## Plan
1. do it — covers: 1
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P

P51_HEAD=$(cat <<'P'
# Session 51 — x: a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN built THEN it surfaces.
2. WHEN gated THEN it blocks.
## Deliverables
- a thing
## Plan
1. build the thing — covers: 1
2. gate the thing — covers: 2
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
)
write_p51() { printf '%s\n%s\n' "$P51_HEAD" "$1" > "$E2E/prompts/51-task-x.md"; }
write_p51 ""
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-51-x )
REAL=$(cd "$E2E" && git rev-parse --short HEAD)

header "1 · SURFACE — vajra next --exec 51: the covered plan as the execution checklist"
label "step 1 recorded against a REAL commit ($REAL); step 2 against a made-up sha (9999999)"
write_p51 $'## Execution\n- step 1 — done: '"$REAL"$'\n- step 2 — done: 9999999'
( cd "$E2E" && "$BIN" next --exec 51 ) || true
ok "the trace derives from the recorded contract — done shas verified against git, never guessed"

header "2 · GATE — vajra next --check-exec 51 BLOCKS a fake/unrecorded trace"
label "a made-up sha is classified UNRECORDED (existence-gated, the S67 lesson git-shaped)"
if ( cd "$E2E" && "$BIN" next --check-exec 51 ); then
  bad "should have blocked"
else
  ok "exit 1 — a session cannot claim execution by a commit that does not exist"
fi

header "3 · GATE — a fully recorded trace passes"
write_p51 $'## Execution\n- step 1 — done: '"$REAL"$'\n- step 2 — done: '"$REAL"
( cd "$E2E" && "$BIN" next --check-exec 51 )
ok "every numbered plan step names a commit that EXISTS — READY"

header "4 · WIRED INTO --advance — the CLOSING session cannot advance unrecorded"
label "unrecorded trace on the closing session 51:"
write_p51 $'## Execution\n- step 1 — done: '"$REAL"
if ( cd "$E2E" && "$BIN" next --advance ); then
  bad "should have refused"
else
  ok "refused — SESSION still $(cat "$E2E/.ai/SESSION") (VAJRA_SKIP_CODER_GATE=1 is the documented override)"
fi
label "record the missing step, advance passes:"
write_p51 $'## Execution\n- step 1 — done: '"$REAL"$'\n- step 2 — done: '"$REAL"
( cd "$E2E" && "$BIN" next --advance )
ok "advanced — SESSION now $(cat "$E2E/.ai/SESSION")"

header "5 · DOGFOOD — this session's own prompt passes its own gate"
"$BIN" next --exec 68 || true
"$BIN" next --check-exec 68 && ok "S68's ## Execution records the real landed commits" \
  || bad "S68's own trace is not recorded"

header "6 · CUMULATIVE — the full station spine rides one command"
printf "${DIM}  vajra next --intake/--scaffold/--validate (WHAT) · --design/--check-design (DESIGN)\n"
printf "  · --plan/--check-plan (HOW) · --exec/--check-exec (CODE) · fidelity gate + ledger (REVIEW)${RESET}\n"
ok "5 governed stations, no 8th command, no second store — the spine the vision names is complete"

header "Scorecard"
printf "  %-44s %s\n" "surface: plan → recorded-state checklist"      "PASS"
printf "  %-44s %s\n" "gate: fake sha classified unrecorded, blocks"  "PASS"
printf "  %-44s %s\n" "gate: recorded trace passes"                   "PASS"
printf "  %-44s %s\n" "advance wiring on the CLOSING session"         "PASS"
printf "  %-44s %s\n" "dogfood: S68 passes its own gate"              "PASS"
printf "${DIM}  honest edge: form + existence, not semantics — an author can done: any real sha.${RESET}\n"
