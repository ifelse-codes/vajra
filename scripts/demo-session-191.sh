#!/usr/bin/env bash
# Session 191 demo — four small fixes from the S190 ground truth.
# A terminal deck (DECISION-009): run it bare in a terminal; piped it prints every slide + the markers.
# Every check runs the REAL hook (today's, and the one at the commit S191 started from, f37b0fe) or the
# real unit test. The verify-133 race takes ~3 minutes, so it is recorded here, not re-run.
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="191"
OLD_SHA=f37b0fe    # the commit S191 started from — pinned, never `main`
# ========================

OLDH="$DK_TMP/oldhooks"; mkdir -p "$OLDH"
git show "$OLD_SHA:scripts/hook-pre-write.sh" > "$OLDH/hook-pre-write.sh"
git show "$OLD_SHA:scripts/hook-session-guard.sh" > "$OLDH/hook-session-guard.sh"
cp scripts/lib-ground-truth.sh scripts/hook-approvals-guard.sh "$OLDH/"

# A project in its ground-truth session (185), and a note folder outside it.
P="$DK_TMP/proj"; mkdir -p "$P/src" "$P/.ai"; echo x > "$P/src/x.rs"
printf 'maturity: L2\nsession:\n  ground_truth_every_n_sessions: 5\n  one_session_per_chat: true\n' > "$P/.ai/CONSTRAINTS.yaml"
( cd "$P" && git init -q && git checkout -q -b session-185-x )
OUT=$(mktemp -d /tmp/s191-demo.XXXXXX); trap 'rm -rf "$OUT"' EXIT
write_try() { # write_try <hookdir> <path> → what the guard says, and its exit
  local m rc
  m=$(printf '{"tool_input":{"file_path":"%s"}}' "$2" | CLAUDE_PROJECT_DIR="$P" /bin/bash "$1/hook-pre-write.sh" 2>&1); rc=$?
  printf '%s\nexit %s — %s\n' "${m:-(nothing printed)}" "$rc" "$([ "$rc" = 2 ] && echo BLOCKED || echo allowed)"
}
G="$DK_TMP/sg"; mkdir -p "$G/.ai"; echo 04 > "$G/.ai/SESSION"
printf 'maturity: L2\nsession:\n  one_session_per_chat: true\n' > "$G/.ai/CONSTRAINTS.yaml"
NOTE="cat > notes.md <<'EOF'
Next chat: git checkout -b session-05-fixes
EOF"
guard_try() { # guard_try <hook> <command> → what the session guard says, and its exit
  local m rc; printf '4\tSID\n' > "$G/.ai/.session-owner"
  m=$(jq -n --arg c "$2" '{session_id:"SID",tool_input:{command:$c}}' | CLAUDE_PROJECT_DIR="$G" /bin/bash "$1" 2>&1); rc=$?
  printf '%s\nexit %s — %s\n' "$(printf '%s' "${m:-(nothing printed)}" | head -2)" "$rc" "$([ "$rc" = 2 ] && echo BLOCKED || echo allowed)"
}
code_of() { printf '%s' "$1" | tail -1 | grep -oE 'exit [0-9]+' | grep -oE '[0-9]+'; }

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "FIXES|4|small, each proven red before and green after"
  dk_h1 "Four small fixes: " "two guards that blocked harmless work" ", and two bugs in Vajra's own tooling."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "A review-only session can now write a scratch note OUTSIDE the project. Writing a note that merely mentions starting the next session no longer counts as starting it." \
    "vajra next --advance no longer rewrites other numbers on the session line, and one old check can now run twice at once."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "N2 — your pick from S190.|In a review-only session the write guard blocked even a note in /tmp. Now a write it can PROVE is outside the project goes through; inside, nothing changed." \
    "N13 — the heredoc hole.|Writing a file whose text said 'git checkout -b session-NN-…' tripped the one-chat-per-session guard. Now one exact, safe shape is read as data." \
    "The number swap.|--advance rewrote 'session-188-summary.md' to '189' on the same line. Now only the number after 'Number:' moves." \
    "The race.|Two runs of verify-133 at once used one shared folder and both failed. Each run now gets its own." \
    "Both guard changes are written down.|DECISION-011 S191 addendum: why each loosening is safe, and its limits."
  dk_caption "heredoc = the 'cat > file <<'EOF' … EOF' way of writing a file from the command line."
}

