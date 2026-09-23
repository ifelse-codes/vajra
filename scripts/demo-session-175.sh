#!/usr/bin/env bash
# Session 175 demo — deliverable 0 (the ground-truth cadence becomes config) and the
# publish-guard merge fix found live in the founder's rudra session 06.
# Built on scripts/demo-kit.sh (DECISION-009/010). Every panel is a live run.
set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="175"
OLD_SHA="4bd8b00"          # main before S175: the merge of S174
# ========================
export VAJRA_BIN="${VAJRA_BIN:-$ROOT/target/release/vajra}"
BIN="$VAJRA_BIN"
unset VAJRA_ALLOW_COMMIT VAJRA_ALLOW_PUBLISH VAJRA_ENFORCE_PUBLISH CLAUDECODE CLAUDE_CODE_ENTRYPOINT CURSOR_TRACE_ID VAJRA_AGENT
OLD="$DK_TMP/old"; mkdir -p "$OLD"
git show "$OLD_SHA:scripts/hook-pre-bash.sh" > "$OLD/hook-pre-bash.sh"
git show "$OLD_SHA:scripts/hook-publish-guard.sh" > "$OLD/hook-publish-guard.sh"
gx() { git -C "$1" -c user.email=d@d -c user.name=d -c commit.gpgsign=false "${@:2}"; }

fixture() { # $1 constraints-body $2 branch -> prints project dir
  local P="$DK_TMP/fx-$RANDOM$RANDOM"; mkdir -p "$P/.ai"; printf '%s\n' "$1" > "$P/.ai/CONSTRAINTS.yaml"
  gx "$P" init -q -b main; gx "$P" commit -q --allow-empty -m i; gx "$P" checkout -q -b "$2"
  printf '%s' "$P"
}
WITH_180=$'maturity: L2\nground_truth_next_session: 180'

slide_headline() {
  dk_section headline "session $SESSION · rudra session 06 · 2026-09-23"
  dk_h1 "Session 175 " "was a multiple of 5" " — it would have blocked itself."
  dk_p "The founder said: keep the rudra test going, no review-only session until 180. But 'ground truth' was hardcoded as every 5th session in six places — including a hook that BLOCKS git commit. This session would have exited 2 on its own first commit. We moved the rule to config first, then fixed a second gap his rudra run found: a merge-everything switch that let the agent merge its own pull requests, unsupervised."
  dk_vajra_tiles "$SESSION"
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: N % 5 == 0 was ground truth, hardcoded in 6 files, no override. VAJRA_ALLOW_PUBLISH=1 allowed git push, gh pr create, AND gh pr merge — no distinction." \
    "New: .ai/CONSTRAINTS.yaml#ground_truth_next_session names the next one explicitly (180); absent, every project is unchanged. VAJRA_ALLOW_PUBLISH=1 no longer allows a merge — merge stays human, always, no env var."
  dk_caption "live = ran just now · recorded = measured at close, not re-run here · filled in by Vajra = derived, never typed"
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What this session did"
  dk_bullets \
    "Deliverable 0, before anything else.|175 % 5 == 0. Under the old rule this session's own hook-pre-bash.sh would have blocked its first git commit — not a paperwork gap, a live block." \
    "The founder's prompt named 2 scripts; the bug was in 6.|hook-session-start.sh and verify-closeout.sh, plus 3 live enforcement/advisory hooks the prompt did not mention: hook-pre-bash.sh, hook-pre-write.sh, hook-prompt-submit.sh, hook-stop.sh." \
    "He ran rudra session 06 under the fix; it worked.|Boot said 'session 05 is merged — session 06 starts here'; the 4 waiting Vajra files were named and committed; zero commit blocks fired." \
    "But he'd launched with VAJRA_ALLOW_PUBLISH=1 — new.|That gate never distinguished push/open-PR from merge. The agent ran gh pr merge on both its PRs, itself. F55 (S173) said merge stays human." \
    "Founder's call, asked plainly: fix it.|VAJRA_ALLOW_PUBLISH=1 now stops short of merge — the same boundary VAJRA_ALLOW_COMMIT already respected."
  dk_caption "One fix removes a live self-block; the other closes a gap this session's own dogfood run found, not a fix planned in advance."
}

