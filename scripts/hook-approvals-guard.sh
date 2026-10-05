#!/usr/bin/env bash
# The founder's approval records are not the agent's to write. Only `vajra approve NN`, typed in the
# founder's own terminal (or the founder's launch-time yes), writes .ai/approvals/.
# One source (S182): Vajra's own hook-pre-bash.sh / hook-pre-write.sh call this file, and `vajra init`
# ships the same bytes to every project as .ai/hooks/hook-approvals-guard.sh.
#
# S188 (DECISION-011 S188 addendum, the founder's plan of 2026-10-05): check what CHANGED, not what the
# words say. Wired on three events, with the same matcher:
#   PreToolUse          save the folder's state (outside the folder, keyed by the call's tool_use_id);
#                       then a Write/Edit/MultiEdit/NotebookEdit aimed at the folder is blocked by its path.
#   PostToolUse         (the call succeeded) and
#   PostToolUseFailure  (it failed): save the state again and compare. Same → silent. Changed, or no
#                       "before" to compare with → every record present is listed in
#                       .ai/approvals/voided.json, so `approved()` reads it as missing until the founder
#                       writes it again, and the agent is told (exit 2 — the tool already ran; it cannot block).
# The founder's own `vajra approve NN` lands BETWEEN two calls, so no pair sees it.
# Bar-raising, not tamper-proof — the gaps are named in the addendum (a change undone within one call, the
# before record edited, a write landing between calls, another project's folder).
# L1 = report-only; L2/L3 = block / void (exit 2).

set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
MATURITY="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$ROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || true)}"
MATURITY="${MATURITY:-L2}"

# jq preflight — fail-closed at L2/L3, advise at L1 (the same fallback every other shipped hook has).
if ! command -v jq >/dev/null 2>&1; then
  [ "$MATURITY" = "L1" ] && { echo "[vajra] jq not on PATH — the approvals guard degraded to advise (L1)."; exit 0; }
  echo "[vajra] BLOCKED: jq required for Vajra enforcement, not on PATH (fail-closed)." 1>&2
  exit 2
fi

INPUT=$(cat 2>/dev/null || echo "{}")

block() {
  if [ "$MATURITY" = "L1" ]; then
    echo "[HOOK WARNING] $1 (L1 report-only, not blocking)"
    exit 0
  fi
  # stderr: on exit 2 Claude Code hands the agent stderr only (the S181 block reached it as "No stderr output").
  echo "[HOOK BLOCK] $1" >&2
  [ -n "${2:-}" ] && echo "  $2" >&2
  exit 2
}

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // ""' 2>/dev/null || echo "")
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // ""' 2>/dev/null || echo "")
CALL=$(echo "$INPUT" | jq -r '.tool_use_id // ""' 2>/dev/null || echo "")

# ── the before/after check (S188) ──────────────────────────────────────────────────────────────────
AP="$ROOT/.ai/approvals"
VOID=voided.json
# The before record: outside the folder and the tracked tree, private to this user (mode 700), named by
# the project and the call. A tool_use_id that is not a plain token is treated as missing.
SNAP="${TMPDIR:-/tmp}"; SNAP="${SNAP%/}/vajra-approvals-$(id -u 2>/dev/null || echo u)"
KEY=""
case "$CALL" in
  ""|*[!A-Za-z0-9_-]*) ;;
  *) KEY="$(printf '%s' "$ROOT" | cksum | awk '{print $1}')-$CALL" ;;
esac

snap_dir_ok() {
  mkdir -p -m 700 "$SNAP" 2>/dev/null || true
  [ -d "$SNAP" ] && [ ! -L "$SNAP" ] && [ -O "$SNAP" ]
}

# A file's content hash. --no-filters: autocrlf or a .gitattributes clean filter must not make two
# different files hash the same, nor run a filter program here (design-advisor rec 5). No git → cksum.
hash_of() {
  git hash-object --no-filters -- "$1" 2>/dev/null \
    || { cksum < "$1" 2>/dev/null | awk '{print "ck" $1 "-" $2}'; } \
    || echo unreadable
}

