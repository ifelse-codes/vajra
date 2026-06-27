#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="16"

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

# Part 1: launch alias removed from main.rs
run_check "no-launch-match"   bash -c '! grep -q "\"launch\"" src/main.rs'
run_check "no-launch-help"    bash -c '! grep -q "launch.*Legacy" src/main.rs'

# Part 2a: ROADMAP — no [x] items in "Does NOT Work Yet"
run_check "roadmap-clean"     bash -c '! sed -n "/Does NOT Work/,/^##/p" .ai/ROADMAP.md | grep -q "\[x\]"'

# Part 2b: KNOWLEDGE.md breadcrumb matches code
run_check "breadcrumb-sync"   bash -c 'grep -q "vajra:.*folded" .ai/KNOWLEDGE.md'

# Part 2c: S11 verify passes (roadmap-clean was failing before)
run_check "s11-verify"        bash scripts/verify-session-11.sh

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
