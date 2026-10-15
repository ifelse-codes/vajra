#!/usr/bin/env bash
# Session 198 demo — the known-bug leftovers: F118 (`vajra next --advance` moves the old Current Session entry
# down to Prior Session) and N18 (the drift check picks its last 10 verify scripts by number, from any folder).
# A terminal deck (DECISION-009): run it bare in a terminal; piped it prints every slide + the markers.
# Every check runs the REAL `vajra next --advance` on a `vajra init` project and the REAL scaffold-drift script —
# today's, and the one at the commit S198 started from (2830bb2).
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="198"
OLD_SHA=2830bb2    # the commit S198 started from — pinned, never `main`
# ========================

NEW="$ROOT/target/release/vajra"; OLD="$ROOT/target/s198-old/release/vajra"
cargo build --release -q || { echo "demo: cargo build failed" >&2; exit 1; }
. "$ROOT/scripts/lib-old-checkout.sh"
OWT=$(vajra_old_checkout "$OLD_SHA") || exit 1
if [ ! -x "$OLD" ]; then
  (cd "$OWT" && CARGO_TARGET_DIR="$ROOT/target/s198-old" cargo build --release -q) || exit 1
fi

W="$ROOT/target/s198-demo-$$"; rm -rf "$W"; mkdir -p "$W"
trap 'vajra_old_checkout_remove "$OWT"; [ -n "${WD:-}" ] && git worktree remove --force "$WD" >/dev/null 2>&1; rm -rf "$W"' EXIT
human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            -u VAJRA_AGENT_MARK -u CLAUDE_PROJECT_DIR GIT_CONFIG_GLOBAL=/dev/null "$@"; }
# project <bin> → a `vajra init` project at L1, session 06 finished, session 07's prompt ready, on its branch.
project() {
  local p="$W/p$RANDOM"; mkdir -p "$p"
  (cd "$p" && human git init -q -b main && human "$1" init </dev/null >/dev/null 2>&1 \
     && perl -pi -e 's/^maturity: L2/maturity: L1/' .ai/CONSTRAINTS.yaml && echo 06 > .ai/SESSION \
     && perl -pi -e 's/\*\*Number:\*\* \d+/**Number:** 06/' .ai/SESSION-BOOT.md \
     && cp prompts/01-task-kickoff.md prompts/07-task-next.md && human git checkout -qb session-07-next)
  printf '%s' "$p"
}
# boot_after <bin> → the Current/Prior part of a Vajra-shaped SESSION-BOOT after that vajra's `--advance`.
boot_after() {
  local p; p=$(project "$1")
  printf '# Session Boot\n\n## Current Session\n- **Number:** 06 — COMPLETE: fixed the login page.\n\n## Prior Session\n- **Number:** 05 — CLOSED: added sign-up.\n' \
    > "$p/.ai/SESSION-BOOT.md"
  (cd "$p" && human "$1" next --advance </dev/null >/dev/null 2>&1)
  sed -n '/^## Current Session/,$p' "$p/.ai/SESSION-BOOT.md"
}

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "KNOWN BUGS|2 fixed|F118 · N18 — the list from S193–S197 is empty"
  dk_h1 "Starting a new session " "no longer leaves the old one's notes on it" "."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "When a session started, Vajra put the new number on top of the last session's notes, and those notes vanished from the history list. Three times we fixed it by hand." \
    "Now the last session's notes move, unchanged, to the top of the history list, and the new session starts clean. A file in any other layout is left alone, and Vajra says why."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "F118: 'vajra next --advance' only swapped the number.|S193, S194 and S197 each had to repair the notes file by hand." \
    "We fixed it — carefully.|It moves the entry only when the file has Vajra's exact layout; any other layout keeps the old behaviour and gets a note." \
    "We used it on ourselves.|This session's own start moved S197's notes down with no hand repair — the first time." \
    "N18: a check picked the wrong files when the folder name had dashes.|It now picks by session number, and prints which files it looked at."
  dk_caption "SESSION-BOOT = the short 'where are we' notes file every session reads first."
}

