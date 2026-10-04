#!/usr/bin/env bash
# PreToolUse(Bash|Edit|Write|MultiEdit|NotebookEdit): the founder's approval records are not the
# agent's to write. Only `vajra approve NN`, typed in the founder's own terminal, writes .ai/approvals/.
# One source (S182): Vajra's own hook-pre-bash.sh / hook-pre-write.sh call this file, and `vajra init`
# ships the same bytes to every project as .ai/hooks/hook-approvals-guard.sh.
#
# Bash: a command that names the folder is blocked when it can write — a redirect whose target lands
# in the folder or cannot be read for certain (S186, F110 b: a variable, glob, quotes, `cd`, a link),
# a file-writing command, or an interpreter or shell (its intent cannot be read from text, S177: fail
# closed). Every command the S182 guard blocked still blocks except a listed set of proven non-writes
# (tests/approvals_guard.rs, `reads()`; S173: guard changes only add).
# Bar-raising, not tamper-proof (DECISION-011): a path built at run time (`d=.ai; d=$d/appr…`) gets past.
# L1 = warn-only; L2/L3 = block (exit 2).

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
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
CWD=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null || echo "")

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

[ -z "$CMD" ] && exit 0
# A backslash-newline is a line continuation: the shell joins the lines before it reads the command
# (S186 cold review P1: `echo x > \<newline>.ai/approvals/y` writes). Joining inside single quotes
# too only makes the guard read MORE as one word — the safe direction.
_BSNL=$'\\\n'; CMD="${CMD//"$_BSNL"/}"

lc() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
# The folder, physically, and the agent's working folder (Claude Code sends `cwd`).
if [ -d "$ROOT/.ai/approvals" ]; then AP=$(cd -P "$ROOT/.ai/approvals" && pwd -P)
elif [ -d "$ROOT/.ai" ]; then AP="$(cd -P "$ROOT/.ai" && pwd -P)/approvals"
else AP="$(cd -P "$ROOT" 2>/dev/null && pwd -P || printf '%s' "$ROOT")/.ai/approvals"; fi
AP_LC=$(lc "$AP")
CWD_P=""; [ -n "$CWD" ] && CWD_P=$(cd -P "$CWD" 2>/dev/null && pwd -P) || true

# Does the command name the folder? Its path, a `cd` into .ai / approvals plus the word, or (S186)
# a `..` segment plus the word. Read case-insensitively and with quotes removed (`".ai"/approvals`,
# `.AI/Approvals` reach the same folder).
NAMED=$(printf '%s' "$CMD" | tr -d "\"'\\\\")
NAMES=0
if printf '%s' "$NAMED" | grep -qiE '\.ai/+(\./)*approvals'; then
  NAMES=1
elif printf '%s' "$NAMED" | grep -qiE 'approvals' && \
     printf '%s' "$NAMED" | grep -qiE '(^|[;&|({`[:space:]])(cd|pushd)[[:space:]]+[^;&|]*(\.ai|approvals)'; then
  NAMES=1
elif printf '%s' "$NAMED" | grep -qiE 'approvals' && \
     printf '%s' "$NAMED" | grep -qE '(^|[/[:space:]=])\.\.(/|[[:space:]]|$)'; then
  NAMES=1
fi
# S186 cold review rec 8: a working folder inside .ai/approvals (a `cd` in an earlier call) — any
# relative write lands there without the command naming it.
case "$(lc "$CWD_P")" in "$AP_LC"|"$AP_LC"/*|*/.ai/approvals|*/.ai/approvals/*) NAMES=1 ;; esac
[ "$NAMES" = 1 ] || exit 0

# Remove only what provably writes nothing: fd duplication/closing and redirects to /dev/null. Each
# is anchored on its right (S182 review rec 1): `>&1/../x` is a WRITE to the file `1/../x`, not a dup.
# The S182 word checks below read this copy, unchanged.
STRIPPED=$(printf '%s' "$CMD" | sed -E \
  -e 's#[0-9]*>&([0-9]+-?|-)([[:space:];&|)]|$)#\2#g' \
  -e 's#[0-9]*<&([0-9]+-?|-)([[:space:];&|)]|$)#\2#g' \
  -e 's#(&>>?|[0-9]*>>?\|?)[[:space:]]*/dev/null([[:space:];&|)]|$)#\2#g')

