#!/usr/bin/env bash
# Session 77 verify — receipt truth on real runs.
# Proves the two S77 fixes, entirely against COMMITTED evidence (CI-safe; the raw 284KB S76
# transcripts are gitignored, so nothing here depends on them):
#   (1) fable-5 is in meter::MODEL_PRICING at real rates ($10/$50), no longer the opus upper bound;
#   (2) metering the real S76-captured fixture (fable-5, headless, NO type:result) yields a receipt
#       that says "no authoritative cost available" + a fable-priced estimate — never "$… total".
# The committed S76 run receipts carry the BEFORE state ($14.3894 total, opus-bound) for contrast.
# `cargo test --lib` stays green. The QA gate re-runs this live at close.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="77"
FIXTURE="sessions/session-76-artifacts/fixtures/s76-fable-headless.jsonl"
RUN1_RECEIPT="sessions/session-76-artifacts/run1/receipt.stderr.txt"
METER="src/meter/mod.rs"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# Meter the fixture once; reuse the captured output across checks.
RECEIPT_OUT="$ARTIFACTS/meter-fixture.txt"
cargo run --quiet -- meter "$FIXTURE" > "$RECEIPT_OUT" 2>&1 || true

# ── criterion 1: fable-5 priced with real rates, not opus upper bound ──
pricing_has_fable5() {
  # the entry must set the fable-5 prefix and the $10/$50 rates
  grep -q 'prefix: "claude-fable-5"' "$METER" \
    && grep -q 'input_per_mtok: 10.0' "$METER" \
    && grep -q 'output_per_mtok: 50.0' "$METER"
}
run_check "pricing-has-fable5-real-rates" pricing_has_fable5

# ── the regression fixture is real S76-captured data, not fabricated ──
run_check "fixture-exists"        test -f "$FIXTURE"
fixture_is_real_s76() {
  grep -q '_provenance' "$FIXTURE" \
    && grep -q 'run1/run.jsonl' "$FIXTURE" \
    && grep -q 'claude-fable-5' "$FIXTURE"
}
run_check "fixture-is-real-s76-data" fixture_is_real_s76
# and it genuinely carries NO authoritative result line (the whole point)
run_check "fixture-has-no-result-line" bash -c "! grep -q '\"type\":\"result\"' '$FIXTURE'"

# ── criterion 2: metering it → 'no authoritative cost available', never a '$… total' ──
run_check "meter-says-no-authoritative" grep -qi "no authoritative cost available" "$RECEIPT_OUT"
run_check "meter-headline-not-a-total"  bash -c "! grep -qE '\\\$[0-9.]+  total' '$RECEIPT_OUT'"
# ── the estimate is at REAL fable rates now, not the opus upper bound ──
run_check "meter-fable-priced-estimate" grep -q '0.2500' "$RECEIPT_OUT"
run_check "meter-no-opus-bound-tag"     bash -c "! grep -qi 'priced as opus upper bound' '$RECEIPT_OUT'"

# ── BEFORE state (committed receipt): the opus-bound overstatement we removed ──
before_state_opus_bound() {
  grep -q 'total' "$RUN1_RECEIPT" && grep -qi 'opus upper bound' "$RUN1_RECEIPT"
}
run_check "before-receipt-was-opus-bound" before_state_opus_bound

# ── criterion 4: the regression test on the real fixture passes ──
run_check "regression-test-passes" \
  cargo test --quiet --lib s76_fable_headless_fixture_prices_fable_and_reports_no_authoritative

# ── criterion 4: the whole lib suite stays green ──
run_check "lib-suite-green" cargo test --quiet --lib

# ── report ─────────────────────────────────────────────────────────────
{
  echo "Session ${SESSION} verify — receipt truth on real runs"
  echo "artifacts: $ARTIFACTS"
  echo
  for r in "${RESULTS[@]}"; do echo "  $r"; done
  echo
  echo "PASS=$PASS FAIL=$FAIL"
} | tee "$ARTIFACTS/summary.txt"

ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"
[ "$FAIL" -eq 0 ] || { echo "VERIFY FAILED ($FAIL red)"; exit 1; }
echo "VERIFY GREEN ($PASS/$PASS)"
