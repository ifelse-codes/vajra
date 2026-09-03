#!/usr/bin/env bash
# Verify — Session 143: the constitution joins the smooth upgrade (split fill from governed body).
# `.ai/AGENTS.md` splits into a user-owned FILLED header + a byte-identical GOVERNED body divided by
# GOVERNED_BODY_SENTINEL; `vajra init --sync-fleet` upgrades ONLY the body (a boundary target),
# preserving the header verbatim, via the S142 MarkdownComment stamp (no fourth stamp path). A
# pre-S143 boundaryless constitution is the fifth state, NeedsBoundary — refused even under
# --overwrite-drifted, never clobbering the fill (DECISION-007 S143 addendum). No 8th command.
#
# What this suite proves beyond "a function exists":
#   1. body-scoped classify returns the FIVE states on the BODY region alone (a pure function of the
#      on-disk file + canonical body), and body_region extracts only the governed body;
#   2. the governed body carries NO fill placeholders (byte-identical across installs) and the
#      sentinel is HTML-legal + fill-free; the scaffold writes the body STAMPED (fresh init UpToDate);
#   3. the session's core property — an UPGRADE preserves the user header BYTE-FOR-BYTE — and a
#      boundaryless constitution is REFUSED even with --overwrite-drifted (unit + live + fixture);
#   4. the five-state falsifiability fixture on the CONSTITUTION goes RED for the exact right reason
#      (a stripped/edited body stamp is refused; a clobbered header fails HDR/MIG) + clean exit-0 control;
#   5. LIVE, with the REAL release binary in a REAL empty dir: fresh init scaffolds a stamped, bounded
#      constitution; immediate --sync-fleet is UpToDate incl. the constitution (no churn); a stale body
#      auto-upgrades preserving the header; a boundaryless one is refused with the sentinel printed;
#   6. the design is RECORDED (DECISION-007 S143 addendum) and it is still 7 top-level commands.
#
# CHECK CLASSES — EXECUTE-BASED (runs the real binary / cargo test, asserts on output) · STRUCTURAL
# grep (asserts architecture) · NESTED (runs another whole suite).
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="143"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

VAJRA="$ROOT/target/release/vajra"
[ -x "$VAJRA" ] || cargo build -q --release || { echo "release build failed"; exit 2; }

