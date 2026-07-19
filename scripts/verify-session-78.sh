#!/usr/bin/env bash
# Session 78 verify — recover the true $ (capture the coding tool's OWN end-of-session cost).
# Proves the recovery path end-to-end against COMMITTED evidence (CI-safe — no paid run needed):
#   (1) the launcher tee-captures stdout ONLY on headless `-p` runs (interactive TTY untouched);
#   (2) `meter::extract_result_cost` reads `total_cost_usd` from a REAL captured result stream, and
#       `apply_captured_cost` promotes it to the receipt headline (S77 "no authoritative" -> real $);
#   (3) the None path (interactive / no result line) still yields S77's honest fallback (criterion 2);
#   (4) the tee never swallows — the live run's stdout carried the result line through untouched.
# A committed live-run receipt shows the AFTER state (a real "$… total"); the S76 fixture (on-disk
# transcript, no result line) is the BEFORE contrast. `cargo test --lib` stays green. QA re-runs this.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="78"
LAUNCH="src/cli/launch.rs"
METER="src/meter/mod.rs"
STREAM_FIXTURE="sessions/session-78-artifacts/fixtures/s78-headless-result-stream.txt"
TRANSCRIPT_FIXTURE="sessions/session-76-artifacts/fixtures/s76-fable-headless.jsonl"
LIVE_RECEIPT="sessions/session-78-artifacts/live-receipt.stderr.txt"
LIVE_RESULT="sessions/session-78-artifacts/live-result-line.txt"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-38s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-38s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# ── (1) capture is headless-only; interactive TTY stays inherited ──────────
run_check "is-headless-fn-exists"        grep -q 'fn is_headless' "$LAUNCH"
piped_only_when_headless() {
  # stdout is piped under `if headless`, else inherited — the guard that keeps interactive safe.
  grep -q 'if headless' "$LAUNCH" && grep -q 'Stdio::piped()' "$LAUNCH" \
    && grep -q 'Stdio::inherit()' "$LAUNCH"
}
run_check "stdout-piped-only-when-headless" piped_only_when_headless
run_check "is-headless-unit-test" \
  cargo test --quiet --lib is_headless_detects_print_flags_only

# ── tee never swallows: writes every byte through AND returns the copy ──────
tee_passes_through() {
  grep -q 'fn tee_and_capture' "$LAUNCH" && grep -q 'write_all' "$LAUNCH"
}
run_check "tee-passes-stdout-through" tee_passes_through

# ── (2) the real captured result-stream fixture is genuine + has a cost ─────
run_check "stream-fixture-exists" test -f "$STREAM_FIXTURE"
stream_fixture_is_real() {
  grep -q '_provenance' "$STREAM_FIXTURE" \
    && grep -q '"type":"result"' "$STREAM_FIXTURE" \
    && grep -q '"total_cost_usd"' "$STREAM_FIXTURE"
}
run_check "stream-fixture-real-with-cost" stream_fixture_is_real
run_check "extract-result-cost-fn-exists" grep -q 'pub fn extract_result_cost' "$METER"

# ── (2) end-to-end: extract -> apply -> authoritative headline (real fixture) ──
run_check "regression-real-captured-stream" \
  cargo test --quiet --lib s78_real_captured_result_stream_yields_authoritative_headline

# ── (3) None path keeps S77's honest fallback; existing figure not overridden ──
run_check "regression-none-path-noop" \
  cargo test --quiet --lib apply_captured_cost_none_is_a_noop_and_does_not_override_existing
run_check "regression-supersedes-absent" \
  cargo test --quiet --lib apply_captured_cost_supersedes_absent_and_drops_the_warning

# ── BEFORE contrast: the on-disk transcript genuinely carries no result line ──
run_check "before-transcript-has-no-result" \
  bash -c "! grep -q '\"type\":\"result\"' '$TRANSCRIPT_FIXTURE'"

# ── (4) LIVE evidence: the recovered receipt is a real total; stdout untouched ──
run_check "live-receipt-shows-real-total" \
  grep -qE '\$[0-9.]+  total' "$LIVE_RECEIPT"
run_check "live-receipt-not-no-authoritative" \
  bash -c "! grep -qi 'no authoritative cost available' '$LIVE_RECEIPT'"
run_check "live-stdout-carried-result-untouched" \
  bash -c "grep -q '\"type\":\"result\"' '$LIVE_RESULT' && grep -q '\"total_cost_usd\"' '$LIVE_RESULT'"

# ── the whole lib suite stays green ────────────────────────────────────────
run_check "lib-suite-green" cargo test --quiet --lib

# ── report ─────────────────────────────────────────────────────────────────
{
  echo "Session ${SESSION} verify — recover the true \$"
  echo "artifacts: $ARTIFACTS"
  echo
  for r in "${RESULTS[@]}"; do echo "  $r"; done
  echo
  echo "PASS=$PASS FAIL=$FAIL"
} | tee "$ARTIFACTS/summary.txt"

ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"
[ "$FAIL" -eq 0 ] || { echo "VERIFY FAILED ($FAIL red)"; exit 1; }
echo "VERIFY GREEN ($PASS/$PASS)"
