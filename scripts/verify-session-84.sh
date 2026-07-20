#!/usr/bin/env bash
# Session 84 verify — typed `CannotEvaluate::{Timeout, SpawnFailure}` for the QA/Demo-er gates'
# live re-run (closes the S73 fakest-green finding, carried 7 sessions: S76-S83). Proves, against
# COMMITTED-plus-working-tree code (CI-safe where noted — the spawn-failure/timeout paths are
# real E2E runs against a synthetic temp repo, no paid API call, $0):
#   (1) a genuine spawn failure yields SpawnFailure, distinct from Timeout — unit (both runners:
#       run_streamed + run_captured) AND live E2E (empty PATH so `bash` cannot be found)
#   (2) a live run past its recorded timeout bound BLOCKS and names TIMEOUT — E2E, both gates
#   (3) a real nonzero exit code is UNCHANGED: still blocks, still names the real code, and is
#       NOT classified as CannotEvaluate — E2E, both gates
#   (4) exit 0 is UNCHANGED (LiveGreen / no block) — E2E, both gates
#   (5) both call sites (qa/mod.rs, demoer/mod.rs) carry the typed distinction in their BLOCK
#       message wording — unit
#   (6) cargo test --lib stays green (267), clippy + fmt clean, and the diff touches exactly the
#       3 named files (no scope creep into launch.rs / the S76 sha debt / the attestation check)

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="84"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-42s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-42s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

BIN="$ROOT/target/debug/vajra"
cargo build --quiet --bin vajra

# ── (1a) unit — SpawnFailure is real and visibly distinct from Timeout, both runners ───────
run_check "unit-run-streamed-spawn-failure-distinct" \
  cargo test --quiet --lib gate_run::tests::run_streamed_spawn_failure_is_distinct_from_timeout
run_check "unit-run-captured-spawn-failure-distinct" \
  cargo test --quiet --lib gate_run::tests::run_captured_spawn_failure_is_distinct_from_timeout

# ── build an isolated temp repo the compiled binary can run --check-qa/--check-demo against ─
TMP_REPO=$(mktemp -d)
trap 'rm -rf "$TMP_REPO"' EXIT
mkdir -p "$TMP_REPO/.ai" "$TMP_REPO/scripts"
cat > "$TMP_REPO/.ai/CONSTRAINTS.yaml" <<'EOF'
verify:
  required_for_done: true
  script_pattern: 'scripts/verify-session-{NN}.sh'
  artifacts_dir: '.ai/verify/session-{NN}/'
  timeout_secs: 1
demo:
  script_pattern: 'scripts/demo-session-{NN}.sh'
  required_elements: [header, cases, summary_table, before_after]
  timeout_secs: 1
EOF

# ── (1b) E2E — a genuine spawn failure (bash unresolvable) BLOCKS and names SPAWN FAILURE ──
cat > "$TMP_REPO/scripts/verify-session-99.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cp "$TMP_REPO/scripts/verify-session-99.sh" "$TMP_REPO/scripts/demo-session-99.sh"
chmod +x "$TMP_REPO/scripts/verify-session-99.sh" "$TMP_REPO/scripts/demo-session-99.sh"

qa_spawn_failure_blocks_and_names_it() {
  local out rc
  out=$(cd "$TMP_REPO" && PATH="/nonexistent-dir-for-s84-verify" "$BIN" next --check-qa 99 2>&1)
  rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -q "SPAWN FAILURE"
}
run_check "e2e-qa-spawn-failure-blocks-and-names-it" qa_spawn_failure_blocks_and_names_it

demo_spawn_failure_blocks_and_names_it() {
  local out rc
  out=$(cd "$TMP_REPO" && PATH="/nonexistent-dir-for-s84-verify" "$BIN" next --check-demo 99 2>&1)
  rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -q "SPAWN FAILURE"
}
run_check "e2e-demo-spawn-failure-blocks-and-names-it" demo_spawn_failure_blocks_and_names_it

# ── (2) E2E — a live run past its timeout bound BLOCKS and names TIMEOUT ───────────────────
cat > "$TMP_REPO/scripts/verify-session-99.sh" <<'EOF'
#!/usr/bin/env bash
sleep 5
EOF
cp "$TMP_REPO/scripts/verify-session-99.sh" "$TMP_REPO/scripts/demo-session-99.sh"
chmod +x "$TMP_REPO/scripts/verify-session-99.sh" "$TMP_REPO/scripts/demo-session-99.sh"

qa_timeout_blocks_and_names_it() {
  local out rc
  out=$(cd "$TMP_REPO" && "$BIN" next --check-qa 99 2>&1)
  rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -q "TIMEOUT"
}
run_check "e2e-qa-timeout-blocks-and-names-it" qa_timeout_blocks_and_names_it

