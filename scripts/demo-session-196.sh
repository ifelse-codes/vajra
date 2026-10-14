#!/usr/bin/env bash
# Session 196 demo — rudra S21 on Opus, and F127: no pull request until the close check is GREEN.
# A terminal deck (DECISION-009): run it bare in a terminal; piped it prints every slide + the markers.
# Every check runs the REAL `vajra init`, the project's own close script and a real `git push` to a real bare
# remote (today's vajra, and the one built at the commit S196 started from, 59719f8). The founder's rudra S21 run
# is recorded, not re-run (its log stays on his machine, S126).
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="196"
OLD_SHA=59719f8    # the commit S196 started from — pinned, never `main`
# ========================

NEW="$ROOT/target/release/vajra"; OLD="$ROOT/target/s196-old/release/vajra"
cargo build --release -q || { echo "demo: cargo build failed" >&2; exit 1; }
if [ ! -x "$OLD" ]; then
  . "$ROOT/scripts/lib-old-checkout.sh"
  WT=$(vajra_old_checkout "$OLD_SHA") || exit 1
  (cd "$WT" && CARGO_TARGET_DIR="$ROOT/target/s196-old" cargo build --release -q) || exit 1
  vajra_old_checkout_remove "$WT"
fi

W="$ROOT/target/s196-demo-$$"; rm -rf "$W"; mkdir -p "$W"; trap 'rm -rf "$W"' EXIT
human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            -u CLAUDE_PROJECT_DIR GIT_CONFIG_GLOBAL=/dev/null "$@"; }
project() { # project <bin> → a `vajra init` project on session-01-x, one commit, a bare remote at <p>.git
  local p="$W/p$RANDOM"; mkdir -p "$p"
  (cd "$p" && human git init -q -b main && human "$1" init </dev/null >/dev/null 2>&1 \
     && echo 1 > .ai/SESSION && human git checkout -qb session-01-x && human git add -A \
     && human git -c user.email=t@t -c user.name=t commit -qm init \
     && human git init -q --bare "$p.git" && human git remote add origin "$p.git"); printf '%s' "$p"
}
# push_red <bin> [human] → the project's own close check (RED in a fresh project), then a push of the branch.
push_red() {
  local p; p=$(project "$1")
  (cd "$p" && human PATH="$(dirname "$1"):$PATH" bash scripts/verify-closeout.sh 1 >/dev/null 2>&1
   echo "\$ bash scripts/verify-closeout.sh   → $(sed -n 's/^verdict: //p' .ai/verify/closeout/2*/result 2>/dev/null | tail -1 || echo '(no result file)')"
   echo "\$ git push origin session-01-x"
   if [ "${2:-}" = human ]; then human git push -q origin session-01-x 2>&1; else human CLAUDECODE=1 git push -q origin session-01-x 2>&1; fi
   human git --git-dir "$p.git" rev-parse -q --verify refs/heads/session-01-x >/dev/null \
     && echo "→ the branch is on the remote: a pull request can open" || echo "→ the branch is NOT on the remote: no pull request")
}
green_then() { # green_then <commit-after:yes|no> → an agent's push after a GREEN result for HEAD
  local p; p=$(project "$NEW"); local d="$p/.ai/verify/closeout/20990101T000000Z"; mkdir -p "$d"
  printf 'vajra-closeout-result: 2\nsession: 1\nhead: %s\nclean: yes\nverdict: GREEN\npass: 20\nfail: 0\nwarn: 0\nfailed: \n' \
    "$(cd "$p" && human git rev-parse HEAD)" > "$d/result"
  (cd "$p"; [ "$1" = yes ] && echo x > later.txt && human git add later.txt \
     && human git -c user.email=t@t -c user.name=t commit -qm "one more commit"
   human CLAUDECODE=1 git push -q origin session-01-x 2>&1
   human git --git-dir "$p.git" rev-parse -q --verify refs/heads/session-01-x >/dev/null \
     && echo "→ on the remote" || echo "→ NOT on the remote")
}

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "RUDRA S21|GREEN|Opus ran every step · 21 passed · \$19.21"
  dk_h1 "No pull request until " "the close check is GREEN" "."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "rudra S20's close check was RED, yet its branch went to GitHub, a PR opened and you merged it. Nothing stopped it." \
    "Now the agent cannot push a session branch until the close check said GREEN for that exact commit. No push, no PR."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "You ran rudra S21 on Opus.|4 helpers called, a real outside review, 18 'vajra next' calls, close GREEN, and 'fully closed' was true. On Haiku (S20) none of that ran." \
    "We found the gap.|The close verdict shows only when you leave the chat — after you merged. A RED close had never stopped anything." \
    "You made the call.|'No PR till it is green.' Stop the agent; warn you, not stop you; session branches only. F126 parked." \
    "We built it.|The close check now writes which commit it checked; the push reads it. Each part fails on the old vajra."
  dk_caption "close check = verify-closeout.sh, the list a session must pass before it is done."
}

