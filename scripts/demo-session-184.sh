#!/usr/bin/env bash
# Session 184 demo — three small fixes the founder said yes to before rudra session 17: F103 (`vajra init`
# no longer waits forever on a silent pipe), F107 (the "unchecked claims" warning stops quoting Vajra's
# own session number to projects), F108 (two close-check modes stop leaving empty folders). Drawn with
# scripts/demo-kit.sh (DECISION-009/010): every claim runs live; the "before" is the commit S184 started
# from. Try it: DEMO_MODE=stream bash scripts/demo-session-184.sh (gate view) · bare in a terminal (deck).

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="184"
OLD_SHA=e1c348e    # the commit S184 started from — pinned, never `main`
# ========================

cargo build --release -q 2>/dev/null
export PATH="$ROOT/target/release:$PATH"
# the binary as it was at $OLD_SHA (verify-session-184.sh builds the same one into the same place)
OLD_VAJRA="$ROOT/target/s184-old/release/vajra"
if [ ! -x "$OLD_VAJRA" ]; then
  git worktree add --detach "$DK_TMP/old" "$OLD_SHA" >/dev/null 2>&1 \
    && (cd "$DK_TMP/old" && CARGO_TARGET_DIR="$ROOT/target/s184-old" cargo build --release -q 2>/dev/null)
  git worktree remove --force "$DK_TMP/old" >/dev/null 2>&1
fi

# a fresh `vajra init` project, one session commit, one unchecked `obeyed:` claim
P="$DK_TMP/proj"; mkdir -p "$P"
(cd "$P" && git init -q && vajra init </dev/null >/dev/null 2>&1 && git add -A \
  && git -c core.hooksPath=/nonexistent commit -qm scaffold && git checkout -q -b session-01-kickoff \
  && echo "# s01" > notes.md && git add notes.md && git -c core.hooksPath=/nonexistent commit -qm s01 \
  && printf '\n## Advice\n- tech-lead rec 1 — obeyed: %s (done)\n' "$(git rev-parse --short HEAD)" >> prompts/01-task-kickoff.md)
git show "$OLD_SHA:scripts/verify-closeout-scaffold.sh" > "$DK_TMP/old-scaffold.sh" 2>/dev/null

# silent_init BIN → `vajra init` on a pipe that stays open and says nothing; gives up watching at 15 s
silent_init() {
  local d; d="$(mktemp -d "$DK_TMP/init.XXXX")"; (cd "$d" && git init -q); mkfifo "$d.in"
  sleep 30 > "$d.in" & local sp=$!
  (cd "$d" && "$1" init < "$d.in" > /dev/null 2> "$d.err") & local ip=$! s=$SECONDS
  while kill -0 "$ip" 2>/dev/null && [ $((SECONDS - s)) -lt 15 ]; do sleep 1; done
  if kill -0 "$ip" 2>/dev/null; then kill "$ip" 2>/dev/null; echo "still waiting after 15 s (stopped by hand)"
  else echo "finished after $((SECONDS - s)) s"; grep -m1 'Project name' "$d.err"; fi
  kill "$sp" 2>/dev/null
}
# warning BIN → the "unchecked claim" summary line the project sees
warning() { (cd "$P" && "$1" next --check-obeyed 1 2>&1) | grep '⚠' | tail -1; }
# folders SCRIPT MODE → close-log folders before → after one run of MODE
folders() {
  local a b; a=$(ls "$P/.ai/verify/closeout" 2>/dev/null | wc -l | tr -d ' '); sleep 1
  CLAUDE_PROJECT_DIR="$P" bash "$1" "$2" >/dev/null 2>&1
  b=$(ls "$P/.ai/verify/closeout" 2>/dev/null | wc -l | tr -d ' '); echo "$2 · close-log folders: $a → $b"
}
# piped_init → answers piped in all at once still land
piped_init() {
  local d; d="$(mktemp -d "$DK_TMP/piped.XXXX")"; (cd "$d" && git init -q)
  (cd "$d" && printf 'acme-app\nship the charts\nL3\n' | vajra init >/dev/null 2>&1)
  grep -m1 -o 'acme-app' "$d/.ai/AGENTS.md"; grep -m1 '^maturity:' "$d/.ai/CONSTRAINTS.yaml"
}

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "FIXES|3|F103 F107 F108"
  dk_h1 "Three small fixes " "you said yes to" ", each proven against the old version."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: 'vajra init' could wait forever on silent input · rudra's close log said 'threshold: session 132', Vajra's own numbering · two close modes left empty folders." \
    "New: init waits 10 s, then uses the defaults and says so · the warning uses words any project understands · no empty folders."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "F103.|A silent open pipe (a CI step, a tool shell) hung 'vajra init'. Now each answer waits 10 s; then every question left gets its default, named on screen. A real terminal has no timer." \
    "F107.|The 'nobody checked this claim' warning told rudra 'threshold: session 132'. Same warning, plain words, no Vajra number." \
    "F108.|'--ledger' and '--ledger-verify' left an empty dated folder, like '--inputs-sha' did before S183." \
    "rudra S17.|You ran it: 21 pass, 0 fail, 2 honest WARNs, 8 of 8 stations for the first time. Five findings: three rudra's own (F109, F111, F112), two Vajra's (F110 guard false block, F113) for S185." \
    "Your calls.|Vajra does not police downloads · the guard false block goes to the S185 review · Vajra's close does not run the tests."
}

