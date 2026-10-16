#!/usr/bin/env bash
# Session 199 demo — every pending known bug: F126, the review-only sign-off step, N19, N20, N21, N14, `latest`,
# gt_cadence_shared, the rest of N7.
# A terminal deck (DECISION-009): run it bare in a terminal; piped it prints every slide + the markers.
# Every check runs the REAL `vajra` on a `vajra init` project — today's, and the one at the commit S199 started
# from (027e70f).
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="199"
OLD_SHA=027e70f    # the commit S199 started from — pinned, never `main`
# ========================

NEW="$ROOT/target/release/vajra"; OLD="$ROOT/target/s199-old/release/vajra"
cargo build --release -q || { echo "demo: cargo build failed" >&2; exit 1; }
if [ ! -x "$OLD" ]; then
  . "$ROOT/scripts/lib-old-checkout.sh"
  WT=$(vajra_old_checkout "$OLD_SHA") || exit 1
  (cd "$WT" && CARGO_TARGET_DIR="$ROOT/target/s199-old" cargo build --release -q) || exit 1
  vajra_old_checkout_remove "$WT"
fi

W="$ROOT/target/s199-demo-$$"; rm -rf "$W"; mkdir -p "$W"; trap 'rm -rf "$W"' EXIT
human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            -u VAJRA_AGENT_MARK -u CLAUDE_PROJECT_DIR GIT_CONFIG_GLOBAL=/dev/null "$@"; }
# project <bin> → a `vajra init` project at L1, session 06 finished, session 07's prompt ready, on its branch.
project() {
  local p="$W/p$RANDOM$RANDOM"; mkdir -p "$p"
  (cd "$p" && human git init -q -b main && human "$1" init </dev/null >/dev/null 2>&1 \
     && perl -pi -e 's/^maturity: L2/maturity: L1/' .ai/CONSTRAINTS.yaml && echo 06 > .ai/SESSION \
     && perl -pi -e 's/\*\*Number:\*\* \d+/**Number:** 06/' .ai/SESSION-BOOT.md \
     && cp prompts/01-task-kickoff.md prompts/07-task-next.md && human git checkout -qb session-07-next)
  printf '%s' "$p"
}
# two_prompts <bin> → what `vajra next --advance` says, and the session number after, with two session-07 prompts.
two_prompts() {
  local p; p=$(project "$1"); cp "$p/prompts/07-task-next.md" "$p/prompts/07-task-another.md"
  local out; out=$(cd "$p" && human "$1" next --advance </dev/null 2>&1 | grep -E 'refusing|Advanced|prompt pointer' | fold -w 80)
  printf '%s\n.ai/SESSION is now: %s' "$out" "$(cat "$p/.ai/SESSION")"
}

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "KNOWN BUGS|9 fixed|F126 · sign-off · N19 · N20 · N21 · N14 · latest · test · N7"
  dk_h1 "The known-bug list " "is empty" " before the next review."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Nine small bugs a user could meet: a late change from you had no place to go, the review-only session never said how it ends, Windows line endings got lost, old notes got rewritten, and two plan files for one session were picked at random." \
    "Each now has a fix you can see run, and a check that fails without it."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "F126: a real test first.|Your late change (a new next step, the summary, the notes) does NOT undo the review sign-off; only this session's own plan, a specialist note or code does. The step list now says so." \
    "Review-only sessions say how they end.|The list shows a step: you type 'vajra approve NN --close'. It ticks once you have." \
    "Starting a session is gentler.|Windows line endings stay; old history entries are never rewritten; two plan files for one session stop it, naming both." \
    "Three tidy-ups.|A new review question (did the agent report the close truthfully?), a broken 'latest' folder fixed (your yes), eight old scripts share one helper."
  dk_caption "Review-only = the every-5th session that writes no code, only a report you sign off."
}

