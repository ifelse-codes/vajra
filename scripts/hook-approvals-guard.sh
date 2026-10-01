#!/usr/bin/env bash
# PreToolUse(Bash|Edit|Write|MultiEdit|NotebookEdit): the founder's approval records are not the
# agent's to write. Only `vajra approve NN`, typed in the founder's own terminal, writes .ai/approvals/.
# One source (S182): Vajra's own hook-pre-bash.sh / hook-pre-write.sh call this file, and `vajra init`
# ships the same bytes to every project as .ai/hooks/hook-approvals-guard.sh.
#
# Bash: a command that names the folder is blocked when it can write — any redirect left after the
# provable non-writes are removed (`N>&M`, `>&N`, `N>&-`, a redirect to /dev/null), a file-writing
# command, or an interpreter (its intent cannot be read from text, S177: fail closed). Every command
# the S181 line blocked is still blocked except those provable non-writes (S173: guard changes only add).
# Bar-raising, not tamper-proof (DECISION-011): a path built at run time (`d=.ai; d=$d/appr…`) gets past.
# L1 = warn-only; L2/L3 = block (exit 2).

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "[vajra] BLOCKED: jq required for Vajra enforcement, not on PATH (fail-closed)." 1>&2
  exit 2
fi

INPUT=$(cat 2>/dev/null || echo "{}")
ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
MATURITY="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$ROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || true)}"
MATURITY="${MATURITY:-L2}"

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

# Write-type tools: the path itself. `//` and `/./` are collapsed so a spelling cannot step around it.
if [ -n "$FILE" ]; then
  NORM=$(printf '%s' "$FILE" | sed -E 's#/+#/#g; s#(/\./)+#/#g; s#^\./##')
  case "$NORM" in
    */.ai/approvals/*|.ai/approvals/*|*/.ai/approvals|.ai/approvals)
      block "$FILE is an approval record. Only the founder writes it: \`vajra approve NN\` in their own terminal." ;;
  esac
fi

[ -z "$CMD" ] && exit 0

# Does the command name the folder? Its path, or a `cd` into .ai / approvals plus the word.
NAMES=0
if printf '%s' "$CMD" | grep -qE '\.ai/+(\./)*approvals'; then
  NAMES=1
elif printf '%s' "$CMD" | grep -qE 'approvals' && \
     printf '%s' "$CMD" | grep -qE '(^|[;&|({[:space:]])(cd|pushd)[[:space:]]+[^;&|]*(\.ai|approvals)'; then
  NAMES=1
fi
[ "$NAMES" = 1 ] || exit 0

# Remove only what provably writes nothing: fd duplication/closing and redirects to /dev/null.
STRIPPED=$(printf '%s' "$CMD" | sed -E \
  -e 's#[0-9]*>&([0-9]+-?|-)##g' \
  -e 's#[0-9]*<&([0-9]+-?|-)##g' \
  -e 's#(&>>?|[0-9]*>>?\|?)[[:space:]]*/dev/null([[:space:];&|)]|$)#\2#g')

if printf '%s' "$STRIPPED" | grep -qE '>'; then
  block ".ai/approvals holds the founder's approvals, and this command redirects output while naming it." \
        "Only \`vajra approve NN\`, typed by the founder in their own terminal, writes there. Reading is fine: run the read on its own (cat/ls/jq), without a redirect in the same command."
fi
if printf '%s' "$STRIPPED" | grep -qE '(\btee\b|\bcp\b|\bmv\b|\brm\b|\btouch\b|sed[[:space:]]+(-[a-zA-Z]*[[:space:]]+)*-i|\bdd\b|\binstall\b|\bln\b|\btruncate\b)'; then
  block ".ai/approvals holds the founder's approvals, and this command runs a file-writing tool while naming it." \
        "Only \`vajra approve NN\`, typed by the founder in their own terminal, writes there."
fi
if printf '%s' "$STRIPPED" | grep -qE '(\bpython[0-9.]*\b|\bperl\b|\bnode\b|\bruby\b|\bosascript\b)'; then
  block ".ai/approvals holds the founder's approvals, and this command runs an interpreter while naming it — what a script writes cannot be read from its text, so it is blocked." \
        "To read the folder, use cat, ls or jq on their own. If the script only mentions the folder's name (for example, editing a document about it), use the Edit tool instead."
fi
exit 0
