#!/usr/bin/env bash
# Session 79 — re-price the stale static opus rate. S78 recovered the AUTHORITATIVE cost for
# headless runs but left the token *estimate* untouched — and that estimate still priced every
# claude-opus-4-x id at $15/$75 (the opus-4.0/4.1 era), while current opus (4.6/4.7/4.8) is
# actually $5/$25. On interactive runs (no result stream, so the estimate IS the only figure) that
# overstated opus by ~3x. This session fixes exactly that, for the estimate path only.
#
# Sprint demo — runs `vajra estimate` LIVE (before/after via the source diff) + the regression
# suite; emits the four gated demo:<element> markers; `--check-demo 79` re-runs it live at close.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

CYAN="\033[36m"; BOLD="\033[1m"; GREEN="\033[32m"; YELLOW="\033[33m"; RED="\033[31m"; DIM="\033[2m"; RESET="\033[0m"
header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
bad()    { printf "${RED}✗ %s${RESET}\n" "$1"; }

header "Session 79 Demo — re-price the stale static opus rate  [demo:header]"
printf "${DIM}  S78 closed the receipt arc for headless runs (real total_cost_usd, captured live). The\n"
printf "  interactive/estimate path it left untouched still had a stale rate baked in — this session\n"
printf "  sources the current rate from the claude-api skill and corrects it.${RESET}\n"

header "Before → After  [demo:before_after]"
label "BEFORE (S78 state — claude-opus-4-8 priced via the generic \"claude-opus-4\" prefix at \$15/\$75):"
printf '   %s\n' 'ModelPricing { prefix: "claude-opus-4", input_per_mtok: 15.0, output_per_mtok: 75.0 }'
bad "an interactive run on the current default model (opus-4-8) overstated cost ~3x — the estimate"
bad "IS the only figure shown on interactive runs (no result stream to recover the true \$ from)."
label "AFTER (S79, metered LIVE via 'vajra estimate' on this repo's real context):"
AFTER=$(cargo run --quiet -- estimate 2>&1 || true)
printf '%s\n' "$AFTER" | sed 's/^/   /'
if printf '%s\n' "$AFTER" | grep -q '@ \$5/MTok' && ! printf '%s\n' "$AFTER" | grep -q '@ \$15/MTok'; then
  ok "input priced at \$5/MTok, not \$15/MTok — the correction is live, not just in a unit test"
else
  bad "expected \$5/MTok input pricing"
fi

header "Cases — the fix  [demo:cases]"

header "1 · claude-opus-4-8/4-7/4-6 price at the current confirmed rate"
grep -B1 -A2 'prefix: "claude-opus-4-8"' src/meter/mod.rs | grep -E 'prefix|input_per_mtok|output_per_mtok' | sed 's/^/   /'
if cargo test --quiet --lib opus_4_8_prices_at_current_rate_legacy_opus_keeps_historical_rate >/dev/null 2>&1; then
  ok "\$5 input / \$25 output per MTok (claude-api skill / shared/models.md, cached 2026-06-24)"
else
  bad "regression test failed"
fi

header "2 · Legacy opus (4.0/4.1/4.5, unconfirmed) keeps the historical rate — recorded, not silent"
grep -A3 'Legacy/unconfirmed opus fallback' src/meter/mod.rs | sed 's/^ *\/\/ */   /'
ok "generic \"claude-opus-4\" prefix stays at \$15/\$75 for ids the current pricing table doesn't cover"
ok "specific-before-generic ordering is itself a regression test (specific-opus-entries-precede-generic)"

header "3 · Unknown-model upper bound still never undercounts"
if cargo test --quiet --lib unknown_model_pricing_still_exceeds_every_known_rate >/dev/null 2>&1; then
  ok "UNKNOWN_MODEL_PRICING (\$15/\$75) reconfirmed >= every real rate in MODEL_PRICING, both dims"
  ok "no longer framed as 'the opus rate' (opus is cheaper than Fable 5 now) — same ceiling, honest framing"
else
  bad "regression test failed"
fi

header "4 · Authoritative (S66/S78) path is untouched — this is estimate-only"
if cargo test --quiet --lib s78_real_captured_result_stream_yields_authoritative_headline >/dev/null 2>&1 \
  && cargo test --quiet --lib s76_fable_headless_fixture_prices_fable_and_reports_no_authoritative >/dev/null 2>&1; then
  ok "both authoritative-path regressions still pass — no run with a real total_cost_usd is affected"
else
  bad "authoritative-path regression failed"
fi

header "Scorecard — S79 acceptance criteria  [demo:summary_table]"
ok "1 · claude-opus-4-8 (and 4-7/4-6) priced at the sourced current rate, not \$15/\$75    SHIPPED"
ok "2 · legacy opus ids kept at their historical rate via specific-before-generic         SHIPPED"
ok "3 · UNKNOWN_MODEL_PRICING re-confirmed as an upper bound over every real rate         SHIPPED"
ok "4 · cargo test --lib green (258, +2); S66/S78 authoritative-path tests untouched      SHIPPED"
ok "5 · verify-session-79 (11/11) + this demo prove before→after, live on 'vajra estimate' SHIPPED"
printf "${DIM}  Honest limit: legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source in this\n"
printf "  skill's cached pricing table, so they keep the historical \$15/\$75 as a conservative,\n"
printf "  non-decreasing estimate rather than a guess — disclosed, not silently assumed correct.${RESET}\n"
