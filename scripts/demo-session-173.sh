#!/usr/bin/env bash
# Session 173 demo — the founder's own rudra session 04, and the eleven things it hit (F45–F55).
# Built on scripts/demo-kit.sh (DECISION-009/010). Every panel is a live run: the hooks as they were
# at f02d8e1 (main before S173, read out of git — never `main`, which is the after-state) against
# today's, fed the exact commands rudra's agent typed; the binary against a clone of rudra pinned
# at its merged session 04 (3c401ec).
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="173"
OLD_SHA="f02d8e1"          # main before S173: the merge of S172's closeout
PIN="3c401ec"              # rudra: the merge of its session 04
# ========================
export VAJRA_BIN="${VAJRA_BIN:-$ROOT/target/release/vajra}"
BIN="$VAJRA_BIN"
unset VAJRA_ALLOW_COMMIT VAJRA_ALLOW_PUBLISH VAJRA_ENFORCE_PUBLISH
OLD="$DK_TMP/old"; mkdir -p "$OLD"
for h in hook-session-start.sh hook-session-guard.sh hook-publish-guard.sh; do
  git show "$OLD_SHA:scripts/$h" > "$OLD/$h"
done
gx() { git -C "$1" -c user.email=d@d -c user.name=d "${@:2}"; }

# rudra's own session-03 handover: it names no prompt file (the F45 trigger).
BOOT="$DK_TMP/boot"; mkdir -p "$BOOT/.ai"
printf '# Session Boot\n\n## Next Session\n- author the session 04 prompt from the summary\n' > "$BOOT/.ai/SESSION-BOOT.md"
printf '# Task\n\nNothing named here.\n' > "$BOOT/.ai/TASK.md"
gx "$BOOT" init -q -b main

# The session guard's fixture: this chat owns session 4.
SG="$DK_TMP/sg"; mkdir -p "$SG/.ai"
printf 'maturity: L2\nsession:\n  one_session_per_chat: true\n' > "$SG/.ai/CONSTRAINTS.yaml"; echo 04 > "$SG/.ai/SESSION"
guard() { # guard <hook> <command> -> exit code
  printf '4\tSID\n' > "$SG/.ai/.session-owner"
  jq -n --arg c "$2" '{session_id:"SID",tool_input:{command:$c}}' | CLAUDE_PROJECT_DIR="$SG" bash "$1" >/dev/null 2>&1
  echo $?
}
RUDRA_MSG="$(printf 'git commit -q -m "$(cat <<'"'"'EOF'"'"'\nS04 setup: advance session pointer 03 → 04\n\nvajra next --advance: .ai/SESSION=04, boot + task pointers synced.\nEOF\n)"')"

# The publish guard's fixture: on session-04-*, launched with VAJRA_ALLOW_COMMIT=04.
PG="$DK_TMP/pg"; mkdir -p "$PG/.ai"; printf 'maturity: L2\n' > "$PG/.ai/CONSTRAINTS.yaml"
gx "$PG" init -q -b main; gx "$PG" checkout -qb session-04-partial-fill
ship() { jq -n --arg c "$1" '{tool_input:{command:$c}}' \
  | env VAJRA_ALLOW_COMMIT=04 CLAUDE_PROJECT_DIR="$PG" bash "$ROOT/scripts/hook-publish-guard.sh" >/dev/null 2>&1; echo $?; }

# rudra at its merged session 04, about to start session 05.
RUDRA="${VAJRA_SYNC_TARGET:-$HOME/playground/rudra}"
RC="$DK_TMP/rudra"; HAVE_RUDRA=0
if [ -d "$RUDRA/.git" ] && git clone -q "$RUDRA" "$RC" 2>/dev/null && gx "$RC" checkout -q "$PIN" 2>/dev/null; then
  HAVE_RUDRA=1
fi

