#!/usr/bin/env bash
# Session 197 demo — the known-bug session: the review-only guard reaches every project and only the founder
# opens it (F125 + N17), plus F116, F119, N10. F118 moved out (founder, 2026-10-14).
# A terminal deck (DECISION-009): run it bare in a terminal; piped it prints every slide + the markers.
# Every check runs the REAL `vajra init`, the project's own scaffolded hook fed the JSON Claude Code sends, the
# real `vajra approve` in a pseudo-terminal and real `vajra next` — today's vajra, and the one built at the commit
# S197 started from (eceb6d5).
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="197"
OLD_SHA=eceb6d5    # the commit S197 started from — pinned, never `main`
# ========================

NEW="$ROOT/target/release/vajra"; OLD="$ROOT/target/s197-old/release/vajra"
cargo build --release -q || { echo "demo: cargo build failed" >&2; exit 1; }
if [ ! -x "$OLD" ]; then
  . "$ROOT/scripts/lib-old-checkout.sh"
  WT=$(vajra_old_checkout "$OLD_SHA") || exit 1
  (cd "$WT" && CARGO_TARGET_DIR="$ROOT/target/s197-old" cargo build --release -q) || exit 1
  vajra_old_checkout_remove "$WT"
fi

W="$ROOT/target/s197-demo-$$"; rm -rf "$W"; mkdir -p "$W/bin" "$W/tmp"; trap 'rm -rf "$W"' EXIT
ln -s "$NEW" "$W/bin/vajra"
human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            -u VAJRA_AGENT_MARK -u CLAUDE_PROJECT_DIR GIT_CONFIG_GLOBAL=/dev/null "$@"; }
project() { # project <bin> [session] → a `vajra init` project; committed .ai/SESSION = session (4: session 5 is next,
            # a review-only session by the every-5th rule), on session-05-closeout
  local p="$W/p$RANDOM"; mkdir -p "$p"
  (cd "$p" && human git init -q -b main && human "$1" init </dev/null >/dev/null 2>&1 && echo "${2:-4}" > .ai/SESSION \
     && perl -pi -e 's/\*\*Number:\*\* \d+/**Number:** '"${2:-4}"'/' .ai/SESSION-BOOT.md \
     && human git checkout -qb session-05-closeout && human git add -A \
     && human git -c user.email=t@t -c user.name=t commit -qm init); printf '%s' "$p"
}
# agent_try <project> <tool> <key> <value> → what Claude Code's PreToolUse hooks in that project say to the agent.
agent_try() {
  local p="$1" j out rc=0 h
  j=$(jq -cn --arg t "$2" --arg k "$3" --arg v "$4" \
        '{hook_event_name:"PreToolUse", tool_name:$t, tool_use_id:"toolu_demo", tool_input:{($k):$v}}')
  for h in $(jq -r '.hooks.PreToolUse[] | select(.matcher|test("NotebookEdit")) | .hooks[].command' "$p/.claude/settings.json" \
               | grep -oE '[a-z-]+\.sh'); do
    out=$(cd "$p" && printf '%s' "$j" | human CLAUDE_PROJECT_DIR="$p" PATH="$W/bin:$PATH" TMPDIR="$W/tmp" bash ".ai/hooks/$h" 2>&1) || rc=$?
    [ "$rc" = 2 ] && { printf '%s\n→ BLOCKED' "$out" | fold -w 90; return; }
  done
  echo "→ allowed"
}
founder() { (cd "$1" && shift && human script -q /dev/null "$@" </dev/null >/dev/null 2>&1); }

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "KNOWN BUGS|4 fixed|F125 (+N17) · F116 · F119 · N10 — F118 moved out"
  dk_h1 "In a review-only session, " "only you can let code back in" "."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Every project's rules said 'no code in a review-only session — hook-enforced'. In your projects no hook existed; in Vajra's own, a branch named …-closeout switched it off." \
    "Now every project gets the guard, no branch name opens it, and it opens only when you type 'vajra approve NN --close' after reading the report."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "F125 was filed as 'rudra's agent switched its guard off'.|Checking it, we found rudra never had one: 'vajra init' never shipped it." \
    "You made the call.|Ship the guard to every project; your record is the only way to open it; F118 moves to a later session." \
    "We built it.|One guard script, shipped and wired by 'vajra init' and '--sync-fleet'; a new 'vajra approve NN --close'." \
    "Three small fixes rode along.|The step list names an approval file not yet in git (F116), ticks design when none is needed (F119); a false alarm is gone (N10)."
  dk_caption "review-only session = a ground truth: every 5th session, a check of the project with no code changes."
}

