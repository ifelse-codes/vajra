#!/usr/bin/env bash
# The review-only (ground-truth) guard: no code, no commits, no pushes, no PRs in a ground-truth session
# until the founder signs off its report with `vajra approve NN --close` in their own terminal.
# One source (S197, F125 — DECISION-011 S197 addendum): Vajra's own hook-pre-bash.sh / hook-pre-write.sh
# call this file, and `vajra init` / `--sync-fleet` ship the same bytes to every project as
# .ai/hooks/hook-ground-truth-guard.sh (PreToolUse, Bash|Edit|Write|MultiEdit|NotebookEdit). Before S197
# projects had no copy at all, while their Hard Rules said "No code in Ground Truth — Hook-enforced".
#
# Which session: the `session-NN` in the branch name; a branch with none (N17) uses HEAD's committed
# .ai/SESSION + 1 (commits are blocked, so the agent cannot move it), else the working-tree file + 1;
# neither readable → the guard is on. A branch NAME opens nothing (the `-closeout` / `-enforcement`
# exemptions and `VAJRA_GT_WAIVER` are retired). Only the founder's record opens it, read by
# `vajra next --check-close-record NN`; no `vajra`, an older one, or any error → closed.
# Bar-raising, not tamper-proof — the limits are named in the addendum.
# L1 = report-only; L2/L3 = block (exit 2).

set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
MATURITY="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$ROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || true)}"
MATURITY="${MATURITY:-L2}"

# jq preflight — fail-closed at L2/L3, advise at L1 (the same fallback every other shipped hook has).
if ! command -v jq >/dev/null 2>&1; then
  [ "$MATURITY" = "L1" ] && { echo "[vajra] jq not on PATH — the ground-truth guard degraded to advise (L1)."; exit 0; }
  echo "[vajra] BLOCKED: jq required for Vajra enforcement, not on PATH (fail-closed)." 1>&2
  exit 2
fi

INPUT=$(cat 2>/dev/null || echo "{}")
case "$(printf '%s' "$INPUT" | jq -r '.hook_event_name // ""' 2>/dev/null)" in
  PostToolUse*) exit 0 ;;   # a Pre guard only; wired in no Post group, silent if it ever is
esac
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null || echo "")
# No tool name (a hand-fed or older payload): judge by what the input carries, never let it through.
if [ -z "$TOOL" ]; then
  if printf '%s' "$INPUT" | jq -e '.tool_input.command' >/dev/null 2>&1; then TOOL=Bash
  elif printf '%s' "$INPUT" | jq -e '.tool_input.file_path // .tool_input.notebook_path' >/dev/null 2>&1; then TOOL=Write
  fi
fi

# S181: one shared ground-truth answer (scripts/lib-ground-truth.sh; in a scaffold: .ai/hooks/).
for _d in "$(dirname "${BASH_SOURCE[0]}")" "$ROOT/scripts" "$ROOT/.ai/hooks"; do
  [ -f "$_d/lib-ground-truth.sh" ] && { . "$_d/lib-ground-truth.sh"; break; }
