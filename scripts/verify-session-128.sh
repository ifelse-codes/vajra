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

# No gate's evidence contract moved — EXCEPT the one this session was ordered to move.
#
# The first cut of this check greped a HAND-TYPED list of eleven gate directories, and the cold
# reviewer called it the session's fakest green for two reasons, both correct: it passes if S128
# shipped nothing, and the list it typed omitted `src/cli/check.rs` — the one file whose evidence
# contract actually changed. The author drew the boundary and then measured inside it.
#
# Rewritten as a DECLARATION check. The module inventory is derived from the tree, never typed;
# every source file this session touched must be DECLARED here with a reason; and a declaration
# that names a file the diff never touched FAILS too, so the list cannot go stale into a pass.
#
# Declared, with why:
#   src/main.rs       — criteria 1-3. The front door's failure posture and the version flag.
#   src/cli/check.rs  — criterion 5. THIS ONE MOVES AN EVIDENCE CONTRACT, by design and by order:
#                       an ABSENT `vajra.varta` used to be a FAIL and is now a PASS. Stated here
#                       rather than hidden behind a boundary that could not see it.
DECLARED_SOURCE_CHANGES="src/main.rs src/cli/check.rs"
no_undeclared_source_change() {
  local base; base="$(git merge-base main HEAD 2>/dev/null)" || return 1
  [ -n "$base" ] || { echo "cannot resolve merge-base — a check that cannot evaluate FAILS"; return 1; }

  local modules; modules="$(ls -d src/*/ 2>/dev/null | sed 's:/$::')"
  [ -n "$modules" ] || { echo "derived module inventory is EMPTY — the probe matched nothing"; return 1; }
  echo "source modules in tree (DERIVED, not typed):"; echo "$modules" | sed 's/^/  /'

  local changed; changed="$(git diff --name-only "$base" HEAD | grep '^src/' || true)"
  echo "source files changed vs $base:"; echo "${changed:-  (none)}" | sed 's/^/  /'

  local f
  for f in $changed; do
    case " $DECLARED_SOURCE_CHANGES " in
      *" $f "*) echo "  declared: $f" ;;
      *) echo "FAIL: UNDECLARED source change: $f"; return 1 ;;
    esac
  done
  for f in $DECLARED_SOURCE_CHANGES; do
    grep -qx "$f" <<<"$changed" || {
      echo "FAIL: declared file $f was never changed — the declaration is stale, not proven"; return 1; }
  done
  echo "OK: $(echo "$modules" | wc -l | tr -d ' ') source modules in tree; every source change is declared."
}
run_check "no-undeclared-source-change" struct no_undeclared_source_change

# ══════════════════════════════════════════════════════════════════════════════════════════════
# CRITERIA 1-7, 9, 10 — the product, in a real empty directory.
# ══════════════════════════════════════════════════════════════════════════════════════════════

# Criteria 1-6: the whole of first contact, driven end to end against the real binary in a real
# empty directory. This is the ONLY instrument in this repo that measures the product rather than
# Vajra governing itself, which is exactly why the four defects survived 125 sessions.
run_check "stranger-check-green" nested /bin/bash "$ROOT/scripts/stranger-check.sh" --bin "$VAJRA"

# Criterion 9: the fixture. Plants each S128 defect back, one at a time, and demands the
# stranger-check go RED through the check that OWNS it — plus the control that renaming a
# message leaves it GREEN. Every plant asserts its own edit landed before the result is trusted.
run_check "falsifiability-fixture" nested /bin/bash "$ROOT/scripts/fixture-session-128.sh"

# Criterion 10: the demo runs green.
run_check "demo-128-green" nested /bin/bash "$ROOT/scripts/demo-session-128.sh"

# Criterion 7: the audit that stops this class recurring is REGISTERED, with a question list that
# says what it is for. Structural by nature — a YAML entry has no runtime output to exercise.
constraints_register_stranger_audit() {
  local f=".ai/CONSTRAINTS.yaml"
  grep -E '^  required_audits:.*\bstranger_check\b' "$f" || {
    echo "MISSING: stranger_check is not in required_audits"; return 1; }
  grep -q '^  stranger_questions:' "$f" || { echo "MISSING: stranger_questions"; return 1; }
  grep -q 'measures the PRODUCT a stranger downloads' "$f" || {
    echo "MISSING: the question list does not say plainly what the audit is for"; return 1; }
  grep -q 'scripts/stranger-check.sh' "$f" || {
    echo "MISSING: the question list does not name the script that produces the evidence"; return 1; }
}
run_check "constraints-registers-stranger-audit" struct constraints_register_stranger_audit

# The unit + integration suites, including the four varta states and the real-binary front-door
# tests. Run last: it is the slowest and the least surprising.
run_check "cargo-tests-green" exec cargo test --release --quiet

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session 128 Verify Summary ==="
printf '%-42s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-42s %-7s %s\n' "------------------------------------------" "-------" "------"
for r in ${RESULTS[@]+"${RESULTS[@]}"}; do echo "$r"; done
echo ""
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" ${NESTED_NAMES[@]+"${NESTED_NAMES[@]}"}
echo ""
echo "WHAT THIS SUITE NEVER EXERCISED — stated, not buried:"
echo "  * ANY user. 0 stars, 0 forks, 0 issues, 19 downloads. A front door that works is a"
echo "    precondition for adoption; it is not evidence of adoption, and nothing here claims it."
echo "  * The scaffolded constitution, still a hand-maintained fork (66 lines vs this repo's 183)."
echo "    Deliberately out of scope this session, and it is the biggest thing a stranger still"
echo "    gets wrong."
echo "  * Any shell that is not this host's /bin/bash. Criterion 4 FAILS rather than passes on a"
echo "    host whose bash lacks 3.2 empty-array semantics — but a green here proves ONE shell."
echo "  * Whether a future ground-truth session actually RUNS stranger_check. The registration is"
echo "    proven; the running is not, and it is the same self-granted-jurisdiction class as S68."
# NOTE the single quotes: an unescaped backtick inside a double-quoted echo is a COMMAND
# SUBSTITUTION. The first cut of these two lines actually RAN `vajra init` in this repo and
# hung the whole suite on its stdin prompt. A disclosure line that executes is its own joke.
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
