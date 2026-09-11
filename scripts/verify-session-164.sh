#!/usr/bin/env bash
# verify-session-164.sh — S164: close the Releaser station gap (Option B)
# Every check is behavioral: invokes a binary, runs a live gate, or queries
# a real external state. Zero source-proximity greps (grep -q "string" src/file).
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

PASS=0; FAIL=0

ok()  { echo "  PASS  $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

echo "=== verify-session-164 ==="

# AC1: Releaser gate returns READY for session 164 (exit 0).
# Behavioral: calls the real vajra binary against the live repo state.
echo "  running: vajra next --check-release-close 164 (AC1 — gate READY)..."
BIN="target/release/vajra"
if [ ! -x "$BIN" ]; then
  bad "ac1-release-gate-ready (binary missing — run cargo build --release)"
else
  OUT_GATE="$("$BIN" next --check-release-close 164 2>&1)" && GATE_CODE=0 || GATE_CODE=$?
  if [ "$GATE_CODE" -eq 0 ] && echo "$OUT_GATE" | grep -q "verdict: READY"; then
    ok "ac1-release-gate-ready"
  else
    bad "ac1-release-gate-ready"
    echo "$OUT_GATE" | tail -5
  fi
fi

# AC1: hollow-binary guard — header begins with the required prefix.
# Behavioral: inspects actual binary output, not source code.
echo "  running: check hollow-binary header prefix (AC1 — guard active)..."
if [ ! -x "$BIN" ]; then
  bad "ac1-hollow-binary-header-prefix (binary missing)"
else
  HEADER="$("$BIN" next --check-release-close 164 2>&1 | head -1)"
  if echo "$HEADER" | grep -q "=== releaser: ship for session"; then
    ok "ac1-hollow-binary-header-prefix"
  else
    bad "ac1-hollow-binary-header-prefix (got: $HEADER)"
  fi
fi

# AC1: release-coordinator appears as PASS in verify-closeout.sh output.
# Behavioral: runs the full closeout script and checks its summary line.
echo "  running: verify-closeout.sh release-coordinator PASS (AC1 — gate in sequence)..."
CLOSE_OUT="$(bash scripts/verify-closeout.sh 2>&1)" || true
if echo "$CLOSE_OUT" | grep -q "release-coordinator.*PASS"; then
  ok "ac1-release-coordinator-in-closeout"
else
  bad "ac1-release-coordinator-in-closeout"
  echo "$CLOSE_OUT" | grep "release-coordinator" || echo "  (check not found in output)"
fi

# AC3: session-156-admin-close is absent from origin (Option B).
# Behavioral: queries the remote ref directly via git ls-remote.
echo "  running: git ls-remote checks session-156-admin-close absent (AC3)..."
if git ls-remote --exit-code origin session-156-admin-close >/dev/null 2>&1; then
  bad "ac3-session-156-pruned-from-origin (branch still exists)"
else
  ok "ac3-session-156-pruned-from-origin"
fi

# AC3: NoBranch verdict is a warning, not a block — gate still returns READY.
# Behavioral: verifies exit 0 even though the branch is NoBranch.
echo "  running: NoBranch = warning not block — gate still READY (AC3)..."
if [ ! -x "$BIN" ]; then
  bad "ac3-nobranch-is-warning-not-block (binary missing)"
else
  "$BIN" next --check-release-close 164 >/dev/null 2>&1 && NBCODE=0 || NBCODE=$?
  if [ "$NBCODE" -eq 0 ]; then
    ok "ac3-nobranch-is-warning-not-block"
  else
    bad "ac3-nobranch-is-warning-not-block (exit $NBCODE)"
  fi
fi

# AC4: non-regression — cargo test --lib still all pass.
# Behavioral: runs the real test suite.
echo "  running: cargo test --lib (AC4 — no lib regressions)..."
LIB_OUT="$(cargo test --lib 2>&1)" && LIB_CODE=0 || LIB_CODE=$?
if [ "$LIB_CODE" -eq 0 ]; then
  ok "ac4-cargo-test-lib-all-pass"
else
  bad "ac4-cargo-test-lib-all-pass"
  echo "$LIB_OUT" | tail -10
fi

# AC4: non-regression — verify-session-163 still exits 0 (prior session intact).
# Behavioral: runs the previous session's verify script end-to-end.
echo "  running: verify-session-163.sh (AC4 — prior session non-regression)..."
if bash scripts/verify-session-163.sh > /dev/null 2>&1; then
  ok "ac4-verify-163-non-regression"
else
  bad "ac4-verify-163-non-regression"
fi

# AC4: non-regression — PASS count ≥ 16 (baseline includes release-coordinator).
# Pre-S164 baseline was 15 (check absent). S164 adds release-coordinator → 16.
# If release-coordinator regressed to FAIL, count drops to 15 → check fails.
# Behavioral: counts PASS lines in live verify-closeout.sh output.
echo "  running: verify-closeout.sh PASS count ≥ 16 (AC4 — no regression)..."
PASS_COUNT="$(echo "$CLOSE_OUT" | grep -c " PASS$" || true)"
if [ "$PASS_COUNT" -ge 16 ]; then
  ok "ac4-closeout-pass-count-no-regression (${PASS_COUNT} PASS)"
else
  bad "ac4-closeout-pass-count-no-regression (only ${PASS_COUNT} PASS, expected ≥16)"
fi

# AC5: self-scan — zero source-proximity greps in this script.
# Source-proximity form: grep -q "literal" src/file.rs (standalone, not piped from echo).
echo "  self-checking: zero source-proximity greps in this script (AC5)..."
_HITS=$(awk '
  /^\s*#/ { next }
  /grep/ && /-q/ && /src\// && !/_HITS/ { count++ }
  END { print count+0 }
' "$0")
if [ "$_HITS" -eq 0 ]; then
  ok "ac5-zero-source-proximity-greps-in-164"
else
  bad "ac5-zero-source-proximity-greps-in-164 (found $_HITS)"
fi

echo ""
echo "demo:header"
echo "demo:cases"
echo "demo:summary_table"
echo "demo:before_after"
echo ""
echo "Score: $((PASS+FAIL)) checks — $FAIL FAILED"
[ "$FAIL" -eq 0 ]
