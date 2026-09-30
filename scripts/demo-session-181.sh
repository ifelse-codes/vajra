#!/usr/bin/env bash
# Session 181 demo — close the loopholes: one shared "is this a review session" answer, a strict
# session type, a human yes the agent cannot type, named waivers, and stamps tied to their text.
# Drawn with scripts/demo-kit.sh (DECISION-009/010): every claim runs live; the "before" is the
# commit S181 started from. Try it: DEMO_MODE=stream bash scripts/demo-session-181.sh (gate view)
# · bare in a terminal (deck).

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="181"
OLD_SHA=e003dd1    # the commit S181 started from — pinned, never `main`
# ========================

cargo build --release -q 2>/dev/null
NEW="$ROOT/target/release/vajra"
git show "$OLD_SHA:scripts/hook-stop.sh" > "$DK_TMP/old-stop.sh" 2>/dev/null

# a project on session branch NN whose constraints still say `ground_truth_next_session: 180`
proj() {
  local d; d="$(mktemp -d "$DK_TMP/p.XXXX")"
  ( cd "$d" && git init -q && git checkout -q -b "session-$1-x" && mkdir -p .ai sessions )
  printf 'maturity: L2\nsession:\n  ground_truth_next_session: 180\n' > "$d/.ai/CONSTRAINTS.yaml"
  echo x > "$d/sessions/session-180-ground-truth.md"
  echo "$d"
}
# stop_says HOOK NN → does that Stop hook treat session NN as a review-only session?
stop_says() {
  local d; d="$(proj "$2")"
  if CLAUDE_PROJECT_DIR="$d" bash "$1" 2>&1 | grep -q "Ground Truth Session $2"; then
    echo "session $2 -> treated as a REVIEW-ONLY session"
  else
    echo "session $2 -> treated as a normal coding session"
  fi
}
# approve_try → what `vajra approve 181` does when the agent (no terminal) types it
approve_try() {
  local d; d="$(mktemp -d "$DK_TMP/a.XXXX")"
  local out rc
  out="$(cd "$d" && "$NEW" approve 181 </dev/null 2>&1)"; rc=$?
  echo "\$ vajra approve 181   (typed by the agent — no terminal)"
  echo "  exit:  $rc"
  echo "  says:  $(head -1 <<<"$out" | cut -c1-96)"
  echo "  wrote: $(find "$d" -type f | wc -l | tr -d ' ') files"
}
# suite NAME → run one Rust test file for real; print its pass line
suite() { cargo test -q --test "$1" 2>&1 | grep -E "test result" | head -1; }

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "PARTS DONE|5|one by one"
  dk_h1 "The controls the agent could type are now " "controls it cannot" "."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: the next big review was a single hand-typed number, so the ones after it would have been skipped. \"Approved\" was a word the agent could write in the brief. One waiver switched off ~20 checks. A helper's stamp survived edits." \
    "New: the rule is \"every 5th, unless you moved one\" and it fixes itself. Approval is a record only you can write. A waiver names what it skips and why. A stamp dies if its text changes."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "Part 1.|Two small review notes from S179: the help line now says \`claude\` is the exception, and a test that could never fail now can." \
    "Part 2.|One shared answer to \"is this a review-only session?\" — six scripts each had their own copy. The override now counts only until its session is done." \
    "Part 3.|A brief names its type on one line. Missing or unknown fails the close check; nobody guesses from the prose." \
    "Part 4.|\`vajra approve NN\` — works only typed by you in your own terminal. Or set your yes at launch." \
    "Part 5.|\`VAJRA_WAIVE=<check>\` with a reason, marked launch-time or set-later; the old all-checks waiver still works, loudly. A helper's stamp is tied to its text." \
    "Review.|A cold review REJECTed the first build (downstream projects were not covered); the fixes went in and it was re-reviewed."
  dk_caption "Review-only session = every 5th, where no code is written and the project's direction is checked."
}

