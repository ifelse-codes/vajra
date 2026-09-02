#!/usr/bin/env bash
# Verify — Session 139: make the tech-lead's `required` verdict BIND at CLOSE. The S135 crew gate
# (`vajra next --check-crew`) already checks "every required role produced a real governed handoff",
# but that binding lived ONLY in `vajra next --advance`, which a real close never invokes — the S138
# dogfood closed 12/12 green + merged with a required role skipped. S139 wires `check_required_crew`
# into `verify-closeout.sh` so the close itself binds. What this suite proves beyond "a function exists":
#   1. S139's OWN close passes `check_required_crew` — the self-binding test (S125/S129, acc 3);
#   2. a session with no tech-lead handoff BLOCKS the close, naming the missing tech-lead (acc 1/2);
#   3. the falsifiability fixture goes RED when a required handoff is hidden, GREEN restored (acc 2);
#   4. `check_required_crew` is wired into `main()`'s check list AND a focused `--crew-only` entry (acc 1);
#   5. the gate propagates to `vajra init` verbatim via include_str! (the scaffold byte-identity, acc 4);
#   6. all three binary-backed close checks use the set -e-safe capture — a BLOCK reports, not aborts;
#   7. nothing else moved — still 7 top-level commands, no new src ladder, the header guard is required.
#
# CHECK CLASSES — EXECUTE-BASED (runs the real close-gate / binary, asserts on output) · STRUCTURAL
# grep (asserts architecture) · NESTED (runs another whole suite).
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="139"
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
    RESULTS+=("$(printf '%-52s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-52s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

GATE="scripts/verify-closeout.sh"

# --- 1. the self-bind: S139's OWN close passes check_required_crew (acc 3) -------------------------
# The whole point (S125/S129/S134): a gate no session runs is decoration. S139 records its own
# tech-lead + three required handoffs, so its own --crew-only close check must be GREEN.
self_bind_passes() {
  local OUT; OUT="$(bash "$GATE" --crew-only 139 2>&1)"; local code=$?
  echo "$OUT" | tail -4; echo "exit=$code"
  [ "$code" -eq 0 ] || { echo "FAIL: S139's own close-gate did not pass check_required_crew"; return 1; }
  grep -q "CREW: PASS" <<<"$OUT" || { echo "FAIL: expected CREW: PASS"; return 1; }
  grep -q "every role it marked .required. produced a governed handoff" <<<"$OUT" \
    || { echo "FAIL: the pass message is not the crew gate's"; return 1; }
}
run_check "self-bind-s139-own-close-passes-crew" exec self_bind_passes

# --- 2. a session with no tech-lead handoff BLOCKS the close, naming it (acc 1/2) ------------------
# Session 9999 has no handoffs at all — the close-gate must BLOCK and name the missing tech-lead,
# never green by falling through. Proves the gate BINDS, not merely runs.
absent_crew_blocks() {
  local OUT; OUT="$(bash "$GATE" --crew-only 9999 2>&1)"; local code=$?
  echo "$OUT" | grep -E "CREW:|no real tech-lead|FAIL:" | head; echo "exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: a session with no tech-lead handoff did not block (exit $code)"; return 1; }
  grep -q "no real tech-lead handoff" <<<"$OUT" || { echo "FAIL: the block does not name the missing tech-lead"; return 1; }
  grep -q "CREW: FAIL" <<<"$OUT" || { echo "FAIL: expected CREW: FAIL"; return 1; }
}
run_check "absent-tech-lead-blocks-the-close" exec absent_crew_blocks

# --- 3. the falsifiability fixture — RED when a required handoff is hidden, GREEN restored (acc 2) --
run_check "falsifiability-fixture" nested bash scripts/fixture-session-139.sh

