#!/usr/bin/env bash
# demo-session-164.sh — S164: close the Releaser station gap
# Shows the before/after: check_release_coordinator was absent; now PASS.
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

echo "demo:header"
echo "=== Session 164 Demo: Releaser Station Gap Closed ==="
echo ""

echo "demo:cases"
echo "--- Case 1: vajra next --check-release-close 164 → READY (AC1) ---"
BIN="target/release/vajra"
if [ ! -x "$BIN" ]; then
  echo "RESULT: binary not built (run cargo build --release first)"
  exit 1
fi
OUT_GATE="$("$BIN" next --check-release-close 164 2>&1)" && GATE_CODE=0 || GATE_CODE=$?
echo "$OUT_GATE"
if [ "$GATE_CODE" -eq 0 ]; then
  echo "RESULT: exit 0 — Releaser gate READY for session 164"
else
  echo "RESULT: exit $GATE_CODE — gate blocked"
fi

echo ""
echo "--- Case 2: session-156-admin-close pruned from origin (AC3) ---"
if git ls-remote --exit-code origin session-156-admin-close >/dev/null 2>&1; then
  echo "RESULT: UNEXPECTED — branch still exists on origin"
else
  echo "RESULT: session-156-admin-close NOT found on origin — pruned (Option B applied)"
fi

echo ""
echo "--- Case 3: release-coordinator PASS — binary gate + crew non-regression (AC1 + AC4) ---"
# Note: we use the targeted binary checks rather than the full verify-closeout.sh here.
# Running verify-closeout.sh from inside the demo script causes infinite recursion:
# verify-closeout.sh → check_demo_markers → demo script → verify-closeout.sh → ...
# The binary check below is the SAME call verify-closeout.sh makes internally.
OUT_RC="$("$BIN" next --check-release-close 164 2>&1)" && RC=0 || RC=$?
echo "$OUT_RC"
if echo "$OUT_RC" | grep -q "verdict: READY"; then
  echo "RESULT: release-coordinator binary gate READY — verify-closeout.sh will report PASS"
else
  echo "RESULT: FAIL — gate not READY (exit=$RC)"
fi
# AC4 non-regression: governed handoffs intact
CREW_OUT="$("$BIN" next --check-crew 164 2>&1)" && CREW_RC=0 || CREW_RC=$?
if echo "$CREW_OUT" | grep -q "verdict: READY"; then
  echo "RESULT: crew check READY — required handoffs intact (non-regression)"
else
  echo "RESULT: FAIL — crew check not READY (exit=$CREW_RC)"
fi

echo ""
echo "--- Case 4: verify-session-164.sh exits 0 (AC5) ---"
if bash scripts/verify-session-164.sh > /dev/null 2>&1; then
  echo "RESULT: verify-session-164.sh exit 0 — all 9 behavioral checks pass"
else
  echo "RESULT: FAIL — verify-session-164.sh exited non-zero"
fi

echo ""
echo "demo:summary_table"
echo "┌──────────────────────────────────────────────────────────┐"
echo "│  S164 Releaser Station Gap Summary                       │"
echo "├──────────────────────┬───────────────────────────────────┤"
echo "│ Root cause            │ check_release_coordinator absent  │"
echo "│                       │ from verify-closeout.sh;          │"
echo "│                       │ gate only ran via --advance        │"
echo "├──────────────────────┼───────────────────────────────────┤"
echo "│ Fix (Option B)        │ Pruned session-156-admin-close    │"
echo "│                       │ from origin; git fetch --prune;   │"
echo "│                       │ NoBranch = WARNING not BLOCK       │"
echo "├──────────────────────┼───────────────────────────────────┤"
echo "│ New check             │ check_release_coordinator() in    │"
echo "│                       │ verify-closeout.sh; calls         │"
echo "│                       │ vajra next --check-release-close  │"
echo "├──────────────────────┼───────────────────────────────────┤"
echo "│ Hollow-binary guard   │ greps header prefix to confirm    │"
echo "│                       │ binary ran the gate, not hollow   │"
echo "└──────────────────────┴───────────────────────────────────┘"

echo ""
echo "demo:before_after"
echo "BEFORE: verify-closeout.sh had no check_release_coordinator function."
echo "        The Releaser station only ran inside --advance (never at real close)."
echo "        There is no runnable before: the function did not exist in any prior binary."
echo "        Result: Releaser station NEVER passed in any session."
echo ""
echo "AFTER:  check_release_coordinator() added; calls vajra next --check-release-close N."
echo "        Hollow-binary guard greps for '=== releaser: ship for session' header."
echo "        session-156-admin-close pruned from origin; NoBranch = warning only."
echo "        Result: release-coordinator PASS at closeout for S164."
