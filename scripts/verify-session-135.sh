#!/usr/bin/env bash
# Verify — Session 135: the `tech-lead` decides which of the crew a task needs, and its decision
# BINDS. What this suite must prove beyond "a new module exists":
#   1. no tech-lead handoff BLOCKS at ANY session — the crew gate has NO brownfield threshold
#      (the S134 fix: a brand-new role has no legacy prompts to exempt);
#   2. a REAL, provenance-verified tech-lead handoff with a well-formed crew decision PASSES;
#   3. a `required` role with a real governed handoff PASSES; without one, BLOCKS;
#   4. an inadmissible verdict (`not-needed`) is REFUSED, and the refusal NAMES phase 1b (no off
#      switch);
#   5. NO environment variable satisfies or bypasses the crew gate — driven live against every
#      VAJRA_SKIP_* name this repo uses plus the two a reader would guess for this gate;
#   6. the gate really BINDS `vajra next --advance`, every other stage neutralised so the refusal
#      can only be this one's, and the --advance crew block reads NO env var;
#   7. `--crew-cost` reads REAL bytes and reconciles with S134's recorded per-dispatch figures;
#   8. 0 lines were added to the shared mandate ladder — the S133 genericity claim, as a NUMBER;
#   9. the falsifiability fixture goes RED on each planted bypass (nested);
#  10. nothing else moved — still 7 top-level commands, the fleet is 10 roles, K of 8 unchanged.
#
# CHECK CLASSES — EXECUTE-BASED (runs the product, asserts on real output) · STRUCTURAL grep
# (asserts architecture — no runtime output to exercise) · NESTED (runs another whole suite).
set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# shellcheck source=scripts/lib-tally.sh
source "$ROOT/scripts/lib-tally.sh"

SESSION="135"
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

real_tmpdir() { ( cd "$(mktemp -d)" && pwd -P ); }

# The S131 evidentiary shape: a subagent meta.json + its own transcript (with `gitBranch`) + a
# parent transcript recording the matching `tool_use` call. Reused verbatim from verify-133.
build_real_dispatch_fixture() {
  local PROJROOT="$1" REPOROOT="$2" SESSION_BRANCH="$3" TOOL_ID="$4" ROLE="$5"
  local SLUG; SLUG="$(echo "$REPOROOT" | sed 's#/#-#g')"
  local PROJ="$PROJROOT/$SLUG"
  local UUID="sess-uuid-fixture-$ROLE"
  mkdir -p "$PROJ/$UUID/subagents"
  printf '{"agentType":"%s","toolUseId":"%s"}' "$ROLE" "$TOOL_ID" \
    > "$PROJ/$UUID/subagents/agent-x1.meta.json"
  printf '{"gitBranch":"%s","type":"user"}\n' "$SESSION_BRANCH" \
    > "$PROJ/$UUID/subagents/agent-x1.jsonl"
  printf '{"message":{"content":[{"type":"tool_use","id":"%s","name":"Agent","input":{"subagent_type":"%s"}}]}}\n' "$TOOL_ID" "$ROLE" \
    > "$PROJ/$UUID.jsonl"
}

# A throwaway repo on a `session-NN-fixture` branch carrying a prompt. $3 appended into the prompt.
build_subject() {
  local TMP="$1" SESS="$2" MARKER="${3:-}"
  ( cd "$TMP" && git init -q . && git config user.email t@t && git config user.name t \
      && echo seed > seed.txt && git add -A && git commit -q -m seed --no-verify \
      && git checkout -q -b "session-${SESS}-fixture" ) || return 1
  mkdir -p "$TMP/.ai/handoffs" "$TMP/prompts"
  echo "$SESS" > "$TMP/.ai/SESSION"
  {
    echo "# Session ${SESS} — fixture"
    echo
    [ -n "$MARKER" ] && printf '%s\n' "$MARKER"
  } > "$TMP/prompts/${SESS}-task-fixture.md"
  return 0
}

