#!/usr/bin/env bash
# Session 201 demo — the S200 small fixes: N24 (a review-only session's steps), N22 (verify-178/demo-178 retired),
# N25 (reinstall after a merge, Vajra's own repo) and the README "tested with" line in the founder's words.
# A terminal deck (DECISION-009): run it bare in a terminal; piped it prints every slide + the markers.
# Every step-list check runs the REAL `vajra` on a `vajra init` project — today's, and the one at the commit S201
# started from (edb92e3).
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="201"
OLD_SHA=edb92e3    # the commit S201 started from — pinned, never `main`
# ========================

NEW="$ROOT/target/release/vajra"; OLD="$ROOT/target/s201-old/release/vajra"
cargo build --release -q || { echo "demo: cargo build failed" >&2; exit 1; }
if [ ! -x "$OLD" ]; then
  . "$ROOT/scripts/lib-old-checkout.sh"
  WT=$(vajra_old_checkout "$OLD_SHA") || exit 1
  (cd "$WT" && CARGO_TARGET_DIR="$ROOT/target/s201-old" cargo build --release -q) || exit 1
  vajra_old_checkout_remove "$WT"
fi

W="$ROOT/target/s201-demo-$$"; rm -rf "$W"; mkdir -p "$W"; trap 'rm -rf "$W"' EXIT
human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            -u VAJRA_AGENT_MARK -u CLAUDE_PROJECT_DIR GIT_CONFIG_GLOBAL=/dev/null "$@"; }
# A `vajra init` project on review-only session 10, the steps before the sign-off done (a recorded tech-lead,
# a filled Delta, the founder's approval), no report written yet — where S200 stood.
P="$W/gt"; mkdir -p "$P"
(cd "$P" && human git init -q -b main && human "$NEW" init </dev/null >/dev/null 2>&1 \
  && echo 09 > .ai/SESSION && cp prompts/01-task-kickoff.md prompts/10-task-review.md \
  && human git checkout -qb session-10-review \
  && perl -0pi -e 's/- `\+` <what this session ADDS[^\n]*\n- `~` <[^\n]*\n- `-` <[^\n]*/- `+` sessions\/session-10-ground-truth.md, the review of sessions 6 to 9/' prompts/10-task-review.md \
  && printf 'crew researcher — deferred-budget — budget: 1 tokens — a stand-in verdict\n' > "$W/tl.md" \
  && human "$NEW" next --role tech-lead --from "$W/tl.md" >/dev/null 2>&1 \
  && mkdir -p .ai/approvals && printf '{"session": 10, "method": "approve-command", "at_unix": 1}\n' > .ai/approvals/session-10.json)
# list <bin> [session] → the scripts lines and the next step, as `vajra next --steps` prints them
list() { (cd "$P" && human "$1" next --steps "${2:-10}" 2>&1) | grep -E 'checks run|demo script|NEXT STEP|how:' | cut -c1-150 | fold -w 92; }

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "SMALL FIXES|4 done|N24 · N22 · N25 · README"
  dk_h1 "The review session's list " "now tells the truth" " — and the README says which models we tried."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "In S200 the to-do list said 'show the founder the report' before anyone had written it, and marked two script steps as missing that a review session never needs. Your installed vajra was also older than the code, and nothing said to update it." \
    "Now the list says 'write the report first', the two steps say 'not needed', Vajra's own merge step says to reinstall, two old broken scripts are marked retired, and the README carries your 'tested with' line."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "N24 — the review session's list.|Before the report exists, the sign-off step says to write it first. The check-script and demo steps say 'not needed' — the close already skips them for a review session." \
    "N25 — reinstall after a merge.|Only in Vajra's own repo: the merge step adds 'if src/ changed, run cargo install --path . --locked'. Other projects never see it." \
    "N22 — two old scripts retired.|verify-178 and demo-178 compare old wording that later sessions changed on purpose. Marked RETIRED at the top; not one check line touched." \
    "Your README line.|'Tested with: Claude Code on Opus and on Haiku 4.5…' — your words, as you picked them."
  dk_caption "Review session = the every-5th session that writes no code, only a report you sign off."
}

