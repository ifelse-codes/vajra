#!/usr/bin/env bash
# Stop hook: auto-runs verify-session-NN.sh.

set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")
SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)

if [ -z "$SESSION_NUM" ]; then exit 0; fi

# Ground Truth: check for required output file
# S175: .ai/CONSTRAINTS.yaml#ground_truth_next_session overrides the every-5th default.
GT_NEXT=$(grep -E '^[[:space:]]*ground_truth_next_session:' "$ROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | grep -oE '[0-9]+' | head -1 || true)
IS_GT=0
if [ "$((10#$SESSION_NUM))" -gt 0 ]; then
  if [ -n "$GT_NEXT" ]; then
    [ "$((10#$SESSION_NUM))" -eq "$((10#$GT_NEXT))" ] && IS_GT=1
  else
    [ "$((10#$SESSION_NUM % 5))" -eq 0 ] && IS_GT=1
  fi
fi
if [ "$IS_GT" -eq 1 ]; then
  GT="$ROOT/sessions/session-${SESSION_NUM}-ground-truth.md"
  if [ ! -f "$GT" ]; then
    echo "[HOOK STOP] Ground Truth Session $SESSION_NUM missing $GT"
  fi
  exit 0
fi

# Normal session: run verification
VERIFY="$ROOT/scripts/verify-session-${SESSION_NUM}.sh"
if [ -f "$VERIFY" ]; then
  echo "[hook stop] Running $VERIFY"
  if bash "$VERIFY"; then
    echo "[hook stop] ALL GREEN."
  else
    echo "[HOOK STOP] VERIFY FAILED for session $SESSION_NUM. Fix before close."
  fi
else
  echo "[hook stop] No verify script at $VERIFY. Session $SESSION_NUM needs one before close."
fi

exit