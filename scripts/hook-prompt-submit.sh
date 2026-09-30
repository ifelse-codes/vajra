#!/usr/bin/env bash
# UserPromptSubmit hook: lightweight reminders. Non-blocking.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
# S181: one shared ground-truth answer (scripts/lib-ground-truth.sh; in a scaffold: .ai/hooks/).
for _d in "$(dirname "${BASH_SOURCE[0]}")" "$ROOT/scripts" "$ROOT/.ai/hooks"; do
  [ -f "$_d/lib-ground-truth.sh" ] && { . "$_d/lib-ground-truth.sh"; break; }
done
type vajra_is_ground_truth >/dev/null 2>&1 || {
  echo "[vajra] lib-ground-truth.sh not found — using every-5th only. Run: vajra init --sync-fleet" >&2
  vajra_is_ground_truth() { [ $((10#${1:-0} % 5)) -eq 0 ] && [ $((10#${1:-0})) -gt 0 ]; }
}
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "[reminder] On $BRANCH. New work must be on a session-NN-<slug> branch."
fi

case "$BRANCH" in
  *-closeout|*-enforcement) : ;;
  *)
    SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
    if [[ "$SESSION_NUM" =~ ^[0-9]+$ ]] && [ "$((10#$SESSION_NUM))" -gt 0 ]; then
      IS_GT=0
      vajra_is_ground_truth "$SESSION_NUM" "$ROOT" && IS_GT=1
      [ -n "${VAJRA_GT_NOTE:-}" ] && echo "[reminder] $VAJRA_GT_NOTE"
      if [ "$IS_GT" -eq 1 ]; then
        echo "[reminder] Ground Truth Session $SESSION_NUM — no code, no commits, no PRs."
      fi
    fi
  ;;
esac

exit 0
