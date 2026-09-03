#!/usr/bin/env bash
# Verify — Session 142: complete the upgrade loop for the pure-render scaffold files. Generalise the
# S141 `vajra-render-sha:` stamp beyond YAML frontmatter to the shell hooks (`.ai/hooks/hook-*.sh`,
# a `# vajra-render-sha:` trailing comment), and widen the SINGLE existing `vajra init --sync-fleet`
# (no 8th command) so the hooks gain the same four-state smooth upgrade — an untouched old render
# auto-upgrades, a user edit / unstamped file is refused. `.ai/AGENTS.md` (a filled template) is the
# named S143 follow-up; `CONSTRAINTS.yaml` stays user-owned (DECISION-007 S142 addendum).
#
# What this suite proves beyond "a function exists":
#   1. the stamp ROUND-TRIPS per file type and the FRONTMATTER variant is byte-identical to S141 (so
#      no role file churns), and the shell/markdown variants strip to the EXACT preimage;
#   2. the hook templates carry NO fill placeholders + a fresh scaffold writes them STAMPED, so a
#      first `--sync-fleet` finds them UpToDate (idempotent, no churn);
#   3. the four-case falsifiability fixture on a HOOK goes RED for the exact right reason (an
#      unstamped/edited hook is REFUSED) and GREEN when correct — positive control asserts exit 0;
#   4. LIVE, with the REAL release binary in a REAL empty dir: fresh sync creates stamped hooks + is
#      idempotent, and a planted stamped OLDER hook upgrades EXACTLY it, nothing else;
#   5. the stamp does NOT change behavior — every stamped hook still parses + the stamp is the inert
#      trailing comment; and the DECISION-007 S142 addendum records the design; still 7 commands.
#
# CHECK CLASSES — EXECUTE-BASED (runs the real binary / cargo test, asserts on output) · STRUCTURAL
# grep (asserts architecture) · NESTED (runs another whole suite).
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="142"
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
    RESULTS+=("$(printf '%-56s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-56s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- 1. the stamp round-trips per file type; frontmatter byte-identical to S141 (acc 1) ----------
run_check "unit-stamp-round-trips-per-file-type" exec \
  cargo test --release --lib stamp_round_trips_per_file_type_and_frontmatter_is_byte_identical_to_s141
run_check "unit-stamp-inverse-and-falsifiable" exec \
  cargo test --release --lib strip_render_stamp_is_the_exact_inverse_and_verification_is_falsifiable

# --- 2. hooks carry no fill + a fresh scaffold writes them stamped, immediately UpToDate (acc 2) --
run_check "unit-hooks-no-fill-placeholders" exec \
  cargo test --release --lib hook_templates_carry_no_fill_placeholders
run_check "unit-scaffolded-hooks-stamped-uptodate" exec \
  cargo test --release --lib scaffolded_hooks_are_stamped_and_immediately_up_to_date
run_check "unit-classify-four-states" exec \
  cargo test --release --lib classify_fleet_file_names_the_four_states
# fidelity-reviewer rec 1: the four states driven through a SHELL HOOK at the pure-unit level,
# not only frontmatter — closes the named fakest green (hook classify had no unit guard).
run_check "unit-classify-four-states-hook" exec \
  cargo test --release --lib classify_names_the_four_states_for_a_shell_hook

# --- 3. the four-case falsifiability fixture on a HOOK (acc 3) ------------------------------------
run_check "falsifiability-fixture-hook-four-states" nested bash scripts/fixture-session-142.sh

# --- 4. LIVE real-empty-dir round-trip on HOOKS with the REAL binary (acc 4) ----------------------
live_hook_round_trip() {
  local W; W="$(mktemp -d "${TMPDIR:-/tmp}/vajra-v142-XXXXXX")"; local rc=0
  ( cd "$W"
    "$VAJRA" init --sync-fleet >/dev/null 2>&1 || { echo "FAIL: fresh sync did not exit 0"; exit 1; }
    local Hk=".ai/hooks/hook-session-guard.sh"
    [ -f "$Hk" ] || { echo "FAIL: fresh sync created no hook"; exit 1; }
    # The hook is stamped with a trailing shell-comment stamp.
    tail -1 "$Hk" | grep -q '^# vajra-render-sha:' || { echo "FAIL: hook not stamped at scaffold"; exit 1; }
    # Idempotence + no churn: mtime of an UpToDate hook must not move on a second sync.
    local m1; m1="$(stat -f %m "$Hk" 2>/dev/null || stat -c %Y "$Hk")"
    sleep 1
    local out2; out2="$("$VAJRA" init --sync-fleet 2>&1)"
    local m2; m2="$(stat -f %m "$Hk" 2>/dev/null || stat -c %Y "$Hk")"
    [ "$m1" = "$m2" ] || { echo "FAIL: an UpToDate hook was rewritten (mtime churn $m1 -> $m2)"; exit 1; }
    grep -qE '^  (create|upgrade|refresh|DRIFT)' <<<"$out2" && { echo "FAIL: idempotent re-run still acted"; exit 1; }
    # Plant a correctly-stamped OLDER hook render; the next sync must upgrade EXACTLY it.
    printf '%s\n' '#!/usr/bin/env bash' '# OLDER hook body' 'exit 0' > older.txt
    local h; h="$(shasum -a 256 < older.txt | awk '{print $1}')"
    cp older.txt "$Hk"; printf '# vajra-render-sha: %s\n' "$h" >> "$Hk"
    local guard_before; guard_before="$(cat .ai/hooks/hook-commit-guard.sh)"
    local out3; out3="$("$VAJRA" init --sync-fleet 2>&1)"; local code=$?
    [ "$code" -eq 0 ] || { echo "FAIL: stale-render sync did not exit 0 (got $code)"; exit 1; }
    grep -q "upgrade $Hk" <<<"$out3" || { echo "FAIL: the stale hook was not upgraded by name"; exit 1; }
    grep -q "OLDER hook body" "$Hk" && { echo "FAIL: the hook still holds the old body"; exit 1; }
    [ "$(cat .ai/hooks/hook-commit-guard.sh)" = "$guard_before" ] || { echo "FAIL: an unrelated hook changed"; exit 1; }
    echo "OK: fresh stamped create + idempotent no-churn + exact-one stale hook upgrade, all live"
  )
  rc=$?
  rm -rf "$W"
  return $rc
}
run_check "live-hook-round-trip" exec live_hook_round_trip

# --- 5. the stamp does NOT change behavior — stamped hooks parse + stamp is the inert last line ---
live_stamp_inert() {
  local W; W="$(mktemp -d "${TMPDIR:-/tmp}/vajra-i142-XXXXXX")"; local rc=0
  ( cd "$W"
    "$VAJRA" init --sync-fleet >/dev/null 2>&1
    for hk in .ai/hooks/hook-*.sh; do
      bash -n "$hk" || { echo "FAIL: $hk does not parse after stamping"; exit 1; }
      tail -1 "$hk" | grep -q '^# vajra-render-sha:' || { echo "FAIL: $hk stamp is not the trailing line"; exit 1; }
      head -1 "$hk" | grep -q '^#!' || { echo "FAIL: $hk lost its shebang on line 1"; exit 1; }
      # Stripping the trailing stamp comment leaves a still-parseable script (inert to execution).
      sed '$ d' "$hk" > nostamp.sh
      bash -n nostamp.sh || { echo "FAIL: $hk body-without-stamp does not parse"; exit 1; }
    done
    echo "OK: every stamped hook parses; shebang on line 1; stamp is the inert trailing comment"
  )
  rc=$?
  rm -rf "$W"
  return $rc
}
run_check "live-stamp-inert-hook-still-runs" exec live_stamp_inert

# --- 6. the shell-comment stamp wiring is really in the source (acc 1/2) --------------------------
source_has_shell_stamp_wiring() {
  local rc=0
  grep -q "enum StampSyntax" src/fleet/mod.rs || { echo "FAIL: no StampSyntax enum"; rc=1; }
  grep -q "ShellComment" src/fleet/mod.rs || { echo "FAIL: no ShellComment variant"; rc=1; }
  grep -q "SYNC_HOOKS" src/cli/init.rs || { echo "FAIL: hooks not in the sync target set"; rc=1; }
  grep -q "render_stamped_hook" src/cli/init.rs || { echo "FAIL: no single-source hook renderer"; rc=1; }
  # classify is now syntax-parameterised, not frontmatter-hardwired. (S143 renamed the classified
  # slice `body` -> `region` when it became body-scoped; the syntax-aware call is the invariant.)
  grep -qE "render_stamp_verifies\((body|region), syntax\)" src/cli/init.rs || { echo "FAIL: classify is not syntax-aware"; rc=1; }
  [ "$rc" -eq 0 ] && echo "OK: StampSyntax::ShellComment + SYNC_HOOKS + render_stamped_hook + syntax-aware classify"
  return $rc
}
run_check "source-has-shell-stamp-wiring" struct source_has_shell_stamp_wiring

# --- 7. the design is RECORDED — the DECISION-007 S142 addendum (acc 5) ---------------------------
addendum_records_the_design() {
  local F="docs/decisions/DECISION-007-agent-fleet.md"; local rc=0
  grep -q "S142 addendum" "$F" || { echo "FAIL: no S142 addendum heading"; rc=1; }
  grep -qi "ShellComment\|shell comment\|# vajra-render-sha" "$F" || { echo "FAIL: addendum omits the shell-comment stamp"; rc=1; }
  grep -qi "constitution is deferred\|AGENTS.md.*defer\|S143\|filled template" "$F" || { echo "FAIL: addendum does not record the deferred constitution"; rc=1; }
  grep -qi "CONSTRAINTS.yaml" "$F" || { echo "FAIL: addendum does not state CONSTRAINTS.yaml stays user-owned"; rc=1; }
  [ "$rc" -eq 0 ] && echo "OK: S142 addendum records the generalised stamp, hooks-in / constitution-deferred, constraints-out"
  return $rc
}
run_check "decision-007-s142-addendum" struct addendum_records_the_design

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
echo "session 142 verify: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] && echo "RESULT: PASS" || echo "RESULT: FAIL"
[ "$FAIL" -eq 0 ]
