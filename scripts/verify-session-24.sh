#!/usr/bin/env bash
# Session 24 — render `.ai/` → generated `vajra.varta`. A persisted `.varta` returns ONLY
# because it can be generated (the S19 condition): one-way render, drift-guarded by
# `vajra check` (the S22 cmp pattern). Proven against a REAL render + a forced-drift case.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="24"
BIN="$ROOT/target/debug/vajra"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"        cargo fmt -- --check
run_check "cargo-clippy"     cargo clippy --all-targets -- -D warnings
run_check "cargo-test-varta" cargo test --lib varta
run_check "cargo-build"      cargo build

# --- Render the live .ai/ into vajra.varta ---
run_check "render-writes"    "$BIN" check --render

# --- The artifact exists and carries the 9 locked ⚡ constructs ---
ART="$ROOT/vajra.varta"
has_construct() { grep -qF "$1" "$ART"; }
run_check "artifact-exists"  test -f "$ART"
run_check "c-project"        has_construct "⚡project"
run_check "c-forbid"         has_construct "⚡forbid"
run_check "c-require"        has_construct "⚡require"
run_check "c-max"            has_construct "⚡max"
run_check "c-pipeline"       has_construct "⚡pipeline"
run_check "c-final"          has_construct "⚡final"
run_check "c-on"             has_construct "⚡on"
run_check "c-assert"         has_construct "⚡assert"
run_check "c-enum-next"      has_construct "⚡enum next"

# --- It is a render of the LIVE .ai/, not a stale copy: config flows through ---
run_check "carries-adr-0005" has_construct "ADR_0005"
run_check "carries-copilot"  has_construct "cmd:git commit"
run_check "warns-generated"  grep -qF "GENERATED from .ai/" "$ART"

# --- Drift guard: a fresh `vajra check` must see the on-disk file as up to date ---
clean_check_passes() { VAJRA_CHECK_RUNNING=1 "$BIN" check | grep -qF "varta: matches render"; }
run_check "drift-guard-clean" clean_check_passes

# --- Forced drift must be CAUGHT (hand-edit -> stale -> FAIL), then restored ---
drift_is_caught() {
  cp "$ART" "$ARTIFACTS/varta.bak"
  printf '\n// hand edit\n' >> "$ART"
  local rc=0
  VAJRA_CHECK_RUNNING=1 "$BIN" check > "$ARTIFACTS/drift-check.log" 2>&1 || rc=$?
  cp "$ARTIFACTS/varta.bak" "$ART"   # restore the real render
  grep -qF "stale" "$ARTIFACTS/drift-check.log" && [ "$rc" -ne 0 ]
}
run_check "drift-guard-catches" drift_is_caught

# --- Re-render must be byte-identical (deterministic) ---
deterministic() {
  "$BIN" check --render >/dev/null
  cp "$ART" "$ARTIFACTS/render-a.varta"
  "$BIN" check --render >/dev/null
  cmp -s "$ARTIFACTS/render-a.varta" "$ART"
}
run_check "render-deterministic" deterministic

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