slide_before_after() {
  dk_section before_after "the change · the same project, before and after"
  dk_h2 "Before → After"
  dk_p "The input: a project whose settings still say \"the next review is 180\", now on session 185. Left: Vajra at $OLD_SHA. Right: today's."
  local before after
  dk_run_v bash -c "$(declare -f proj stop_says); DK_TMP='$DK_TMP'; stop_says '$DK_TMP/old-stop.sh' 185"; before="$_DK_OUT"
  dk_run_v bash -c "$(declare -f proj stop_says); DK_TMP='$DK_TMP'; stop_says '$ROOT/scripts/hook-stop.sh' 185"; after="$_DK_OUT"
  dk_compare "BEFORE|Vajra at $OLD_SHA" "$before" "AFTER|Vajra today · live" "$after"
  echo
  dk_check "before: session 185 was NOT treated as review-only (the loophole)" \
    bash -c 'printf "%s" "$1" | grep -q "normal coding session"' _ "$before"
  dk_check "after: session 185 IS review-only, with no edit to the setting" \
    bash -c 'printf "%s" "$1" | grep -q "REVIEW-ONLY"' _ "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What Vajra does now"
  dk_table "Thing|Vajra now" \
    "next review-only session|every 5th, unless you set one — the setting counts only until that session is done or passed, then it says so and rolls to the next 5th" \
    "session type|one line: session_type: CODE, DOCUMENT, GROUND_TRUTH or INTERACTIVE — missing or unknown fails the close check" \
    "your approval|a record written by \`vajra approve NN\` in your own terminal (or your yes at launch) — the words in the brief are no longer read" \
    "a waiver|VAJRA_WAIVE=<check> plus a reason; the log says launch-time or set-later" \
    "a helper's stamp|tied to the text it was written with; edit the text and it no longer verifies"
  dk_caption "Old briefs and old stamps (up to session 180, or below a project's own start session) keep working — and say so every time."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v approve_try
  dk_term "1 · the agent tries to approve its own session" "$_DK_OUT"
  dk_check "refused, and nothing written" \
    bash -c 'printf "%s" "$1" | grep -q "exit:  1" && printf "%s" "$1" | grep -q "wrote: 0 files"' _ "$_DK_OUT"
  dk_run_v suite named_waivers
  dk_term "2 · named waivers, run for real against both close gates" "$_DK_OUT"
  dk_check "one name waives one check; no reason is refused; the old waiver warns" \
    bash -c 'printf "%s" "$1" | grep -qE "ok\. 6 passed; 0 failed"' _ "$_DK_OUT"
  dk_run_v suite stamp_gate
  dk_term "3 · a helper's record is edited by hand after capture" "$_DK_OUT"
  dk_check "the fidelity and mandate gates stop trusting the edited record" \
    bash -c 'printf "%s" "$1" | grep -qE "ok\. 2 passed; 0 failed"' _ "$_DK_OUT"
  dk_run_v suite session_type_gate
  dk_term "4 · a brief with no session_type, both close gates" "$_DK_OUT"
  dk_check "it fails closed; old briefs pass with a loud dated line" \
    bash -c 'printf "%s" "$1" | grep -qE "ok\. 6 passed; 0 failed"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-181.sh — 13 real-run checks|13 / 13" \
    "the whole cargo test suite|0 failed"
  dk_verdict "HONEST NOTES" \
    "Bar-raising, not tamper-proof: an agent with a shell can strip the mark, fake a terminal, or re-record its own text through the normal command. The hooks that block its writes to the approval folder live in Vajra's own repo, not yet in scaffolded projects." \
    "A project that started before session 181 keeps the old readings until it adds \`session_rules_from: N\` to its settings; the close check prints the line to add. Upgrade never edits that file." \
    "The --allow-all record is not tied to one session and relies on the launch process being alive."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "A|session 182: put the approval hooks and the start-session setting into scaffolded projects|closes the biggest disclosed gap · risk: touches every project's upgrade path" \
    "B|OpenCode, the first non-Claude tool (F91, F94, F95)|you said one tool at a time · risk: a big design" \
    "C|finish 0.2.0: crates.io publish|a stranger gets S167–S181 · risk: founder-only steps"
  dk_table "word|meaning" \
    "review-only session|the ground-truth session — no code; checks direction" \
    "stamp|the note on a helper's record saying it really ran" \
    "waiver|your explicit skip of a close check"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
