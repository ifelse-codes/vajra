#!/usr/bin/env bash
# Session 174 demo — the founder's rudra session 05, and the things it hit (F58–F63).
# Built on scripts/demo-kit.sh (DECISION-009/010). Every panel is a live run: the hooks as they were
# at f170e1c (main before S174, read out of git) against today's, fed the exact commands rudra's
# agent typed; the binary against a clone of rudra pinned at its merged session 05 (512c71a).
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="174"
OLD_SHA="f170e1c"          # main before S174: the merge of S173
PIN="512c71a"              # rudra: the merge of its session 05
# ========================
export VAJRA_BIN="${VAJRA_BIN:-$ROOT/target/release/vajra}"
BIN="$VAJRA_BIN"
unset VAJRA_ALLOW_COMMIT VAJRA_ALLOW_PUBLISH VAJRA_ENFORCE_PUBLISH CLAUDECODE CLAUDE_CODE_ENTRYPOINT CURSOR_TRACE_ID VAJRA_AGENT
OLD="$DK_TMP/old"; mkdir -p "$OLD"
git show "$OLD_SHA:scripts/hook-publish-guard.sh" > "$OLD/hook-publish-guard.sh"
git show "$OLD_SHA:scripts/hook-session-start.sh" > "$OLD/hook-session-start.sh"
git show "$OLD_SHA:.githooks/pre-commit" > "$OLD/pre-commit"
gx() { git -C "$1" -c user.email=d@d -c user.name=d -c commit.gpgsign=false "${@:2}"; }
mkdir -p "$DK_TMP/bin"; ln -sf "$BIN" "$DK_TMP/bin/vajra"

# The publish guard's fixture: on session-05-*, launched with VAJRA_ALLOW_COMMIT=05.
PG="$DK_TMP/pg"; mkdir -p "$PG/.ai"; printf 'maturity: L3\n' > "$PG/.ai/CONSTRAINTS.yaml"
gx "$PG" init -q -b main; gx "$PG" commit -q --allow-empty -m i; gx "$PG" checkout -qb session-05-directive-monitors
pgrun() { jq -n --arg c "$2" --arg d "$PG" '{cwd:$d,tool_input:{command:$c}}' \
  | env VAJRA_ALLOW_COMMIT=05 CLAUDE_PROJECT_DIR="$PG" bash "$1" 2>&1; }
RUDRA_PR='gh pr create --base main --head session-05-directive-monitors --title "Session 05" --body "$(cat <<'"'"'EOF'"'"'
## What shipped
EOF
)" 2>&1 | tail -5'

# rudra at its merged session 05.
RUDRA="${VAJRA_SYNC_TARGET:-$HOME/playground/rudra}"
RC="$DK_TMP/rudra"; HAVE_RUDRA=0
if [ -d "$RUDRA/.git" ] && git clone -q "$RUDRA" "$RC" 2>/dev/null && gx "$RC" checkout -q -B main "$PIN" 2>/dev/null; then
  gx "$RC" update-ref refs/remotes/origin/main "$PIN"; HAVE_RUDRA=1
fi

slide_headline() {
  dk_section headline "session $SESSION · the founder's rudra session 05 · 2026-09-22"
  dk_h1 "Vajra now " "tells the agent what to do" " at each place it got stuck."
  dk_p "The founder ran rudra's session 05 under Vajra. It shipped, but he still had to open and merge the pull request himself. The agent never saw its to-do list again after start-up, and it told him to throw away Vajra's own update. We collected everything first, then fixed it all."
  dk_vajra_tiles "$SESSION"
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: an approved agent was told 'relaunch with another setting' and gave the PR back; the start-up list said 'nothing left' about the last session; Vajra's update looked like a stranger's edit." \
    "New: the block says 'you ARE approved — put the text in a file'; the list moves to the next session once one is merged; start-up says 'these are Vajra's update, commit them, never revert'. No check let anything new through."
  dk_caption "live = ran just now · recorded = measured at close, not re-run here · filled in by Vajra = derived, never typed"
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What this session did"
  dk_bullets \
    "He ran it; we read the record after.|Four hours, three of them Claude being unavailable. Six problems (F58–F63) plus one to watch." \
    "The PR fell back to him.|Vajra let the agent push. The PR command had its text written inline, so it was sent back — and the message never said 'you are allowed, just use a file'." \
    "The to-do list never reached the agent.|At start-up it described session 04 as finished; the agent started 05 and never looked again. Last session's fixes all live on that list." \
    "Vajra's update was nearly thrown away.|Three synced files sat uncommitted all session; at the end the agent said 'git checkout' would revert them." \
    "Two blocks cost extra tries.|The 3-files rule left all eight files staged; the session-number rule did not name the line to fix."
  dk_caption "Every fix changes what the agent is TOLD, or which session the advice list is about. None changes what is allowed."
}

