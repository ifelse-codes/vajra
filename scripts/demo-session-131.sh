#!/usr/bin/env bash
# Demo — Session 131: the fidelity-reviewer handoff, mandatory and provable.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases ·
# summary_table · before_after. Cumulative: this demo re-derives `K of 8` and the 7-command
# floor from prior sessions, alongside the new gate.
#
# The claim under demonstration: a session cannot close without a REAL fidelity-reviewer
# handoff — not merely a file with that name.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="131"
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

# ── The subject: a throwaway repo, never this one. ────────────────────────────────────────────────
real_tmpdir() { ( cd "$(mktemp -d "${TMPDIR:-/tmp}/vajra-demo-131-XXXXXX")" && pwd -P ); }
TMP="$(real_tmpdir)"; trap 'rm -rf "$TMP"' EXIT
case "$TMP" in "$ROOT"*) echo "demo bug: temp dir inside the repo"; exit 2;; esac
( cd "$TMP" && git init -q . && git config user.email t@t && git config user.name t \
    && echo seed > seed.txt && git add -A && git commit -q -m seed --no-verify ) || exit 1
mkdir -p "$TMP/.ai/handoffs" "$TMP/prompts"
echo "131" > "$TMP/.ai/SESSION"
( cd "$TMP" && git checkout -q -b session-131-demo-subject )

# --- demo:header -----------------------------------------------------------------------------------
header "Session ${SESSION} Demo — the fidelity-reviewer handoff, mandatory and provable  [demo:header]"
dim "  S130's ground truth found fleet usage falling every session (S126 5 handoffs -> S129 0),"
dim "  with no gate that ever complained about the zero — and the one field that claimed a real"
dim "  dispatch (\`agent: claude-code-subagent\`) was a hardcoded literal a hand-typed file could"
dim "  copy for free. This session makes fidelity-reviewer MANDATORY and its provenance PROVABLE."
dim "  Subject: $TMP — a throwaway repo, never this one."

# --- demo:cases --------------------------------------------------------------------------------
header "Cases — the real binary, three directions, driven live  [demo:cases]"

label "case 1 — a session with NO fidelity-reviewer handoff cannot close"
OUT="$( cd "$TMP" && "$VAJRA" next --check-fidelity-handoff 131 2>&1 )"; RC=$?
dim "    $(printf '%s\n' "$OUT" | grep '✗')"
[ "$RC" -eq 1 ] && printf '%s' "$OUT" | grep -q "no fidelity-reviewer handoff recorded"
score $? exec "case 1: absence BLOCKS, naming the exact missing path"

label "case 2 — a hand-typed handoff claiming a made-up dispatch id is refused"
cat > "$TMP/.ai/handoffs/session-131-fidelity-reviewer.md" <<'HAND'
---
role: fidelity-reviewer
session: 131
agent: claude-code-subagent (verified: toolu_TOTALLYMADEUP)
source-sha: deadbeef
captured: 2026-08-24T00:00:00Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 131

rec 1 — a fabricated finding

## Handoff Delta
- `+` new: hand-typed for the demo
HAND
OUT="$( cd "$TMP" && "$VAJRA" next --check-fidelity-handoff 131 2>&1 )"; RC=$?
dim "    $(printf '%s\n' "$OUT" | grep '✗' | cut -c1-110)"
[ "$RC" -eq 1 ] && printf '%s' "$OUT" | grep -q "could not be independently re-verified"
score $? exec "case 2: a fabricated dispatch id is refused, not silently accepted"

label "case 3 — a REAL dispatch (the S111/S117/S123 evidentiary shape) writes VERIFIED provenance"
PROJ="$TMP/fake-cc-projects"
SLUG="$(echo "$TMP" | sed 's#/#-#g')"
mkdir -p "$PROJ/$SLUG/sess-uuid-demo/subagents"
printf '{"agentType":"fidelity-reviewer","toolUseId":"toolu_01DEMOFIXTURE"}' \
  > "$PROJ/$SLUG/sess-uuid-demo/subagents/agent-x1.meta.json"
printf '{"gitBranch":"session-131-demo-subject","type":"user"}\n' \
  > "$PROJ/$SLUG/sess-uuid-demo/subagents/agent-x1.jsonl"
printf '{"message":{"content":[{"type":"tool_use","id":"toolu_01DEMOFIXTURE","name":"Agent","input":{"subagent_type":"fidelity-reviewer"}}]}}\n' \
  > "$PROJ/$SLUG/sess-uuid-demo.jsonl"
printf 'rec 1 — a real finding\n' > "$TMP/brief.md"
OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJ" "$VAJRA" next --role fidelity-reviewer --from brief.md 2>&1 )"
dim "    $(printf '%s\n' "$OUT" | grep 'provenance:')"
printf '%s' "$OUT" | grep -q "provenance: claude-code-subagent (verified: toolu_01DEMOFIXTURE)"
score $? exec "case 3: a real dispatch derives VERIFIED provenance, not a hardcoded string"

