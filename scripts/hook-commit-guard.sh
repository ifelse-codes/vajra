#!/usr/bin/env bash
# PreToolUse(Bash): the un-forgeable teeth on `git commit` (S93 — no-autonomous-commit ENFORCED).
#
# The gap (S76 + S92 dogfoods): the agent self-stops at `commit.autonomous: false` only because
# it CHOOSES to — no hook checks for approval. The L2 `.githooks/pre-commit` belt does check
# (VAJRA_ALLOW_COMMIT==NN), but an agent controlling the command line can inline that env prefix,
# and `git commit --no-verify` skips the git hook entirely. This PreToolUse guard closes both:
#   - It reads its OWN launch environment for the approval marker. An inline
#     `VAJRA_ALLOW_COMMIT=NN git commit` typed by the agent never reaches this hook's env
#     (a child shell can't mutate the parent's env, and PreToolUse fires BEFORE the command
#     runs) — the same un-forgeability the publish-guard relies on (S37).
#   - It fires on the `git commit` tool call regardless of `--no-verify` (that flag skips git's
#     own hooks, not Claude Code's PreToolUse). So a bypass must beat BOTH layers.
#
# Approval signal: VAJRA_ALLOW_COMMIT must equal the current session number (parsed from the
# session-NN-* branch), set by the founder at launch (e.g. `VAJRA_ALLOW_COMMIT=93 vajra claude`).
# Session-scoped, mirroring VAJRA_CLOSEOUT_WAIVER (S56).
#
# Maturity-gated like every Vajra hook (S21): L1 -> ADVISE (exit 0); L2/L3 -> ENFORCE (exit 2).
# Test/override knob: VAJRA_GUARD_MATURITY overrides the maturity read from CONSTRAINTS.yaml.

set -euo pipefail

# ── Opt-in gate (mirrors the S47 publish-guard switch) ───────────────────────────────────────
# The guard ENFORCES only when EITHER VAJRA_ENFORCE_COMMIT=1 is set (explicit re-arm), OR
# .ai/CONSTRAINTS.yaml does NOT carry `commit_guard: off`. The vajra repo sets `commit_guard: off`
# because a live L3 block would brick the build agent's own commits (it cannot set its launch env
# mid-session) — the L2 belt governs this repo, and L3 is proven by payload test. The `vajra init`
# scaffold ships NO such line — the SAME byte-identical hook, gated by config — so every NEW
# project gets the un-forgeable guard ON. The switch lives in CONSTRAINTS, not the code: no drift.
_VROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
_CG=$(grep -m1 '^[[:space:]]*commit_guard:[[:space:]]' "$_VROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo "")
if [ "${VAJRA_ENFORCE_COMMIT:-}" != "1" ] && [ "$_CG" = "off" ]; then
  exit 0
fi

# jq preflight — fail-closed (AGENTS.md L147: a check that cannot evaluate FAILS).
if ! command -v jq >/dev/null 2>&1; then
  _VMAT="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$_VROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo L2)}"
  [ "$_VMAT" = "L1" ] && { echo "[vajra] jq not on PATH — enforcement degraded to advise (L1)."; exit 0; }
  echo "[vajra] BLOCKED: jq required for Vajra enforcement, not on PATH (fail-closed)." 1>&2
  exit 2
fi

INPUT=$(cat 2>/dev/null || echo "{}")
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
CONSTRAINTS="$ROOT/.ai/CONSTRAINTS.yaml"

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
[ -n "$CMD" ] || exit 0

# Classify against the command with QUOTED SPANS REMOVED (the S39 over-block fix), so a trigger
# phrase buried in a message/arg (`echo "git commit"`, `--body "then git commit"`) can't
# false-block. A real invocation always places the command name OUTSIDE quotes.
SCAN=$(sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g" <<<"$CMD")

# Only `git commit` is guarded (not commit-tree, not status/log/diff). Here-string, not a pipe,
# so a short-circuiting grep -q can never SIGPIPE a producer under `set -o pipefail` (S32 gotcha).
grep -qE '(^|[^[:alnum:]_])git[[:space:]]+commit([^[:alnum:]]|$)' <<<"$SCAN" || exit 0

# Session number for this launch (from the session-NN-* branch). A commit off a session branch
# is already policed elsewhere (pre-commit blocks main); if we can't resolve one, fail-closed
# by requiring the marker to be simply non-empty below.
BRANCH=$(git -C "$ROOT" symbolic-ref --quiet --short HEAD 2>/dev/null || echo "")
SESS=""
[[ "$BRANCH" =~ ^session-([0-9]+)- ]] && SESS="${BASH_REMATCH[1]}"

# Defend the "jurisdiction-self-granted" fakest-green (S69): if the agent tries to inline the
# marker in the command itself, that assignment sets the CHILD's env, never this hook's — but
# call it out explicitly rather than letting it look like it might have worked.
if grep -qE '(^|[^[:alnum:]_])VAJRA_ALLOW_COMMIT=' <<<"$SCAN"; then
  {
    echo "[vajra commit-guard] BLOCKED: VAJRA_ALLOW_COMMIT set INLINE in the command."
    echo "  Approval cannot be self-granted. This hook reads its OWN launch environment, which an"
    echo "  inline prefix never reaches. The founder must launch with the marker in the env."
  } 1>&2
  exit 2
fi

# Explicit founder approval for this launch: the marker in THIS hook's env, session-scoped.
if [ -n "${VAJRA_ALLOW_COMMIT:-}" ] && { [ -z "$SESS" ] || [ "${VAJRA_ALLOW_COMMIT}" = "$SESS" ]; }; then
  echo "[vajra commit-guard] ALLOWED (git commit) — VAJRA_ALLOW_COMMIT=${VAJRA_ALLOW_COMMIT}."
  exit 0
fi

MATURITY="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$CONSTRAINTS" 2>/dev/null | awk '{print $2}' || echo "L2")}"

if [ "$MATURITY" = "L1" ]; then
  echo "[vajra commit-guard] git commit — L1 advise (not blocking)."
  echo "  no-autonomous-commit: confirm explicit founder approval per .ai/AGENTS.md."
  exit 0
fi

{
  echo "[vajra commit-guard] BLOCKED: git commit without approval evidence."
  echo "  no-autonomous-commit is ENFORCED (S93). A commit needs explicit founder approval,"
  echo "  supplied as an un-forgeable env marker set at launch (mirrors VAJRA_CLOSEOUT_WAIVER):"
  echo "      VAJRA_ALLOW_COMMIT=${SESS:-NN} vajra claude"
  echo "  To downgrade to advice: set maturity: L1 in .ai/CONSTRAINTS.yaml."
} 1>&2
exit 2
