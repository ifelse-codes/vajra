#!/usr/bin/env bash
# Verify — Session 129: one source for what a stranger gets.
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

SESSION="129"
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
    RESULTS+=("$(printf '%-44s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-44s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# ══════════════════════════════════════════════════════════════════════════════════════════════
# CRITERION 6 — traced, not asserted: NOTHING else moved.
# ══════════════════════════════════════════════════════════════════════════════════════════════

# `K of 8` still derives from each gate's evidence, and still names the same eight stations in
# the same order. Read LIVE from the binary, against a real, non-degenerate history (S128 = 8/8).
STATIONS=(Analyst Architect Planner Coder QA Demo-er Releaser Reviewer)
stations_shape_unchanged() {
  local out; out="$("$VAJRA" next --stations 128 2>&1)"; echo "$out"
  grep -q "stations passed (derived from each gate's evidence" <<<"$out" || {
    echo "MISSING: the derivation sentence — K of 8 is no longer described as derived"; return 1; }
  local s
  for s in "${STATIONS[@]}"; do
    grep -qE "^  \[(PASSED|ABSENT|WARN)\] +${s}\b" <<<"$out" || {
      echo "MISSING station line: $s"; return 1; }
  done
  local n; n="$(grep -cE '^  \[(PASSED|ABSENT|WARN)\]' <<<"$out")"
  [ "$n" -eq 8 ] || { echo "expected 8 station lines, got $n"; return 1; }
  grep -q "8 of 8 stations passed" <<<"$out" || {
    echo "S128 baseline moved — expected '8 of 8 stations passed'"; return 1; }
}
run_check "stations-k-of-8-unmoved" exec stations_shape_unchanged

# No 8th top-level command. Driven through the REAL front door. `scaffold` and `drift` are in the
# list because this session's new capability is a SCRIPT — if it had grown a command, this fails.
no_eighth_command_exists() {
  local w
  for w in scaffold drift version stranger ship review advice fleet; do
    local err rc
    err="$("$VAJRA" "$w" 2>&1 >/dev/null)"; rc=$?
    echo "vajra $w -> exit $rc :: $(head -1 <<<"$err")"
    [ "$rc" -ne 0 ] || { echo "FAIL: 'vajra $w' exited 0 — it is a command"; return 1; }
    grep -q "unrecognised command" <<<"$err" || {
      echo "FAIL: 'vajra $w' was not rejected as unrecognised"; return 1; }
  done
}
run_check "no-eighth-command-exists" exec no_eighth_command_exists

# The banner still advertises exactly the seven. (BEHAVIORAL — a hardcoded usage string. It
# proves what is PRINTED, never what is dispatched; named in the disclosure since S69.)
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"; echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "banner-still-lists-seven" behav help_lists_seven

# Every BUILD INPUT this session touched is DECLARED here with a reason, and a declaration that
# names a file the diff never touched FAILS too (S128's replacement for its own fakest green).
#
# S129 widens the inventory, because the derivation moved OUTSIDE src/: the binary is now built
# from build.rs and, through it, from two files in .ai/. The inventory is DERIVED twice over —
# `git ls-files` for the tree, and build.rs's own `cargo:rerun-if-changed=` lines for the
# governance files it reads. Nothing here is typed, so adding a new derivation source widens the
# check automatically.
#
# Declared, with why:
#   build.rs             — steps 3+4, NEW. The derivation and the declaration manifest.
#   src/cli/init.rs      — steps 3+4. TPL_AGENTS and TPL_CONSTRAINTS now include_str! the derived
#                          fragments in place of the hand-typed Hard Rules table and audit list.
#   Cargo.toml           — step 3. Un-excludes the two derivation sources so a PACKAGED crate can
#                          still build; without it `cargo install vajractl` would break.
#   .ai/CONSTRAINTS.yaml — step 4. Registers scaffold_drift_check as the 12th required audit,
#                          with its question list. It is a build input now, hence in scope here.
#   (.ai/AGENTS.md is a build input too and is deliberately NOT declared — this session changed
#    no binding rule, and over-declaring it would fail the stale half of this check.)
DECLARED_BUILD_INPUT_CHANGES="build.rs src/cli/init.rs Cargo.toml .ai/CONSTRAINTS.yaml"
no_undeclared_build_input_change() {
  local base; base="$(git merge-base main HEAD 2>/dev/null)" || return 1
  [ -n "$base" ] || { echo "cannot resolve merge-base — a check that cannot evaluate FAILS"; return 1; }

  # Derivation 1: what the crate compiles from, straight out of git.
  local tree; tree="$(git ls-files src build.rs Cargo.toml 2>/dev/null)"
  [ -n "$tree" ] || { echo "derived tree inventory is EMPTY — the probe matched nothing"; return 1; }
  # Derivation 2: the governance files build.rs declares it reads. Read from build.rs, not typed.
  local rerun; rerun="$(grep -o 'cargo:rerun-if-changed=[^"]*' build.rs | sed 's/.*=//' | grep -v '^build.rs$')"
  [ -n "$rerun" ] || { echo "build.rs declares no rerun-if-changed sources — the probe matched nothing"; return 1; }
  echo "build inputs (DERIVED, not typed):"
  echo "  from git ls-files : $(echo "$tree" | wc -l | tr -d ' ') file(s)"
  echo "  from build.rs rerun-if-changed:"; echo "$rerun" | sed 's/^/    /'

  local inventory; inventory="$(printf '%s\n%s\n' "$tree" "$rerun" | sort -u)"
  local changed; changed="$(git diff --name-only "$base" HEAD | grep -Fx -f <(printf '%s\n' "$inventory") || true)"
  echo "build inputs changed vs $base:"; echo "${changed:-  (none)}" | sed 's/^/  /'

  local f
  for f in $changed; do
    case " $DECLARED_BUILD_INPUT_CHANGES " in
      *" $f "*) echo "  declared: $f" ;;
      *) echo "FAIL: UNDECLARED build-input change: $f"; return 1 ;;
    esac
  done
  for f in $DECLARED_BUILD_INPUT_CHANGES; do
    grep -qx "$f" <<<"$changed" || {
      echo "FAIL: declared file $f was never changed — the declaration is stale, not proven"; return 1; }
  done
  echo "OK: $(echo "$inventory" | wc -l | tr -d ' ') build inputs in the derived inventory; every change is declared."
}
run_check "no-undeclared-build-input-change" struct no_undeclared_build_input_change

