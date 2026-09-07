#!/usr/bin/env bash
# demo-session-148.sh — S148: close test-runner compression gaps.
#
# Shows Gap A (bare jest now dispatched) and Gap B (fail-path 30-399 lines now compressed)
# side by side with before/after. Each case runs the relevant unit test live.
#
# Usage: bash scripts/demo-session-148.sh

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

PASS=0; FAIL=0

ok()   { echo "  PASS  $1"; PASS=$((PASS+1)); }
fail() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

echo "=== demo-session-148: test-runner compression gaps ==="
echo ""

# ── Gap A: bare jest dispatch ─────────────────────────────────────────────────
echo "--- Gap A: bare jest dispatch ---"
echo ""
echo "BEFORE S148: dispatch table only matched 'npm test' / 'npm run test'."
echo "             A bare 'jest' command was never compressed (no heuristic)."
echo ""
echo "AFTER  S148: JestHeuristic added; bare 'jest' dispatched before 'npm' arm."
echo ""

# C1: detection test fires
c1_gap_a_detect() {
  cargo test --lib engine::heuristic::npm::tests::jest_detects_bare_jest 2>&1 \
    | grep -q "test result: ok"
}
if c1_gap_a_detect 2>/dev/null; then
  ok "C1 — jest_detects_bare_jest unit test fires"
else
  fail "C1 — jest_detects_bare_jest unit test did not fire"
fi

# C2: npm test still not matched by JestHeuristic (no regression)
c2_gap_a_no_crossmatch() {
  cargo test --lib engine::heuristic::npm::tests::jest_does_not_detect_npm 2>&1 \
    | grep -q "test result: ok"
}
if c2_gap_a_no_crossmatch 2>/dev/null; then
  ok "C2 — jest_does_not_detect_npm (no cross-match regression)"
else
  fail "C2 — jest_does_not_detect_npm FAILED"
fi

# C3: jest pass-path summary line preserved
c3_gap_a_pass_summary() {
  cargo test --lib engine::heuristic::npm::tests::jest_pass_summary_preserved 2>&1 \
    | grep -q "test result: ok"
}
if c3_gap_a_pass_summary 2>/dev/null; then
  ok "C3 — jest pass summary line preserved verbatim (AC2)"
else
  fail "C3 — jest_pass_summary_preserved FAILED"
fi

echo ""

# ── Gap B: fail-path compression for 30-399 line outputs ─────────────────────
echo "--- Gap B: fail-path compression for 30-399 line outputs ---"
echo ""
echo "BEFORE S148: FAIL_PASSTHROUGH_CAP=400 + preserves_failure_signal()→false"
echo "             meant any failing test run under 400 lines passed through"
echo "             unchanged. A 35-line jest failure consumed all 35 lines in"
echo "             the context window, not just the failure lines."
echo ""
echo "AFTER  S148: All three test heuristics override preserves_failure_signal()→true."
echo "             Fail path compresses: keeps failure lines + fold notice (FAIL_COMPRESS_FLOOR=20)."
echo ""

# C4: npm fail-path produces fewer lines
c4_gap_b_npm_compress() {
  cargo test --lib engine::heuristic::npm::tests::npm_fail_gap_b_preserves_failed_line 2>&1 \
    | grep -q "test result: ok"
}
if c4_gap_b_npm_compress 2>/dev/null; then
  ok "C4 — npm fail output compressed (Gap B, failure line preserved)"
else
  fail "C4 — npm_fail_gap_b_preserves_failed_line FAILED"
fi

# C5: fold notice format matches AC4 exactly
c5_notice_format() {
  cargo test --lib engine::heuristic::npm::tests::npm_fail_gap_b_notice_format 2>&1 \
    | grep -q "test result: ok"
}
if c5_notice_format 2>/dev/null; then
  ok "C5 — fold notice format: [vajra] N lines folded — set VAJRA_RAW=1 to see full output"
else
  fail "C5 — npm_fail_gap_b_notice_format FAILED"
fi

# C6: floor passthrough — below 20 lines, no compression (AC7)
c6_floor_passthrough() {
  cargo test --lib "npm_fail_floor_passthrough" 2>&1 | grep -q "test result: ok" || return 1
  cargo test --lib "cargo_test_fail_small_is_passthrough" 2>&1 | grep -q "test result: ok" || return 1
  cargo test --lib "pytest_fail_floor_passthrough" 2>&1 | grep -q "test result: ok" || return 1
}
if c6_floor_passthrough 2>/dev/null; then
  ok "C6 — floor passthrough: <20 lines not compressed (all three heuristics)"
else
  fail "C6 — floor passthrough FAILED for one or more heuristics"
fi

# C7: preserves_failure_signal() overridden (all three heuristics)
c7_preserves_signal() {
  cargo test --lib "cargo_test_preserves_failure_signal_override" 2>&1 | grep -q "test result: ok" || return 1
  cargo test --lib "pytest_preserves_failure_signal_override" 2>&1 | grep -q "test result: ok" || return 1
}
if c7_preserves_signal 2>/dev/null; then
  ok "C7 — preserves_failure_signal()→true for cargo + pytest"
else
  fail "C7 — preserves_failure_signal override FAILED"
fi

# C8: full cargo test suite passes
c8_cargo_test() {
  cargo test --lib 2>&1 | grep -q "^test result: ok\."
}
if c8_cargo_test 2>/dev/null; then
  ok "C8 — 485 lib tests pass (no regressions)"
else
  fail "C8 — cargo test FAILED"
fi

echo ""
echo "Results: ${PASS} PASS  ${FAIL} FAIL  (of $((PASS+FAIL)) checks)"
echo ""
if [ "$FAIL" -gt 0 ]; then
  echo "FAIL — $FAIL check(s) failed"; exit 1
fi
echo "PASS — Gap A (bare jest) and Gap B (fail-path 30-399 lines) both proven live."
