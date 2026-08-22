#!/usr/bin/env bash
# Demo — Session 127: advice you asked for can no longer be dropped in silence.
#
# Sprint-demo contract (CONSTRAINTS.yaml#demo.required_elements): header · cases · summary_table ·
# before_after. Cumulative: replays what the fleet could already do (S109 governed handoff, S126's
# nine roles) and then shows the one thing that changed — a gate that CONSUMES one.
#
# Shaped by this session's own `demo-producer` brief (.ai/handoffs/session-127-demo-producer.md),
# whose 24 numbered recommendations are answered in the prompt's `## Advice`. Its anti-cases are
# honoured: no `|| true` on a scored assertion, no scoring the read-only `--advice` surface as
# proof of blocking, no assertion on a gate message's wording, and every state rewrites the prompt
# from ONE template rather than mutating the previous state's file.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="127"
BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"; RED="\033[31m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}== %s ==${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}> %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}OK %s${RESET}\n" "$1"; }
no()     { printf "${RED}xx %s${RESET}\n" "$1"; }
dim()    { printf "${DIM}%s${RESET}\n" "$1"; }

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "build failed"; exit 1; }
BASE="$(git merge-base HEAD main)"

PASS=0; FAIL=0; EXEC_N=0; STRUCT_N=0; BEHAV_N=0; ROWS=(); BLOCKS=0; LIMITS=0
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

# ── The throwaway subject. ONE temp dir, ONE prompt template, rewritten per state. ──────────────
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
( cd "$TMP" && git init -q . && git config user.email t@t && git config user.name t \
    && echo seed > seed.txt && git add -A && git commit -q -m seed --no-verify ) || exit 1
mkdir -p "$TMP/prompts" "$TMP/.ai/handoffs"
SUBJECT_SHA="$( cd "$TMP" && git rev-parse HEAD )"
# The prompt is the REAL S126 prompt, copied in unchanged — it has no `## Advice` section, which is
# the historical truth this demo re-enacts (demo-producer rec 7).
cp prompts/126-task-finish-the-fleet.md "$TMP/prompts/"
echo "126" > "$TMP/.ai/SESSION"
prompt_advice() {  # rewrite from ONE template; never edit the previous state in place (rec 8/23)
  local body="$1"
  { sed '/^## Advice/,$d' prompts/126-task-finish-the-fleet.md; printf '\n## Advice\n%s\n' "$body"; } \
    > "$TMP/prompts/126-task-finish-the-fleet.md"
}

# --- demo:header --------------------------------------------------------------------------------
header "Session ${SESSION} Demo — every recommendation must be ANSWERED  [demo:header]"
label "Every numbered recommendation in a session's governed handoffs must now carry a recorded"
label "disposition — obeyed: <sha> that resolves, refused: <reason> that is written, deferred:"
label "<path> that exists — or the session cannot close."
dim "This forces an ANSWER, not obedience. A reasoned refusal PASSES by design. What became"
dim "impossible is the silent version — the one that cost S126 twice in its own record."
dim "It is also the FIRST gate that reads a governed handoff as a binding input: eight station"
dim "gates read a marker inside the session's own prompt; this one reads"
dim ".ai/handoffs/session-NN-<role>.md too, and binds the two together (DECISION-007 S116"
dim "deferral, lifted in the S127 addendum)."
dim "One gate consumes handoffs. The other seven do not. The fleet is not 'wired in'."

# --- demo:before_after --------------------------------------------------------------------------
header "Before → after  [demo:before_after]"
echo "  merge-base: $BASE"