# ══════════════════════════════════════════════════════════════════════════════════════════════
# CRITERIA 1-5, 7, 8 — the scaffold, in a real empty directory.
# ══════════════════════════════════════════════════════════════════════════════════════════════

# Criteria 1-4: is a stranger governed by what this repo is governed by, with every difference
# declared? Real empty dir, real git init, real binary, compared against the LIVE .ai/.
run_check "scaffold-drift-green" nested /bin/bash "$ROOT/scripts/scaffold-drift.sh" --bin "$VAJRA"

# Criterion 5: S128's four fixes do not regress, and criterion 6 of that suite now looks at the
# governance a stranger is handed.
run_check "stranger-check-green" nested /bin/bash "$ROOT/scripts/stranger-check.sh" --bin "$VAJRA"

# Criterion 7: five plants, each red through the check that OWNS it, plus a control that stays
# green. Includes the build-time half (a stale declaration must fail `cargo build`), which no
# shell check above can reach.
run_check "falsifiability-fixture" nested /bin/bash "$ROOT/scripts/fixture-session-129.sh"

# Criterion 8: the demo runs green.
run_check "demo-129-green" nested /bin/bash "$ROOT/scripts/demo-session-129.sh"

# The templates no longer CONTAIN the lists — they include the derived fragments. Structural by
# nature: this asserts the ARCHITECTURE (one source), and the drift check asserts the RESULT.
templates_are_derived() {
  local f="src/cli/init.rs"
  grep -q 'include_str!(concat!(env!("OUT_DIR"), "/scaffold_hard_rules.md"))' "$f" || {
    echo "MISSING: TPL_AGENTS no longer includes the derived Hard Rules fragment"; return 1; }
  grep -q 'include_str!(concat!(env!("OUT_DIR"), "/scaffold_ground_truth.yaml"))' "$f" || {
    echo "MISSING: TPL_CONSTRAINTS no longer includes the derived ground-truth fragment"; return 1; }
  # And no hand-typed twin left behind next to the include.
  grep -q '^| Max 2 retries |' "$f" && {
    echo "FAIL: the old hand-typed Hard Rules table is still in the template"; return 1; }
  grep -qE '^ *required_audits: \[' "$f" && {
    echo "FAIL: a hand-typed required_audits list is still in the template"; return 1; }
  echo "OK: both binding sets are included from OUT_DIR, with no hand-typed twin beside them."
}
run_check "templates-are-derived" struct templates_are_derived

