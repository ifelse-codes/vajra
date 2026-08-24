#!/usr/bin/env bash
# Verify — Session 131: the `fidelity-reviewer` handoff becomes MANDATORY, and its provenance
# becomes PROVABLE (not the hardcoded literal `"claude-code-subagent"`).
#
# What this suite must actually prove, beyond "a new module exists":
#   1. the REAL binary BLOCKS a close with no fidelity-reviewer handoff at all, naming the path;
#   2. a handoff with FABRICATED/unverifiable provenance BLOCKS — never silently accepted as real;
#   3. a REAL dispatch (the S111/S117/S123 evidentiary shape, built as a fixture — never asserted
#      in prose) writes a VERIFIED provenance and the gate PASSES on it;
#   4. a MALFORMED handoff fails closed, not read as "absent";
#   5. the gate really BINDS `vajra next --advance`, driven live, with every other stage
#      neutralised so the refusal can only be this one's — and the documented override both
#      advances and announces itself;
#   6. the falsifiability fixture goes RED when the cross-check is bypassed and stays GREEN when
#      every message string is renamed (S122/S127's contract, applied to a NEW module);
#   7. NOTHING else moved — `K of 8` unchanged at a non-degenerate baseline, still 7 commands, this
#      gate is not a ninth station;
#   8. the whole library (including `dispatch`/`fidelity`) is green.
#
# CHECK CLASSES — the S121/S122/S123 contract: EXECUTE-BASED (runs the product, asserts on real
# output) · STRUCTURAL grep (asserts architecture — no runtime output exists to exercise) ·
# BEHAVIORAL grep (greps source and treats it as proof the feature works — HOLLOW, disclosed) ·
# NESTED (runs another whole suite).

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="131"
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
    RESULTS+=("$(printf '%-46s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-46s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# ── A throwaway repo, seeded the same way for every check below ─────────────────────────────────
build_subject() {
  local TMP="$1"
  ( cd "$TMP" && git init -q . && git config user.email t@t && git config user.name t \
      && echo seed > seed.txt && git add -A && git commit -q -m seed --no-verify ) || return 1
  mkdir -p "$TMP/.ai/handoffs" "$TMP/prompts"
  echo "131" > "$TMP/.ai/SESSION"
  printf 'rec 1 — an example finding\n' > "$TMP/brief.md"
}

# Real, physical path (macOS's /tmp is a symlink to /private/tmp) — the same resolution
# `env::current_dir()` performs inside the binary, so a fixture project dir keyed on the RAW
# `mktemp -d` path would silently miss (a lesson this session's own manual smoke-test hit first).
real_tmpdir() { ( cd "$(mktemp -d)" && pwd -P ); }

# Build a REAL fixture dispatch matching the S111/S117/S123 evidentiary shape: a subagent
# meta.json + its own transcript (carrying `gitBranch`), and a parent transcript recording the
# matching `tool_use` call — three independently-checked facts, not one hand-typed blob.
build_real_dispatch_fixture() {
  local PROJROOT="$1" REPOROOT="$2" SESSION_BRANCH="$3" TOOL_ID="$4"
  local SLUG; SLUG="$(echo "$REPOROOT" | sed 's#/#-#g')"
  local PROJ="$PROJROOT/$SLUG"
  local UUID="sess-uuid-fixture"
  mkdir -p "$PROJ/$UUID/subagents"
  printf '{"agentType":"fidelity-reviewer","toolUseId":"%s"}' "$TOOL_ID" \
    > "$PROJ/$UUID/subagents/agent-x1.meta.json"
  printf '{"gitBranch":"%s","type":"user"}\n' "$SESSION_BRANCH" \
    > "$PROJ/$UUID/subagents/agent-x1.jsonl"
  printf '{"message":{"content":[{"type":"tool_use","id":"%s","name":"Agent","input":{"subagent_type":"fidelity-reviewer"}}]}}\n' "$TOOL_ID" \
    > "$PROJ/$UUID.jsonl"
}

# --- 1. no handoff at all -> BLOCKS, naming the absence + path ------------------------------------
absent_handoff_blocks() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT
  build_subject "$TMP" || { rm -rf "$TMP"; return 1; }
  OUT="$( cd "$TMP" && "$VAJRA" next --check-fidelity-handoff 131 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: expected exit 1, got $code"; rc=1; }
  grep -q "no fidelity-reviewer handoff recorded for session 131" <<<"$OUT" \
    || { echo "FAIL: does not name the absence"; rc=1; }
  grep -q ".ai/handoffs/session-131-fidelity-reviewer.md" <<<"$OUT" \
    || { echo "FAIL: does not name the expected path"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "absent-handoff-blocks" exec absent_handoff_blocks

# --- 2. a handoff with FABRICATED provenance -> BLOCKS, not silently accepted ---------------------
fabricated_provenance_blocks() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT
  build_subject "$TMP" || { rm -rf "$TMP"; return 1; }
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
- `+` new: hand-typed for the fixture
HAND
  OUT="$( cd "$TMP" && "$VAJRA" next --check-fidelity-handoff 131 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: expected exit 1, got $code"; rc=1; }
  grep -q "could not be independently re-verified" <<<"$OUT" \
    || { echo "FAIL: does not name the re-verification failure"; rc=1; }
  # A bare pre-S131 label with no id at all must ALSO block, distinctly.
  sed -i.bak 's/agent: claude-code-subagent (verified: toolu_TOTALLYMADEUP)/agent: claude-code-subagent/' \
    "$TMP/.ai/handoffs/session-131-fidelity-reviewer.md"
  OUT="$( cd "$TMP" && "$VAJRA" next --check-fidelity-handoff 131 2>&1 )"
  grep -q "no verifiable dispatch id" <<<"$OUT" \
    || { echo "FAIL: a bare pre-S131 label does not block on 'no verifiable dispatch id'"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "fabricated-provenance-blocks" exec fabricated_provenance_blocks

# --- 3. a REAL dispatch fixture writes VERIFIED provenance and the gate PASSES --------------------
real_dispatch_verifies_and_passes() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT PROJROOT
  build_subject "$TMP" || { rm -rf "$TMP"; return 1; }
  ( cd "$TMP" && git checkout -q -b session-131-fixture-branch )
  PROJROOT="$TMP/fake-cc-projects"
  build_real_dispatch_fixture "$PROJROOT" "$TMP" "session-131-fixture-branch" "toolu_01FIXTURE"
  OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --role fidelity-reviewer --from brief.md 2>&1 )"
  echo "$OUT"
  grep -q "provenance: claude-code-subagent (verified: toolu_01FIXTURE)" <<<"$OUT" \
    || { echo "FAIL: the write path did not derive a VERIFIED provenance from the real fixture"; rc=1; }
  OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --check-fidelity-handoff 131 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 0 ] || { echo "FAIL: expected exit 0 on a real dispatch, got $code"; rc=1; }
  grep -q "verdict: READY" <<<"$OUT" || { echo "FAIL: expected READY"; rc=1; }
  # A role dispatched under the WRONG session's branch must still fail — the gitBranch bind, live.
  local PROJROOT2="$TMP/fake-cc-projects-wrong-branch"
  build_real_dispatch_fixture "$PROJROOT2" "$TMP" "session-93-some-other-work" "toolu_01WRONGSESSION"
  OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT2" "$VAJRA" next --role fidelity-reviewer --from brief.md 2>&1 )"
  grep -q "unverifiable" <<<"$OUT" \
    || { echo "FAIL: a dispatch recorded under a different session's branch was accepted"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "real-dispatch-fixture-verifies-and-passes" exec real_dispatch_verifies_and_passes

# --- 4. a MALFORMED handoff fails CLOSED, never read as "absent" ----------------------------------
malformed_handoff_fails_closed() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT
  build_subject "$TMP" || { rm -rf "$TMP"; return 1; }
  printf 'not a handoff at all\n' > "$TMP/.ai/handoffs/session-131-fidelity-reviewer.md"
  OUT="$( cd "$TMP" && "$VAJRA" next --check-fidelity-handoff 131 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: expected exit 1, got $code"; rc=1; }
  grep -q "does not satisfy the handoff contract" <<<"$OUT" \
    || { echo "FAIL: does not say why it failed closed"; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "malformed-handoff-fails-closed" exec malformed_handoff_fails_closed

# --- 5. the gate really BINDS `--advance`, driven, with every other stage neutralised --------------
advance_binds_the_close_path() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0 OUT
  ( cd "$TMP" && git init -q . && git config user.email t@t && git config user.name t \
      && "$VAJRA" init >/dev/null 2>&1 </dev/null ) || { echo "FAIL: init"; rm -rf "$TMP"; return 1; }
  echo "50" > "$TMP/.ai/SESSION"
  mkdir -p "$TMP/.ai/handoffs" "$TMP/prompts"
  printf '# S50\n\n## Plan\n1. x\n' > "$TMP/prompts/50-task-x.md"
  ( cd "$TMP" && git add -A >/dev/null 2>&1 && git commit -q -m seed --no-verify \
      && git checkout -q -b session-50-x ) || { echo "FAIL: branch"; rm -rf "$TMP"; return 1; }

  local SKIPS="VAJRA_SKIP_ANALYST_GATE=1 VAJRA_SKIP_ARCHITECT_GATE=1 VAJRA_SKIP_PLANNER_GATE=1 \
VAJRA_SKIP_CODER_GATE=1 VAJRA_SKIP_QA_GATE=1 VAJRA_SKIP_DEMOER_GATE=1 VAJRA_SKIP_RELEASER_GATE=1 \
VAJRA_SKIP_ADVICE_GATE=1"

  OUT="$( cd "$TMP" && eval "$SKIPS" "$VAJRA" next --advance 2>&1 )"; local code=$?
  echo "$OUT" | grep -iE 'fidelity|refusing' | head -5
  [ "$code" -ne 0 ] || { echo "FAIL: --advance succeeded with no fidelity-reviewer handoff"; rc=1; }
  grep -q "\[vajra fidelity\]" <<<"$OUT" || { echo "FAIL: the refusal did not come from the Fidelity gate"; rc=1; }

  OUT="$( cd "$TMP" && eval "$SKIPS" VAJRA_SKIP_FIDELITY_GATE=1 "$VAJRA" next --advance 2>&1 )"; code=$?
  grep -q "VAJRA_SKIP_FIDELITY_GATE set" <<<"$OUT" \
    || { echo "FAIL: the override does not announce itself"; echo "$OUT" | tail -5; rc=1; }
  [ "$code" -eq 0 ] || { echo "FAIL: the override did not advance (exit $code)"; echo "$OUT" | tail -5; rc=1; }
  rm -rf "$TMP"; return $rc
}
run_check "advance-really-binds-on-missing-fidelity-handoff" exec advance_binds_the_close_path

