#!/usr/bin/env bash
# Verify — Session 128: first contact works.
#
# CHECK CLASSES — the S121/S122/S123 contract: EXECUTE-BASED (runs the product, asserts on real
# output) · STRUCTURAL grep (asserts architecture — no runtime output exists to exercise) ·
# BEHAVIORAL grep (greps source and treats it as proof the feature works — HOLLOW, named in the
# disclosure) · NESTED (runs another whole suite).

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="128"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

PASS=0; FAIL=0; RESULTS=()
EXEC_N=0; STRUCT_N=0; BEHAV_N=0; NESTED_N=0; NESTED_NAMES=()
run_check() {
  local NAME="$1"; local CLASS="$2"; shift 2
  local LOG="$ARTIFACTS/${NAME}.log"
  case "$CLASS" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    nested) NESTED_N=$((NESTED_N+1)); NESTED_NAMES+=("$NAME") ;;
    *) echo "verify bug: unknown class '$CLASS' for $NAME"; exit 2 ;;
  esac
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-42s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-42s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# ══════════════════════════════════════════════════════════════════════════════════════════════
# CRITERION 8 — traced, not asserted: NOTHING else moved.
#   `K of 8` unchanged in derivation and shape · the command count stays 7 (a version FLAG is
#   not a command) · no gate's evidence contract moves.
# ══════════════════════════════════════════════════════════════════════════════════════════════

# `K of 8` still derives from each gate's evidence, and still names the same eight stations in
# the same order. Read LIVE from the binary, for a session with a real, non-degenerate history.
STATIONS=(Analyst Architect Planner Coder QA Demo-er Releaser Reviewer)
stations_shape_unchanged() {
  local out; out="$("$VAJRA" next --stations 127 2>&1)"; echo "$out"
  grep -q "stations passed (derived from each gate's evidence" <<<"$out" || {
    echo "MISSING: the derivation sentence — K of 8 is no longer described as derived"; return 1; }
  local s
  for s in "${STATIONS[@]}"; do
    grep -qE "^  \[(PASSED|ABSENT|WARN)\] +${s}\b" <<<"$out" || {
      echo "MISSING station line: $s"; return 1; }
  done
  # exactly eight station lines — not seven, not nine
  local n; n="$(grep -cE '^  \[(PASSED|ABSENT|WARN)\]' <<<"$out")"
  [ "$n" -eq 8 ] || { echo "expected 8 station lines, got $n"; return 1; }
  # and a non-degenerate baseline: S127 closed at 8 of 8
  grep -q "8 of 8 stations passed" <<<"$out" || {
    echo "S127 baseline moved — expected '8 of 8 stations passed'"; return 1; }
}
run_check "stations-k-of-8-unmoved" exec stations_shape_unchanged

# No 8th top-level command. Driven through the REAL front door: every plausible new command
# word — including `version`, because `--version` is a FLAG — must be rejected as unrecognised.
no_eighth_command_exists() {
  local w
  for w in version stranger ship review advice fleet stations doctor; do
    local err rc
    err="$("$VAJRA" "$w" 2>&1 >/dev/null)"; rc=$?
    echo "vajra $w -> exit $rc :: $(head -1 <<<"$err")"
    [ "$rc" -ne 0 ] || { echo "FAIL: 'vajra $w' exited 0 — it is a command"; return 1; }
    grep -q "unrecognised command" <<<"$err" || {
      echo "FAIL: 'vajra $w' was not rejected as unrecognised"; return 1; }
  done
}
run_check "no-eighth-command-exists" exec no_eighth_command_exists

# The banner still advertises exactly the seven. (BEHAVIORAL — a hardcoded usage string, named
# in the disclosure since S69. It proves what is PRINTED, never what is dispatched.)
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"; echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "banner-still-lists-seven" behav help_lists_seven

# No gate's evidence contract moved. Computed from git against the merge base — not from prose.
GATE_MODULES="src/analyst src/architect src/planner src/coder src/qa src/demoer src/releaser src/advice src/stations src/obedience src/fleet"
no_gate_module_touched() {
  local base; base="$(git merge-base main HEAD 2>/dev/null)" || return 1
  [ -n "$base" ] || { echo "cannot resolve merge-base — a check that cannot evaluate FAILS"; return 1; }
  local changed; changed="$(git diff --name-only "$base" HEAD)"
  echo "changed files vs $base:"; echo "$changed" | sed 's/^/  /'
  local m
  for m in $GATE_MODULES; do
    if grep -q "^${m}/" <<<"$changed"; then
      echo "FAIL: $m was modified — a gate's evidence contract moved"; return 1
    fi
  done
  echo "OK: none of the 11 gate/station modules were touched."
}
run_check "no-gate-evidence-contract-moved" struct no_gate_module_touched

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 128 Verify Summary ==="
printf '%-42s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-42s %-7s %s\n' "------------------------------------------" "-------" "------"
for r in ${RESULTS[@]+"${RESULTS[@]}"}; do echo "$r"; done
echo ""
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" ${NESTED_NAMES[@]+"${NESTED_NAMES[@]}"}
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
