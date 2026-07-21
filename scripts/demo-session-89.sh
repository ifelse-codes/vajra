#!/usr/bin/env bash
# demo-session-89.sh — Session 89: ROADMAP consolidation
set -euo pipefail

ROADMAP=".ai/ROADMAP.md"

echo "=== demo-session-89: ROADMAP consolidation + stale table fix ==="
echo

# --- Before: what the stale table looked like (from git history) ---
echo "── BEFORE (stale fields as of last commit on main) ──────────────────"
BEFORE_SECTION=$(git show main:.ai/ROADMAP.md 2>/dev/null \
  | awk '/^## Where We Are/,/^---/')
echo "$BEFORE_SECTION" | head -12
echo

# --- After: the updated table ---
echo "── AFTER (current .ai/ROADMAP.md) ──────────────────────────────────"
AFTER_SECTION=$(awk '/^## Where We Are/,/^---/' "$ROADMAP")
echo "$AFTER_SECTION" | head -12
echo

# --- Size comparison ---
OLD_LINES=$(git show main:.ai/ROADMAP.md 2>/dev/null | wc -l)
NEW_LINES=$(wc -l < "$ROADMAP")
echo "── Size reduction ───────────────────────────────────────────────────"
echo "  Before: ${OLD_LINES} lines"
echo "  After:  ${NEW_LINES} lines"
echo "  Saved:  $((OLD_LINES - NEW_LINES)) lines ($(( (OLD_LINES - NEW_LINES) * 100 / OLD_LINES ))%)"
echo

# --- New structure overview ---
echo "── New section structure ────────────────────────────────────────────"
grep '^## ' "$ROADMAP"
echo

echo "=== demo complete ==="
