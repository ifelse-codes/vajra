#!/usr/bin/env bash
# Session 33 — Compression schema fix (S31 finding #2): make the hook fire on real CC.
# Root cause: HookInput had #[serde(rename_all="camelCase")] but real CC sends snake_case
# top-level keys (tool_name/tool_input/tool_response) -> parse fails -> silent "{}"
# passthrough on every real session since S03/S07. Fix: drop that attribute from HookInput
# ONLY (HookToolResponse keeps camelCase — its nested keys really are camelCase).
# Proven end-to-end: a real-shaped payload (snake_case top level) now folds; the same
# fixture using the OLD camelCase top-level shape still (correctly) fails-open.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="33"
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
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test

# --- Core: HookInput no longer forces camelCase; HookToolResponse still does ---
run_check "hookinput-no-camelcase" bash -c \
  '! grep -B1 "pub struct HookInput" src/adapter/claude_code.rs | grep -q "rename_all"'
run_check "hooktoolresponse-keeps-camelcase" bash -c \
  'grep -B1 "pub struct HookToolResponse" src/adapter/claude_code.rs | grep -q "rename_all = \"camelCase\""'
run_check "exit-code-stays-option" bash -c \
  'grep -q "pub exit_code: Option<i32>" src/adapter/claude_code.rs'

# --- Regression tests exist and encode the real (snake_case top-level) shape ---
run_check "regression-test-present" bash -c \
  'grep -q "fn real_cc_payload_folds_not_passthrough" tests/hook_adapter.rs'
run_check "old-shape-documented" bash -c \
  'grep -q "fn camel_case_top_level_is_not_the_real_shape_and_still_passthroughs" tests/hook_adapter.rs'

# --- ≤3 files touched this session (constitution cap) ---
run_check "three-file-cap" bash -c \
  '[ "$(git diff --name-only main... 2>/dev/null | wc -l | tr -d " ")" -le 3 ] || \
   [ "$(git diff --name-only HEAD 2>/dev/null | wc -l | tr -d " ")" -le 3 ]'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
