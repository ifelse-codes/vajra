#!/usr/bin/env bash
# PreToolUse(Bash): guards outward/irreversible actions (S37 — close the S36 enforcement leak).
#
# The S36 dogfood finding: at maturity L3, in ONE chat, the agent pushed to a real
# remote and created + merged two real PRs — Vajra's hooks stopped none of it.
# hook-pre-bash.sh only *warns* on `git push`; nothing watched `gh pr create`/`gh pr merge`.
# This hook turns the outward/irreversible actions into a real, maturity-gated BLOCK
# unless the founder has explicitly authorized publishing for this launch.
#
# Guarded actions: git push (any form), gh pr create, gh pr merge, glab mr create/merge.
#
# Approval signal: the environment variable VAJRA_ALLOW_PUBLISH=1, set by the founder at
# launch (e.g. `VAJRA_ALLOW_PUBLISH=1 vajra claude`). An env var — NOT a token file —
# because the agent can `touch` a file itself but CANNOT mutate this hook's launch
# environment from inside a Bash tool call (a child shell can't change the parent's env,
# and PreToolUse fires *before* the command runs, so an inline `VAJRA_ALLOW_PUBLISH=1 git
# push` typed by the agent never reaches this hook's own environment). Escape hatch mirrors
# VAJRA_SKIP_AUTH_CHECK (S34).
#
# When enforcing (see the S47 opt-in gate below), maturity-gated like every Vajra hook (S21):
#   L1    -> ADVISE  : warn on stdout, exit 0 (agent may proceed).
#   L2/L3 -> ENFORCE : warn on stderr, exit 2 (action blocked).
# NOTE (S47): no longer always-on — this repo DISABLED it (`publish_guard: off` in CONSTRAINTS);
# re-arm with VAJRA_ENFORCE_PUBLISH=1. The `vajra init` scaffold still ships it on. See the gate
# right after `set -euo pipefail`.
#
# Test/override knob: VAJRA_GUARD_MATURITY overrides the maturity read from CONSTRAINTS.yaml.

set -euo pipefail

# ── S47 founder directive: the publish-guard is OPT-IN now ───────────────────────────────────
# The enforcement arc (S37→S44) is complete + LIVE-VERIFIED (S46) and direction is B, so the
# founder disabled the always-on block in THIS repo. The guard ENFORCES only when EITHER the env
# var VAJRA_ENFORCE_PUBLISH=1 is set (explicit re-arm), OR .ai/CONSTRAINTS.yaml does NOT carry
# `publish_guard: off`. This repo sets `publish_guard: off`, so publishing is allowed with no env
# var. The scaffold ships NO such line — the SAME byte-identical hook, gated by config — so every
# NEW project still gets the guard ON. The switch lives in CONSTRAINTS, not the code: no drift.
_VROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
_PG=$(grep -m1 '^[[:space:]]*publish_guard:[[:space:]]' "$_VROOT/.ai/CONSTRAINTS.yaml" 2>/dev/null | awk '{print $2}' || echo "")
if [ "${VAJRA_ENFORCE_PUBLISH:-}" != "1" ] && [ "$_PG" = "off" ]; then
  exit 0
fi

# jq preflight — fail-closed (AGENTS.md L147: a check that cannot evaluate FAILS).
if ! command -v jq >/dev/null 2>&1; then
  _VROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
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

