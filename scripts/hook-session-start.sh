#!/usr/bin/env bash
# SessionStart hook: prints mandatory load-order files. Non-blocking.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

echo "=== Vajra Agent Boot (per .ai/AGENTS.md) ==="
echo ""

# Darshan enforcement (S32): surface the speaking skill IN the boot packet so it
# loads every session (was only a prose row in AGENTS.md the agent skipped — S31 #1).
# The one rule is inlined so it governs even if the file is never opened; speak-back
# makes it stick (mirrors Varta's read->internalize->speak ritual). Advised -> enforced.
echo "┌─ SPEAKING SKILL · DARSHAN (default human output, every reply) ─┐"
echo "│ ONE RULE: render the richest visual this surface can handle ·  │"
echo "│ always glanceable · never drop meaning.                       │"
echo "│ PLAIN WORDS: the words beside any box are everyday English a  │"
echo "│ non-coder gets — no project jargon; say what it means for     │"
echo "│ them. Session results come this way FIRST, never on request.  │"
echo "│ Tiers: rich chat (HTML/SVG) · terminal (ANSI/box) · plain md.  │"
echo "│ Full skill: darshan/SKILL.md                                   │"
echo "│ ▶ ACK NOW: open your FIRST reply in Darshan form (a glance /   │"
echo "│   verdict / table), not a wall of prose.                      │"
echo "└───────────────────────────────────────────────────────────────┘"
echo ""

for f in .ai/SESSION .ai/SESSION-BOOT.md .ai/TASK.md .ai/STATE.md .ai/CONSTRAINTS.yaml; do
  if [ -f "$ROOT/$f" ]; then
    echo "----- $f -----"
    cat "$ROOT/$f"
    echo ""
  else
    echo "[hook warn] missing: $f" >&2
  fi
done

# S172 F38: the handover names the next prompt by hand, and rudra's said `prompts/03-execution-…`
# for a file saved as `prompts/03-task-execution-…`. Say so at boot instead of letting the agent
# find out mid-session. Only the pointer files' top (the "next" part), and only a warning.
{ cat "$ROOT/.ai/SESSION-BOOT.md" 2>/dev/null || true; head -15 "$ROOT/.ai/TASK.md" 2>/dev/null || true; } \
  | grep -oE 'prompts/[0-9]+-[A-Za-z0-9._<>-]+\.md' | sort -u | while read -r p; do
    case "$p" in *'<'*|*'>'*) continue ;; esac   # `prompts/173-task-<slug>.md` is a shape, not a file

    [ -f "$ROOT/$p" ] && continue
    near=$(ls "$ROOT/prompts/" 2>/dev/null | grep -E "^$(echo "$p" | grep -oE '[0-9]+' | head -1)-task-" | head -1 || true)
    echo "[hook warn] the handover names $p — no such file.${near:+ Did it mean prompts/$near?}"
  done

BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")
echo "Current branch: $BRANCH"

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo ""
  echo "[REMINDER] On $BRANCH. Branch session-NN-<slug> before any work."
fi

case "$BRANCH" in
  *-closeout|*-enforcement) : ;;
  *)
    SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
    if [[ "$SESSION_NUM" =~ ^[0-9]+$ ]] && [ "$((10#$SESSION_NUM))" -gt 0 ]; then
      if [ "$((10#$SESSION_NUM % 5))" -eq 0 ]; then
        echo ""
        echo "[REMINDER] Session $SESSION_NUM is GROUND TRUTH. No code, no commits, no PRs."
      fi
    fi
  ;;
esac

# Commit pre-authorization (S99) — the S97 Rung-1 blocker (b): an unattended `-p` run has no chat
# channel to receive an approval token, so it can never commit and the Coder station can never
# record a sha. The out-of-band token already exists (VAJRA_ALLOW_COMMIT=NN, the S93 un-forgeable
# marker); nothing told the agent it was there. `vajra next` says this too, but a headless run may
# never call it — the boot packet is the surface it always reads.
#
# Classification mirrors scripts/hook-commit-guard.sh exactly (session digits from a session-NN-*
# branch; off such a branch any non-empty marker is accepted), so this line can never say
# "pre-granted" where the guard would block. It is ADVISORY: the guard is the enforcing check.
echo ""
_SESS=$(echo "$BRANCH" | grep -oE '^session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
if [ -z "${VAJRA_ALLOW_COMMIT:-}" ]; then
  echo "[commit approval] NOT GIVEN for this launch — you may not commit on your own."
  echo "  Saying yes in chat does NOT reach this check (S171). Either the person types the commit"
  echo "  in their own terminal — Vajra does not stop a person — or they start you with the"
  echo "  approval already given: VAJRA_ALLOW_COMMIT=${_SESS:-NN} vajra claude"
elif [ -z "$_SESS" ] || [ "${VAJRA_ALLOW_COMMIT}" = "$_SESS" ]; then
  echo "[commit approval] PRE-GRANTED — VAJRA_ALLOW_COMMIT=${VAJRA_ALLOW_COMMIT} is set at launch."
  echo "  That marker IS the founder's approval token for this session (S93); commits may proceed"
  echo "  without a chat token. Advisory line — the L3 commit-guard remains the enforcing check."
else
  echo "[commit approval] NOT VALID HERE — VAJRA_ALLOW_COMMIT=${VAJRA_ALLOW_COMMIT} is scoped to"
  echo "  session ${VAJRA_ALLOW_COMMIT}, but this branch is session ${_SESS}. The guard will BLOCK."
  echo "  Relaunch with VAJRA_ALLOW_COMMIT=${_SESS}."
fi

# S171 (founder's first-run test): the session's checklist, printed at boot. Everything the agent
# skipped until it was asked — the crew dispatch, the demo, the three ranked options, the next
# prompt — is a line here, with the first unfinished one named as the move to make now. Prose in
# .ai/AGENTS.md was skippable; this is the first thing the session reads. Silent when vajra is not
# on PATH (an older install still boots).
if command -v vajra >/dev/null 2>&1; then
  echo ""
  vajra next --steps 2>/dev/null || true
fi

exit 0
