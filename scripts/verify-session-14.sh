#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="14"

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

run_check "cargo-check"  cargo check --all-targets
run_check "cargo-test"   cargo test --all-targets
run_check "cargo-fmt"    cargo fmt -- --check
run_check "cargo-clippy" cargo clippy --all-targets -- -D warnings

# Verify maturity module exists
run_check "maturity-module" test -f src/maturity/mod.rs

# Verify maturity field in own CONSTRAINTS.yaml
run_check "maturity-in-constraints" grep -q '^maturity:' .ai/CONSTRAINTS.yaml

# Verify maturity template placeholder
run_check "maturity-in-template" grep -q '{MATURITY}' src/cli/init.rs

# Verify hook scripts read maturity
run_check "hook-pre-bash-maturity" grep -q 'MATURITY' scripts/hook-pre-bash.sh
run_check "hook-pre-write-maturity" grep -q 'MATURITY' scripts/hook-pre-write.sh

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