slide_before_after() {
  dk_section before_after "the change · the same project, before and after"
  dk_h2 "Before → After"
  dk_p "A review-only session 10, no report written yet. We ask 'vajra next --steps'. Left: vajra at $OLD_SHA. Right: today's."
  local b a
  b=$(list "$OLD"); a=$(list "$NEW")
  dk_compare "BEFORE|vajra at $OLD_SHA" "$b" "AFTER|vajra today · live" "$a"
  echo
  dk_check "before: 'show the founder' a report nobody wrote; both script steps ✗" bash -c 'printf "%s" "$1" | tr -d "\n" | grep -q "how: show the founder sessions/session-10-ground-truth" && printf "%s" "$1" | grep -q "✗ the checks run"' _ "$b"
  dk_check "after: 'write the report' first; both script steps ✓ not needed" bash -c 'printf "%s" "$1" | tr -d "\n" | grep -q "how: write sessions/session-10-ground-truth.md" && printf "%s" "$1" | grep -q "✓ the checks run and pass — not needed"' _ "$a"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "Who decides 'not needed'"
  dk_table "Step|Review session|Code session" \
    "write the report, then you sign it off|yes — first|no such step" \
    "check script + demo script|not needed (the close skips them)|needed, as before" \
    "reinstall vajra after the merge|Vajra's own repo only|Vajra's own repo only"
  dk_caption "No new rule: the list asks the same helper the close check asks. The reinstall line is a note, not a block."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  local a
  mkdir -p "$P/sessions"; echo '# GT' > "$P/sessions/session-10-ground-truth.md"
  a=$( (cd "$P" && human "$NEW" next --steps 10 2>&1) | grep 'how:' | cut -c1-150 | fold -w 92)
  dk_term "1 · the same session, report written" "$a"
  dk_check "now it says: show the founder the report" bash -c 'printf "%s" "$1" | tr -d "\n" | grep -q "how: show the founder sessions/session-10-ground-truth.md;"' _ "$a"
  rm -f "$P/sessions/session-10-ground-truth.md"

  a=$(list "$NEW" 9 | grep -E 'checks run|demo script')
  dk_term "2 · a code session (9) in the same project" "$a"
  dk_check "a code session still owes both scripts" bash -c 'printf "%s" "$1" | grep -q "✗ the checks run and pass" && ! printf "%s" "$1" | grep -q "not needed"' _ "$a"

  a=$(cargo test -q --lib only_vajras_own_repo_is_told_to_reinstall_after_the_merge 2>&1 | grep 'test result')
  dk_term "3 · the reinstall note: Vajra's repo yes, another project no" "$a"
  dk_check "the reinstall test ran and passed" bash -c 'printf "%s" "$1" | grep -q "ok. 1 passed"' _ "$a"

  a=$(grep -A3 'Tested with' README.md)
  dk_term "4 · README.md" "$a"
  dk_check "your words are in the README" grep -qF '**Tested with:** Claude Code on Opus and on Haiku 4.5.' README.md
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-201.sh (5 rows; each red at $OLD_SHA)|see the summary" \
    "the full cargo test · CI's lint|see the summary"
  dk_verdict "HONEST NOTES" \
    "The reinstall note is proven by a unit test and the file line, not by a live merge: the merge step only shows at the very end of a session." \
    "verify-178 / demo-178 still fail when run — retired means 'history', not 'fixed'."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next — 3 ranked options (the same as the summary)"
  dk_table " |Option|Why pick it · the risk" \
    "1|(your pick) pause Vajra development; use it on another project|does it help a real project, by that project's goals? · risk: no measure written down = 'it felt fine'" \
    "2|rudra S22, synced|today's fixes on a real project · risk: still Vajra-centred, long and paid" \
    "3|cut the start cost (boot diet)|every session loads 95 KB at start · risk: more Vajra development, which you paused"
  dk_table "word|meaning" \
    "review session|the every-5th session: a report, no code, your sign-off" \
    "step list|'vajra next --steps' — the session's to-do list, ✓ or ✗" \
    "reinstall|rebuild the vajra on your machine from the merged code"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
