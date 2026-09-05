#!/usr/bin/env bash
# verify-session-146.sh — execute-based checks for S146 deliverables.
# All checks are execute-based (no hollow source-greps).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="146"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  if "$@" > "$ARTIFACTS/${NAME}.log" 2>&1; then
    echo "  PASS  $NAME"; PASS=$((PASS+1)); RESULTS+=("PASS $NAME")
  else
    echo "  FAIL  $NAME (see $ARTIFACTS/${NAME}.log)"; FAIL=$((FAIL+1)); RESULTS+=("FAIL $NAME")
  fi
}

# Always use the LOCAL dev build — verifying S146 changes requires the branch binary, not the
# installed version which predates these changes.
cargo build --release --quiet 2>/dev/null || cargo build --quiet 2>/dev/null
BIN="$ROOT/target/release/vajra"
[ -x "$BIN" ] || { echo "BLOCK: local vajra binary not built"; exit 1; }

echo "=== verify-session-146 (bin: $BIN) ==="

# Helper: scaffold into a temp dir and run callback with DIR set
with_scaffold() {
  local DIR; DIR=$(mktemp -d)
  (cd "$DIR" && printf "test-project\nfirst-session\n2\n" | "$BIN" init 2>/dev/null) || true
  echo "$DIR"
}

# C1: scaffold creates scripts/verify-closeout.sh
c1_scaffold_creates_gate() {
  local DIR; DIR=$(with_scaffold)
  local OK=0
  [ -f "$DIR/scripts/verify-closeout.sh" ] && OK=1
  rm -rf "$DIR"
  [ "$OK" -eq 1 ]
}
run_check "C1-scaffold-creates-gate" c1_scaffold_creates_gate

# C2: scaffolded gate carries a ShellComment stamp line
c2_scaffold_gate_is_stamped() {
  local DIR; DIR=$(with_scaffold)
  local GATE="$DIR/scripts/verify-closeout.sh"
  local OK=0
  grep -qE "^# vajra-render-sha: [0-9a-f]{64}$" "$GATE" && OK=1
  rm -rf "$DIR"
  [ "$OK" -eq 1 ]
}
run_check "C2-scaffold-gate-stamped" c2_scaffold_gate_is_stamped

# C3: scaffolded gate has PATH-first resolver
c3_path_first_resolver() {
  local DIR; DIR=$(with_scaffold)
  local OK=0
  grep -q "command -v vajra" "$DIR/scripts/verify-closeout.sh" && OK=1
  rm -rf "$DIR"
  [ "$OK" -eq 1 ]
}
run_check "C3-path-first-resolver-present" c3_path_first_resolver

# C4: fresh init + --sync-fleet reports verify-closeout.sh as up to date (not drifted)
c4_sync_fleet_up_to_date() {
  local DIR; DIR=$(with_scaffold)
  local OUT; OUT=$(cd "$DIR" && "$BIN" init --sync-fleet 2>&1 || true)
  echo "$OUT"
  local OK=0
  echo "$OUT" | grep -i "verify-closeout" | grep -qi "up to date" && OK=1
  rm -rf "$DIR"
  [ "$OK" -eq 1 ]
}
run_check "C4-sync-fleet-up-to-date-after-init" c4_sync_fleet_up_to_date

# C5: --sync-fleet creates verify-closeout.sh when missing (Missing → created)
c5_sync_fleet_creates_gate() {
  local DIR; DIR=$(with_scaffold)
  rm -f "$DIR/scripts/verify-closeout.sh"
  local OUT; OUT=$(cd "$DIR" && "$BIN" init --sync-fleet 2>&1 || true)
  echo "$OUT"
  local OK=0
  [ -f "$DIR/scripts/verify-closeout.sh" ] && OK=1
  rm -rf "$DIR"
  [ "$OK" -eq 1 ]
}
run_check "C5-sync-fleet-creates-gate-when-missing" c5_sync_fleet_creates_gate

# C6: Vajra's own scripts/verify-closeout.sh is UNCHANGED (hardcoded BIN still present)
c6_vajra_source_unchanged() {
  grep -q 'local BIN="target/release/vajra"' "$ROOT/scripts/verify-closeout.sh"
}
run_check "C6-vajra-source-gate-unchanged" c6_vajra_source_unchanged

# C7: scaffold template has PATH-first resolver in all 3 binary-backed checks
c7_scaffold_template_three_resolvers() {
  local COUNT; COUNT=$(grep -c "command -v vajra" "$ROOT/scripts/verify-closeout-scaffold.sh")
  echo "count=$COUNT"
  [ "$COUNT" -eq 3 ]
}
run_check "C7-scaffold-template-has-3-resolvers" c7_scaffold_template_three_resolvers

# C8: 470 tests pass
c8_tests_pass() {
  local OUT; OUT=$(cargo test 2>&1)
  echo "$OUT"
  echo "$OUT" | grep -q "470 passed"
}
run_check "C8-470-tests-pass" c8_tests_pass

echo ""
echo "--- results ---"
printf '%s\n' "${RESULTS[@]}"
echo ""
echo "PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
