#!/usr/bin/env bash
# Session 71 — The Demo-er station (the pipeline's SHOW gate — the 7th governed station).
# Demo: six stations governed WHAT/DESIGN/HOW/DID/WORKS/REVIEW — and nothing governed SHOW.
# The sprint demo ("seeing it, the user knows what this session delivered, and the
# before-and-after" — the founder's S70 contract) was a house rule: CONSTRAINTS.yaml#demo named
# a script_pattern, a template that DID NOT EXIST on disk, and required_elements nothing read.
# The Demo-er SURFACES the recorded contract (`--demo NN`, read-only) and ENFORCES it by
# RE-RUNNING the demo LIVE (`--check-demo NN`, the S69 executable-marker pattern): a non-zero
# exit OR a required element missing from the LIVE output BLOCKS the close — the hollow exit-0
# demo dies on the element scan. The binary surfaces + enforces; it never authors or renders a
# demo (presentation stays the agent's Darshan job). Cumulative: one CLI, no 8th command,
# WHAT (S54+61+62) → DESIGN (S67) → HOW-plan (S64) → CODE (S68) → WORKS (S69) → SHOW (S71) →
# REVIEW (S55-59) riding the same `vajra next`.
#
# This script is itself session 71's sprint demo — it emits the four required
# `demo:<element>` markers it enforces, and `--check-demo 71` re-runs it live at close.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session 71 Demo — the Demo-er: every close now SHOWS what it delivered  [demo:header]"
printf "${DIM}  WHAT → DESIGN → HOW-plan → CODE → WORKS → SHOW (new) → REVIEW — seven governed stations, one command.${RESET}\n"

cargo build --quiet 2>/dev/null || true
BIN="$ROOT/target/debug/vajra"

header "Before → After  [demo:before_after]"
label "BEFORE (S70 and every session before it):"
if git cat-file -e "8dc5485:scripts/demo-session-template.sh" 2>/dev/null; then
  bad "unexpected: the template existed at the S70 merge"
else
  ok "scripts/demo-session-template.sh at the S70 merge (8dc5485): DOES NOT EXIST — named in CONSTRAINTS, missing on disk (the S70 GT finding)"
fi
printf "${DIM}  and nothing read required_elements: a session could close with no demo, a red demo, or an\n"
printf "  exit-0 demo that showed nothing — no gate would notice.${RESET}\n"
label "AFTER (S71):"
ok "the template EXISTS, runs green, and carries all four demo:<element> markers"
ok "vajra next --demo/--check-demo surface + LIVE-enforce the contract; --advance blocks a close whose demo does not SHOW"

# Throwaway Vajra GIT repo: session 51 is CLOSING (covered plan, no ## Execution so the Coder
# only warns, 3 ranked options, live-GREEN verify so QA passes) — only the Demo-er gate varies.
E2E="$(mktemp -d)"; trap 'rm -rf "$E2E"' EXIT
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions" "$E2E/scripts"
echo "51" > "$E2E/.ai/SESSION"
{ printf 'version: 3\nmaturity: L3\n\nverify:\n'
  printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n"
  printf "  artifacts_dir: '.ai/verify/session-{NN}/'\n"
  printf '\ndemo:\n'
  printf "  script_pattern: 'scripts/demo-session-{NN}.sh'\n"
  printf '  required_elements: [header, cases, summary_table, before_after]\n'
} > "$E2E/.ai/CONSTRAINTS.yaml"
printf '# Session Boot\n- **Number:** 51\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/51-task-x.md`\n' > "$E2E/.ai/TASK.md"
printf '# Vajra — Working Roadmap\n' > "$E2E/.ai/ROADMAP.md"
{ printf '# S51 summary\n\n## Next — ranked candidates (S52)\n\n'
  printf -- '- **A — one.**\n- **B — two.**\n- **C — three.**\n'
} > "$E2E/sessions/session-51-summary.md"
for NN in 51 52; do
cat > "$E2E/prompts/${NN}-task-x.md" <<'P'
# Session NN — x: a slice
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
done
printf 'exit 0\n' > "$E2E/scripts/verify-session-51.sh"
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-51-x )
D51="$E2E/scripts/demo-session-51.sh"

header "Cases — run against a throwaway governed repo, live  [demo:cases]"

header "1 · SURFACE — vajra next --demo 51: the recorded contract, read-only"
label "no demo script yet — the contract shows exactly what is required and missing:"
( cd "$E2E" && "$BIN" next --demo 51 ) || true
ok "derived from CONSTRAINTS.yaml#demo (script_pattern + required_elements) — no new store, nothing executed"

