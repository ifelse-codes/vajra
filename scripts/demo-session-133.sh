#!/usr/bin/env bash
# Demo — Session 133: the design-advisor is MANDATORY, and a skip must cost a recorded sentence.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases ·
# summary_table · before_after. Cumulative: this demo re-derives `K of 8`, the 7-command floor,
# S131's Fidelity gate and S132's Obeyed gate alongside the new one.
#
# The claim under demonstration: a session can no longer reach its close without either a REAL
# design-advisor dispatch or a reason a human can read months later — and no environment variable
# can make either one go away.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="133"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "build failed"; exit 1; }

PASS=0; FAIL=0; EXEC_N=0; STRUCT_N=0; BEHAV_N=0; ROWS=()
score() {
  case "$2" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    *) echo "demo bug: unknown class '$2' for $3"; exit 2 ;;
  esac
  if [ "$1" -eq 0 ]; then ok "$3"; PASS=$((PASS+1)); ROWS+=("$(printf '%-62s %-7s %s' "$3" "$2" PASS)")
  else no "$3"; FAIL=$((FAIL+1)); ROWS+=("$(printf '%-62s %-7s %s' "$3" "$2" FAIL)"); fi
}

# ── The subject: a throwaway repo, never this one (except case 7, which is the point). ────────────
real_tmpdir() { ( cd "$(mktemp -d "${TMPDIR:-/tmp}/vajra-demo-133-XXXXXX")" && pwd -P ); }
TMP="$(real_tmpdir)"; trap 'rm -rf "$TMP"' EXIT
case "$TMP" in "$ROOT"*) echo "demo bug: temp dir inside the repo"; exit 2;; esac
( cd "$TMP" && git init -q . && git config user.email t@t && git config user.name t \
    && echo seed > seed.txt && git add -A && git commit -q -m seed --no-verify \
    && git checkout -q -b session-133-demo-subject ) || exit 1
mkdir -p "$TMP/.ai/handoffs" "$TMP/prompts"
echo "133" > "$TMP/.ai/SESSION"

PROMPT="$TMP/prompts/133-task-demo.md"
write_prompt() {   # $1 = the marker line to record (or empty for silence)
  {
    echo "# S133 demo"
    echo
    echo "## Design"
    echo "- design-significant: no — a demo fixture"
    [ -n "${1:-}" ] && echo "$1"
  } > "$PROMPT"
}

GATE="next --check-design-handoff"

# --- demo:header ---------------------------------------------------------------------------------
header "Session 133 — the design-advisor becomes mandatory  [demo:header]"
dim "  Nine roles. 18 governed handoffs across 132 sessions. design-advisor: used ONCE."
dim "  The one mandatory role (S131) grades finished work. The advisors that could change what"
dim "  gets BUILT were all optional — and optional loses to time pressure every session."
dim "  After this session: consult the role, or write down why you did not. Nothing else passes."
dim ""
dim "  subject repo: $TMP (throwaway — the product is driven, never described)"

# --- demo:cases ----------------------------------------------------------------------------------
header "Cases  [demo:cases]"

label "case 1 — a session that just does not ask: BLOCKED, and told both ways out"
write_prompt ""
OUT="$( cd "$TMP" && "$VAJRA" $GATE 133 2>&1 )"; CODE=$?
dim "    \$ vajra next --check-design-handoff 133   ->  exit $CODE"
printf '%s\n' "$OUT" | grep -E '✗' | fold -s -w 108 | sed 's/^/    /'
[ "$CODE" -eq 1 ] \
  && printf '%s' "$OUT" | grep -q "=== mandate: design-advisor for session 133 ===" \
  && printf '%s' "$OUT" | grep -q -- "--role design-advisor --from" \
  && printf '%s' "$OUT" | grep -q "skipped — <reason>"
score $? exec "case 1: silence BLOCKS, naming the dispatch AND the reasoned skip"

label "case 2 — a reasoned skip: PASSES, and the reason is printed where a reader sees it"
write_prompt "- design-advisor: skipped — a one-line README typo; no interface, module, or locked record moves"
OUT="$( cd "$TMP" && "$VAJRA" $GATE 133 2>&1 )"; CODE=$?
dim "    \$ vajra next --check-design-handoff 133   ->  exit $CODE"
printf '%s\n' "$OUT" | grep -E 'SKIPPED|verdict:' | fold -s -w 108 | sed 's/^/    /'
[ "$CODE" -eq 0 ] \
  && printf '%s' "$OUT" | grep -q "design-advisor review SKIPPED — a one-line README typo" \
  && printf '%s' "$OUT" | grep -q "verdict: READY"
score $? exec "case 2: a recorded reason PASSES and is never a clean green"