# --- 6. the pure cross-check's truth table (unit tests) --------------------------------------------
dispatch_and_fidelity_unit_tests_green() {
  cargo test -q --lib dispatch:: 2>&1 | tee /tmp/verify131-dispatch.$$ ; local d=$?
  grep -q "test result: ok" /tmp/verify131-dispatch.$$ || d=1
  cargo test -q --lib fidelity:: 2>&1 | tee /tmp/verify131-fidelity.$$; local f=$?
  grep -q "test result: ok" /tmp/verify131-fidelity.$$ || f=1
  rm -f /tmp/verify131-dispatch.$$ /tmp/verify131-fidelity.$$
  [ "$d" -eq 0 ] && [ "$f" -eq 0 ]
}
run_check "dispatch-and-fidelity-unit-tests-green" exec dispatch_and_fidelity_unit_tests_green

# --- 7. the falsifiability fixture is real: red on bypass, green on renaming -----------------------
# `cargo test` accepts exactly one TESTNAME filter, so the two modules are checked with two
# invocations joined by `&&` — never one invalid multi-arg call silently doing nothing.
both_modules_green() {
  ( cd "$1" && cargo test -q --lib dispatch::tests:: 2>&1 | grep -q "test result: ok" ) \
    && ( cd "$1" && cargo test -q --lib fidelity::tests:: 2>&1 | grep -q "test result: ok" )
}
fixture_fails_for_the_right_reason() {
  local WT; WT="$(mktemp -d)"; local rc=0
  git worktree add --detach -q "$WT" HEAD 2>/dev/null || { echo "FAIL: no clean-room worktree"; return 1; }
  local D="$WT/src/dispatch/mod.rs"

  both_modules_green "$WT" \
    && echo "OK: shipped fixture GREEN" || { echo "FAIL: the shipped fixture is not green"; rc=1; }

  # Bypass A — the gitBranch bind: accept ANY branch, not just this session's.
  perl -0pi -e 's/Some\(b\) if b\.starts_with\(&expected_prefix\) => Ok\(\(\)\),/Some(_b) => Ok(()),/' "$D"
  if ( cd "$WT" && cargo test -q --lib dispatch::tests::cross_check_fails_when_git_branch_is_a_different_session 2>&1 | grep -q "test result: ok" ); then
    echo "FAIL: bypassing the gitBranch bind left its own test GREEN"; rc=1
  else
    echo "OK: bypassing the gitBranch bind -> RED"
  fi
  git -C "$WT" checkout -q -- src/dispatch/mod.rs

  # Bypass B — the role-identity check on the PARENT side: accept any subagent_type.
  perl -0pi -e 's/if parent\.subagent_type != role_name \{/if false {/' "$D"
  if ( cd "$WT" && cargo test -q --lib dispatch::tests::cross_check_fails_when_parent_dispatched_a_different_role 2>&1 | grep -q "test result: ok" ); then
    echo "FAIL: bypassing the parent role check left its own test GREEN"; rc=1
  else
    echo "OK: bypassing the parent role check -> RED"
  fi
  git -C "$WT" checkout -q -- src/dispatch/mod.rs

  # The other direction (S122): renaming every message string must NOT turn it red.
  perl -pi -e 's/no parent-transcript tool_use call for/RENAMED: no parent call for/; s/no subagent meta\.json for/RENAMED: no meta for/; s/appears in neither a parent transcript/RENAMED: appears nowhere/' "$D"
  if both_modules_green "$WT"; then
    echo "OK: renaming every gate message -> still GREEN (the fixture binds to behaviour)"
  else
    echo "FAIL: the fixture is bound to message strings, not behaviour"; rc=1
  fi

  git worktree remove --force "$WT" >/dev/null 2>&1 || true
  return $rc
}
run_check "fixture-red-on-bypass-green-on-rename" exec fixture_fails_for_the_right_reason

