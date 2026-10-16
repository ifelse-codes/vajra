#!/usr/bin/env bash
# Session 199 verify — every pending known bug (founder pick, 2026-10-16):
#   F126  a late founder change has a place: the step list says where it goes and what it costs
#   sign-off  a review-only session's step list has the founder's `vajra approve NN --close` step
#   N19   `vajra next --advance` keeps a CRLF SESSION-BOOT / TASK.md CRLF
#   N20   the advance's prompt-pointer rewrite leaves `## Prior Session` entries alone
#   N21   two prompt files for one session are named and refused, not coin-tossed
#   N14   a ground-truth question reads the close result against what the human was told
#   latest  Vajra's own `.ai/verify/closeout/latest` is a link, not a folder (local, founder's yes)
#   gt_cadence_shared  `announces_gt()` reads only the announcement line
#   N7    the last eight scripts take their old-version checkout from scripts/lib-old-checkout.sh
# Rows 2–6 RUN the built `vajra` on temp `vajra init` projects, and again with the binary from the commit
# S199 started at (027e70f), where each must go red for its own reason (S122). Rows 1 and 8 run one named
# test each (absent at 027e70f), row 1 also the real stamp. Row 7 reads this machine's own folder.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
. "$ROOT/scripts/lib-old-checkout.sh"
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; vajra_old_checkout_remove "${STAMP_WT:-}"; rm -rf "$T"' EXIT
OLD_SHA=027e70f
VAJRA="$ROOT/target/release/vajra"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
OLD_VAJRA="$ROOT/target/s199-old/release/vajra"
if [ ! -x "$OLD_VAJRA" ]; then
  OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
  (cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s199-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
  vajra_old_checkout_remove "$OLD_WT"; OLD_WT=""
fi

human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            -u VAJRA_AGENT_MARK -u CLAUDE_PROJECT_DIR GIT_CONFIG_GLOBAL=/dev/null "$@"; }
has() { printf '%s\n' "$1" | grep -qF -- "$2"; }
# one_test FILTER [cargo-args...] → passes when exactly that one test ran and passed
one_test() { cargo test -q "$@" 2>&1 | grep -qE '^test result: ok\. 1 passed;'; }

# project BIN NAME → a `vajra init` project at L1 (gates advise, so the advance runs), on session 07's branch,
# .ai/SESSION 06, with a session-07 prompt.
project() {
  local p="$T/$2"; rm -rf "$p"; mkdir -p "$p"
  (cd "$p" && human git init -q -b main && human "$1" init </dev/null >/dev/null 2>&1 \
     && perl -pi -e 's/^maturity: L2/maturity: L1/' .ai/CONSTRAINTS.yaml && echo 06 > .ai/SESSION \
     && perl -pi -e 's/\*\*Number:\*\* \d+/**Number:** 06/' .ai/SESSION-BOOT.md \
     && cp prompts/01-task-kickoff.md prompts/07-task-next.md && human git checkout -qb session-07-next)
  printf '%s' "$p"
}
advance() { (cd "$1" && human "$2" next --advance </dev/null 2>&1); }
crlf_only() { [ "$(grep -c $'\r$' "$1")" = "$(wc -l < "$1" | tr -d ' ')" ]; }   # every line ends \r\n

# --- 1 (F126, AC1): late founder edits leave the stamp alone; the step list says so -----------------
STAMP_WT=$(vajra_old_checkout HEAD) || { echo "FAIL: worktree at HEAD"; exit 1; }
SAME=0; MOVED=0
(
  cd "$STAMP_WT" || exit 1
  echo "// stand-in" >> src/lib.rs; human git -c user.name=t -c user.email=t@t commit -qam stand-in --no-verify
  stamp() { bash scripts/verify-closeout.sh --inputs-sha 199 2>/dev/null | tail -1; }
  base=$(stamp); [ -n "$base" ] || exit 9
  try() { human git add -A >/dev/null; human git -c user.name=t -c user.email=t@t commit -qm late --no-verify
          [ "$(stamp)" = "$base" ] && echo same || echo moved; human git reset -q --hard HEAD~1; }
  printf '# next\n' > prompts/200-task-late-pick.md; try
  echo late >> sessions/session-198-summary.md; try
  for f in TASK STATE ROADMAP; do echo late >> ".ai/$f.md"; try; done
  echo late >> prompts/199-task-all-pending-bugs.md; try
) > "$T/stamp.out"
SAME=$(grep -c '^same$' "$T/stamp.out"); MOVED=$(sed -n 6p "$T/stamp.out")
if [ "$SAME" = 5 ] && [ "$MOVED" = moved ] && one_test --lib nextstep::tests::a_late_founder_change_has_a_place -- --exact; then
  ok "F126 real stamp: a next prompt, a summary, TASK/STATE/ROADMAP edits leave it (5/5), this session's own prompt moves it; the step list's test passes (absent at $OLD_SHA)"
else bad "F126: $(tr '\n' ' ' < "$T/stamp.out")"; fi

