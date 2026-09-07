#!/usr/bin/env bash
# demo-session-149.sh — S149 advice-influence audit (DOCUMENT session).
#
# Shows: the audit file exists, the summary table, and the recommendation verdict.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

AUDIT="sessions/session-149-advice-influence-audit.md"

echo "demo:header"
echo "=== S149 Demo: Advice-Influence Audit ==="
echo ""

echo "demo:cases"
echo "--- Audit file ---"
[ -f "$AUDIT" ] || { echo "FAIL: $AUDIT not found"; exit 1; }
echo "PASS: $AUDIT exists"
echo ""

echo "--- Summary table ---"
grep -A10 "^## Summary table" "$AUDIT" | head -12
echo ""

echo "--- Recommendation verdict ---"
grep -A3 "^## Recommendation" "$AUDIT" | head -4
echo ""

echo "demo:summary_table"
echo "=== Grading counts ==="
grep "\*\*Total\*\*" "$AUDIT" | head -1
echo ""

echo "demo:before_after"
echo "--- Before S149 ---"
echo "  F2f gap: named since S133, no data on whether advice changed work"
echo "--- After S149 ---"
echo "  22 advice items graded: 13 Changed · 1 Noted · 8 Hollow (59% Changed)"
echo "  Recommendation: ban carry-forward without named target session (zero new code)"
echo ""

echo "=== PASS ==="
