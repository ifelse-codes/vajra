#!/usr/bin/env bash
# check-subagent-cost-fields.sh — S111: reusable, re-runnable check for whether a Claude Code
# subagent transcript EVER carries a per-call dollar cost (`total_cost_usd` / `cost_usd`).
#
# This is NOT a check against a doc-comment's claim — it scans the real, local
# ~/.claude/projects/*/*/subagents/*.jsonl files on THIS machine, the same files `vajra meter`
# already reads (src/meter/mod.rs's `subagent_dir` folding). Anyone (the founder, CI-on-a-machine-
# with-history, a future session) can re-run this and get the same falsifiable answer.
#
# This is inherently LOCAL-machine-only (a fresh CI runner has no `~/.claude/projects` history) —
# same class of limitation as `vajra next --dogfood-age`. Exit 0 either way; the finding is printed,
# not asserted. `--assert-null` makes it fail (exit 1) if ANY file DOES carry a cost key, so this
# script can also be used to catch the day Claude Code starts emitting one.

set -uo pipefail

HOME_DIR="${HOME:-$(eval echo ~)}"
PROJECTS_DIR="${VAJRA_CLAUDE_PROJECTS_DIR:-$HOME_DIR/.claude/projects}"
ASSERT_NULL=0
[ "${1:-}" = "--assert-null" ] && ASSERT_NULL=1

if [ ! -d "$PROJECTS_DIR" ]; then
  echo "SKIP: no $PROJECTS_DIR on this machine — nothing to check (local-machine-only check)."
  exit 0
fi

total=0
with_cost=0
files_with_cost=()

while IFS= read -r -d '' f; do
  total=$((total+1))
  if grep -q '"total_cost_usd"\|"cost_usd"' "$f" 2>/dev/null; then
    with_cost=$((with_cost+1))
    files_with_cost+=("$f")
  fi
done < <(find "$PROJECTS_DIR" -path "*/subagents/*.jsonl" -print0 2>/dev/null)

echo "subagent JSONL transcripts scanned: $total"
echo "transcripts carrying total_cost_usd/cost_usd: $with_cost"
if [ "$with_cost" -gt 0 ]; then
  printf '  %s\n' "${files_with_cost[@]}"
fi

if [ "$ASSERT_NULL" -eq 1 ] && [ "$with_cost" -gt 0 ]; then
  echo "ASSERT FAILED: --assert-null was passed but $with_cost file(s) carry a cost key."
  exit 1
fi

exit 0
