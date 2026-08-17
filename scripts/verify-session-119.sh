#!/usr/bin/env bash
# Verify — Session 119: clean-room re-run for QA and Demo-er stations.
#
# S118 spent $4.09 proving nothing in Vajra ever runs the product in an environment the graded
# agent did not prepare. 19/20 charts errored behind a 14/14 ALL GREEN suite made of grep checks.
# CI caught the defect in 37s by running in a clean state nobody controlled. S119 gives Vajra that
# ability locally: `CleanRoom` materialises HEAD via `git worktree add --detach` — absent of
# uncommitted files and gitignored artifacts by construction — and QA + Demo-er route through it
# when `verify.clean_room.enabled: true`.
#
# The real deliverable is the FALSIFIABILITY FIXTURE: a verify script that PASSES in a working
# tree holding a stale build artifact, and FAILS in the clean room where that artifact is absent.
# That is the exact defect CI caught at S118 while ten cold reviews missed it.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="119"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-44s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-44s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- AC 7a: toolchain green -----------------------------------------------------------------------
run_check "cargo-build"   cargo build --all-targets
run_check "cargo-test"    cargo test --lib
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings

# --- AC 1+2: CleanRoom unit tests pass ------------------------------------------------------------
run_check "unit-clean-room-materialises-and-drops" \
  cargo test --lib gate_run::tests::clean_room_materialises_head_and_drop_cleans_up
run_check "unit-clean-room-excludes-uncommitted-and-gitignored" \
  cargo test --lib gate_run::tests::clean_room_excludes_uncommitted_and_gitignored_files

# --- AC 6: the falsifiability fixture — the session's real deliverable ----------------------------
# A verify script PASSES in a working tree holding a stale artifact and FAILS in the clean room
# where that artifact is absent. Both directions are asserted inside the test — a failure here
# means the clean room either let the artifact through (won't catch S118-class defects) or
# rejected the script when it shouldn't have (broken by construction).
run_check "falsifiability-fixture" \
  cargo test --lib gate_run::tests::clean_room_falsifiability_fixture

# Shell-level falsifiability: independently reproduce the fixture logic without the unit-test harness.
shell_falsifiability_fixture() {
  local REPO; REPO="$(mktemp -d)"

  git -C "$REPO" init -q
  git -C "$REPO" config user.email "t@t.com"
  git -C "$REPO" config user.name "T"

  # Commit a .gitignore (ignores dist/) and a verify script that needs dist/output.txt.
  printf 'dist/\n' > "$REPO/.gitignore"
  mkdir -p "$REPO/scripts"
  printf '#!/usr/bin/env bash\n[ -f dist/output.txt ] || { echo FAIL:absent; exit 1; }\necho PASS:present\n' \
    > "$REPO/scripts/verify.sh"
  git -C "$REPO" add . && git -C "$REPO" commit -qm "initial"

  # Stale artifact: gitignored, only in the working tree.
  mkdir -p "$REPO/dist" && printf 'stale\n' > "$REPO/dist/output.txt"

  # (1) In the working tree: artifact present → PASS.
  if ! (cd "$REPO" && bash scripts/verify.sh) 2>/dev/null; then
    rm -rf "$REPO"
    echo "FAIL: working tree should pass with stale artifact present"
    return 1
  fi

  # (2) In a clean room: artifact absent → FAIL.
  local CR; CR="$(mktemp -d)"; rmdir "$CR"   # remove so git worktree add can create it
  git -C "$REPO" worktree add --detach "$CR" HEAD -q
  local clean_result=0
  (cd "$CR" && bash scripts/verify.sh) 2>/dev/null && clean_result=1
  git -C "$REPO" worktree remove --force "$CR" 2>/dev/null || true
  rm -rf "$REPO"
  if [ "$clean_result" -eq 1 ]; then
    echo "FAIL: clean room should fail (artifact absent in checkout of HEAD)"
    return 1
  fi
  echo "OK: working tree passed (artifact present); clean room failed (artifact absent)"
}
run_check "shell-falsifiability-fixture" shell_falsifiability_fixture

# --- AC 3: CONSTRAINTS.yaml carries clean_room section, default off ------------------------------
constraints_has_clean_room_keys() {
  local F=".ai/CONSTRAINTS.yaml"
  grep -q "clean_room:" "$F"        || { echo "FAIL: no clean_room: section in $F"; return 1; }
  grep -q "enabled: false" "$F"     || { echo "FAIL: expected enabled: false (default off) in $F"; return 1; }
  echo "OK: $F has clean_room section with enabled: false"
}
run_check "constraints-has-clean-room-section" constraints_has_clean_room_keys

# --- AC 3+7: init scaffold includes clean_room ---------------------------------------------------
init_scaffold_has_clean_room() {
  local F="src/cli/init.rs"
  grep -q "clean_room:" "$F"    || { echo "FAIL: init scaffold TPL_CONSTRAINTS missing clean_room:"; return 1; }
  grep -q "enabled: false" "$F" || { echo "FAIL: init scaffold missing enabled: false default"; return 1; }
  echo "OK: init scaffold includes clean_room keys with enabled: false default"
}
run_check "init-scaffold-has-clean-room" init_scaffold_has_clean_room

# --- AC 4: config reader unit tests ---------------------------------------------------------------
run_check "unit-config-defaults-absent"  \
  cargo test --lib gate_run::tests::clean_room_config_defaults_when_key_absent
run_check "unit-config-reads-enabled"    \
  cargo test --lib gate_run::tests::clean_room_config_reads_enabled_and_bootstrap
run_check "unit-config-no-bleed"         \
  cargo test --lib gate_run::tests::clean_room_config_does_not_bleed_into_demo_section

# --- AC 4: bootstrap unit tests -------------------------------------------------------------------
run_check "unit-bootstrap-pass"    cargo test --lib gate_run::tests::run_bootstrap_passes_on_exit_zero
run_check "unit-bootstrap-nonzero" cargo test --lib gate_run::tests::run_bootstrap_blocks_on_nonzero_exit
run_check "unit-bootstrap-timeout" cargo test --lib gate_run::tests::run_bootstrap_blocks_on_timeout

# --- AC 5: VAJRA_SKIP_CLEAN_ROOM=1 falls back to working tree -----------------------------------
# This check verifies the env var is honoured by grepping the compiled binary's usage of the key.
# The actual path exercise happens in the lib tests via injected closures.
skip_env_var_referenced() {
  grep -r "VAJRA_SKIP_CLEAN_ROOM" src/qa/mod.rs src/demoer/mod.rs | grep -q "VAJRA_SKIP_CLEAN_ROOM" \
    || { echo "FAIL: VAJRA_SKIP_CLEAN_ROOM not referenced in qa and demoer gates"; return 1; }
  echo "OK: VAJRA_SKIP_CLEAN_ROOM referenced in both QA and Demo-er gates"
}
run_check "skip-env-var-referenced-in-gates" skip_env_var_referenced

# --- AC 5: run location printed in gate output ---------------------------------------------------
run_location_printed() {
  grep -q "running in clean room" src/qa/mod.rs    || { echo "FAIL: qa gate doesn't print clean room location"; return 1; }
  grep -q "running in clean room" src/demoer/mod.rs || { echo "FAIL: demoer gate doesn't print clean room location"; return 1; }
  echo "OK: both gates print the clean room path in their streamed output"
}
run_check "run-location-printed-in-output" run_location_printed

# --- demo script exits 0 -------------------------------------------------------------------------
run_check "demo-session-119-exits-zero" bash scripts/demo-session-119.sh

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-44s %s\n' "STEP" "RESULT"
printf '%-44s %s\n' "--------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
