#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="13"

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

# Core build checks
run_check "cargo-check"  cargo check --all-targets
run_check "cargo-test"   cargo test --all-targets
run_check "cargo-fmt"    cargo fmt -- --check
run_check "cargo-clippy" cargo clippy --all-targets -- -D warnings

# Crate metadata
run_check "crate-description" grep -q '^description' Cargo.toml
run_check "crate-license"     grep -q '^license' Cargo.toml
run_check "crate-repository"  grep -q '^repository' Cargo.toml
run_check "crate-keywords"    grep -q '^keywords' Cargo.toml

# CI workflows exist
run_check "ci-workflow"      test -f .github/workflows/ci.yml
run_check "release-workflow" test -f .github/workflows/release.yml

# Homebrew formula exists
run_check "homebrew-formula" test -f Formula/vajra.rb

# README install section
run_check "readme-install" grep -q 'cargo install vajractl' README.md

# cargo package dry-run
run_check "cargo-package" cargo package --allow-dirty 2>&1

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
