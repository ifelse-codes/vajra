#!/usr/bin/env bash
# Session 178 demo — three close messages made true (F83, F86, F87), found by the founder's rudra
# sessions 10–13 (two of them under other agents: omp, OpenCode). Drawn with scripts/demo-kit.sh
# (DECISION-009/010): every claim runs live; the "before" is Vajra built from the pinned commit this
# session started from. Try it: DEMO_MODE=stream bash scripts/demo-session-178.sh (gate view) · bare
# in a terminal (deck).

set -uo pipefail   # no -e: a live check that fails must be SHOWN, not abort the demo
KIT="$(cd "$(dirname "$0")" && pwd)/demo-kit.sh"
[ -f "$KIT" ] || { echo "demo: $KIT is missing — run: vajra init --sync-fleet" >&2; exit 1; }
. "$KIT"
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || exit 1

# === EDIT PER SESSION ===
SESSION="178"
OLD_SHA=dc57eb0    # the commit S178 started from — pinned, never `main` (after the merge main IS new)
RUDRA="${RUDRA:-/Users/suman/playground/rudra}"
# ========================

cargo build --release -q 2>/dev/null
NEW="$ROOT/target/release/vajra"
OLD="${OLD_VAJRA:-$ROOT/target/s178-old/release/vajra}"
if [ ! -x "$OLD" ]; then
  git worktree add -q --detach "$DK_TMP/old" "$OLD_SHA" 2>/dev/null
  ( cd "$DK_TMP/old" && CARGO_TARGET_DIR="$ROOT/target/s178-old" cargo build --release -q 2>/dev/null )
  git worktree remove --force "$DK_TMP/old" >/dev/null 2>&1
fi

# crew BIN N → the crew check on rudra's real record for session N, the lines a person reads
crew() {
  local out; out="$( cd "$RUDRA" && "$1" next --check-crew "$2" 2>&1 )"
  grep -m1 "^verdict" <<<"$out"
  grep -oE "belongs to a different session|a hand-typed[^,]*handoff|can satisfy or bypass this gate|changes this check's answer|ran in an agent other than Claude Code|will not change that|no waiver replaces" <<<"$out" \
    | awk '!seen[$0]++' | sed 's/^/says: /'
}

slide_headline() {
  dk_section headline "session $SESSION · what shipped"
  dk_vajra_tiles "$SESSION" "RUDRA RUNS|4|S10–S13 · real"
  dk_h1 "Vajra's end-of-session messages now " "tell the truth" "."
  dk_verdict "WHAT CHANGED, IN ONE BREATH" \
    "Old: under OpenCode, Vajra said 'this looks hand-typed — run the helper again', and the agent tried ~30 times. It also said nothing could get past the check — but the founder's override did." \
    "New: it says a helper that ran outside Claude Code can't be confirmed, re-running on the same notes won't help, and names the two ways through: run the helpers again in Claude Code, or the founder's override. Same verdicts; only the words changed."
}

slide_story() {
  dk_section story "the story"
  dk_h2 "What we did this session"
  dk_bullets \
    "Four real rudra runs.|S10 (Claude Code), S11 (omp, on purpose), S12 (Claude Code, 21/21 clean), S13 (OpenCode)." \
    "What they found.|12 findings, F77–F88. The biggest: the controls meant only for the founder — 'APPROVED', the override, the 'verified' stamp — are text the agent can type. That goes to session 180 as its first item." \
    "What the founder said yes to now.|Three wording fixes. No check added, loosened or removed." \
    "F86.|OpenCode's close ran ~30 times against 3 checks it could never pass. The message blamed 'a hand-typed record'." \
    "F87 + F83.|A sentence that was false at close, and a tech-lead template that showed its lines inside a code box the check skips."
  dk_caption "End check = scripts/verify-closeout.sh — the list of checks a session must pass before it can close."
}

slide_before_after() {
  dk_section before_after "the change · rudra session 13 · the same records"
  dk_h2 "Before → After"
  dk_p "The input: rudra's real session 13 records (helpers ran in OpenCode). Left: Vajra at $OLD_SHA. Right: today's."
  local before after
  dk_run_v crew "$OLD" 13; before="$_DK_OUT"
  dk_run_v crew "$NEW" 13; after="$_DK_OUT"
  dk_compare "BEFORE|Vajra at $OLD_SHA" "$before" "AFTER|Vajra today · live" "$after"
  echo
  dk_check "before: blames a hand-typed record and claims nothing can bypass it" \
    bash -c 'printf "%s" "$1" | grep -q "hand-typed" && printf "%s" "$1" | grep -q "can satisfy or bypass"' _ "$before"
  dk_check "after: says the helpers ran outside Claude Code and re-running won't help" \
    bash -c 'printf "%s" "$1" | grep -q "ran in an agent other than Claude Code" && printf "%s" "$1" | grep -q "will not change that"' _ "$after"
  dk_check "same verdict before and after (still blocked)" \
    bash -c '[ "$(printf "%s" "$1" | grep ^verdict)" = "$(printf "%s" "$2" | grep ^verdict)" ]' _ "$before" "$after"
}