done
type vajra_is_ground_truth >/dev/null 2>&1 || {
  echo "[vajra] lib-ground-truth.sh not found — using every-5th only. Run: vajra init --sync-fleet" >&2
  vajra_is_ground_truth() { [ $((10#${1:-0} % 5)) -eq 0 ] && [ $((10#${1:-0})) -gt 0 ]; }
}

BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || true)
NUM=$(printf '%s' "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
GT=0
if [[ "$NUM" =~ ^[0-9]+$ ]] && [ "$((10#$NUM))" -gt 0 ]; then
  vajra_is_ground_truth "$NUM" "$ROOT" && GT=1
else
  # N17: no session number in the branch name.
  _s=$(cd "$ROOT" && git show HEAD:.ai/SESSION 2>/dev/null | tr -d '[:space:]' || true)
  [[ "$_s" =~ ^[0-9]+$ ]] || _s=$(tr -d '[:space:]' < "$ROOT/.ai/SESSION" 2>/dev/null || true)
  if [[ "$_s" =~ ^[0-9]+$ ]]; then
    NUM=$((10#$_s + 1))
    vajra_is_ground_truth "$NUM" "$ROOT" && GT=1
  else
    NUM="?"; GT=1
  fi
fi
[ "$GT" -eq 1 ] || exit 0

# The one opening: the founder's sign-off record, read by the binary (one reader of the S188 void).
OPEN_WHY="the founder has not signed off the report"
if [ "$NUM" = "?" ]; then
  OPEN_WHY="the session number cannot be read (no session-NN in the branch name, no readable .ai/SESSION)"
elif ! command -v vajra >/dev/null 2>&1; then
  OPEN_WHY="vajra is not on PATH, so the founder's sign-off cannot be read"
else
  _out=$(cd "$ROOT" && vajra next --check-close-record "$NUM" 2>&1); _rc=$?
  # Exit 0 alone is not enough: an older `vajra next` ignores a flag it does not know and exits 0.
  [ "$_rc" -eq 0 ] && [ "$(printf '%s\n' "$_out" | head -1)" = "the founder signed off session $((10#$NUM))'s report — the review-only guard is open" ] && exit 0
  case "$_out" in
    *"no founder sign-off"*|*"does not count"*|*"is not a"*) OPEN_WHY="$(printf '%s' "$_out" | head -1)" ;;
    *) OPEN_WHY="this vajra cannot read the founder's sign-off (update vajra: cargo install vajractl)" ;;
  esac
fi
HOW="Write the report (sessions/session-${NUM}-ground-truth.md) and show it to the founder; only they open this, by typing \`vajra approve ${NUM} --close\` in their OWN terminal ($OPEN_WHY)."

refuse() { # what
  if [ "$MATURITY" = "L1" ]; then
    echo "[HOOK WARNING] Ground Truth Session $NUM: $1 (L1 report-only, not blocking)"
    exit 0
  fi
  # stderr: on exit 2 Claude Code hands the agent stderr only.
  echo "[HOOK BLOCK] Ground Truth Session $NUM $1" >&2
  echo "  $HOW" >&2
  exit 2
}

# A path Vajra can reason about — absolute, printable ASCII, no `.`/`..` segment (S191, N2).
gt_plain_path() { # path
  case "$1" in /*) ;; *) return 1 ;; esac
  case "$1" in */../*|*/..|*/./*|*/.|*/) return 1 ;; esac
  case "$1" in *$'\n'*) return 1 ;; esac
  LC_ALL=C grep -q '[^ -~]' <<<"$1"
  [ $? -eq 1 ]   # 1 = no byte outside space..~ ; 0 (found one) or 2 (grep failed) refuse
}

# S191 (N2): 0 only when the target is PROVABLY outside the project folder. The root and the
# target's folder are both resolved through every symlink; a leaf that is a link, a hard link or not a
# plain file refuses; the compare is lower-cased (macOS disks ignore case) on a `/` boundary. Any
# step that fails returns 1, and the caller refuses. GT_WHY names a missing folder.
gt_outside() { # path
  local f="$1" r r0 p parent leaf h t
  GT_WHY=""
  r=$(CDPATH= cd -P -- "$ROOT" 2>/dev/null && pwd -P) || r=""
  [ -n "$r" ] && [ "$r" != "/" ] || return 1
  r0="$r"   # as resolved — the inode walk below needs a real path, not the lower-cased copy
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
  # S191 review rec 1: `cd -P` resolves symlinks only, so a macOS firmlink spelling
  # (/System/Volumes/Data/Users/…) of an inside folder passed the compare above. Walk the target's
  # folder up to `/` and refuse if any step IS the root (`-ef`: same device and inode).
  local d="$p"
  while :; do
    [ "$d" -ef "$r0" ] && return 1
    [ "$d" = / ] && break
    d="${d%/*}"; [ -n "$d" ] || d=/
  done
  return 0
}

case "$TOOL" in
  Bash)
    CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
    case "$CMD" in
      *"git commit"*|*"git push"*|*"gh pr create"*|*"gh pr merge"*|*"glab mr create"*|*"glab mr merge"*|*"git commit --amend"*|*"git rebase"*)
        refuse "forbids commits/pushes/PR ops/rebases."
        ;;
      *"git"*)
        if printf '%s' "$CMD" | grep -qE 'git (commit|push|merge|rebase|cherry-pick|reset|revert|stash)'; then
          refuse "forbids git state changes."
        fi
        ;;
    esac
    ;;
  Edit|Write|MultiEdit|NotebookEdit)
    FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""' 2>/dev/null || echo "")
    gt_plain_path "$FILE" \
      || refuse "forbids edits to $FILE (Vajra can only check an absolute, plain-ASCII path with no '.' or '..' part)"
    case "$FILE" in
      */sessions/session-*-ground-truth.md|*/sessions/session-*-review.md|*/reviewer/*|*/.ai/*|*/scripts/*) : ;;
      *)
        if ! gt_outside "$FILE"; then
          if [ "$GT_WHY" = missing ]; then
            refuse "forbids edits to $FILE: the folder ${FILE%/*} does not exist yet, so Vajra cannot check that the file is outside the project. If it is outside, create the folder first in Bash (mkdir -p '${FILE%/*}'), then write again."
          else
            refuse "forbids edits to $FILE (a file outside the project folder is allowed)"
          fi
        fi
        ;;
    esac
    ;;
esac

exit 0