# --- 8. nothing else moved: K of 8 at a non-degenerate baseline, and this is not a 9th station -----
k_of_8_unchanged_and_not_a_ninth_station() {
  local WT; WT="$(mktemp -d)"; local rc=0 BEFORE AFTER
  git worktree add --detach -q "$WT" HEAD 2>/dev/null || { echo "FAIL: no worktree"; return 1; }
  BEFORE="$( cd "$WT" && "$VAJRA" next --stations 126 2>&1 | grep -oE '[0-9]+ of 8 stations passed' )"
  echo "baseline (session 126): $BEFORE"
  case "$BEFORE" in
    "0 of 8 stations passed"|"") echo "FAIL: DEGENERATE baseline — this check would prove nothing"; rc=1 ;;
  esac
  printf 'rec 1 — a fixture finding that must not move K\n' > "$WT/b.md"
  ( cd "$WT" && "$VAJRA" next --role fidelity-reviewer --from b.md >/dev/null 2>&1 ) || rc=1
  AFTER="$( cd "$WT" && "$VAJRA" next --stations 126 2>&1 | grep -oE '[0-9]+ of 8 stations passed' )"
  echo "after a fidelity-reviewer handoff lands: $AFTER"
  [ "$BEFORE" = "$AFTER" ] || { echo "FAIL: the handoff moved K — it must be derived from station gates alone"; rc=1; }
  local SOUT; SOUT="$( cd "$WT" && "$VAJRA" next --stations 126 2>&1 )"
  if grep -ciE '(\[PASSED\]|\[ABSENT\]|\[LEGACY\]) *fidelity' <<<"$SOUT" | grep -qv '^0$'; then
    echo "FAIL: fidelity appears as a station row"; rc=1
  else
    echo "OK: fidelity is not a ninth station ($(grep -cE '\[(PASSED|ABSENT|LEGACY)\]' <<<"$SOUT") station rows read)"
  fi
  git worktree remove --force "$WT" >/dev/null 2>&1 || true
  return $rc
}
run_check "k-of-8-unchanged-and-not-a-ninth-station" exec k_of_8_unchanged_and_not_a_ninth_station

# --- 9. the whole library is green, including the two new modules ----------------------------------
run_check "lib-tests-green" exec cargo test -q --lib

# --- 10. the non-goals stay non-goals ---------------------------------------------------------------
# BEHAVIORAL, and labelled so — the same hardcoded-banner grep named since S69.
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"; echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "no-eighth-command" behav help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 131 Verify Summary ==="
printf '%-46s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-46s %-7s %s\n' "----------------------------------------------" "-------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" "${NESTED_NAMES[@]:-}"
echo ""
echo "WHAT THIS SUITE NEVER EXERCISED — stated, not buried:"
echo "  * whether the fidelity-reviewer's own verdict was thorough or correct — that stays"
echo "    sessions/session-NN-review.md's job, gated separately (verify-closeout.sh, pre-existing)."
echo "  * anything off this machine — the whole provenance check is local-machine-only, same"
echo "    disclosed limit as scripts/check-subagent-cost-fields.sh (S111) and --dogfood-age (S91)."
echo "  * a second role made mandatory the same way — explicitly out of scope this session."
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
