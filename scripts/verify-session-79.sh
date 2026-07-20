#!/usr/bin/env bash
# Session 79 verify — re-price the stale static opus rate (receipt-accuracy pass).
# Proves, against COMMITTED code + a live run (CI-safe — no paid API call needed):
#   (1) claude-opus-4-8/4-7/4-6 now price at the confirmed current rate ($5/$25 per MTok), not the
#       stale $15/$75 (opus-4.0/4.1-era) the generic "claude-opus-4" prefix used to apply to all;
#   (2) legacy/unconfirmed opus ids (4.0, 4.1, 4.5, ...) fall through to the generic entry and keep
#       the historical rate — a specific-before-generic prefix, the recorded granularity decision;
#   (3) UNKNOWN_MODEL_PRICING still exceeds every real rate in MODEL_PRICING on both dimensions —
#       the fallback never undercounts, even now that opus is cheaper than Claude Fable 5;
#   (4) the S66/S78 authoritative path is untouched — this is an estimate-only rate correction;
#   (5) `vajra estimate` (the interactive/estimate path this session targets) now prices its
#       default model at $5/$25 live, not $15/$75.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="79"
METER="src/meter/mod.rs"
ESTIMATE="src/cli/estimate.rs"

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

# ── (1) current opus ids are priced ahead of the generic legacy fallback ──
specific_opus_entries_precede_generic() {
  # The three current-opus entries must appear in the source BEFORE the generic "claude-opus-4"
  # fallback entry, since pricing_for returns the first prefix match.
  local specific_line generic_line
  specific_line=$(grep -n 'prefix: "claude-opus-4-8"' "$METER" | head -1 | cut -d: -f1)
  generic_line=$(grep -n 'prefix: "claude-opus-4",' "$METER" | head -1 | cut -d: -f1)
  [ -n "$specific_line" ] && [ -n "$generic_line" ] && [ "$specific_line" -lt "$generic_line" ]
}
run_check "specific-opus-entries-precede-generic" specific_opus_entries_precede_generic
run_check "regression-opus-4-8-current-rate" \
  cargo test --quiet --lib opus_4_8_prices_at_current_rate_legacy_opus_keeps_historical_rate

# ── (2) hand-calc regression locks the corrected figure ────────────────────
run_check "regression-cost-formula-hand-calc" \
  cargo test --quiet --lib meter_cost_formula_matches_hand_calculation

# ── (3) unknown-model fallback stays an upper bound, never an undercount ──
run_check "regression-unknown-model-upper-bound" \
  cargo test --quiet --lib unknown_model_pricing_still_exceeds_every_known_rate

# ── (4) authoritative (S66/S78) path tests are unaffected by this change ──
run_check "regression-authoritative-headline" \
  cargo test --quiet --lib authoritative_total_is_the_headline_estimate_is_labeled
run_check "regression-s78-captured-stream" \
  cargo test --quiet --lib s78_real_captured_result_stream_yields_authoritative_headline
run_check "regression-s76-fable-fixture" \
  cargo test --quiet --lib s76_fable_headless_fixture_prices_fable_and_reports_no_authoritative

# ── (5) the estimate path (interactive/estimate) prices at the corrected rate ──
run_check "estimate-default-model-is-opus-4-8" grep -q 'claude-opus-4-8' "$ESTIMATE"
run_check "regression-estimate-hand-math" \
  cargo test --quiet --lib cli::estimate::tests::cost_calculation_matches_hand_math
estimate_live_shows_corrected_rate() {
  # Live: `vajra estimate` must show $5/MTok input, never the stale $15/MTok.
  local out
  out=$(cargo run --quiet -- estimate 2>&1)
  echo "$out" | grep -q '@ \$5/MTok' && ! echo "$out" | grep -q '@ \$15/MTok'
}
run_check "estimate-live-shows-corrected-rate" estimate_live_shows_corrected_rate

# ── the whole lib suite stays green ────────────────────────────────────────
run_check "lib-suite-green" cargo test --quiet --lib

# ── report ─────────────────────────────────────────────────────────────────
{
  echo "Session ${SESSION} verify — re-price the stale static opus rate"
  echo "artifacts: $ARTIFACTS"
  echo
  for r in "${RESULTS[@]}"; do echo "  $r"; done
  echo
  echo "PASS=$PASS FAIL=$FAIL"
} | tee "$ARTIFACTS/summary.txt"

ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"
[ "$FAIL" -eq 0 ] || { echo "VERIFY FAILED ($FAIL red)"; exit 1; }
echo "VERIFY GREEN ($PASS/$PASS)"
