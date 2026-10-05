#!/usr/bin/env bash
# Session 188 demo — the approvals folder: check what changed, not what the words say. The AI's Bash
# commands are no longer judged by their words: Vajra saves the folder's state before each AI call and
# compares after it; a change voids those approvals until the founder approves again. Drawn with
# scripts/demo-kit.sh (DECISION-009/010): every claim runs live; the "before" is the commit S188 started from.
# Try it: DEMO_MODE=stream bash scripts/demo-session-188.sh (gate view) · bare in a terminal (deck).

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="188"
OLD_SHA=43305fd    # the commit S188 started from — pinned, never `main`
# ========================

cargo build --release -q 2>/dev/null
export PATH="$ROOT/target/release:$PATH"
git show "$OLD_SHA:scripts/hook-approvals-guard.sh" > "$DK_TMP/old-guard.sh" 2>/dev/null

D=.ai/approvals
# a fresh `vajra init` project at session 2, approved by the founder, committed
P="$DK_TMP/proj"; mkdir -p "$P" "$DK_TMP/home"
(cd "$P" && git init -q && vajra init </dev/null >/dev/null 2>&1 && echo 2 > .ai/SESSION && mkdir -p $D \
  && printf '{"session": 2, "method": "approve-command", "at_unix": 1}\n' > $D/session-02.json \
  && printf '{"session": 3, "method": "approve-command"}\n' > forged.json \
  && git add -A && git -c user.name=v -c user.email=v@v commit -qm start --no-verify) >/dev/null 2>&1

