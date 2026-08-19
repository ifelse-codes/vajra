#!/usr/bin/env bash
# Verify — Session 123: fence the qa-specialist Write/Edit grant.
#
# S121 shipped the fleet's first executing role holding Bash, Write, Edit — documented, not
# controlled. S122's own addendum retracted the "cannot fake a pass" claim and named the grant as
# the last self-granted jurisdiction in the fleet: on both live runs the working tree was
# unchanged only because the agent CHOSE to leave it alone, "which is not a control."
#
# This suite's ONE job beyond "the fence exists": prove it has TEETH against a REAL write attempt,
# not against the fence's own source text. The load-bearing fixture below runs the actual compiled
# binary's --clean-room-open/--clean-room-close against a real (throwaway) git repo, attempts a
# write while pointed at the clean room, and shows the SOURCE repo's HEAD sha / `git ls-files -s`
# hash / `git status --porcelain` are byte-identical before and after — then runs the SAME
# detection logic against a write that bypasses the clean room, to prove the check is not
# vacuously green (S122 lesson: a fixture that cannot fail is not evidence).
#
# CHECK CLASSES — same as S121/S122 (EXECUTE-BASED / STRUCTURAL grep / BEHAVIORAL grep / NESTED).
#
# THE EXECUTOR THESIS IS STILL UNPROVEN, and fencing this grant does not change that. What this
# session adds is INDEPENDENCE-preserving isolation: the role cannot repair the product it is
# testing and report the repair as the original state, without that repair being detectable. It
# does not prove no executor can ever fake a pass — see DECISION-007's S123 addendum for the
# residual risk (the clean room isolates the REPO, not the MACHINE; Bash remains granted).

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="123"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

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
    RESULTS+=("$(printf '%-38s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-38s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- toolchain: unchanged discipline ------------------------------------------------------------
run_check "cargo-build"   exec cargo build --all-targets
run_check "cargo-test"    exec cargo test --lib
run_check "cargo-fmt"     exec cargo fmt -- --check
run_check "cargo-clippy"  exec cargo clippy --all-targets -- -D warnings

VAJRA="$ROOT/target/debug/vajra"

# `cargo test --lib <filter>` EXITS 0 WHEN THE FILTER MATCHES NOTHING (S112) — reused verbatim.
named_test_passed() {
  local out; out="$(cargo test --lib "$1" 2>&1)"
  echo "$out"
  grep -qE 'test result: ok\. [1-9][0-9]* passed' <<<"$out" \
    || { echo "FAIL: filter '$1' matched no test that ran and passed"; return 1; }
}
filter_guard_has_teeth() {
  if named_test_passed fleet::tests::this_test_does_not_exist_on_purpose >/dev/null 2>&1; then
    echo "FAIL: named_test_passed is green on a filter that matches no test"; return 1
  fi
  echo "OK: a filter matching zero tests fails, as it must"
}
run_check "test-filter-guard-has-teeth" exec filter_guard_has_teeth

# ONE SOURCE (established S123 step 2, now a third user): confirm this suite's own tally
# functions also resolve from lib-tally.sh, not a local redefinition.
tally_is_one_source() {
  shopt -s extdebug
  local pt tn
  pt="$(declare -F print_tally 2>/dev/null | awk '{print $NF}')"
  tn="$(declare -F tally_discloses_nesting 2>/dev/null | awk '{print $NF}')"
  shopt -u extdebug
  case "$pt" in */lib-tally.sh) ;; *) echo "FAIL: print_tally did not resolve from lib-tally.sh (got: $pt)"; return 1 ;; esac
  case "$tn" in */lib-tally.sh) ;; *) echo "FAIL: tally_discloses_nesting did not resolve from lib-tally.sh (got: $tn)"; return 1 ;; esac
  echo "OK: both tally functions resolved from lib-tally.sh, not a local copy"
}
run_check "tally-is-one-source" struct tally_is_one_source

# --- the nested suite ----------------------------------------------------------------------------
# verify-session-122.sh already nests 121 + fleet-smoke + s113-counter — nesting it here carries
# the whole prior chain without re-typing it. Run ONCE; later checks assert on this run's output.
S122_LOG="$ARTIFACTS/s122-run.txt"
bash scripts/verify-session-122.sh > "$S122_LOG" 2>&1; S122_RC=$?
s122_exited_zero() { echo "verify-session-122.sh exit code: $S122_RC"; tail -40 "$S122_LOG"; [ "$S122_RC" -eq 0 ]; }
run_check "s122-suite-green" nested s122_exited_zero

# --- unit-level proof the new primitives exist and pass, independent of the CLI ------------------
run_check "gate-run-open-persistent-tests" exec named_test_passed gate_run::tests::open_persistent
run_check "gate-run-remove-persistent-tests" exec named_test_passed gate_run::tests::remove_persistent

