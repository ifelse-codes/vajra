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
# S173 (F50, after two cold-review REJECTs): what a guard READS is the pre-S173 rule — quoted spans
# stripped LINE BY LINE — plus ONE narrow exception. Cleverer readers were tried twice and each hid
# something bash runs. The exception: a commit message / PR body in the exact shape agents write,
#     git commit -q -m "$(cat <<'EOF'      (a QUOTED delimiter: bash expands nothing in the body)
#     …
#     EOF
#     )"
# is text, and hidden — only when the text before it is a plain `git commit … -m` or
# `gh pr create … --body` with no quoting at all, and only up to the first delimiter line. rudra's
# F50 commit was this shape.
# vajra_heredoc [1] prints the command with that shape removed (1 = replaced by the placeholder Q);
# vajra_scan then strips quoted spans line by line, as before S173 —
vajra_heredoc() { VQ="${1:-0}" perl -0777 -pe '
  my $q = ($ENV{VQ} // "") eq "1";
  # Bash ends a heredoc at the FIRST line that is the delimiter. So no body line may even look
  # like one (any leading/trailing blanks): the hidden span then ends where bash ends it, or
  # earlier — never later (cold review pass 3: a lazy body ran past an early delimiter and hid
  # the lines bash runs after it). A plain << must end on the bare delimiter; <<- may indent it
  # with tabs. Anything that does not fit stays visible.
  # The START is pinned too (cold review pass 4: counting quote marks is not bash quoting). The
  # span must open a line as a plain `git commit … -m ` or `gh pr create … --body `, and NOTHING
  # between the start of the command (or the end of the last hidden span) and it may hold a quote,
  # backslash, `$`, backtick or `<` — so bash cannot be inside a quote or a heredoc when it gets
  # there. Anything that does not fit stays visible and the pre-S173 rule decides.
  my $w = qr{[^\s\x27"\\\$`#;|&<>()]+};
  my $re = qr{^((?:cd $w && )?(?:git commit(?: -[A-Za-z]+)*|gh pr create(?: --?[a-z][a-z-]*(?: $w)?)*) (?:-m|--message|--body|-b) )"\$\(\s*cat\s+<<(-?)[ \t]*([\x27"])(\w+)\3[ \t]*\n((?:(?![ \t]*\4[ \t]*\n)[^\n]*\n)*)(\t*)\4\n\s*\)"}m;
  my ($out, $rest) = ("", $_);
  while ($rest =~ $re) {
    my ($before, $all, $after, $pre, $dash, $tabs) = ($`, $&, $'"'"', $1, $2, $6);
    if ($before !~ /[\x27"\\\$`<]/ && ($dash eq "-" || $tabs eq "")) {
      $out .= $before . $pre . ($q ? "Q" : "");
    } else {
      $out .= $before . $all;       # kept visible — and it now poisons every later span
      $out .= $after; $rest = ""; last;
    }
    $rest = $after;
  }
  $_ = $out . $rest;
'; }
# ...and then ADDS what bash runs from inside quotes — every `$( … )` and backtick body, and every
# `eval` / `sh -c` string — so a push hidden there is seen. Adding text can only block MORE, never
# less, so this part cannot regress anything (it closes holes that predate S173).
vajra_scan() {
  local h; h=$(vajra_heredoc 0)
  sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g" <<<"$h"
  perl -0777 -ne '
    while (/\$\(((?:[^()]++|\((?1)\))*)\)/g) { print "\n$1" }
    while (/`([^`]*)`/g) { print "\n$1" }
    while (/(?:^|[^\w])(?:eval|(?:ba|z|da|k)?sh\s+(?:-\w+\s+)*-c)\s+(["\x27])(.*?)\1/gs) { print "\n$2" }
  ' <<<"$h"
}
SCAN=$(vajra_scan <<<"$CMD")

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
  # The allow path reads the RAW command (only the quoted-heredoc message shape removed): any `$`,
  # backtick, backslash or line break left means bash could run something the shape check cannot
  # see, so it falls back to the human (cold review pass 2: a merge rode in a PR body's `$( )`).
  RAW1=$(vajra_heredoc 1 <<<"$CMD")
  if grep -q '[$`\\]' <<<"$RAW1" || [ "$(printf '%s' "$RAW1" | wc -l | tr -d ' ')" != 0 ]; then
    RAW1=""
  fi
  QSCAN=$(sed -E "s/'[^']*'/Q/g; s/\"[^\"]*\"/Q/g" <<<"$RAW1")
  ONE=$(sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//; s/ \| (head|tail)( -n)?( -?[0-9]+)?$//; s/ 2>&1$//' <<<"$QSCAN")
  B_RE=$(printf '%s' "$BRANCH" | sed -E 's/[].[^$*+?(){}|\\/]/\\&/g')
  # A leading `cd <this project> && ` or `cd <this project>; ` (rudra's agent writes one on every
  # command) — this project only.
  ROOT_REAL=$(cd "$ROOT" 2>/dev/null && pwd -P || printf '%s' "$ROOT")
  for R in "$ROOT" "$ROOT_REAL"; do
    [ "${ONE#cd $R && }" != "$ONE" ] && ONE="${ONE#cd $R && }"
    [ "${ONE#cd $R; }" != "$ONE" ] && ONE="${ONE#cd $R; }"
  done
  SHIP_OK=""
  if [[ "$ONE" =~ ^git\ push(\ (-u|--set-upstream))?(\ origin(\ (HEAD|$B_RE))?)?$ ]]; then
    SHIP_OK=1
  # gh pr create: no shell syntax, no backslash, and either no head flag or exactly ONE, spelled
  # `--head <this branch>` / `--head=<this branch>` / `-H <this branch>` (cold review rec 4: a joined
  # `-Hsession-03-y`, a repeated `--head`, and `--he\ad` all got past the first cut).
  elif [[ "$ONE" =~ ^gh\ pr\ create(\ |$) ]] && ! grep -qE '[][;&|<>$`(){}\\]' <<<"$ONE" \
       && ! grep -qE -- '(^| )(-[A-Za-z]*R|--repo)' <<<"$ONE" \
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
