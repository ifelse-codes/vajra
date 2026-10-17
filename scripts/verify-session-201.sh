#!/usr/bin/env bash
# Session 201 verify — the S200 small fixes + the README "tested with" line (founder pick C, 2026-10-16):
#   N24   a review-only session's sign-off step says "write the report" first; verify/demo steps not needed
#   N22   verify-178 / demo-178 RETIRED as history — headers only, no check line changed
#   N25   in Vajra's own repo the merge step says to reinstall `vajra`; other projects get no such line
#   README  the "tested with" line, in the founder's words
# Rows 1–2 RUN the built `vajra next --steps` on a temp `vajra init` review-only project, and again with
# the binary from the commit S201 started at (edb92e3), where each must go red for its own reason (S122).
# Row 3 runs one named test (absent at edb92e3) and shows the site. Rows 4–5 diff against edb92e3.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
T="$(cd "$(mktemp -d)" && pwd -P)"
. "$ROOT/scripts/lib-old-checkout.sh"
trap 'vajra_old_checkout_remove "${OLD_WT:-}"; rm -rf "$T"' EXIT
OLD_SHA=edb92e3
VAJRA="$ROOT/target/release/vajra"
cargo build --release -q || { echo "FAIL: cargo build --release"; exit 1; }
OLD_VAJRA="$ROOT/target/s201-old/release/vajra"
if [ ! -x "$OLD_VAJRA" ]; then
  OLD_WT=$(vajra_old_checkout "$OLD_SHA") || { echo "FAIL: worktree at $OLD_SHA"; exit 1; }
  (cd "$OLD_WT" && CARGO_TARGET_DIR="$ROOT/target/s201-old" cargo build --release -q) || { echo "FAIL: build at $OLD_SHA"; exit 1; }
  vajra_old_checkout_remove "$OLD_WT"; OLD_WT=""
fi

human() { env -u CLAUDECODE -u CLAUDE_CODE_ENTRYPOINT -u CURSOR_TRACE_ID -u VAJRA_AGENT -u VAJRA_ALLOW_COMMIT \
            -u VAJRA_AGENT_MARK -u CLAUDE_PROJECT_DIR GIT_CONFIG_GLOBAL=/dev/null "$@"; }
has() { printf '%s\n' "$1" | grep -qF -- "$2"; }
# one_test FILTER [cargo-args...] → passes when exactly that one test ran and passed
one_test() { cargo test -q "$@" 2>&1 | grep -qE '^test result: ok\. 1 passed;'; }

# A `vajra init` project on review-only session 10 (every 5th), with the steps before the sign-off done:
# a recorded tech-lead, a filled `## Delta`, the founder's approval record. So the sign-off step is the
# first open one — as it was in S200.
P="$T/gt"; mkdir -p "$P"
(cd "$P" && human git init -q -b main && human "$VAJRA" init </dev/null >/dev/null 2>&1 \
  && echo 09 > .ai/SESSION && cp prompts/01-task-kickoff.md prompts/10-task-review.md \
  && human git checkout -qb session-10-review \
  && perl -0pi -e 's/- `\+` <what this session ADDS[^\n]*\n- `~` <[^\n]*\n- `-` <[^\n]*/- `+` sessions\/session-10-ground-truth.md, the review of sessions 6 to 9/' prompts/10-task-review.md \
  && printf 'crew researcher — deferred-budget — budget: 1 tokens — a stand-in verdict\n' > "$T/tl.md" \
  && human "$VAJRA" next --role tech-lead --from "$T/tl.md" >/dev/null 2>&1 \
  && mkdir -p .ai/approvals && printf '{"session": 10, "method": "approve-command", "at_unix": 1}\n' > .ai/approvals/session-10.json) \
  || { echo "FAIL: temp project"; exit 1; }
steps() { (cd "$P" && human "$1" next --steps "${2:-10}" 2>&1); }
how_of_next() { printf '%s\n' "$1" | grep -A1 'YOUR NEXT STEP' | sed -n 's/^ *how: //p'; }

# --- 1 (N24, AC1): no report → "write the report" first; with it → today's "show the founder" --------------
S0=$(steps "$VAJRA"); H0=$(how_of_next "$S0"); O0=$(how_of_next "$(steps "$OLD_VAJRA")")
mkdir -p "$P/sessions"; echo '# GT' > "$P/sessions/session-10-ground-truth.md"
S1=$(steps "$VAJRA"); H1=$(how_of_next "$S1")
rm "$P/sessions/session-10-ground-truth.md"
if has "$S0" "▶ YOUR NEXT STEP: the founder has signed off this review-only session's report" \
   && has "$H0" "write sessions/session-10-ground-truth.md (every audit, live), then show it to the founder" \
   && has "$S1" "▶ YOUR NEXT STEP: the founder has signed off" && has "$H1" "show the founder sessions/session-10-ground-truth.md;" \
   && ! has "$H1" "write sessions/" && ! has "$O0" "write sessions/" && has "$O0" "show the founder sessions/session-10-ground-truth.md"; then
  ok "N24: no report → the sign-off step (the first open one) says \"write sessions/session-10-ground-truth.md (every audit, live)\" first; report present → \"show the founder …\"; at $OLD_SHA it said \"show the founder\" with no report"
