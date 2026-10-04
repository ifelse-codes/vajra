#!/usr/bin/env bash
# Session 186 demo — the fixes the S185 ground truth picked: the approvals guard reads where output
# really goes (F110 b), a project's unchecked claims warn instead of blocking (F113), a fresh project's
# ledger speaks (F114), and hook block reasons reach the agent (N1). Drawn with scripts/demo-kit.sh
# (DECISION-009/010): every claim runs live; the "before" is the commit S186 started from.
# Try it: DEMO_MODE=stream bash scripts/demo-session-186.sh (gate view) · bare in a terminal (deck).

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="186"
OLD_SHA=b10a1a6    # the commit S186 started from — pinned, never `main`
# ========================

cargo build --release -q 2>/dev/null
export PATH="$ROOT/target/release:$PATH"
# the binary as it was at $OLD_SHA (verify-session-186.sh builds the same one into the same place)
OLD_VAJRA="$ROOT/target/s186-old/release/vajra"
if [ ! -x "$OLD_VAJRA" ]; then
  git worktree add --detach "$DK_TMP/old" "$OLD_SHA" >/dev/null 2>&1 \
    && (cd "$DK_TMP/old" && CARGO_TARGET_DIR="$ROOT/target/s186-old" cargo build --release -q 2>/dev/null)
  git worktree remove --force "$DK_TMP/old" >/dev/null 2>&1
fi
git show "$OLD_SHA:scripts/hook-approvals-guard.sh" > "$DK_TMP/old-guard.sh" 2>/dev/null

# a fresh `vajra init` project at session 132 with one unchecked `obeyed:` claim
P="$DK_TMP/proj"; mkdir -p "$P"
(cd "$P" && git init -q && vajra init </dev/null >/dev/null 2>&1 && echo 132 > .ai/SESSION && mkdir -p prompts \
  && git add -A && git -c core.hooksPath=/nonexistent commit -qm seed \
  && printf '# S132\n\n## Advice\n\n- plan-advisor rec 1 — obeyed: %s\n' "$(git rev-parse --short=7 HEAD)" > prompts/132-task-x.md)
git show "$OLD_SHA:scripts/verify-closeout-scaffold.sh" > "$P/scripts/old-closeout.sh" 2>/dev/null

D=.ai/approvals
COMMIT="git commit -m \"S186: fix the $D guard

Co-Authored-By: Claude <noreply@anthropic.com>\""
# guard SCRIPT CMD → what the guard says about one command (exit code + its first line)
guard() {
  local out rc
  out=$(jq -n --arg c "$2" --arg d "$P" '{tool_name:"Bash", cwd:$d, tool_input:{command:$c}}' \
    | CLAUDE_PROJECT_DIR="$P" bash "$1" 2>&1 >/dev/null); rc=$?
  if [ "$rc" = 0 ]; then echo "allowed (exit 0)"; else echo "BLOCKED (exit $rc)"; printf '%s\n' "$out" | head -1 | cut -c1-110; fi
}
# claim BIN → what `--check-obeyed 132` says in the fresh project
claim() {
  local out rc; out=$(cd "$P" && "$1" next --check-obeyed 132 2>&1); rc=$?
  echo "exit $rc · $(printf '%s\n' "$out" | grep '^verdict')"
  printf '%s\n' "$out" | grep -oE 'does not block on unchecked `obeyed:` claims \(no `obeyed_blocks_from:`[^)]*\)|carries no independent judgment' | head -1
}
ledger() { local out rc; out=$(cd "$P" && bash "$1" --ledger 2>&1); rc=$?; echo "exit $rc · ${out:-<prints nothing>}"; }

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "FIXES|6|F113 F110 F114 F115 N1 +3 guard recs"
  dk_h1 "The guard stops blocking " "what it can prove is harmless" " — and still blocks the rest."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: any command that named the approvals folder AND had a '>' anywhere was blocked — even a commit message with an email in <angle brackets>. A project's own session 132 started blocking unchecked claims." \
    "New: the guard works out where the output really goes; harmless ones pass, and anything it cannot be sure of still blocks. Projects warn about unchecked claims; only Vajra blocks."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "F110 (b).|The guard read the TEXT. It now reads where each '>' really writes: a plain file outside the folder passes; a variable, a quote, a 'cd', a link, or the folder itself still blocks." \
    "S182 recs.|'..' tricks count as the folder; more write tools (find -delete, git checkout, rsync, curl -o) and shells (sh, bash, eval) are caught; --sync-fleet stops adding a hook twice." \
    "F113.|'Block unchecked claims from session 132' was Vajra's own number, applied to every project. It is now a setting only Vajra's own file has." \
    "F115 + F114 + N1.|A check broken since S135 works again · a new project's ledger says 'no reviewed sessions yet' instead of dying silently · ground-truth block reasons reach the agent." \
    "Found on the way.|The guard blocked my own commands four times while I built it — the safe direction. verify-133 has been red since S181 (3 checks, same at main)."
}

