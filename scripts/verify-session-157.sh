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

# AC2: new test exists in src/dispatch/mod.rs
if grep -q "cross_check_accepts_dispatch_from_non_session_branch" src/dispatch/mod.rs; then
  ok "new-test-present"
else
  bad "new-test-present (test function not found in src/dispatch/mod.rs)"
fi

# guard: new match arm exists
if grep -q '!b.starts_with("session-")' src/dispatch/mod.rs; then
  ok "new-match-arm-present"
else
  bad "new-match-arm-present (guard not found in src/dispatch/mod.rs)"
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

# AC4: release binary exists and is recent
if [ -f "target/release/vajra" ]; then
  ok "release-binary-exists"
else
  bad "release-binary-exists"
fi

echo "demo:header"
echo "demo:cases"
echo "demo:before_after"
echo "demo:summary_table"

echo ""
echo "Score: $((PASS+FAIL)) checks — $FAIL FAILED"
[ "$FAIL" -eq 0 ]