else bad "N24 report: new=[$H0] with-report=[$H1] old=[$O0]"; fi

# --- 2 (N24, AC1): verify/demo steps ✓ "not needed" on review-only 10; ✗ as before on CODE session 9 -------
GT=$(steps "$VAJRA" 10); CODE=$(steps "$VAJRA" 9); OLD=$(steps "$OLD_VAJRA" 10)
if has "$GT" "✓ the checks run and pass — not needed: the close passes it N/A on a review-only session" \
   && has "$GT" "✓ a demo script exists and draws every required section — not needed:" \
   && has "$CODE" "✗ the checks run and pass" && has "$CODE" "✗ a demo script exists" && ! has "$CODE" "not needed" \
   && has "$OLD" "✗ the checks run and pass" && has "$OLD" "✗ a demo script exists"; then
  ok "N24: review-only session 10 shows the verify and demo steps ✓ \"not needed\" (the close passes them N/A, verify-closeout.sh check_verify_demo_scripts); CODE session 9 keeps both ✗; at $OLD_SHA session 10 showed both ✗"
else bad "N24 scripts: gt=[$(printf '%s' "$GT" | grep -E 'checks run|demo script')] code=[$(printf '%s' "$CODE" | grep -E 'checks run|demo script')]"; fi

# --- 3 (N25, AC3): the merge step's reinstall note, Vajra's own repo only -----------------------------------
SITE=$(grep -n 'fn reinstall_note' src/nextstep/mod.rs | cut -d: -f1)
OLD_HAS=$(git show "$OLD_SHA:src/nextstep/mod.rs" | grep -c 'cargo install --path . --locked')
if one_test --lib only_vajras_own_repo_is_told_to_reinstall_after_the_merge && [ -n "$SITE" ] && [ "$OLD_HAS" = 0 ] \
   && grep -q '^name = "vajractl"' Cargo.toml; then
  ok "N25: src/nextstep/mod.rs:$SITE reinstall_note — the merge step (\"the work is merged and the branch is gone\") adds \`cargo install --path . --locked\` when Cargo.toml's [package] name is vajractl, nothing for another project or a dependency named vajractl (unit test ran, 1 passed); absent at $OLD_SHA"
else bad "N25: test or site missing (site=$SITE, old mentions=$OLD_HAS)"; fi

# --- 4 (N22, AC2): both scripts RETIRED, only comment lines added; ROADMAP says so ---------------------------
CODE_LINES=$(git diff "$OLD_SHA" -- scripts/verify-session-178.sh scripts/demo-session-178.sh | grep -E '^[-+]' | grep -vE '^(\+\+\+|---)' | grep -vc '^+#')
if [ "$CODE_LINES" = 0 ] && sed -n 2p scripts/verify-session-178.sh | grep -q '^# RETIRED (superseded) — S201' \
   && sed -n 2p scripts/demo-session-178.sh | grep -q '^# RETIRED (superseded) — S201' \
   && grep -q '^- \*\*N22 — RETIRED S201 (superseded' .ai/ROADMAP.md \
   && ! git show "$OLD_SHA:scripts/verify-session-178.sh" | grep -q RETIRED; then
  ok "N22: verify-178 and demo-178 open with a RETIRED (superseded) header; every changed line since $OLD_SHA is an added comment (0 other lines); ROADMAP's N22 entry says RETIRED S201"
else bad "N22: non-comment changed lines=$CODE_LINES"; fi

# --- 5 (AC4): the README line, in the founder's words -------------------------------------------------------
WORDS='**Tested with:** Claude Code on Opus and on Haiku 4.5.'
if grep -qF -- "$WORDS" README.md && grep -qF -- "what Vajra blocks (the 3-file cap, a push to main) held." README.md \
   && ! git show "$OLD_SHA:README.md" | grep -qF -- 'Tested with'; then
  ok "README: the picked \"tested with\" line is in README.md; absent at $OLD_SHA (who picked it is in the summary, not checkable here)"
else bad "README: the line is missing"; fi

echo "=== verify-session-201: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
