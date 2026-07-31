#!/usr/bin/env bash
# Verify — Session 106: v0.1 is installable, and an INSTRUMENT proves it (not a feeling).
# One install path (`cargo install` from a clean source) works end-to-end; `scripts/install-smoke.sh`
# asserts it fresh-dir → init → next and fails non-zero if broken; the README shows only paths that
# actually work. No pipeline-station logic changed — the suite guards that.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="106"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-30s %s' "$NAME" PASS)"); PASS=$((PASS + 1))
  else
    RESULTS+=("$(printf '%-30s %s' "$NAME" FAIL)"); FAIL=$((FAIL + 1))
  fi
}

# --- toolchain: nothing this session touches src/, and the suite proves no pipeline logic moved ---
run_check "cargo-test-lib"  cargo test --lib
run_check "cargo-fmt"       cargo fmt -- --check
run_check "cargo-clippy"    cargo clippy --all-targets -- -D warnings

# --- AC1+AC2: the install instrument runs green from a clean source (fresh install → init → next) ---
run_check "install-smoke"   bash scripts/install-smoke.sh

# --- AC3: the README shows only working paths; unshipped ones stay honestly marked ---
check_readme_truth() {
  grep -q "cargo install --git https://github.com/ifelse-codes/vajra" README.md \
    || { echo "README missing the working --git one-liner"; return 1; }
  grep -q "scripts/install-smoke.sh" README.md \
    || { echo "README does not point at the smoke instrument"; return 1; }
  grep -q "NOT YET PUBLISHED" README.md \
    || { echo "README no longer marks the unshipped paths honestly"; return 1; }
  grep -q "cargo install vajractl" README.md \
    || { echo "the crates.io (unshipped) row vanished — do not silently drop honesty rows"; return 1; }
}
run_check "readme-truth-pass" check_readme_truth

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