slide_before_after() {
  dk_section before_after "the change · two real runs · the same input"
  dk_h2 "Before → After"
  dk_p "The input: the exact PR command rudra's agent typed, on its session branch, launched with VAJRA_ALLOW_COMMIT=05. Left: the publish guard at $OLD_SHA, read out of git. Right: today's."
  local before after brc arc
  dk_run_v pgrun "$OLD/hook-publish-guard.sh" "$RUDRA_PR"; brc=$_DK_RC
  before="exit $brc
$(printf '%s\n' "$_DK_OUT" | sed -n '1,4p' | cut -c1-46)"
  dk_run_v pgrun "$ROOT/scripts/hook-publish-guard.sh" "$RUDRA_PR"; arc=$_DK_RC
  after="exit $arc
$(printf '%s\n' "$_DK_OUT" | sed -n '1,6p' | cut -c1-46)"
  dk_compare "BEFORE|publish guard at $OLD_SHA" "$before" "AFTER|publish guard today · live" "$after"
  dk_caption "Both panels ran just now. Both block (exit 2): nothing new gets through — only the words changed."
  echo
  dk_check "both still block rudra's command (exit 2)" bash -c '[ "$1" = 2 ] && [ "$2" = 2 ]' _ "$brc" "$arc"
  dk_check "today's says it IS approved and names --body-file" \
    bash -c 'printf "%s" "$1" | grep -q "You ARE approved" && printf "%s" "$1" | grep -q -- "--body-file"' _ "$after"
  dk_check "and the shape it names passes" \
    bash -c 'pgrun() { jq -n --arg c "$2" --arg d "$3" "{cwd:\$d,tool_input:{command:\$c}}" | env VAJRA_ALLOW_COMMIT=05 CLAUDE_PROJECT_DIR="$3" bash "$1" >/dev/null 2>&1; }; pgrun "$1" "gh pr create --title \"Session 05\" --body-file notes.md" "$2"' \
    _ "$ROOT/scripts/hook-publish-guard.sh" "$PG"
}