# --- 4. check_required_crew is wired into main() AND has a focused entry (acc 1) -------------------
wired_into_close() {
  local rc=0
  # The function is CALLED in main()'s check list (not merely defined), between the design mandate
  # and the attestation — the same neighborhood as its binary-backed siblings.
  awk '/^check_session_file$/,/^check_review_attestation$/' "$GATE" | grep -q '^check_required_crew$' \
    || { echo "FAIL: check_required_crew is not called in main()'s check list"; rc=1; }
  # The focused entry point exists (the fixture drives it).
  grep -q '"--crew-only"' "$GATE" || { echo "FAIL: no --crew-only focused entry point"; rc=1; }
  # It runs the REAL binary and requires the gate's own header (a run_dump exit-0 cannot green it).
  grep -q 'next --check-crew' "$GATE" || { echo "FAIL: the check does not call vajra next --check-crew"; rc=1; }
  grep -q '=== crew: tech-lead for session' "$GATE" || { echo "FAIL: the check does not require the gate header"; rc=1; }
  [ "$rc" -eq 0 ] && echo "OK: wired into main(), --crew-only present, binary + header guard in place"
  return $rc
}
run_check "check-required-crew-wired-into-close" struct wired_into_close

# --- 5. propagation to `vajra init` — the scaffold ships this gate verbatim (acc 4) ----------------
# verify-closeout.sh is embedded by include_str!, so the one edit reaches every adopter. The init
# byte-identity test proves the scaffolded copy equals the canonical one (now carrying the gate).
run_check "scaffold-ships-crew-gate-verbatim" nested \
  cargo test --release --lib cli::init::tests::scaffold_ships_verify_closeout_verbatim_and_executable

# --- 6. all three binary-backed close checks use the set -e-safe capture ---------------------------
# The bare `out="$(cmd)"; code=$?` ABORTS under set -e on a non-zero binary exit — a BLOCKING verdict
# would kill the run before printing its FAIL reason (breaking the S122 "right reason" bar). All three
# must use the `&& code=0 || code=$?` list form; no bare form may survive.
set_e_safe_capture() {
  local rc=0
  local list_forms; list_forms="$(grep -cE 'next --check-(crew|obeyed|design-handoff) .* && code=0 \|\| code=\$\?' "$GATE")"
  echo "set -e-safe list-form captures found: $list_forms (expect 3)"
  [ "$list_forms" -eq 3 ] || { echo "FAIL: not all three binary-backed checks use the list form"; rc=1; }
  if grep -nE 'next --check-(crew|obeyed|design-handoff) 2>&1\)"; code=\$\?' "$GATE"; then
    echo "FAIL: a bare 'out=\$(...); code=\$?' capture survives — it aborts on a blocking verdict"; rc=1
  else
    echo "OK: no bare command-substitution capture remains on a binary-backed check"
  fi
  return $rc
}
run_check "all-binary-checks-set-e-safe" struct set_e_safe_capture

# --- 7. nothing else moved — 7 commands, no new src ladder, K of 8 unchanged -----------------------
nothing_else_moved() {
  local rc=0
  # No 8th top-level command: this rides verify-closeout.sh + the existing `vajra next --check-crew`.
  local CMDS; CMDS="$("$VAJRA" --help 2>&1 | grep -cE '^\s{2,}(claude|next|init|check|meter|estimate|hook)\b')"
  echo "top-level commands matched: $CMDS (expect 7)"
  [ "$CMDS" -eq 7 ] || { echo "FAIL: the top-level command count changed"; rc=1; }
  # This session added NO Rust — it is a shell-gate wiring + fixture + scripts. src/ is untouched vs main.
  local SRC_DELTA; SRC_DELTA="$(git diff main --stat -- src/ 2>/dev/null)"
  echo "git diff main -- src/: ${SRC_DELTA:-<empty — 0 lines>}"
  [ -z "$SRC_DELTA" ] || { echo "FAIL: src/ changed — this session was meant to be shell-only"; rc=1; }
  # The crew suite still passes (the gate this close-check delegates to is unbroken).
  cargo test --release --lib crew::tests >/dev/null 2>&1 || { echo "FAIL: crew unit suite red"; rc=1; }
  [ "$rc" -eq 0 ] && echo "OK: 7 commands, 0 src lines, crew suite green"
  return $rc
}
run_check "nothing-else-moved-7-commands-no-src-delta" exec nothing_else_moved

# ── tally ─────────────────────────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════════════"
printf '%s\n' "${RESULTS[@]}"
echo "────────────────────────────────────────────────────────────────────"
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" "${NESTED_NAMES[@]}"
echo "────────────────────────────────────────────────────────────────────"
echo "session 139 verify: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] && echo "RESULT: PASS" || echo "RESULT: FAIL"
[ "$FAIL" -eq 0 ]