# --- the grant itself: Write/Edit dropped, Bash kept ----------------------------------------------
# BEHAVIORAL, reclassified from an initial `exec` label after the dispatched qa-specialist's live
# run named it correctly: this greps a STATIC, already-committed file. It proves the checked-in
# artifact currently reads as the narrowed grant; it does NOT re-render from `fleet::ROLES` and
# diff, so a hand-edited or stale file would pass identically, and it proves nothing about whether
# Claude Code's harness actually HONOURS the `tools:` line at dispatch time (that is the S123 step
# 3(a) measurement, done live against the real dispatch mechanism, not from inside a shell script —
# see DECISION-007's S123 addendum). The real execute-based coverage of the render logic lives in
# `cargo test --lib fleet::tests::render_subagent_definition_is_correct_for_every_registered_role`,
# already exercised by `cargo-test` above.
grant_is_bash_read_grep_glob_only() {
  local F="$ROOT/.claude/agents/qa-specialist.md"
  [ -f "$F" ] || { echo "FAIL: qa-specialist.md is not scaffolded in this repo"; return 1; }
  grep -q "^tools: Bash, Read, Grep, Glob$" "$F" \
    || { echo "FAIL: the scaffolded grant is not the S123 narrowed grant"; return 1; }
  ! grep -q "Write" "$F" || { echo "FAIL: Write still present in the rendered grant"; return 1; }
  ! grep -q "Edit" "$F" || { echo "FAIL: Edit still present in the rendered grant"; return 1; }
  echo "OK: the scaffolded qa-specialist grant reads Bash, Read, Grep, Glob — no Write/Edit \
(this checks the committed FILE, not that the harness enforces it — see the comment above)"
}
run_check "grant-write-edit-dropped" behav grant_is_bash_read_grep_glob_only

# --- clean-room-open is gated to roles that actually hold Bash ------------------------------------
clean_room_open_refuses_read_only_role() {
  local OUT; OUT="$("$VAJRA" next --role researcher --clean-room-open 2>&1)"; local RC=$?
  echo "$OUT"
  [ "$RC" -ne 0 ] || { echo "FAIL: a read-only role's --clean-room-open exited 0"; return 1; }
  grep -q "read-only" <<<"$OUT" || { echo "FAIL: refusal did not name the reason"; return 1; }
  echo "OK: a read-only role is refused a clean room, on the real CLI path"
}
run_check "clean-room-open-refuses-read-only" exec clean_room_open_refuses_read_only_role

