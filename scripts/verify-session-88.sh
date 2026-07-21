#!/usr/bin/env bash
# Session 88 verify — hash a review-time snapshot of the prompt file, not its current live bytes.
#
# S87 (a legitimate, docs-only fix) proved live that both hashing call sites — the Rust
# `attested_hash_outcome` (src/stations/mod.rs, drives `vajra next --stations`) and the bash
# `canonical_inputs_sha` (scripts/verify-closeout.sh, drives `--inputs-sha`/`--attest-only`) —
# read the prompt file's CURRENT on-disk bytes, never a snapshot from review/commit time. Editing
# ANY historical prompt file for any reason silently un-attests that session's review.
#
# This script proves, against THIS repo's real history (not a synthetic fixture alone, the S86
# house pattern) AND a temp-repo fixture (for the case real history can't safely reproduce):
#   (1) cargo build/test/clippy/fmt stay green, including a NEW regression test
#       (`reviewer_stays_verified_after_a_later_session_edits_the_same_prompt_file`).
#   (2) the Rust side: `vajra next --stations 76` — Reviewer/Releaser flip back PASSED, live,
#       against this repo's real S76→S87 history (the exact incident this session fixes).
#   (3) BONUS, real, previously-undiagnosed: `vajra next --stations 73` and `--stations 79` ALSO
#       flip Reviewer PASSED — both were misclassified "genuinely unreconstructable" by S86, but
#       `git log --follow` proves their prompt files were ALSO edited by a later session
#       (S81 for 79, S74 for 73) — the exact same root cause, not a coincidence.
#   (4) S64 and S69 stay Unverifiable — confirmed via `git log --follow` to have NO later edit,
#       so their gap is a genuinely different, disclosed, unchanged cause (S86).
#   (5) the bash side, in an isolated temp-repo fixture (real git, genuine merge-base emit/verify
#       pairing — the honest scope `canonical_inputs_sha` supports, a single (base,tip) pair for
#       the CURRENTLY open session): `--inputs-sha` then `--attest-only` match on a live branch,
#       and an UNCOMMITTED stray edit to the prompt file no longer flips that match (AC3) —
#       before this fix, `cat` would have read the stray edit and broken it.
#   (6) scope: no new command, no CONSTRAINTS.yaml key, only src/stations/mod.rs +
#       scripts/verify-closeout.sh + their tests/this proof changed.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="88"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-46s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-46s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# ── (1) baseline hygiene ─────────────────────────────────────────────────────
run_check "cargo-build"  cargo build --quiet --release --bin vajra
run_check "cargo-test"   cargo test --quiet --lib
run_check "cargo-fmt"    cargo fmt -- --check
run_check "cargo-clippy" cargo clippy --all-targets --quiet -- -D warnings
run_check "new-regression-test-present" \
  grep -q "fn reviewer_stays_verified_after_a_later_session_edits_the_same_prompt_file" \
  src/stations/mod.rs

BIN="$ROOT/target/release/vajra"

# ── (2) the direct fix: S76 flips back PASSED, live, real history ───────────
stations_76_reviewer_passed() { "$BIN" next --stations 76 | grep -q '\[PASSED\] Reviewer'; }
run_check "stations-76-reviewer-passed" stations_76_reviewer_passed
stations_76_releaser_passed() { "$BIN" next --stations 76 | grep -q '\[PASSED\] Releaser'; }
run_check "stations-76-releaser-passed" stations_76_releaser_passed

# ── (3) BONUS real finding: S73 and S79 were ALSO victims of this same bug ──
# git log --follow proves a LATER session touched their prompt file (S81 -> 79, S74 -> 73) —
# the same shape as S87 -> 76. Before this session's fix, both misread as Unverifiable.
# Heuristic: the MOST RECENT commit touching the file — does its subject's LEADING "S<NN>"
# token exceed the file's own session number? (Prefix-only, not a full-text scan: a session's
# own summary often mentions a LATER candidate number in prose — e.g. S69's own delivery
# commit says "...3 ranked S71 candidates" — which a full-text scan would misread as evidence
# S71 touched the file. The commit's own AUTHORING session is always its subject's leading
# token — house convention "S<NN>: ..." / "S<NN> ...", holds across this repo's history.)
prompt_touched_by_later_session() {
  local nn="$1"
  local subject tok
  subject=$(git log --follow --format='%s' -n1 -- "prompts/${nn}-task-*.md" 2>/dev/null)
  tok=$(printf '%s' "$subject" | grep -oiE '^S[0-9]{2}' | tr -d 'Ss' | sed 's/^0*//')
  [ -n "$tok" ] && [ "$tok" -gt "$nn" ]
}
prompt_73_has_later_edit() { prompt_touched_by_later_session 73; }
run_check "prompt-73-touched-by-later-session" prompt_73_has_later_edit
prompt_79_has_later_edit() { prompt_touched_by_later_session 79; }
run_check "prompt-79-touched-by-later-session" prompt_79_has_later_edit
stations_73_reviewer_passed() { "$BIN" next --stations 73 | grep -q '\[PASSED\] Reviewer'; }
run_check "stations-73-reviewer-passed-bonus" stations_73_reviewer_passed
stations_79_reviewer_passed() { "$BIN" next --stations 79 | grep -q '\[PASSED\] Reviewer'; }
run_check "stations-79-reviewer-passed-bonus" stations_79_reviewer_passed