slide_before_after() {
  dk_section before_after "the change · two real runs · the same input"
  dk_h2 "Before → After"
  dk_p "The input: rudra session 06's own launch, replayed. Left: the publish guard at $OLD_SHA (main before this session), read out of git. Right: today's."
  local PG; PG=$(fixture "maturity: L2" session-06-x)
  pgrun() { jq -n --arg c "$2" '{tool_input:{command:$c}}' \
    | env VAJRA_ENFORCE_PUBLISH=1 VAJRA_ALLOW_PUBLISH=1 CLAUDE_PROJECT_DIR="$3" bash "$1" 2>&1; }
  local before after brc arc
  dk_run_v pgrun "$OLD/hook-publish-guard.sh" 'gh pr merge 7 --merge --delete-branch' "$PG"; brc=$_DK_RC
  before="exit $brc
$(printf '%s\n' "$_DK_OUT" | sed -n '1,3p' | cut -c1-46)"
  dk_run_v pgrun "$ROOT/scripts/hook-publish-guard.sh" 'gh pr merge 7 --merge --delete-branch' "$PG"; arc=$_DK_RC
  after="exit $arc
$(printf '%s\n' "$_DK_OUT" | sed -n '1,4p' | cut -c1-46)"
  dk_compare "BEFORE|publish guard at $OLD_SHA" "$before" "AFTER|publish guard today · live" "$after"
  dk_caption "This is rudra session 06's exact merge command, replayed against both hooks, right now."
  echo
  dk_check "before: VAJRA_ALLOW_PUBLISH=1 let the merge through (exit 0 — the bug)" \
    bash -c '[ "$1" = 0 ]' _ "$brc"
  dk_check "after: the same launch, the same command, now BLOCKED (exit 2)" \
    bash -c '[ "$1" = 2 ]' _ "$arc"
  dk_check "and it says why: merging stays with the human, always" \
    bash -c 'printf "%s" "$1" | grep -q "Merging stays with the human"' _ "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words · every verdict below is live"
  dk_h2 "175 was a multiple of 5. It is not ground truth."
  dk_p ".ai/CONSTRAINTS.yaml#ground_truth_next_session names the next review-only session explicitly. Every one of the 6 sites checks it first, falling back to N % 5 == 0 only when it is absent."
  local PG175 PG180
  PG175=$(fixture "$WITH_180" session-175-x); PG180=$(fixture "$WITH_180" session-180-x)
  local commit_json; commit_json="$(jq -n --arg c 'git commit -m x' '{tool_input:{command:$c}}')"
  dk_run_v bash -c "printf '%s' '$commit_json' | CLAUDE_PROJECT_DIR='$PG175' bash '$ROOT/scripts/hook-pre-bash.sh'"
  local r175="$_DK_OUT" rc175=$_DK_RC
  dk_run_v bash -c "printf '%s' '$commit_json' | CLAUDE_PROJECT_DIR='$PG180' bash '$ROOT/scripts/hook-pre-bash.sh'"
  local r180="$_DK_OUT" rc180=$_DK_RC
  dk_term "hook-pre-bash.sh, session-175, key=180 — git commit" "exit $rc175 (was exit 2 under the old rule)"
  dk_term "hook-pre-bash.sh, session-180, key=180 — git commit" "exit $rc180 (real ground truth, still enforced)"
  dk_check "session 175 (key=180): commit NOT blocked — the live self-block this session fixes" \
    bash -c '[ "$1" = 0 ]' _ "$rc175"
  dk_check "session 180 (key=180): commit IS blocked — real ground truth still holds" \
    bash -c '[ "$1" = 2 ]' _ "$rc180"
  local -a rows
  rows+=("key absent|old N % 5 == 0 rule|byte-for-byte unchanged, every other project")
  rows+=("key present, N == key|ground truth (blocked/advised)|180 in this repo, today")
  rows+=("key present, N != key|plain CODE session|175, 176, 179 — and every other former multiple of 5")
  dk_table "Constraint|Verdict|Where" "${rows[@]}"
  dk_caption "scripts/verify-session-175.sh AC1 runs all 6 sites for real, plus verify-closeout.sh's own is_ground_truth_session(), extracted and executed."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "The two escape hatches, checked side by side"
  local PG; PG=$(fixture "maturity: L2" session-06-x)
  pg() { jq -n --arg c "$2" '{tool_input:{command:$c}}' | env "${@:3}" CLAUDE_PROJECT_DIR="$PG" bash "$1" 2>&1; }
  # 1 — VAJRA_ALLOW_PUBLISH still covers push + PR-open.
  dk_run_v pg "$ROOT/scripts/hook-publish-guard.sh" 'git push -u origin session-06-x' VAJRA_ENFORCE_PUBLISH=1 VAJRA_ALLOW_PUBLISH=1
  dk_term "1 · git push, VAJRA_ALLOW_PUBLISH=1" "$(printf '%s\n' "$_DK_OUT" | cut -c1-90)"
  dk_check "still allowed — this session did not touch push or PR-open" \
    bash -c 'printf "%s" "$1" | grep -q ALLOWED' _ "$_DK_OUT"
  # 2 — VAJRA_ALLOW_COMMIT's merge exclusion (F55, S173) is untouched.
  dk_run_v pg "$ROOT/scripts/hook-publish-guard.sh" 'gh pr merge 6' VAJRA_ALLOW_COMMIT=06
  dk_term "2 · gh pr merge, VAJRA_ALLOW_COMMIT=06 (the F55 path)" "$(printf '%s\n' "$_DK_OUT" | cut -c1-90)"
  dk_check "still blocked, never told 'approved' — this session did not touch this path" \
    bash -c '! printf "%s" "$1" | grep -q "You ARE approved"' _ "$_DK_OUT"
  # 3 — a glab merge request, the same fix.
  dk_run_v pg "$ROOT/scripts/hook-publish-guard.sh" 'glab mr merge 3' VAJRA_ENFORCE_PUBLISH=1 VAJRA_ALLOW_PUBLISH=1
  dk_term "3 · glab mr merge, VAJRA_ALLOW_PUBLISH=1" "$(printf '%s\n' "$_DK_OUT" | cut -c1-90)"
  dk_check "blocked too — the fix covers both gh and glab" \
    bash -c 'printf "%s" "$1" | grep -q "Merging stays with the human"' _ "$_DK_OUT"
}

slide_scorecard() {
  dk_section scorecard "the scorecard"
  dk_h2 "Every check on this deck, and the session's own numbers"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "every check on this deck · live"
  dk_caption "scripts/verify-session-175.sh runs 14 checks, incl. an old-vs-new diff over 10 commands that found exactly one intended difference (merge, under VAJRA_ALLOW_PUBLISH) and none unexpected."
}

slide_next() {
  dk_section next "what is next"
  dk_h2 "Where this leaves us"
  dk_bullets \
    "verify-closeout-scaffold.sh — the file vajra init hands new projects — was NOT touched.|A new project has no reason to move its first ground truth on day one; a tracked, pre-existing scaffold-drift gap, not one this session closes." \
    "The cadence override is one integer, not a schedule.|Moving it again means editing the key again. Fine for a one-time move; not a recurring policy." \
    "F58, F61/F63, the cwd/worktree push test — still not exercised live.|No block fired to retry from this run; no worktree was used. Unchanged from before."
  dk_caption "Every limit above is written in the session summary too, not only said here."
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