# The audit that stops this class recurring is REGISTERED, with a question list that says what it
# is for and names the script that produces its evidence.
constraints_register_drift_audit() {
  local f=".ai/CONSTRAINTS.yaml"
  grep -E '^  required_audits:.*\bscaffold_drift_check\b' "$f" || {
    echo "MISSING: scaffold_drift_check is not in required_audits"; return 1; }
  grep -q '^  scaffold_drift_questions:' "$f" || { echo "MISSING: scaffold_drift_questions"; return 1; }
  grep -q 'scripts/scaffold-drift.sh' "$f" || {
    echo "MISSING: the question list does not name the script that produces the evidence"; return 1; }
  grep -q 'has any OTHER binding list grown a scaffolded twin' "$f" || {
    echo "MISSING: the question list does not ask the widening question"; return 1; }
}
run_check "constraints-registers-drift-audit" struct constraints_register_drift_audit

# The unit + integration suites. Run last: slowest, least surprising.
run_check "cargo-tests-green" exec cargo test --release --quiet

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 129 Verify Summary ==="
printf '%-44s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-44s %-7s %s\n' "--------------------------------------------" "-------" "------"
for r in ${RESULTS[@]+"${RESULTS[@]}"}; do echo "$r"; done
echo ""
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" ${NESTED_NAMES[@]+"${NESTED_NAMES[@]}"}
echo ""
echo "WHAT THIS SUITE NEVER EXERCISED — stated, not buried:"
echo "  * ANY user. 0 stars, 0 forks, 0 issues, 19 downloads. A stranger is now governed by the"
echo "    same 13 rules we are; nobody has asked for them."
echo "  * Every OTHER list in this repo. Only two were derived — Hard Rules and required_audits."
echo "    S128's lesson was that any list here may have a scaffolded twin; this session proved it"
echo "    for two and looked no further."
echo "  * ENFORCEMENT of the recovered rules. A stranger now READS all 13; what enforces them in"
echo "    their repo is the same hook set as before, untouched this session. Carrying a rule into"
echo "    a file is not the same as making it bite."
echo "  * The published crate. \`cargo package --list\` is asserted; nothing here runs"
echo "    \`cargo install vajractl\` from crates.io, and 0.1.0 there still predates all of this."
echo "  * banner-still-lists-seven is the one behavioral grep above — it reads a hardcoded usage"
echo "    string. no-eighth-command-exists is what actually proves the dispatch table."
echo '  * `vajra init` still blocking on stdin without EOF — known, unfixed, worked around with'
echo '    `</dev/null` in every script here.'
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, $FAIL fail)"
  exit 0
else
  echo "RED ($PASS pass, $FAIL fail)"
  exit 1
fi
