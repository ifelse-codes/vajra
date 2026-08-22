#!/usr/bin/env bash
# Verify — Session 127: every recommendation must be ANSWERED (obeyed, refused, or deferred).
#
# What this suite must actually prove, beyond "a new module exists":
#   1. the REAL binary BLOCKS a session that leaves a recorded recommendation unanswered, naming
#      the role, the number and the handoff path — driven end-to-end, not read out of source;
#   2. it PASSES when every recommendation carries a disposition, and prints which one each took;
#   3. each evidence kind is existence-gated — a made-up sha, a placeholder reason, a deferral to
#      a file that does not exist are all scored UNANSWERED;
#   4. a handoff with no numbered recommendations WARNs and NAMES THE DODGE — it never blocks;
#   5. a MALFORMED handoff fails closed — it is never swallowed as "no handoffs";
#   6. every registered role is taught the marker shape the parser actually reads back;
#   7. NOTHING else moved — `K of 8` unchanged at a NON-degenerate baseline, still 7 commands;
#   8. the falsifiability fixture goes RED when the consumption is deleted and stays GREEN when
#      every message string is renamed.
#
# CHECK CLASSES — the S121/S122/S123 contract: EXECUTE-BASED (runs the product, asserts on real
# output) · STRUCTURAL grep (asserts architecture — no runtime output exists to exercise) ·
# BEHAVIORAL grep (greps source and treats it as proof the feature works — HOLLOW, named in the
# disclosure) · NESTED (runs another whole suite).
#
# S127 carries ONE behavioral check: the same hardcoded-usage-banner grep named since S69.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="127"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

PASS=0; FAIL=0; RESULTS=()
EXEC_N=0; STRUCT_N=0; BEHAV_N=0; NESTED_N=0; NESTED_NAMES=()
run_check() {
  local NAME="$1"; local CLASS="$2"; shift 2
  local LOG="$ARTIFACTS/${NAME}.log"
  case "$CLASS" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    nested) NESTED_N=$((NESTED_N+1)); NESTED_NAMES+=("$NAME") ;;
    *) echo "verify bug: unknown class '$CLASS' for $NAME"; exit 2 ;;
  esac
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-42s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-42s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# ── The subject: a throwaway repo carrying ONE governed handoff with one numbered rec ───────────
# The handoff is written by the REAL binary (`vajra next --role … --from …`), never hand-typed, so
# if the DECISION-007 contract changes the fixture follows it automatically (S122).
build_subject() {
  local TMP="$1"
  ( cd "$TMP" \
      && git init -q . \
      && git config user.email t@t && git config user.name t \
      && echo seed > seed.txt && git add -A && git commit -q -m seed --no-verify ) || return 1
  mkdir -p "$TMP/prompts" "$TMP/.ai/handoffs"
  echo "127" > "$TMP/.ai/SESSION"
  printf 'rec 1 — lift the S116 deferral in a DECISION-007 addendum\n' > "$TMP/brief.md"
  ( cd "$TMP" && "$VAJRA" next --role design-advisor --from brief.md >/dev/null 2>&1 ) || return 1
  [ -f "$TMP/.ai/handoffs/session-127-design-advisor.md" ] || return 1
  ( cd "$TMP" && git rev-parse HEAD )
}

# Rewrite the prompt from ONE template every time. Never mutate the previous state's file — that
# leak is exactly what made S122's fixture fire for the wrong reason.
write_prompt() { printf '# Session 127\n\n## Advice\n%s\n\n## Plan\n1. x\n' "$2" > "$1/prompts/127-task-x.md"; }

