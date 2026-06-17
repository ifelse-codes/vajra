#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit): blocks code edits during Ground Truth.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo "{}")
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""' 2>/dev/null || echo "")

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")
SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)

# Ground Truth detection
case "$BRANCH" in
  *-closeout|*-enforcement) GT_PW=0 ;;
  *)
    if [ -n "$SESSION_NUM" ] && [ "$((10#$SESSION_NUM))" -gt 0 ]; then
      if [ "$((10#$SESSION_NUM % 5))" -eq 0 ]; then
        GT_PW=1
      else
        GT_PW=0
      fi
    else
      GT_PW=0
    fi
  ;;
esac

if [ "$GT_PW" -eq 1 ]; then
  case "$FILE" in
    */sessions/session-*-ground-truth.md|*/.ai/*|*/scripts/*) : ;;
    *)
      echo "[HOOK BLOCK] Ground Truth Session $SESSION_NUM forbids edits to $FILE"
      exit 2
      ;;
  esac
fi

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "[HOOK WARNING] Editing files while on $BRANCH. Branch session-NN-<slug> first."
fi

exit 0
