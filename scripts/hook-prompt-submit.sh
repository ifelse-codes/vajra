#!/usr/bin/env bash
# UserPromptSubmit hook: lightweight reminders. Non-blocking.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "[reminder] On $BRANCH. New work must be on a session-NN-<slug> branch."
fi

case "$BRANCH" in
  *-closeout|*-enforcement) : ;;
  *)
    SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
    if [[ "$SESSION_NUM" =~ ^[0-9]+$ ]] && [ "$((10#$SESSION_NUM))" -gt 0 ]; then
      if [ "$((10#$SESSION_NUM % 5))" -eq 0 ]; then
        echo "[reminder] Ground Truth Session $SESSION_NUM — no code, no commits, no PRs."
      fi
    fi
  ;;
esac

exit 0
