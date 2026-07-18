#!/usr/bin/env bash
# Session 73 — Close-path RELIABILITY: fix the brakes.
# Since S69 every close RE-RUNS the full suite + the demo LIVE — the close path IS the brakes.
# Two real defects, both seen at S72's own close:
#   (a) FLAKE — two hook_adapter compression tests failed intermittently under repeated full-suite
#       runs. Root cause: std::env is process-WIDE and Rust runs #[test]s on parallel threads;
#       passthrough_vajra_raw_env's set_var("VAJRA_RAW") leaked into a concurrent fold test,
#       flipping fold→passthrough. FIX: an ENV_LOCK the mutating test + every fold reader take —
#       isolation at the ROOT, no assertion weakened, no #[ignore], no retry, no test deleted.
#   (b) UNBOUNDED — the QA (S69) + Demo-er (S71) live runners had NO time limit → a hung script
#       hung the close forever. FIX: src/gate_run.rs bounds both by a recorded wall-clock timeout;
#       a run past the bound is KILLED (whole process group) and returns None = cannot-evaluate,
#       which the gates already treat as a BLOCK — naming the timeout + script, never a silent pass.
# The bound is a recorded key on the CONSTRAINTS spine (verify/demo.timeout_secs, default 600s),
# vajra init propagated. No CLI change, no 8th command, no new dependency, no second store.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="73"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

BIN="$ROOT/target/debug/vajra"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-54s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-54s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "cargo-build"   cargo build

# ============================================================================
# (a) THE DEFLAKE (Acceptance #1)
# ============================================================================
# The isolation exists and the assertions are intact — isolate, never weaken.
run_check "deflake-env-lock-present" bash -c "grep -q 'static ENV_LOCK' tests/hook_adapter.rs && grep -q 'fn env_guard' tests/hook_adapter.rs"
# An actual `#[ignore]` attribute is a line that begins (after indent) with it — a doc comment
# that merely says "no #[ignore]" starts with `///` and must not trip this check.
run_check "deflake-no-ignore"        bash -c "! grep -qE '^[[:space:]]*#\\[ignore\\]' tests/hook_adapter.rs"
# The three fold assertions + the regression-loop assertion are all still present (nothing deleted).
run_check "deflake-assertions-intact" bash -c "[ \"\$(grep -c 'assert_ne!' tests/hook_adapter.rs)\" -ge 4 ]"
run_check "deflake-root-cause-named" bash -c "grep -qi 'process-WIDE\\|process-global' tests/hook_adapter.rs"

# The >=10-consecutive-run loop of the previously flaky tests — every run green (the core proof).
deflake_loop_10x() {
  local i
  for i in $(seq 1 10); do
    cargo test --test hook_adapter -- compression passthrough_vajra_raw_env real_cc_payload_folds git_log >/dev/null 2>&1 || return 1
  done
  return 0
}
run_check "deflake-10x-consecutive-green" deflake_loop_10x

# Plus the full `cargo test` at least twice — deterministic across whole-suite runs.
run_check "deflake-full-suite-run-2" cargo test
run_check "deflake-full-suite-run-3" cargo test

# ============================================================================
# (b) THE BOUNDED RUNNER (Acceptance #2, #3, #5)
# ============================================================================
# The shared runner's own unit tests (green passes · hang killed+named · recorded/default/scoped).
run_check "test-gate-timeout-default"   cargo test --lib gate_run::tests::gate_timeout_defaults_when_unrecorded
run_check "test-gate-timeout-recorded"  cargo test --lib gate_run::tests::gate_timeout_recorded_value_wins_and_is_section_scoped
run_check "test-gate-timeout-malformed" cargo test --lib gate_run::tests::gate_timeout_malformed_or_zero_falls_back_to_default
run_check "test-run-streamed-green"     cargo test --lib gate_run::tests::run_streamed_green_returns_zero
run_check "test-run-streamed-hang"      cargo test --lib gate_run::tests::run_streamed_hang_is_killed_and_blocks
run_check "test-run-captured-green"     cargo test --lib gate_run::tests::run_captured_green_captures_output
run_check "test-run-captured-hang-name" cargo test --lib gate_run::tests::run_captured_hang_is_killed_and_names_the_timeout

# --- E2E: a minimal governed repo (just .ai/ + scripts/) exercised through the real gates. ---
E2E="$ROOT/$ARTIFACTS/e2e"; rm -rf "$E2E"; mkdir -p "$E2E/.ai" "$E2E/scripts"
write_constraints() { # $1 = the recorded verify/demo timeout_secs value (blank ⇒ omit the key = default)
  { printf 'version: 3\nmaturity: L3\n\nverify:\n'
    printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n"
    if [ -n "${1:-}" ]; then printf '  timeout_secs: %s\n' "$1"; fi
    printf '\ndemo:\n'
    printf "  script_pattern: 'scripts/demo-session-{NN}.sh'\n"
    printf '  required_elements: [header, cases, summary_table, before_after]\n'
    if [ -n "${1:-}" ]; then printf '  timeout_secs: %s\n' "$1"; fi
  } > "$E2E/.ai/CONSTRAINTS.yaml"
}

