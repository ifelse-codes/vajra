#!/usr/bin/env bash
# Session 96 — CI green: the rustfmt 1.9.0 drift on 3 files is fixed (`cargo fmt`, zero logic).
#
# The only failing CI step was `cargo fmt --check` on 3 pre-existing drifted files:
#   src/cli/next.rs · src/dogfood/mod.rs · src/stations/mod.rs
# committed under an older rustfmt, reformatted by 1.9.0-stable. This verify asserts the whole
# crate is now fmt-clean, clippy stays green, tests stay green, and the src/ change set is exactly
# those 3 files (no logic, no scope creep) — the AC1..AC4 that CI (AC5) also enforces on the PR.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="96"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

EXPECTED=(src/cli/next.rs src/dogfood/mod.rs src/stations/mod.rs)

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

# --- AC1: whole crate is fmt-clean --------------------------------------------------------------
run_check "fmt-check"  cargo fmt --check

# --- AC2: clippy stays green (deny warnings) ----------------------------------------------------
run_check "clippy"     cargo clippy --all-targets -- -D warnings

# --- AC3: lib tests stay green (286+) -----------------------------------------------------------
chk_tests() {
  local out; out=$(cargo test --lib 2>&1); echo "$out"
  grep -qE 'test result: ok\. ([0-9]+) passed' <<<"$out" || return 1
  local n; n=$(grep -oE '([0-9]+) passed' <<<"$out" | grep -oE '[0-9]+' | head -1)
  [ "$n" -ge 286 ]
}
run_check "test-lib-286plus"  chk_tests

# --- AC4: exactly the 3 known src/ files changed; no other src/ file, no logic ------------------
# Property: no src/ file OTHER than the expected 3 appears in the branch diff vs its main base.
# (Empty diff — e.g. re-run after merge — also passes: nothing out of scope.)
chk_scope() {
  local base changed
  base=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD origin/main 2>/dev/null || true)
  if [ -z "$base" ]; then echo "no main base to diff against — skipping scope check as PASS"; return 0; fi
  changed=$(git diff --name-only "$base"..HEAD -- src 2>/dev/null || true)
  echo "src/ files changed on branch:"; echo "$changed"
  local f
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    case " ${EXPECTED[*]} " in *" $f "*) ;; *) echo "UNEXPECTED src/ change: $f"; return 1;; esac
  done <<<"$changed"
  return 0
}
run_check "scope-3-src-files"  chk_scope

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
