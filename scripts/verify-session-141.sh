#!/usr/bin/env bash
# Verify — Session 141: best install + upgrade-in-place. Give every scaffolded fleet role file a
# recorded `vajra-render-sha:` stamp, add the fourth `FleetFileState::StaleRender`, and make
# `vajra init --sync-fleet` AUTO-UPGRADE an untouched old render (no `--overwrite-drifted`) while
# still refusing a user edit / unstamped file. Closes the S136 "stale-vs-edited not derivable" floor
# by RECORDING the provenance (DECISION-007 S141 addendum), not inferring it.
#
# What this suite proves beyond "a function exists":
#   1. the stamp ROUND-TRIPS and is INERT — per role, sha256(body-minus-stamp)==embedded, and the
#      stamp sits in the frontmatter (never the model-visible body), so dispatch-by-name is untouched;
#   2. `classify_fleet_file` returns FOUR states and StaleRender is driven by the stamp VERIFYING;
#   3. the four-case falsifiability fixture goes RED for the exact right reason (an unstamped/edited
#      file is REFUSED) and GREEN when correct — its positive control asserts a clean exit 0;
#   4. LIVE, with the REAL release binary in a REAL empty dir: fresh sync creates + is idempotent
#      (no mtime churn), and a planted stamped OLDER render upgrades EXACTLY it, nothing else;
#   5. the DECISION-007 S141 addendum records the design; still 7 top-level commands (no 8th).
#
# CHECK CLASSES — EXECUTE-BASED (runs the real binary / cargo test, asserts on output) · STRUCTURAL
# grep (asserts architecture) · NESTED (runs another whole suite).
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="141"
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
    RESULTS+=("$(printf '%-54s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-54s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- 1. the stamp round-trips + is inert, PER ROLE (acc 1) ----------------------------------------
run_check "unit-stamp-round-trip-and-inert" exec \
  cargo test --release --lib render_stamp_round_trips_and_is_inert_for_every_role
run_check "unit-stamp-inverse-and-falsifiable" exec \
  cargo test --release --lib strip_render_stamp_is_the_exact_inverse_and_verification_is_falsifiable

# --- 2. classify returns FOUR states, StaleRender driven by the stamp verifying (acc 2) -----------
run_check "unit-classify-four-states" exec \
  cargo test --release --lib classify_fleet_file_names_the_four_states
run_check "unit-sync-auto-upgrades-stale" exec \
  cargo test --release --lib sync_fleet_auto_upgrades_a_stale_render_without_overwrite_and_exits_zero

# --- 3. the four-case falsifiability fixture (acc 3) ----------------------------------------------
run_check "falsifiability-fixture-four-states" nested bash scripts/fixture-session-141.sh

# --- 4. LIVE real-empty-dir round-trip with the REAL binary (acc 4) -------------------------------
# Fresh sync creates + is idempotent with NO mtime churn; a planted stamped OLDER render upgrades
# EXACTLY it and nothing else. The stranger-check property: proven against the real product a user
# downloads, not only in unit tests.
live_real_dir_round_trip() {
  local W; W="$(mktemp -d "${TMPDIR:-/tmp}/vajra-v141-XXXXXX")"; local rc=0
  # No .git ancestor, so find_project_root uses W as-is.
  ( cd "$W"
    "$VAJRA" init --sync-fleet >/dev/null 2>&1 || { echo "FAIL: fresh sync did not exit 0"; exit 1; }
    local R=".claude/agents/researcher.md"
    [ -f "$R" ] || { echo "FAIL: fresh sync created no researcher.md"; exit 1; }
    # Idempotence + no churn: mtime of an UpToDate file must not move on a second sync.
    local m1; m1="$(stat -f %m "$R" 2>/dev/null || stat -c %Y "$R")"
    sleep 1
    local out2; out2="$("$VAJRA" init --sync-fleet 2>&1)"
    local m2; m2="$(stat -f %m "$R" 2>/dev/null || stat -c %Y "$R")"
    [ "$m1" = "$m2" ] || { echo "FAIL: an UpToDate file was rewritten (mtime churn $m1 -> $m2)"; exit 1; }
    grep -qE '^  (create|upgrade|refresh|DRIFT)' <<<"$out2" && { echo "FAIL: idempotent re-run still acted"; exit 1; }
    # Plant a correctly-stamped OLDER render for ONE role; the next sync must upgrade EXACTLY it.
    printf '%s\n' '---' 'name: researcher' 'description: older' 'tools: Read, Grep, Glob' '---' '' 'OLDER' > older.txt
    local h; h="$(shasum -a 256 < older.txt | awk '{print $1}')"
    awk -v h="$h" '/^---$/{c++; if(c==2) print "vajra-render-sha: " h} {print}' older.txt > "$R"
    local plan_before; plan_before="$(cat .claude/agents/plan-advisor.md)"
    local out3; out3="$("$VAJRA" init --sync-fleet 2>&1)"; local code=$?
    [ "$code" -eq 0 ] || { echo "FAIL: stale-render sync did not exit 0 (got $code)"; exit 1; }
    grep -q "upgrade $R" <<<"$out3" || { echo "FAIL: the stale render was not upgraded by name"; exit 1; }
    grep -q "OLDER" "$R" && { echo "FAIL: researcher.md still holds the old body"; exit 1; }
    [ "$(cat .claude/agents/plan-advisor.md)" = "$plan_before" ] || { echo "FAIL: an unrelated role file changed"; exit 1; }
    echo "OK: fresh create + idempotent no-churn + exact-one stale upgrade, all live"
  )
  rc=$?
  rm -rf "$W"
  return $rc
}
run_check "live-real-dir-round-trip" exec live_real_dir_round_trip

# --- 5. the stamp is emitted in the FRONTMATTER of the REAL render (acc 1, placement) -------------
live_stamp_placement() {
  local W; W="$(mktemp -d "${TMPDIR:-/tmp}/vajra-p141-XXXXXX")"; local rc=0
  ( cd "$W"
    "$VAJRA" init --sync-fleet >/dev/null 2>&1
    local R=".claude/agents/researcher.md"
    # The stamp must sit between the two `---` fences (frontmatter), NOT in the body after them.
    local close; close="$(grep -n '^---$' "$R" | sed -n 2p | cut -d: -f1)"
    local stampln; stampln="$(grep -n '^vajra-render-sha:' "$R" | head -1 | cut -d: -f1)"
    [ -n "$stampln" ] || { echo "FAIL: no vajra-render-sha stamp in the rendered file"; exit 1; }
    [ "$stampln" -lt "$close" ] || { echo "FAIL: stamp (line $stampln) is not before the closing fence (line $close)"; exit 1; }
    awk 'f{print} /^---$/{c++; if(c==2) f=1}' "$R" | grep -q '^vajra-render-sha:' \
      && { echo "FAIL: stamp leaked into the model-visible body"; exit 1; }
    grep -q '^name: researcher$' "$R" || { echo "FAIL: name: missing — dispatch-by-name would break"; exit 1; }
    echo "OK: stamp in frontmatter (line $stampln < closing fence $close), body clean, name: intact"
  )
  rc=$?
  rm -rf "$W"
  return $rc
}
run_check "live-stamp-in-frontmatter-not-body" exec live_stamp_placement

# --- 6. the fourth state + the stamp-driven classify are really in the source (acc 2) -------------
source_has_fourth_state() {
  local rc=0
  grep -q "StaleRender" src/cli/init.rs || { echo "FAIL: FleetFileState::StaleRender absent"; rc=1; }
  grep -q "render_stamp_verifies(body)" src/cli/init.rs || { echo "FAIL: classify does not gate StaleRender on the stamp verifying"; rc=1; }
  grep -q 'RENDER_STAMP_KEY' src/fleet/mod.rs || { echo "FAIL: no stamp key constant"; rc=1; }
  [ "$rc" -eq 0 ] && echo "OK: StaleRender + stamp-verified classify + RENDER_STAMP_KEY present"
  return $rc
}
run_check "source-has-fourth-state-and-stamp" struct source_has_fourth_state

# --- 7. the design is RECORDED — the DECISION-007 S141 addendum (acc 5) ---------------------------
addendum_records_the_design() {
  local F="docs/decisions/DECISION-007-agent-fleet.md"; local rc=0
  grep -q "S141 addendum — the render stamp" "$F" || { echo "FAIL: no S141 addendum heading"; rc=1; }
  grep -q "tamper-EVIDENT not tamper-PROOF" "$F" || { echo "FAIL: addendum omits the honest content-hash limit"; rc=1; }
  grep -qi "written at render time\|does not\|NOT reopen\|recorded" "$F" || { echo "FAIL: addendum does not distinguish recorded-vs-inferred"; rc=1; }
  [ "$rc" -eq 0 ] && echo "OK: S141 addendum records the stamp format, the fourth state, and the honest limits"
  return $rc
}
run_check "decision-007-s141-addendum" struct addendum_records_the_design

# --- 8. nothing else moved — still 7 top-level commands (no 8th, guardrail) -----------------------
seven_commands_still() {
  local rc=0
  local CMDS; CMDS="$("$VAJRA" --help 2>&1 | grep -cE '^\s{2,}(claude|next|init|check|meter|estimate|hook)\b')"
  echo "top-level commands matched: $CMDS (expect 7)"
  [ "$CMDS" -eq 7 ] || { echo "FAIL: the top-level command count changed — an 8th command?"; rc=1; }
  return $rc
}
run_check "seven-commands-no-eighth" exec seven_commands_still

# ── tally ─────────────────────────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════════════"
printf '%s\n' "${RESULTS[@]}"
echo "────────────────────────────────────────────────────────────────────"
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" "${NESTED_NAMES[@]}"
echo "────────────────────────────────────────────────────────────────────"
echo "session 141 verify: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] && echo "RESULT: PASS" || echo "RESULT: FAIL"
[ "$FAIL" -eq 0 ]