# --- 2 (sign-off, AC2): a review-only session's list has the close step: ✗, then ✓ + not in git, then ✓ -----
signoff() { (cd "$1" && human "$2" next --steps 10 2>&1) | grep 'signed off this review-only session' | head -1; }
P="$T/gt"; mkdir -p "$P"; (cd "$P" && human git init -q -b main && human "$VAJRA" init </dev/null >/dev/null 2>&1 \
  && echo 09 > .ai/SESSION && cp prompts/01-task-kickoff.md prompts/10-task-review.md && human git checkout -qb session-10-review)
S0=$(signoff "$P" "$VAJRA")
mkdir -p "$P/.ai/approvals"; printf '{"session": 10, "method": "close-command", "at_unix": 1}\n' > "$P/.ai/approvals/session-10-close.json"
S1=$(signoff "$P" "$VAJRA")
(cd "$P" && human git add -A && human git -c user.name=t -c user.email=t@t commit -qm r --no-verify)
S2=$(signoff "$P" "$VAJRA"); SO=$(signoff "$P" "$OLD_VAJRA")
if has "$S0" "✗ the founder has signed off" \
   && has "$S1" "✓ the founder has signed off" && has "$S1" ".ai/approvals/session-10-close.json is not in git yet" \
   && has "$S2" "✓ the founder has signed off" && ! has "$S2" "not in git" && [ -z "$SO" ]; then
  ok "sign-off: review-only session 10 shows ✗ until the close record, ✓ naming it while not in git, ✓ after the commit; no such step at $OLD_SHA (the step's close-command wording: unit test a_review_only_session_has_the_founders_sign_off_step)"
else bad "sign-off: [$S0] [$S1] [$S2] old=[$SO]"; fi

# --- 3+4 (N19 + N20, AC3/AC4): CRLF kept on both shapes and TASK.md; a Prior pointer is untouched -------
PRIOR_LINE='- **Number:** 05 — CLOSED. Read prompt `prompts/05-task-old.md` then.'
boot() { printf '# Session Boot\n\n## Next Session\n- **Read prompt:** `prompts/06-task-old.md`\n\n## Current Session\n- **Number:** 06 — done.\n  more.\n\n## Prior Session\n%s\n' "$PRIOR_LINE" | perl -pe 's/\n/\r\n/'; }
crlf_run() { # BIN NAME → the project after an advance on CRLF files (Vajra-shaped boot)
  local p; p=$(project "$1" "$2"); boot > "$p/.ai/SESSION-BOOT.md"
  printf '# Task\nRead prompt: `prompts/06-task-old.md`\n' | perl -pe 's/\n/\r\n/' > "$p/.ai/TASK.md"
  advance "$p" "$1" >/dev/null; printf '%s' "$p"
}
P=$(crlf_run "$VAJRA" crlf); PO=$(crlf_run "$OLD_VAJRA" crlf-old)
Q=$(project "$VAJRA" crlf-init); perl -pi -e 's/\n/\r\n/' "$Q/.ai/SESSION-BOOT.md"; advance "$Q" "$VAJRA" >/dev/null
if [ "$(cat "$P/.ai/SESSION")" = 07 ] && crlf_only "$P/.ai/SESSION-BOOT.md" && crlf_only "$P/.ai/TASK.md" \
   && crlf_only "$Q/.ai/SESSION-BOOT.md" && grep -qF '**Number:** 07' "$Q/.ai/SESSION-BOOT.md" \
   && ! crlf_only "$PO/.ai/SESSION-BOOT.md"; then
  ok "N19: after an advance every line of a CRLF SESSION-BOOT (Vajra's shape and init's) and TASK.md still ends in CRLF; at $OLD_SHA they came out LF"
else bad "N19: $(grep -c $'\r$' "$P/.ai/SESSION-BOOT.md")/$(wc -l < "$P/.ai/SESSION-BOOT.md") CRLF lines; old $(grep -c $'\r$' "$PO/.ai/SESSION-BOOT.md")"; fi
if grep -qF -- "$PRIOR_LINE"$'\r' "$P/.ai/SESSION-BOOT.md" \
   && grep -qF -- '- **Read prompt:** `prompts/07-task-next.md`' "$P/.ai/SESSION-BOOT.md" \
   && grep -qF 'Read prompt: `prompts/07-task-next.md`' "$P/.ai/TASK.md" \
   && ! grep -qF -- "$PRIOR_LINE" "$PO/.ai/SESSION-BOOT.md"; then
  ok "N20: the old entry's \"Read prompt \`prompts/05-task-old.md\`\" under Prior is byte-for-byte unchanged; the Next pointer and TASK.md moved to 07; at $OLD_SHA the Prior line was rewritten"
else bad "N20:"$'\n'"$(cat -v "$P/.ai/SESSION-BOOT.md")"; fi

