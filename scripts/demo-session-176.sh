#!/usr/bin/env bash
# Session 176 demo — F70: a plan citing acceptance items the prompt no longer has used to pass the
# Planner. Drawn with scripts/demo-kit.sh (DECISION-009/010): every claim below runs live, the
# "before" is the real Planner compiled from the pinned commit this session started from (cd4302b).
# Try it: DEMO_MODE=stream bash scripts/demo-session-176.sh (gate view) · bare in a terminal (deck).

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="176"
OLD_SHA=cd4302b    # the commit S176 started from — pinned, never `main` (after the merge main IS new)
# ========================

# The two Planners: today's build, and the one from $OLD_SHA (built once, cached under target/).
cargo build --release -q 2>/dev/null
NEW="$ROOT/target/release/vajra"
OLD="$ROOT/target/verify-176-old/release/vajra"
if [ ! -x "$OLD" ]; then
  git worktree add -q --detach "$DK_TMP/old" "$OLD_SHA" >/dev/null 2>&1
  ( cd "$DK_TMP/old" && CARGO_TARGET_DIR="$ROOT/target/verify-176-old" cargo build --release -q 2>/dev/null )
  git worktree remove --force "$DK_TMP/old" >/dev/null 2>&1
fi
proj() { local P="$DK_TMP/p$RANDOM$RANDOM"; mkdir -p "$P/prompts" "$P/.ai"; cp "$2" "$P/prompts/$1-task-x.md"; printf '%s' "$P"; }
plan() { ( cd "$1" && "$2" next --check-plan "$3" 2>&1 ); }
WIPED=$(proj 08 tests/fixtures/f70-rudra-s08-wiped.md)

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "RUDRA RUNS|2|S07 + S08 · real"
  dk_h1 "The plan check now " "refuses" " a plan whose brief was cut."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: rudra S08's agent deleted 5 sections of its own approved brief; the plan check said READY." \
    "New: the same brief → NOT READY, naming the 7 missing items and how to restore them from git."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "Two real rudra runs.|The founder ran rudra sessions 07 and 08 under Vajra. S07 had nothing to fix, so this session stayed open for S08 (his pick)." \
    "What held.|The agent could not merge even when told to (S175's fix, live). Tech-lead first, 7th and 8th time. Every handoff committed. Close check 21/21 before each PR." \
    "What broke.|In S08 the agent's own edit wiped Deliverables, Acceptance, Guardrails, Delta, Assumptions from its brief. It noticed itself, 7 minutes later. Vajra's plan check would have said READY." \
    "What we fixed.|A plan that points at acceptance items the brief does not have is now NOT READY." \
    "What the fix found.|Checking every old brief turned up 11 written as tables the check never read — 12 sessions it quietly waved through. It reads them now; 3 old plans really were wrong."
  dk_caption "Plan check = \`vajra next --check-plan\`: does every acceptance item have a plan step pointing at it (\`covers: N\`)?"
}

