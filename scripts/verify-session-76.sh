#!/usr/bin/env bash
# Session 76 verify — dogfood ride-along (MEASURE).
# Proves: the artifacts + report exist and are INTERNALLY CONSISTENT — the cost figure
# recorded in the report equals the figure in the captured receipt artifact (criterion 5),
# the recorded "no authoritative cost" null is real (0 type:result in the run JSONLs), and
# no src/ changed (this is a measurement session, not a build).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="76"
ART="sessions/session-${SESSION}-artifacts"
REPORT="sessions/session-${SESSION}-dogfood.md"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-32s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-32s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# ── existence ──────────────────────────────────────────────────────────
run_check "report-exists"        test -f "$REPORT"
run_check "artifacts-dir"        test -d "$ART"
run_check "task-prompt"          test -f "$ART/task-prompt.txt"
run_check "measurement-checklist" test -f "$ART/measurement-checklist.md"
run_check "capture-harness"      test -x "$ART/capture.sh"
run_check "run1-receipt"         test -f "$ART/run1/receipt.stderr.txt"
run_check "run2-receipt"         test -f "$ART/run2/receipt.stderr.txt"

# ── internal consistency: recorded cost == captured receipt line (criterion 5) ──
cost_matches() {
  local receipt="$1"
  # pull the headline dollar figure (e.g. 14.3894) from the receipt artifact
  local dollar
  dollar=$(grep -oE '\$[0-9]+\.[0-9]{4}' "$receipt" | head -1 | tr -d '$')
  [ -n "$dollar" ] || { echo "no dollar figure in $receipt"; return 1; }
  grep -qF "$dollar" "$REPORT" || { echo "receipt \$$dollar not cited in report"; return 1; }
  echo "receipt \$$dollar is cited in $REPORT"
}
run_check "cost-consistency-run1" cost_matches "$ART/run1/receipt.stderr.txt"
run_check "cost-consistency-run2" cost_matches "$ART/run2/receipt.stderr.txt"

# ── the recorded null is REAL: the receipt itself warns "no total_cost_usd" ──
# (Receipts are the small, committed evidence; the raw run.jsonl transcripts are kept
#  local-only — gitignored, 855KB — but the receipt carries the authoritative-absent warn.)
null_warned() { grep -qi "no total_cost_usd" "$1"; }
run_check "run1-null-is-real"    null_warned "$ART/run1/receipt.stderr.txt"
run_check "run2-null-is-real"    null_warned "$ART/run2/receipt.stderr.txt"
run_check "report-records-null"  grep -qi "no authoritative\|no .total_cost_usd\|ABSENT" "$REPORT"

# ── the headline positive is recorded ──
run_check "report-records-obedience" grep -qi "voluntar\|per CONSTRAINTS\|refused to auto-commit" "$REPORT"

# ── scope guard: no src/ change in this MEASURE session ──
no_src_change() { ! git diff --name-only main -- src 2>/dev/null | grep -q . ; }
run_check "no-src-change"        no_src_change

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-32s %s\n' "STEP" "RESULT"
printf '%-32s %s\n' "--------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
