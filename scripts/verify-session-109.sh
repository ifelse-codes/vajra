#!/usr/bin/env bash
# Verify — Session 109: fleet slice 1 — one named agent (Researcher) as a governed step.
# Exit 0 = done. Includes a FALSIFIABLE fail-closed probe (fleet-smoke.sh), the max-7-commands
# guard, and the Architect design gate (DECISION-007 must exist and pass --check-design).

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="109"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-32s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-32s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- toolchain: the code compiles, tests pass, is formatted + lint-clean -----------------------------
run_check "cargo-build"   cargo build --all-targets
run_check "cargo-test"    cargo test --lib
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings

# --- fleet dispatch: the falsifiable stub smoke (includes 5 fail-closed cases) -----------------------
run_check "fleet-smoke"   bash scripts/fleet-smoke.sh

# --- design gate: DECISION-007 exists and the Architect gate passes for this session -----------------
run_check "decision-007-exists" test -f docs/decisions/DECISION-007-agent-fleet.md
run_check "architect-check-design" ./target/debug/vajra next --check-design 109

# --- max-7-commands guard: --help must still list exactly the 7 commands (no 8th) --------------------
help_lists_seven() {
  local help; help="$(./target/debug/vajra --help 2>&1)"
  echo "$help"
  echo "$help" | grep -q "vajra <init|claude|check|next|estimate|hook|meter>"
}
run_check "no-eighth-command" help_lists_seven

# --- fail-closed probe: fleet-smoke MUST go RED if a fail-closed case is defeated --------------------
# Prove the smoke is not a rubber stamp: feed it a "stub" that returns 0 for EVERYTHING (so the
# missing-agent / unknown-role assertions would be satisfied spuriously) — the smoke must still FAIL
# because a real dispatch through it produces no parseable handoff. (Belt: the smoke's own 5 negative
# cases already assert non-zero; this is the meta-check that the harness itself fails loudly.)
probe_smoke_is_falsifiable() {
  # A binary that always exits 0 and prints nothing can never produce a valid handoff, so a smoke
  # run pointed at it as the vajra binary MUST fail (not silently pass).
  local fakebin; fakebin="$(mktemp)"; printf '#!/bin/sh\nexit 0\n' > "$fakebin"; chmod +x "$fakebin"
  if VAJRA_BIN="$fakebin" bash scripts/fleet-smoke.sh >/dev/null 2>&1; then
    rm -f "$fakebin"; return 1   # smoke passed with a no-op binary -> NOT falsifiable -> this check FAILS
  fi
  rm -f "$fakebin"; return 0
}
run_check "smoke-is-falsifiable" probe_smoke_is_falsifiable

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-32s %s\n' "STEP" "RESULT"
printf '%-32s %s\n' "--------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
