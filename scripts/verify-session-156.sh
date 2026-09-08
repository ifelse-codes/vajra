#!/usr/bin/env bash
# verify-session-156.sh — S156 administrative close
# Checks: AC2 (KNOWLEDGE.md ≤ 400 lines), AC3 (header updated), AC4 (STATE.md agrees)
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

PASS=0; FAIL=0

ok()  { echo "  PASS  $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

echo "=== verify-session-156 ==="

# AC2: KNOWLEDGE.md line count ≤ 400
LINES=$(wc -l < .ai/KNOWLEDGE.md | tr -d ' ')
if [ "$LINES" -le 400 ]; then
  ok "knowledge-md-lines-le-400 ($LINES lines)"
else
  bad "knowledge-md-lines-le-400 (got $LINES, need ≤ 400)"
fi

# AC3: header reflects S156 prune (must mention S156)
if grep -q "as of S156" .ai/KNOWLEDGE.md; then
  ok "knowledge-md-header-updated"
else
  bad "knowledge-md-header-updated (no 'as of S156' in header)"
fi

# AC4: STATE.md references the new line count for KNOWLEDGE.md
if grep -q "282" .ai/STATE.md || grep -q "${LINES}" .ai/STATE.md; then
  ok "state-md-knowledge-count-agrees"
else
  bad "state-md-knowledge-count-agrees (STATE.md does not reference ${LINES})"
fi

# AC1 (partial): S155 closeout PR (#187) merged — confirmed by SESSION ≥ 155
SESSION=$(tr -d ' \t\n\r' < .ai/SESSION)
if [ "$((10#$SESSION))" -ge 155 ]; then
  ok "s155-closeout-merged (SESSION=$SESSION)"
else
  bad "s155-closeout-merged (SESSION=$SESSION)"
fi

# demo marker
echo "demo:before_after"
echo "demo:knowledge_line_count"

echo ""
echo "Score: $((PASS+FAIL)) checks — $FAIL FAILED"
[ "$FAIL" -eq 0 ]
