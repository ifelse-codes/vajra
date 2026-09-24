#!/usr/bin/env bash
# Session 177 demo — F74 + F76: the close gate every Vajra project gets skipped a CODE session's
# CODE checks when the founder moved the next ground truth (F74), or when the brief wrote
# `**CODE.**` (F76 — every rudra brief). Drawn with scripts/demo-kit.sh (DECISION-009/010): every
# claim runs live; the "before" is the gate from the pinned commit this session started from.
# Try it: DEMO_MODE=stream bash scripts/demo-session-177.sh (gate view) · bare in a terminal (deck).

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="177"
OLD_SHA=8061a52    # the commit S177 started from — pinned, never `main` (after the merge main IS new)
RUDRA="${RUDRA:-/Users/suman/playground/rudra}"
# ========================

git show "$OLD_SHA:scripts/verify-closeout-scaffold.sh" > "$DK_TMP/old.sh"
cp scripts/verify-closeout-scaffold.sh "$DK_TMP/new.sh"
# A copy of rudra's real state for session 10: its settings (next ground truth = 15) and its S10
# brief (written `- **CODE.** …`), no scripts yet — exactly what its close check will see.
R10="$DK_TMP/rudra10"; mkdir -p "$R10/prompts" "$R10/.ai"
printf 'session:\n  ground_truth_every_n_sessions: 5\n  ground_truth_next_session: 15\n' > "$R10/.ai/CONSTRAINTS.yaml"
if [ -f "$RUDRA/prompts/10-task-persist-verdicts.md" ]; then cp "$RUDRA/prompts/10-task-persist-verdicts.md" "$R10/prompts/"
else printf '# S10\n\n## Type\n- **CODE.** Max 2 assumptions · 1 story\n' > "$R10/prompts/10-task-persist-verdicts.md"; fi