slide_rule() {
  dk_section rule "the rule, in plain words"
  dk_h2 "What each message says now"
  dk_table "Situation|Vajra now says" \
    "a helper can't be confirmed|its old reason, PLUS: if the helpers ran outside Claude Code this can't pass as they are; re-running on the same notes won't help; ways through: run them again in Claude Code, or the founder's override" \
    "no tech-lead at all|no skip flag turns the check off; the override can waive this check — but a coding session still needs the tech-lead file, which no override replaces" \
    "the tech-lead writes its crew|as plain lines — a code box is read as an example and skipped"
  dk_caption "Nothing got easier or harder to pass: every verdict and exit code is the same (old vs new on 15 real checks)."
}

slide_cases() {
  dk_section cases "the cases · live"
  dk_h2 "See it for yourself"
  dk_run_v bash -c "cd '$RUDRA' && '$NEW' next --check-fidelity-handoff 11 2>&1 | grep -E '^verdict|✗' | cut -c1-230"
  dk_term "1 · rudra S11 (omp): the review's 'verified' stamp was hand-written" "$_DK_OUT"
  dk_check "S11 still blocks, and now says why a non-Claude run can't pass" \
    bash -c 'printf "%s" "$1" | grep -q "NOT READY" && printf "%s" "$1" | grep -q "other than Claude Code"' _ "$_DK_OUT"

  local o n
  o="$(cd "$RUDRA" && "$OLD" next --check-crew 12 2>&1)"; n="$(cd "$RUDRA" && "$NEW" next --check-crew 12 2>&1)"
  dk_run_v bash -c "printf '%s\n' \"\$1\" | grep -E '^verdict' " _ "$n"
  dk_term "2 · rudra S12 (Claude Code, closed clean): unchanged" "$_DK_OUT"
  dk_check "S12 passes exactly as before (output identical)" bash -c '[ "$1" = "$2" ]' _ "$o" "$n"

  if [ -f "$RUDRA/.claude/agents/tech-lead.md" ]; then
    dk_run_v bash -c "grep -n 'PLAIN lines' '$RUDRA/.claude/agents/tech-lead.md' | cut -c1-160"
    dk_term "3 · rudra's tech-lead instructions (after the sync)" "$_DK_OUT"
    dk_check "rudra's tech-lead is told to write its crew as plain lines" \
      bash -c 'printf "%s" "$1" | grep -q "PLAIN lines"' _ "$_DK_OUT"
  fi
}

slide_scorecard() {
  dk_section scorecard "proof · what Vajra knows · what ran live · what was recorded"
  dk_h2 "The scorecard"
  dk_vajra_scorecard "$SESSION"
  dk_scorecard "LIVE — ran while you watched"
  dk_table "Recorded at close — not re-run here|Result" \
    "old vs new, 15 real checks in rudra (S11, S12, S13) and Vajra (S176, S177) — verify-session-178.sh|same verdict + exit; only the wording differs" \
    "lib tests (cargo test --lib)|550 / 550"
  dk_verdict "HONEST NOTES" \
    "This only fixes the WORDS. Vajra still cannot confirm a helper that ran outside Claude Code (F80) — that, and the agent being able to type the founder's controls (F77–F79, F84, F85), is session 180's first item." \
    "The new text names the override. The agent can read it and type it, just as it could before (F78) — the text says 'meant for the founder', and the close log records every use." \
    "rudra's new tech-lead file is sitting uncommitted in rudra; its next session's agent commits it first."
}

slide_next() {
  dk_section next "where this sits · what's next"
  dk_h2 "Next"
  dk_table " |Option|Why pick it · the risk" \
    "A|rudra session 14 under Vajra|see the new messages in a real run · risk: little new to learn if it's Claude Code again" \
    "B|session 180 early: the founder's controls the agent can type|the biggest problem found · risk: a design session, no code" \
    "C|finish 0.2.0: crates.io publish|a stranger gets S167–S178 · risk: founder-only steps"
  dk_table "word|meaning" \
    "end check|scripts/verify-closeout.sh — must pass before a session closes" \
    "override|VAJRA_CLOSEOUT_WAIVER — lets a session close past a failing check; recorded in the close log" \
    "sync|vajra init --sync-fleet — copies Vajra's newest files into a project"
}

dk_deck slide_headline slide_story slide_before_after slide_rule slide_cases slide_scorecard slide_next
dk_finish
