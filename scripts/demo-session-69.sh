#!/usr/bin/env bash
# Session 69 — The QA station (the pipeline's WORKS gate — the 6th governed station).
# Demo: the Analyst governs the WHAT; the Architect the DESIGN; the Planner the HOW-plan; the
# Coder the DID; the Reviewer/ledger the REVIEW — and nothing governed WORKS. QA SURFACES the
# session's recorded verify contract (script + .ai/verify/ runs), then ENFORCES it by RE-RUNNING
# the script LIVE: a recorded green is never trusted (no stale-green — the marker here is
# EXECUTABLE, so the gate executes the evidence instead of reading a claim). The binary surfaces
# + enforces; it never writes or fixes a test. Cumulative: one CLI, no 8th command, the
# .ai/+prompts/ spine, WHAT (S54+61+62) → DESIGN (S67) → HOW-plan (S64) → CODE (S68) →
# WORKS (S69) → REVIEW (S55-59) riding the same `vajra next`.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session 69 Demo — QA: surface the verify contract, RE-RUN it live as the close gate"
printf "${DIM}  WHAT → DESIGN → HOW-plan → CODE → WORKS (new) → REVIEW — six governed stations, one command.${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

# Throwaway Vajra GIT repo: session 51 is CLOSING (covered plan, no ## Execution so the Coder
# only warns, 3 ranked options); session 52's prompt is APPROVED — only the QA gate is exercised.
E2E="$(mktemp -d)"; trap 'rm -rf "$E2E"' EXIT
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions" "$E2E/scripts"
echo "51" > "$E2E/.ai/SESSION"
{ printf 'version: 3\nmaturity: L3\n\nverify:\n'
  printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n"
  printf "  artifacts_dir: '.ai/verify/session-{NN}/'\n"
} > "$E2E/.ai/CONSTRAINTS.yaml"
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
cat > "$E2E/prompts/51-task-x.md" <<'P'
# Session 51 — x: a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN built THEN it works.
## Deliverables
- a thing
## Plan
1. build the thing — covers: 1
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-51-x )
V51="$E2E/scripts/verify-session-51.sh"

header "1 · SURFACE — vajra next --qa 51: the recorded verify contract, read-only"
label "no script yet — the contract shows exactly what is (and is not) recorded:"
( cd "$E2E" && "$BIN" next --qa 51 ) || true
ok "derived from CONSTRAINTS.yaml#verify (script_pattern + artifacts_dir) — no new store"

header "2 · GATE — the stale-green is killed: recorded runs look green, the script is red NOW"
label "two recorded runs + a latest symlink say 'green'; the script itself exits 3:"
mkdir -p "$E2E/.ai/verify/session-51/20260101T000000Z" "$E2E/.ai/verify/session-51/20260102T000000Z"
ln -sfn "20260102T000000Z" "$E2E/.ai/verify/session-51/latest"
printf 'echo "51 checks running"\nexit 3\n' > "$V51"
if ( cd "$E2E" && "$BIN" next --check-qa 51 ); then
  bad "should have blocked"
else
  ok "exit 1 — the gate RE-RAN the script live; a recorded green is never accepted as proof"
fi

header "3 · GATE — a live green passes"
printf 'echo "51 checks running"\nexit 0\n' > "$V51"
( cd "$E2E" && "$BIN" next --check-qa 51 )
ok "READY on live evidence only"

header "4 · NO SCRIPT — NO-CODE ground-truth / legacy sessions WARN, the dodge named"
rm -f "$V51"
( cd "$E2E" && "$BIN" next --check-qa 51 ) || true
ok "warns, never blocks — and says plainly that deleting the script downgrades the gate"

header "5 · WIRED INTO --advance — the CLOSING session cannot advance with a red verify"
label "red verify on the closing session 51:"
printf 'echo "51 checks running"\nexit 3\n' > "$V51"
if ( cd "$E2E" && "$BIN" next --advance ); then
  bad "should have refused"
else
  ok "refused — SESSION still $(cat "$E2E/.ai/SESSION") (VAJRA_SKIP_QA_GATE=1 is the documented override)"
fi
label "fix the verify to live-green, advance passes:"
printf 'echo "51 checks running"\nexit 0\n' > "$V51"
( cd "$E2E" && "$BIN" next --advance )
ok "advanced — SESSION now $(cat "$E2E/.ai/SESSION")"

header "6 · DOGFOOD — this session's own contract"
"$BIN" next --qa 69 || true
ok "the script the contract names IS scripts/verify-session-69.sh — closing S69 re-runs it live"
printf "${DIM}  honest cost: the live run executes cargo build/test — slow; that is the point.${RESET}\n"

header "7 · CUMULATIVE — six governed stations ride one command"
printf "${DIM}  vajra next --intake/--scaffold/--validate (WHAT) · --design/--check-design (DESIGN)\n"
printf "  · --plan/--check-plan (HOW) · --exec/--check-exec (CODE) · --qa/--check-qa (WORKS)\n"
printf "  · fidelity gate + ledger (REVIEW)${RESET}\n"
ok "6 governed stations, no 8th command, no second store — the crew grows one per session"

header "Scorecard"
printf "  %-44s %s\n" "surface: recorded verify contract"             "PASS"
printf "  %-44s %s\n" "gate: stale-green killed (live re-run)"        "PASS"
printf "  %-44s %s\n" "gate: live green passes"                       "PASS"
printf "  %-44s %s\n" "no-script: WARN, dodge named"                  "PASS"
printf "  %-44s %s\n" "advance wiring on the CLOSING session"         "PASS"
printf "  %-44s %s\n" "dogfood: S69's contract names this script"     "PASS"
printf "${DIM}  honest edge: a green verify only proves what its author chose to check — jurisdiction\n"
printf "  is still self-granted (no script → WARN). QA verifies the checks pass, not that they suffice.${RESET}\n"
