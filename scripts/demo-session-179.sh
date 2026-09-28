#!/usr/bin/env bash
# Session 179 demo — F89 (`vajra <cmd> --help` ran the command), F90 (`init` ignored words it did
# not know), F93 (a project's ground truth asked about the tool, not the project). Drawn with
# scripts/demo-kit.sh (DECISION-009/010): every claim runs live in a fresh temp repo; the "before"
# is Vajra built from the pinned commit this session started from. Try it:
# DEMO_MODE=stream bash scripts/demo-session-179.sh (gate view) · bare in a terminal (deck).

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="179"
OLD_SHA=224b349    # the commit S179 started from — pinned, never `main` (after the merge main IS new)
RUDRA="${RUDRA:-/Users/suman/playground/rudra}"
# ========================

cargo build --release -q 2>/dev/null
NEW="$ROOT/target/release/vajra"
OLD="${OLD_VAJRA:-$ROOT/target/s179-old/release/vajra}"
if [ ! -x "$OLD" ]; then
  git worktree add -q --detach "$DK_TMP/old" "$OLD_SHA" 2>/dev/null
  ( cd "$DK_TMP/old" && CARGO_TARGET_DIR="$ROOT/target/s179-old" cargo build --release -q 2>/dev/null )
  git worktree remove --force "$DK_TMP/old" >/dev/null 2>&1
fi