slide_before_after() {
  dk_section before_after "the change · the same push, before and after"
  dk_h2 "Before → After"
  dk_p "A fresh project's own close check runs (RED — nothing of a session exists yet), then the agent pushes. Left: vajra at $OLD_SHA. Right: today's."
  local b a
  b=$(push_red "$OLD"); a=$(push_red "$NEW")
  dk_compare "BEFORE|vajra at $OLD_SHA" "$b" "AFTER|vajra today · live" "$(printf '%s' "$a" | fold -w 70)"
  echo
  dk_check "before: the RED branch reached the remote" bash -c 'printf "%s" "$1" | grep -q "branch is on the remote"' _ "$b"
  dk_check "after: refused — 'the close check is RED', not on the remote" bash -c 'printf "%s" "$1" | grep -q "the close check is RED" && printf "%s" "$1" | grep -q "NOT on the remote"' _ "$a"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "When the agent pushes a session branch"
  dk_table "The close check, for the commit being pushed…|The push" \
    "said GREEN (warnings are fine)|goes through — then the PR can open" \
    "said RED|refused: names what failed; fix, run it again until GREEN" \
    "ran before the newest commit|refused: run it again" \
    "ran with files not yet committed|refused: commit them, run it again" \
    "never ran, or is in the old format|refused: run it (or vajra init --sync-fleet first)" \
    "— you push it yourself|a note telling you it is not GREEN; your push goes on" \
    "— a branch not named session-NN-…|not checked (your 2026-09-21 rule)"
  dk_caption "Vajra reads the one result file the close check writes, never the agent's words."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  local a
  a=$(green_then no); dk_term "1 · a GREEN close for this commit, then the agent pushes" "$a"
  dk_check "goes through, says GREEN" bash -c 'printf "%s" "$1" | grep -q "GREEN on" && printf "%s" "$1" | grep -q "→ on the remote"' _ "$a"
  a=$(green_then yes); dk_term "2 · a GREEN, then one more commit, then the push" "$(printf '%s' "$a" | fold -w 90)"
  dk_check "refused: a commit landed after it" bash -c 'printf "%s" "$1" | grep -q "a commit landed after it" && printf "%s" "$1" | grep -q "NOT on the remote"' _ "$a"
  a=$(push_red "$NEW" human); dk_term "3 · YOU push the RED branch" "$(printf '%s' "$a" | fold -w 90)"
  dk_check "a note, and your push goes on" bash -c 'printf "%s" "$1" | grep -q "Note:" && printf "%s" "$1" | grep -q "branch is on the remote"' _ "$a"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "rudra S21 close log: WAIVED / N/A / WARN first|0 waived · 1 N/A · 2 WARN · GREEN 21 pass / 0 fail" \
    "rudra S21 cost: cost-state vs ~/.claude.json lastCost|\$19.2087 = \$19.2087" \
    "Opus S21 vs Haiku S20|4 vs 0 helpers · 18 vs 0 'vajra next' · real vs self-written review · true vs false 'fully closed'" \
    "scripts/verify-session-196.sh · the full cargo test|see the summary"
  dk_verdict "HONEST NOTES" \
    "It raises the bar; it is not a lock: an agent set on cheating could write a fake GREEN file or type 'git push --no-verify'. It never stops your own push." \
    "rudra gets this after 'vajra init --sync-fleet'. Parked: F126 (your late S22 change lived only in the agent's notes)."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next — 3 ranked options (the same as the summary)"
  dk_table " |Option|Why pick it · the risk" \
    "1|S197 — the known-bug session: F125 first (+N17), then F116, F118, F119, N10|each one a user meets · risk: F125's design could grow" \
    "2|rudra S22 synced — the push belt's first real run|proves F127 live · risk: S22 is a real build, long and paid" \
    "3|design: Vajra runs the required reviewer itself (Haiku answer d) + README 'tested with'|the root fix on cheap models · risk: design only; every close then costs money"
  dk_table "word|meaning" \
    "close check|the list of checks a session must pass to be done" \
    "push|sending a branch to GitHub — a pull request needs it first" \
    "session branch|a branch named session-NN-…, where a session's work lives"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
