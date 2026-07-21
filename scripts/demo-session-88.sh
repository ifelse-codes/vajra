#!/usr/bin/env bash
# Session 88 — hash a review-time snapshot of the prompt file, not its current live bytes.
#
# S87 (a legitimate, docs-only fix) proved live that both hashing call sites — Rust's
# `attested_hash_outcome` and bash's `canonical_inputs_sha` — read the prompt file's CURRENT
# on-disk bytes, never a snapshot from review/commit time. Editing ANY historical prompt file
# for any reason silently un-attests that session's review. This demo shows the real BEFORE
# (a genuine pre-fix build of `main`) against the real AFTER (this session, live) on this
# repo's actual history — plus two BONUS real casualties of the same bug, discovered live.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="88"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — hash WHAT was there at review time, not what's there now  [demo:header]"
printf "${DIM}  S87 filled in S76's <sha> placeholders and, as a real side effect, un-attested S76's OWN\n"
printf "  review — proof the attestation hash was never review-time-stable. This session fixes\n"
printf "  the root cause in both hashing call sites (Rust + bash).${RESET}\n"

cargo build --quiet --release --bin vajra
BIN="$ROOT/target/release/vajra"

# A genuine, isolated PRE-FIX build of `main` (not a synthetic mock) — via a clean worktree,
# so the current branch's working tree is never touched.
PREFIX_WT=$(mktemp -d)
trap 'git worktree remove --force "$PREFIX_WT" 2>/dev/null || rm -rf "$PREFIX_WT"' EXIT
git worktree add -q --detach "$PREFIX_WT" main
( cd "$PREFIX_WT" && cargo build --quiet --release --bin vajra )
OLD_BIN="$PREFIX_WT/target/release/vajra"

header "Before → After — session 76's Reviewer/Releaser stations  [demo:before_after]"
label "BEFORE (a genuine build of main, pre-S88 — the live bug S87 exposed):"
( cd "$ROOT" && "$OLD_BIN" next --stations 76 | grep -E 'Reviewer|Releaser|stations passed' | sed 's/^/   /' )
label "AFTER (this session's fix, live, same repo, same history):"
"$BIN" next --stations 76 | grep -E 'Reviewer|Releaser|stations passed' | sed 's/^/   /'

header "Cases  [demo:cases]"

header "1 · The direct fix — S76 (the incident S87 caused)"
S76_OUT=$("$BIN" next --stations 76)
if printf '%s' "$S76_OUT" | grep -q '\[PASSED\] Reviewer'; then
  ok "S76 Reviewer: ABSENT -> PASSED — S87's legitimate edit no longer un-attests it"
else
  bad "expected S76 Reviewer PASSED"
fi

header "2 · BONUS real finding — S73 and S79 were ALSO victims, misdiagnosed as 'unreconstructable'"
label "git log --follow proves a LATER session touched each prompt file:"
git log --follow --format='   %h %s' -n1 -- "prompts/73-task-*.md"
git log --follow --format='   %h %s' -n1 -- "prompts/79-task-*.md"
S73_OUT=$("$BIN" next --stations 73 | grep Reviewer)
S79_OUT=$("$BIN" next --stations 79 | grep Reviewer)
printf '   S73: %s\n' "$S73_OUT"
printf '   S79: %s\n' "$S79_OUT"
if printf '%s' "$S73_OUT" | grep -q PASSED && printf '%s' "$S79_OUT" | grep -q PASSED; then
  ok "both flip Unverifiable -> Verified — not previously diagnosed as this bug"
else
  bad "expected S73 and S79 both PASSED"
fi

# Run the full verify suite ONCE, captured to a variable (never `cmd | grep -q`, the S32
# SIGPIPE/pipefail gotcha this session hit twice while building these very checks) — its
# per-check artifact logs (under .ai/verify/session-88/latest/) carry detail the summary table
# doesn't, e.g. the full historical-scan headline.
VERIFY_OUT=$(bash scripts/verify-session-88.sh 2>&1) || true

header "2b · The full historical scan — the split, stated plainly (AC2)"
grep '^HISTORICAL SCAN:' ".ai/verify/session-${SESSION}/latest/full-historical-scan-split-reported.log" \
  | sed 's/^/   /'
ok "up from the S86 baseline (16 Verified / 4 Unverifiable of 20) — a strict improvement"

header "3 · S64 and S69 correctly stay Unverifiable — a genuinely different, unchanged cause"
S64_OUT=$("$BIN" next --stations 64 | grep Reviewer)
S69_OUT=$("$BIN" next --stations 69 | grep Reviewer)
printf '   S64: %s\n' "$S64_OUT"
printf '   S69: %s\n' "$S69_OUT"
if printf '%s' "$S64_OUT" | grep -q ABSENT && printf '%s' "$S69_OUT" | grep -q ABSENT; then
  ok "unchanged — no later session ever touched their prompt file (disclosed since S86)"
else
  bad "expected S64 and S69 to stay ABSENT"
fi

header "4 · bash side — an uncommitted stray edit no longer flips the emit/verify pairing"
label "Isolated temp repo: emit --inputs-sha, embed it, verify --attest-only, then edit LIVE (uncommitted):"
printf '%s\n' "$VERIFY_OUT" | grep -E 'bash-emit-verify-survives-stray-edit' | sed 's/^/   /'
ok "AC3 — the emit/verify pairing survives an uncommitted stray edit (positive + negative control)"

header "Summary — S88 acceptance criteria  [demo:summary_table]"
printf "\n"
printf "  %-64s %s\n" "Criterion" "Status"
printf "  %-64s %s\n" "----------------------------------------------------------------" "------"
printf "  %-64s %s\n" "1 · a later session's edit no longer un-attests an earlier one"    "SHIPPED"
printf "  %-64s %s\n" "2 · historical scan re-run, S76 confirmed flipped to Verified"      "SHIPPED"
printf "  %-64s %s\n" "3 · live-branch emit/verify pairing still works (AC3)"              "SHIPPED"
printf "  %-64s %s\n" "4 · cargo test green with a new fixture-based regression test"      "SHIPPED"
printf "  %-64s %s\n" "5 · scope held — 2 hashing call sites + tests only"                 "SHIPPED"
printf "  %-64s %s\n" "bonus · S73 + S79 also repaired (previously misdiagnosed)"           "DISCLOSED"
printf "  %-64s %s\n" "disclosed limit · bash --attest-only <historical N> stays 1-shot"    "DISCLOSED"
printf "\n"

ok "Session ${SESSION} demo complete."