label "1. The machinery did not exist at all. Read from git, not typed."
if git show "$BASE:src/advice/mod.rs" >/dev/null 2>&1; then B_MOD="present"; else B_MOD="absent (git show fails)"; fi
B_FLAG=$( git show "$BASE:src/cli/next.rs" 2>/dev/null | grep -c -- '--check-advice' )
A_FLAG=$( grep -c -- '--check-advice' src/cli/next.rs )
B_SEC=$( git grep -l '^## Advice' "$BASE" -- 'prompts/*.md' 2>/dev/null | wc -l | tr -d ' ' )
A_SEC=$( grep -l '^## Advice' prompts/*.md 2>/dev/null | wc -l | tr -d ' ' )
printf "  %-38s %-24s %s\n" "" "BEFORE (merge-base)" "AFTER (this branch)"
printf "  %-38s %-24s %s\n" "--------------------------------------" "------------------------" "-----------"
printf "  %-38s %-24s %s\n" "src/advice/mod.rs"                 "$B_MOD"    "present"
printf "  %-38s %-24s %s\n" "'--check-advice' in src/cli/next.rs" "$B_FLAG"  "$A_FLAG"
printf "  %-38s %-24s %s\n" "prompts carrying a '## Advice' section" "$B_SEC" "$A_SEC"
[ "$B_FLAG" -eq 0 ] && [ "$A_FLAG" -gt 0 ] && [ "$B_SEC" -eq 0 ] && [ "$A_SEC" -gt 0 ]
score $? exec "before: no gate, no section — after: both, read from git"

label "2. The DECISION-007 deferral — the record change a feature demo would otherwise hide."
echo "  BEFORE (merge-base):"
git show "$BASE:docs/decisions/DECISION-007-agent-fleet.md" 2>/dev/null | grep -n "explicitly deferred as a non-goal" | head -1 | sed 's/^/    /'
echo "  AFTER (this branch):"
grep -n "S116 deferral is LIFTED" docs/decisions/DECISION-007-agent-fleet.md | head -1 | sed 's/^/    /'
B_LIFT=$( git show "$BASE:docs/decisions/DECISION-007-agent-fleet.md" 2>/dev/null | grep -c "S116 deferral is LIFTED" )
A_LIFT=$( grep -c "S116 deferral is LIFTED" docs/decisions/DECISION-007-agent-fleet.md )
[ "$B_LIFT" -eq 0 ] && [ "$A_LIFT" -gt 0 ]
score $? exec "the locked deferral is lifted on the record, not silently deviated from"

label "3. What actually went wrong in S126 — and what happens now."
printf "\n  %-34s %-30s %s\n" "WHAT THE ADVISOR RECORDED" "WHAT S126 SHIPPED" "WHAT HAPPENS NOW"
printf "  %-34s %-30s %s\n" "----------------------------------" "------------------------------" "----------------"
printf "  %-34s %-30s %s\n" "demo-producer: show the verify-121" "the roster only; no trace" "BLOCKS the close"
printf "  %-34s %-30s %s\n" "  unpin in the before/after"        "  anywhere. Surfaced by"    "  until answered"
printf "  %-34s %-30s %s\n" ""                                   "  luck in a later cold pass" ""
printf "  %-34s %-30s %s\n" "design-advisor: S127 reverses a"    "never reached the first"    "BLOCKS the close"
printf "  %-34s %-30s %s\n" "  locked DECISION-007 deferral"     "  draft of the S127 prompt"  "  until answered"
echo ""

# --- demo:cases ---------------------------------------------------------------------------------
header "Cases — the real binary  [demo:cases]"

label "1. The session that SHIPS the gate is the first subject of it. Its own advice, answered."
REAL_OUT="$( "$VAJRA" next --check-advice 127 2>&1 )"; REAL_CODE=$?
N_TOTAL=$( grep -cE '^ +\[.\] ' <<<"$REAL_OUT" )
N_BAD=$(   grep -cE '^ +\[✗\] ' <<<"$REAL_OUT" )
echo "$REAL_OUT" | grep -E '^ +\[.\] ' | head -3 | cut -c1-140
dim "  … $((N_TOTAL - 3)) more (full list: vajra next --advice 127)"
echo "  recommendations recorded: $N_TOTAL   unanswered: $N_BAD   exit: $REAL_CODE"
[ "$REAL_CODE" -eq 0 ] && [ "$N_TOTAL" -gt 0 ] && [ "$N_BAD" -eq 0 ]
score $? exec "this session answers every one of its own $N_TOTAL recommendations"

label "2. The disposition MIX — proof that honest disobedience passes."
N_OB=$(  grep -cE '^ +\[✓\] .* — obeyed: '   <<<"$REAL_OUT" )
N_RE=$(  grep -cE '^ +\[✓\] .* — refused: '  <<<"$REAL_OUT" )
N_DE=$(  grep -cE '^ +\[✓\] .* — deferred: ' <<<"$REAL_OUT" )
echo "  obeyed: $N_OB · refused: $N_RE · deferred: $N_DE   (sum $((N_OB+N_RE+N_DE)) of $N_TOTAL)"
[ $((N_OB+N_RE+N_DE)) -eq "$N_TOTAL" ]
score $? exec "every recommendation took exactly one of the three dispositions"

label "3. Zero ORPHANS — no recorded answer points at advice no handoff records."
N_ORPH=$( grep -c "which no handoff for session" <<<"$REAL_OUT" )
echo "  orphan warnings: $N_ORPH"
[ "$N_ORPH" -eq 0 ]; score $? exec "no answer points at a renumbered or vanished recommendation"

label "4. S126's REAL drop, re-enacted. Verbatim advisor text, the real prompt, the real writer."
VERBATIM="$( grep -o 'without it the before/after only shows the after' .ai/handoffs/session-126-demo-producer.md | head -1 )"
[ -n "$VERBATIM" ] || VERBATIM="show the verify-session-121.sh unpin in the before/after"
printf 'rec 2 — %s\n' "$VERBATIM" > "$TMP/brief.md"
echo "  advisor said (verbatim from S126's committed handoff): \"$VERBATIM\""
( cd "$TMP" && "$VAJRA" next --role demo-producer --from brief.md >/dev/null 2>&1 ) || { no "ingest failed"; exit 1; }
OUT="$( cd "$TMP" && "$VAJRA" next --check-advice 126 2>&1 )"; CODE=$?
echo "$OUT" | grep -E 'verdict|✗' | head -2 | cut -c1-160
[ "$CODE" -eq 1 ] && grep -q "demo-producer rec 2" <<<"$OUT" \
  && grep -q ".ai/handoffs/session-126-demo-producer.md" <<<"$OUT"
score $? exec "the item S126 actually dropped now BLOCKS, naming role + number + path"
BLOCKS=$((BLOCKS+1))

label "5. The same subject, answered — a reasoned refusal is a pass."
prompt_advice "- demo-producer rec 2 — refused: S126 shipped one story and the unpin is a second"
OUT="$( cd "$TMP" && "$VAJRA" next --check-advice 126 2>&1 )"; CODE=$?
echo "$OUT" | grep -E 'verdict|\[✓\]' | head -2 | cut -c1-160
[ "$CODE" -eq 0 ]; score $? exec "refused: <reason> -> exit 0 (honest disobedience passes)"

label "6. Answered with a commit that EXISTS, and with a deferral to a file that EXISTS."
prompt_advice "- demo-producer rec 2 — obeyed: $SUBJECT_SHA"
( cd "$TMP" && "$VAJRA" next --check-advice 126 >/dev/null 2>&1 ); R1=$?
prompt_advice "- demo-producer rec 2 — deferred: prompts/126-task-finish-the-fleet.md"
( cd "$TMP" && "$VAJRA" next --check-advice 126 >/dev/null 2>&1 ); R2=$?
echo "  obeyed:<real sha> exit=$R1   deferred:<file that exists> exit=$R2"
[ "$R1" -eq 0 ] && [ "$R2" -eq 0 ]; score $? exec "obeyed and deferred with real evidence -> exit 0"

label "7. An answer whose EVIDENCE IS NOT REAL is scored unanswered — the S68/S61/S67 rules."
RC=0
for LINE in "obeyed: 9999999" "obeyed: HEAD" "refused: <reason>" "deferred: prompts/999-nope.md"; do
  prompt_advice "- demo-producer rec 2 — $LINE"
  OUT="$( cd "$TMP" && "$VAJRA" next --check-advice 126 2>&1 )"; C=$?
  if [ "$C" -eq 1 ] && grep -q "demo-producer rec 2" <<<"$OUT"; then printf "  BLOCKED  %s\n" "$LINE"
  else printf "  LEAKED   %s\n" "$LINE"; RC=1; fi
done
[ "$RC" -eq 0 ]; score $? exec "fake sha, bare ref, placeholder reason, missing target: all block"
BLOCKS=$((BLOCKS+4))

label "8. A MALFORMED handoff FAILS CLOSED — never swallowed as 'nothing to answer'."
prompt_advice "- demo-producer rec 2 — obeyed: $SUBJECT_SHA"
cp "$TMP/.ai/handoffs/session-126-demo-producer.md" "$TMP/keep.md"
printf 'not a handoff at all\n' > "$TMP/.ai/handoffs/session-126-demo-producer.md"
OUT="$( cd "$TMP" && "$VAJRA" next --check-advice 126 2>&1 )"; CODE=$?
echo "$OUT" | grep -E 'verdict|✗' | head -2 | cut -c1-160
[ "$CODE" -eq 1 ]; score $? exec "malformed handoff -> exit 1 (a gate that cannot evaluate FAILS)"
BLOCKS=$((BLOCKS+1))
cp "$TMP/keep.md" "$TMP/.ai/handoffs/session-126-demo-producer.md"

label "9. The nine-role round trip: what every role is TOLD to write is what the gate READS BACK."
mkdir -p "$TMP/.claude/agents"; ( cd "$TMP" && "$VAJRA" init >/dev/null 2>&1 </dev/null )
RT_OK=0; RT_N=0
for DEF in "$TMP"/.claude/agents/*.md; do
  R="$(basename "$DEF" .md)"; RT_N=$((RT_N+1))
  grep -E '^\s*rec 1 ' "$DEF" | head -1 > "$TMP/rt.md"
  ( cd "$TMP" && "$VAJRA" next --role "$R" --from rt.md >/dev/null 2>&1 ) || continue
  ( cd "$TMP" && "$VAJRA" next --check-advice 126 2>&1 ) | grep -q "$R rec 1" && RT_OK=$((RT_OK+1))
  rm -f "$TMP/.ai/handoffs/session-126-$R.md"
done
echo "  roles whose own taught example is read back by the gate: $RT_OK of $RT_N"
[ "$RT_N" -eq 9 ] && [ "$RT_OK" -eq 9 ]; score $? exec "9 of 9 roles: taught shape == parsed shape, through the binary"

label "10. THE HONEST BLIND SPOT, run live: this gate would NOT have caught S126's two drops."
OUT="$( "$VAJRA" next --check-advice 126 2>&1 )"; CODE=$?
grep -o "DELETING THE NUMBERS DODGES THIS GATE" <<<"$OUT" | head -1 | sed 's/^/  /'
echo "  real repo, S126's five committed handoffs -> exit $CODE (a WARN, not a block)"
[ "$CODE" -eq 0 ] && grep -q "DELETING THE NUMBERS DODGES THIS GATE" <<<"$OUT"
score $? exec "unnumbered handoffs WARN and the gate names its own dodge — a disclosed limit"
LIMITS=$((LIMITS+1))

label "11. Nothing else moved: K of 8, and still seven commands."
STATIONS="$( "$VAJRA" next --stations 126 2>&1 )"
K_LINE="$( grep -oE '[0-9]+ of 8 stations passed' <<<"$STATIONS" )"
ROWS_N="$( grep -cE '^\s+\[(PASSED|ABSENT|LEGACY)\]' <<<"$STATIONS" )"
echo "  $K_LINE · station rows: $ROWS_N · advice among them: $(grep -ci 'advice' <<<"$STATIONS")"
HELP="$( "$VAJRA" --help 2>&1 )"
grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$HELP" && CMD_OK=0 || CMD_OK=1
echo "  usage banner: $(grep -o 'vajra <[^>]*>' <<<"$HELP" | head -1)"
[ "$ROWS_N" -eq 8 ] && [ "$K_LINE" != "0 of 8 stations passed" ] && [ -n "$K_LINE" ] \
  && [ "$(grep -ci 'advice' <<<"$STATIONS")" -eq 0 ] && [ "$CMD_OK" -eq 0 ]
score $? exec "8 station rows at a non-degenerate baseline, no advice station, 7 commands"

dim "NARRATED, not scored: the falsifiability experiment is 'delete the consumption and watch it go"
dim "red' — a demo cannot perform that on itself without lying. It lives in mod falsifiability"
dim "(src/advice/mod.rs) and its execute-based twin in scripts/verify-session-127.sh."
dim "Also narrated: the --advance wiring. Driving a full close inside a throwaway repo needs a"
dim "session branch, a maturity level and a prior session's ship state; the binding is asserted by"
dim "test and by the verify suite, and is NOT shown running here."

# --- demo:summary_table -------------------------------------------------------------------------
header "Summary  [demo:summary_table]"
printf '%-62s %-7s %s\n' "CASE" "CLASS" "RESULT"
printf '%-62s %-7s %s\n' "--------------------------------------------------------------" "-------" "------"
for r in "${ROWS[@]}"; do echo "$r"; done
echo ""
label "This session's own advice ledger — rendered from the real --check-advice output, not typed:"
printf '  %-12s %s\n' "DISPOSITION" "COUNT"
printf '  %-12s %s\n' "------------" "-----"
printf '  %-12s %s\n' "obeyed"   "$N_OB"
printf '  %-12s %s\n' "refused"  "$N_RE"
printf '  %-12s %s\n' "deferred" "$N_DE"
printf '  %-12s %s\n' "TOTAL"    "$N_TOTAL"
echo ""
echo "  execute-based: $EXEC_N · structural: $STRUCT_N · behavioral source grep: $BEHAV_N"
echo "  (a class label here is self-assigned, exactly as in the verify suite — S122)"
echo "  BLOCKS demonstrated: $BLOCKS (missing · bad sha · bare ref · placeholder reason ·"
echo "                          missing deferral target · malformed handoff)"
echo "  LIMITS demonstrated: $LIMITS (unnumbered handoffs WARN only — and it is S126's own record"
echo "                          that proves the limit is real, not hypothetical)"
echo ""
echo "WHAT THIS DEMO DOES NOT SHOW, in order:"
echo "  1. It does not show OBEDIENCE. Every case proves an answer was recorded and its evidence"
echo "     is real. Required != obeyed; answered != obeyed well."
echo "  2. The refusal floor is a FORM floor: a one-word reason passes, by decision."
echo "  3. Jurisdiction is self-granted (S68/S71) — case 10 shows it live, against the very"
echo "     handoffs whose dropped advice motivated this session."
echo "  4. ONE gate consumes handoffs; the other seven do not, and nothing here dispatches an"
echo "     advisor (the standing S111 limit every fleet demo since S109 has disclosed)."
echo "  A green demo is not a passing delivery — the fidelity verdict lives in"
echo "  sessions/session-127-review.md."
echo ""
if [ "$FAIL" -eq 0 ]; then
  ok "DEMO GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  no "DEMO RED ($PASS pass, $FAIL fail)"
  exit 1
fi
