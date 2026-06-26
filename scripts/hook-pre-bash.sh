#!/usr/bin/env bash
# PreToolUse(Bash): warns on destructive cmds; blocks commits during Ground Truth.
# Respects maturity level from CONSTRAINTS.yaml (L1 = warn-only, L2/L3 = can block).

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo "{}")
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
MATURITY=$(grep -m1 '^maturity:' "$ROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo "L2")

# Destructive command warnings
case "$CMD" in
  *"git commit"*|*"git push"*|*"git reset --hard"*|*"git push --force"*|*"rm -rf"*|*"--no-verify"*|*"--no-gpg-sign"*|*"git checkout ."*|*"git restore ."*|*"git clean -f"*|*"git branch -D"*)
    echo "[HOOK WARNING] Destructive/publish/skip-verify command:"
    echo "  $CMD"
    echo "[HOOK WARNING] Per .ai/AGENTS.md, confirm explicit user approval first."
    ;;
esac

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
  gt_block() {
    if [ "$MATURITY" = "L1" ]; then
      echo "[HOOK WARNING] Ground Truth Session $GT_NUM: $1 (L1 report-only, not blocking)"
    else
      echo "[HOOK BLOCK] Ground Truth Session $GT_NUM $1"
      exit 2
    fi
  }
  case "$CMD" in
    *"git commit"*|*"git push"*|*"gh pr create"*|*"gh pr merge"*|*"glab mr create"*|*"glab mr merge"*|*"git commit --amend"*|*"git rebase"*)
      gt_block "forbids commits/pushes/PR ops/rebases."
      ;;
    *"git"*)
      if echo "$CMD" | grep -qE 'git (commit|push|merge|rebase|cherry-pick|reset|revert|stash)'; then
        gt_block "forbids git state changes."
      fi
      ;;
  esac
fi

exit 0
