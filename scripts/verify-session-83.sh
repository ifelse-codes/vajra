#!/usr/bin/env bash
# Session 83 verify — warn before a headless `vajra claude -p` run with no permission-mode flag
# hits Claude Code's silent read-only wall (S76 dogfood run 1 finding, carried 5 sessions).
# Proves, against COMMITTED code (CI-safe — no real Claude API call, a stub `claude` binary
# stands in for the real one so the full `run()` path executes end-to-end for $0):
#   (1) headless + no permission flag -> stderr warning BEFORE claude is spawned (AC1)
#   (2) --dangerously-skip-permissions present -> no warning (AC2)
#   (3) --permission-mode <mode> present -> no warning, any mode (AC3)
#   (4) interactive (no -p/--print) -> no warning regardless of permission flags (AC4)
#   (5) advisory only: exit code / args untouched in every case (AC5)
#   (6) unit test matrix + full lib suite stay green (AC6)

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="83"
LAUNCH="src/cli/launch.rs"

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

# ── build a stub `claude` so the real launch path can run E2E for $0 ───────
STUB_DIR="$ARTIFACTS/stub-bin"
mkdir -p "$STUB_DIR"
cat > "$STUB_DIR/claude" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$STUB_DIR/claude"
export PATH="$STUB_DIR:$PATH"
export VAJRA_SKIP_AUTH_CHECK=1
export VAJRA_QUIET=1

BIN="$ROOT/target/debug/vajra"
cargo build --quiet --bin vajra

# ── (1) AC1 — headless, no permission flag -> warning fires ────────────────
headless_no_flag_warns() {
  "$BIN" claude -p "do a thing" 2>&1 1>/dev/null | grep -qi 'read-only\|no approval channel\|silently denied'
}
run_check "ac1-headless-no-flag-warns" headless_no_flag_warns

# ── (2) AC2 — --dangerously-skip-permissions present -> no warning ─────────
headless_skip_permissions_silent() {
  ! "$BIN" claude -p "do a thing" --dangerously-skip-permissions 2>&1 1>/dev/null | grep -qi 'read-only\|no approval channel\|silently denied'
}
run_check "ac2-skip-permissions-silent" headless_skip_permissions_silent

# ── (3) AC3 — --permission-mode <mode> present -> no warning, any mode ─────
headless_permission_mode_silent() {
  ! "$BIN" claude --print "x" --permission-mode plan 2>&1 1>/dev/null | grep -qi 'read-only\|no approval channel\|silently denied'
}
run_check "ac3-permission-mode-silent" headless_permission_mode_silent

# ── (4) AC4 — interactive (no -p/--print) -> no warning regardless ─────────
interactive_never_warns() {
  ! "$BIN" claude --model opus < /dev/null 2>&1 1>/dev/null | grep -qi 'read-only\|no approval channel\|silently denied'
}
run_check "ac4-interactive-never-warns" interactive_never_warns

# ── (5) AC5 — advisory only: exit code untouched (stub exits 0 either way) ─
advisory_exit_code_untouched() {
  "$BIN" claude -p "do a thing" >/dev/null 2>&1
  local a=$?
  "$BIN" claude -p "do a thing" --dangerously-skip-permissions >/dev/null 2>&1
  local b=$?
  [ "$a" -eq 0 ] && [ "$b" -eq 0 ]
}
run_check "ac5-advisory-exit-code-untouched" advisory_exit_code_untouched

# ── (6) AC6 — the new unit test matrix + full lib suite ────────────────────
run_check "unit-has-permission-flag" \
  cargo test --quiet --lib cli::launch::tests::has_permission_flag_detects_either_flag_exact_token
run_check "unit-should-warn-matrix" \
  cargo test --quiet --lib cli::launch::tests::should_warn_readonly_headless_matrix
run_check "lib-suite-green" cargo test --quiet --lib
run_check "clippy-clean" cargo clippy --all-targets -- -D warnings
run_check "fmt-clean" cargo fmt --check

# ── scope check: only src/cli/launch.rs changed under src/ ─────────────────
scope_is_launch_module_only() {
  local changed
  changed=$(git diff --name-only main -- src/ | sort)
  [ "$changed" = "$LAUNCH" ]
}
run_check "scope-launch-module-only" scope_is_launch_module_only

# ── report ───────────────────────────────────────────────────────────────
{
  echo "Session ${SESSION} verify — warn before the headless read-only wall"
  echo "artifacts: $ARTIFACTS"
  echo
  for r in "${RESULTS[@]}"; do echo "  $r"; done
  echo
  echo "PASS=$PASS FAIL=$FAIL"
} | tee "$ARTIFACTS/summary.txt"

ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"
[ "$FAIL" -eq 0 ] || { echo "VERIFY FAILED ($FAIL red)"; exit 1; }
echo "VERIFY GREEN ($PASS/$PASS)"
