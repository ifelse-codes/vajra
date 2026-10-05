#!/usr/bin/env bash
# PreToolUse(Bash|Edit|Write|MultiEdit|NotebookEdit): the founder's approval records are not the
# agent's to write. Only `vajra approve NN`, typed in the founder's own terminal, writes .ai/approvals/.
# One source (S182): Vajra's own hook-pre-bash.sh / hook-pre-write.sh call this file, and `vajra init`
# ships the same bytes to every project as .ai/hooks/hook-approvals-guard.sh.
#
# Bash: a command that names the folder (its path, a `..` next to the word, a `cd` into it, or a working
# folder inside it) is blocked when it can write — any redirect left after the provable non-writes, a
# file-writing command, or an interpreter, shell or program that writes by its own syntax (its intent
# cannot be read from text, S177: fail closed). S186 only adds to what the S182 guard blocked: every S182
# check reads the command as written, unchanged; the joined copy is extra lines (tests/approvals_guard.rs).
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
# A backslash-newline is a line continuation (S186 cold review P1: `echo x > \<newline>.ai/approvals/y`
# writes). The joined copy is APPENDED as extra lines, never put in place of the command: every check
# below is a line-by-line grep, so it reads the command exactly as S182 did PLUS the joined lines — it
# can only match more (pass 3, R1: replacing it hid `rm` behind `#x\<newline>`, which the shell runs).
# awk, not `${CMD//\\$'\n'/}`: that bash substitution is quadratic in backslashes on macOS's bash 3.2
# (S186 pass 5: 10,000 backslashes took over 120 s — past a hook timeout, which does not block). awk
# reads everything (no early exit, so no SIGPIPE) and is linear.
_BSNL=$'\\\n'
case "$CMD" in
  *"$_BSNL"*) _JOINED=$(printf '%s\n' "$CMD" | awk '{ if (sub(/\\$/, "")) printf "%s", $0; else print }')
               CMD="$CMD"$'\n'"$_JOINED" ;;
esac

lc() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
# The folder, physically, and the agent's working folder (Claude Code sends `cwd`).
# Never an exit here: under `set -e` a folder that cannot be entered (`chmod 000`) used to end the
# guard with exit 1, which Claude Code does not treat as a block (pass 3, R3). Fall back to the path.
AP=$(cd -P "$ROOT/.ai/approvals" 2>/dev/null && pwd -P) \
  || AP="$(cd -P "$ROOT/.ai" 2>/dev/null && pwd -P)/approvals" \
  || AP="$ROOT/.ai/approvals"
[ "$AP" = "/approvals" ] && AP="$ROOT/.ai/approvals"
AP_LC=$(lc "$AP")
CWD_P=""; [ -n "$CWD" ] && CWD_P=$(cd -P "$CWD" 2>/dev/null && pwd -P) || true

# Does the command name the folder? Its path, a `cd` into .ai / approvals plus the word, or (S186)
# a `..` segment plus the word. Read case-insensitively and with quotes removed (`".ai"/approvals`,
# `.AI/Approvals` reach the same folder).
NAMED=$(printf '%s' "$CMD" | tr -d "\"'\\\\")
NAMES=0
if printf '%s' "$NAMED" | grep -ciE '\.ai/+(\./)*approvals' >/dev/null; then
  NAMES=1
elif printf '%s' "$NAMED" | grep -ciE 'approvals' >/dev/null && \
     printf '%s' "$NAMED" | grep -ciE '(^|[;&|({`[:space:]])(cd|pushd)[[:space:]]+[^;&|]*(\.ai|approvals)' >/dev/null; then
  NAMES=1
elif printf '%s' "$NAMED" | grep -ciE 'approvals' >/dev/null && \
     printf '%s' "$NAMED" | grep -cE '(^|[/[:space:]=])\.\.(/|[[:space:]]|$)' >/dev/null; then
  NAMES=1
fi
# S186 cold review rec 8: a working folder inside .ai/approvals (a `cd` in an earlier call) — any
# relative write lands there without the command naming it.
case "$(lc "$CWD_P")" in "$AP_LC"|"$AP_LC"/*|*/.ai/approvals|*/.ai/approvals/*) NAMES=1 ;; esac
[ "$NAMES" = 1 ] || exit 0

# Every check below is `printf | grep -c … >/dev/null`, never `grep -q` (S186 pass 4): under pipefail,
# grep -q quitting on its first match killed printf with SIGPIPE on a large command, and the failed pipe
# read as "no match" — the S182 guard let a ~60 KB command through that way. grep -c reads all of its
# input, so printf always finishes; and unlike a here-string it needs no temp file (pass 5: a full disk).
# Remove only what provably writes nothing: fd duplication/closing and redirects to /dev/null. Each
# is anchored on its right (S182 review rec 1): `>&1/../x` is a WRITE to the file `1/../x`, not a dup.
# The S182 word checks below read this copy, unchanged.
STRIPPED=$(printf '%s' "$CMD" | sed -E \
  -e 's#[0-9]*>&([0-9]+-?|-)([[:space:];&|)]|$)#\2#g' \
  -e 's#[0-9]*<&([0-9]+-?|-)([[:space:];&|)]|$)#\2#g' \
  -e 's#(&>>?|[0-9]*>>?\|?)[[:space:]]*/dev/null([[:space:];&|)]|$)#\2#g')

