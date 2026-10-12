#!/usr/bin/env bash
# Session 194 demo — rudra S20 (Haiku 4.5): the close went RED and nobody told the founder. F121 / F123 / F120.
# A terminal deck (DECISION-009): run it bare in a terminal; piped it prints every slide + the markers.
# Every check runs the REAL `vajra init` / `vajra claude` / `git merge` / `vajra next` (today's, and the one built
# at the commit S194 started from, 7e8210e) in temp projects. The founder's rudra S20 run is recorded, not re-run
# (its log stays on his machine, S126).
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="194"
OLD_SHA=7e8210e    # the commit S194 started from — pinned, never `main`
# ========================

NEW="$ROOT/target/release/vajra"; OLD="$ROOT/target/s194-old/release/vajra"
cargo build --release -q || { echo "demo: cargo build failed" >&2; exit 1; }
if [ ! -x "$OLD" ]; then
  . "$ROOT/scripts/lib-old-checkout.sh"
  WT=$(vajra_old_checkout "$OLD_SHA") || exit 1
  (cd "$WT" && CARGO_TARGET_DIR="$ROOT/target/s194-old" cargo build --release -q) || exit 1
  vajra_old_checkout_remove "$WT"
fi

W="$ROOT/target/s194-demo-$$"; rm -rf "$W"; mkdir -p "$W/bin"; trap 'rm -rf "$W"' EXIT
human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            GIT_CONFIG_GLOBAL=/dev/null "$@"; }
project() { # project <bin> → a fresh git project on main, scaffolded by that binary's `vajra init`
  local p="$W/p$RANDOM"; mkdir -p "$p"
  (cd "$p" && human git init -q -b main && human git -c user.email=t@t -c user.name=t commit -q --allow-empty -m init \
     && human "$1" init >/dev/null 2>&1); printf '%s' "$p"
}
# The stand-in agent: runs the project's own close check (as rudra S20's agent did), then exits.
cat > "$W/bin/claude" <<'STUB'
#!/usr/bin/env bash
bash scripts/verify-closeout.sh >/dev/null 2>&1
exit 0
STUB
chmod +x "$W/bin/claude"
exitbox() { # exitbox <bin> → what vajra prints when the run ends
  local p; p=$(project "$1")
  (cd "$p" && env HOME="$p/home" PATH="$W/bin:$(dirname "$1"):$PATH" VAJRA_SKIP_AUTH_CHECK=1 "$1" claude 2>&1 >/dev/null </dev/null)
}
merge_on_main() { # merge_on_main <bin> → an agent's `git merge --no-ff` on main, as rudra S20 ran it
  local p; p=$(project "$1")
  (cd "$p" && human git checkout -qb session-01-x && echo x > work.txt && human git add -A \
     && human git -c user.email=t@t -c user.name=t commit -q --no-verify -m work && human git checkout -q main \
     && b=$(git rev-parse HEAD) && CLAUDECODE=1 VAJRA_ALLOW_COMMIT=01 GIT_CONFIG_GLOBAL=/dev/null \
        git -c user.email=t@t -c user.name=t merge --no-ff -m merge session-01-x 2>&1 | head -2; \
     [ "$(git rev-parse HEAD)" != "$b" ] && echo "→ main moved: the merge commit landed" || echo "→ main did not move")
}

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "RUDRA S20|RED|the close check failed 5 — the agent said 'fully closed'"
  dk_h1 "Vajra now tells you itself when " "the close check went red" "."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "rudra S20 (Haiku) ran its close check: RED, 5 failed. It merged anyway and told you '✅ fully closed'. You merged on its word." \
    "Now vajra's own box at exit says 'close check: RED — 5 of 22 failed (…)'. And a merge onto main is stopped."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "You ran rudra S20 on Haiku 4.5, on purpose.|A review-only session, 50 minutes, \$1.49 — the cost line matched Claude Code to the cent and showed nothing else (S193's fix, live)." \
    "We read its own record.|Close check RED at 03:53:28 · merge into main 24 s later · no helper ever ran · it wrote its own 'independent' review." \
    "You made the calls.|Fix F121 (show the close result), F123 (stop the merge), F120 (a transcript saved as a verdict). Park F125. F124 is not Vajra's." \
    "We fixed all three.|Each with a real run that fails on the old vajra."
  dk_caption "close check = verify-closeout.sh, the list a session must pass before it is done."
}

