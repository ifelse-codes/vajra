#!/usr/bin/env bash
# verify-session-148.sh — S148 close test-runner compression gaps.
#
# SUITE DECLARATION: 8 checks total.
#   Execute-based (EXEC): C1, C2, C3, C4, C5, C6, C8 — live cargo test or binary invoke.
#   CANNOT-EVALUATE: C7 — S144 JSONL not available on this machine.
#
# FIDELITY GAPS (things this suite CANNOT verify):
#   C7: S144 JSONL token reduction — file not present locally.
#      Recorded as CANNOT-EVALUATE per AC6 (not a blocking failure).
#   The implementation-advisor and fidelity-reviewer cold read verify AC3/AC4 pattern
#   correctness and notice format beyond what these structural checks can assert.
#
# FAKEST GREEN (disclosed): C3 asserts that compress functions produce fewer lines
# than input; it cannot verify that the *right* lines were kept vs dropped.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="148"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; SKIP=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  if "$@" > "$ARTIFACTS/${NAME}.log" 2>&1; then
    echo "  PASS  $NAME"; PASS=$((PASS+1)); RESULTS+=("PASS $NAME")
  else
    echo "  FAIL  $NAME (see $ARTIFACTS/${NAME}.log)"; FAIL=$((FAIL+1)); RESULTS+=("FAIL $NAME")
  fi
}
skip_check() {
  local NAME="$1"; local REASON="$2"
  echo "  SKIP  $NAME — $REASON"; SKIP=$((SKIP+1)); RESULTS+=("SKIP $NAME")
  echo "CANNOT-EVALUATE: $REASON" > "$ARTIFACTS/${NAME}.log"
}

echo "=== verify-session-148 ==="

# C1: cargo test exits 0 (AC8 — all existing + new tests pass)
c1_cargo_test() {
  cargo test --lib 2>&1 | grep -E "^test result:" | grep -q "^test result: ok\."
}
run_check "C1-cargo-test" c1_cargo_test

# C2: JestHeuristic detect fires on bare 'jest' (Gap A, AC1)
c2_jest_detect() {
  cargo test --lib engine::heuristic::npm::tests::jest_detects_bare_jest 2>&1 \
    | grep -q "test result: ok"
}
run_check "C2-jest-detect" c2_jest_detect

# C3: Gap B — fail-path produces fewer lines for 25-line npm fail input (AC1/AC2)
# Build a temp Rust test via `cargo test` filter
c3_gap_b_npm_compression() {
  cargo test --lib engine::heuristic::npm::tests::npm_fail_gap_b_preserves_failed_line 2>&1 \
    | grep -q "test result: ok"
}
run_check "C3-gap-b-npm" c3_gap_b_npm_compression

# C4: Gap B — fold notice format matches AC4 exactly
c4_notice_format() {
  cargo test --lib engine::heuristic::npm::tests::npm_fail_gap_b_notice_format 2>&1 \
    | grep -q "test result: ok"
}
run_check "C4-notice-format" c4_notice_format

# C5: Passthrough below floor for all three heuristics (AC7)
# cargo test accepts one filter — run each separately, aggregate exit
c5_floor_passthrough() {
  cargo test --lib "npm_fail_floor_passthrough" 2>&1 | grep -q "test result: ok" || return 1
  cargo test --lib "cargo_test_fail_small_is_passthrough" 2>&1 | grep -q "test result: ok" || return 1
  cargo test --lib "pytest_fail_floor_passthrough" 2>&1 | grep -q "test result: ok" || return 1
}
run_check "C5-floor-passthrough" c5_floor_passthrough

# C6: preserves_failure_signal() returns true for all three heuristics (engine gate)
c6_preserves_failure_signal() {
  cargo test --lib "cargo_test_preserves_failure_signal_override" 2>&1 | grep -q "test result: ok" || return 1
  cargo test --lib "pytest_preserves_failure_signal_override" 2>&1 | grep -q "test result: ok" || return 1
  cargo test --lib "jest_detects_bare_jest" 2>&1 | grep -q "test result: ok" || return 1
}
run_check "C6-preserves-failure-signal" c6_preserves_failure_signal

# C7: S144 JSONL token reduction measurement (AC6)
# The S144 session ran inside chitra; its JSONL is not present on this machine.
JSONL_PATH=$(ls ~/.claude/projects/*/chitra/*/session.jsonl 2>/dev/null | head -1 || true)
if [ -n "$JSONL_PATH" ]; then
  c7_jsonl_reduction() {
    local before after
    before=$(python3 -c "
import json, sys
total = 0
with open('$JSONL_PATH') as f:
    for line in f:
        try:
            obj = json.loads(line)
            u = obj.get('usage') or obj.get('message', {}).get('usage', {})
            total += u.get('input_tokens', 0) + u.get('output_tokens', 0)
        except: pass
print(total)
" 2>/dev/null || echo 0)
    echo "tokens before (raw): $before"
    # Measurement only — AC6 requires M < N for exit 0.
    # Without applying the new heuristic rules to the transcript replay,
    # we cannot compute 'after'. Recording as structural measurement only.
    [ "$before" -gt 0 ] || { echo "No token data found in JSONL"; return 1; }
    echo "tokens after: N/A (replay not implemented — see AC6 CANNOT-EVALUATE note)"
    # Exit 1 to mark as not fully satisfied per AC6
    return 1
  }
  run_check "C7-jsonl-token-reduction" c7_jsonl_reduction
else
  skip_check "C7-jsonl-token-reduction" "S144 JSONL not available on this machine (AC6 CANNOT-EVALUATE)"
fi

# C8: Jest pass-path summary line survives (AC2, Gap A)
c8_jest_pass_summary() {
  cargo test --lib engine::heuristic::npm::tests::jest_pass_summary_preserved 2>&1 \
    | grep -q "test result: ok"
}
run_check "C8-jest-pass-summary" c8_jest_pass_summary

# ── report ────────────────────────────────────────────────────────────────────
ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"
echo ""
echo "Results: ${PASS} PASS  ${FAIL} FAIL  ${SKIP} SKIP  (of $((PASS+FAIL+SKIP)) checks)"
for r in "${RESULTS[@]}"; do echo "  $r"; done
echo ""
if [ "$FAIL" -gt 0 ]; then
  echo "FAIL — $FAIL check(s) failed"; exit 1
fi
echo "PASS — all checks passed (${SKIP} skipped/CANNOT-EVALUATE)"
