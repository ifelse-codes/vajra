#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="08"

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

# Verify vajra init works in a temp dir
run_check "init-fresh" bash -c '
  TMPDIR=$(mktemp -d)
  cd "$TMPDIR"
  git init -q
  printf "TestProj\nTest goal\n" | '"$ROOT"'/target/debug/vajra init 2>/dev/null
  test -f .ai/AGENTS.md && test -f .ai/SESSION && test -f .claude/settings.json
  STATUS=$?
  rm -rf "$TMPDIR"
  exit $STATUS
'

# Verify idempotency
run_check "init-idempotent" bash -c '
  TMPDIR=$(mktemp -d)
  cd "$TMPDIR"
  git init -q
  printf "P\nG\n" | '"$ROOT"'/target/debug/vajra init 2>/dev/null
  echo "SENTINEL" > .ai/AGENTS.md
  printf "P2\nG2\n" | '"$ROOT"'/target/debug/vajra init 2>/dev/null
  grep -q "SENTINEL" .ai/AGENTS.md
  STATUS=$?
  rm -rf "$TMPDIR"
  exit $STATUS
'

# Verify demo script runs
run_check "demo-script" bash scripts/demo-session-08.sh

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