slide_headline() {
  dk_section headline "session $SESSION · the founder used Vajra on his own project again · 2026-09-22"
  dk_h1 "Vajra stops " "tripping over its own words" "."
  dk_p "The founder ran rudra's session 04 end to end under Vajra — plan, build, review, merge — and we collected everything it hit before fixing any of it. Eleven problems. The worst: Vajra's start-up crashed halfway on his project, a guard read a commit MESSAGE as a command, and he typed git commands by hand at the end of every session."
  dk_vajra_tiles "$SESSION"
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: start-up died on a handover naming no plan file; the guard blocked a commit whose message mentioned 'vajra next --advance'; Vajra asked 'y/N' and the agent answered itself; he pushed and opened every PR himself." \
    "New: start-up runs to the end; guards read commands, not prose; nobody is asked a fake question; with the launch approval the agent pushes its OWN branch and opens its PR — merging stays his."
  dk_caption "live = ran just now · recorded = measured at close, not re-run here · filled in by Vajra = derived, never typed"
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What this session did"
  dk_bullets \
    "He ran it; we only watched.|His rule this time: collect every finding while rudra's session runs, fix them all after it closes. Eleven findings, F45 to F55, each with how bad it was." \
    "Start-up survives his project.|Last session's 'missing plan file' warning crashed when the handover named no file at all — rudra's case — and took the branch, commit and to-do lines with it." \
    "Guards read commands, not sentences.|A multi-line commit message quoting a Vajra command was read as the command. Now message text is ignored; a real command is still caught." \
    "Less paperwork, in the right order.|A merged session's leftovers print as one counted line, not 38. The to-do list now names the advisor answers and says: stamp the review LAST." \
    "He stops typing git commands.|His pick: the launch approval now lets the agent push its own session branch and open the PR — by a list of exact allowed shapes, after the design check broke the first version a dozen ways."
  dk_caption "stamp = the review's Review-Inputs-SHA, a hash of the plan and the work. Any later edit moves it; rudra re-did it four times."
}