# --- 1. an unanswered recommendation BLOCKS, naming role + number + handoff path -----------------
unanswered_blocks() {
  local TMP; TMP="$(mktemp -d)"; local rc=0 SHA OUT
  SHA="$(build_subject "$TMP")" || { echo "FAIL: could not build the subject"; rm -rf "$TMP"; return 1; }
  write_prompt "$TMP" "- (nothing answered here)"
  OUT="$( cd "$TMP" && "$VAJRA" next --check-advice 127 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: expected exit 1, got $code"; rc=1; }
  grep -q "design-advisor rec 1" <<<"$OUT" || { echo "FAIL: the block does not name the role+number"; rc=1; }
  grep -q ".ai/handoffs/session-127-design-advisor.md" <<<"$OUT" || { echo "FAIL: the block does not name the handoff path"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "unanswered-rec-blocks-the-close" exec unanswered_blocks

# --- 2. every recommendation answered PASSES, and each disposition is printed --------------------
answered_passes() {
  local TMP; TMP="$(mktemp -d)"; local rc=0 SHA OUT
  SHA="$(build_subject "$TMP")" || { rm -rf "$TMP"; return 1; }
  write_prompt "$TMP" "- design-advisor rec 1 — obeyed: $SHA"
  OUT="$( cd "$TMP" && "$VAJRA" next --check-advice 127 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 0 ] || { echo "FAIL: expected exit 0, got $code"; rc=1; }
  grep -q "\[✓\] design-advisor rec 1 — obeyed:" <<<"$OUT" \
    || { echo "FAIL: the pass does not print the disposition each rec took"; rc=1; }
  grep -q "never that the answer was a good one" <<<"$OUT" \
    || { echo "FAIL: the gate does not state its own floor on a PASS"; rc=1; }
  # A reasoned refusal and a real deferral are equally valid answers — the point of the contract.
  write_prompt "$TMP" "- design-advisor rec 1 — refused: this session ships one story and that is a second"
  ( cd "$TMP" && "$VAJRA" next --check-advice 127 >/dev/null 2>&1 ) \
    || { echo "FAIL: a reasoned REFUSAL must pass — this gate forces an answer, not obedience"; rc=1; }
  write_prompt "$TMP" "- design-advisor rec 1 — deferred: prompts/127-task-x.md"
  ( cd "$TMP" && "$VAJRA" next --check-advice 127 >/dev/null 2>&1 ) \
    || { echo "FAIL: a deferral to a file that EXISTS must pass"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "every-rec-answered-passes" exec answered_passes

# --- 3. each evidence kind is existence-gated (criteria 3, 4, 5) ---------------------------------
unreal_evidence_blocks() {
  local TMP; TMP="$(mktemp -d)"; local rc=0 line OUT
  build_subject "$TMP" >/dev/null || { rm -rf "$TMP"; return 1; }
  for line in \
    "- design-advisor rec 1 — obeyed: 9999999" \
    "- design-advisor rec 1 — refused: <reason>" \
    "- design-advisor rec 1 — deferred: prompts/999-task-nope.md" \
    "- design-advisor rec 1 — obeyed: HEAD"
  do
    write_prompt "$TMP" "$line"
    OUT="$( cd "$TMP" && "$VAJRA" next --check-advice 127 2>&1 )"
    if [ $? -eq 1 ] && grep -q "design-advisor rec 1" <<<"$OUT"; then
      echo "OK: BLOCKED on '$line'"
    else
      echo "FAIL: '$line' did not block"; echo "$OUT"; rc=1
    fi
  done
  rm -rf "$TMP"; return $rc
}
run_check "unreal-evidence-is-scored-unanswered" exec unreal_evidence_blocks

# --- 4. no numbered recommendations -> WARN, dodge named. A MALFORMED handoff -> fails closed ----
dodge_named_and_malformed_fails_closed() {
  local TMP; TMP="$(mktemp -d)"; local rc=0 OUT
  build_subject "$TMP" >/dev/null || { rm -rf "$TMP"; return 1; }
  write_prompt "$TMP" "- (none)"
  # Replace the handoff's findings with prose carrying no numbers, through the real ingest path.
  printf 'You should probably do the thing.\n' > "$TMP/brief.md"
  ( cd "$TMP" && "$VAJRA" next --role design-advisor --from brief.md >/dev/null 2>&1 ) || rc=1
  OUT="$( cd "$TMP" && "$VAJRA" next --check-advice 127 2>&1 )"; local code=$?
  echo "$OUT"
  [ "$code" -eq 0 ] || { echo "FAIL: an unnumbered brief must WARN, never block (got $code)"; rc=1; }
  grep -q "DELETING THE NUMBERS DODGES THIS GATE" <<<"$OUT" \
    || { echo "FAIL: the gate does not name its own dodge in plain words"; rc=1; }

  # Now break the handoff's contract. It must fail CLOSED, not read as "no handoffs".
  printf 'not a handoff at all\n' > "$TMP/.ai/handoffs/session-127-design-advisor.md"
  OUT="$( cd "$TMP" && "$VAJRA" next --check-advice 127 2>&1 )"; code=$?
  echo "$OUT"
  [ "$code" -eq 1 ] || { echo "FAIL: a malformed handoff must BLOCK (got $code)"; rc=1; }
  grep -q "cannot read its input FAILS" <<<"$OUT" \
    || { echo "FAIL: the malformed block does not say why it failed closed"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "dodge-named-and-malformed-fails-closed" exec dodge_named_and_malformed_fails_closed

# --- 5. the round trip: what every role is TAUGHT is what the parser reads back ------------------
# EXECUTE-BASED via the test binary, deliberately NOT a grep for the sentence: a verify-script grep
# would be hollow (S122), and would also trip verify-session-121.sh's one-source-of-role-text guard
# the moment the addendum or the summary quotes the same words.
roles_taught_shape_round_trips() {
  cargo test -q --lib advice::tests::what_every_role_is_taught_to_write_is_what_the_parser_reads_back 2>&1 \
    | tee /dev/stderr | grep -q "test result: ok. 1 passed"
}
run_check "role-text-round-trips-through-the-parser" exec roles_taught_shape_round_trips

# --- 6. the falsifiability fixture is real: red on deletion, green on renaming -------------------
# rec 17: the two deletions are applied to a COPY of the module in a scratch checkout, so the
# working tree is never mutated. Each deletion removes one half of the CONSUMPTION.
fixture_fails_for_the_right_reason() {
  local WT; WT="$(mktemp -d)"; local rc=0
  git worktree add --detach -q "$WT" HEAD 2>/dev/null || { echo "FAIL: no clean-room worktree"; return 1; }
  local M="$WT/src/advice/mod.rs"

  # Control: the fixture is GREEN as shipped.
  ( cd "$WT" && cargo test -q --lib advice::falsifiability 2>&1 | grep -q "test result: ok" ) \
    && echo "OK: shipped fixture GREEN" || { echo "FAIL: the shipped fixture is not green"; rc=1; }

  # Deletion A — the ANSWER classification: every recorded disposition counts, real or not.
  perl -0pi -e 's/Some\(\(_, d\)\) => match check\(d\) \{\n\s*Ok\(\(\)\) => Answer::Answered\(d\.clone\(\)\),\n\s*Err\(why\) => Answer::Unreal\(d\.clone\(\), why\),\n\s*\},/Some((_, d)) => Answer::Answered(d.clone()),/s' "$M"
  if ( cd "$WT" && cargo test -q --lib advice::falsifiability 2>&1 | grep -q "test result: ok" ); then
    echo "FAIL: deleting the answer classification left the fixture GREEN"; rc=1
  else
    echo "OK: deleting the answer classification -> RED"
  fi
  git -C "$WT" checkout -q -- src/advice/mod.rs

  # Deletion B — the RECOMMENDATION parser: nothing is read out of the handoff at all.
  perl -0pi -e 's/for line in skip_fenced\(&handoff\.raw_body\) \{/for line in Vec::<&str>::new() {/' "$M"
  if ( cd "$WT" && cargo test -q --lib advice::falsifiability 2>&1 | grep -q "test result: ok" ); then
    echo "FAIL: deleting the recommendation parser left the fixture GREEN"; rc=1
  else
    echo "OK: deleting the recommendation parser -> RED"
  fi
  git -C "$WT" checkout -q -- src/advice/mod.rs

  # The other direction (S122): renaming every message string must NOT turn it red.
  perl -pi -e 's/names no commit in this repo/IS NOT A COMMIT, renamed/; s/no line in `## Advice` answers it/NOBODY ANSWERED, renamed/; s/names a file that does not exist/RENAMED MISSING FILE/; s/the refusal reason is still the template placeholder/RENAMED PLACEHOLDER/' "$M"
  if ( cd "$WT" && cargo test -q --lib advice::falsifiability 2>&1 | grep -q "test result: ok" ); then
    echo "OK: renaming every gate message -> still GREEN (the fixture binds to behaviour)"
  else
    echo "FAIL: the fixture is bound to message strings, not behaviour"; rc=1
  fi

  git worktree remove --force "$WT" >/dev/null 2>&1 || true
  return $rc
}
run_check "fixture-red-on-deletion-green-on-rename" exec fixture_fails_for_the_right_reason

# --- 7. nothing else moved: K of 8 at a NON-degenerate baseline ----------------------------------
# S126's review flagged that its own invariance check compared at a degenerate `0 of 8`. This one
# compares at a session that really passes stations, in a clean worktree of HEAD, before and after
# a governed handoff carrying numbered recommendations lands.
k_of_8_unchanged_at_a_real_baseline() {
  local WT; WT="$(mktemp -d)"; local rc=0 BEFORE AFTER
  git worktree add --detach -q "$WT" HEAD 2>/dev/null || { echo "FAIL: no worktree"; return 1; }
  BEFORE="$( cd "$WT" && "$VAJRA" next --stations 126 2>&1 | grep -oE '[0-9]+ of 8 stations passed' )"
  echo "baseline (session 126): $BEFORE"
  case "$BEFORE" in
    "0 of 8 stations passed"|"") echo "FAIL: DEGENERATE baseline — this check would prove nothing"; rc=1 ;;
  esac
  printf 'rec 1 — a numbered recommendation that must not move K\n' > "$WT/b.md"
  ( cd "$WT" && "$VAJRA" next --role plan-advisor --from b.md >/dev/null 2>&1 ) || rc=1
  AFTER="$( cd "$WT" && "$VAJRA" next --stations 126 2>&1 | grep -oE '[0-9]+ of 8 stations passed' )"
  echo "after a numbered handoff lands: $AFTER"
  [ "$BEFORE" = "$AFTER" ] || { echo "FAIL: advice moved K — it must be derived from station gates alone"; rc=1; }
  ( cd "$WT" && "$VAJRA" next --stations 126 2>&1 | grep -qi '^\s*\[.*\] *advice' ) \
    && { echo "FAIL: advice appears as a station row"; rc=1; } || echo "OK: advice is not a ninth station"
  git worktree remove --force "$WT" >/dev/null 2>&1 || true
  return $rc
}
run_check "k-of-8-unchanged-at-a-real-baseline" exec k_of_8_unchanged_at_a_real_baseline

# --- 8. the whole library is green, including the new module ------------------------------------
run_check "lib-tests-green" exec cargo test -q --lib

# --- 9. the non-goals stay non-goals ------------------------------------------------------------
# BEHAVIORAL, and labelled so — the same hardcoded-banner grep named since S69: it runs the real
# binary, but what it asserts on is a usage string an 8th command could be added without touching.
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"; echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "no-eighth-command" behav help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 127 Verify Summary ==="
printf '%-42s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-42s %-7s %s\n' "------------------------------------------" "-------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" "${NESTED_NAMES[@]:-}"
echo ""
echo "WHAT THIS SUITE NEVER EXERCISED — stated, not buried:"
echo "  * whether an 'obeyed: <sha>' commit actually IMPLEMENTS the advice it answers."
echo "  * whether a 'refused: <reason>' reason is SOUND. A one-word reason passes."
echo "  * an advisor that never numbers its advice. Deleting the numbers dodges this gate"
echo "    entirely — the self-granted-jurisdiction class (S68/S71), named here and in the gate."
echo "  Answered is proven. Obeyed-well is not, and is not claimed."
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
