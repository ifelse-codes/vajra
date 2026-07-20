#!/usr/bin/env bash
# Session 82 verify — Releaser station reads from the attested ledger when a session's branch has
# been merged and pruned (BranchShip::NoBranch), instead of a false [ABSENT] "branch not merged".
# Proves, against COMMITTED code + a live corpus check (CI-safe — no paid API call needed):
#   (1) NoBranch + attested ACCEPT ledger evidence → PASSED, naming the ledger as the source (AC1)
#   (2) NoBranch + no ledger evidence (ghost session) → ABSENT, no false positive (AC2)
#   (3) NoBranch + a REJECT verdict (even attested) is not shipping evidence → ABSENT (AC2 edge)
#   (4) Unmerged branch path is unchanged (AC3)
#   (5) the happy-path Merged/synced/pruned case is unchanged (AC4)
#   (6) `vajra next --stations 81` shows [PASSED] Releaser SHIP live, on the real repo (AC5)
#   (7) the full lib suite stays green, with the corrected 8/8 fixture ceiling (AC6)

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="82"
STATIONS="src/stations/mod.rs"

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

# ── (1) AC1 — NoBranch + attested ACCEPT ledger → PASSED ──────────────────
run_check "regression-ac1-ledger-fallback-passes" \
  cargo test --quiet --lib stations::tests::releaser_passes_when_no_branch_but_ledger_attested

# ── (2) AC2 — NoBranch + no ledger evidence → ABSENT (no false positive) ──
run_check "regression-ac2-no-ledger-stays-absent" \
  cargo test --quiet --lib stations::tests::releaser_absent_when_no_branch_and_no_ledger

# ── (3) AC2 edge — NoBranch + REJECT verdict (even attested) → ABSENT ─────
run_check "regression-ac2-reject-verdict-stays-absent" \
  cargo test --quiet --lib stations::tests::releaser_absent_when_no_branch_but_ledger_rejects

# ── (4) AC3 — unmerged branch path unchanged ───────────────────────────────
run_check "regression-ac3-unmerged-unchanged" \
  cargo test --quiet --lib stations::tests::releaser_passes_only_when_branch_merged_and_pruned

# ── (5) AC4 — the fully-evidenced fixture reaches the corrected 8/8 ceiling ─
run_check "regression-ac4-ac6-fixture-reaches-8-of-8" \
  cargo test --quiet --lib stations::tests::fully_filled_session_counts_high

# ── (5b) --advance's release_gate_for_close is untouched (NoBranch stays a warning there) ──
release_gate_for_close_untouched() {
  ! git diff main -- src/releaser/mod.rs | grep -q '^[+-]'
}
run_check "release-gate-for-close-untouched" release_gate_for_close_untouched

# ── (6) AC5 — live corpus check: session 81 (merged + pruned, attested ACCEPT) ──
stations_81_shows_passed_releaser() {
  local out
  out=$(cargo run --quiet -- next --stations 81 2>&1)
  echo "$out" | grep -q '\[PASSED\] Releaser' \
    && echo "$out" | grep -qi 'ledger' \
    && echo "$out" | grep -q '7 of 8 stations passed'
}
run_check "live-stations-81-releaser-passed" stations_81_shows_passed_releaser

# ── scope check: only the stations module changed ──────────────────────────
scope_is_stations_module_only() {
  local changed
  changed=$(git diff --name-only main -- src/ | sort)
  [ "$changed" = "$STATIONS" ]
}
run_check "scope-stations-module-only" scope_is_stations_module_only

# ── the whole lib suite + clippy + fmt stay clean ───────────────────────────
run_check "lib-suite-green" cargo test --quiet --lib
run_check "clippy-clean" cargo clippy --all-targets -- -D warnings
run_check "fmt-clean" cargo fmt --check

# ── report ───────────────────────────────────────────────────────────────
{
  echo "Session ${SESSION} verify — Releaser reads the ledger when the branch is pruned"
  echo "artifacts: $ARTIFACTS"
  echo
  for r in "${RESULTS[@]}"; do echo "  $r"; done
  echo
  echo "PASS=$PASS FAIL=$FAIL"
} | tee "$ARTIFACTS/summary.txt"

ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"
[ "$FAIL" -eq 0 ] || { echo "VERIFY FAILED ($FAIL red)"; exit 1; }
echo "VERIFY GREEN ($PASS/$PASS)"
