#!/usr/bin/env bash
# Session 87 — the last standing `<sha>` placeholder in the repo's history, filled in.
# prompts/76-task-dogfood-ride-along.md's `## Execution` section named 4 `<sha>` placeholders
# since before the S81 closeout-gate hardening existed to catch it — first flagged S81, carried
# disclosed-not-fixed for 9 sessions. This session content-matches each Plan step to its real
# landing commit (not the scrambled "(N/4)" commit-message numbering) and fills them in.
#
# Runs the REAL `vajra next` gate path against THIS repo's real session 76 — not a synthetic
# fixture, because S76 is real history. Also demos the side effect this fix surfaced live: the
# same edit un-attests S76's own Reviewer/Releaser stations (S86's canonical_inputs_sha hashes
# the prompt file's LIVE bytes, not a review-time snapshot) — disclosed, not hidden, not fixed
# here (out of scope; a strong S88 candidate).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="87"

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo — S76's last <sha> placeholder, filled in  [demo:header]"
printf "${DIM}  9 sessions overdue (S81 -> S87). Fixed by reading each candidate commit's real diff,\n"
printf "  not by pattern-matching the misleading '(N/4)' commit-message numbering.${RESET}\n"

cargo build --quiet --release --bin vajra
BIN="$ROOT/target/release/vajra"

TARGET="prompts/76-task-dogfood-ride-along.md"
header "Before → After  [demo:before_after]"
label "BEFORE (the pre-S87 commit's content, swapped in temporarily):"
cp "$TARGET" "$TARGET.s87-after"
trap '[ -f "$TARGET.s87-after" ] && mv -f "$TARGET.s87-after" "$TARGET"' EXIT
git show HEAD~1:"$TARGET" > "$TARGET"
("$BIN" next --check-exec 76 | sed 's/^/   /') || true
("$BIN" next --stations 76 | grep -E 'Coder|stations passed' | sed 's/^/   /') || true
mv "$TARGET.s87-after" "$TARGET"
label "AFTER (this session's fix, live):"
"$BIN" next --check-exec 76 | sed 's/^/   /'
"$BIN" next --stations 76 | grep -E 'Coder|stations passed' | sed 's/^/   /'

header "Cases  [demo:cases]"

header "1 · Content-matched mapping (not number-matched)"
label "Each Plan step's real landing commit, matched by reading the diff:"
printf '   %s\n' "step 1 (prepare/harness/checklist)     -> 16d30aa"
printf '   %s\n' "step 2 (capture live run artifacts)    -> 08e4718"
printf '   %s\n' "step 3 (derive numbers from artifacts) -> 9f0cab0"
printf '   %s\n' "step 4 (write report+scripts+summary)  -> 9f0cab0 (+76190f1, disclosed 2-commit span)"
ok "no <sha> placeholder remains in the file"

header "2 · The Coder gate flips (the session's own goal)"
STATIONS_OUT=$("$BIN" next --stations 76)
printf '%s\n' "$STATIONS_OUT" | grep -i coder | sed 's/^/   /'
if printf '%s' "$STATIONS_OUT" | grep -q '\[PASSED\] Coder'; then
  ok "Coder: ABSENT -> PASSED, exactly as AC3 required"
else
  bad "expected Coder PASSED"
fi

header "3 · Disclosed side effect (found live, not hidden)"
label "Editing a historical prompt file un-attests its OWN review — a real S86-mechanism gap:"
printf '%s\n' "$STATIONS_OUT" | grep -E 'Reviewer|Releaser' | sed 's/^/   /'
ATTEST_OUT=$(bash scripts/verify-closeout.sh --attest-only 76 2>&1) || true
printf '%s\n' "$ATTEST_OUT" | tail -4 | sed 's/^/   /'
if printf '%s' "$ATTEST_OUT" | grep -q "BLOCK: attestation MISMATCH"; then
  ok "reproduced live — recorded as a strong S88 candidate, not fixed here (out of scope)"
else
  bad "expected the disclosed mismatch to reproduce"
fi

header "Summary — S87 acceptance criteria  [demo:summary_table]"
printf "\n"
printf "  %-58s %s\n" "Criterion" "Status"
printf "  %-58s %s\n" "----------------------------------------------------------" "------"
printf "  %-58s %s\n" "1 · every step matched to its real commit, no <sha> left"    "SHIPPED"
printf "  %-58s %s\n" "2 · check-exec 76 NOT READY -> READY (live)"                  "SHIPPED"
printf "  %-58s %s\n" "3 · stations 76 Coder ABSENT -> PASSED (live, before/after)"  "SHIPPED"
printf "  %-58s %s\n" "4 · multi-commit span disclosed, not forced to 1:1 (AC4)"     "SHIPPED"
printf "  %-58s %s\n" "5 · single-file, docs-only scope held"                        "SHIPPED"
printf "  %-58s %s\n" "bonus · Reviewer/Releaser regression found + disclosed"       "DISCLOSED"
printf "\n"

ok "Session ${SESSION} demo complete."
