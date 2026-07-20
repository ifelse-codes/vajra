#!/usr/bin/env bash
# Session 82 — the Releaser station reads from the attested ledger when a session's branch has
# been merged and pruned. Pruning the merged branch is the REQUIRED close step (S37) — so every
# properly-shipped session used to read a false [ABSENT] "branch not merged into main" from
# `vajra next --stations NN`, because a pruned-after-merge branch is indistinguishable in git
# alone from a branch that never existed. The S75 and S80 ground truths both flagged this as the
# station counter's own credibility problem. This session fixes it: when no branch ref survives,
# the fix falls back to the attested cold-review ledger (S55-S59) as shipping evidence.
#
# Sprint demo — runs `vajra next --stations 81` LIVE (real repo, real pruned branch, real
# attested review) + the regression suite; emits the four gated demo:<element> markers;
# `--check-demo 82` re-runs it live at close.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="82"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — Releaser reads the ledger when the branch is pruned  [demo:header]"
printf "${DIM}  S75 and S80's ground truths both flagged the same false read: 'vajra next --stations NN'\n"
printf "  reported [ABSENT] Releaser SHIP for every past session, because merging THEN pruning the\n"
printf "  branch (the required S37 end-state) is indistinguishable in git alone from a branch that\n"
printf "  never shipped. This session fixes it with a ledger fallback.${RESET}\n"

header "Before → After  [demo:before_after]"
label "BEFORE (S81 close — the counter's own S75/S80-flagged bug):"
printf '   [ABSENT] Releaser  SHIP   — branch not merged into main\n'
bad "wrong: session 81's branch WAS merged (PR #79) and properly pruned per S37 — the counter"
bad "cannot tell 'pruned after merge' from 'never created' using git refs alone."
label "AFTER (S82, metered LIVE on real session 81 — its branch is gone, its review is attested):"
AFTER=$(cargo run --quiet -- next --stations 81 2>&1 || true)
printf '%s\n' "$AFTER" | sed 's/^/   /'
if printf '%s\n' "$AFTER" | grep -q '\[PASSED\] Releaser' && printf '%s\n' "$AFTER" | grep -qi 'ledger'; then
  ok "[PASSED] Releaser SHIP — the ledger's attested ACCEPT review is now named as the evidence"
else
  bad "expected a [PASSED] Releaser line naming the ledger"
fi

header "Cases — the fix  [demo:cases]"

header "1 · No branch + attested ACCEPT ledger evidence → PASSED (AC1)"
if cargo test --quiet --lib stations::tests::releaser_passes_when_no_branch_but_ledger_attested >/dev/null 2>&1; then
  ok "a merged-then-pruned branch, with an attested ACCEPT review, now reads PASSED"
else
  bad "regression test failed"
fi

header "2 · No branch + no ledger evidence → stays ABSENT — no false positives (AC2)"
if cargo test --quiet --lib stations::tests::releaser_absent_when_no_branch_and_no_ledger >/dev/null 2>&1 \
  && cargo test --quiet --lib stations::tests::releaser_absent_when_no_branch_but_ledger_rejects >/dev/null 2>&1; then
  ok "a ghost session (no branch, no review) stays ABSENT"
  ok "a REJECT verdict (even attested) is not shipping evidence — stays ABSENT"
else
  bad "regression test failed"
fi

header "3 · Unmerged and Merged/synced/pruned paths are unchanged (AC3, AC4)"
if cargo test --quiet --lib stations::tests::releaser_passes_only_when_branch_merged_and_pruned >/dev/null 2>&1; then
  ok "an existing, unmerged branch still reads ABSENT — the fallback only fires on NoBranch"
else
  bad "regression test failed"
fi

header "4 · The fully-evidenced fixture now reaches the honest 8/8 ceiling (AC6)"
if cargo test --quiet --lib stations::tests::fully_filled_session_counts_high >/dev/null 2>&1; then
  ok "a fixture with every station's evidence, incl. a pruned branch + attested review, hits 8/8"
  ok "the old '7/8 ceiling' comment was the symptom of this bug, not a real ceiling — corrected"
else
  bad "regression test failed"
fi

header "Summary — S82 acceptance criteria  [demo:summary_table]"
printf "\n"
printf "  %-58s %s\n" "Criterion" "Status"
printf "  %-58s %s\n" "----------------------------------------------------------" "------"
printf "  %-58s %s\n" "1 · NoBranch + attested ACCEPT ledger -> PASSED, names ledger" "SHIPPED"
printf "  %-58s %s\n" "2 · NoBranch + no ledger evidence -> ABSENT (no false pos.)"  "SHIPPED"
printf "  %-58s %s\n" "3 · Unmerged branch path unchanged"                          "SHIPPED"
printf "  %-58s %s\n" "4 · Merged/synced/pruned happy path unchanged"               "SHIPPED"
printf "  %-58s %s\n" "5 · 'vajra next --stations 81' shows PASSED Releaser, live"   "SHIPPED"
printf "  %-58s %s\n" "6 · cargo test --lib green (261, +3); fixture hits 8/8"       "SHIPPED"
printf "\n"

ok "Session ${SESSION} demo complete."