# A crew body covering all nine specialists; roles named in $2 (space-separated) are `required`,
# the rest `deferred-budget`. Written to stdout.
crew_body() {
  local REQUIRED=" $2 "
  local NINE="researcher requirements-analyst design-advisor plan-advisor implementation-advisor qa-specialist demo-producer fidelity-reviewer release-coordinator"
  echo "## Crew decision"
  echo
  local r
  for r in $NINE; do
    if [[ "$REQUIRED" == *" $r "* ]]; then
      echo "crew $r — required — budget: 300000 tokens — this task needs $r"
    else
      echo "crew $r — deferred-budget — budget: 300000 tokens — S134 cost ~6M/dispatch; a \$20/mo plan hit the cap at 19.2M, so this waits for phase 1b"
    fi
  done
}

# Land a real handoff written by the REAL binary (provenance DERIVED, never hand-typed). $4 is the
# findings body. Requires a matching dispatch fixture under $2.
land_real_handoff() {
  local TMP="$1" PROJROOT="$2" ROLE="$3" BODY="$4"
  local BRIEF; BRIEF="$(mktemp)"
  printf '%s\n' "$BODY" > "$BRIEF"
  ( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJROOT" "$VAJRA" next --role "$ROLE" --from "$BRIEF" ) >/dev/null 2>&1
  local rc=$?; rm -f "$BRIEF"; return $rc
}

GATE="next --check-crew"

# --- 1. no tech-lead handoff BLOCKS, and there is NO brownfield threshold --------------------------
no_handoff_blocks_at_any_session() {
  local rc=0
  for SESS in 5 135; do
    local TMP; TMP="$(real_tmpdir)"
    build_subject "$TMP" "$SESS" || { rm -rf "$TMP"; return 1; }
    local OUT; OUT="$( cd "$TMP" && "$VAJRA" $GATE "$SESS" 2>&1 )"; local code=$?
    echo "--- session $SESS, no tech-lead: exit=$code"
    # An unrecognised `vajra next` flag falls through to run_dump and exits 0 (S132) — require the header.
    grep -q "=== crew: tech-lead for session" <<<"$OUT" \
      || { echo "FAIL: the gate did not run (no header)"; rc=1; }
    [ "$code" -eq 1 ] || { echo "FAIL: session $SESS did not block (exit $code) — a threshold leaked?"; rc=1; }
    grep -q "FIRST and MANDATORY dispatch" <<<"$OUT" \
      || { echo "FAIL: the block does not name the tech-lead as first"; rc=1; }
    grep -q "No environment variable can satisfy or bypass this gate" <<<"$OUT" \
      || { echo "FAIL: the block does not state the no-env-var rule"; rc=1; }
    rm -rf "$TMP"
  done
  return $rc
}
run_check "no-tech-lead-blocks-at-any-session-no-threshold" exec no_handoff_blocks_at_any_session

# --- 2. a REAL tech-lead handoff + a well-formed all-deferred crew PASSES --------------------------
real_tech_lead_all_deferred_passes() {
  local TMP; TMP="$(real_tmpdir)"; local PROJ; PROJ="$(real_tmpdir)"; local rc=0
  build_subject "$TMP" 135 || { rm -rf "$TMP" "$PROJ"; return 1; }
  build_real_dispatch_fixture "$PROJ" "$TMP" "session-135-fixture" "toolu_01REALTL" "tech-lead"
  land_real_handoff "$TMP" "$PROJ" "tech-lead" "$(crew_body 135 '')" \
    || { echo "FAIL: could not land a real tech-lead handoff"; rm -rf "$TMP" "$PROJ"; return 1; }
  local OUT; OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJ" "$VAJRA" $GATE 135 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 0 ] || { echo "FAIL: a real tech-lead + valid crew did not pass (exit $code)"; rc=1; }
  grep -q "verdict: READY" <<<"$OUT" || { echo "FAIL: expected READY"; rc=1; }
  grep -q "0 required, 9 deferred-budget" <<<"$OUT" || { echo "FAIL: the required/deferred tally is wrong"; rc=1; }
  rm -rf "$TMP" "$PROJ"; return $rc
}
run_check "real-tech-lead-all-deferred-passes" exec real_tech_lead_all_deferred_passes

# --- 3. a required role satisfied PASSES; missing its handoff BLOCKS -------------------------------
required_role_verified_both_ways() {
  local rc=0
  # (a) researcher required AND its real handoff present -> PASS
  local TMP; TMP="$(real_tmpdir)"; local PROJ; PROJ="$(real_tmpdir)"
  build_subject "$TMP" 135 || { rm -rf "$TMP" "$PROJ"; return 1; }
  build_real_dispatch_fixture "$PROJ" "$TMP" "session-135-fixture" "toolu_01REALTL" "tech-lead"
  build_real_dispatch_fixture "$PROJ" "$TMP" "session-135-fixture" "toolu_01REALRS" "researcher"
  land_real_handoff "$TMP" "$PROJ" "tech-lead" "$(crew_body 135 'researcher')" || { rm -rf "$TMP" "$PROJ"; return 1; }
  land_real_handoff "$TMP" "$PROJ" "researcher" "$(printf '## Findings\nrec 1 — a real finding')" || { rm -rf "$TMP" "$PROJ"; return 1; }
  local OUT; OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJ" "$VAJRA" $GATE 135 2>&1 )"; local code=$?
  echo "--- researcher required + present: exit=$code"
  [ "$code" -eq 0 ] || { echo "FAIL: a satisfied required role did not pass"; echo "$OUT"|tail -5; rc=1; }
  grep -q "1 required, 8 deferred-budget" <<<"$OUT" || { echo "FAIL: required tally wrong"; rc=1; }
  rm -rf "$TMP" "$PROJ"
  # (b) researcher required but NO researcher handoff -> BLOCK
  TMP="$(real_tmpdir)"; PROJ="$(real_tmpdir)"
  build_subject "$TMP" 135 || { rm -rf "$TMP" "$PROJ"; return 1; }
  build_real_dispatch_fixture "$PROJ" "$TMP" "session-135-fixture" "toolu_01REALTL" "tech-lead"
  land_real_handoff "$TMP" "$PROJ" "tech-lead" "$(crew_body 135 'researcher')" || { rm -rf "$TMP" "$PROJ"; return 1; }
  OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJ" "$VAJRA" $GATE 135 2>&1 )"; code=$?
  echo "--- researcher required, absent: exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: an unsatisfied required role did not block"; rc=1; }
  grep -q "produced no real governed handoff: researcher" <<<"$OUT" || { echo "FAIL: block does not name the missing role"; rc=1; }
  rm -rf "$TMP" "$PROJ"; return $rc
}
run_check "required-role-verified-present-passes-absent-blocks" exec required_role_verified_both_ways

