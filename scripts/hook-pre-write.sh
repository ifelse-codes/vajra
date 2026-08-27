#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit): blocks code edits during Ground Truth.
# Respects maturity level from CONSTRAINTS.yaml (L1 = warn-only, L2/L3 = can block).

set -euo pipefail

# jq preflight — fail-closed (AGENTS.md L147: a check that cannot evaluate FAILS).
if ! command -v jq >/dev/null 2>&1; then
  _VROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
  _VMAT="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$_VROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo L2)}"
  [ "$_VMAT" = "L1" ] && { echo "[vajra] jq not on PATH — enforcement degraded to advise (L1)."; exit 0; }
  echo "[vajra] BLOCKED: jq required for Vajra enforcement, not on PATH (fail-closed)." 1>&2
  exit 2
fi

INPUT=$(cat 2>/dev/null || echo "{}")
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""' 2>/dev/null || echo "")

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
MATURITY=$(grep -m1 '^maturity:' "$ROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo "L2")
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

# S134 founder waiver: a Ground Truth session may be converted to a CODE session, but ONLY by the
# founder, and ONLY for one named session number. `VAJRA_GT_WAIVER` is set in the LAUNCH
# environment (`VAJRA_GT_WAIVER=NN vajra claude`) — the agent cannot set its own launch env
# mid-session, which is the same un-forgeable-BY-THE-AGENT property `VAJRA_CLOSEOUT_WAIVER` relies
# on. It must equal THIS session's number: a blanket `=1` or a stale number does nothing, so a
# waiver cannot silently outlive the session it was granted for. It is loud on purpose.
if [ "$GT_PW" -eq 1 ] && [ "${VAJRA_GT_WAIVER:-}" = "$SESSION_NUM" ]; then
  echo "[HOOK] Ground Truth Session $SESSION_NUM WAIVED by founder (VAJRA_GT_WAIVER=$SESSION_NUM) — code edits allowed" >&2
  GT_PW=0
fi

if [ "$GT_PW" -eq 1 ]; then
  case "$FILE" in
    */sessions/session-*-ground-truth.md|*/sessions/session-*-review.md|*/reviewer/*|*/.ai/*|*/scripts/*) : ;;
    *)
      if [ "$MATURITY" = "L1" ]; then
        echo "[HOOK WARNING] Ground Truth Session $SESSION_NUM: edit to $FILE (L1 report-only, not blocking)"
      else
        echo "[HOOK BLOCK] Ground Truth Session $SESSION_NUM forbids edits to $FILE"
        exit 2
      fi
      ;;
  esac
fi

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "[HOOK WARNING] Editing files while on $BRANCH. Branch session-NN-<slug> first."
fi

exit 0