slide_before_after() {
  dk_section before_after "the change · two real runs · the same input"
  dk_h2 "Before → After"
  dk_p "The input: a project whose handover names no plan file — exactly rudra's. The left side runs the start-up script as it was at $OLD_SHA, read out of git; the right side runs today's."
  local before after brc arc
  dk_check "the old start-up script is in git at $OLD_SHA" test -s "$OLD/hook-session-start.sh"
  dk_run_v env CLAUDE_PROJECT_DIR="$BOOT" bash "$OLD/hook-session-start.sh"
  brc=$_DK_RC; before="exit $brc · last lines:
$(printf '%s\n' "$_DK_OUT" | grep -v '^$' | tail -3 | cut -c1-44)
(no branch · no commit rule · no to-do list)"
  dk_run_v env CLAUDE_PROJECT_DIR="$BOOT" bash "$ROOT/scripts/hook-session-start.sh"
  arc=$_DK_RC; after="exit $arc · reaches:
$(printf '%s\n' "$_DK_OUT" | grep -E '^Current branch|^\[commit approval\]' | cut -c1-44)"
  dk_compare "BEFORE|start-up at $OLD_SHA" "$before" "AFTER|start-up today · live" "$after"
  dk_caption "Both panels ran just now, on the same fixture."
  echo
  dk_check "the old start-up crashed (exit $brc) before the branch line" \
    bash -c '[ "$1" != 0 ]' _ "$brc"
  dk_check "today's runs to the end: branch line, commit rule, exit 0" \
    bash -c '[ "$1" = 0 ] && printf "%s" "$2" | grep -q "Current branch" && printf "%s" "$2" | grep -q "commit approval"' _ "$arc" "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words · every verdict below is live"
  dk_h2 "What the agent may now ship on its own"
  dk_p "Launched with VAJRA_ALLOW_COMMIT=04, on branch session-04-partial-fill. Anything not on the allowed list falls back to the human, as before."
  local -a rows; local r
  row() { # row <want> <command> <why>
    r="$(ship "$2")"
    dk_check -q "rule · $2" bash -c '[ "$1" = "$2" ]' _ "$r" "$1"
    if [ "$r" = 0 ]; then rows+=("$2|${C_YES}✓ AGENT${C_0}|$3"); else rows+=("$2|${C_NO}✗ HUMAN${C_0}|$3"); fi
  }
  row 0 'git push -u origin session-04-partial-fill' "its own branch"
  row 0 'gh pr create --base main --title "S04" --body "…"' "opening a PR is not a merge"
  row 2 'gh pr merge 5 --merge' "merging stays the human's"
  row 2 'git push origin HEAD:main' "main, by any spelling"
  row 2 'git push origin HEAD:session-05-y' "another session's branch (the first cut let this through)"
  row 2 'git push -uf origin session-04-partial-fill' "a force hidden in combined flags (same)"
  row 2 'git push origin "+session-04-partial-fill"' "a force hidden in quotes (same)"
  row 2 'git push -o merge_request.create -o merge_request.target=main' "a merge smuggled in as a push option (same)"
  dk_table "The agent types…|Who|Why" "${rows[@]}"
  dk_caption "AGENT = the guard lets it through · HUMAN = blocked, the person does it. Each row ran just now. The full list is 29 cases in scripts/verify-session-173.sh."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "Four things to see for yourself"
  # 1 — rudra's own commit, old guard vs new.
  local o n
  o="$(guard "$OLD/hook-session-guard.sh" "$RUDRA_MSG")"; n="$(guard "$ROOT/scripts/hook-session-guard.sh" "$RUDRA_MSG")"
  dk_term "1 · rudra's own commit (message mentions 'vajra next --advance') — old guard exit $o, today's exit $n" \
    "$(printf '%s\n' "$RUDRA_MSG" | head -4 | cut -c1-96)"
  dk_check "the old guard blocked his commit, today's lets it through" bash -c '[ "$1" = 2 ] && [ "$2" = 0 ]' _ "$o" "$n"
  dk_check "a real advance in the same chat is still blocked" \
    bash -c '[ "$1" = 2 ]' _ "$(guard "$ROOT/scripts/hook-session-guard.sh" 'vajra next --advance')"
  # 2 — the advance on rudra after its merged session 04.
  if [ "$HAVE_RUDRA" = 1 ]; then
    gx "$RC" checkout -q -b session-05-directive-monitors
    sed -i.bak 's/Status:\*\* DRAFT/Status:** APPROVED/' "$RC/prompts/05-task-directive-monitors.md"
    dk_run_v bash -c "cd '$RC' && VAJRA_SKIP_ARCHITECT_GATE=1 VAJRA_SKIP_PLANNER_GATE=1 '$BIN' next --advance </dev/null 2>&1"
    local adv="$_DK_OUT"   # dk_check overwrites _DK_OUT — keep this run's output
    dk_term "2 · rudra, starting session 05 after its merged 04 — the merged session's leftovers, then the question" \
      "$(printf '%s\n' "$adv" | grep -E 'for the record|note\(s\)|not asked|Advanced' | cut -c1-110)"
    dk_check "the merged session prints counts, no per-item ✗ wall" \
      bash -c 'printf "%s" "$1" | grep -q "for the record" && ! printf "%s" "$1" | grep -q "cannot close"' _ "$adv"
    dk_check "no fake y/N: it says it did not ask, and advances" \
      bash -c 'printf "%s" "$1" | grep -q "not asked: no terminal" && ! printf "%s" "$1" | grep -q "\[y/N\]"' _ "$adv"
  else
    dk_term "2 · rudra" "no clone of rudra at $PIN — set VAJRA_SYNC_TARGET to see this one"
    dk_check "a clone of rudra at $PIN is present" false
  fi
  # 3 — the to-do list: advice answers and the stamp, LAST.
  local E="$DK_TMP/empty"; mkdir -p "$E/.ai"; echo 01 > "$E/.ai/SESSION"; gx "$E" init -q -b main
  dk_run_v bash -c "cd '$E' && '$BIN' next --steps 2>&1 | sed -n '10,15p'"
  dk_term "3 · the end of every session's to-do list, today" "$(printf '%s\n' "$_DK_OUT" | cut -c1-96)"
  dk_check "answer the advisors, then stamp LAST, then merge" \
    bash -c 'printf "%s" "$1" | grep -A1 "advisor recommendation" | grep -q "stamp matches the finished work (do this LAST)"' _ "$_DK_OUT"
  # 4 — sync says whose files it wrote.
  if [ "$HAVE_RUDRA" = 1 ]; then
    local C2="$DK_TMP/rudra2"; git clone -q "$RUDRA" "$C2" && gx "$C2" checkout -q "$PIN"
    dk_run_v bash -c "cd '$C2' && '$BIN' init --sync-fleet 2>&1 | tail -3"
    dk_term "4 · vajra init --sync-fleet on a copy of rudra at its session 04" "$(printf '%s\n' "$_DK_OUT" | cut -c1-110)"
    dk_check "it upgrades cleanly and says the files are Vajra's to commit" \
      bash -c 'printf "%s" "$1" | grep -qE "^0 created, [0-9]+ upgraded, .*0 drifted" && printf "%s" "$1" | grep -q "are Vajra'"'"'s"' _ "$_DK_OUT"
  fi
}

slide_scorecard() {
  dk_section scorecard "the scorecard"
  dk_h2 "Every check on this deck, and the session's own numbers"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "every check on this deck · live"
  dk_caption "Top box: filled in by Vajra from this session's own records. Bottom box: every check on this deck, each one a live run."
}

slide_next() {
  dk_section next "what is next"
  dk_h2 "Where this leaves us"
  dk_bullets \
    "The push permission is a text match, and says so.|Plain pushes of the session's own branch go through; a dozen tricky spellings go back to you. A few exotic ones were never recognised as a push at all — listed in DECISION-007, S173 addendum." \
    "One thing parked.|F47: options copied from a summary keep its jargon. Low; carried to the next session." \
    "The next test is rudra session 05.|Sync the fixes in, launch with VAJRA_ALLOW_COMMIT=05, and see whether the agent now ships its own PR and the close runs in order."
  dk_caption "Every limit above is written in the session summary too, not only said here."
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