slide_before_after() {
  dk_section before_after "the change · two real runs · the same input"
  dk_h2 "Before → After"
  dk_p "The input: rudra session 08's final brief with the five sections its agent deleted, re-created. Left: the plan check at $OLD_SHA. Right: today's."
  local before after brc arc
  dk_run_v plan "$WIPED" "$OLD" 8; brc=$_DK_RC
  before="exit $brc
$(printf '%s\n' "$_DK_OUT" | grep -E '^verdict|✗' | cut -c1-46)"
  dk_run_v plan "$WIPED" "$NEW" 8; arc=$_DK_RC
  after="exit $arc
$(printf '%s\n' "$_DK_OUT" | grep -E '^verdict' )
$(printf '%s\n' "$_DK_OUT" | grep '✗' | cut -c1-140 | fold -w 46)"
  dk_compare "BEFORE|plan check at $OLD_SHA" "$before" "AFTER|plan check today · live" "$after"
  echo
  dk_check "before: the wiped brief passed (READY, exit 0 — the bug)" bash -c '[ "$1" = 0 ]' _ "$brc"
  dk_check "after: the same brief is NOT READY (exit 1)" bash -c '[ "$1" = 1 ]' _ "$arc"
  dk_check "and it names the 7 items the plan cites but the brief lost" \
    bash -c 'plan() { ( cd "$1" && "$2" next --check-plan 8 2>&1 ); }; plan "$1" "$2" | grep -q "cites acceptance item(s) 1, 2, 3, 4, 5, 6, 7"' _ "$WIPED" "$NEW"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What happens now"
  dk_table "The brief|The plan check says|Why" \
    "Acceptance deleted, plan still cites 1–7|✗ NOT READY|the plan points at items that are gone" \
    "Acceptance cut to 1–3, plan cites 4, 5|✗ NOT READY|same — names 4, 5" \
    "Plan misses an item AND cites a gone one|✗ names the gone one first|the list itself is the problem" \
    "Acceptance written as an AC1-table|reads it now|11 old briefs used that shape" \
    "No acceptance, plan cites nothing|✓ READY, as before|nothing changed here (adds only)"
  dk_caption "The message names the cause it sees: the section is gone, the list was cut, or its items are not numbered."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  local cut; cut="$DK_TMP/cut.md"
  printf '# S\n## Acceptance\n1. x\n2. y\n3. z\n## Plan\n1. a — covers: 1, 2, 3\n2. b — covers: 4, 5\n' > "$cut"
  local P; P=$(proj 21 "$cut")
  dk_run_v plan "$P" "$NEW" 21
  dk_term "1 · list cut short: plan cites 4, 5 past item 3" "$(printf '%s\n' "$_DK_OUT" | grep -E 'verdict|✗' | cut -c1-120)"
  dk_check "a cut list is NOT READY and names 4, 5" bash -c 'printf "%s" "$1" | grep -q "cites acceptance item(s) 4, 5"' _ "$_DK_OUT"

  local none; none="$DK_TMP/none.md"
  printf '# S\n## Goal\ng\n## Plan\n1. do a real thing\n' > "$none"
  P=$(proj 22 "$none")
  dk_run_v plan "$P" "$NEW" 22
  dk_term "2 · no acceptance list, plan cites nothing (old rule kept)" "$(printf '%s\n' "$_DK_OUT" | grep -E 'verdict')"
  dk_check "no list + no citations is still READY (nothing loosened, nothing new blocked)" \
    bash -c 'printf "%s" "$1" | grep -q "verdict: READY"' _ "$_DK_OUT"

  dk_run_v plan "$ROOT" "$NEW" 166
  dk_term "3 · a real old brief (S166) written as an AC1-table" "$(printf '%s\n' "$_DK_OUT" | grep -E 'verdict|✗' | cut -c1-120)"
  dk_check "the table is read now: S166's plan really never covered AC1" \
    bash -c 'printf "%s" "$1" | grep -q "criterion(s) 1 "' _ "$_DK_OUT"

  ( cd "$WIPED" && "$NEW" next --stations 8 > "$DK_TMP/st.txt" 2>&1 )
  dk_term "4 · the stations counter on the wiped brief" "$(grep -i 'planner' "$DK_TMP/st.txt" | cut -c1-120)"
  dk_check "the counter shows the Planner not passed" grep -q "\[ABSENT\] Planner.*plan cites missing criteria" "$DK_TMP/st.txt"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "old vs new over every brief (verify-session-176.sh)|173 Vajra session numbers + 10 rudra · 3 flips, all real (155 157 166)" \
    "planner unit tests|26 / 26" \
    "all tests (cargo test)|594 / 594"
  dk_verdict "HONEST NOTES" \
    "Fakest green: an edit that ALSO deletes the covers: markers, or the whole ## Plan, still passes — same known limit as S68." \
    "Nothing at close re-runs the plan check. A wipe is caught only if someone runs --check-plan or --steps (a close re-run needs the founder's yes)." \
    "3 old closed sessions (155, 157, 166) now read NOT READY — history, not reopened." \
    "Not shown: the receipt still overstates Opus 5.5 ~5× (F67, parked for a permanent fix)."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "A|rudra session 09 under Vajra|the test that keeps finding real bugs · risk: finds nothing (then fold into S178)" \
    "B|F67 for good: read the cost from Claude Code itself|ends the wrong-money receipt for every model · risk: interactive runs may not expose it" \
    "C|finish 0.2.0: crates.io publish + brew smoke|a stranger gets S167–S176 · risk: founder-only steps"
  dk_table "word|meaning" \
    "brief|the session's prompt file — what the human approved" \
    "acceptance item|one checkable 'done means…' line in the brief" \
    "covers: N|a plan step saying which acceptance item it delivers" \
    "plan check|vajra next --check-plan — every item has a step, every step's item exists"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
