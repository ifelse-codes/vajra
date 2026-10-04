#!/usr/bin/env bash
# Session 187 demo — the small daily annoyances: the approvals guard says how to get past a joined read
# (fix C — what blocks is unchanged), the step list names a missing approval (N4), --sync-fleet brings an
# old project its missing review questions (F97), and three leftovers only we feel (verify-133, the
# ROADMAP header, old checkouts; dogfood-age's blind spot named). Drawn with scripts/demo-kit.sh
# (DECISION-009/010): every claim runs live; the "before" is the commit S187 started from.
# Try it: DEMO_MODE=stream bash scripts/demo-session-187.sh (gate view) · bare in a terminal (deck).

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="187"
OLD_SHA=0071dca    # the commit S187 started from — pinned, never `main`
# ========================

cargo build --release -q 2>/dev/null
export PATH="$ROOT/target/release:$PATH"
# the binary as it was at $OLD_SHA (verify-session-187.sh builds the same one into the same place)
OLD_VAJRA="$ROOT/target/s187-old/release/vajra"
if [ ! -x "$OLD_VAJRA" ]; then
  . "$ROOT/scripts/lib-old-checkout.sh"
  OLD_WT=$(vajra_old_checkout "$OLD_SHA") \
    && (cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s187-old" cargo build --release -q 2>/dev/null)
  vajra_old_checkout_remove "${OLD_WT:-}"
fi
git show "$OLD_SHA:scripts/hook-approvals-guard.sh" > "$DK_TMP/old-guard.sh" 2>/dev/null

# a fresh `vajra init` project — an old one: delivery_progress and its questions taken out
P="$DK_TMP/proj"; mkdir -p "$P"
(cd "$P" && git init -q && vajra init </dev/null >/dev/null 2>&1 && echo 2 > .ai/SESSION)
python3 - "$P/.ai/CONSTRAINTS.yaml" <<'PY'
import re, sys
p = sys.argv[1]; s = open(p).read()
s = s.replace('delivery_progress, ', '', 1)
s = re.sub(r'  delivery_progress_questions:\n(    .*\n)+', '', s)
open(p, 'w').write(s)
PY
cp "$P/.ai/CONSTRAINTS.yaml" "$DK_TMP/old.yaml"

D=.ai/approvals
LIVE="git checkout -b X main && cd ~/playground/rudra && ls $D/"
# guard SCRIPT CMD → what the guard tells the agent (exit code + the how-to-get-past line)
guard() {
  local out rc
  out=$(jq -n --arg c "$2" --arg d "$P" '{tool_name:"Bash", cwd:$d, tool_input:{command:$c}}' \
    | CLAUDE_PROJECT_DIR="$P" bash "$1" 2>&1 >/dev/null); rc=$?
  if [ "$rc" = 0 ]; then echo "allowed (exit 0)"; else echo "BLOCKED (exit $rc)"
    printf '%s\n' "$out" | sed -n 2p | sed 's/^ *//' | fold -s -w 70; fi
}
# steps BIN → the approval line of `vajra next --steps` (or say there is none)
steps() { (cd "$P" && "$1" next --steps 2>&1) | grep 'approved this session' || echo "(no line about the approval)"; }
# audits FILE → the project's required_audits list
audits() { grep 'required_audits:' "$1" | sed 's/^ *//' | fold -s -w 70; }
sync_once() { (cd "$P" && "$1" init --sync-fleet 2>&1) | grep -iE 'ground-truth|comes back' | sed 's/^ *//' | fold -s -w 70; }

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "FIXES|5|guard message · N4 · F97 · verify-133 · N6 · N7 (N5 named) — N2 → S188"
  dk_h1 "Vajra tells you " "how to get past" " a block — and old projects get the new review questions."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: a harmless read joined to any write was blocked with no way out named. A missing approval hid behind the wrong step. Old projects never got the 'what did we deliver' review questions." \
    "New: the block says 'run the read as its own command'. The step list shows ✗ approval with 'vajra approve N'. --sync-fleet adds the missing review topics in their place, nothing else moves."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "Rewritten with you.|rudra waits for its data API, so S187 became the guard + the S190 leftovers. You picked fix C: what blocks stays the same, the message says how to get past." \
    "Guard message.|The block that hit me twice this session now says: run the read on its own; write commit text to a file and use git commit -F." \
    "N4 + F97.|Your approval has its own line in the step list. An old project's CONSTRAINTS.yaml gains only the missing review topics and questions." \
    "For us.|verify-133 green again (a rule moved, not a break). ROADMAP's 'Session 166' header gone. Killed test runs no longer leave copies scattered. dogfood-age says it only sees this repo." \
    "Moved.|N2 (review-only sessions writing outside the project) → S188: it loosens a guard and needs ten holes closed."
}

