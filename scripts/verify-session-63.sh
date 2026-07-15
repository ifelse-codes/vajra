#!/usr/bin/env bash
# Session 63 — PAID DOGFOOD: measure the governed loop as EXPERIENCE.
# This is a measurement session (minimal-to-no src change), so the gate asserts the EVIDENCE exists and is
# real — a non-author can see the authoritative spend + the governance events — and that whatever src/ changed
# (nothing this session) stays green.
#   - the dogfood report exists and records the AUTHORITATIVE total_cost_usd (not the receipt)
#   - the report carries the governance-fired table + the obedience read
#   - the raw run artifact (run-result.json) actually contains total_cost_usd (the number is not hand-typed)
#   - the vajra receipt artifact is preserved (the ~4.7x overstatement is inspectable)
#   - cargo fmt/clippy/test/build stay green

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="63"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

REPORT="sessions/session-63-dogfood.md"
RUNJSON="sessions/session-63-artifacts/run-result.json"
RECEIPT="sessions/session-63-artifacts/vajra-receipt.txt"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-40s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-40s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates (no src changed this session; prove it stayed green) ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "cargo-build"   cargo build

# --- Evidence gates ---
run_check "dogfood-report-exists"       test -f "$REPORT"
run_check "run-artifact-exists"         test -f "$RUNJSON"
run_check "receipt-artifact-exists"     test -f "$RECEIPT"
# The report cites the authoritative cost, the governance table, and the obedience read.
run_check "report-records-total-cost"   grep -q 'total_cost_usd' "$REPORT"
run_check "report-cites-authoritative"  grep -q '1.2662' "$REPORT"
run_check "report-governance-table"     grep -qi 'Governance-fired table' "$REPORT"
run_check "report-obedience-read"       grep -q 'obedience' "$REPORT"
# The number is not hand-typed: it is present in the raw run JSON the binary emitted.
run_check "artifact-has-total-cost"     grep -q 'total_cost_usd' "$RUNJSON"
run_check "artifact-cost-matches"       grep -q '1.2662' "$RUNJSON"
# The receipt overstatement is inspectable (the receipt figure differs from the authoritative one).
run_check "receipt-overstates"          grep -q '5.96' "$RECEIPT"

echo ""
echo "=== Session 63 Verify Summary ==="
printf '%-40s %s\n' "STEP" "RESULT"
printf '%-40s %s\n' "----------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, 0 fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