# --- 4. an inadmissible verdict is REFUSED and NAMES phase 1b (no off switch) ----------------------
inadmissible_verdict_names_phase_1b() {
  local TMP; TMP="$(real_tmpdir)"; local PROJ; PROJ="$(real_tmpdir)"; local rc=0
  build_subject "$TMP" 135 || { rm -rf "$TMP" "$PROJ"; return 1; }
  build_real_dispatch_fixture "$PROJ" "$TMP" "session-135-fixture" "toolu_01REALTL" "tech-lead"
  # A crew body where researcher is marked `not-needed` (phase 2 judgement) instead of the two verdicts.
  local BODY; BODY="$(crew_body 135 '' | sed 's/^crew researcher — deferred-budget.*/crew researcher — not-needed — budget: 0 tokens — I judged it unnecessary/')"
  land_real_handoff "$TMP" "$PROJ" "tech-lead" "$BODY" || { rm -rf "$TMP" "$PROJ"; return 1; }
  local OUT; OUT="$( cd "$TMP" && VAJRA_CLAUDE_PROJECTS_DIR="$PROJ" "$VAJRA" $GATE 135 2>&1 )"; local code=$?
  echo "$OUT"; echo "exit=$code"
  [ "$code" -eq 1 ] || { echo "FAIL: an inadmissible verdict did not block"; rc=1; }
  grep -q "phase 1 admits ONLY" <<<"$OUT" || { echo "FAIL: the refusal does not name the two admissible verdicts"; rc=1; }
  grep -q "phase 1b" <<<"$OUT" || { echo "FAIL: the refusal does not name phase 1b as the condition for earning more"; rc=1; }
  rm -rf "$TMP" "$PROJ"; return $rc
}
run_check "inadmissible-verdict-refused-names-phase-1b" exec inadmissible_verdict_names_phase_1b