PASS=0; FAIL=0; RESULTS=()
EXEC_N=0; STRUCT_N=0; BEHAV_N=0; NESTED_N=0; NESTED_NAMES=()
run_check() {
  local NAME="$1" CLASS="$2"; shift 2
  case "$CLASS" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    nested) NESTED_N=$((NESTED_N+1)); NESTED_NAMES+=("$NAME") ;;
  esac
  if "$@" >>"$ARTIFACTS/${NAME}.log" 2>&1; then
    RESULTS+=("$(printf '%-58s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-58s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- 1. the FIVE body-scoped states + body_region are pure functions (acc 1, 2) -------------------
run_check "unit-classify-constitution-five-states" exec \
  cargo test -q --lib classify_constitution_names_the_five_states_on_the_body_region -- --exact
run_check "unit-body-region-extracts-body" exec \
  cargo test -q --lib body_region_extracts_only_the_governed_body -- --exact

# --- 2. the split is real: body has no fill, sentinel is legal, scaffold is stamped+UpToDate (acc 1) -
run_check "unit-constitution-body-no-fill" exec \
  cargo test -q --lib constitution_body_carries_no_fill_placeholders -- --exact
run_check "unit-sentinel-html-legal" exec \
  cargo test -q --lib governed_body_sentinel_is_html_legal_and_fill_free -- --exact
run_check "unit-scaffolded-constitution-uptodate" exec \
  cargo test -q --lib scaffolded_constitution_is_stamped_and_immediately_up_to_date -- --exact

# --- 3. the core property: header preserved on upgrade; boundaryless refused even with force (acc 3) -
run_check "unit-header-preserved-on-upgrade" exec \
  cargo test -q --lib governed_body_upgrade_preserves_the_user_header_verbatim -- --exact
run_check "unit-boundaryless-refused-even-forced" exec \
  cargo test -q --lib boundaryless_constitution_is_refused_even_with_overwrite_drifted -- --exact
run_check "unit-missing-constitution-warns-skips" exec \
  cargo test -q --lib a_missing_constitution_warns_and_is_skipped_not_created -- --exact

# --- 4. the five-state falsifiability fixture on the CONSTITUTION (acc 3) --------------------------
run_check "falsifiability-fixture-constitution-five-states" nested bash scripts/fixture-session-143.sh

# --- 5. LIVE: fresh init + sync + stale-upgrade + boundaryless, real binary, real dir (acc 4) -----
live_constitution_round_trip() {
  local W; W="$(mktemp -d "${TMPDIR:-/tmp}/vajra-v143-XXXXXX")"
  local S='<!-- vajra:governed-body - do not edit below this line - vajra owns and upgrades these bytes -->'
  ( cd "$W"
    printf 'acme-app\nlock the charts\nL2\n' | "$VAJRA" init >/dev/null 2>&1
    grep -qF "$S" .ai/AGENTS.md || { echo "FAIL: fresh init did not add the sentinel"; exit 1; }
    tail -1 .ai/AGENTS.md | grep -q '^<!-- vajra-render-sha:' || { echo "FAIL: constitution body not stamped"; exit 1; }
    # immediate sync: UpToDate incl. the constitution, no churn
    m1=$(stat -f %m .ai/AGENTS.md 2>/dev/null || stat -c %Y .ai/AGENTS.md)
    out="$("$VAJRA" init --sync-fleet 2>&1)"; [ $? -eq 0 ] || { echo "FAIL: immediate sync did not exit 0"; exit 1; }
    grep -q ".ai/AGENTS.md (up to date)" <<<"$out" || { echo "FAIL: constitution not reported up to date"; exit 1; }
    # AC4 end-to-end: EVERYTHING (roles + hooks + constitution) UpToDate — nothing created/upgraded/refreshed.
    grep -q "0 created, 0 upgraded, 0 refreshed" <<<"$out" || { echo "FAIL: immediate sync was not all-UpToDate (roles+hooks+constitution)"; exit 1; }
    m2=$(stat -f %m .ai/AGENTS.md 2>/dev/null || stat -c %Y .ai/AGENTS.md)
    [ "$m1" = "$m2" ] || { echo "FAIL: UpToDate constitution was rewritten (mtime churn)"; exit 1; }
    # plant a stamped OLDER body under a CUSTOM header; it must auto-upgrade and preserve the header
    printf '# ACME \xe2\x80\x94 Our Constitution\n\n> hand preamble\n\n' > hdr.txt
    printf '%s\n\n## Mandatory Load Order\n\nOLD BODY\n' "$S" > pre.txt
    h="$(shasum -a 256 < pre.txt | awk '{print $1}')"
    { cat hdr.txt pre.txt; printf '<!-- vajra-render-sha: %s -->\n' "$h"; } > .ai/AGENTS.md
    out="$("$VAJRA" init --sync-fleet 2>&1)"; [ $? -eq 0 ] || { echo "FAIL: stale body did not auto-upgrade"; exit 1; }
    grep -q "upgrade .ai/AGENTS.md" <<<"$out" || { echo "FAIL: stale body upgrade not reported by name"; exit 1; }
    grep -q "OLD BODY" .ai/AGENTS.md && { echo "FAIL: old body survived the upgrade"; exit 1; }
    python3 - .ai/AGENTS.md "$S" hdr.txt <<'PY' || { echo "FAIL: header not preserved byte-for-byte"; exit 1; }
import sys
d=open(sys.argv[1],'rb').read(); i=d.find(sys.argv[2].encode())
sys.exit(0 if d[:i]==open(sys.argv[3],'rb').read() else 1)
PY
    # a boundaryless constitution is NeedsBoundary — refused even with --overwrite-drifted
    printf '# ACME \xe2\x80\x94 legacy\n\n## Mandatory Load Order\n\nno sentinel here\n' > .ai/AGENTS.md
    before="$(cat .ai/AGENTS.md)"
    out="$("$VAJRA" init --sync-fleet --overwrite-drifted 2>&1)"; rc=$?
    [ "$rc" -eq 1 ] || { echo "FAIL: boundaryless constitution not refused (exit $rc)"; exit 1; }
    grep -q "needs-boundary" <<<"$out" || { echo "FAIL: not reported as needs-boundary"; exit 1; }
    grep -qF "$S" <<<"$out" || { echo "FAIL: migration message did not print the sentinel"; exit 1; }
    [ "$(cat .ai/AGENTS.md)" = "$before" ] || { echo "FAIL: boundaryless constitution was rewritten"; exit 1; }
    echo "OK: fresh init stamped + bounded; sync UpToDate no-churn; stale upgrade preserved header; boundaryless refused"
  )
  local rc=$?
  rm -rf "$W"
  return $rc
}
run_check "live-constitution-round-trip" exec live_constitution_round_trip

# --- 6a. the boundary wiring is in the SOURCE (acc 1-3) -------------------------------------------
source_has_boundary_wiring() {
  local rc=0
  grep -q "GOVERNED_BODY_SENTINEL" src/cli/init.rs || { echo "FAIL: no GOVERNED_BODY_SENTINEL"; rc=1; }
  grep -q "fn body_region" src/cli/init.rs || { echo "FAIL: no body_region helper"; rc=1; }
  grep -q "NeedsBoundary" src/cli/init.rs || { echo "FAIL: no NeedsBoundary state"; rc=1; }
  grep -q "boundary: Option" src/cli/init.rs || { echo "FAIL: no boundary field on the sync target"; rc=1; }
  grep -q "fn governed_body_canonical" src/cli/init.rs || { echo "FAIL: no governed_body_canonical"; rc=1; }
  grep -q "MarkdownComment" src/cli/init.rs || { echo "FAIL: constitution not using MarkdownComment stamp"; rc=1; }
  [ "$rc" -eq 0 ] && echo "OK: GOVERNED_BODY_SENTINEL + body_region + NeedsBoundary + boundary target + MarkdownComment"
  return $rc
}
run_check "source-has-boundary-wiring" struct source_has_boundary_wiring

# --- 6b. the design is RECORDED — the DECISION-007 S143 addendum (acc 5) ---------------------------
addendum_records_the_design() {
  local F="docs/decisions/DECISION-007-agent-fleet.md"; local rc=0
  grep -q "S143 addendum" "$F" || { echo "FAIL: no S143 addendum heading"; rc=1; }
  grep -qi "governed-body\|boundary sentinel\|GOVERNED_BODY_SENTINEL" "$F" || { echo "FAIL: addendum omits the boundary sentinel"; rc=1; }
  grep -qi "NeedsBoundary\|needs-boundary\|paste the sentinel\|one-time migration" "$F" || { echo "FAIL: addendum omits the legacy migration"; rc=1; }
  grep -qi "header.*verbatim\|preserve.*header\|byte-for-byte" "$F" || { echo "FAIL: addendum omits header preservation"; rc=1; }
  grep -qi "CONSTRAINTS.yaml" "$F" || { echo "FAIL: addendum does not state CONSTRAINTS.yaml stays out"; rc=1; }
  [ "$rc" -eq 0 ] && echo "OK: S143 addendum records the sentinel, body-scoped upgrade, migration, header preservation, constraints-out"
  return $rc
}
run_check "decision-007-s143-addendum" struct addendum_records_the_design

# --- 6c. nothing else moved — still 7 top-level commands (no 8th, guardrail) -----------------------
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
echo "session 143 verify: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] && echo "RESULT: PASS" || echo "RESULT: FAIL"
[ "$FAIL" -eq 0 ]