# S39 (story B — fix the over-block): classify against the command with QUOTED SPANS
# REMOVED, so a trigger phrase buried inside an argument/message no longer false-blocks
# (`git commit -m "…git push…"`, `--body "…gh pr create…"`, `echo "gh pr merge"`). A real
# invocation always places the command name OUTSIDE quotes, so stripping quoted spans can
# never hide a genuine push/PR — fail-safe: anything unquoted still matches and blocks.
# S173 (F50/F44, cold review recs 1-3): what a guard READS. Prose — quoted text, a heredoc body —
# is hidden; anything bash would RUN stays visible: backticks and $( ) (even inside double quotes),
# the rest of the line a heredoc opens on, and the whole of a `bash -c` / `eval` string. The first
# S173 cut hid all of those and let `cat <<EOF >x; git push -f origin HEAD:main` through unapproved.
# vajra_scan [1] — with 1, each quoted span becomes the placeholder Q instead of vanishing.
vajra_scan() { VQ="${1:-0}" perl -0777 -pe '
# VAJRA_SCAN (S173): what a guard reads. Prose is hidden; anything bash would RUN stays visible.
my $q = ($ENV{VQ} // "") eq "1";   # 1 = each quoted span becomes the placeholder Q
my $s = $_;
# The BODY of a heredoc is text — unless it is fed to a shell (bash <<EOF runs it). The rest of
# the line the heredoc opens on is still command, and stays.
$s =~ s{(^|\n)([^\n]*?)<<-?[ \t]*([\x27"]?)(\w+)\3([^\n]*)\n.*?\n[ \t]*\4[ \t]*(?=\n|$)}{
  my ($p, $pre, $rest, $all) = ($1, $2, $5, $&);
  $pre =~ /(^|[^\w])((?:ba|z|da|k)?sh|eval|source)\s*$/ ? $all : "$p$pre H $rest" }gse;
$s =~ s/\$\(\s*cat\s+H\s*\)/ /g;   # "$(cat <<EOF … EOF)" — a heredoc fed to cat is text
# A `-c` / eval string IS a command: past this point hide nothing (over-block is the safe side).
unless ($s =~ /(^|[^\w])(eval|(?:ba|z|da|k)?sh\s+(?:-\w+\s+)*-c)(\s|$)/) {
  # Left to right, as bash reads it: single-quoted text is literal; "…" is text except $( … ) and `…` inside,
  # which bash runs and so stay visible; outside quotes everything stays.
  my ($o, $i, $n) = ("", 0, length $s);
  while ($i < $n) {
    my $c = substr($s, $i, 1);
    if ($c eq "\\") { $o .= substr($s, $i, 2); $i += 2; next; }
    if ($c eq "\x27") { my $j = index($s, "\x27", $i + 1); $j = $n if $j < 0;
                        $o .= $q ? "Q" : ""; $i = $j + 1; next; }
    if ($c eq "\"") {
      my @keep; $i++;
      while ($i < $n && substr($s, $i, 1) ne "\"") {
        my $d = substr($s, $i, 1);
        if ($d eq "\\") { $i += 2; next; }
        if ($d eq "`") { my $j = index($s, "`", $i + 1); $j = $n if $j < 0;
                         push @keep, substr($s, $i + 1, $j - $i - 1); $i = $j + 1; next; }
        if (substr($s, $i, 2) eq "\$(") { my ($j, $depth) = ($i + 2, 1);
          while ($j < $n && $depth) { my $e = substr($s, $j, 1); $depth++ if $e eq "("; $depth-- if $e eq ")"; $j++; }
          push @keep, substr($s, $i + 2, $j - $i - 3); $i = $j; next; }
        $i++;
      }
      $i++;
      $o .= @keep ? " " . join(" ; ", @keep) . " " : ($q ? "Q" : "");
      next;
    }
    $o .= $c; $i++;
  }
  $s = $o;
}
$_ = $s;
'; }
SCAN=$(vajra_scan 0 <<<"$CMD")

# Classify the command as an outward/irreversible action. Here-strings (not pipes) so a
# short-circuiting `grep -q` can never SIGPIPE a producer under `set -o pipefail` (S32 gotcha).
ACTION=""
if grep -qE '(^|[^[:alnum:]_])git[[:space:]]+push([^[:alnum:]]|$)' <<<"$SCAN"; then
  ACTION="git push (publishing commits to a remote)"
elif grep -qE '(^|[^[:alnum:]_])gh[[:space:]]+pr[[:space:]]+create([^[:alnum:]]|$)' <<<"$SCAN"; then
  ACTION="gh pr create (opening a pull request)"
elif grep -qE '(^|[^[:alnum:]_])gh[[:space:]]+pr[[:space:]]+merge([^[:alnum:]]|$)' <<<"$SCAN"; then
  ACTION="gh pr merge (merging a pull request)"
elif grep -qE '(^|[^[:alnum:]_])glab[[:space:]]+mr[[:space:]]+create([^[:alnum:]]|$)' <<<"$SCAN"; then
  ACTION="glab mr create (opening a merge request)"
elif grep -qE '(^|[^[:alnum:]_])glab[[:space:]]+mr[[:space:]]+merge([^[:alnum:]]|$)' <<<"$SCAN"; then
  ACTION="glab mr merge (merging a merge request)"
fi
[ -n "$ACTION" ] || exit 0

# Explicit founder approval for this launch — allow through.
if [ "${VAJRA_ALLOW_PUBLISH:-}" = "1" ]; then
  echo "[vajra publish-guard] ALLOWED ($ACTION) — VAJRA_ALLOW_PUBLISH=1."
  exit 0
fi

# S173 F55 (founder pick B, 2026-09-22): the session's launch approval also covers SHIPPING that
# session's own branch. In rudra S04 the founder chose "push + open PR" in chat, the guard blocked
# both, and he hand-typed `git push` and a long `gh pr create`. With VAJRA_ALLOW_COMMIT=NN set at
# launch, on branch session-NN-*, the agent may run EXACTLY one of these shapes and nothing else:
#     git push [-u|--set-upstream] [origin [HEAD|<this branch>]]
#     gh pr create …            (no --head, or --head <this branch>; any --base)
# optionally after `cd <this project> && ` and followed by `2>&1` and one `| head`/`| tail`. An ALLOW-list, not a block-list: the
# S173 design-advisor found a dozen push spellings a block-list missed (colon refspecs to other
# branches, `-uf`, quoted `+`, `--no-verify`, push options, URLs, `git -c … push`). Anything not on
# the list falls back to the human, as before S173. The env var is read from THIS hook's launch
# environment, so an agent typing `VAJRA_ALLOW_COMMIT=NN git push` inline changes nothing.
BRANCH=$(git -C "$ROOT" branch --show-current 2>/dev/null || echo "")
SESS=""
[[ "$BRANCH" =~ ^session-([0-9]+)- ]] && SESS="${BASH_REMATCH[1]}"
if [ -n "$SESS" ] && [ "${VAJRA_ALLOW_COMMIT:-}" = "$SESS" ]; then
  # One line, single spaces, the optional output tail removed.
  # Quoted spans become a placeholder `Q`, not nothing: deleting them turned
  # `git push origin "+session-NN-x"` (a force-push) into a plain `git push origin`.
  QSCAN=$(vajra_scan 1 <<<"$CMD")
  ONE=$(tr '\n' ' ' <<<"$QSCAN" | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//; s/ \| (head|tail)( -n)?( -?[0-9]+)?$//; s/ 2>&1$//')
  B_RE=$(printf '%s' "$BRANCH" | sed -E 's/[].[^$*+?(){}|\\/]/\\&/g')
  # A leading `cd <this project> && ` (rudra's agent writes one on every command) — this project only.
  ROOT_REAL=$(cd "$ROOT" 2>/dev/null && pwd -P || printf '%s' "$ROOT")
  for R in "$ROOT" "$ROOT_REAL"; do
    [ "${ONE#cd $R && }" != "$ONE" ] && ONE="${ONE#cd $R && }"
  done
  SHIP_OK=""
  if [[ "$ONE" =~ ^git\ push(\ (-u|--set-upstream))?(\ origin(\ (HEAD|$B_RE))?)?$ ]]; then
    SHIP_OK=1
  # gh pr create: no shell syntax, no backslash, and either no head flag or exactly ONE, spelled
  # `--head <this branch>` / `--head=<this branch>` / `-H <this branch>` (cold review rec 4: a joined
  # `-Hsession-03-y`, a repeated `--head`, and `--he\ad` all got past the first cut).
  elif [[ "$ONE" =~ ^gh\ pr\ create(\ |$) ]] && ! grep -qE '[][;&|<>$`(){}\\]' <<<"$ONE" \
       && HEADS=$({ grep -oE -- '(^| )(-H[^ ]*|--he[a-z]*[^ ]*)' <<<"$ONE" || true; } | wc -l | tr -d ' ') \
       && { [ "$HEADS" = 0 ] \
            || { [ "$HEADS" = 1 ] && grep -qE -- "(^| )(--head[ =]|-H )$B_RE( |$)" <<<"$ONE"; }; }; then
    SHIP_OK=1
  fi
  if [ -n "$SHIP_OK" ]; then
    echo "[vajra publish-guard] ALLOWED ($ACTION) — session $SESS's own branch; VAJRA_ALLOW_COMMIT=$SESS was given at launch. Merging stays with the human."
    exit 0
  fi
fi

MATURITY="${VAJRA_GUARD_MATURITY:-$(grep -m1 '^maturity:' "$CONSTRAINTS" 2>/dev/null | awk '{print $2}' || echo "L2")}"

if [ "$MATURITY" = "L1" ]; then
  echo "[vajra publish-guard] $ACTION — L1 advise (not blocking)."
  echo "  Outward/irreversible action; confirm explicit founder approval per .ai/AGENTS.md."
  exit 0
fi

{
  echo "[vajra publish-guard] BLOCKED: $ACTION"
  echo "  Outward/irreversible actions need explicit founder approval (S37 — the S36 leak)."
  echo "  To allow this launch: relaunch with VAJRA_ALLOW_PUBLISH=1"
  echo "    (e.g. VAJRA_ALLOW_PUBLISH=1 vajra claude)."
  echo "  To downgrade to advice: set maturity: L1 in .ai/CONSTRAINTS.yaml."
} 1>&2
exit 2