label "case 3 — the reason has to be a sentence: placeholder, bare word, and 'done' all BLOCK"
RC3=0
for M in "- design-advisor: <skipped — why this session needs no design review>" \
         "- design-advisor: skipped" \
         "- design-advisor: done"; do
  write_prompt "$M"
  OUT="$( cd "$TMP" && "$VAJRA" $GATE 133 2>&1 )"; CODE=$?
  dim "    ${M#- }  ->  exit $CODE"
  printf '%s\n' "$OUT" | grep -E '✗' | head -1 | fold -s -w 108 | sed 's/^/      /'
  [ "$CODE" -eq 1 ] || RC3=1
done
score $RC3 exec "case 3: an unusable reason BLOCKS — the skip costs a sentence"

label "case 4 — a hand-typed handoff does not satisfy a mandatory role, and a reason cannot cure it"
write_prompt "- design-advisor: skipped — a perfectly good reason, recorded in the repo"
cat > "$TMP/.ai/handoffs/session-133-design-advisor.md" <<'HAND'
---
role: design-advisor
session: 133
agent: claude-code-subagent (verified: toolu_FAKEFAKEFAKE)
source-sha: deadbeef
captured: 2026-08-25T00:00:00Z
cost_usd: null
---

# Design-advisor handoff — session 133

rec 1 — a finding nobody was ever dispatched to write

## Handoff Delta
- `+` new: forged handoff
HAND
OUT="$( cd "$TMP" && "$VAJRA" $GATE 133 2>&1 )"; CODE=$?
dim "    a handoff exists, its dispatch does not  ->  exit $CODE"
printf '%s\n' "$OUT" | grep -E '✗' | fold -s -w 108 | sed 's/^/    /'
[ "$CODE" -eq 1 ] \
  && printf '%s' "$OUT" | grep -q "could not be independently re-verified" \
  && printf '%s' "$OUT" | grep -q "does not cure it" \
  && ! printf '%s' "$OUT" | grep -q "SKIPPED"
score $? exec "case 4: a forged handoff BLOCKS — rung 1 beats the reasoned skip"
rm -f "$TMP/.ai/handoffs/session-133-design-advisor.md"

label "case 5 — a REAL dispatch: PASSES, and the gate names the provenance it accepted"
PROJROOT="$TMP/fake-cc-projects"
SLUG="$(echo "$TMP" | sed 's#/#-#g')"; PROJ="$PROJROOT/$SLUG"; UUID="demo-uuid"
mkdir -p "$PROJ/$UUID/subagents"
printf '{"agentType":"design-advisor","toolUseId":"toolu_01DEMOREAL"}' > "$PROJ/$UUID/subagents/agent-x1.meta.json"
printf '{"gitBranch":"session-133-demo-subject","type":"user"}\n' > "$PROJ/$UUID/subagents/agent-x1.jsonl"
printf '{"message":{"content":[{"type":"tool_use","id":"toolu_01DEMOREAL","name":"Agent","input":{"subagent_type":"design-advisor"}}]}}\n' > "$PROJ/$UUID.jsonl"
BRIEF="$TMP/brief.md"; printf '## Findings\n\nrec 1 — a real recommendation from a real dispatch\n' > "$BRIEF"
write_prompt ""
( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --role design-advisor --from "$BRIEF" ) \
  2>&1 | grep -E 'provenance:|handoff:' | sed 's/^/    /'
OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" $GATE 133 2>&1 )"; CODE=$?
dim "    \$ vajra next --check-design-handoff 133   ->  exit $CODE"
printf '%s\n' "$OUT" | grep -E 'agent:|verdict:' | sed 's/^/    /'
[ "$CODE" -eq 0 ] && printf '%s' "$OUT" | grep -q "verified: toolu_01DEMOREAL"
score $? exec "case 5: a provenance-verified dispatch PASSES, no reason needed"
rm -f "$TMP/.ai/handoffs/session-133-design-advisor.md"

label "case 6 — no environment variable makes this gate go away (the whole point)"
write_prompt ""
RC6=0
for V in VAJRA_SKIP_DESIGN_ADVISOR_GATE VAJRA_SKIP_MANDATE_GATE VAJRA_SKIP_DESIGN_GATE \
         VAJRA_SKIP_FIDELITY_GATE VAJRA_CLOSEOUT_WAIVER; do
  OUT="$( cd "$TMP" && env "$V=1" "$VAJRA" $GATE 133 2>&1 )"; CODE=$?
  dim "    $V=1  ->  exit $CODE $([ "$CODE" -eq 1 ] && echo '(still blocked)' || echo '(BYPASSED!)')"
  [ "$CODE" -eq 1 ] || RC6=1
done
score $RC6 exec "case 6: every VAJRA_SKIP_* name still BLOCKS — the escape is a written reason"

label "case 7 — this very session passes the gate it built, by REAL use (not a fixture)"
OUT="$( "$VAJRA" $GATE 133 2>&1 )"; CODE=$?
printf '%s\n' "$OUT" | grep -E 'handoff:|agent:|verdict:' | sed 's/^/    /'
[ "$CODE" -eq 0 ] \
  && printf '%s' "$OUT" | grep -q ".ai/handoffs/session-133-design-advisor.md" \
  && ! printf '%s' "$OUT" | grep -q "SKIPPED"