slide_before_after() {
  dk_section before_after "the change · the same commit, before and after"
  dk_h2 "Before → After"
  dk_p "A project whose notes file says session 06 is done. We start session 07 with 'vajra next --advance'. Left: vajra at $OLD_SHA. Right: today's."
  local b a
  b=$(boot_after "$OLD"); a=$(boot_after "$NEW")
  dk_compare "BEFORE|vajra at $OLD_SHA" "$b" "AFTER|vajra today · live" "$a"
  echo
  dk_check "before: session 06's notes sat under the number 07" bash -c 'printf "%s" "$1" | grep -q "Number:\*\* 07 — COMPLETE: fixed the login page"' _ "$b"
  dk_check "after: 07 starts clean; 06's notes are the first history entry" bash -c 'printf "%s\n" "$1" | sed -n 2p | grep -q "07 — IN PROGRESS" && printf "%s\n" "$1" | sed -n 5p | grep -q "06 — COMPLETE: fixed the login page"' _ "$a"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "When a new session starts, the notes file…"
  dk_table "Has this layout|What 'vajra next --advance' does" \
    "Vajra's: one entry under 'Current Session', then 'Prior Session'|moves that entry down, unchanged; writes 'NN — IN PROGRESS'" \
    "anything else (e.g. the one 'vajra init' makes)|changes only the number, as before, and says why it moved nothing else" \
    "no 'Number:' line for this session|changes nothing, and says so"
  dk_caption "It never guesses at a layout it does not know (the 'no text guessing' rule)."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  local p a
  p=$(project "$NEW")
  a=$(cd "$p" && human "$NEW" next --advance </dev/null 2>&1 | grep 'SESSION-BOOT.md' | fold -w 90)
  dk_term "1 · a 'vajra init' project starts session 07 — its own layout is left alone" "$a"
  dk_check "only the number moved, and Vajra says why" bash -c 'printf "%s" "$1" | grep -q "the old entry was NOT moved"' _ "$a"

  mkdir -p "$W/a-b-c"; WD="$W/a-b-c/vajra"; git worktree add -q --detach "$WD" HEAD >/dev/null 2>&1
  a=$(CLAUDE_PROJECT_DIR="$WD" bash "$WD/scripts/scaffold-drift.sh" --bin "$NEW" 2>&1 | grep -A2 -- '--- 6' | fold -w 90)
  dk_term "2 · the drift check run from a folder named 'a-b-c' (dashes)" "$a"
  local last; last=$(ls scripts | sed -n 's/^verify-session-\([0-9][0-9]*\)\.sh$/\1/p' | sort -n | tail -1)
  dk_check "it looked at the newest scripts, up to verify-session-$last" bash -c 'printf "%s" "$1" | tr -d "\n" | grep -q "verify-session-$2.sh"' _ "$a" "$last"
  a=$(CLAUDE_PROJECT_DIR="$WD" bash "$OWT/scripts/scaffold-drift.sh" --bin "$OLD" 2>&1 | grep -A1 -- '--- 6' | fold -w 90)
  dk_term "3 · the same folder, the check at $OLD_SHA — it never said which files it read" "$a"
  dk_check "the old check names no files" bash -c '! printf "%s" "$1" | grep -q "scanned:"' _ "$a"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-198.sh (4 rows; rows 1–3 red at $OLD_SHA)|see the summary" \
    "the full cargo test · CI's lint|see the summary"
  dk_verdict "HONEST NOTES" \
    "Only Vajra's own layout is moved. A project with its own notes layout (rudra's) still gets only the number changed — now with a note saying so." \
    "The drift check's 'last 10' still skips scripts whose name is not a plain number (none exist today)."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next — 3 ranked options (the same as the summary)"
  dk_table " |Option|Why pick it · the risk" \
    "1|rudra S22, synced — the push belt and the review-only guard on a real project|both have only run in temp projects · risk: a real build, long and paid" \
    "2|design: Vajra runs the required reviewer itself (Haiku answer d) + README 'tested with'|the root fix for 'the agent graded itself' · risk: design only; every close then costs money" \
    "3|the step list names the founder's close record (S197 design-advisor rec 10)|small, users meet it in every review-only session · risk: little on its own"
  dk_table "word|meaning" \
    "session|one unit of work, with its own branch, notes and review" \
    "notes file|.ai/SESSION-BOOT.md — 'where are we', read first every session" \
    "drift check|a script that compares what a new user gets with what Vajra runs on"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
