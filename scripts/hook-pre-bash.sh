#!/usr/bin/env bash
# PreToolUse(Bash): warns on destructive cmds; blocks commits during Ground Truth.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo "{}")
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# Destructive command warnings
case "$CMD" in
  *"git commit"*|*"git push"*|*"git reset --hard"*|*"git push --force"*|*"rm -rf"*|*"--no-verify"*|*"--no-gpg-sign"*|*"git checkout ."*|*"git restore ."*|*"git clean -f"*|*"git branch -D"*)
    echo "[HOOK WARNING] Destructive/publish/skip-verify command:"
    echo "  $CMD"
    echo "[HOOK WARNING] Per .ai/AGENTS.md, confirm explicit user approval first."
    ;;
esac

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")

# Ground Truth detection
GT=0; GT_NUM=""
case "$BRANCH" in
  *-closeout|*-enforcement) GT=0 ;;
  *)
    SNUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
    if [[ "$SNUM" =~ ^[0-9]+$ ]] && [ "$((10#$SNUM))" -gt 0 ]; then
      if [ "$((10#$SNUM % 5))" -eq 0 ]; then
        GT=1; GT_NUM="$SNUM"
      fi
    fi
  ;;
esac

# Block commits/pushes/PRs during Ground Truth
if [ "$GT" -eq 1 ]; then
  case "$CMD" in
    *"git commit"*|*"git push"*|*"gh pr create"*|*"gh pr merge"*|*"glab mr create"*|*"glab mr merge"*|*"git commit --amend"*|*"git rebase"*)
      echo "[HOOK BLOCK] Ground Truth Session $GT_NUM forbids commits/pushes/PR ops/rebases."
      exit 2
      ;;
    *"git"*)
      # Block any git command that might modify history or state during GT
      if echo "$CMD" | grep -qE 'git (commit|push|merge|rebase|cherry-pick|reset|revert|stash)'; then
        echo "[HOOK BLOCK] Ground Truth Session $GT_NUM forbids git state changes."
        exit 2
      fi
      ;;
  esac
fi

exit 0