# Case A — a HANGING verify script BLOCKS within the recorded bound, naming the timeout + script.
#   recorded timeout_secs: 1 vs a sleep-30 script: the 1 must WIN (else the default 600 would hang
#   this check). We assert it both blocks AND returns fast (well under the 30s the script sleeps).
printf '#!/usr/bin/env bash\nsleep 30\n' > "$E2E/scripts/verify-session-50.sh"
write_constraints 1
hanging_verify_blocks_within_bound() {
  local start end elapsed out
  start=$(date +%s)
  out="$(cd "$E2E" && "$BIN" next --check-qa 50 2>&1 || true)"
  ( cd "$E2E" && ! "$BIN" next --check-qa 50 >/dev/null 2>&1 ) || return 1   # must BLOCK (exit 1)
  end=$(date +%s); elapsed=$((end - start))
  [ "$elapsed" -lt 20 ] || return 1                                          # killed at the bound, not after 30s
  echo "$out" | grep -q 'TIMEOUT' && echo "$out" | grep -q 'verify-session-50.sh'
}
run_check "e2e-hanging-verify-blocks-within-bound" hanging_verify_blocks_within_bound

# Case B — a GREEN verify script still PASSES (normal behavior unchanged), recorded bound generous.
printf '#!/usr/bin/env bash\nexit 0\n' > "$E2E/scripts/verify-session-51.sh"
write_constraints 600
run_check "e2e-green-verify-passes" bash -c "cd '$E2E' && '$BIN' next --check-qa 51"

# Case C — DEFAULT path: no timeout_secs key recorded, green fast script → still passes (default 600).
write_constraints ""   # omit the key
run_check "e2e-default-timeout-green-passes" bash -c "cd '$E2E' && '$BIN' next --check-qa 51"

# Case D — the Demo-er runner is bounded too: a hanging demo script BLOCKS fast, naming the timeout.
printf '#!/usr/bin/env bash\necho demo:header\nsleep 30\n' > "$E2E/scripts/demo-session-52.sh"
write_constraints 1
hanging_demo_blocks_within_bound() {
  local start end elapsed out
  start=$(date +%s)
  out="$(cd "$E2E" && "$BIN" next --check-demo 52 2>&1 || true)"
  ( cd "$E2E" && ! "$BIN" next --check-demo 52 >/dev/null 2>&1 ) || return 1
  end=$(date +%s); elapsed=$((end - start))
  [ "$elapsed" -lt 20 ] || return 1
  echo "$out" | grep -q 'TIMEOUT' && echo "$out" | grep -q 'demo-session-52.sh'
}
run_check "e2e-hanging-demo-blocks-within-bound" hanging_demo_blocks_within_bound

# --- Scaffold propagation (Acceptance #3, the S22/S57 pattern): a real `vajra init` records it. ---
scaffold_records_timeout() {
  local T; T="$(mktemp -d)"
  ( cd "$T" && git init -q . && "$BIN" init >/dev/null 2>&1 ) || { rm -rf "$T"; return 1; }
  grep -q 'timeout_secs: 600' "$T/.ai/CONSTRAINTS.yaml"
  local rc=$?
  rm -rf "$T"
  return $rc
}
run_check "e2e-scaffold-records-timeout" scaffold_records_timeout

# ============================================================================
# Own the spine (Acceptance #4): no CLI surface change, no 8th command, no new dep, no store.
# ============================================================================
run_check "no-cli-surface-change" git diff --quiet main -- src/main.rs
run_check "no-8th-command"        bash -c "! grep -q 'gate_run' src/main.rs"
run_check "no-new-dependency"     git diff --quiet main -- Cargo.toml
run_check "no-second-store"       bash -c "! test -e '$ROOT/qa.md' && ! test -e '$ROOT/demo.md' && ! test -e '$ROOT/timeout.md'"
# The bound is recorded on the existing spine, both sections.
run_check "constraints-record-timeout" bash -c "grep -q 'timeout_secs:' '$ROOT/.ai/CONSTRAINTS.yaml'"

# ============================================================================
# Prior harnesses stay green (Acceptance #4): verify-71 + verify-72 re-run unchanged.
# ============================================================================
run_check "verify-71-still-green" bash "$ROOT/scripts/verify-session-71.sh"
run_check "verify-72-still-green" bash "$ROOT/scripts/verify-session-72.sh"

# --- Session artifacts + hard rules ---
summary_present() {
  local S="$ROOT/sessions/session-73-summary.md"
  [ -f "$S" ] && grep -qi 'deflake\|flake\|timeout' "$S"
}
run_check "summary-artifact-present" summary_present
run_check "cold-review-present" test -f "$ROOT/sessions/session-73-review.md"

per_commit_file_cap() {
  local sha n
  for sha in $(git rev-list main..HEAD 2>/dev/null || true); do
    n=$(git show --name-only --format= "$sha" | grep -c . || true)
    [ "$n" -le 3 ] || return 1
  done
  return 0
}
run_check "per-commit-file-cap" per_commit_file_cap

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-54s %s\n' "STEP" "RESULT"
printf '%-54s %s\n' "------------------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1
fi