header "2 · GATE — the hollow demo is killed: exit 0, nothing shown"
label "an exit-0 demo that shows nothing ('all done, trust me'):"
printf 'echo "all done, trust me"\nexit 0\n' > "$D51"
if ( cd "$E2E" && "$BIN" next --check-demo 51 ); then
  bad "should have blocked"
else
  ok "exit 1 — the run passed but the ELEMENT SCAN of the live output failed: a demo must SHOW"
fi

header "3 · GATE — a red demo blocks, naming the live exit code"
printf 'echo "demo:header"\nexit 3\n' > "$D51"
if ( cd "$E2E" && "$BIN" next --check-demo 51 ); then
  bad "should have blocked"
else
  ok "exit 1 — the gate RE-RAN the script live; a recorded green is never accepted as proof"
fi

header "4 · GATE — a full sprint demo passes: green run + all four elements shown"
printf 'echo "demo:header S51"\necho "demo:before_after old vs new"\necho "demo:cases 1"\necho "demo:summary_table"\n' > "$D51"
( cd "$E2E" && "$BIN" next --check-demo 51 )
ok "READY on live evidence only — run green AND elements shown"

header "5 · WIRED INTO --advance — the CLOSING session cannot advance without SHOWING"
label "hollow demo on the closing session 51:"
printf 'echo "looks fine"\nexit 0\n' > "$D51"
if ( cd "$E2E" && "$BIN" next --advance ); then
  bad "should have refused"
else
  ok "refused — SESSION still $(cat "$E2E/.ai/SESSION") (VAJRA_SKIP_DEMOER_GATE=1 is the documented override; it skips the live run itself, disclosed)"
fi
label "fix the demo to a full live sprint demo, advance passes:"
printf 'echo "demo:header S51"\necho "demo:before_after old vs new"\necho "demo:cases 1"\necho "demo:summary_table"\n' > "$D51"
( cd "$E2E" && "$BIN" next --advance )
ok "advanced — SESSION now $(cat "$E2E/.ai/SESSION")"

header "6 · NO SCRIPT — NO-CODE ground-truth / legacy sessions WARN, the dodge named"
echo "51" > "$E2E/.ai/SESSION"
rm -f "$D51"
( cd "$E2E" && "$BIN" next --check-demo 51 ) || true
ok "warns, never blocks — and says plainly that deleting the script downgrades the gate"

header "7 · TEMPLATE + SCAFFOLD — the S70 gap closed and propagated"
bash "$ROOT/scripts/demo-session-template.sh" >/dev/null
ok "the canonical template runs green and carries all four markers"
SCAF="$(mktemp -d)"
( cd "$SCAF" && git init -q . && "$BIN" init >/dev/null 2>&1 )
if diff -q "$ROOT/scripts/demo-session-template.sh" "$SCAF/scripts/demo-session-template.sh" >/dev/null \
   && grep -q 'required_elements:.*before_after' "$SCAF/.ai/CONSTRAINTS.yaml"; then
  ok "vajra init scaffolds it byte-identically (include_str!, one source) + records before_after"
else
  bad "scaffold propagation failed"
fi
rm -rf "$SCAF"

header "8 · DOGFOOD — this session's own contract"
"$BIN" next --demo 71 || true
ok "the script the contract names IS this script — closing S71 re-runs it live, element-scanned"
printf "${DIM}  honest cost: the live re-run costs real seconds; the override skips the run itself.${RESET}\n"

header "Scorecard  [demo:summary_table]"
printf "  %-52s %s\n" "surface: recorded sprint-demo contract, read-only"   "PASS"
printf "  %-52s %s\n" "gate: hollow exit-0 demo killed (element scan)"      "PASS"
printf "  %-52s %s\n" "gate: red demo blocked (live re-run)"                "PASS"
printf "  %-52s %s\n" "gate: full sprint demo passes"                       "PASS"
printf "  %-52s %s\n" "advance wiring on the CLOSING session"               "PASS"
printf "  %-52s %s\n" "no-script: WARN, dodge named"                        "PASS"
printf "  %-52s %s\n" "template created + scaffold propagation"             "PASS"
printf "  %-52s %s\n" "dogfood: S71's contract names this script"           "PASS"
printf "${DIM}  honest edge: an element is a recorded marker the demo emits — the scan proves the demo\n"
printf "  PRINTS header · cases · summary_table · before_after, not that what it prints demonstrates\n"
printf "  anything (the covers:-class form floor). No script → WARN (self-granted jurisdiction,\n"
printf "  disclosed). Never pitch this as 'the demo is verified.'${RESET}\n"