# Any redirect left after the provable non-writes above blocks — the S182 rule, kept. S186 built a
# guard that read where each `>` really writes (F110 b); two cold reviews found writes into the folder
# it let through that this rule blocks (a backslash-newline, awk's own `>`, a disguised `cd`, zsh's
# `>>!`/`>&|`, a full-path awk). The founder split (b) into its own session (2026-10-04); until then a
# command that names the folder AND redirects anywhere blocks, and the message says how to get past.
if printf '%s' "$STRIPPED" | grep -cE '>' >/dev/null; then
  block ".ai/approvals holds the founder's approvals, and this command redirects output while naming it." \
        "Only \`vajra approve NN\`, typed by the founder in their own terminal, writes there. Reading is fine: run the read on its own (cat/ls/jq), without a redirect in the same command. Writing ABOUT the folder (a commit message, notes)? Put the text in a file with the Write tool, then \`git commit -F <file>\`."
fi

# S187 (F110 class, founder pick C): the checks below read the WHOLE command, so a harmless read
# joined to an unrelated write (`git checkout -b x main && ls <the folder>`, 2026-10-04) blocks.
# What blocks does not change; the reason says how to get past it.
SPLIT="Only reading the folder? Run the read (cat, ls or jq) as its own command, not joined to the rest by && or ; — the rest then runs as a second command. Writing ABOUT the folder (a commit message, notes)? Put the text in a file with the Write tool, then \`git commit -F <file>\`."
S182_WRITERS='(\btee\b|\bcp\b|\bmv\b|\brm\b|\btouch\b|sed[[:space:]]+(-[a-zA-Z]*[[:space:]]+)*-i|\bdd\b|\binstall\b|\bln\b|\btruncate\b)'
S182_INTERP='(\bpython[0-9.]*\b|\bperl\b|\bnode\b|\bruby\b|\bosascript\b)'
# The S182 lists, unchanged, read the command as written AND (S186, pass-2 rec 4) the de-quoted copy,
# so a quote-spelled writer (`l''n`, `r"m"`) is caught too. Only adds.
if printf '%s' "$STRIPPED" | grep -cE "$S182_WRITERS" >/dev/null || printf '%s' "$NAMED" | grep -cE "$S182_WRITERS" >/dev/null; then
  block ".ai/approvals holds the founder's approvals, and this command runs a file-writing tool while naming it." \
        "Only \`vajra approve NN\`, typed by the founder in their own terminal, writes there. $SPLIT"
fi
if printf '%s' "$STRIPPED" | grep -cE "$S182_INTERP" >/dev/null || printf '%s' "$NAMED" | grep -cE "$S182_INTERP" >/dev/null; then
  block ".ai/approvals holds the founder's approvals, and this command runs an interpreter while naming it — what a script writes cannot be read from its text, so it is blocked." \
        "$SPLIT If the script only mentions the folder's name (for example, editing a document about it), use the Edit tool instead."
fi

# S186 (S182 review rec 5): more writers and interpreters — matched only where a command starts
# (start of a line, after `;&|(` or a backtick, or after a wrapper such as `xargs`/`env`/`sudo`), so
# a file name like `hook.sh` or the word "source" in prose is not one (design rec 9). De-quoted copy.
# (cold review rec 4) Also after `if`/`while`/`then`/`do`/`!`/`{` and leading `NAME=value` assignments.
AT='(^|[;&|(`])[[:space:]]*((if|while|until|then|do|else|elif|!|\{)[[:space:]]+)*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*((xargs|env|exec|command|builtin|nohup|sudo|time)([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+)?([^[:space:];&|]*/)?'
if printf '%s' "$NAMED" | grep -cE "${AT}(rsync|wget|tar|unzip|patch|sponge)([[:space:]]|\$)" >/dev/null || \
   printf '%s' "$NAMED" | grep -cE "${AT}git([[:space:]]+[^;&|[:space:]]+)*[[:space:]]+(checkout|restore|clean|reset|stash|apply)([[:space:]]|\$)" >/dev/null || \
   printf '%s' "$NAMED" | grep -cE "${AT}curl([[:space:]][^;&|]*)?[[:space:]](-[a-zA-Z]*[oO]|--output|--remote-name)" >/dev/null || \
   printf '%s' "$NAMED" | grep -cE "${AT}find[[:space:]][^;&|]*[[:space:]]-(delete|exec|execdir|ok|okdir|fprint[0f]?|fls)([[:space:]]|\$)" >/dev/null; then
  block ".ai/approvals holds the founder's approvals, and this command runs a file-writing tool while naming it." \
        "Only \`vajra approve NN\`, typed by the founder in their own terminal, writes there. $SPLIT"
fi
# awk and other programs write by their own syntax (`print 1 > f`, an editor's `:w`) — like the S182
# interpreters, they block while the command names the folder, with or without a path in front.
if printf '%s' "$NAMED" | grep -cE "${AT}(sh|bash|zsh|dash|ksh|fish|eval|source|\.|xargs|awk|gawk|mawk|nawk|busybox|ed|ex|vi|vim|nvim|emacs|sqlite3|php|lua|tclsh|Rscript)([[:space:]]|\$)" >/dev/null; then
  block ".ai/approvals holds the founder's approvals, and this command runs a shell or a program with its own way to write (awk, an editor) while naming it — what it writes cannot be read from its text, so it is blocked." \
        "$SPLIT"
fi
exit 0
