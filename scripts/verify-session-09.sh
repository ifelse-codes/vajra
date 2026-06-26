#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="09"

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

# vajra check runs against this repo
run_check "check-runs" "$ROOT/target/debug/vajra" check

# vajra next (bare) still dumps the packet
run_check "next-dump" bash -c '
  OUT=$("'"$ROOT"'/target/debug/vajra" next 2>&1)
  echo "$OUT" | grep -q "=== vajra next ==="
'

# vajra next --advance in a temp dir
run_check "next-advance" bash -c '
  TMPDIR=$(mktemp -d)
  cd "$TMPDIR"
  git init -q
  mkdir -p .ai
  echo "03" > .ai/SESSION
  printf "# Boot\n- **Number:** 03\n" > .ai/SESSION-BOOT.md
  git checkout -q -b session-03-test
  echo "y" | "'"$ROOT"'/target/debug/vajra" next --advance 2>/dev/null
  SESSION=$(cat .ai/SESSION)
  test "$SESSION" = "04"
  STATUS=$?
  rm -rf "$TMPDIR"
  exit $STATUS
'

# vajra next --advance refuses on main
run_check "next-advance-main-guard" bash -c '
  TMPDIR=$(mktemp -d)
  cd "$TMPDIR"
  git init -q
  mkdir -p .ai
  echo "03" > .ai/SESSION
  echo "y" | "'"$ROOT"'/target/debug/vajra" next --advance 2>&1 | grep -q "refusing"
  STATUS=$?
  rm -rf "$TMPDIR"
  exit $STATUS
'

# Demo script runs
run_check "demo-script" bash scripts/demo-session-09.sh

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