# ==================================================================================================
# THE LOAD-BEARING FIXTURE (AC 5): a write ATTEMPTED during a QA run does not touch the source repo.
# ==================================================================================================
# Built against a THROWAWAY git repo (never this repo) — real files, real git, real hashes, but
# nothing here can touch the working tree this suite itself is running from. S122 lesson applied:
# the subject is rebuilt from a known-clean commit before each half, so a later assertion cannot
# inherit an earlier half's planted state and pass for the wrong reason.
clean_room_fence_has_teeth() {
  local TMP; TMP="$(mktemp -d)"; local rc=0
  # Deliberately NOT `vajra init` here: `resolve_role("qa-specialist")` resolves against the
  # compiled-in `fleet::ROLES` table, not a file on disk, so --clean-room-open needs nothing but a
  # `.ai/` directory to satisfy `repo_root()`. Running `vajra init` would also install this repo's
  # OWN governance hooks (`core.hooksPath`) into the throwaway subject, which then correctly BLOCKS
  # a plain commit to `main` — real teeth, wrong fixture. Keep the subject minimal on purpose.
  (
    set -e
    cd "$TMP"
    git init -q .
    git config user.email t@t.com; git config user.name T
    mkdir -p .ai
    echo "1" > .ai/SESSION
    echo "original" > tracked.txt
    git add -A
    git commit -q -m "subject: minimal .ai + tracked file"
  )
  [ -d "$TMP/.ai" ] || { echo "FAIL: subject repo has no .ai directory"; rm -rf "$TMP"; return 1; }
  git -C "$TMP" rev-parse HEAD >/dev/null 2>&1 \
    || { echo "FAIL: subject repo has no HEAD commit — fixture setup itself failed"; rm -rf "$TMP"; return 1; }

  echo "--- half 1: write routed THROUGH the clean room (the fenced path) ---"
  local HEAD_BEFORE LS_BEFORE STATUS_BEFORE
  HEAD_BEFORE="$(git -C "$TMP" rev-parse HEAD)"
  LS_BEFORE="$(git -C "$TMP" ls-files -s | shasum -a 256 | awk '{print $1}')"
  STATUS_BEFORE="$(git -C "$TMP" status --porcelain)"

  local OPEN_OUT CR_PATH
  OPEN_OUT="$(cd "$TMP" && "$VAJRA" next --role qa-specialist --clean-room-open 2>&1)"
  echo "$OPEN_OUT"
  CR_PATH="$(head -1 <<<"$OPEN_OUT" | sed -E 's/^clean room opened for [^:]+: //')"
  [ -d "$CR_PATH" ] || { echo "FAIL: --clean-room-open did not produce a real directory"; rc=1; }
  [ -f "$CR_PATH/tracked.txt" ] || { echo "FAIL: the clean room does not carry the committed file"; rc=1; }

  # Simulate a QA run's write while correctly pointed at the clean room.
  echo "PROBE-FROM-QA-RUN" >> "$CR_PATH/tracked.txt"

  local HEAD_AFTER LS_AFTER STATUS_AFTER
  HEAD_AFTER="$(git -C "$TMP" rev-parse HEAD)"
  LS_AFTER="$(git -C "$TMP" ls-files -s | shasum -a 256 | awk '{print $1}')"
  STATUS_AFTER="$(git -C "$TMP" status --porcelain)"

  if grep -q "PROBE-FROM-QA-RUN" "$CR_PATH/tracked.txt" \
     && ! grep -q "PROBE-FROM-QA-RUN" "$TMP/tracked.txt" \
     && [ "$HEAD_BEFORE" = "$HEAD_AFTER" ] \
     && [ "$LS_BEFORE" = "$LS_AFTER" ] \
     && [ "$STATUS_BEFORE" = "$STATUS_AFTER" ]; then
    echo "OK: the write landed in the clean room; source HEAD/ls-files-hash/porcelain unchanged"
  else
    echo "FAIL: fenced write path did not land purely in the clean room"
    echo "  head:   before=$HEAD_BEFORE after=$HEAD_AFTER"
    echo "  ls:     before=$LS_BEFORE after=$LS_AFTER"
    echo "  status: before=[$STATUS_BEFORE] after=[$STATUS_AFTER]"
    rc=1
  fi

  (cd "$TMP" && "$VAJRA" next --role qa-specialist --clean-room-close "$CR_PATH" >/dev/null 2>&1)
  [ ! -d "$CR_PATH" ] || { echo "FAIL: --clean-room-close did not remove the worktree"; rc=1; }

  echo "--- half 2 (negative control, S122 lesson): the SAME detection catches an UNFENCED write ---"
  # Proves half 1's "unchanged" result is not vacuous — restore-then-mutate the subject directly,
  # bypassing any clean room, exactly what routing through one exists to prevent.
  HEAD_BEFORE="$(git -C "$TMP" rev-parse HEAD)"
  LS_BEFORE="$(git -C "$TMP" ls-files -s | shasum -a 256 | awk '{print $1}')"
  echo "UNFENCED-PROBE" >> "$TMP/tracked.txt"
  STATUS_AFTER="$(git -C "$TMP" status --porcelain)"
  LS_AFTER="$(git -C "$TMP" ls-files -s | shasum -a 256 | awk '{print $1}')"
  # ls-files -s hashes the INDEX, not the working tree, so an unstaged edit shows only in
  # porcelain — the real signal an unfenced write leaves. Assert on porcelain, not the ls hash.
  if [ -n "$STATUS_AFTER" ] && grep -q "tracked.txt" <<<"$STATUS_AFTER"; then
    echo "OK: an unfenced write IS detected (porcelain flips) — the check above has teeth"
  else
    echo "FAIL: the detection logic is vacuous — it did not catch a real unfenced write either"
    rc=1
  fi
  git -C "$TMP" checkout -q -- tracked.txt
  [ -z "$(git -C "$TMP" status --porcelain)" ] || { echo "FAIL: could not restore the subject repo to clean"; rc=1; }

  rm -rf "$TMP"
  return $rc
}
run_check "clean-room-fence-has-teeth" exec clean_room_fence_has_teeth

# --- the non-goals stay non-goals ---------------------------------------------------------------
# BEHAVIORAL, and labelled so — the same hardcoded-banner grep named since S69, formally classified
# hollow at S121: it runs the real binary, but what it asserts on is a usage string an 8th command
# could be added without touching. Kept, labelled, not relabelled — S123 adds two flags, no command.
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"; echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "no-eighth-command" behav help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

# --- summary + honest tally ----------------------------------------------------------------------
echo ""
echo "=== Session 123 Verify Summary ==="
printf '%-38s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-38s %-7s %s\n' "------------------------------------" "-------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" "${NESTED_NAMES[@]:-}"
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
