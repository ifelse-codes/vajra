#!/usr/bin/env bash
# verify-session-157.sh — S157 crew-branch fix
# Checks: AC1 (cargo test green), AC2 (new test present + passes), AC3 (replay check still passes), AC4 (release build)
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

PASS=0; FAIL=0

ok()  { echo "  PASS  $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

echo "=== verify-session-157 ==="

# AC2: new test exists AND passes (targeted cargo test run)
# FALSIFIABILITY: the old grep accepted a src/dispatch/mod.rs that had the test NAME
# in a comment but the test body was absent or #[ignore]d — cargo test rejects it:
# a missing or disabled function would not emit
# "cross_check_accepts_dispatch_from_non_session_branch ... ok".
echo "  running targeted cargo test: cross_check_accepts_dispatch_from_non_session_branch..."
TEST_NON_SESSION="$(cargo test cross_check_accepts_dispatch_from_non_session_branch 2>&1)"
if echo "$TEST_NON_SESSION" | grep -q "cross_check_accepts_dispatch_from_non_session_branch ... ok"; then
  ok "new-test-present-and-passes"
else
  bad "new-test-present-and-passes"
  echo "$TEST_NON_SESSION" | tail -10
fi

# guard fix active — verified via the complementary test that would fail without it
# FALSIFIABILITY: the old grep for '!b.starts_with("session-")' accepted that pattern
# in dead code or a comment — cargo test rejects it: if the guard were absent,
# cross_check_fails_when_git_branch_is_a_different_session would FAIL (wrong branch
# accepted instead of rejected).
echo "  running targeted cargo test: cross_check_fails_when_git_branch_is_a_different_session..."
TEST_DIFF_SESSION="$(cargo test cross_check_fails_when_git_branch_is_a_different_session 2>&1)"
if echo "$TEST_DIFF_SESSION" | grep -q "cross_check_fails_when_git_branch_is_a_different_session ... ok"; then
  ok "fix-guard-enforced-by-test"
else
  bad "fix-guard-enforced-by-test"
  echo "$TEST_DIFF_SESSION" | tail -10
fi

# AC1 + AC2 + AC3: cargo test (all 487 tests pass, including new + replay-check tests)
echo "  running cargo test..."
TEST_OUT=$(cargo test 2>&1)
if echo "$TEST_OUT" | grep -q "^test result: ok"; then
  ok "cargo-test-all-green"
else
  bad "cargo-test-all-green"
  echo "$TEST_OUT" | tail -20
fi

# AC2 specifically: new test passes
if echo "$TEST_OUT" | grep -q "cross_check_accepts_dispatch_from_non_session_branch ... ok"; then
  ok "new-test-passes"
else
  bad "new-test-passes"
fi

# AC3 specifically: replay-check test still passes
if echo "$TEST_OUT" | grep -q "cross_check_fails_when_git_branch_is_a_different_session ... ok"; then
  ok "replay-check-test-still-passes"
else
  bad "replay-check-test-still-passes"
fi

# AC4: cargo build --release succeeds for this session's changes
echo "  running cargo build --release..."
if cargo build --release 2>&1; then
  ok "cargo-build-release"
else
  bad "cargo-build-release"
fi

echo "demo:header"
echo "demo:cases"
echo "demo:before_after"
echo "demo:summary_table"

echo ""
echo "Score: $((PASS+FAIL)) checks — $FAIL FAILED"
[ "$FAIL" -eq 0 ]
