#!/usr/bin/env bash
# Verify — Session 108: publish to crates.io + Homebrew tap — finish every install channel.
# The `vajractl` crate is published to crates.io and a Homebrew tap installs the `v0.1.0` release
# binary; `install-smoke.sh` gains a `crates` mode (`cargo install vajractl`) and a `brew` mode
# (`brew install <tap>/vajra`, sha256-verified), each failing non-zero on a missing crate / bad
# formula / sha mismatch / non-zero `vajra`; the README un-marks the last two rows.
# No src/ or pipeline-station logic changed — the suite guards that. These checks are OFFLINE-safe:
# the fail-closed probes assert a non-zero exit whether the failure is a 404 or no network, and the
# LIVE positive install proofs (crates/brew) are captured in the summary/demo, since a close-gate
# must not depend on the network.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="108"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-32s %s' "$NAME" PASS)"); PASS=$((PASS + 1))
  else
    RESULTS+=("$(printf '%-32s %s' "$NAME" FAIL)"); FAIL=$((FAIL + 1))
  fi
}

# --- discipline: nothing this session touches src/; the suite proves no pipeline logic moved ---
run_check "cargo-test-lib"  cargo test --lib
run_check "cargo-fmt"       cargo fmt -- --check
run_check "cargo-clippy"    cargo clippy --all-targets -- -D warnings

# --- the path-mode instrument still runs green from a clean source (no regression) ---
run_check "install-smoke-path"  bash scripts/install-smoke.sh

# --- AC1/AC2: install-smoke.sh grew real `crates` and `brew` modes ---
check_new_modes() {
  local s=scripts/install-smoke.sh
  grep -q 'SOURCE" = "crates"'  "$s" || { echo "no crates branch in install-smoke.sh"; return 1; }
  grep -q 'install-from-crates'  "$s" || { echo "no cargo-install-from-crates step"; return 1; }
  grep -q 'SOURCE" = "brew"'     "$s" || { echo "no brew branch in install-smoke.sh"; return 1; }
  grep -q 'brew-install-tap'     "$s" || { echo "no brew-install-tap step"; return 1; }
}
run_check "smoke-has-new-modes" check_new_modes

# --- AC3 (fail-closed): crates mode on a nonexistent crate MUST exit non-zero ---
crates_fails_closed() {
  if VAJRA_SMOKE_SOURCE=crates VAJRA_SMOKE_CRATE=vajra-nope-zzz-does-not-exist \
     VAJRA_SMOKE_BUDGET_SECS=120 bash scripts/install-smoke.sh >/dev/null 2>&1; then
    echo "crates smoke returned 0 for a nonexistent crate — NOT fail-closed"; return 1
  fi
  return 0
}
run_check "crates-mode-fail-closed" crates_fails_closed

# --- AC3 (fail-closed): brew mode with a missing formula MUST exit non-zero ---
brew_fails_closed() {
  if VAJRA_SMOKE_SOURCE=brew VAJRA_SMOKE_FORMULA=/nonexistent/vajra.rb \
     VAJRA_SMOKE_BUDGET_SECS=60 bash scripts/install-smoke.sh >/dev/null 2>&1; then
    echo "brew smoke returned 0 for a missing formula — NOT fail-closed"; return 1
  fi
  return 0
}
run_check "brew-mode-fail-closed" brew_fails_closed

# --- AC2: the formula carries REAL sha256s (no PLACEHOLDER) pinned to the v0.1.0 release ---
check_formula_real() {
  local f=Formula/vajra.rb
  grep -q 'PLACEHOLDER' "$f" && { echo "formula still has a PLACEHOLDER sha256"; return 1; }
  grep -q 'releases/download/v#{version}/vajra-' "$f" || { echo "formula does not point at the release tarballs"; return 1; }
  local n; n=$(grep -Ec 'sha256 "[0-9a-f]{64}"' "$f")
  [ "$n" -ge 2 ] || { echo "formula has <2 real 64-hex sha256 lines (found $n)"; return 1; }
  return 0
}
run_check "formula-real-shas" check_formula_real

# --- AC1: the published crate keeps its publish metadata + excludes stray root HTML from the package ---
check_package_clean() {
  cargo package --allow-dirty --list 2>/dev/null | grep -qiE 'first-mate|cto-audit' \
    && { echo "stray root HTML would ship in the crate — exclude it"; return 1; }
  grep -q '^description = ' Cargo.toml && grep -q '^license = ' Cargo.toml \
    && grep -q '^repository = ' Cargo.toml || { echo "Cargo.toml missing publish metadata"; return 1; }
  return 0
}
run_check "package-clean" check_package_clean

# --- AC4: README un-marks BOTH rows (real commands) and leaves nothing faked ---
check_readme_truth() {
  grep -q "cargo install vajractl"           README.md || { echo "README lost the crates.io command"; return 1; }
  grep -q "brew install ifelse-codes/tap/vajra" README.md || { echo "README lost the real brew command"; return 1; }
  grep -q "NOT YET PUBLISHED" README.md \
    && { echo "a row is STILL marked NOT YET PUBLISHED — un-mark it (both shipped)"; return 1; }
  grep -q "cargo install --git" README.md || { echo "README dropped the from-source row"; return 1; }
  return 0
}
run_check "readme-truth-pass" check_readme_truth

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-32s %s\n' "STEP" "RESULT"
printf '%-32s %s\n' "--------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