score $? exec "case 7: S133 satisfied its own mandate by dispatching, not by skipping"

label "case 8 — a fresh project is not exempt: the scaffold makes session 1 block"
( cd "$TMP" && "$VAJRA" next --scaffold 1 fresh-project ) >/dev/null 2>&1
dim "    \$ vajra next --scaffold 1 fresh-project"
grep -n "design-advisor:" "$TMP/prompts/01-task-fresh-project.md" | sed 's/^/    /'
OUT="$( cd "$TMP" && "$VAJRA" $GATE 1 2>&1 )"; CODE=$?
dim "    \$ vajra next --check-design-handoff 1   ->  exit $CODE"
[ "$CODE" -eq 1 ] && printf '%s' "$OUT" | grep -q "template placeholder"
score $? exec "case 8: the session-number threshold does not swallow a new repo"

label "case 9 — nothing else moved: K of 8, S131's Fidelity gate, S132's Obeyed gate, 7 commands"
ST="$( "$VAJRA" next --stations 132 2>&1 )"
dim "    $(printf '%s\n' "$ST" | grep 'stations passed')"
OB="$( "$VAJRA" next --check-obeyed 127 2>&1 )"; OBC=$?
dim "    \$ vajra next --check-obeyed 127  ->  exit $OBC $(printf '%s' "$OB" | grep -o 'MISMATCH' | head -1)"
NOT_A_COMMAND="$( "$VAJRA" checkdesignhandoff 2>&1 >/dev/null )"
dim "    \$ vajra checkdesignhandoff  ->  $(printf '%s' "$NOT_A_COMMAND" | head -1)"
printf '%s' "$ST" | grep -q "of 8 stations passed" \
  && ! printf '%s' "$ST" | grep -qiE '(\[PASSED\]|\[ABSENT\]|\[LEGACY\]).*(mandate|design-advisor)' \
  && [ "$OBC" -eq 1 ] \
  && printf '%s' "$NOT_A_COMMAND" | grep -q "unrecognised command"
score $? exec "case 9: K of 8 unmoved, prior gates unmoved, still 7 commands"

# --- demo:before_after ---------------------------------------------------------------------------
header "Before -> after  [demo:before_after]"
printf '%-48s %-30s %s\n' "A SESSION THAT..." "BEFORE S133" "AFTER S133"
printf '%-48s %-30s %s\n' "------------------------------------------------" "------------------------------" "-----------------------------------"
printf '%-48s %-30s %s\n' "never asked a design-advisor anything"    "closed, silently"            "BLOCKED from session 133 onward"
printf '%-48s %-30s %s\n' "skipped for a good reason"                "indistinguishable from above" "PASSES, and PRINTS the reason"
printf '%-48s %-30s %s\n' "wrote \`skipped\` with no reason"           "n/a"                          "BLOCKED — a skip costs a sentence"
printf '%-48s %-30s %s\n' "hand-typed the handoff"                   "n/a"                          "BLOCKED — provenance re-verified"
printf '%-48s %-30s %s\n' "wants out via an env var"                 "VAJRA_SKIP_*_GATE=1, no trace" "no such variable exists"
printf '%-48s %-30s %s\n' "is session 1 of a brand-new repo"         "n/a"                          "BLOCKED — the scaffold carries it"

# --- demo:summary_table --------------------------------------------------------------------------
header "Summary  [demo:summary_table]"
printf '%-62s %-7s %s\n' "CASE" "CLASS" "RESULT"
printf '%-62s %-7s %s\n' "--------------------------------------------------------------" "-------" "------"
for r in ${ROWS[@]+"${ROWS[@]}"}; do echo "$r"; done
echo ""
echo "  execute-based: $EXEC_N · structural: $STRUCT_N · behavioral source grep: $BEHAV_N"
echo "  (a class label here is self-assigned, exactly as in the verify suite — S122)"
echo ""
echo "WHAT THIS DEMO DOES NOT SHOW, in order:"
echo "  1. That a recorded reason is a GOOD one. \`design-advisor: skipped — pure fix\`, typed"
echo "     reflexively, passes every case above. The gate proves a sentence was written."
echo "  2. That the advice REACHED the design. Write the code, dispatch at close, land the"
echo "     handoff — every case above still goes green (.ai/ROADMAP.md F2f)."
echo "  3. Whether the reasoned skip becomes the default dodge. Nothing counts it yet; the"
echo "     counting rule is written down in sessions/session-133-summary.md and run by hand."
echo "  4. Anything off this machine: the provenance chain is local-machine-only and UNSIGNED"
echo "     (S131's disclosed limit, inherited whole, not improved here)."
echo "  A green demo is not a passing delivery — the fidelity verdict lives in"
echo "  sessions/session-133-review.md."
echo ""
if [ "$FAIL" -eq 0 ]; then
  ok "DEMO GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  no "DEMO RED ($PASS pass, $FAIL fail)"
  exit 1
fi
