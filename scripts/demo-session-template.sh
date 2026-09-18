#!/usr/bin/env bash
# Template — copy to scripts/demo-session-NN.sh, then fill in every section.
# `vajra init` scaffolds this file and `vajra init --sync-fleet` upgrades it: edit your COPY.
#
# THE TERMINAL DEMO IS THE HUMAN DEMO (DECISION-009). Whoever watches runs this script in a
# terminal and sees a slide deck (← → / space · a autoplay · q quit). The Demo-er gate (S71)
# re-runs the SAME script at close (`vajra next --check-demo NN`) and blocks on a non-zero exit
# or a missing `demo:<element>` marker: header · cases · summary_table · before_after.
# There is no separate HTML deck to make — this script is the demo.
#
# A DEMO THAT CANNOT BE FAKED (DECISION-010). Because this demo is built on the kit, the gate also
# requires `demo:complete` (dk_finish prints it only when the whole outline passed) and compares
# every `demo:fact` line with the facts Vajra derives at close — so:
#   - dk_check runs a COMMAND and its real exit code decides: dk_check "label" test -f out.txt
#     (a bare PASS / FAIL / 0 is refused by name and fails the demo);
#   - the numbers Vajra knows (stations, review, advice answered, crew) are filled in by Vajra:
#     dk_vajra_tiles "$SESSION" and dk_vajra_scorecard "$SESSION" — never type them by hand.
#
# The outline — seven sections, one slide each, drawn with scripts/demo-kit.sh:
#   1 headline      what shipped · Vajra-filled tiles · the change in one breath → demo:header
#   2 story         what happened this session, in plain words
#   3 before_after  the SAME input through the old and the new, both live    → demo:before_after
#   4 rule          the new rule or behaviour, in plain words
#   5 cases         ordinary and odd inputs, each run live and checked       → demo:cases
#   6 scorecard     Vajra's facts · live checks · recorded numbers · honest
#                   notes · what this demo does NOT show                     → demo:summary_table
#   7 next          what comes next + a small-words helper
# `dk_section` prints each marker where its section really renders. Each `dk_todo` is a
# placeholder that FAILS the demo by name — replace it with the real thing. dk_finish also fails
# when a section never rendered, when no live check ran, or when a live check failed or was refused.
#
# Rules for a demo that shows something:
#   - A panel that claims a result runs the real command: dk_run_v · dk_term · dk_check.
#   - The before is REAL: run the old code out of git (git show <sha>:<path> > "$DK_TMP/old"),
#     or say plainly the capability did not exist. Never echo a hand-written "before".
#   - A number not re-run here is labelled "recorded", never "live".
#   - Demos are cumulative: keep showing what earlier sessions built while it still matters.
# Try it: DEMO_MODE=stream bash scripts/demo-session-NN.sh shows the gate's view; run it bare in a
# terminal for the deck (DEMO_THEME=light on a white background). Kit reference: the header of
# scripts/demo-kit.sh.

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="NN"
# ========================

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION"
  dk_todo headline "One line on what this session delivered (dk_h1 \"The gate now \" \"blocks\" \" a fake step.\") and the change in one breath (dk_verdict \"WHAT CHANGED, IN ONE BREATH\" \"Old: …\" \"New: …\"). The tiles above are filled in by Vajra; add your own live tiles after the session: dk_vajra_tiles \"\$SESSION\" \"CASES|4|of 4 · live\"."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_todo story "Three to five plain-words bullets: why this work, what changed, what was proven (dk_bullets \"Lead words.|the rest\" …). Add a dk_caption for any word a newcomer would not know."
}

slide_before_after() {
  dk_section before_after "the change · two real runs · same input"
  dk_h2 "Before → After"
  dk_todo before_after "Run the SAME input through the old code and the new, both live. Old code out of git: git show <sha>:<path> > \"\$DK_TMP/old.sh\" — <sha> is the commit this session STARTED from (write the real sha in; never `main`: after the merge main IS the new code, and the demo flips red). Then dk_run_v <old>; before=\"\$_DK_OUT\"; brc=\$_DK_RC; dk_run_v <new>; dk_compare \"BEFORE|at <sha> · exit \$brc\" \"\$before\" \"AFTER|today · exit \$_DK_RC\" \"\$_DK_OUT\"; then check the difference with a command: dk_check \"old passed, new blocks\" test \"\$brc\" = 0."
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What happens now"
  dk_todo rule "The new rule or behaviour in plain words, best as a table where each row is a real run: dk_table \"The input|What happens|Why\" \"row|✓ passes|reason\" …"
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_todo cases "Ordinary and odd inputs, each run live and shown: dk_run_v <cmd>; dk_term \"1 · what this case shows\" \"\$_DK_OUT\"; then dk_check \"what it proves\" <a command that fails if it is not true> (e.g. grep -q 'blocked' out.txt). Include at least one case that would fail if the work were reverted."
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_todo scorecard "A table of numbers measured elsewhere, labelled recorded (dk_table \"Recorded at close — not re-run here|Result\" …), and dk_verdict \"HONEST NOTES\" naming the fakest green and what this demo does NOT show."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_todo next "The next options in one table (dk_table \" |Option|Why pick it · the risk\" …), then a small-words helper: dk_table \"word|meaning\" for every term a newcomer would trip on."
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
