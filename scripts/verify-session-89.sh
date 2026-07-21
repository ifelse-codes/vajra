#!/usr/bin/env bash
# verify-session-89.sh — Session 89: ROADMAP.md consolidation + stale table fix
set -euo pipefail

ROADMAP=".ai/ROADMAP.md"
PASS=0
FAIL=0

check() {
  local desc="$1" result="$2"
  if [ "$result" = "ok" ]; then
    echo "  PASS  $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== verify-session-89: ROADMAP consolidation + stale table fix ==="
echo

# --- AC1: stale strings are ABSENT ---
echo "[AC1] Stale strings absent from ROADMAP"
check "stale date 2026-07-14 absent" \
  "$(grep -q '2026-07-14' "$ROADMAP" && echo fail || echo ok)"
check "stale phase 'S59 done' absent" \
  "$(grep -q 'S59 done' "$ROADMAP" && echo fail || echo ok)"
check "stale 'Session 60' in table absent" \
  "$(grep -q 'Session 60 —' "$ROADMAP" && echo fail || echo ok)"
check "stale 'S60 closed' active-session line absent" \
  "$(grep -q 'S60 closed' "$ROADMAP" && echo fail || echo ok)"
echo

# --- AC1: correct current values are PRESENT ---
echo "[AC1] Correct current values present"
check "today's date 2026-07-21 present" \
  "$(grep -q '2026-07-21' "$ROADMAP" && echo ok || echo fail)"
check "current phase mentions '8-station'" \
  "$(grep -q '8-station' "$ROADMAP" && echo ok || echo fail)"
check "last closed session = 88 present" \
  "$(grep -q 'Session 88' "$ROADMAP" && echo ok || echo fail)"
check "active session 'between sessions' present" \
  "$(grep -q 'between sessions' "$ROADMAP" && echo ok || echo fail)"
echo

# --- AC2: file is dramatically shorter (consolidation) ---
echo "[AC2] File size (consolidation target: ≤ 250 lines)"
LINE_COUNT=$(wc -l < "$ROADMAP")
check "line count ≤ 250 (actual: ${LINE_COUNT})" \
  "$([ "$LINE_COUNT" -le 250 ] && echo ok || echo fail)"
echo

# --- AC2: no src/ change ---
echo "[AC2] Scope: no src/ change"
SRC_DIFF=$(git diff --name-only main..HEAD -- src/ 2>/dev/null || true)
check "no src/ files changed" \
  "$([ -z "$SRC_DIFF" ] && echo ok || echo fail)"
echo

# --- AC3: ROADMAP structure present ---
echo "[AC3] Required sections present"
check "'## Where We Are' section present" \
  "$(grep -q '^## Where We Are' "$ROADMAP" && echo ok || echo fail)"
check "'## Pipeline Status' section present" \
  "$(grep -q '^## Pipeline Status' "$ROADMAP" && echo ok || echo fail)"
check "'## Completed Sessions' section present" \
  "$(grep -q '^## Completed Sessions' "$ROADMAP" && echo ok || echo fail)"
check "'## Backlog' section present" \
  "$(grep -q '^## Backlog' "$ROADMAP" && echo ok || echo fail)"
check "'## Design Rules' section present" \
  "$(grep -q '^## Design Rules' "$ROADMAP" && echo ok || echo fail)"
echo

# --- AC4: cargo test --lib unchanged ---
echo "[AC4] cargo test --lib (docs-only session — must stay green)"
if cargo test --lib 2>&1 | grep -q 'test result: ok'; then
  check "cargo test --lib green" "ok"
else
  check "cargo test --lib green" "fail"
fi
echo

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Result: ${PASS}/${TOTAL} checks passed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