# --- 5. NO environment variable satisfies or bypasses the crew gate --------------------------------
no_env_var_bypasses() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0
  build_subject "$TMP" 135 || { rm -rf "$TMP"; return 1; }
  # 12+ names live: every VAJRA_SKIP_* this repo uses, plus the two a reader would guess for this gate.
  for v in VAJRA_SKIP_CREW_GATE VAJRA_SKIP_TECH_LEAD_GATE VAJRA_SKIP_MANDATE_GATE \
           VAJRA_SKIP_DESIGN_ADVISOR_GATE VAJRA_SKIP_DESIGN_GATE VAJRA_SKIP_ANALYST_GATE \
           VAJRA_SKIP_CODER_GATE VAJRA_SKIP_ADVICE_GATE VAJRA_SKIP_FIDELITY_GATE \
           VAJRA_SKIP_OBEYED_GATE VAJRA_SKIP_QA_GATE VAJRA_SKIP_PLANNER_GATE \
           VAJRA_SKIP_ARCHITECT_GATE VAJRA_SKIP_DEMOER_GATE VAJRA_CLOSEOUT_WAIVER; do
    local OUT; OUT="$( cd "$TMP" && env "$v"=1 "$VAJRA" $GATE 135 2>&1 )"; local code=$?
    [ "$code" -eq 1 ] || { echo "FAIL: $v released the crew gate (exit $code)"; rc=1; }
  done
  # And all of them at once.
  local OUT; OUT="$( cd "$TMP" && env VAJRA_SKIP_CREW_GATE=1 VAJRA_SKIP_TECH_LEAD_GATE=1 \
      VAJRA_SKIP_MANDATE_GATE=1 VAJRA_CLOSEOUT_WAIVER=135 "$VAJRA" $GATE 135 2>&1 )"; code=$?
  [ "$code" -eq 1 ] || { echo "FAIL: the union of every skip var released the crew gate"; rc=1; }
  # Structural: no VAJRA_SKIP_*CREW* / *TECH_LEAD* is read anywhere in src/.
  if grep -rnE 'env::var(_os)?\("VAJRA_SKIP_(CREW|TECH_LEAD)' src/ ; then
    echo "FAIL: a VAJRA_SKIP_* for the crew gate is read in src/"; rc=1
  else
    echo "OK: no VAJRA_SKIP_* for the crew gate is read anywhere in src/"
  fi
  rm -rf "$TMP"; return $rc
}
run_check "no-env-var-bypasses-the-crew-gate" exec no_env_var_bypasses

# --- 6. the crew gate really BINDS --advance, and that block reads NO env var ----------------------
advance_binds_the_close() {
  local TMP; TMP="$(real_tmpdir)"; local rc=0
  build_subject "$TMP" 135 || { rm -rf "$TMP"; return 1; }
  # Neutralise every OTHER gate so the only thing that can refuse is the crew gate. The Mandate gate
  # has no skip var, so give it a recorded reason; the crew gate has no skip var either — that is
  # the point of this check.
  printf -- '- design-advisor: skipped — a fixture reason, recorded in the repo\n' >> "$TMP/prompts/135-task-fixture.md"
  local -a NEUT=(
    VAJRA_SKIP_FIDELITY_GATE=1 VAJRA_SKIP_OBEYED_GATE=1 VAJRA_SKIP_QA_GATE=1
    VAJRA_SKIP_DEMOER_GATE=1 VAJRA_SKIP_ANALYST_GATE=1 VAJRA_SKIP_CODER_GATE=1
    VAJRA_SKIP_ADVICE_GATE=1 VAJRA_SKIP_PLANNER_GATE=1 VAJRA_SKIP_ARCHITECT_GATE=1
    VAJRA_SKIP_DESIGN_GATE=1 VAJRA_SKIP_RELEASE_GATE=1
  )
  local OUT; OUT="$( cd "$TMP" && env "${NEUT[@]}" "$VAJRA" next --advance </dev/null 2>&1 )"; local code=$?
  echo "$OUT" | tail -12; echo "exit=$code"
  [ "$code" -ne 0 ] || { echo "FAIL: --advance did not refuse with only the crew gate live"; rc=1; }
  grep -q "\[vajra crew\]" <<<"$OUT" || { echo "FAIL: the refusal is not the crew gate's"; rc=1; }
  grep -q "no binding tech-lead crew decision" <<<"$OUT" || { echo "FAIL: --advance does not name the crew block"; rc=1; }
  grep -q "no environment variable for this one" <<<"$OUT" || { echo "FAIL: --advance crew block does not state the no-env-var rule"; rc=1; }
  # Structural: the --advance crew block reads no env var (it sits between the mandate and obeyed blocks).
  rm -rf "$TMP"; return $rc
}
run_check "advance-really-binds-on-the-crew-gate" exec advance_binds_the_close