slide_before_after() {
  dk_section before_after "the change · the same commit, before and after"
  dk_h2 "Before → After"
  dk_p "A project with TWO plan files for session 07. We start session 07 with 'vajra next --advance'. Left: vajra at $OLD_SHA. Right: today's."
  local b a
  b=$(two_prompts "$OLD"); a=$(two_prompts "$NEW")
  dk_compare "BEFORE|vajra at $OLD_SHA" "$b" "AFTER|vajra today · live" "$a"
  echo
  dk_check "before: it advanced, on whichever file the disk listed first" bash -c 'printf "%s" "$1" | grep -q "SESSION is now: 07"' _ "$b"
  dk_check "after: it refuses, names both files, and changes nothing" bash -c 'printf "%s" "$1" | tr -d "\n" | grep -q "07-task-another.md, prompts/07-task-next.md" && printf "%s" "$1" | grep -q "SESSION is now: 06"' _ "$a"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "A late change from you, after the review is signed"
  dk_table "You change…|Review sign-off|What to do" \
    "the next session's plan|stays|commit it, run the close check once more" \
    "the summary, or the notes (STATE, TASK, ROADMAP)|stays|commit it, run the close check once more" \
    "this session's own plan, a specialist note, or code|moves|stamp again, then the close check"
  dk_caption "Found by a real run (stamp, edit, stamp again). The push still needs a green close for the exact commit."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  local p a
  p="$W/gt"; mkdir -p "$p"
  (cd "$p" && human git init -q -b main && human "$NEW" init </dev/null >/dev/null 2>&1 && echo 09 > .ai/SESSION \
     && cp prompts/01-task-kickoff.md prompts/10-task-review.md && human git checkout -qb session-10-review)
  a=$(cd "$p" && human "$NEW" next --steps 10 2>&1 | grep 'signed off' | head -1 | fold -w 90)
  dk_term "1 · a review-only session (10) — the step list" "$a"
  dk_check "it shows the founder's sign-off step, not yet done" bash -c 'printf "%s" "$1" | grep -q "✗ the founder has signed off"' _ "$a"

  p=$(project "$NEW"); perl -pi -e 's/\n/\r\n/' "$p/.ai/SESSION-BOOT.md"
  (cd "$p" && human "$NEW" next --advance </dev/null >/dev/null 2>&1)
  local crlf total
  crlf=$(grep -c $'\r$' "$p/.ai/SESSION-BOOT.md"); total=$(wc -l < "$p/.ai/SESSION-BOOT.md" | tr -d ' ')
  a="$crlf of $total lines end in CRLF (Windows) after the advance"
  dk_term "2 · a Windows-edited notes file, after starting session 07" "$a"
  dk_check "every line kept its Windows ending" test "$crlf" = "$total"

  p=$(project "$NEW")
  a=$(grep -A1 'constraint_violation_questions' "$p/.ai/CONSTRAINTS.yaml" | cut -c1-140 | fold -w 90)
  dk_term "3 · a fresh 'vajra init' — the new review question" "$a"
  dk_check "the question reads the close result" grep -qF 'closeout/<stamp>/result' "$p/.ai/CONSTRAINTS.yaml"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-199.sh (9 rows; red at $OLD_SHA)|see the summary" \
    "the full cargo test · CI's lint|see the summary"
  dk_verdict "HONEST NOTES" \
    "verify-session-178 was already red on main (old wording checks) — filed as N22, not fixed. rudra gets the new review question only after its next 'vajra init --sync-fleet'." \
    "F126 needed no new rule: it is words in the step list, backed by the real stamp test."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next — 3 ranked options (the same as the summary)"
  dk_table " |Option|Why pick it · the risk" \
    "1|S200 — the review-only session (due by the every-5th rule)|it is the rule; first use of the close-truth question · risk: none, no code" \
    "2|after S200: rudra S22, synced|the push belt, the review-only guard and today's steps on a real project · risk: long and paid" \
    "3|after S200: the README 'tested with' line, then the boot diet|tells a user which models Vajra was tried on; cheaper sessions · risk: words must be yours"
  dk_table "word|meaning" \
    "session|one unit of work, with its own branch, notes and review" \
    "stamp|the review's fingerprint of the finished work; editing the work moves it" \
    "close check|the script that must say GREEN before the agent may push"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
