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
# The outline — seven sections, one slide each, drawn with scripts/demo-kit.sh:
#   1 headline      what shipped · number tiles · the change in one breath   → demo:header
#   2 story         what happened this session, in plain words
#   3 before_after  the SAME input through the old and the new, both live    → demo:before_after
#   4 rule          the new rule or behaviour, in plain words
#   5 cases         ordinary and odd inputs, each run live and checked       → demo:cases
#   6 scorecard     live checks vs recorded numbers · honest notes · what
#                   this demo does NOT show                                  → demo:summary_table
#   7 next          what comes next + a small-words helper
# `dk_section` prints each marker where its section really renders. Each `dk_todo` is a
# placeholder that FAILS the demo by name — replace it with the real thing. dk_finish also fails
# when a section never rendered, when no live check ran, or when a live check failed.
#
# Rules for a demo that shows something:
#   - A panel that claims a result runs the real command: dk_run_v · dk_term · dk_check.
#   - The before is REAL: run the old code out of git (git show <sha>:<path> > "$DK_TMP/old"),
#     or say plainly the capability did not exist. Never echo a hand-written "before".
#   - A number not re-run here is labelled "recorded", never "live".
#   - Demos are cumulative: keep showing what earlier sessions built while it still matters.
# Try it: DEMO_MODE=stream bash scripts/demo-session-NN.sh shows the gate's view; run it bare in a
# terminal for the deck. Kit reference: the header of scripts/demo-kit.sh.

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
  dk_todo headline "One line on what this session delivered (dk_h1 \"The gate now \" \"blocks\" \" a fake step.\"), number tiles that say live or recorded (dk_metrics \"CHECKS|9|of 9 · live\" \"TESTS|487|recorded\"), and the change in one breath (dk_verdict \"WHAT CHANGED, IN ONE BREATH\" \"Old: …\" \"New: …\")."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_todo story "Three to five plain-words bullets: why this work, what changed, what was proven (dk_bullets \"Lead words.|the rest\" …). Add a dk_caption for any word a newcomer would not know."
}

slide_before_after() {
  dk_section before_after "the change · two real runs · same input"
  dk_h2 "Before → After"
  dk_todo before_after "Run the SAME input through the old code and the new, both live. Old code out of git: git show <sha>:<path> > \"\$DK_TMP/old.sh\". Then dk_run_v <old>; before=\"\$_DK_OUT\"; dk_run_v <new>; dk_compare \"BEFORE|at <sha> · exit N\" \"\$before\" \"AFTER|today · exit N\" \"\$_DK_OUT\"; and dk_check the difference you expect."
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What happens now"
  dk_todo rule "The new rule or behaviour in plain words, best as a table where each row is a real run: dk_table \"The input|What happens|Why\" \"row|✓ passes|reason\" …"
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_todo cases "Ordinary and odd inputs, each run live and shown: dk_run_v <cmd>; dk_term \"1 · what this case shows\" \"\$_DK_OUT\"; dk_check \"what it proves\" \$_DK_RC. Include at least one case that would fail if the work were reverted."
}

slide_scorecard() {
  dk_section scorecard "proof · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_todo scorecard "dk_scorecard \"LIVE — ran while you watched\" lists every dk_check. Then a table of numbers measured elsewhere, labelled recorded (dk_table \"Recorded at close — not re-run here|Result\" …), and dk_verdict \"HONEST NOTES\" naming the fakest green and what this demo does NOT show."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_todo next "The next options in one table (dk_table \" |Option|Why pick it · the risk\" …), then a small-words helper: dk_table \"word|meaning\" for every term a newcomer would trip on."
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
