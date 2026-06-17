#!/usr/bin/env bash
# Stop hook: auto-runs verify-session-NN.sh.

set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")
SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)

if [ -z "$SESSION_NUM" ]; then exit 0; fi

# Ground Truth: check for required output file
if [ "$((10#$SESSION_NUM))" -gt 0 ] && [ "$((10#$SESSION_NUM % 5))" -eq 0 ]; then
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