# ── (4) S64/S69 stay Unverifiable — a genuinely different, unchanged cause ──
# No commit outside their OWN session (or the preceding session's legitimate scaffold-commit)
# ever touches their prompt file — so this fix correctly leaves them as-is (disclosed, S86).
prompt_64_has_no_later_edit() { ! prompt_touched_by_later_session 64; }
run_check "prompt-64-no-later-edit-stays-unverifiable" prompt_64_has_no_later_edit
prompt_69_has_no_later_edit() { ! prompt_touched_by_later_session 69; }
run_check "prompt-69-no-later-edit-stays-unverifiable" prompt_69_has_no_later_edit
stations_64_reviewer_absent() { "$BIN" next --stations 64 | grep -q '\[ABSENT\] Reviewer'; }
run_check "stations-64-reviewer-still-absent" stations_64_reviewer_absent
stations_69_reviewer_absent() { "$BIN" next --stations 69 | grep -q '\[ABSENT\] Reviewer'; }
run_check "stations-69-reviewer-still-absent" stations_69_reviewer_absent

# ── (5) bash side, isolated temp-repo fixture: emit/verify pairing + AC3 ────
# canonical_inputs_sha's honest scope is ONE (base,tip) pair for the CURRENTLY open session —
# this proves that scope correctly: emit then verify match on a live branch, and an
# UNCOMMITTED stray edit no longer flips the match (the S88 fix). It does NOT claim to fix
# `--attest-only <a different, already-merged N>` from an unrelated branch — that was never
# this function's design (only ONE candidate is tried; the historical multi-candidate search
# is the Rust side's job, proven in (2)-(4) above) and remains a disclosed, pre-existing scope
# boundary, unchanged by this session.
bash_emit_verify_pairing_survives_stray_edit() (
  # Subshell (parens, not braces): an EXIT trap set here is local to THIS subshell only — a
  # RETURN trap set in a plain function body would keep firing on every later function's
  # return for the rest of the script, referencing `$tmp` after it's out of scope.
  set -e
  local tmp; tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  git init -q -b main "$tmp"
  git -C "$tmp" config user.email t@t
  git -C "$tmp" config user.name t
  mkdir -p "$tmp/prompts" "$tmp/sessions"
  printf '# Session 05 fixture\noriginal text\n' > "$tmp/prompts/05-task-fixture.md"
  git -C "$tmp" add -A
  git -C "$tmp" commit -qm "main: session 05 prompt scaffolded"
  git -C "$tmp" checkout -qb session-05-x
  printf 'work\n' > "$tmp/work.txt"
  git -C "$tmp" add -A
  git -C "$tmp" commit -qm "s05 work"

  local h1
  h1=$(CLAUDE_PROJECT_DIR="$tmp" bash "$ROOT/scripts/verify-closeout.sh" --inputs-sha 5)
  [ -n "$h1" ] || return 1

  printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** %s\n' "$h1" > "$tmp/sessions/session-05-review.md"
  git -C "$tmp" add -A
  git -C "$tmp" commit -qm "s05 review"

  CLAUDE_PROJECT_DIR="$tmp" bash "$ROOT/scripts/verify-closeout.sh" --attest-only 5 \
    | grep -q "^ATTEST: PASS$" || return 1

  # Uncommitted stray edit to the prompt file — must NOT change the outcome after this fix.
  printf '# Session 05 fixture\noriginal text\nSTRAY UNCOMMITTED EDIT\n' > "$tmp/prompts/05-task-fixture.md"
  CLAUDE_PROJECT_DIR="$tmp" bash "$ROOT/scripts/verify-closeout.sh" --attest-only 5 \
    | grep -q "^ATTEST: PASS$"
)
run_check "bash-emit-verify-survives-stray-edit" bash_emit_verify_pairing_survives_stray_edit

# ── (6) scope: no new command, no CONSTRAINTS.yaml key ──────────────────────
scope_no_new_command() {
  ! git diff --name-only main..HEAD -- src/cli 2>/dev/null | grep -q .
}
run_check "scope-no-new-cli-command" scope_no_new_command
scope_no_constraints_key_change() {
  ! git diff --name-only main..HEAD -- .ai/CONSTRAINTS.yaml 2>/dev/null | grep -q .
}
run_check "scope-no-constraints-key-change" scope_no_constraints_key_change

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-46s %s\n' "STEP" "RESULT"
printf '%-46s %s\n' "----------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
