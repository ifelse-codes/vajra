#!/usr/bin/env bash
# Session 186 demo — the fixes the S185 ground truth picked: a project's unchecked claims warn instead
# of blocking (F113), the approvals guard catches more ways to write (S182 recs 1/5; F110 b was split
# out by the founder), a fresh project's ledger speaks (F114), and hook block reasons reach the agent (N1). Drawn with scripts/demo-kit.sh
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
# write_tool GUARD → what the guard says about the Write tool aimed at .ai/hooks/../approvals/x
write_tool() {
  jq -n --arg d "$P" '{tool_name:"Write", cwd:$d, tool_input:{file_path:($d + "/.ai/hooks/../approvals/x")}}' \
    | CLAUDE_PROJECT_DIR="$P" bash "$1" >/dev/null 2>&1 && echo "allowed (exit 0)" || echo "BLOCKED (exit $?)"
}
ledger() { local out rc; out=$(cd "$P" && bash "$1" --ledger 2>&1); rc=$?; echo "exit $rc · ${out:-<prints nothing>}"; }

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "FIXES|5|F113 F114 F115 N1 +3 guard recs · F110 (b) split out"
  dk_h1 "Projects stop blocking at " "Vajra's session numbers" " — and the guard catches more ways to write."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: a project's own session 132 started blocking unchecked claims (Vajra's number). '..', 'find -delete', 'git checkout', awk got past the guard. A new project's ledger died silently." \
    "New: projects warn and say why; only Vajra blocks. Those writes are blocked. The ledger says 'no reviewed sessions yet'. F110 (the commit-message false block) is still open — split out, by your call."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "F113.|'Block unchecked claims from session 132' was Vajra's own number, applied to every project. It is now a setting only Vajra's own file has." \
    "Guard, only adds.|'..' tricks, a working folder inside the approvals folder, find -delete, git checkout, rsync, curl -o, sh/bash/eval, awk and editors are now caught." \
    "F110 (b), split out.|I built a guard that reads where '>' really writes. Two cold reviews each found writes into the folder it let through. You chose to put the old rule back and give (b) its own session." \
    "F115 + F114 + N1.|A check broken since S135 works again · a new project's ledger speaks · ground-truth block reasons reach the agent." \
    "Found on the way.|verify-133 has been red since S181 (3–4 old checks, same at main) → backlog."
}

slide_before_after() {
  dk_section before_after "the change · the same project, the same claim, before and after"
  dk_h2 "Before → After"
  dk_p "The input: a fresh 'vajra init' project at its own session 132, with one 'I followed the advice' claim nobody checked. Left: Vajra at $OLD_SHA. Right: today's."
  local before after
  dk_run_v claim "$OLD_VAJRA"; before="$_DK_OUT"
  dk_run_v claim vajra; after="$_DK_OUT"
  dk_compare "BEFORE|vajra at $OLD_SHA" "$before" "AFTER|vajra today · live" "$after"
  echo
  dk_check "before: blocked (exit 1)" bash -c 'printf "%s" "$1" | grep -q "exit 1"' _ "$before"
  dk_check "after: warns, says why, exit 0" bash -c 'printf "%s" "$1" | grep -q "exit 0" && printf "%s" "$1" | grep -q "no \`obeyed_blocks_from:\`"' _ "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What the guard does now"
  dk_table "The command names the approvals folder and…|Guard now" \
    "redirects output anywhere ('>')|BLOCKED — as before; the message now says: write it to a file, then git commit -F" \
    "reaches it with '..' or from a working folder inside it|BLOCKED (new)" \
    "runs find -delete, git checkout, rsync, curl -o, sponge|BLOCKED (new)" \
    "runs sh, bash, eval, source, awk, an editor — even as /usr/bin/awk|BLOCKED (new)" \
    "only reads it (cat, ls, jq, git add)|allowed — as before"
  dk_caption "Honest limit: a path built while the command runs (d=.ai; d=\$d/appr…) still gets past — the guard reads text, it is not a sandbox."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v write_tool "$DK_TMP/old-guard.sh"
  dk_term "1 · the Write tool into .ai/hooks/../approvals/x — guard at $OLD_SHA" "$_DK_OUT"
  dk_check "it got through" bash -c 'printf "%s" "$1" | grep -q allowed' _ "$_DK_OUT"
  dk_run_v write_tool "$ROOT/scripts/hook-approvals-guard.sh"
  dk_term "2 · the same, guard today" "$_DK_OUT"
  dk_check "blocked" bash -c 'printf "%s" "$1" | grep -q BLOCKED' _ "$_DK_OUT"
  dk_run_v guard "$ROOT/scripts/hook-approvals-guard.sh" "find $D -delete"
  dk_term "3 · a write tool the old guard did not know" "$_DK_OUT"
  dk_check "blocked" bash -c 'printf "%s" "$1" | grep -q BLOCKED' _ "$_DK_OUT"
  dk_run_v guard "$ROOT/scripts/hook-approvals-guard.sh" "$COMMIT"
  dk_term "4 · F110, still open: a commit message naming the folder, with an email in <angle brackets>" "$_DK_OUT"
  dk_check "still blocked (F110 split out)" bash -c 'printf "%s" "$1" | grep -q BLOCKED' _ "$_DK_OUT"
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
    "scripts/verify-session-186.sh — real-run checks; each fix is run at $OLD_SHA too|31 / 31" \
    "scripts/verify-session-132.sh — incl. the --advance check red since S135|13 / 13"
  dk_verdict "HONEST NOTES" \
    "F110 is NOT fixed: a command that names the folder and has any '>' still blocks, even a commit message. Split out by your call after two cold reviews found holes in the fix." \
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