slide_before_after() {
  dk_section before_after "the change · the same silent pipe, before and after"
  dk_h2 "Before → After"
  dk_p "The input: 'vajra init' with its input wired to a pipe that never says anything. Left: Vajra at $OLD_SHA. Right: today's."
  local before after
  dk_run_v silent_init "$OLD_VAJRA"; before="$_DK_OUT"
  dk_run_v silent_init "$ROOT/target/release/vajra"; after="$_DK_OUT"
  dk_compare "BEFORE|vajra at $OLD_SHA" "$before" "AFTER|vajra today · live" "$after"
  echo
  dk_check "before: still waiting after 15 s" bash -c 'printf "%s" "$1" | grep -q "still waiting"' _ "$before"
  dk_check "after: finished, with the default name, and said so" \
    bash -c 'printf "%s" "$1" | grep -q "finished after" && printf "%s" "$1" | grep -q "my-project  (default"' _ "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What Vajra does now"
  dk_table "Thing|Vajra now" \
    "init on a real terminal|waits for you, as long as you take — exactly as before" \
    "init on piped answers|reads them at once — exactly as before" \
    "init on a silent pipe|waits 10 s for an answer, then uses the default for it and every later question, and prints which" \
    "the unchecked-claims warning|says nobody checked, that it is named not blocked, and how to check one" \
    "--ledger, --ledger-verify|leave no folder behind (in a project with no reviews yet, --ledger still fails silently: F114, S185)"
  dk_caption "Honest limit: the numbering behind the warning is still Vajra's — a project reaching its own session 132 starts blocking unchecked claims; only the words changed."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v warning "$OLD_VAJRA"
  dk_term "1 · F107 before ($OLD_SHA): the warning a project sees" "$_DK_OUT"
  dk_check "it quoted Vajra's session 132" bash -c 'printf "%s" "$1" | grep -q "threshold: session 132"' _ "$_DK_OUT"
  dk_run_v warning vajra
  dk_term "2 · F107 now: the same project, the same claim" "$_DK_OUT"
  dk_check "no '132', and it still says it is not blocking" \
    bash -c '! printf "%s" "$1" | grep -qE "132|threshold" && printf "%s" "$1" | grep -q "does not block"' _ "$_DK_OUT"
  dk_run_v folders "$DK_TMP/old-scaffold.sh" --ledger
  dk_term "3 · F108 before ($OLD_SHA): one --ledger run" "$_DK_OUT"
  dk_check "it added a folder" bash -c 'printf "%s" "$1" | grep -qE "folders: ([0-9]+) → ([0-9]+)$" && ! printf "%s" "$1" | grep -qE "folders: ([0-9]+) → \1$"' _ "$_DK_OUT"
  dk_run_v folders "$P/scripts/verify-closeout.sh" --ledger-verify
  dk_term "4 · F108 now: one --ledger-verify run" "$_DK_OUT"
  dk_check "no new folder" bash -c 'printf "%s" "$1" | grep -qE "folders: ([0-9]+) → \1$"' _ "$_DK_OUT"
  dk_run_v piped_init
  dk_term "5 · F103 control: answers piped in all at once" "$_DK_OUT"
  dk_check "all three land (name and maturity L3)" bash -c 'printf "%s" "$1" | grep -q acme-app && printf "%s" "$1" | grep -q "maturity: L3"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-184.sh — real-run checks; each FIX has one that is red at $OLD_SHA|14 / 14" \
    "rudra S17 close (the founder's run)|21 pass · 0 fail · 2 WARN · 0 WAIVED · 8/8 stations"
  dk_verdict "HONEST NOTES" \
    "The 10 s wait is a guess that fits every script in this repo; a slow program feeding answers more than 10 s apart would get defaults." \
    "Not fixed, by your call: F109–F112 are rudra's own; the guard's false block (F110) waits for the S185 review."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "A|S185 ground truth — the review-only session (due now)|every 5th session; F110 and S182's parked guard recs are on its list · risk: no code, it may say 'rethink'" \
    "B|F67: the receipt reads the tool's own cost|rudra S17 read ~\$110, ~5× real · risk: Claude Code may not expose it" \
    "C|the non-Claude tools brainstorm (F91, F94, F95)|parked since S179 · risk: a design session, nothing a user runs yet"
  dk_table "word|meaning" \
    "pipe|input fed to a program from another program, not typed by a person" \
    "default|the answer Vajra uses when none is given (my-project, first session, L2)" \
    "obeyed claim|the agent saying 'I did what the advisor recommended', with a commit"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
