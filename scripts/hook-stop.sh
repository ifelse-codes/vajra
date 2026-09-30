#!/usr/bin/env bash
# Stop hook: auto-runs verify-session-NN.sh.

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
SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)

if [ -z "$SESSION_NUM" ]; then exit 0; fi

# Ground Truth: check for required output file
IS_GT=0
vajra_is_ground_truth "$SESSION_NUM" "$ROOT" && IS_GT=1
[ -n "${VAJRA_GT_NOTE:-}" ] && echo "[HOOK STOP] $VAJRA_GT_NOTE"
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