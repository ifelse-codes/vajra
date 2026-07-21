#!/usr/bin/env bash
# Session 86 verify — hardens `reviewer_status`/`session_attested_accept` (src/stations/mod.rs)
# from a bare `.contains("review-inputs-sha")` LABEL match into a real recompute-and-compare
# against the canonical `sha256(prompt bytes \0 delivery diff)` hash. Proves, both via the unit
# suite and a real E2E `vajra next --stations NN` run against a synthetic temp git repo ($0, no
# paid API call):
#   (1) a genuine, matching hash -> Reviewer PASSED (unchanged happy path)
#   (2) a well-formed but WRONG hash (forged/stale) -> Reviewer ABSENT (the pre-S86 gap; this
#       used to silently pass)
#   (2b) a hash recycled from a DIFFERENT session's real review -> also ABSENT (the prompt bytes
#        anchor the hash to its own session)
#   (3) no attestation line at all -> ABSENT, unchanged
#   (4) the Releaser's `NoBranch` fallback (`session_attested_accept`) carries the SAME fix, not
#       a hand-duplicated check
#   (6) cargo test --lib stays green (270, +3), clippy + fmt clean, scope = 1 file

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="86"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-42s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-42s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

BIN="$ROOT/target/debug/vajra"
cargo build --quiet --bin vajra

# ── unit — the new/updated tests directly exercising AttestOutcome ─────────────────────────
run_check "unit-reviewer-verified-rejects-forged" \
  cargo test --quiet --lib stations::tests::reviewer_passes_on_verified_hash_rejects_forged
run_check "unit-reviewer-rejects-recycled" \
  cargo test --quiet --lib stations::tests::reviewer_absent_when_hash_recycled_from_another_session
run_check "unit-reviewer-malformed-or-missing" \
  cargo test --quiet --lib stations::tests::reviewer_absent_on_missing_reject_or_malformed_attestation
run_check "unit-releaser-verified-fallback" \
  cargo test --quiet --lib stations::tests::releaser_passes_when_no_branch_but_ledger_attested
run_check "unit-releaser-rejects-forged" \
  cargo test --quiet --lib stations::tests::releaser_absent_when_no_branch_but_hash_forged

# ── E2E — build a real git repo the compiled binary reads via `next --stations` ─────────────
TMP_REPO=$(mktemp -d)
trap 'rm -rf "$TMP_REPO"' EXIT
mkdir -p "$TMP_REPO/.ai" "$TMP_REPO/prompts" "$TMP_REPO/sessions" "$TMP_REPO/scripts"
git -C "$TMP_REPO" init -q -b main
git -C "$TMP_REPO" config user.email t@t
git -C "$TMP_REPO" config user.name t
echo "init" > "$TMP_REPO/README.md"
git -C "$TMP_REPO" add -A
git -C "$TMP_REPO" commit -qm init

land_session() {
  # land_session NN marker — cut session-NN-x off main, add one real file change, commit, merge
  # --no-ff, delete the local branch. Mirrors the mandatory S37 merge+prune close step.
  local nn="$1" marker="$2"
  printf 'prompt for session %s\n' "$nn" > "$TMP_REPO/prompts/${nn}-task-fixture.md"
  git -C "$TMP_REPO" add -A
  git -C "$TMP_REPO" commit -qm "add prompt ${nn}"
  local base; base=$(git -C "$TMP_REPO" rev-parse HEAD)
  git -C "$TMP_REPO" checkout -qb "session-${nn}-x"
  printf 'work\n' > "$TMP_REPO/${marker}.txt"
  git -C "$TMP_REPO" add -A
  git -C "$TMP_REPO" commit -qm "s${nn} work"
  local tip; tip=$(git -C "$TMP_REPO" rev-parse HEAD)
  git -C "$TMP_REPO" checkout -q main
  git -C "$TMP_REPO" merge -q --no-ff "session-${nn}-x" -m "merge ${nn}"
  git -C "$TMP_REPO" branch -D "session-${nn}-x" >/dev/null
  echo "$base $tip"
}

canonical_hash() {
  # canonical_hash NN base tip — same sha256(prompt \0 diff) preimage as canonical_inputs_sha,
  # trailing-newline-stripped diff included (mirrors bash `$(...)` semantics).
  local nn="$1" base="$2" tip="$3"
  local diff
  diff=$(git -C "$TMP_REPO" diff --no-color --no-ext-diff "$base" "$tip" -- \
    ':(exclude)sessions' ':(exclude)prompts' \
    ':(exclude).ai/STATE.md' ':(exclude).ai/SESSION-BOOT.md' \
    ':(exclude).ai/SESSION' ':(exclude).ai/TASK.md' \
    ':(exclude).ai/ROADMAP.md' ':(exclude).ai/KNOWLEDGE.md' \
    ':(exclude).ai/verify' ':(exclude).ai/.session-owner')
  { cat "$TMP_REPO/prompts/${nn}-task-fixture.md"; printf '\0'; printf '%s' "$diff"; } | shasum -a 256 | awk '{print $1}'
}