# fresh → a new empty git repo (what a stranger types their first command in)
fresh() { local d; d="$(mktemp -d "$DK_TMP/r.XXXX")"; ( cd "$d" && git init -q && git -c user.name=t -c user.email=t@t commit -q --allow-empty -m x ); echo "$d"; }
# try BIN ARGS... → run it in a fresh repo; print its first line, its exit, and what it wrote
try() {
  local b="$1"; shift; local d out rc n
  d="$(fresh)"; out="$(cd "$d" && "$b" "$@" </dev/null 2>&1)"; rc=$?
  n="$(cd "$d" && git status --porcelain | wc -l | tr -d ' ')"
  echo "\$ vajra $*"
  echo "  says:  $(head -1 <<<"$out" | cut -c1-90)"
  echo "  exit:  $rc"
  echo "  wrote: $n files into the repo"
}
# audits BIN → the review questions a brand-new project gets from `vajra init`
audits() {
  local d; d="$(fresh)"; ( cd "$d" && "$1" init </dev/null >/dev/null 2>&1 )
  sed -n 's/^  required_audits: \[\(.*\)\]$/\1/p' "$d/.ai/CONSTRAINTS.yaml" | tr ',' '\n' | sed 's/^ */  /' | nl -w2 -s'. '
}

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "RUDRA RUNS READ|2|S14 + S15 · OpenCode"
  dk_h1 "Asking for help no longer " "changes your project" "."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: \`vajra init --help\` set up a whole project (11 files). \`vajra init --dry-run\` did too. And a project's big review asked mostly about Vajra, never whether the project was on track." \
    "New: every \`--help\` prints help and touches nothing; \`init\` refuses a word it doesn't know; a project's review asks first what the project delivered and whether it's on track."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "F89.|Found after S178: \`vajra init --help\` ran a real setup. In Vajra's own repo it doubled every guard. rudra's agent also hit it live — it ran \`vajra next --help\` twice and got the full session report." \
    "F90.|Found while checking F89: \`init\` ignored words it didn't know, so a preview flag did the real thing." \
    "rudra S14 + S15 (OpenCode).|Close runs fell from ~30 to ~5 — S178's message fix worked. Six new findings; the ones about non-Claude tools are parked until after session 180." \
    "F93.|rudra's first big review (S15) audited Vajra's paperwork, not rudra. The founder caught it. Cause: Vajra handed the project its own checklist." \
    "S178's record corrected.|It blamed 'something else' for stray files; S178's own \`init --help\` wrote them."
  dk_caption "Big review = the ground-truth session, every 5th session, where no code is written and the project's direction is checked."
}

slide_before_after() {
  dk_section before_after "the change · the same command, a brand-new empty project"
  dk_h2 "Before → After"
  dk_p "The input: \`vajra init --help\` in a fresh, empty git repo. Left: Vajra at $OLD_SHA. Right: today's."
  local before after
  dk_run_v try "$OLD" init --help; before="$_DK_OUT"
  dk_run_v try "$NEW" init --help; after="$_DK_OUT"
  dk_compare "BEFORE|Vajra at $OLD_SHA" "$before" "AFTER|Vajra today · live" "$after"
  echo
  dk_check "before: asking for help wrote files into the project" \
    bash -c 'printf "%s" "$1" | grep -qE "wrote: [1-9][0-9]* files"' _ "$before"
  dk_check "after: help is printed and nothing is written" \
    bash -c 'printf "%s" "$1" | grep -q "wrote: 0 files" && printf "%s" "$1" | grep -q "vajra init —"' _ "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What Vajra does now"
  dk_table "You type|Vajra now" \
    "vajra <command> --help (or -h)|prints that command's help, changes nothing — for init, check, next, estimate, hook, meter" \
    "vajra claude --help|unchanged: passed to Claude Code, which shows its own help" \
    "vajra init <a word it doesn't know>|refuses, says 'nothing was written', and names the right command when there is one" \
    "vajra init (new project)|the big review's first three questions are about the project: vision, roadmap, and what was delivered"
  dk_caption "Checked old vs new on 35 live runs (scripts/verify-session-179.sh)."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v try "$NEW" init --dry-run
  dk_term "1 · the preview flag without --sync-fleet" "$_DK_OUT"
  dk_check "refused, nothing written, points at the right command" \
    bash -c 'printf "%s" "$1" | grep -q "wrote: 0 files" && printf "%s" "$1" | grep -q "exit:  1"' _ "$_DK_OUT"

  local o n
  dk_run_v audits "$OLD"; o="$_DK_OUT"
  dk_run_v audits "$NEW"; n="$_DK_OUT"
  dk_compare "BEFORE|review questions a new project got" "$o" "AFTER|today · live" "$n"
  dk_check "before: Vajra's own usage questions were handed to the project" \
    bash -c 'printf "%s" "$1" | grep -q "dogfood_check"' _ "$o"
  dk_check "after: the project's delivery is the third question; Vajra's usage questions are gone" \
    bash -c 'printf "%s" "$1" | grep -qE "^ ?3\. +delivery_progress" && ! printf "%s" "$1" | grep -q dogfood' _ "$n"

  if [ -f "$RUDRA/.ai/CONSTRAINTS.yaml" ]; then
    dk_run_v bash -c "grep -m1 -A1 '^  delivery_progress_questions:' '$RUDRA/.ai/CONSTRAINTS.yaml' | cut -c1-120"
    dk_term "3 · rudra's checklist (updated by hand, founder yes)" "$_DK_OUT"
    dk_check "rudra's next big review asks what rudra delivered" \
      bash -c 'printf "%s" "$1" | grep -q "What did this project actually deliver"' _ "$_DK_OUT"
  fi
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "old vs new, 35 live runs — verify-session-179.sh|35 / 35" \
    "command-line tests (tests/cli_front_door.rs)|9 / 9" \
    "lib tests (cargo test --lib)|551 / 551"
  dk_verdict "HONEST NOTES" \
    "Other projects that already use Vajra do NOT get the new review questions — the upgrade command never touches that file (F97). rudra got them by hand." \
    "A stranger gets F89/F90/F93 only after the next crates.io release; the founder's own vajra needs a rebuild." \
    "The findings about other coding tools (the agent committing and pushing to main unchecked under OpenCode, the waiver labelled 'founder' for a session he didn't waive) are parked until after session 180."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "A|session 180: the big review (no code), Goal 0 first|already booked; the founder's controls the agent can type · risk: a design session, no code" \
    "B|after 180: brainstorm Vajra on other coding tools (F91, F94, F95)|OpenCode ran 2 sessions with the guards blind · risk: a big design" \
    "C|finish 0.2.0: crates.io publish|a stranger gets S167–S179 · risk: founder-only steps"
  dk_table "word|meaning" \
    "big review|the ground-truth session — no code; checks direction" \
    "scaffold|the files \`vajra init\` writes into a new project" \
    "upgrade command|vajra init --sync-fleet — copies Vajra's newest roles and hooks into a project"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