slide_before_after() {
  dk_section before_after "the change · the same commit, before and after"
  dk_h2 "Before → After"
  dk_p "A fresh project, session 5 (review-only), on a branch named session-05-closeout. The agent tries 'git commit'. Left: a project made by vajra at $OLD_SHA. Right: today's."
  local b a
  b=$(agent_try "$(project "$OLD")" Bash command "git commit -m 'add feature'")
  a=$(agent_try "$(project "$NEW")" Bash command "git commit -m 'add feature'")
  dk_compare "BEFORE|vajra at $OLD_SHA" "$b" "AFTER|vajra today · live" "$a"
  echo
  dk_check "before: nothing stopped the commit" bash -c 'printf "%s" "$1" | grep -q "→ allowed"' _ "$b"
  dk_check "after: blocked, and told only the founder opens it" bash -c 'printf "%s" "$1" | grep -q "BLOCKED" && printf "%s" "$1" | grep -q "vajra approve 5 --close"' _ "$a"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "In a review-only session, the agent…"
  dk_table "Tries to…|Before you sign off|After 'vajra approve NN --close'" \
    "write the report, notes under .ai/|allowed|allowed" \
    "change code (src/, prompts/…)|blocked|allowed" \
    "commit, push, open a PR|blocked|allowed" \
    "name its branch …-closeout|opens nothing|—" \
    "use a branch with no session number|guarded as last committed session + 1|—" \
    "write the sign-off file itself|caught, the file stops counting|—"
  dk_caption "Your record lives in .ai/approvals/ — the folder the agent cannot write to (DECISION-011)."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  local p a
  p=$(project "$NEW")
  a=$(agent_try "$p" Write file_path "$p/sessions/session-05-ground-truth.md"); dk_term "1 · the agent writes the report" "$a"
  dk_check "the report is allowed" bash -c 'printf "%s" "$1" | grep -q "→ allowed"' _ "$a"
  founder "$p" "$NEW" approve 5 --close
  a=$(agent_try "$p" Bash command "git commit -m 'review done'"); dk_term "2 · you type 'vajra approve 5 --close', then the agent commits" "$a"
  dk_check "after your sign-off the commit goes through" bash -c 'printf "%s" "$1" | grep -q "→ allowed"' _ "$a"
  p=$(project "$NEW" 6); founder "$p" "$NEW" approve 7
  printf '# Session 7\n## Type\nsession_type: CODE\n## Goal\nfix one thing\n## Design\ndesign-significant: no\n' > "$p/prompts/07-task-fix.md"
  a=$(cd "$p" && human "$NEW" next --steps 7 2>&1 | grep -E 'founder has approved|design is recorded')
  dk_term "3 · the step list: approval not yet in git (F116), no design needed (F119)" "$(printf '%s' "$a" | fold -w 90)"
  dk_check "names the approval file and ticks design" bash -c 'printf "%s" "$1" | grep -q "not in git yet" && printf "%s" "$1" | grep -q "✓ the design is recorded"' _ "$a"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-197.sh (11 rows, each red at $OLD_SHA)|see the summary" \
    "the full cargo test · CI's lint|see the summary"
  dk_verdict "HONEST NOTES" \
    "It raises the bar; it is not a lock: an agent set on it could fake a terminal, edit the guard file, or spell 'git' oddly. A branch with the wrong session number is not seen." \
    "rudra gets it after 'vajra init --sync-fleet' and a Claude Code restart. Still open: F118. New, filed: N18."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next — 3 ranked options (the same as the summary)"
  dk_table " |Option|Why pick it · the risk" \
    "1|rudra S22, synced — the push belt and the review-only guard on a real project|both have only run in temp projects · risk: S22 is a real build, long and paid" \
    "2|the known-bug leftovers: F118 (advance leaves old text) + N18 (drift check sorts by path)|small, each one a user meets · risk: little user-visible value" \
    "3|design: Vajra runs the required reviewer itself (Haiku answer d) + README 'tested with'|the root fix on cheap models · risk: design only; every close then costs money"
  dk_table "word|meaning" \
    "review-only session|every 5th session: check the project, change no code" \
    "sign off|you read the report, then type 'vajra approve NN --close'" \
    "guard|a check Claude Code runs before each command the agent makes"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