read_out() { (cd "$TMP_REPO" && "$BIN" next --stations "$1" 2>&1); }

# ── (1) genuine, matching hash -> Reviewer PASSED ───────────────────────────────────────────
read -r BASE60 TIP60 <<< "$(land_session 60 f60)"
HASH60=$(canonical_hash 60 "$BASE60" "$TIP60")
printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** %s\n' "$HASH60" > "$TMP_REPO/sessions/session-60-review.md"
e2e_genuine_hash_passes() { read_out 60 | grep -q '\[PASSED\] Reviewer'; }
run_check "e2e-genuine-hash-passes" e2e_genuine_hash_passes

# ── (2) well-formed but WRONG hash -> ABSENT (the pre-S86 gap) ──────────────────────────────
FORGED=$(printf 'f%.0s' $(seq 1 64))
printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** %s\n' "$FORGED" > "$TMP_REPO/sessions/session-60-review.md"
e2e_forged_hash_absent() { read_out 60 | grep -q '\[ABSENT\] Reviewer'; }
run_check "e2e-forged-hash-rejected" e2e_forged_hash_absent

# ── (2b) hash recycled from a DIFFERENT session's real review -> ABSENT ────────────────────
read -r BASE61 TIP61 <<< "$(land_session 61 f61)"
HASH61=$(canonical_hash 61 "$BASE61" "$TIP61")
printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** %s\n' "$HASH61" > "$TMP_REPO/sessions/session-61-review.md"
e2e_session61_genuine_passes() { read_out 61 | grep -q '\[PASSED\] Reviewer'; }
run_check "e2e-session61-genuine-hash-passes" e2e_session61_genuine_passes
# recycle S61's genuine hash into S60's review (S60 has a DIFFERENT prompt) -> must reject
printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** %s\n' "$HASH61" > "$TMP_REPO/sessions/session-60-review.md"
e2e_recycled_hash_absent() { read_out 60 | grep -q '\[ABSENT\] Reviewer'; }
run_check "e2e-recycled-hash-rejected" e2e_recycled_hash_absent

# ── (3) no attestation line at all -> ABSENT, unchanged ─────────────────────────────────────
printf '**Verdict:** ACCEPT\n' > "$TMP_REPO/sessions/session-60-review.md"
e2e_missing_attestation_absent() { read_out 60 | grep -q '\[ABSENT\] Reviewer'; }
run_check "e2e-missing-attestation-absent" e2e_missing_attestation_absent

# ── (4) Releaser NoBranch fallback carries the same fix ─────────────────────────────────────
read -r BASE62 TIP62 <<< "$(land_session 62 f62)"
HASH62=$(canonical_hash 62 "$BASE62" "$TIP62")
printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** %s\n' "$HASH62" > "$TMP_REPO/sessions/session-62-review.md"
e2e_releaser_genuine_passes() { read_out 62 | grep -q '\[PASSED\] Releaser'; }
run_check "e2e-releaser-genuine-hash-passes" e2e_releaser_genuine_passes
printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** %s\n' "$FORGED" > "$TMP_REPO/sessions/session-62-review.md"
e2e_releaser_forged_absent() { read_out 62 | grep -q '\[ABSENT\] Releaser'; }
run_check "e2e-releaser-forged-hash-rejected" e2e_releaser_forged_absent

# ── (6) full lib suite + clippy + fmt + scope ────────────────────────────────────────────────
run_check "lib-suite-green" cargo test --quiet --lib
run_check "clippy-clean" cargo clippy --all-targets -- -D warnings
run_check "fmt-clean" cargo fmt --check

scope_is_stations_only() {
  local changed
  changed=$(git diff --name-only main -- src/ | sort)
  [ "$changed" = "src/stations/mod.rs" ]
}
run_check "scope-1-file-only" scope_is_stations_only

# ── report ───────────────────────────────────────────────────────────────
{
  echo "Session ${SESSION} verify — recompute-and-compare attestation hash (no more bare label match)"
  echo "artifacts: $ARTIFACTS"
  echo
  for r in "${RESULTS[@]}"; do echo "  $r"; done
  echo
  echo "PASS=$PASS FAIL=$FAIL"
} | tee "$ARTIFACTS/summary.txt"

ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"
[ "$FAIL" -eq 0 ] || { echo "VERIFY FAILED ($FAIL red)"; exit 1; }
echo "VERIFY GREEN ($PASS/$PASS)"