slide_before_after() {
  dk_section before_after "the change · the same commit message, before and after"
  dk_h2 "Before → After"
  dk_p "The input: a commit message that names the approvals folder and ends with an email sign-off in <angle brackets>. Left: the guard at $OLD_SHA. Right: today's."
  local before after
  dk_run_v guard "$DK_TMP/old-guard.sh" "$COMMIT"; before="$_DK_OUT"
  dk_run_v guard "$ROOT/scripts/hook-approvals-guard.sh" "$COMMIT"; after="$_DK_OUT"
  dk_compare "BEFORE|guard at $OLD_SHA" "$before" "AFTER|guard today · live" "$after"
  echo
  dk_check "before: blocked" bash -c 'printf "%s" "$1" | grep -q BLOCKED' _ "$before"
  dk_check "after: allowed" bash -c 'printf "%s" "$1" | grep -q "allowed"' _ "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What the guard does now"
  dk_table "The command names the approvals folder and…|Guard now" \
    "writes to a plain file elsewhere ('> notes.md')|allowed — it can prove where that goes" \
    "writes into the folder, even spelled oddly ('.AI//Approvals/../approvals')|BLOCKED" \
    "writes to a variable, a glob, '~', a quoted path, or after a 'cd'|BLOCKED — it cannot be sure" \
    "writes to a file that is a link into the folder|BLOCKED" \
    "runs find -delete, git checkout, rsync, curl -o, sh, bash, eval|BLOCKED"
  dk_caption "Honest limit: a path built while the command runs (d=.ai; d=\$d/appr…) still gets past — the guard reads text, it is not a sandbox."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v guard "$ROOT/scripts/hook-approvals-guard.sh" "echo x >> .AI//Approvals/../approvals/y"
  dk_term "1 · a sneaky spelling of the folder" "$_DK_OUT"
  dk_check "still blocked" bash -c 'printf "%s" "$1" | grep -q BLOCKED' _ "$_DK_OUT"
  dk_run_v guard "$ROOT/scripts/hook-approvals-guard.sh" "find $D -delete"
  dk_term "2 · a write tool the old guard did not know" "$_DK_OUT"
  dk_check "blocked" bash -c 'printf "%s" "$1" | grep -q BLOCKED' _ "$_DK_OUT"
  dk_run_v claim "$OLD_VAJRA"
  dk_term "3 · F113 before ($OLD_SHA): a fresh project at its own session 132" "$_DK_OUT"
  dk_check "it blocked (exit 1)" bash -c 'printf "%s" "$1" | grep -q "exit 1"' _ "$_DK_OUT"
  dk_run_v claim vajra
  dk_term "4 · F113 now: the same project, the same claim" "$_DK_OUT"
  dk_check "it warns, says why, and does not block" bash -c 'printf "%s" "$1" | grep -q "exit 0" && printf "%s" "$1" | grep -q "no \`obeyed_blocks_from:\`"' _ "$_DK_OUT"
  dk_run_v ledger scripts/old-closeout.sh
  dk_term "5 · F114 before ($OLD_SHA): --ledger in a fresh project" "$_DK_OUT"
  dk_check "silent failure" bash -c 'printf "%s" "$1" | grep -q "exit 1 · <prints nothing>"' _ "$_DK_OUT"
  dk_run_v ledger scripts/verify-closeout.sh
  dk_term "6 · F114 now" "$_DK_OUT"
  dk_check "says so, exit 0" bash -c 'printf "%s" "$1" | grep -q "exit 0 · ledger: no reviewed sessions yet"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-186.sh — real-run checks; each fix is run at $OLD_SHA too|25 / 25" \
    "scripts/verify-session-132.sh — incl. the --advance check red since S135|13 / 13"
  dk_verdict "HONEST NOTES" \
    "The guard still over-blocks: any quote after a '>' in a command naming the folder blocks (an arrow '->' inside a commit message, for example). The message says: write it to a file, then git commit -F." \
    "Vajra's own repo can switch off its blocking by editing obeyed_blocks_from — only the diff shows it."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "1|rudra S18 with the new guard (interactive)|you run --sync-fleet in rudra and use it; we fix what you hit · risk: new over-blocks show up in real use" \
    "2|F67: the receipt reads the tool's own cost|the one wrong number every user sees (~5× high) · risk: Claude Code may not expose it" \
    "3|the non-Claude tools brainstorm (F91, F94, F95)|promised since S179 · risk: a design session, nothing a user runs yet"
  dk_table "word|meaning" \
    "redirect ('>')|sending a command's output into a file" \
    "obeyed claim|the agent saying 'I did what the advisor recommended', with a commit" \
    "ledger|Vajra's chained list of every review verdict"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