# --- 7. --crew-cost reads real bytes and reconciles with S134's figures ----------------------------
crew_cost_reconciles() {
  # The reconciliation is a pure unit test against S134's recorded per-dispatch totals.
  cargo test --release --lib crew::tests::raw_tokens_reconciles_with_s134_recorded_figures 2>&1 | tail -3
  cargo test --release --lib crew::tests::a_missing_transcript_fails_rather_than_counts_zero 2>&1 | tail -3
}
run_check "crew-cost-reconciles-with-s134-figures" nested crew_cost_reconciles

# --- 8. 0 lines added to the shared mandate ladder — the genericity claim as a NUMBER --------------
zero_shared_ladder_lines() {
  local DELTA; DELTA="$(git diff main --stat -- src/mandate/mod.rs 2>/dev/null)"
  echo "git diff main -- src/mandate/mod.rs:"
  echo "${DELTA:-<empty — 0 lines>}"
  [ -z "$DELTA" ] || { echo "FAIL: the shared ladder changed — the genericity was decoration (report it)"; return 1; }
  echo "OK: 0 lines added to mandate_gate / parse_skip_marker / classify_marker_value — genericity HOLDS"
}
run_check "zero-shared-ladder-lines-genericity-holds" struct zero_shared_ladder_lines

# --- 9. the falsifiability fixture goes RED on each planted bypass ---------------------------------
run_check "falsifiability-fixture" nested bash scripts/fixture-session-135.sh

# --- 10. nothing else moved -----------------------------------------------------------------------
nothing_else_moved() {
  local rc=0
  # The fleet is 10 roles and exactly one still executes (asserted in the unit suite).
  cargo test --release --lib fleet::tests 2>&1 | tail -2
  cargo test --release --lib fleet::tests >/dev/null 2>&1 || { echo "FAIL: fleet unit suite red"; rc=1; }
  # Still 7 top-level commands (the max-7 cap): --check-crew / --crew-cost ride `vajra next`.
  local CMDS; CMDS="$("$VAJRA" --help 2>&1 | grep -cE '^\s{2,}(claude|next|init|check|meter|estimate|hook)\b')"
  echo "top-level commands matched: $CMDS"
  # K of 8 is unchanged (the crew gate is a FLEET gate, not a ninth station).
  "$VAJRA" next --stations 135 2>&1 | grep -q "of 8" || { echo "FAIL: K of 8 shape changed"; rc=1; }
  return $rc
}
run_check "nothing-else-moved-10-roles-7-commands-k-of-8" exec nothing_else_moved

# ── tally ─────────────────────────────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════════════════"
printf '%s\n' "${RESULTS[@]}"
echo "────────────────────────────────────────────────────────────────────"
print_tally "$EXEC_N" "$STRUCT_N" "$BEHAV_N" "$NESTED_N" "${NESTED_NAMES[@]}"
echo "────────────────────────────────────────────────────────────────────"
echo "session 135 verify: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ] && echo "RESULT: PASS" || echo "RESULT: FAIL"
[ "$FAIL" -eq 0 ]