label "case 4 — and the gate now PASSES on that same handoff"
OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJ" "$VAJRA" next --check-fidelity-handoff 131 2>&1 )"; RC=$?
dim "    $(printf '%s\n' "$OUT" | grep 'verdict:')"
[ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -q "verdict: READY"
score $? exec "case 4: a real, independently re-verified dispatch PASSES"

label "case 5 — a dispatch recorded under a DIFFERENT session's branch does not count"
PROJ2="$TMP/fake-cc-projects-wrong"
mkdir -p "$PROJ2/$SLUG/sess-uuid-wrong/subagents"
printf '{"agentType":"fidelity-reviewer","toolUseId":"toolu_01WRONGSESSION"}' \
  > "$PROJ2/$SLUG/sess-uuid-wrong/subagents/agent-x1.meta.json"
printf '{"gitBranch":"session-93-prove-commit-gate-teeth","type":"user"}\n' \
  > "$PROJ2/$SLUG/sess-uuid-wrong/subagents/agent-x1.jsonl"
printf '{"message":{"content":[{"type":"tool_use","id":"toolu_01WRONGSESSION","name":"Agent","input":{"subagent_type":"fidelity-reviewer"}}]}}\n' \
  > "$PROJ2/$SLUG/sess-uuid-wrong.jsonl"
OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJ2" "$VAJRA" next --role fidelity-reviewer --from brief.md 2>&1 )"
dim "    $(printf '%s\n' "$OUT" | grep 'provenance:' | cut -c1-110)"
printf '%s' "$OUT" | grep -q "unverifiable"
score $? exec "case 5: a real dispatch from a DIFFERENT session's branch is rejected too"

label "case 6 — the close path really refuses without this gate's say-so"
( cd "$TMP" && printf '{"agentType":"fidelity-reviewer","toolUseId":"toolu_01DEMOFIXTURE"}' \
    > "$PROJ/$SLUG/sess-uuid-demo/subagents/agent-x1.meta.json" )
rm -rf "$TMP/.ai/handoffs"; mkdir -p "$TMP/.ai/handoffs"
printf '# S131\n\n## Plan\n1. x\n' > "$TMP/prompts/131-task-x.md"
SKIPS="VAJRA_SKIP_ANALYST_GATE=1 VAJRA_SKIP_ARCHITECT_GATE=1 VAJRA_SKIP_PLANNER_GATE=1 VAJRA_SKIP_CODER_GATE=1 VAJRA_SKIP_QA_GATE=1 VAJRA_SKIP_DEMOER_GATE=1 VAJRA_SKIP_RELEASER_GATE=1 VAJRA_SKIP_ADVICE_GATE=1"
OUT="$( cd "$TMP" && eval "$SKIPS" "$VAJRA" next --advance 2>&1 )"; RC=$?
dim "    $(printf '%s\n' "$OUT" | grep -i '\[vajra fidelity\]')"
[ "$RC" -ne 0 ] && printf '%s' "$OUT" | grep -q '\[vajra fidelity\]'
score $? exec "case 6: --advance is refused BY THIS GATE, driven end-to-end"

label "case 7 — nothing else moved: K of 8 unchanged, this is not a 9th station"
ST="$( "$VAJRA" next --stations 126 2>&1 )"
dim "    $(printf '%s\n' "$ST" | grep 'stations passed')"
printf '%s' "$ST" | grep -q "of 8 stations passed" \
  && ! printf '%s' "$ST" | grep -qiE '(\[PASSED\]|\[ABSENT\]|\[LEGACY\]).*fidelity'
score $? exec "case 7: K of 8 unmoved, fidelity is a fleet gate, not a station"

label "case 8 — still 7 top-level commands"
NOT_A_COMMAND="$( "$VAJRA" checkfidelity 2>&1 >/dev/null )"
dim "    \$ vajra checkfidelity  ->  $(printf '%s' "$NOT_A_COMMAND" | head -1)"
printf '%s' "$NOT_A_COMMAND" | grep -q "unrecognised command"
score $? exec "case 8: still 7 commands — this gate rides \`vajra next\`, not an 8th"

# --- demo:before_after -------------------------------------------------------------------------
header "Before -> after  [demo:before_after]"
printf '%-42s %-26s %s\n' "WHAT A SESSION CANNOT DO" "BEFORE S131" "AFTER S131"
printf '%-42s %-26s %s\n' "------------------------------------------" "--------------------------" "-------------------------"
printf '%-42s %-26s %s\n' "close with zero fleet handoffs"       "silently allowed (S129 did)" "BLOCKED without fidelity-reviewer"
printf '%-42s %-26s %s\n' "hand-type a fake dispatch"            "\`agent:\` was a hardcoded literal" "re-derived + independently re-verified"
printf '%-42s %-26s %s\n' "reuse an old real dispatch id"        "n/a (no check existed)"      "rejected — gitBranch binds it to THIS session"
printf '%-42s %-26s %s\n' "\`--advance\` with no fidelity handoff" "succeeded"                   "refused, by name, at L2/L3"

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
echo "  1. Whether the fidelity-reviewer's own verdict was thorough or correct. That stays"
echo "     sessions/session-NN-review.md's job, gated separately (pre-existing, unchanged)."
echo "  2. Anything off this machine. The whole provenance check is local-machine-only, the same"
echo "     disclosed limit as check-subagent-cost-fields.sh (S111) and --dogfood-age (S91)."
echo "  3. A second role made mandatory the same way — explicitly out of scope this session."
echo "  4. Whether the mandate changes what sessions actually DO — this demo proves the gate"
echo "     blocks/passes correctly; whether builders route around it with the override is a"
echo "     usage question only future sessions' git history can answer."
echo "  A green demo is not a passing delivery — the fidelity verdict lives in"
echo "  sessions/session-131-review.md."
echo ""
if [ "$FAIL" -eq 0 ]; then
  ok "DEMO GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  no "DEMO RED ($PASS pass, $FAIL fail)"
  exit 1
fi
