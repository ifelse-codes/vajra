#!/usr/bin/env bash
# Verify — Session 107: the no-Rust install path — a prebuilt binary a stranger downloads and runs.
# A `v0.1.0` tag fires release.yml → 3 prebuilt tarballs + a GitHub release; `install-smoke.sh` gains a
# `release` mode that downloads the host tarball, verifies its sha256, extracts `vajra`, and runs the
# stranger flow (init → next), failing non-zero on any broken step; the README un-marks that one row.
# No src/ or pipeline-station logic changed — the suite guards that. (These checks are OFFLINE; the
# live download proof for AC2 is captured separately, since a close-gate must not depend on the network.)

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="107"
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

# --- AC2: install-smoke.sh grew a real `release` mode (download → sha256 verify → extract → run) ---
check_release_mode() {
  local s=scripts/install-smoke.sh
  grep -q 'SOURCE" = "release"' "$s"        || { echo "no release branch in install-smoke.sh"; return 1; }
  grep -q 'host_target'          "$s"        || { echo "no host-target detection"; return 1; }
  grep -q 'sha_verify'           "$s"        || { echo "no sha256 verification"; return 1; }
  grep -q 'download-tarball'     "$s"        || { echo "no tarball download step"; return 1; }
  grep -q 'extract-binary'       "$s"        || { echo "no extract step"; return 1; }
}
run_check "smoke-has-release-mode" check_release_mode

# --- AC2 (fail-closed): release mode with an unreachable tag MUST exit non-zero (never a skipped green) ---
release_mode_fails_closed() {
  # A tag that does not exist → the download 404s (or, offline, curl cannot connect) → SMOKE FAIL.
  if VAJRA_SMOKE_SOURCE=release VAJRA_SMOKE_RELEASE_TAG=v0.0.0-nonexistent \
     VAJRA_SMOKE_BUDGET_SECS=120 bash scripts/install-smoke.sh >/dev/null 2>&1; then
    echo "release smoke returned 0 for a nonexistent release — NOT fail-closed"; return 1
  fi
  return 0
}
run_check "release-mode-fail-closed" release_mode_fails_closed

# --- AC3: README un-marks the prebuilt row (real command) and keeps crates.io + brew marked ---
check_readme_truth() {
  grep -q "releases/latest/download/vajra-" README.md \
    || { echo "README lost the real prebuilt download command"; return 1; }
  grep -Eiq "prebuilt.*NOT YET PUBLISHED" README.md \
    && { echo "prebuilt row is STILL marked NOT YET PUBLISHED — un-mark it"; return 1; }
  grep -q "cargo install vajractl" README.md \
    || { echo "crates.io (unshipped) row vanished — do not silently drop honesty rows"; return 1; }
  grep -q "brew install suman/tap/vajra" README.md \
    || { echo "brew (unshipped) row vanished — do not silently drop honesty rows"; return 1; }
  grep -q "NOT YET PUBLISHED" README.md \
    || { echo "README no longer marks the unshipped paths honestly"; return 1; }
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