slide_before_after() {
  dk_section before_after "the change · the same write, before and after"
  dk_h2 "Before → After"
  dk_p "A review-only session writes a scratch note to $OUT/n.md (outside the project). Left: the guard at $OLD_SHA. Right: today's."
  local b a
  b=$(write_try "$OLDH" "$OUT/n.md"); a=$(write_try scripts "$OUT/n.md")
  dk_compare "BEFORE|guard at $OLD_SHA" "$b" "AFTER|guard today · live" "$a"
  echo
  dk_check "before: the outside note was blocked" test "$(code_of "$b")" = 2
  dk_check "after: the outside note goes through" test "$(code_of "$a")" = 0
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What each guard lets through now"
  dk_table "The command|Before|Now" \
    "a review-only session writes a file outside the project|blocked|allowed (if its folder exists)" \
    "… writes a file inside the project (not .ai/, scripts/)|blocked|blocked" \
    "… a path with '..' that lands back inside|allowed (a hole)|blocked" \
    "cat > notes.md <<'EOF' … a line about the next session … EOF|blocked|allowed" \
    "the same text fed to bash, or with <<EOF unquoted|blocked|blocked" \
    "git checkout -b session-NN-… typed for real|blocked|blocked"
  dk_caption "Both guard changes are named in DECISION-011's S191 addendum, with what they still cannot see."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v write_try scripts "$P/src/x.rs"
  dk_term "1 · write inside the project during a review-only session" "$_DK_OUT"
  dk_check "still blocked" test "$(code_of "$_DK_OUT")" = 2
  dk_run_v write_try scripts "$P/.ai/../src/x.rs"
  dk_term "2 · the same file through '.ai/../' (passed at $OLD_SHA)" "$_DK_OUT"
  dk_check "now blocked" test "$(code_of "$_DK_OUT")" = 2
  dk_run_v write_try scripts "$OUT/new-folder/n.md"
  dk_term "3 · outside, but the folder does not exist yet" "$_DK_OUT"
  dk_check "blocked, and the message says: mkdir -p it first" bash -c 'printf "%s" "$1" | grep -q "mkdir -p"' _ "$_DK_OUT"
  local b a
  b=$(guard_try "$OLDH/hook-session-guard.sh" "$NOTE"); a=$(guard_try scripts/hook-session-guard.sh "$NOTE")
  dk_compare "BEFORE|session guard at $OLD_SHA" "$b" "AFTER|session guard today" "$a"
  dk_check "4 · a note mentioning the next session: blocked before, allowed now" test "$(code_of "$b")$(code_of "$a")" = 20
  dk_run_v guard_try scripts/hook-session-guard.sh "$(printf "cat <<'EOF' | bash\ngit checkout -b session-05-fixes\nEOF")"
  dk_term "5 · the same text fed to bash" "$_DK_OUT"
  dk_check "still blocked" test "$(code_of "$_DK_OUT")" = 2
  dk_run_v cargo test -q --lib -- update_session_boot_leaves_prose_numbers_alone
  dk_term "6 · --advance on the real S188 line (it names 188 five more times)" "$(printf '%s' "$_DK_OUT" | grep -E 'test result|running')"
  dk_check "only the Number moves; the other five 188s stay" bash -c 'printf "%s" "$1" | grep -q "1 passed"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "scripts/verify-session-191.sh — every fix run at $OLD_SHA too (red) and today (green)|see the summary" \
    "verify-133 twice at once: at $OLD_SHA both runs fail; today 3 rounds, all pass|recorded" \
    "the full cargo test, before the push|see the summary"
  dk_verdict "HONEST NOTES" \
    "The write guard is a speed bump, not a sandbox: in a review-only session Bash could already write anywhere. It cannot see a folder swapped for a link between its check and the write." \
    "The heredoc rule trusts that cat and tee are the real programs. A project gets the new session guard on its next vajra init --sync-fleet with a vajra built from S191 or later."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "1|prove the receipt live (S189 carries)|one tiny paid interactive run with /clear, --continue, a fork · risk: needs your yes and a few cents" \
    "2|rudra S18 under the new rules|first real use of S188 + S189 + S191 in your project · risk: waits on rudra's own work" \
    "3|the non-Claude tools brainstorm (F91/F94/F95)|promised since S179 · risk: a design session, nothing a user runs"
  dk_table "word|meaning" \
    "review-only session|a ground truth — every 5th session, no code allowed" \
    "heredoc|writing a file's text inline: cat > file <<'EOF' … EOF" \
    "guard|a small script Claude Code runs before each command, which can block it"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
