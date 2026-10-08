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
# S181: one shared ground-truth answer (scripts/lib-ground-truth.sh; in a scaffold: .ai/hooks/).
for _d in "$(dirname "${BASH_SOURCE[0]}")" "$ROOT/scripts" "$ROOT/.ai/hooks"; do
  [ -f "$_d/lib-ground-truth.sh" ] && { . "$_d/lib-ground-truth.sh"; break; }
done
type vajra_is_ground_truth >/dev/null 2>&1 || {
  echo "[vajra] lib-ground-truth.sh not found — using every-5th only. Run: vajra init --sync-fleet" >&2
  vajra_is_ground_truth() { [ $((10#${1:-0} % 5)) -eq 0 ] && [ $((10#${1:-0})) -gt 0 ]; }
}
MATURITY=$(grep -m1 '^maturity:' "$ROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo "L2")
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")
SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)

# S181 Part 4 / S182: the founder's approval records are not the agent's to write. One guard, one
# source: scripts/hook-approvals-guard.sh (shipped to projects as .ai/hooks/hook-approvals-guard.sh).
_AG="$(dirname "${BASH_SOURCE[0]}")/hook-approvals-guard.sh"
if [ -f "$_AG" ]; then
  printf '%s' "$INPUT" | bash "$_AG" || exit $?
elif [ "${MATURITY:-L2}" != "L1" ]; then
  echo "[HOOK BLOCK] hook-approvals-guard.sh is missing next to $(basename "$0") — cannot check (fail-closed)." >&2
  exit 2
fi

# Ground Truth detection
case "$BRANCH" in
  *-closeout|*-enforcement) GT_PW=0 ;;
  *)
    if [ -n "$SESSION_NUM" ] && [ "$((10#$SESSION_NUM))" -gt 0 ]; then
      if vajra_is_ground_truth "$SESSION_NUM" "$ROOT"; then GT_PW=1; else GT_PW=0; fi
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

# One way to refuse, as before S191: warn at L1, otherwise block (exit 2 — exit 1 does not block).
gt_refuse() { # why
  if [ "$MATURITY" = "L1" ]; then
    echo "[HOOK WARNING] Ground Truth Session $SESSION_NUM: edit to $FILE (L1 report-only, not blocking)"
  else
    echo "[HOOK BLOCK] Ground Truth Session $SESSION_NUM forbids edits to $FILE$1" >&2
    exit 2
  fi
}

# S191 (N2, DECISION-011 S191 addendum §1): a path Vajra can reason about — absolute, printable
# ASCII, no `.`/`..` segment. Anything else is refused before the allowlist, so
# `/proj/.ai/../src/x.rs` no longer passes as `*/.ai/*`.
gt_plain_path() { # path
  case "$1" in /*) ;; *) return 1 ;; esac
  case "$1" in */../*|*/..|*/./*|*/.|*/) return 1 ;; esac
  case "$1" in *$'\n'*) return 1 ;; esac
  LC_ALL=C grep -q '[^ -~]' <<<"$1"
  [ $? -eq 1 ]   # 1 = no byte outside space..~ ; 0 (found one) or 2 (grep failed) refuse
}

# S191 (N2): 0 only when the target is PROVABLY outside the project folder. The root and the
# target's folder are both resolved through every link; a leaf that is a link, a hard link or not a
# plain file refuses; the compare is lower-cased (macOS disks ignore case) on a `/` boundary. Any
# step that fails returns 1, and the caller refuses. GT_WHY names a missing folder.
gt_outside() { # path
  local f="$1" r p parent leaf h t
  GT_WHY=""
  r=$(CDPATH= cd -P -- "$ROOT" 2>/dev/null && pwd -P) || r=""
  [ -n "$r" ] && [ "$r" != "/" ] || return 1
  parent="${f%/*}"; leaf="${f##*/}"
  [ -n "$parent" ] || parent="/"
  [ -n "$leaf" ] || return 1
  if [ ! -d "$parent" ]; then GT_WHY=missing; return 1; fi
  p=$(CDPATH= cd -P -- "$parent" 2>/dev/null && pwd -P) || p=""
  [ -n "$p" ] || return 1
  if [ -e "$f" ] || [ -L "$f" ]; then
    [ ! -L "$f" ] && [ -f "$f" ] || return 1
    h=$(find "$f" -prune -links +1 2>/dev/null) || h=ERR
    [ -z "$h" ] || return 1
  fi
  t="${p%/}/$leaf"
  r=$(LC_ALL=C tr '[:upper:]' '[:lower:]' <<<"$r") || return 1
  t=$(LC_ALL=C tr '[:upper:]' '[:lower:]' <<<"$t") || return 1
  case "$t" in "$r"|"$r"/*) return 1 ;; esac
  return 0
}

if [ "$GT_PW" -eq 1 ]; then
  gt_plain_path "$FILE" \
    || gt_refuse " (Vajra can only check an absolute, plain-ASCII path with no '.' or '..' part)"
  case "$FILE" in
    */sessions/session-*-ground-truth.md|*/sessions/session-*-review.md|*/reviewer/*|*/.ai/*|*/scripts/*) : ;;
    *)
      if ! gt_outside "$FILE"; then
        if [ "$GT_WHY" = missing ]; then
          gt_refuse ": the folder ${FILE%/*} does not exist yet, so Vajra cannot check that the file is outside the project. If it is outside, create the folder first in Bash (mkdir -p '${FILE%/*}'), then write again."
        else
          gt_refuse " (a file outside the project folder is allowed)"
        fi
      fi
      ;;
  esac
fi

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "[HOOK WARNING] Editing files while on $BRANCH. Branch session-NN-<slug> first."
fi

exit 0
