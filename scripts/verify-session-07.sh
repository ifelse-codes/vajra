#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="07"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-30s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-30s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

run_check "cargo-test"   cargo test --all-targets
run_check "cargo-clippy" cargo clippy --all-targets -- -D warnings
run_check "summary-exists" test -f sessions/session-07-summary.md
run_check "summary-has-conclusion" grep -q "CONFIRMED" sessions/session-07-summary.md
run_check "summary-has-3-options" bash -c 'count=$(grep -c "^### [A-C] —" sessions/session-07-summary.md); [ "$count" -eq 3 ]'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
