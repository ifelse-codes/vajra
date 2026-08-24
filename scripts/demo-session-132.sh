#!/usr/bin/env bash
# Demo — Session 132: an `obeyed:` disposition must be JUDGED TRUE, not merely resolve.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases ·
# summary_table · before_after. Cumulative: this demo re-derives `K of 8`, the 7-command floor
# and S131's Fidelity gate alongside the new one.
#
# The claim under demonstration: a session can no longer close on an `obeyed: <sha>` that nobody
# independent ever checked — and the S127 specimen that started this is caught on the REAL record.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="132"
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

# ── The subject: a throwaway repo, never this one (except case 5, which is the point). ────────────
real_tmpdir() { ( cd "$(mktemp -d "${TMPDIR:-/tmp}/vajra-demo-132-XXXXXX")" && pwd -P ); }
TMP="$(real_tmpdir)"; trap 'rm -rf "$TMP"' EXIT
case "$TMP" in "$ROOT"*) echo "demo bug: temp dir inside the repo"; exit 2;; esac
( cd "$TMP" && git init -q . && git config user.email t@t && git config user.name t \
    && echo seed > seed.txt && git add -A && git commit -q -m seed --no-verify \
    && git checkout -q -b session-132-demo-subject ) || exit 1
mkdir -p "$TMP/.ai/handoffs" "$TMP/prompts"
echo "132" > "$TMP/.ai/SESSION"
SHA="$( cd "$TMP" && git rev-parse --short=7 HEAD )"
printf '# S132 demo\n\n## Advice\n\n- plan-advisor rec 1 — obeyed: %s\n' "$SHA" \
  > "$TMP/prompts/132-task-demo.md"
cat > "$TMP/.ai/handoffs/session-132-plan-advisor.md" <<HAND
---
role: plan-advisor
session: 132
agent: claude-code-subagent (verified: toolu_ADVISOR)
source-sha: deadbeef
captured: 2026-08-24T00:00:00Z
cost_usd: null
---

# Plan-advisor handoff — session 132

rec 1 — record a covers: tag on every plan step