slide_rule() {
  dk_section rule "the rule, in plain words · every verdict below is live"
  dk_h2 "Once a session is merged, the list moves on"
  dk_p "vajra next --steps is the first thing every session reads. It now asks git whether the session's summary is on main. If it is, that session is done: the list shows the next one's start."
  local -a rows
  if [ "$HAVE_RUDRA" = 1 ]; then
    local after
    dk_run_v bash -c "cd '$RC' && '$BIN' next --steps 2>&1 | sed -n '1,4p;/YOUR NEXT STEP/,/how:/p'"
    after="$_DK_OUT"
    dk_term "rudra at its merged session 05 — vajra next --steps, today" "$(printf '%s\n' "$after" | cut -c1-100)"
    dk_check "it says session 05 is merged and 06 starts here" \
      bash -c 'printf "%s" "$1" | grep -q "session 05 is merged — session 06 starts here"' _ "$after"
    dk_check "the first move is the new branch, not a merged session's leftovers" \
      bash -c 'printf "%s" "$1" | grep -q "YOUR NEXT STEP: you are on this session.s own branch"' _ "$after"
  else
    dk_term "rudra" "no clone of rudra at $PIN — set VAJRA_SYNC_TARGET to see this one"
    dk_check "a clone of rudra at $PIN is present" false
  fi
  rows+=("summary on main|next session's start|merged — reported on, never re-graded")
  rows+=("summary only on the branch|this session's own list|closed, not merged: unchanged")
  rows+=("on the new session's branch|the normal list, tech-lead first|unchanged")
  rows+=("not a git repo|the normal list|unchanged")
  dk_table "The session's close is…|The list shows|Why" "${rows[@]}"
  dk_caption "Rows 2–4 are unit tests run by scripts/verify-session-174.sh."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "Three more things to see for yourself"
  # 1 — Vajra's own update.
  if [ "$HAVE_RUDRA" = 1 ]; then
    (cd "$RC" && "$BIN" init --sync-fleet >/dev/null 2>&1)
    dk_run_v env PATH="$DK_TMP/bin:$PATH" CLAUDE_PROJECT_DIR="$RC" bash "$ROOT/scripts/hook-session-start.sh"
    local s="$_DK_OUT"
    dk_term "1 · start-up on rudra right after a Vajra sync" \
      "$(printf '%s\n' "$s" | sed -n "/vajra update/,/Never revert/p" | cut -c1-100)"
    dk_check "start-up names the synced files as Vajra's update: commit, never revert" \
      bash -c 'printf "%s" "$1" | grep -q "Vajra.s own update" && printf "%s" "$1" | grep -q "Never revert"' _ "$s"
    dk_run_v env PATH="$DK_TMP/bin:$PATH" CLAUDE_PROJECT_DIR="$RC" bash "$OLD/hook-session-start.sh"
    # QA rec 3: a crashed or silent old hook must not pass this.
    dk_check "the old start-up ran fine (exit 0, its to-do list printed) and said nothing about them" \
      bash -c '[ "$2" = 0 ] && printf "%s" "$1" | grep -q "what is left in session" && ! printf "%s" "$1" | grep -q "vajra update"' _ "$_DK_OUT" "$_DK_RC"
  fi
  # 2 — the 3-file block.
  local C="$DK_TMP/c"; mkdir -p "$C/.ai"; gx "$C" init -q -b main; gx "$C" commit -q --allow-empty -m i; gx "$C" checkout -q -b session-05-x
  echo 05 > "$C/.ai/SESSION"; printf '## Current Session\n- **Number:** 05\n' > "$C/.ai/SESSION-BOOT.md"
  local k; for k in 1 2 3 4 5 6 7 8; do echo "$k" > "$C/h$k.md"; done; gx "$C" add h*.md
  dk_run_v bash -c "cd '$C' && CLAUDECODE=1 VAJRA_ALLOW_COMMIT=05 bash '$ROOT/.githooks/pre-commit'"
  dk_term "2 · an agent commits 8 handoff files at once" "$(printf '%s\n' "$_DK_OUT" | cut -c1-100)"
  dk_check "blocked, and told the 8 are still staged: git reset first" \
    bash -c 'printf "%s" "$1" | grep -q "STILL STAGED"' _ "$_DK_OUT"
  gx "$C" reset -q
  # 3 — the session-number block.
  printf '## Current Session\n- **Number:** 04\n' > "$C/.ai/SESSION-BOOT.md"; gx "$C" add .ai/SESSION
  dk_run_v bash -c "cd '$C' && CLAUDECODE=1 VAJRA_ALLOW_COMMIT=05 bash '$ROOT/.githooks/pre-commit'"
  dk_term "3 · the first commit of a new session, boot file not moved" "$(printf '%s\n' "$_DK_OUT" | cut -c1-110)"
  dk_check "blocked, and told the exact line to set" \
    bash -c 'printf "%s" "$1" | grep -q "Number:\*\* 05"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "the scorecard"
  dk_h2 "Every check on this deck, and the session's own numbers"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "every check on this deck · live"
  dk_caption "Top box: filled in by Vajra from this session's own records. Bottom box: every check on this deck, each one a live run. scripts/verify-session-174.sh compares every allow/deny decision of the old hooks and the new on 77 cases: all identical."
}

slide_next() {
  dk_section next "what is next"
  dk_h2 "Where this leaves us"
  dk_bullets \
    "rudra still has Vajra's update uncommitted.|Session 06's start-up will now tell its agent to commit it first. Don't revert it." \
    "The list only helps if it is read.|It now says 're-run after each step', and it is right at start-up. Whether the agent re-reads it mid-session is the thing to watch in rudra 06." \
    "Parked, not dropped.|F47, F56, F57 low; F64 (an advice answer switched to pass the check) to watch."
  dk_caption "Every limit above is written in the session summary too, not only said here."
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