# gate GATE DIR N → two lines: is it CODE, and what the "verify + demo scripts" check says
gate() {
  ( cd "$2" && bash -c '
    for f in is_ground_truth_session is_code_session check_verify_demo_scripts spath; do
      source /dev/stdin <<<"$(sed -n "/^$f()/,/^}/p" "$1")"
    done
    waiver_ok() { false; }; ok() { R=PASS; }; bad() { R=FAIL; }
    N=$2; ARTIFACTS=$(mktemp -d); R=; check_verify_demo_scripts
    if is_code_session; then echo "CODE session: yes"; else echo "CODE session: no"; fi
    echo "scripts check: $R"; grep -hE "^(N/A|BLOCK)" "$ARTIFACTS"/*.log | cut -c1-60' _ "$1" "$3" )
}
fx() { # fx N KEY TYPELINE → fixture project
  local P="$DK_TMP/p$RANDOM$RANDOM"; mkdir -p "$P/prompts" "$P/.ai"
  { echo "session:"; [ "$2" = - ] || echo "  ground_truth_next_session: $2"; } > "$P/.ai/CONSTRAINTS.yaml"
  printf '# S\n\n## Type\n%s\n' "$3" > "$P/prompts/$(printf '%02d' "$1")-task-x.md"; printf '%s' "$P"
}

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "RUDRA RUN|1|S09 · real"
  dk_h1 "A coding session now gets " "all" " its end-of-session checks."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: rudra's end check thought session 10 was review-only (10 ÷ 5), and thought every rudra brief was not code." \
    "New: it reads the founder's own setting (review at 15) and the way rudra writes CODE — S10 gets its full checks."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "One real rudra run.|The founder ran rudra session 09 under Vajra: 3h20m, 21/21 at the end check, PR merged by him." \
    "What held.|Tech-lead asked first (9th time). All 7 specialist notes committed. The agent pushed and opened the PR itself; the merge stayed his." \
    "What broke (F74).|He moved rudra's review-only session from 10 to 15. The start message listened; the end check did not — it would have skipped S10's code checks." \
    "What the fix found (F76).|The same check only knew \`**CODE**\`. rudra writes \`**CODE.**\` — so for 8 sessions its 'tech-lead asked?' check never ran." \
    "What we fixed.|Both, in the one file every project gets. Then pushed into rudra, before its session 10."
  dk_caption "End check = scripts/verify-closeout.sh — the list of checks a session must pass before it can close."
}

slide_before_after() {
  dk_section before_after "the change · rudra session 10 · the same input"
  dk_h2 "Before → After"
  dk_p "The input: rudra as it stands for session 10 — review moved to 15, the S10 brief as written, no scripts yet. Left: the end check at $OLD_SHA. Right: today's."
  local before after
  dk_run_v gate "$DK_TMP/old.sh" "$R10" 10; before="$_DK_OUT"
  dk_run_v gate "$DK_TMP/new.sh" "$R10" 10; after="$_DK_OUT"
  dk_compare "BEFORE|end check at $OLD_SHA" "$before" "AFTER|end check today · live" "$after"
  echo
  dk_check "before: S10 read as not-code, scripts check skipped (N/A) — the bug" \
    bash -c 'printf "%s" "$1" | grep -q "CODE session: no" && printf "%s" "$1" | grep -q "scripts check: PASS"' _ "$before"
  dk_check "after: S10 is a coding session and the missing scripts BLOCK" \
    bash -c 'printf "%s" "$1" | grep -q "CODE session: yes" && printf "%s" "$1" | grep -q "scripts check: FAIL"' _ "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What happens now"
  dk_table "The project says|Session|End check treats it as" \
    "review moved to 15|10|coding — full checks" \
    "review moved to 15|15|review-only — code checks skipped" \
    "nothing (no setting)|10, 15, 20…|review-only, exactly as before" \
    "brief says **CODE.**|any|coding (new)" \
    "brief says **NO-CODE.**|any|not coding, as before"
  dk_caption "Only ever adds checks: 17 old briefs move from not-code to code; none move the other way."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v gate "$DK_TMP/new.sh" "$(fx 15 15 '- **NO-CODE** review.')" 15
  dk_term "1 · review moved to 15: session 15 is the review" "$_DK_OUT"
  dk_check "session 15 is review-only (scripts N/A)" bash -c 'printf "%s" "$1" | grep -q "N/A"' _ "$_DK_OUT"

  local o w; o=$(gate "$DK_TMP/old.sh" "$(fx 10 - '- **CODE**, one story.')" 10)
  dk_run_v gate "$DK_TMP/new.sh" "$(fx 10 - '- **CODE**, one story.')" 10; w="$_DK_OUT"
  dk_term "2 · no setting: session 10 is still review-only, as before" "$w"
  dk_check "no setting → old and new answer the same (CODE? + scripts check)" \
    bash -c '[ "$(printf "%s\n" "$1" | head -2)" = "$(printf "%s\n" "$2" | head -2)" ]' _ "$o" "$w"

  dk_run_v gate "$DK_TMP/new.sh" "$(fx 9 - '- **NO-CODE.** Max 2 assumptions')" 9
  dk_term "3 · a **NO-CODE.** brief stays not-code" "$_DK_OUT"
  dk_check "**NO-CODE.** is not read as CODE" bash -c 'printf "%s" "$1" | grep -q "CODE session: no"' _ "$_DK_OUT"

  if [ -f "$RUDRA/scripts/verify-closeout.sh" ]; then
    dk_run_v gate "$RUDRA/scripts/verify-closeout.sh" "$RUDRA" 10
    dk_term "4 · rudra's OWN end check (after the sync), in rudra, session 10" "$_DK_OUT"
    dk_check "rudra's synced end check calls S10 a coding session" \
      bash -c 'printf "%s" "$1" | grep -q "CODE session: yes"' _ "$_DK_OUT"
  fi
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "old vs new, 16 session numbers, no setting (verify-session-177.sh)|identical" \
    "old vs new over every brief in both repos|17 not-code → code · 0 code → not-code" \
    "all tests (cargo test)|598 / 598"
  dk_verdict "HONEST NOTES" \
    "Vajra's OWN end check still only knows **CODE** (10 old Vajra briefs say **CODE.**) — not changed: that is a check on Vajra's own paperwork." \
    "rudra's fix is sitting uncommitted in rudra; its session 10 agent commits it first thing (the sync message says so)." \
    "Not fixed, parked by the founder: the money on exit is ~5× too high (F67); the GitHub branch stays after a merge (F71)."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "A|rudra session 10 under Vajra|the first run with its full end checks · risk: they now block things they used to wave through" \
    "B|F67 for good: read the cost from Claude Code itself|ends the wrong money on every exit · risk: may not be exposed after exit" \
    "C|finish 0.2.0: crates.io publish + brew smoke|a stranger gets S167–S177 · risk: founder-only steps"
  dk_table "word|meaning" \
    "end check|scripts/verify-closeout.sh — must pass before a session closes" \
    "review-only session|the every-5th 'ground truth': no code, just a look at whether we're on course" \
    "sync|vajra init --sync-fleet — copies Vajra's newest files into a project"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