# The folder's state: its own type first, then one NUL-ended record per entry (type, name, hash or link
# target), sorted. A NUL cannot be in a name, so two different states never print the same bytes.
state() {
  if [ -L "$AP" ]; then printf 'folder\tlink\t%s\0' "$(readlink "$AP" 2>/dev/null || echo '?')"
  elif [ -d "$AP" ]; then
    if [ -r "$AP" ] && [ -x "$AP" ]; then printf 'folder\tdir\0'; else printf 'folder\tunreadable\0'; return 0; fi
  elif [ -e "$AP" ]; then printf 'folder\tother\0'; return 0
  else printf 'folder\tabsent\0'; return 0
  fi
  [ -d "$AP/" ] || return 0
  local f rel i=0 paths=() batch=() hashes=() h
  while IFS= read -r -d '' f; do paths+=("$f"); done < <(find "$AP/" -mindepth 1 -print0 2>/dev/null | LC_ALL=C sort -z)
  # Every plain file's hash from ONE git process (S188 review rec 5: a spawn per record made every call
  # slower as records pile up, one per session). A path holding a newline cannot go through
  # --stdin-paths: it is hashed on its own below. A batch that fails (an unreadable file) or comes back
  # short falls back to one hash per file, so an unreadable entry is still recorded as a state.
  for f in ${paths[@]+"${paths[@]}"}; do
    [ ! -L "$f" ] && [ -f "$f" ] && case "$f" in *$'\n'*) ;; *) batch+=("$f") ;; esac
  done
  if [ ${#batch[@]} -gt 0 ]; then
    while IFS= read -r h; do hashes+=("$h"); done < <(printf '%s\n' "${batch[@]}" | git hash-object --no-filters --stdin-paths 2>/dev/null || true)
    [ ${#hashes[@]} -eq ${#batch[@]} ] || hashes=()
  fi
  for f in ${paths[@]+"${paths[@]}"}; do
    rel="${f#"$AP"/}"
    if [ -L "$f" ]; then printf 'L\t%s\t%s\0' "$rel" "$(readlink "$f" 2>/dev/null || echo '?')"
    elif [ -d "$f" ]; then
      if [ -r "$f" ] && [ -x "$f" ]; then printf 'D\t%s\0' "$rel"; else printf 'D\t%s\tunreadable\0' "$rel"; fi
    elif [ -f "$f" ]; then
      h=""
      case "$f" in *$'\n'*) ;; *) [ ${#hashes[@]} -gt 0 ] && h="${hashes[$i]}"; i=$((i+1)) ;; esac
      [ -n "$h" ] || h=$(hash_of "$f")
      printf 'F\t%s\t%s\0' "$rel" "$h"
    else printf 'O\t%s\0' "$rel"
    fi
  done
}

# PreToolUse: save first, before any block decides (design-advisor rec 4). A state that cannot be saved
# leaves no record and exits nothing here — never 1, which would end Vajra's own hook-pre-bash.sh and
# hook-pre-write.sh before their later checks. The after hook counts a missing record as a change.
save_before() {
  [ -n "$KEY" ] || return 0
  snap_dir_ok || return 0
  find "$SNAP" -type f -mtime +0 -delete 2>/dev/null || true   # records older than a day
  local tmp
  tmp=$(mktemp "$SNAP/.b.XXXXXX" 2>/dev/null) || return 0
  if state > "$tmp" 2>/dev/null; then mv -f "$tmp" "$SNAP/$KEY" 2>/dev/null || rm -f "$tmp"
  else rm -f "$tmp"; fi
  return 0
}

# What changed, in names (for the message only — macOS's awk cannot split on NUL, so NUL becomes a
# newline here; a name holding a newline reads oddly in the message, the compare above is exact).
describe() {
  local b a
  b=$(mktemp "$SNAP/.d.XXXXXX" 2>/dev/null) && a=$(mktemp "$SNAP/.d.XXXXXX" 2>/dev/null) || { echo "something in it"; return 0; }
  tr '\0' '\n' < "$1" > "$b"; tr '\0' '\n' < "$2" > "$a"
  awk -F '\t' '
    FNR == NR { if ($1 != "folder") before[$2] = $0; else bf = $0; next }
    { if ($1 != "folder") { after[$2] = $0; if (!($2 in before)) add = add " " $2; else if (before[$2] != $0) chg = chg " " $2 } else af = $0 }
    END {
      for (n in before) if (!(n in after)) rem = rem " " n
      if (bf != af) out = out "the folder itself (" substr(bf, 8) " → " substr(af, 8) ") "
      if (add != "") out = out "added:" add " "
      if (chg != "") out = out "changed:" chg " "
      if (rem != "") out = out "removed:" rem
      sub(/ +$/, "", out); print out
    }' "$b" "$a" 2>/dev/null || echo "something in it"
  rm -f "$b" "$a"
}

# The void: every record name present now (top level, the marker itself left out), written by THIS
# process into the folder — so removing or editing the marker is itself a change the next pair catches.
# S188 review rec 1 — it must not fail open: the names reach jq on stdin, NUL-separated (as argv, a file
# named `--x` was read by jq as an option and no void was written), and a folder made read-only is
# made writable again first. If it still cannot be written, the caller says the approvals STILL count.
write_void() {
  local what="$1" names=() f n tmp
  [ -d "$AP/" ] || return 1
  while IFS= read -r -d '' f; do
    n="${f##*/}"; [ "$n" = "$VOID" ] || names+=("$n")
  done < <(find "$AP/" -mindepth 1 -maxdepth 1 -print0 2>/dev/null | LC_ALL=C sort -z)
  [ -w "$AP/" ] || chmod u+w "$AP/" 2>/dev/null || true
  [ -d "$AP/$VOID" ] && [ ! -L "$AP/$VOID" ] && rm -rf "$AP/$VOID"
  tmp=$(mktemp "$AP/.$VOID.XXXXXX" 2>/dev/null) || return 1
  if printf '%s\0' ${names[@]+"${names[@]}"} | jq -Rs --arg what "$what" --arg at "$(date +%s)" \
      '{listed: (split("\u0000") | map(select(. != ""))), at_unix: ($at | tonumber), what: $what,
        note: "an AI tool call changed this folder; a listed record does not count until the founder writes it again (vajra approve NN)"}' \
      > "$tmp" 2>/dev/null; then
    mv -f "$tmp" "$AP/$VOID" 2>/dev/null && return 0
  fi
  rm -f "$tmp"; return 1
}

# PostToolUse / PostToolUseFailure. Never deletes the before record: the after check can run twice for
# one call (a project wiring it twice, or vajra claude's --settings copy), and two runs must agree.
after() {
  local why="" what="" now listed
  if [ -z "$KEY" ]; then
    why="this tool call carried no tool_use_id, so there is no record of the folder from before it (update Claude Code)"
  elif [ ! -f "$SNAP/$KEY" ]; then
    why="there is no record of the folder from before this command (a hook that timed out, a full temp folder, or the record was removed)"
  else
    now=$(mktemp "$SNAP/.a.XXXXXX" 2>/dev/null) || now=""
    if [ -z "$now" ] || ! state > "$now" 2>/dev/null; then
      why="Vajra could not read the folder after this command"
    elif cmp -s "$SNAP/$KEY" "$now"; then
      rm -f "$now"; return 0
    else
      what=$(describe "$SNAP/$KEY" "$now")
    fi
    [ -n "$now" ] && rm -f "$now"
  fi
  if [ "$MATURITY" = "L1" ]; then
    echo "[HOOK WARNING] .ai/approvals: ${what:+changed during this command — $what}${why:+$why} (L1 report-only: no approval voided)"
    return 0
  fi
  local voided=1
  if write_void "${what:-$why}"; then
    listed=$(jq -r '.listed | join(", ")' "$AP/$VOID" 2>/dev/null || true)
  else
    voided=0
    listed=$(find "$AP/" -mindepth 1 -maxdepth 1 2>/dev/null | sed 's#.*/##' | LC_ALL=C sort | paste -sd, - | sed 's/,/, /g')
  fi
  {
    if [ -n "$what" ]; then
      echo "[vajra] CAUGHT: .ai/approvals changed during this command — $what"
    else
      echo "[vajra] CAUGHT: Vajra could not compare .ai/approvals before and after this command — $why."
    fi
    echo "  Only the founder writes there (\`vajra approve NN\`, in their own terminal). Vajra cannot undo it."
    if [ "$voided" = 1 ]; then
      echo "  These approvals no longer count until the founder approves again: ${listed:-none present} (listed in .ai/approvals/$VOID)."
    else
      echo "  Vajra could NOT write .ai/approvals/$VOID, so these approvals were NOT voided and STILL count: ${listed:-none present}. Founder: look at the folder now."
    fi
    echo "  Stop and tell the founder what you ran. Do not write there again — reading it is fine."
    echo "  Founder: if you ran \`vajra approve\` yourself while this command was running, or this was a git checkout or pull that moved a record, just run it again."
  } >&2
  return 2
}

case "$EVENT" in
  PostToolUse|PostToolUseFailure) rc=0; after || rc=$?; exit "$rc" ;;
esac
# PreToolUse (or a direct call that names no event): save the state first, then the checks below.
save_before

# Write-type tools: the path itself. `//` and `/./` are collapsed, and (S186, S182 review rec 1) a
# `..` segment next to the word `approvals` counts as the folder: `.ai/hooks/../approvals/x` is it.
if [ -n "$FILE" ]; then
  # Lower-cased: macOS's default filesystem is case-insensitive, so `.AI/Approvals/x` is the folder.
  NORM=$(printf '%s' "$FILE" | tr '[:upper:]' '[:lower:]' | sed -E 's#/+#/#g; s#(/\./)+#/#g; s#^\./##')
  case "$NORM" in
    */.ai/approvals/*|.ai/approvals/*|*/.ai/approvals|.ai/approvals|*approvals*/../*|*/../*approvals*|../*approvals*)
      block "$FILE is an approval record. Only the founder writes it: \`vajra approve NN\` in their own terminal." ;;
  esac
fi

# S188: the Bash word checks are gone (DECISION-011 S188 addendum). A Bash command is not read: what it
# changed in the folder is checked after it runs (above). Writing ABOUT the folder, or reading it in any
# command, is never blocked again.
exit 0
