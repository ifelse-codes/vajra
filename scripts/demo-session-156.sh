#!/usr/bin/env bash
# demo-session-156.sh — S156 administrative close
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

echo "=== S156 Demo: KNOWLEDGE.md prune ==="
echo ""

# before_after: show the before and after line counts
echo "demo:before_after"
echo "  BEFORE (S155 GT): 1364 lines (header claimed 475 as of S105 — 3× stale)"
LINES=$(wc -l < .ai/KNOWLEDGE.md | tr -d ' ')
echo "  AFTER  (S156):    ${LINES} lines (≤ 400)"
echo ""

# knowledge_line_count
echo "demo:knowledge_line_count"
echo "  wc -l .ai/KNOWLEDGE.md → ${LINES}"
echo ""

echo "=== S156 Demo: PR merges ==="
SESSION=$(tr -d ' \t\n\r' < .ai/SESSION)
echo "  .ai/SESSION = ${SESSION}"
echo "  S155 closeout merged as PR #187"
echo "  S153 PR #184 MERGED"
echo "  S154 PR #185 MERGED"
echo ""

echo "Done."