slide_before_after() {
  dk_section before_after "the change · the same command, before and after"
  dk_h2 "Before → After"
  dk_p "The input: the command that blocked me on 2026-10-04 — make a branch, then list rudra's approvals folder, in one line. Left: the guard at $OLD_SHA. Right: today's."
  local before after
  dk_run_v guard "$DK_TMP/old-guard.sh" "$LIVE"; before="$_DK_OUT"
  dk_run_v guard "$ROOT/scripts/hook-approvals-guard.sh" "$LIVE"; after="$_DK_OUT"
  dk_compare "BEFORE|guard at $OLD_SHA" "$before" "AFTER|guard today · live" "$after"
  echo
  dk_check "before: blocked, no way past named" bash -c 'printf "%s" "$1" | grep -q BLOCKED && ! printf "%s" "$1" | grep -q "own command"' _ "$before"
  dk_check "after: still blocked, says how to get past" bash -c 'printf "%s" "$1" | grep -q BLOCKED && printf "%s" "$1" | tr "\n" " " | grep -q "as its own"' _ "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What changed for whom"
  dk_table "Who|Before|Now" \
    "an agent blocked by the guard|blocked, guess why|blocked, told: read on its own / git commit -F" \
    "you, reading the step list|approval hidden behind 'fill the Delta'|its own line: ✗ … vajra approve N" \
    "an old project after --sync-fleet|review questions never updated|missing topics added in place; nothing else moves" \
    "a project that deleted a topic on purpose|—|it comes back (sync says so); an opt-out → S188"
  dk_caption "What the guard blocks is exactly the same as before: every command in the test list exits the same at $OLD_SHA and today."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v steps "$OLD_VAJRA"
  dk_term "1 · the step list with no approval record — vajra at $OLD_SHA" "$_DK_OUT"
  dk_check "no line about the approval" bash -c 'printf "%s" "$1" | grep -q "no line"' _ "$_DK_OUT"
  dk_run_v steps vajra
  dk_term "2 · the same, vajra today" "$_DK_OUT"
  dk_check "✗ the approval line" bash -c 'printf "%s" "$1" | grep -q "✗ the founder has approved this session"' _ "$_DK_OUT"
  dk_run_v audits "$DK_TMP/old.yaml"
  dk_term "3 · an old project's review topics (no delivery_progress)" "$_DK_OUT"
  dk_check "delivery_progress missing" bash -c '! printf "%s" "$1" | grep -q delivery_progress' _ "$_DK_OUT"
  dk_run_v sync_once vajra
  dk_term "4 · vajra init --sync-fleet, today" "$_DK_OUT"
  dk_check "adds it and says what comes back" bash -c 'printf "%s" "$1" | grep -q "delivery_progress" && printf "%s" "$1" | grep -q "comes back"' _ "$_DK_OUT"
  dk_run_v audits "$P/.ai/CONSTRAINTS.yaml"
  dk_term "5 · the topics after: in its place, the rest unchanged" "$_DK_OUT"
  dk_check "after roadmap_alignment" bash -c 'printf "%s" "$1" | tr -d "\n" | grep -q "roadmap_alignment, delivery_progress, state_drift"' _ "$_DK_OUT"
  dk_run_v bash -c 'vajra next --dogfood-age 2>&1 | sed -n 2p | sed "s/^ *//" | fold -s -w 70'
  dk_term "6 · dogfood-age names its blind spot (named, not closed)" "$_DK_OUT"
  dk_check "THIS repo only" bash -c 'printf "%s" "$1" | grep -q "THIS repo only"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-187.sh — real-run checks; each fix is run at $OLD_SHA too|see the summary" \
    "scripts/verify-session-133.sh — red since S181|15 / 15 green"
  dk_verdict "HONEST NOTES" \
    "F110 is NOT fixed: the guard still blocks a harmless read joined to a write. It now says how to get past — that is all fix C does." \
    "N5 is named, not closed: dogfood-age still cannot see rudra's runs; it now says so."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "1|N2: review-only sessions may write outside the project|the design is ready (10 holes named) · risk: it is a guard that lets more through" \
    "2|F67: the receipt reads the tool's own cost|the one wrong number every user sees (~5× high) · risk: Claude Code may not expose it" \
    "3|the non-Claude tools brainstorm (F91, F94, F95)|promised since S179 · risk: a design session, nothing a user runs yet"
  dk_table "word|meaning" \
    "--sync-fleet|the command that brings an existing project up to today's Vajra" \
    "review topics|the audits a review-only (ground-truth) session must answer" \
    "named, not closed|the problem is now said out loud, but not fixed"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
