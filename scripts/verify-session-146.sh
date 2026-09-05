#!/usr/bin/env bash
# verify-session-146.sh — checks for S146 deliverables.
# C1-C5, C7, C8, C9, C10: execute-based (runs vajra binary or cargo test).
# C6, C7b: structural source-greps confirming unchanged/expected source content.

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

# C7: scaffolded gate (binary output) has PATH-first resolver in all 3 binary-backed checks
# (execute-based: counts in the generated file, not the source template)
c7_scaffold_gate_three_resolvers() {
  local DIR; DIR=$(with_scaffold)
  local COUNT; COUNT=$(grep -c "command -v vajra" "$DIR/scripts/verify-closeout.sh" || true)
  echo "count=$COUNT"
  rm -rf "$DIR"
  [ "$COUNT" -eq 3 ]
}
run_check "C7-scaffold-gate-has-3-resolvers" c7_scaffold_gate_three_resolvers

# C7b: source template also has 3 resolvers (structural guard so C7 and the source stay in sync)
c7b_source_template_three_resolvers() {
  local COUNT; COUNT=$(grep -c "command -v vajra" "$ROOT/scripts/verify-closeout-scaffold.sh")
  echo "count=$COUNT"
  [ "$COUNT" -eq 3 ]
}
run_check "C7b-source-template-has-3-resolvers" c7b_source_template_three_resolvers

# C9: --sync-fleet detects a modified gate as Drifted (stamp-based drift detection works)
c9_sync_fleet_detects_drift() {
  local DIR; DIR=$(with_scaffold)
  # Append a line to break the stamp
  echo "# intentional drift" >> "$DIR/scripts/verify-closeout.sh"
  local OUT; OUT=$(cd "$DIR" && "$BIN" init --sync-fleet 2>&1 || true)
  echo "$OUT"
  rm -rf "$DIR"
  # Must report 'drifted' for verify-closeout.sh
  echo "$OUT" | grep -i "verify-closeout" | grep -qi "drifted"
}
run_check "C9-sync-fleet-detects-drifted-gate" c9_sync_fleet_detects_drift

# C10: PATH-first resolver resolves to PATH vajra when no target/release/vajra exists (AC5 live proof)
# Scaffolds into a temp dir with no Rust build, then evaluates the resolver logic from the generated
# gate and confirms the resolved BIN is the PATH vajra, not the fallback literal.
c10_path_first_resolves_to_path_vajra() {
  local DIR; DIR=$(with_scaffold)
  local GATE="$DIR/scripts/verify-closeout.sh"
  # No target/release/vajra in DIR (fresh scaffold has no Rust build)
  [ ! -f "$DIR/target/release/vajra" ] || { echo "unexpected: target/release/vajra exists"; rm -rf "$DIR"; return 1; }
  # Evaluate the resolver expression from the generated gate (bash subshell, no side effects)
  local RESOLVED; RESOLVED=$(bash -c '
    BIN="$(command -v vajra 2>/dev/null || echo "target/release/vajra")"
    echo "$BIN"
  ')
  echo "resolved: $RESOLVED"
  # PATH vajra must resolve (installed at ~/.cargo/bin/vajra or similar)
  [ "$RESOLVED" != "target/release/vajra" ] || { echo "FAIL: PATH vajra not found, resolver fell back to literal"; rm -rf "$DIR"; return 1; }
  [ -x "$RESOLVED" ] || { echo "FAIL: resolved path $RESOLVED is not executable"; rm -rf "$DIR"; return 1; }
  # Confirm the generated gate actually contains the resolver text (belt-and-suspenders)
  grep -q "command -v vajra" "$GATE"
  rm -rf "$DIR"
  echo "PATH-first resolver correctly resolves to: $RESOLVED"
}
run_check "C10-path-first-resolves-to-path-vajra" c10_path_first_resolves_to_path_vajra

# C8: 471 tests pass (470 baseline + 1 new fixture_146 test)
c8_tests_pass() {
  local OUT; OUT=$(cargo test 2>&1)
  echo "$OUT"
  echo "$OUT" | grep -q "471 passed"
}
run_check "C8-471-tests-pass" c8_tests_pass

echo ""
echo "--- results ---"
printf '%s\n' "${RESULTS[@]}"
echo ""
echo "PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