## Handoff Delta
- \`+\` new: demo advisor brief
HAND

PROJROOT="$TMP/fake-cc-projects"
build_dispatch() {
  local ROLE="$1" TOOL_ID="$2"
  local SLUG; SLUG="$(echo "$TMP" | sed 's#/#-#g')"
  local PROJ="$PROJROOT/$SLUG" UUID="uuid-$ROLE"
  mkdir -p "$PROJ/$UUID/subagents"
  printf '{"agentType":"%s","toolUseId":"%s"}' "$ROLE" "$TOOL_ID" > "$PROJ/$UUID/subagents/agent-x1.meta.json"
  printf '{"gitBranch":"session-132-demo-subject","type":"user"}\n' > "$PROJ/$UUID/subagents/agent-x1.jsonl"
  printf '{"message":{"content":[{"type":"tool_use","id":"%s","name":"Agent","input":{"subagent_type":"%s"}}]}}\n' \
    "$TOOL_ID" "$ROLE" > "$PROJ/$UUID.jsonl"
}
land_judgment() {
  { printf 'rec 1 — a finding from the judge\n\n'; printf '%s\n' "$1"; } > "$TMP/judge.md"
  ( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --role "$2" --from judge.md ) >/dev/null 2>&1
}

# --- demo:header -----------------------------------------------------------------------------------
header "Session ${SESSION} Demo — an \`obeyed:\` that nobody checked no longer closes a session  [demo:header]"
dim "  S127 shipped the disposition contract, then recorded \`implementation-advisor rec 9 —"
dim "  obeyed: 8cd3bea\` against advice that said 'delete the _uses stub'. The sha resolved, so the"
dim "  gate scored it ANSWERED and the session closed READY. The stub was still there."
dim "  S132 makes an INDEPENDENT, provenance-verified judgment the price of an \`obeyed:\`."
dim "  Subject: $TMP — a throwaway repo (case 5 is the exception, and deliberately so)."

# --- demo:cases --------------------------------------------------------------------------------
header "Cases — the real binary, driven live  [demo:cases]"

label "case 1 — BEFORE: the Advice gate is happy, because the sha resolves"
OUT="$( cd "$TMP" && "$VAJRA" next --check-advice 132 2>&1 )"
dim "    $(printf '%s\n' "$OUT" | grep -E 'plan-advisor rec 1|verdict:' | tr '\n' ' ')"
printf '%s' "$OUT" | grep -q "verdict: READY"
score $? exec "case 1: --check-advice still says READY — answered is not obeyed"

label "case 2 — AFTER: the same session cannot close, because nobody judged it"
OUT="$( cd "$TMP" && "$VAJRA" next --check-obeyed 132 2>&1 )"; RC=$?
dim "    $(printf '%s\n' "$OUT" | grep -E 'UNJUDGED|verdict:' | head -2 | tr '\n' ' ')"
[ "$RC" -eq 1 ] && printf '%s' "$OUT" | grep -q "UNJUDGED"
score $? exec "case 2: an unjudged \`obeyed:\` BLOCKS (exit 1)"

label "case 3 — a MISMATCH verdict blocks and says what the judge disagreed with"
build_dispatch fidelity-reviewer toolu_01DEMOJUDGE
land_judgment "obeyed-check plan-advisor rec 1 — mismatch: ${SHA} — the commit adds a seed file and no covers: tag" fidelity-reviewer
OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-obeyed 132 2>&1 )"; RC=$?
dim "    $(printf '%s\n' "$OUT" | grep -E 'MISMATCH' | head -1)"
[ "$RC" -eq 1 ] && printf '%s' "$OUT" | grep -q "no covers: tag"
score $? exec "case 3: a mismatch BLOCKS, naming role, rec number and disagreement"

label "case 4 — the three forgeries: self-graded, stale sha, hand-typed provenance"
build_dispatch plan-advisor toolu_01DEMOSELF
land_judgment "obeyed-check plan-advisor rec 1 — implemented: ${SHA} — graded by its own author" plan-advisor
SELF="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-obeyed 132 2>&1 )"
dim "    self-graded   -> $(printf '%s\n' "$SELF" | grep -o 'graded its OWN recommendation' | head -1)"
rm -f "$TMP/.ai/handoffs/session-132-plan-advisor.md"
cat > "$TMP/.ai/handoffs/session-132-plan-advisor.md" <<HAND
---
role: plan-advisor
session: 132
agent: claude-code-subagent (verified: toolu_ADVISOR)
source-sha: deadbeef
captured: 2026-08-24T00:00:00Z
cost_usd: null
---

# Plan-advisor handoff — session 132

rec 1 — record a covers: tag on every plan step

## Handoff Delta
- \`+\` new: demo advisor brief
HAND
land_judgment "obeyed-check plan-advisor rec 1 — implemented: 0000000abc — I read some other commit" fidelity-reviewer
STALE="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-obeyed 132 2>&1 )"
dim "    stale sha     -> $(printf '%s\n' "$STALE" | grep -o 'is stale, not evidence' | head -1)"
perl -pi -e 's/^agent: .*/agent: claude-code-subagent (verified: toolu_HANDTYPED)/' \
  "$TMP/.ai/handoffs/session-132-fidelity-reviewer.md"
perl -pi -e "s/0000000abc/${SHA}/" "$TMP/.ai/handoffs/session-132-fidelity-reviewer.md"
TYPED="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-obeyed 132 2>&1 )"
dim "    hand-typed    -> $(printf '%s\n' "$TYPED" | grep -o 'could not be independently re-verified' | head -1)"
printf '%s' "$SELF"  | grep -q "graded its OWN recommendation" \
  && printf '%s' "$STALE" | grep -q "is stale, not evidence" \
  && printf '%s' "$TYPED" | grep -q "could not be independently re-verified"
score $? exec "case 4: all three inadmissible judgments refused, each for its own reason"

label "case 5 — the S127 specimen, on the REAL record of this repo (not a fixture)"
OUT="$( "$VAJRA" next --check-obeyed 127 2>&1 )"; RC=$?
dim "    $(printf '%s\n' "$OUT" | grep 'implementation-advisor rec 9' | head -1)"
[ "$RC" -eq 1 ] && printf '%s' "$OUT" | grep -q "implementation-advisor rec 9 — obeyed: 8cd3bea — MISMATCH"
score $? exec "case 5: the defect that started this is caught on the real historical record"

label "case 6 — a TRUE judgment from a verified independent judge passes"
rm -f "$TMP/.ai/handoffs/session-132-fidelity-reviewer.md"
build_dispatch fidelity-reviewer toolu_01DEMOJUDGE
land_judgment "obeyed-check plan-advisor rec 1 — implemented: ${SHA} — the commit really lands what rec 1 asked for" fidelity-reviewer
OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-obeyed 132 2>&1 )"; RC=$?
dim "    $(printf '%s\n' "$OUT" | grep -E 'implemented \(|verdict:' | head -2 | tr '\n' ' ')"
[ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -q "verdict: READY"
score $? exec "case 6: a real judgment passes — the gate is not merely a blocker"

label "case 7 — the gate really refuses \`--advance\`, every other stage neutralised"
rm -f "$TMP/.ai/handoffs/session-132-fidelity-reviewer.md"
SKIPS="VAJRA_SKIP_ANALYST_GATE=1 VAJRA_SKIP_ARCHITECT_GATE=1 VAJRA_SKIP_PLANNER_GATE=1 VAJRA_SKIP_CODER_GATE=1 VAJRA_SKIP_QA_GATE=1 VAJRA_SKIP_DEMOER_GATE=1 VAJRA_SKIP_RELEASER_GATE=1 VAJRA_SKIP_ADVICE_GATE=1 VAJRA_SKIP_FIDELITY_GATE=1"
OUT="$( cd "$TMP" && eval "$SKIPS" "$VAJRA" next --advance 2>&1 )"; RC=$?
dim "    $(printf '%s\n' "$OUT" | grep -i '\[vajra obeyed\]' | head -1)"
[ "$RC" -ne 0 ] && printf '%s' "$OUT" | grep -q '\[vajra obeyed\]'
score $? exec "case 7: --advance is refused BY THIS GATE, driven end-to-end"

label "case 8 — nothing else moved: K of 8, S131's Fidelity gate, 7 commands"
ST="$( "$VAJRA" next --stations 126 2>&1 )"
dim "    $(printf '%s\n' "$ST" | grep 'stations passed')"
NOT_A_COMMAND="$( "$VAJRA" checkobeyed 2>&1 >/dev/null )"
dim "    \$ vajra checkobeyed  ->  $(printf '%s' "$NOT_A_COMMAND" | head -1)"
printf '%s' "$ST" | grep -q "of 8 stations passed" \
  && ! printf '%s' "$ST" | grep -qiE '(\[PASSED\]|\[ABSENT\]|\[LEGACY\]).*obeyed' \
  && printf '%s' "$NOT_A_COMMAND" | grep -q "unrecognised command"
score $? exec "case 8: K of 8 unmoved, still 7 commands — this rides \`vajra next\`"

# --- demo:before_after -------------------------------------------------------------------------
header "Before -> after  [demo:before_after]"
printf '%-46s %-30s %s\n' "AN \`obeyed: <sha>\` DISPOSITION" "BEFORE S132" "AFTER S132"
printf '%-46s %-30s %s\n' "----------------------------------------------" "------------------------------" "-----------------------------------"
printf '%-46s %-30s %s\n' "cited a commit that does something else" "PASSED (the sha resolved)"    "BLOCKED once a judge says mismatch"
printf '%-46s %-30s %s\n' "was never read by anyone independent"   "PASSED, silently"             "BLOCKED from session 132 onward"
printf '%-46s %-30s %s\n' "graded by the advisor that gave it"     "n/a (no judgment existed)"     "REFUSED — no self-certification"
printf '%-46s %-30s %s\n' "judged, then the sha edited underneath" "n/a"                          "REFUSED — the judgment names its sha"
printf '%-46s %-30s %s\n' "S127 rec 9 (\`obeyed: 8cd3bea\`)"        "READY"                        "MISMATCH, on the real record"

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
echo "  1. That a judge's verdict is CORRECT. \`implemented:\` written without reading the diff"
echo "     passes every case above — the same form floor S127 disclosed for a refusal reason."
echo "  2. An end to the regress: the judge's own recommendations get dispositions that would"
echo "     themselves need judging. S132 terminates that by hand, not by mechanism."
echo "  3. \`refused:\` / \`deferred:\` soundness — explicitly out of scope this session."
echo "  4. Anything off this machine: the provenance chain is local-machine-only and UNSIGNED"
echo "     (S131's disclosed limit, inherited whole, not improved here)."
echo "  A green demo is not a passing delivery — the fidelity verdict lives in"
echo "  sessions/session-132-review.md."
echo ""
if [ "$FAIL" -eq 0 ]; then
  ok "DEMO GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  no "DEMO RED ($PASS pass, $FAIL fail)"
  exit 1
fi
