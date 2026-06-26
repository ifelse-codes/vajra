#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="11"

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

run_check "cargo-check"       cargo check --all-targets
run_check "cargo-test"        cargo test --all-targets
run_check "cargo-clippy"      cargo clippy --all-targets -- -D warnings

# Budget module exists
run_check "budget-mod-exists" test -f src/budget/mod.rs

# Budget tests pass
run_check "budget-tests"      cargo test budget --lib

# CONSTRAINTS.yaml has budget section
run_check "constraints-budget" grep -q "cap_usd:" .ai/CONSTRAINTS.yaml

# STATE.md test count fixed (not 32)
run_check "state-test-count"  bash -c '! grep -q "(32 tests)" .ai/STATE.md'

# ROADMAP.md no done items in "Does NOT Work"
run_check "roadmap-clean"     bash -c '! grep -A20 "Does NOT Work" .ai/ROADMAP.md | grep -q "\[x\]"'

# session-06-summary.md restored
run_check "session-06-exists" test -f sessions/session-06-summary.md

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