LIVE="git checkout -q -b X main && cd ~/playground/rudra && ls $D/"
# before GUARD CMD → what the before side of the guard does with a Bash command
before() {
  local out rc
  out=$(jq -n --arg c "$2" --arg d "$P" '{hook_event_name:"PreToolUse",tool_name:"Bash",tool_use_id:"toolu_demo",tool_input:{command:$c},cwd:$d}' \
    | CLAUDE_PROJECT_DIR="$P" TMPDIR="$DK_TMP" bash "$1" 2>&1 >/dev/null); rc=$?
  if [ "$rc" = 0 ]; then echo "allowed (exit 0)"; else echo "BLOCKED (exit $rc)"
    printf '%s\n' "$out" | head -1 | sed 's/^\[HOOK BLOCK\] //' | fold -s -w 70; fi
}
# the guard command this project's settings run for EVENT (Bash)
reg() { jq -r --arg ev "$1" '[.hooks[$ev][]? | select((.matcher // "") | split("|") | index("Bash")) | .hooks[].command | select(contains("hook-approvals-guard"))][0] // ""' "$P/.claude/settings.json"; }
N=0
# ai CMD → one AI Bash call as Claude Code runs it: the project's before hook, the command, its after hook
ai() {
  N=$((N+1)); local id="toolu_demo_$N" in; in=$(jq -n --arg c "$1" '{command:$c}')
  local j; j() { jq -n --arg ev "$1" --arg id "$id" --argjson in "$in" '{hook_event_name:$ev,tool_name:"Bash",tool_use_id:$id,tool_input:$in}'; }
  j PreToolUse | CLAUDE_PROJECT_DIR="$P" TMPDIR="$DK_TMP" bash -c "$(reg PreToolUse)" >/dev/null 2>&1
  local ev=PostToolUse
  (cd "$P" && HOME="$DK_TMP/home" bash -c "$1") >/dev/null 2>&1 </dev/null || ev=PostToolUseFailure
  local err rc
  err=$(j "$ev" | CLAUDE_PROJECT_DIR="$P" TMPDIR="$DK_TMP" bash -c "$(reg "$ev")" 2>&1 >/dev/null); rc=$?
  echo "\$ $1"
  if [ "$rc" = 0 ]; then echo "→ nothing raised (exit 0)"; else echo "→ exit $rc"; printf '%s\n' "$err" | fold -s -w 72; fi
}
steps() { (cd "$P" && vajra next --steps 2>&1) | grep 'founder has approved this session' | sed 's/^ *//'; }
approve() {
  (cd "$P" && env -u VAJRA_AGENT_MARK python3 -c \
    "import pty,sys; sys.exit(0 if pty.spawn(['vajra','approve','2'])==0 else 1)" </dev/null 2>&1) \
    | tr -d '\r' | sed 's/^ *//' | fold -s -w 72
}

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "CHANGE|1|the approvals folder: check what changed, not the words"
  dk_h1 "Reading the approvals folder " "never blocks" " again — writing to it is always caught."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: Vajra read the WORDS of every AI command. A harmless read that mentioned the folder was blocked (5 times in S187 alone), and a clever spelling could still slip past." \
    "New: Vajra takes a snapshot of the folder before each AI command and compares after. Same → silent. Changed → the AI is told, and those approvals stop counting until you approve again."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "Your plan.|'We tell it not to write; if it does, even by a trick, we catch it and ask you again.' No sandbox, no chasing tricks." \
    "Before and after.|Claude Code runs a hook before every command and one after (success OR failure). Vajra photographs the folder in the first and compares in the second." \
    "The void.|A change writes a 'voided' list inside the folder. Those records stop counting. Your \`vajra approve NN\` takes yours off the list." \
    "Projects get it.|\`vajra init\` and \`--sync-fleet\` wire the after hooks; a project's own hooks are left alone." \
    "Moved.|N2 → backlog as a known issue (your call). The S187 summary now says so too."
}

slide_before_after() {
  dk_section before_after "the change · the same command, before and after"
  dk_h2 "Before → After"
  dk_p "The input: the command that blocked me on 2026-10-04 — make a branch, then list rudra's approvals folder. Left: the guard at $OLD_SHA. Right: today's."
  local b a
  dk_run_v before "$DK_TMP/old-guard.sh" "$LIVE"; b="$_DK_OUT"
  dk_run_v before "$ROOT/scripts/hook-approvals-guard.sh" "$LIVE"; a="$_DK_OUT"
  dk_compare "BEFORE|guard at $OLD_SHA" "$b" "AFTER|guard today · live" "$a"
  echo
  dk_check "before: a plain read was blocked" bash -c 'printf "%s" "$1" | grep -q BLOCKED' _ "$b"
  dk_check "after: it runs" bash -c 'printf "%s" "$1" | grep -q "allowed"' _ "$a"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What changed for whom"
  dk_table "Who|Before|Now" \
    "an AI reading the folder|often blocked (it named the folder)|never blocked" \
    "an AI writing ABOUT it (notes, commits)|blocked — use git commit -F|never blocked" \
    "an AI writing INTO it, any spelling|blocked if the words looked like writing|runs, is caught after, approvals stop counting" \
    "an AI using the Write tool on it|blocked before it runs|the same — blocked before it runs" \
    "you, typing vajra approve|never flagged|never flagged between commands; during one → told to run it again"
  dk_caption "Counted, not claimed: of the 76 commands the old guard blocked, 45 really wrote (now caught after) and 31 wrote nothing (now pass)."
}

slide_cases() {
  dk_section cases "the cases · live, in a fresh vajra init project"
  dk_h2 "See it for yourself"
  dk_run_v ai "ls $D && cat $D/session-02.json > /dev/null"
  dk_term "1 · the AI reads the folder" "$_DK_OUT"
  dk_check "nothing raised" bash -c 'printf "%s" "$1" | grep -q "nothing raised"' _ "$_DK_OUT"
  dk_run_v ai "d=.ai; cp forged.json \$d/approvals/session-03.json; false"
  dk_term "2 · the AI forges next session's approval (a path built at run time, in a FAILING command)" "$_DK_OUT"
  dk_check "caught after it ran" bash -c 'printf "%s" "$1" | grep -q "CAUGHT"' _ "$_DK_OUT"
  dk_run_v steps
  dk_term "3 · vajra next --steps — your approval no longer counts" "$_DK_OUT"
  dk_check "✗ approval" bash -c 'printf "%s" "$1" | grep -q "✗"' _ "$_DK_OUT"
  dk_run_v approve
  dk_term "4 · you run vajra approve 2 in your own terminal" "$_DK_OUT"
  dk_check "recorded" bash -c 'printf "%s" "$1" | grep -q "approved session 2"' _ "$_DK_OUT"
  dk_run_v steps
  dk_term "5 · your approval counts again" "$_DK_OUT"
  dk_check "✓ approval" bash -c 'printf "%s" "$1" | grep -q "✓"' _ "$_DK_OUT"
  dk_run_v bash -c "jq -c '.listed' '$P/$D/voided.json' 2>/dev/null || echo '(no voided list)'"
  dk_term "6 · the forged record stays voided (it was for session 3)" "$_DK_OUT"
  dk_check "session-03.json still listed" bash -c 'printf "%s" "$1" | grep -q "session-03.json"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-188.sh — real runs in real projects; each fix run at $OLD_SHA too|see the summary" \
    "the full cargo test, before the push|see the summary"
  dk_verdict "HONEST NOTES" \
    "Not caught: a change the AI undoes inside the same command; a write timed to land after the command returns; a write into ANOTHER project's folder (the old guard blocked that by its words)." \
    "Flagged by mistake: your own approve while an AI command is running, or a git checkout that moves a record — the message says to run it again."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "1|F67: the receipt reads the tool's own cost|the one wrong number every user sees (~5× high) · risk: Claude Code may not write a cost into an interactive run" \
    "2|the non-Claude tools brainstorm (F91, F94, F95)|promised since S179 · risk: a design session, nothing a user runs yet" \
    "3|rudra S18 under the new check|the first real run of this session's change · risk: waits for rudra's data API"
  dk_table "word|meaning" \
    "the void|the list inside the folder of approvals that stopped counting" \
    "before / after hook|what Claude Code runs just before and just after every AI command" \
    "named, not closed|the gap is said out loud, but not fixed"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