demo_timeout_blocks_and_names_it() {
  local out rc
  out=$(cd "$TMP_REPO" && "$BIN" next --check-demo 99 2>&1)
  rc=$?
  [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -q "TIMEOUT"
}
run_check "e2e-demo-timeout-blocks-and-names-it" demo_timeout_blocks_and_names_it

# ── (3) E2E — a real nonzero exit code is UNCHANGED: blocks, names the real code, and is ───
#            NOT classified as CannotEvaluate (neither TIMEOUT nor SPAWN FAILURE mentioned)
cat > "$TMP_REPO/scripts/verify-session-99.sh" <<'EOF'
#!/usr/bin/env bash
exit 7
EOF
cp "$TMP_REPO/scripts/verify-session-99.sh" "$TMP_REPO/scripts/demo-session-99.sh"
chmod +x "$TMP_REPO/scripts/verify-session-99.sh" "$TMP_REPO/scripts/demo-session-99.sh"

qa_real_red_unchanged() {
  local out rc
  out=$(cd "$TMP_REPO" && "$BIN" next --check-qa 99 2>&1)
  rc=$?
  [ "$rc" -eq 1 ] \
    && printf '%s' "$out" | grep -q "exited 7" \
    && ! printf '%s' "$out" | grep -qE "TIMEOUT|SPAWN FAILURE"
}
run_check "e2e-qa-real-nonzero-code-unchanged" qa_real_red_unchanged

demo_real_red_unchanged() {
  local out rc
  out=$(cd "$TMP_REPO" && "$BIN" next --check-demo 99 2>&1)
  rc=$?
  [ "$rc" -eq 1 ] \
    && printf '%s' "$out" | grep -q "exited 7" \
    && ! printf '%s' "$out" | grep -qE "TIMEOUT|SPAWN FAILURE"
}
run_check "e2e-demo-real-nonzero-code-unchanged" demo_real_red_unchanged

# ── (4) E2E — exit 0 is UNCHANGED (LiveGreen / no block) ───────────────────────────────────
cat > "$TMP_REPO/scripts/verify-session-99.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$TMP_REPO/scripts/demo-session-99.sh" <<'EOF'
#!/usr/bin/env bash
printf 'demo:header\ndemo:cases\ndemo:summary_table\ndemo:before_after\n'
EOF
chmod +x "$TMP_REPO/scripts/verify-session-99.sh" "$TMP_REPO/scripts/demo-session-99.sh"

qa_green_unchanged() {
  (cd "$TMP_REPO" && "$BIN" next --check-qa 99) >/dev/null 2>&1
}
run_check "e2e-qa-exit-zero-unchanged" qa_green_unchanged

demo_green_unchanged() {
  (cd "$TMP_REPO" && "$BIN" next --check-demo 99) >/dev/null 2>&1
}
run_check "e2e-demo-exit-zero-unchanged" demo_green_unchanged

# ── (5) unit — both call sites' BLOCK message names Timeout vs SpawnFailure distinctly ─────
run_check "unit-qa-message-distinguishes-reasons" \
  cargo test --quiet --lib qa::tests::gate_block_message_names_timeout_distinctly_from_spawn_failure
run_check "unit-demo-message-distinguishes-reasons" \
  cargo test --quiet --lib demoer::tests::gate_block_message_names_timeout_distinctly_from_spawn_failure

# ── (6) full lib suite + clippy + fmt + scope ───────────────────────────────────────────────
run_check "lib-suite-green" cargo test --quiet --lib
run_check "clippy-clean" cargo clippy --all-targets -- -D warnings
run_check "fmt-clean" cargo fmt --check

scope_is_gate_run_qa_demoer_only() {
  local changed expect
  changed=$(git diff --name-only main -- src/ | sort)
  expect=$(printf '%s\n' "src/demoer/mod.rs" "src/gate_run.rs" "src/qa/mod.rs" | sort)
  [ "$changed" = "$expect" ]
}
run_check "scope-3-files-only" scope_is_gate_run_qa_demoer_only

# ── report ───────────────────────────────────────────────────────────────
{
  echo "Session ${SESSION} verify — typed CannotEvaluate::{Timeout, SpawnFailure}"
  echo "artifacts: $ARTIFACTS"
  echo
  for r in "${RESULTS[@]}"; do echo "  $r"; done
  echo
  echo "PASS=$PASS FAIL=$FAIL"
} | tee "$ARTIFACTS/summary.txt"

ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"
[ "$FAIL" -eq 0 ] || { echo "VERIFY FAILED ($FAIL red)"; exit 1; }
echo "VERIFY GREEN ($PASS/$PASS)"
