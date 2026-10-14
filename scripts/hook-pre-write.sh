#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit): blocks code edits during Ground Truth (hook-ground-truth-guard.sh).
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

# S181 Part 4 / S182: the founder's approval records are not the agent's to write. One guard, one
# source: scripts/hook-approvals-guard.sh (shipped to projects as .ai/hooks/hook-approvals-guard.sh).
_AG="$(dirname "${BASH_SOURCE[0]}")/hook-approvals-guard.sh"
if [ -f "$_AG" ]; then
  printf '%s' "$INPUT" | bash "$_AG" || exit $?
elif [ "${MATURITY:-L2}" != "L1" ]; then
  echo "[HOOK BLOCK] hook-approvals-guard.sh is missing next to $(basename "$0") — cannot check (fail-closed)." >&2
  exit 2
fi

# S197 (F125, DECISION-011 S197 addendum): the review-only guard — one source, shipped to every project.
# A branch name opens nothing; only the founder's `vajra approve NN --close` record does.
_GG="$(dirname "${BASH_SOURCE[0]}")/hook-ground-truth-guard.sh"
if [ -f "$_GG" ]; then
  printf '%s' "$INPUT" | bash "$_GG" || exit $?
elif [ "${MATURITY:-L2}" != "L1" ]; then
  echo "[HOOK BLOCK] hook-ground-truth-guard.sh is missing next to $(basename "$0") — cannot check (fail-closed)." >&2
  exit 2
fi

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "[HOOK WARNING] Editing files while on $BRANCH. Branch session-NN-<slug> first."
fi

exit 0
