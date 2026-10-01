#!/usr/bin/env bash
# Session 182 demo — S181's controls reach projects that already use Vajra: the approvals guard (now
# blocking writes, not reads), wired by `--sync-fleet`, a report for a missing `session_rules_from`,
# and `--allow-all=NN`. Drawn with scripts/demo-kit.sh (DECISION-009/010): every claim runs live; the
# "before" is the commit S182 started from. Try it: DEMO_MODE=stream bash scripts/demo-session-182.sh
# (gate view) · bare in a terminal (deck).

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="182"
OLD_SHA=e5db703    # the commit S182 started from — pinned, never `main`
# ========================

cargo build --release -q 2>/dev/null
NEW="$ROOT/target/release/vajra"
APPR=".ai/approvals"
git show "$OLD_SHA:scripts/hook-pre-bash.sh" > "$DK_TMP/old-pre-bash.sh" 2>/dev/null
P="$DK_TMP/p"; mkdir -p "$P/.ai"; echo "maturity: L2" > "$P/.ai/CONSTRAINTS.yaml"

# guard_says HOOK COMMAND → what that hook does with an agent's shell command
guard_says() {
  local e
  printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$2" \
    | CLAUDE_PROJECT_DIR="$P" bash "$1" >/dev/null 2>&1; e=$?
  if [ "$e" = 2 ]; then echo "\$ $2"; echo "  → BLOCKED (exit 2)"; else echo "\$ $2"; echo "  → allowed (exit $e)"; fi
}
# allow_all_try FLAG → the launcher's answer to a bare or numbered --allow-all (no agent mark)
allow_all_try() {
  local d out rc; d="$(mktemp -d "$DK_TMP/l.XXXX")"
  out="$(cd "$d" && env -u VAJRA_AGENT_MARK "$NEW" claude "$1" </dev/null 2>&1)"; rc=$?
  echo "\$ vajra claude $1"; echo "  exit: $rc"; echo "  says: $(head -1 <<<"$out" | cut -c1-140)"
}
# rudra_live → rudra's own registered guard, driven with an agent write (only if rudra is here)
rudra_live() {
  local R=/Users/suman/playground/rudra cmd e
  [ -d "$R/.ai" ] || { echo "rudra not on this machine — see sessions/session-182-summary.md"; return 0; }
  cmd=$(jq -r '[.hooks.PreToolUse[].hooks[].command | select(contains("hook-approvals-guard"))][0]' "$R/.claude/settings.json")
  echo "registered in rudra: $cmd"
  e=$(printf '{"tool_name":"Bash","tool_input":{"command":"echo x > %s/session-16.json"}}' "$APPR" | (cd "$R" && CLAUDE_PROJECT_DIR="$R" bash -c "$cmd" >/dev/null 2>&1); echo $?)
  echo "agent writes rudra's approvals → exit $e"
  echo "$(grep -E '^[[:space:]]*session_rules_from' "$R/.ai/CONSTRAINTS.yaml" | sed 's/#.*//;s/^ *//')"
}
suite() { cargo test -q --test "$1" 2>&1 | grep -E "test result" | head -1; }

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "PARTS DONE|7|one by one"
  dk_h1 "S181's controls now reach " "every project" ", not just Vajra's own."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: the guard on your approvals lived only in Vajra's repo, blocked harmless reads, and hid its reason from the agent. An upgraded project got none of it. \"--allow-all\" approved whatever session ran." \
    "New: every project gets the guard and the upgrade switches it on. Reads pass, writes block, and the reason reaches the agent. You're told the one line to add. --allow-all=NN approves one session."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "Guard.|The approvals guard blocked my plain reads twice at the start of this session. It now blocks writes only, and tells the agent why." \
    "Ship.|New projects get it, and \`vajra init --sync-fleet\` adds it to an existing project's Claude settings without touching your own settings." \
    "Report.|The upgrade tells you the exact \`session_rules_from\` line to add. It never edits your rules file." \
    "Allow-all.|\`--allow-all=NN\` approves that one session. A bare \`--allow-all\` is refused before anything starts." \
    "Tests.|S181's weak whole-suite check now fails on code that won't compile; an edited judge verdict is caught end to end." \
    "rudra.|Upgraded for real with this branch's Vajra. Its own guard blocks an agent write. Nothing committed there."
}

slide_before_after() {
  dk_section before_after "the change · the same command, before and after"
  dk_h2 "Before → After"
  dk_p "The input: an agent reads the approvals folder, with error output sent to the screen. Left: Vajra at $OLD_SHA. Right: today's."
  local before after
  dk_run_v bash -c "$(declare -f guard_says); P='$P'; guard_says '$DK_TMP/old-pre-bash.sh' 'cat $APPR/x 2>&1'"; before="$_DK_OUT"
  dk_run_v bash -c "$(declare -f guard_says); P='$P'; guard_says '$ROOT/scripts/hook-pre-bash.sh' 'cat $APPR/x 2>&1'"; after="$_DK_OUT"
  dk_compare "BEFORE|Vajra at $OLD_SHA" "$before" "AFTER|Vajra today · live" "$after"
  echo
  dk_check "before: a plain read was BLOCKED (the false alarm)" \
    bash -c 'printf "%s" "$1" | grep -q "BLOCKED"' _ "$before"
  dk_check "after: the read is allowed" \
    bash -c 'printf "%s" "$1" | grep -q "allowed"' _ "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What Vajra does now"
  dk_table "Thing|Vajra now" \
    "an agent writes your approvals|blocked — a redirect, a file-writing tool, a \`cd\` into the folder, or a script that names it" \
    "an agent reads them|allowed (\`cat\`, \`ls\`, \`jq\`, with or without \`2>&1\`)" \
    "an existing project upgrades|gets the guard file AND its entry in Claude's settings; your keys kept" \
    "no session_rules_from|the upgrade prints the line to add; your rules file is never edited" \
    "--allow-all=NN|approves session NN only, while that launch runs; bare --allow-all is refused"
  dk_caption "Bar-raising, not tamper-proof: a folder path built up inside a script at run time still gets past."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v bash -c "$(declare -f guard_says); P='$P'; guard_says '$ROOT/scripts/hook-pre-bash.sh' 'echo x 2>&1 > $APPR/x'"
  dk_term "1 · the agent tries to write an approval after a 2>&1" "$_DK_OUT"
  dk_check "still blocked" bash -c 'printf "%s" "$1" | grep -q "BLOCKED"' _ "$_DK_OUT"
  dk_run_v allow_all_try --allow-all
  dk_term "2 · a bare --allow-all" "$_DK_OUT"
  dk_check "refused before anything starts, showing the form to type" \
    bash -c 'printf "%s" "$1" | grep -q "exit: 1" && printf "%s" "$1" | grep -q "allow-all=182"' _ "$_DK_OUT"
  dk_run_v suite approvals_scaffold
  dk_term "3 · an old project upgraded: guard wired through settings; rules line reported, never written" "$_DK_OUT"
  dk_check "every scaffold test passes (new project, old project, pre-S93 project, rules report)" \
    bash -c 'printf "%s" "$1" | grep -qE "ok\. [4-9][0-9]* passed; 0 failed"' _ "$_DK_OUT"
  dk_run_v rudra_live
  dk_term "4 · rudra, the founder's real project" "$_DK_OUT"
  dk_check "rudra's own guard blocks an agent write (or rudra is absent here)" \
    bash -c 'printf "%s" "$1" | grep -qE "exit 2|not on this machine"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-182.sh — real-run checks|15 / 15" \
    "the whole cargo test suite|0 failed"
  dk_verdict "HONEST NOTES" \
    "Bar-raising, not tamper-proof: a path assembled inside a variable or script at run time gets past the guard. A command that names the folder and redirects anywhere is blocked, even a harmless one; the message says to split it." \
    "rudra's upgrade is uncommitted there on purpose: you commit it in rudra's next session."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "A|rudra session 16 under the new rules (interactive)|the controls get their first real use · risk: new refusals mid-session" \
    "B|F67: the receipt reads the tool's own cost for interactive runs|rudra receipts show ~5× the real cost · risk: Claude Code may not expose it" \
    "C|finish 0.2.0: crates.io publish|a stranger gets S167–S182 · risk: founder-only steps; you said not yet"
  dk_table "word|meaning" \
    "approvals folder|where \`vajra approve NN\` records your yes" \
    "--sync-fleet|the upgrade command for a project already using Vajra" \
    "session_rules_from|the first session that follows the new approval rules"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
