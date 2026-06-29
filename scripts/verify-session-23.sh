#!/usr/bin/env bash
# Session 23 — first-run "aha": `vajra init` ends by firing the just-scaffolded co-pilot
# live, so the user *sees* Vajra guard their agent in seconds. Proven against a REAL
# `vajra init` into a temp dir (the felt moment must appear in init's own output).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="23"
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
run_check "cargo-fmt"       cargo fmt -- --check
run_check "cargo-clippy"    cargo clippy --all-targets -- -D warnings
run_check "cargo-test-init" cargo test --lib cli::init
run_check "cargo-build"     cargo build

# --- Run a REAL `vajra init` into a temp dir; the first-run aha must be in its output ---
SCAFFOLD=$(mktemp -d)
OUT="$ARTIFACTS/init-output.log"
init_runs() { ( cd "$SCAFFOLD" && "$BIN" init < /dev/null ) > "$OUT" 2>&1; }
run_check "init-exits-zero" init_runs   # the live fire (child exit 2) must NOT fail init

# --- The felt moment: init ends with the co-pilot firing LIVE (real hook, not static) ---
aha_header()  { grep -qF "See it work" "$OUT"; }
aha_live_block() {
  grep -qF "[vajra co-pilot]" "$OUT" || { echo "no co-pilot banner in init output"; return 1; }
  grep -qF "fired"            "$OUT" || { echo "co-pilot did not fire"; return 1; }
  grep -qF ".ai/STATE.md"     "$OUT" || { echo "STATE.md not surfaced"; return 1; }
}
aha_framing()   { grep -qF "guiding your agent" "$OUT"; }
aha_next_step() { grep -qF "vajra claude" "$OUT"; }
run_check "aha-header-present"  aha_header
run_check "aha-fires-live"      aha_live_block
run_check "aha-reframes"        aha_framing
run_check "aha-next-step"       aha_next_step

# --- The aha rides on a real, complete scaffold (didn't replace it) ---
run_check "scaffold-intact"     grep -qF "Created 17 files" "$OUT"

# --- The preview must not leak debounce state into the user's temp dir ---
no_state_leak() { ! ls -d "${TMPDIR:-/tmp}"/vajra-aha-* >/dev/null 2>&1; }
run_check "no-debounce-leak"    no_state_leak

rm -rf "$SCAFFOLD"

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
