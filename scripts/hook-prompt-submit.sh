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
      # S175: .ai/CONSTRAINTS.yaml#ground_truth_next_session overrides the every-5th default.
      GT_NEXT=$(grep -E '^[[:space:]]*ground_truth_next_session:' "$ROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | grep -oE '[0-9]+' | head -1 || true)
      IS_GT=0
      if [ -n "$GT_NEXT" ]; then
        [ "$((10#$SESSION_NUM))" -eq "$((10#$GT_NEXT))" ] && IS_GT=1
      else
        [ "$((10#$SESSION_NUM % 5))" -eq 0 ] && IS_GT=1
      fi
      if [ "$IS_GT" -eq 1 ]; then
        echo "[reminder] Ground Truth Session $SESSION_NUM — no code, no commits, no PRs."
      fi
    fi
  ;;
esac

exit 0