# --- Redirects (S186, F110 b): block only a redirect that writes into the folder, or one whose target
# the guard cannot read for certain. Every `>` in the de-quoted copy is a possible redirect — heredoc
# bodies and quoted text are read, never skipped (S173), so the worst case is an over-block. `tr -d`
# removes no `>`, so the k-th `>` here is the k-th `>` in the command as written; the target is read
# from both, and any quote or backslash in the written one blocks (`> "a b/../.ai/approvals/y"`).
# Prints one line per redirect: PROC, QUOTED <word>, or TARGET <word>. No next word (end, `;&|`) is
# not a redirect (`<noreply@x>"` in a commit message); `>&N`, `>&-` and /dev/null write nothing.
REDIRECTS=$(G_D="$NAMED" G_C="$CMD" awk '
function sep(ch) { return ch == "" || ch == " " || ch == "\t" || ch == "\n" || index(";&|<>()", ch) > 0 }
function nextgt(s, from,   p) { p = index(substr(s, from), ">"); return p ? from + p - 1 : 0 }
BEGIN {
  d = ENVIRON["G_D"]; c = ENVIRON["G_C"]; nd = length(d); nc = length(c); i = 1; j = 1
  while ((i = nextgt(d, i)) > 0) {
    if ((j = nextgt(c, j)) == 0) { print "QUOTED\t?"; exit }
    i++; j++; op = substr(d, i, 1); quoted = 0
    if (op == "(") { print "PROC"; continue }
    if (op == ">") {
      i++; j2 = nextgt(c, j); if (j2 != j) quoted = 1; j = (j2 ? j2 + 1 : nc + 1)
    } else if (op == "|" || op == "&" || op == "!") {
      i++; if (substr(c, j, 1) == op) j++; else quoted = 1
    }
    while (substr(d, i, 1) == " " || substr(d, i, 1) == "\t") i++
    w = ""; while (i <= nd && !sep(substr(d, i, 1))) { w = w substr(d, i, 1); i++ }
    if (w == "") continue
    if (op == "&" && w ~ /^([0-9]+-?|-)$/) continue
    if (w == "/dev/null") continue
    while (substr(c, j, 1) == " " || substr(c, j, 1) == "\t") j++
    r = ""; while (j <= nc && !sep(substr(c, j, 1))) { r = r substr(c, j, 1); j++ }
    if (quoted || r != w) { print "QUOTED\t" w; continue }
    print "TARGET\t" w
  }
}') || REDIRECTS="QUOTED	?"

# Where a literal target really lands. Exit 0 = into the folder OR not provable; 1 = provably not.
# The existing part of the path is resolved by the kernel (`cd -P`, so a symlink or a `..` after one
# is followed exactly as the write would follow it); a `..` past a missing folder, a target that is
# itself a symlink, or a file with a second hard link is not provable (S186 design rec 7).
lands_in_folder() {
  local t="$1" p dir base rest="" phys seg up full links
  case "$t" in /*) p="$t" ;; *) [ -n "$CWD_P" ] || return 0; p="$CWD_P/$t" ;; esac
  dir="${p%/*}"; base="${p##*/}"; [ -n "$dir" ] || dir=/
  case "$base" in ""|.|..) return 0 ;; esac
  while ! phys=$(cd -P "$dir" 2>/dev/null && pwd -P); do
    seg="${dir##*/}"
    case "$seg" in ..|.) return 0 ;; esac
    rest="$seg/$rest"; up="${dir%/*}"; [ "$up" != "$dir" ] || return 0; dir="${up:-/}"
  done
  if [ -z "$rest" ]; then
    [ -L "$phys/$base" ] && return 0
    if [ -f "$phys/$base" ]; then
      links=$(ls -ld "$phys/$base" 2>/dev/null | awk '{print $2}')
      [ "${links:-2}" = 1 ] || return 0
    fi
  fi
  full=$(lc "$phys/$rest$base" | sed -E 's#/+#/#g')
  case "$full" in "$AP_LC"|"$AP_LC"/*|*/.ai/approvals|*/.ai/approvals/*) return 0 ;; esac
  return 1
}

if [ -n "$REDIRECTS" ]; then
  # A directory change anywhere in the command means a relative target cannot be resolved from `cwd`:
  # `cd`/`pushd`/`popd`/zsh's `chdir` after anything but a letter, `-C`/`--chdir`, or (P3) a command
  # word that expands when it runs (`${x}cd`, `"$x"cd`, `$'\x63d'`) — fail closed.
  CHDIR=0
  printf '%s' "$NAMED" | grep -qE '(^|[^A-Za-z0-9_])(cd|pushd|popd|chdir)([[:space:]]|$|;)|(^|[[:space:]])(-C|--chdir)([[:space:]=]|$)' && CHDIR=1
  printf '%s' "$NAMED" | grep -qE '(^|[;&|(`])[[:space:]]*[^[:space:];&|]*[$`{]' && CHDIR=1
  REASON=""
  while IFS="$(printf '\t')" read -r kind word; do
    case "$kind" in
      PROC) REASON="it writes through a process substitution \`>(…)\`" ;;
      QUOTED) REASON="a redirect target holds quotes or backslashes, so where it writes cannot be read for certain" ;;
      TARGET)
        case "$word" in
          *'$'*|*'`'*|*'{'*|*'*'*|*'?'*|*'['*|*'~'*) REASON="the redirect target \`$word\` is built when the command runs (a variable, glob or \`~\`)" ;;
          *) if [ "$CHDIR" = 1 ]; then REASON="it changes directory (\`cd\`, \`-C\`), so the redirect target \`$word\` cannot be resolved"
             elif lands_in_folder "$word"; then REASON="the redirect target \`$word\` lands in .ai/approvals (or where it lands cannot be proven)"; fi ;;
        esac ;;
    esac
    [ -n "$REASON" ] && break
  done <<EOF
$REDIRECTS
EOF
  if [ -n "$REASON" ]; then
    block ".ai/approvals holds the founder's approvals, and this command names it and redirects output: $REASON." \
          "Only \`vajra approve NN\`, typed by the founder in their own terminal, writes there. Reading is fine: run the read on its own (cat/ls/jq). Writing ABOUT the folder (a commit message, notes)? Put the text in a file with the Write tool, then \`git commit -F <file>\`."
  fi
fi

if printf '%s' "$STRIPPED" | grep -qE '(\btee\b|\bcp\b|\bmv\b|\brm\b|\btouch\b|sed[[:space:]]+(-[a-zA-Z]*[[:space:]]+)*-i|\bdd\b|\binstall\b|\bln\b|\btruncate\b)'; then
  block ".ai/approvals holds the founder's approvals, and this command runs a file-writing tool while naming it." \
        "Only \`vajra approve NN\`, typed by the founder in their own terminal, writes there."
fi
if printf '%s' "$STRIPPED" | grep -qE '(\bpython[0-9.]*\b|\bperl\b|\bnode\b|\bruby\b|\bosascript\b)'; then
  block ".ai/approvals holds the founder's approvals, and this command runs an interpreter while naming it — what a script writes cannot be read from its text, so it is blocked." \
        "To read the folder, use cat, ls or jq on their own. If the script only mentions the folder's name (for example, editing a document about it), use the Edit tool instead."
fi

# S186 (S182 review rec 5): more writers and interpreters — matched only where a command starts
# (start of a line, after `;&|(` or a backtick, or after a wrapper such as `xargs`/`env`/`sudo`), so
# a file name like `hook.sh` or the word "source" in prose is not one (design rec 9). De-quoted copy.
# (cold review rec 4) Also after `if`/`while`/`then`/`do`/`!`/`{` and leading `NAME=value` assignments.
AT='(^|[;&|(`])[[:space:]]*((if|while|until|then|do|else|elif|!|\{)[[:space:]]+)*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*((xargs|env|exec|command|nohup|sudo|time)([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+)?'
if printf '%s' "$NAMED" | grep -qE "${AT}(rsync|wget|tar|unzip|patch|sponge)([[:space:]]|\$)" || \
   printf '%s' "$NAMED" | grep -qE "${AT}git([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+(checkout|restore|clean|reset|stash|apply)([[:space:]]|\$)" || \
   printf '%s' "$NAMED" | grep -qE "${AT}curl([[:space:]][^;&|]*)?[[:space:]](-[a-zA-Z]*[oO]|--output|--remote-name)" || \
   printf '%s' "$NAMED" | grep -qE "${AT}find[[:space:]][^;&|]*[[:space:]]-(delete|exec|execdir|ok|okdir|fprint[0f]?|fls)([[:space:]]|\$)"; then
  block ".ai/approvals holds the founder's approvals, and this command runs a file-writing tool while naming it." \
        "Only \`vajra approve NN\`, typed by the founder in their own terminal, writes there."
fi
# P2: awk and other programs write with their own `>` (`print 1 > f`), which no redirect reading can
# see — like the S182 interpreters, they block while the command names the folder.
if printf '%s' "$NAMED" | grep -qE "${AT}(sh|bash|zsh|dash|ksh|fish|eval|source|\.|xargs|awk|gawk|mawk|nawk|busybox|ed|ex|vi|vim|nvim|emacs|sqlite3|php|lua|tclsh|Rscript)([[:space:]]|\$)"; then
  block ".ai/approvals holds the founder's approvals, and this command runs a shell or a program with its own way to write (awk, an editor) while naming it — what it writes cannot be read from its text, so it is blocked." \
        "To read the folder, use cat, ls or jq on their own."
fi
exit 0