# --- 5 (N21, AC5): two prompts for one session — refused naming both; the step list names both ----------
two() { local p; p=$(project "$1" "$2"); cp "$p/prompts/07-task-next.md" "$p/prompts/07-task-another.md"; printf '%s' "$p"; }
P=$(two "$VAJRA" two); A=$(advance "$P" "$VAJRA"); RC=$?; ST=$( (cd "$P" && human "$VAJRA" next --steps 7 2>&1) )
PO=$(two "$OLD_VAJRA" two-old); advance "$PO" "$OLD_VAJRA" >/dev/null
if [ "$RC" -ne 0 ] && [ "$(cat "$P/.ai/SESSION")" = 06 ] \
   && has "$A" "has 2 prompt files (prompts/07-task-another.md, prompts/07-task-next.md)" \
   && has "$ST" "✗ this session has ONE prompt — it has 2: prompts/07-task-another.md, prompts/07-task-next.md" \
   && [ "$(cat "$PO/.ai/SESSION")" = 07 ]; then
  ok "N21: with two session-07 prompts the advance exits $RC naming both and writes nothing; --steps leads with a ✗ naming both; at $OLD_SHA it advanced on one of them"
else bad "N21 (rc $RC): $A"$'\n'"$ST"; fi

# --- 6 (N14, AC6): the question reaches a fresh init and --sync-fleet; scaffold-drift green -------------------
Q14='read its newest `.ai/verify/closeout/<stamp>/result`'
P=$(project "$VAJRA" n14); PO=$(project "$OLD_VAJRA" n14-old)
F1=$(grep -cF "$Q14" "$P/.ai/CONSTRAINTS.yaml")
perl -0pi -e 's/  constraint_violation_questions:\n(    - .*\n)+//' "$P/.ai/CONSTRAINTS.yaml"
F2=$(grep -cF "$Q14" "$P/.ai/CONSTRAINTS.yaml")
SY=$( (cd "$P" && human "$VAJRA" init --sync-fleet </dev/null 2>&1) ); F3=$(grep -cF "$Q14" "$P/.ai/CONSTRAINTS.yaml")
bash scripts/scaffold-drift.sh > "$T/drift.out" 2>&1; DR=$?
if [ "$F1" = 1 ] && [ "$F2" = 0 ] && [ "$F3" = 1 ] && has "$SY" "constraint_violation_questions" && [ "$DR" -eq 0 ] \
   && ! grep -qF "$Q14" "$PO/.ai/CONSTRAINTS.yaml"; then
  ok "N14: a fresh vajra init carries the close-truth question; with it removed, --sync-fleet adds it back; scaffold-drift exit 0 ($(tail -1 "$T/drift.out" | tr -d '=')); absent at $OLD_SHA"
else bad "N14: init=$F1 removed=$F2 synced=$F3 drift=$DR"$'\n'"$SY"; fi

# --- 7 (latest, AC7): Vajra's own closeout `latest` is a link to a run folder (this machine's, local) -----------
L=.ai/verify/closeout/latest
if [ -L "$L" ] && [ -f "$L/result" ] && printf '%s' "$(readlink "$L")" | grep -qE '^[0-9]{8}T[0-9]{6}Z$'; then
  ok "latest: $L is a link to run $(readlink "$L") (a real folder from 2026-08-03 until the founder's yes, 2026-10-16)"
else bad "latest: $(ls -ld "$L" 2>&1)"; fi

# --- 8 (gt_cadence_shared, AC8): only the announcement line counts ------------------------------------------
if one_test --test gt_cadence_shared ground_truth_words_in_the_boot_files_are_not_an_announcement -- --exact \
   && cargo test -q --test gt_cadence_shared 2>&1 | grep -qE '^test result: ok\. 6 passed;'; then
  ok "gt_cadence_shared: 'ground truth' in a non-ground-truth session's boot output is not an announcement (test absent at $OLD_SHA); the file's 6 tests pass"
else bad "gt_cadence_shared"; fi

# --- 9 (N7, AC9): the eight scripts use the shared checkout; one runs and leaves no checkout -----------------------
N7="verify-session-176 verify-session-178 verify-session-179 demo-session-176 demo-session-178 demo-session-179 demo-session-184 demo-session-186"
MISS=""; for f in $N7; do
  grep -q 'lib-old-checkout.sh' "scripts/$f.sh" && grep -q 'vajra_old_checkout ' "scripts/$f.sh" \
    && ! grep -q 'git worktree add' "scripts/$f.sh" || MISS="$MISS $f"
done
mkdir -p "$T/oc"; rm -rf "$ROOT/target/verify-176-old"
VAJRA_OLD_CHECKOUTS="$T/oc" bash scripts/verify-session-176.sh > "$T/v176.out" 2>&1; R176=$?
LEFT=$(ls "$T/oc" | wc -l | tr -d ' ')
if [ -z "$MISS" ] && [ "$R176" -eq 0 ] && [ "$LEFT" = 0 ] && grep -q 'old build compiled from pinned pre-fix commit' "$T/v176.out"; then
  ok "N7: all 8 scripts take their checkout from lib-old-checkout.sh (none makes its own); verify-176 rebuilt its old binary through it, exit 0, and left 0 checkouts"
else bad "N7: missing:[$MISS] verify-176 exit $R176, $LEFT left"$'\n'"$(tail -5 "$T/v176.out")"; fi

echo "=== verify-session-199: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