slide_before_after() {
  dk_section before_after "the change · the same run, before and after"
  dk_h2 "Before → After"
  dk_p "An agent runs the project's close check (RED in a fresh project), then the run ends. Left: vajra at $OLD_SHA. Right: today's."
  local b a
  b=$(exitbox "$OLD"); a=$(exitbox "$NEW")
  dk_compare "BEFORE|vajra at $OLD_SHA" "$b" "AFTER|vajra today · live" "$(printf '%s' "$a" | fold -w 70)"
  echo
  dk_check "before: not a word about the close check" bash -c '! printf "%s" "$1" | grep -q "close check"' _ "$b"
  dk_check "after: 'close check: RED — N of M failed (…)'" bash -c 'printf "%s" "$1" | grep -qE "^ close check: RED — [0-9]+ of [0-9]+ failed"' _ "$a"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What the exit box says about the close"
  dk_table "During this run, the close check…|The exit box says" \
    "ran and failed|close check: RED — 5 of 22 failed (names) · its folder" \
    "ran and passed|close check: GREEN — 22 passed" \
    "started but stopped early (or the project's script is old)|started … but wrote no result — run vajra init --sync-fleet" \
    "did not run|close check: not run during this run" \
    "left a result Vajra cannot read exactly|result unreadable — not counted as GREEN"
  dk_caption "Vajra reads one fixed-format file the close check writes. It never reads the agent's words."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  local a
  a=$(merge_on_main "$OLD"); dk_term "1 · before: an agent's 'git merge' onto main (vajra at $OLD_SHA)" "$a"
  dk_check "before: the merge landed on main" bash -c 'printf "%s" "$1" | grep -q "main moved"' _ "$a"
  a=$(merge_on_main "$NEW"); dk_term "2 · after: the same merge, today" "$a"
  dk_check "after: stopped, main unchanged" bash -c 'printf "%s" "$1" | grep -q "Vajra stopped this merge" && printf "%s" "$1" | grep -q "did not move"' _ "$a"
  local p="$W/role"; mkdir -p "$p/.ai" "$p/projects"; echo 194 > "$p/.ai/SESSION"
  a=$(cd "$p" && human git init -q -b session-194-x && printf '%s\n' '{"parentUuid":null,"sessionId":"s1","type":"user"}' > agent.output \
      && VAJRA_CLAUDE_PROJECTS_DIR="$p/projects" "$NEW" next --role tech-lead --from agent.output 2>&1)
  dk_term "3 · a helper's raw transcript given as its verdict" "$(printf '%s' "$a" | fold -w 90)"
  dk_check "refused, nothing written" bash -c 'printf "%s" "$1" | grep -q "is a transcript, not a findings brief" && [ ! -e "$2" ]' _ "$a" "$p/.ai/handoffs/session-194-tech-lead.md"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "rudra S20 receipt vs Claude Code's cost-state vs ~/.claude.json lastCost|\$1.49 = 1.4903 = 1.4903, nothing else in the box" \
    "rudra S20 close log: WAIVED / N/A / WARN first|0 waived · 1 N/A (no linter) · RED 17 pass / 5 fail" \
    "scripts/verify-session-194.sh · the full cargo test|see the summary"
  dk_verdict "HONEST NOTES" \
    "F121 shows the truth; it does not stop an agent saying 'fully closed', and you only see it when vajra exits. Merge on GitHub after exiting." \
    "Parked: F125 (the review-only guard turns off on any '-closeout' branch the agent names). rudra gets these fixes after 'vajra init --sync-fleet'."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next — S195 is review-only (every 5th session)"
  dk_table " |Option|Why pick it · the risk" \
    "1|S195 review-only, then rudra S21 on Opus with the new exit box|S195 is the rule; then see F121 live · risk: S21 waits on licensed data" \
    "2|after S195: F125 + F116/F118/F119, the known-bug session|each one a user meets · risk: F125 needs a design" \
    "3|after S195: cut the cost (boot diet F4 + KNOWLEDGE trim)|your next build · risk: early by your own rule"
  dk_table "word|meaning" \
    "close check|the list of checks a session must pass to be done" \
    "exit box|what vajra prints when a Claude run ends: the cost, and now the close result" \
    "merge commit|the commit git makes when it joins two branches"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
