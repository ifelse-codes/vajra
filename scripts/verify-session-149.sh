#!/usr/bin/env bash
# verify-session-149.sh — S149 advice-influence audit (DOCUMENT session).
#
# SUITE DECLARATION: 4 checks total.
#   Execute-based (EXEC): C1, C2, C3, C4.
#   Structural (STRUCT): none — all checks run live against the produced file.
#
# FIDELITY GAPS (things this suite CANNOT verify):
#   Grade correctness (Changed/Noted/Hollow) — those judgments are verified by
#   the fidelity-reviewer cold pass, not a script.
#   Completeness of advice items audited — likewise a cold-pass concern.
#
# FAKEST GREEN (disclosed): C2 asserts the summary table header row exists;
# it cannot verify that the row counts are accurate or that all advice items
# were included.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="149"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; SKIP=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  if "$@" > "$ARTIFACTS/${NAME}.log" 2>&1; then
    echo "  PASS  $NAME"; PASS=$((PASS+1)); RESULTS+=("PASS $NAME")
  else
    echo "  FAIL  $NAME (see $ARTIFACTS/${NAME}.log)"; FAIL=$((FAIL+1)); RESULTS+=("FAIL $NAME")
  fi
}

echo "=== verify-session-149 ==="

AUDIT="sessions/session-149-advice-influence-audit.md"

# C1: audit file exists (AC5 — deliverable present)
c1_audit_exists() {
  [ -f "$AUDIT" ] || { echo "File not found: $AUDIT"; return 1; }
  echo "Found: $AUDIT"
}
run_check "C1-audit-exists" c1_audit_exists

# C2: summary table header present (AC5 — table must be there, not just the file)
c2_summary_table_header() {
  grep -q "^## Summary table" "$AUDIT" \
    || { echo "Missing '## Summary table' header in $AUDIT"; return 1; }
  echo "Summary table header found"
}
run_check "C2-summary-table-header" c2_summary_table_header

# C3: all three sessions S146/S147/S148 appear as H2 sections (AC1 — 3 sessions selected)
c3_three_sessions_present() {
  grep -q "^## S146" "$AUDIT" || { echo "Missing S146 section"; return 1; }
  grep -q "^## S147" "$AUDIT" || { echo "Missing S147 section"; return 1; }
  grep -q "^## S148" "$AUDIT" || { echo "Missing S148 section"; return 1; }
  echo "All three session sections present"
}
run_check "C3-three-sessions" c3_three_sessions_present

# C4: recommendation section present and takes a yes/no position (AC4)
c4_recommendation_present() {
  grep -q "^## Recommendation" "$AUDIT" \
    || { echo "Missing '## Recommendation' section in $AUDIT"; return 1; }
  # Must contain either "Yes" or "No" (case-insensitive) as a position
  grep -qi "not yet\|yes\b\|no,\b\|no —" "$AUDIT" \
    || { echo "Recommendation section lacks a clear yes/no position"; return 1; }
  echo "Recommendation section with position found"
}
run_check "C4-recommendation-position" c4_recommendation_present

# ── report ────────────────────────────────────────────────────────────────────
ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"
echo ""
echo "Results: ${PASS} PASS  ${FAIL} FAIL  ${SKIP} SKIP  (of $((PASS+FAIL+SKIP)) checks)"
for r in "${RESULTS[@]}"; do echo "  $r"; done
echo ""
if [ "$FAIL" -gt 0 ]; then
  echo "FAIL — $FAIL check(s) failed"; exit 1
fi
echo "PASS — all checks passed (${SKIP} skipped/CANNOT-EVALUATE)"
