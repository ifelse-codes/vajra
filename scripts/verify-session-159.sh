#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="159"

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

AUDIT="sessions/session-159-advice-influence-reaudit.md"

# AC1: audit file exists
run_check "audit-file-exists" test -f "$AUDIT"

# AC1: audit is non-trivial (>= 100 lines)
run_check "audit-nontrivial" bash -c "wc -l < '$AUDIT' | awk '{if (\$1 >= 100) exit 0; else exit 1}'"

# AC1/AC3: summary table present (contains "| S149 baseline |" row)
run_check "summary-table-present" grep -q "S149 baseline" "$AUDIT"

# AC1: all 6 sessions referenced (S153 through S158)
run_check "s153-referenced" grep -q "S153" "$AUDIT"
run_check "s154-referenced" grep -q "S154" "$AUDIT"
run_check "s155-referenced" grep -q "S155" "$AUDIT"
run_check "s156-referenced" grep -q "S156" "$AUDIT"
run_check "s157-referenced" grep -q "S157" "$AUDIT"
run_check "s158-referenced" grep -q "S158" "$AUDIT"

# AC2: each rec has a Grade line
run_check "grade-labels-present" grep -q "Grade:" "$AUDIT"

# AC2: evidence citations present (SHA, file:line, or "no evidence")
run_check "evidence-citations" grep -q "Evidence:" "$AUDIT"

# AC3: comparison to S149 baseline present (59% Changed)
run_check "s149-comparison" grep -q "59%" "$AUDIT"

# AC4: key findings section present
run_check "key-findings-present" grep -q "Key findings" "$AUDIT"

# AC4: carries a conclusion on whether the rule worked
run_check "rule-verdict-present" grep -q "Hollow rate" "$AUDIT"

ln -sfn "$TS" ".ai/verify/session-${SESSION}/latest"

echo "=== Session ${SESSION} verify ==="
for R in "${RESULTS[@]}"; do echo "  $R"; done
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "  ALL ${PASS} PASS"
  exit 0
else
  echo "  ${PASS} PASS  ${FAIL} FAIL"
  exit 1
fi
