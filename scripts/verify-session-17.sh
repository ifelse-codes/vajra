#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="17"

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

# estimate command exists and runs
run_check "estimate-runs"     cargo run -- estimate

# estimate output contains expected fields
run_check "estimate-tokens"   bash -c 'cargo run -- estimate 2>&1 | grep -q "input.*output.*tokens"'
run_check "estimate-budget"   bash -c 'cargo run -- estimate 2>&1 | grep -q "budget"'

# help text includes estimate
run_check "help-estimate"     bash -c 'cargo run -- help 2>&1 | grep -q "estimate"'

# ADR-0005 exists
run_check "adr-0005-exists"   test -f docs/adr/0005-pre-run-cost-estimate.md

# KNOWLEDGE.md references ADR-0005
run_check "knowledge-adr5"    grep -q "ADR-0005" .ai/KNOWLEDGE.md

# AGENTS.md references ADR-0005
run_check "agents-adr5"       grep -q "ADR-0005" .ai/AGENTS.md

# prior session verify still passes
run_check "s16-verify"        bash scripts/verify-session-16.sh

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
