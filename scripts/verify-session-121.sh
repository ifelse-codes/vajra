#!/usr/bin/env bash
# Verify — Session 121: the fleet's FOURTH role, the QA Specialist (founder pick at the S120 GT).
#
# Same shape as verify-session-116.sh (the third role), with one difference this session must not
# duck. S120's GT named the disease these checks can carry: a BEHAVIORAL SOURCE GREP — greping src/
# for a message string and calling that proof a feature works — passes even if the feature is
# deleted and only the string survives. The role built here exists to catch exactly that, so this
# script classifies its OWN checks, in the same two classes the role's contract uses:
#
#   EXECUTE-BASED   — runs the product (the binary, cargo test, a script) and asserts on real output.
#   STRUCTURAL grep — asserts ARCHITECTURE (one source of truth, no second copy, no key collision,
#                     a file's absence). Legitimate: there is no output to run for "this text exists
#                     in exactly one place".
#   BEHAVIORAL grep — the hollow class. Aimed for ZERO here; any that survive are named in the
#                     summary and in the session's fakest-green disclosure.
#
# The tally is printed at the end so it cannot be quietly claimed in prose only.
#
# KNOWN, DISCLOSED: verify-session-116.sh's `init-scaffolds-three-roles` and `test-roles-read-only`
# go RED by construction against this branch — the fleet grew to four, and the every-role-is-
# read-only invariant was DELIBERATELY changed at S121 (DECISION-007 S121 addendum), which is why
# that test was renamed rather than quietly loosened. Same reasoning S116 recorded for S114's
# `scaffolds_two_roles`: those scripts are historical snapshots of their session's world, not living
# regression suites. The role-COUNT-AGNOSTIC ones (S113's counter suite, fleet-smoke.sh) ARE re-run
# below, unchanged, and must stay green.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="121"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
EXEC_N=0; STRUCT_N=0; BEHAV_N=0
# $1 = check name, $2 = class (exec|struct|behav), rest = the command.
run_check() {
  local NAME="$1"; local CLASS="$2"; shift 2
  local LOG="$ARTIFACTS/${NAME}.log"
  case "$CLASS" in
    exec)   EXEC_N=$((EXEC_N+1)) ;;
    struct) STRUCT_N=$((STRUCT_N+1)) ;;
    behav)  BEHAV_N=$((BEHAV_N+1)) ;;
    *) echo "verify bug: unknown class '$CLASS' for $NAME"; exit 2 ;;
  esac
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %-7s %s' "$NAME" "$CLASS" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %-7s %s' "$NAME" "$CLASS" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- toolchain: unchanged discipline ----------------------------------------------------------
run_check "cargo-build"   exec cargo build --all-targets
run_check "cargo-test"    exec cargo test --lib
run_check "cargo-fmt"     exec cargo fmt -- --check
run_check "cargo-clippy"  exec cargo clippy --all-targets -- -D warnings

# The role-count-agnostic regressions: a fourth role does not get to move what the fleet already
# guarantees. (S113 tests the counter MECHANISM and never asserts "exactly N roles"; fleet-smoke
# exercises the researcher path only.)
run_check "fleet-smoke"              exec bash scripts/fleet-smoke.sh
run_check "s113-counter-still-green" exec bash scripts/verify-session-113.sh

VAJRA="$ROOT/target/debug/vajra"

# `cargo test --lib <filter>` EXITS 0 WHEN THE FILTER MATCHES NOTHING (S112 pass 2) — a bare
# filtered run names a lock it does not hold. Reused verbatim, as required.
named_test_passed() {
  local out; out="$(cargo test --lib "$1" 2>&1)"
  echo "$out"
  grep -qE 'test result: ok\. [1-9][0-9]* passed' <<<"$out" \
    || { echo "FAIL: filter '$1' matched no test that ran and passed"; return 1; }
}
run_check "test-role-registered" exec \
  named_test_passed fleet::tests::qa_specialist_is_registered_with_a_non_colliding_key_and_the_execution_grant
run_check "test-execution-allowlist" exec \
  named_test_passed fleet::tests::tool_grants_are_per_role_and_execution_is_the_qa_specialists_alone
run_check "test-delta-names-role" exec \
  named_test_passed fleet::tests::compute_delta_names_the_producing_role_not_a_hardcoded_one
run_check "test-render-every-role" exec \
  named_test_passed fleet::tests::render_subagent_definition_is_correct_for_every_registered_role
# The guard on the guard: a filter matching nothing must FAIL, or every check above is theatre.
filter_guard_has_teeth() {
  if named_test_passed fleet::tests::this_test_does_not_exist_on_purpose >/dev/null 2>&1; then
    echo "FAIL: named_test_passed is green on a filter that matches no test"; return 1
  fi
  echo "OK: a filter matching zero tests fails, as it must"
}
run_check "test-filter-guard-has-teeth" exec filter_guard_has_teeth

strip_fleet() { grep -vE '^[[:space:]]*(⚠ )?fleet:'; }

# --- criteria 1 + 2: a fresh `vajra init` scaffolds FOUR agent files, one of which EXECUTES -------
# Proven by RUNNING init and asserting on what it produced — never by reading src/cli/init.rs.
scaffolds_four_roles() { local TMP; TMP="$(mktemp -d)"; _scaffolds_four_roles "$TMP"; local rc=$?; rm -rf "$TMP"; return $rc; }
_scaffolds_four_roles() {
  local TMP="$1"
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null ) || { echo "vajra init failed"; return 1; }
  echo "--- scaffolded agents ---"; ls -1 "$TMP/.claude/agents/"

  local N; N="$(find "$TMP/.claude/agents" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
  [ "$N" = "4" ] || { echo "FAIL: expected 4 scaffolded agent files, got $N"; return 1; }
  for f in researcher fidelity-reviewer plan-advisor qa-specialist; do
    [ -f "$TMP/.claude/agents/$f.md" ] || { echo "FAIL: $f not scaffolded"; return 1; }
  done

  # The scaffolded qa-specialist carries the CONTRACT, not a stub: run it, classify every check,
  # name the hollow ones, never repair what you tested, never silently skip.
  local F="$TMP/.claude/agents/qa-specialist.md"
  grep -q "^name: qa-specialist$" "$F" || { echo "FAIL: wrong subagent name"; return 1; }
  grep -q 'scripts/verify-session-NN.sh' "$F" || { echo "FAIL: it is not told to run the verify script"; return 1; }
  grep -q 'BEHAVIORAL SOURCE GREP' "$F" || { echo "FAIL: no hollow-check classification contract"; return 1; }
  grep -q 'EXECUTE-BASED' "$F" || { echo "FAIL: no execute-based classification contract"; return 1; }
  grep -q 'do NOT repair the checks you criticise' "$F" || { echo "FAIL: the independence rule is missing"; return 1; }
  grep -q 'a check that cannot evaluate fails' "$F" || { echo "FAIL: the fail-closed rule is missing"; return 1; }
  grep -q "vajra next --role qa-specialist --from" "$F" || { echo "FAIL: wrong handoff command"; return 1; }

  # CRITERION 2, the load-bearing half: this role EXECUTES, and it is the ONLY one that does.
  grep -q "^tools: Bash, Read, Write, Edit, Grep, Glob$" "$F" \
    || { echo "FAIL: the qa-specialist tool grant is not the recorded execution grant"; return 1; }
  local NEXEC; NEXEC="$(grep -lE '^tools:.*Bash' "$TMP/.claude/agents/"*.md | wc -l | tr -d ' ')"
  echo "scaffolded roles granted Bash: $NEXEC"
  [ "$NEXEC" = "1" ] || { echo "FAIL: $NEXEC roles were granted Bash; the allowlist is exactly one"; return 1; }
  for f in researcher fidelity-reviewer plan-advisor; do
    grep -q "^tools: Read, Grep, Glob" "$TMP/.claude/agents/$f.md" \
      || { echo "FAIL: $f is no longer read-only — the grant leaked past the allowlist"; return 1; }
  done
  # No role got the web-plus-everything grant by accident.
  if grep -qE '^tools:.*NotebookEdit' "$TMP/.claude/agents/"*.md; then
    echo "FAIL: a role was granted NotebookEdit"; return 1
  fi

  # This repo's committed copies must be exactly what init renders — a rendering, not a duplicate.
  for f in researcher.md fidelity-reviewer.md plan-advisor.md qa-specialist.md; do
    diff -u "$TMP/.claude/agents/$f" "$ROOT/.claude/agents/$f" \
      || { echo "FAIL: the repo's $f has drifted from the render"; return 1; }
  done

  # EXACTLY the rendered set — a hand-written extra file would be a real, boot-loadable, second
  # source of role text sitting in the one place nothing looks (S114 cold-review finding).
  local REPO_AGENTS RENDERED
  REPO_AGENTS="$(cd "$ROOT/.claude/agents" && ls -1 | sort)"
  RENDERED="$(cd "$TMP/.claude/agents" && ls -1 | sort)"
  echo "--- repo .claude/agents/ ---"; echo "$REPO_AGENTS"
  if [ "$REPO_AGENTS" != "$RENDERED" ]; then
    echo "FAIL: .claude/agents/ holds files vajra init does not render — a hand-maintained agent definition is a second source"
    diff <(echo "$RENDERED") <(echo "$REPO_AGENTS"); return 1
  fi
  echo "OK: four roles scaffolded byte-identical to this repo's copies; exactly one grants Bash"
  return 0
}
run_check "init-scaffolds-four-roles" exec scaffolds_four_roles

# --- the no-second-source guard (with its positive control) -------------------------------------
# STRUCTURAL by nature: the claim is "this text exists in exactly one hand-maintained file", which
# has no runtime behaviour to exercise. The probe sentence sits UNBROKEN on one Rust source line —
# a phrase split across a `\`-continuation is invisible to grep (the S114 trap).
one_source_of_role_text() {
  local PROBE="Fixing what you just tested destroys the independence"
  local HITS
  HITS="$(grep -rl "$PROBE" . 2>/dev/null \
            | grep -v '^\./target/' | grep -v '^\./\.git/' | grep -v '^\./\.ai/verify/' \
            | grep -v '^\./\.claude/agents/' | grep -v '^\./docs/decisions/' \
            | grep -v '^\./sessions/' | grep -v '^\./scripts/verify-session-121\.sh$' | sort)"
  echo "carriers of the qa-specialist prompt text:"; echo "$HITS"
  grep -q '^\./src/fleet/mod\.rs$' <<<"$HITS" \
    || { echo "FAIL: the pattern does not even match the canonical source — it proves nothing"; return 1; }
  local N; N="$(grep -c . <<<"$HITS")"
  [ "$N" = "1" ] || { echo "FAIL: role text lives in $N places, not 1"; return 1; }
  echo "OK: the qa-specialist's prompt text exists in exactly one hand-maintained file"
  return 0
}
run_check "one-source-of-role-text" struct one_source_of_role_text

# --- criterion 3, END-TO-END in a throwaway repo -------------------------------------------------
# Fail-closed for the new role, the key collision, then FOUR governed handoffs in one session.
e2e_four_handoffs() { local TMP; TMP="$(mktemp -d)"; _e2e_four_handoffs "$TMP"; local rc=$?; rm -rf "$TMP"; return $rc; }
_e2e_four_handoffs() {
  local TMP="$1"
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null ) || { echo "vajra init failed"; return 1; }
  echo "121" > "$TMP/.ai/SESSION"

  mkdir -p "$TMP/prompts"
  cat > "$TMP/prompts/121-task-fixture.md" <<'FIXTURE'
# Session 121 — fixture

## Acceptance
1. **WHEN** four roles have governed handoffs **THEN** the counter names all four
2. **WHEN** the qa-specialist role is unknown **THEN** the writer fails closed

## Design
- design-significant: no

## Plan
1. register the fourth role. covers: 1
2. govern its handoff. covers: 2

## Delta
- `+` the fleet's fourth named role, the first that executes
FIXTURE

  local BEFORE; BEFORE="$(cd "$TMP" && "$VAJRA" next --stations 121 2>&1)" || { echo "--stations failed"; return 1; }
  echo "--- BEFORE (no fleet work) ---"; echo "$BEFORE"
  grep -qi "fleet" <<<"$BEFORE" && { echo "FAIL: fleet mentioned with no handoff"; return 1; }
  grep -qE "^  [1-9] of 8 stations passed" <<<"$BEFORE" \
    || { echo "FAIL: fixture has 0 passing stations — the byte-identity check would be vacuous"; return 1; }

  # --- fail-closed: the collision word + the standard three ---
  printf 'QA: ran verify-session-121.sh, exit 0. 18 checks: 15 execute-based, 3 structural.\n' > "$TMP/qa.md"
  : > "$TMP/empty.md"
  ( cd "$TMP" && "$VAJRA" next --role qa --from qa.md ) >/dev/null 2>&1 \
    && { echo "FAIL: the bare key 'qa' was accepted — the collision was not resolved"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role qa-specialist ) >/dev/null 2>&1 \
    && { echo "FAIL: --role without --from was accepted"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role qa-specialist --from empty.md ) >/dev/null 2>&1 \
    && { echo "FAIL: empty findings were accepted"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role qa-specialist --from nope.md ) >/dev/null 2>&1 \
    && { echo "FAIL: a missing findings file was accepted"; return 1; }
  echo "OK: unknown role (the collision word) · missing --from · empty findings · missing file all fail closed"

  # --- the real writer, all four roles ---
  printf 'ANSWER: ANTHROPIC_API_KEY is the only auth that survives a fresh no-TTY shell.\n' > "$TMP/findings.md"
  printf 'VERDICT: ACCEPT. 6 of 6 requirements SHIPPED.\nFakest green: the counter counts files, not agents.\n' > "$TMP/review.md"
  printf 'PLAN: 1. do the thing — covers: 1\n2. do the other thing — covers: 2\n' > "$TMP/plan.md"
  ( cd "$TMP" && "$VAJRA" next --role researcher --from findings.md ) >/dev/null \
    || { echo "researcher handoff failed"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer --from review.md ) >/dev/null \
    || { echo "reviewer handoff failed"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role plan-advisor --from plan.md ) >/dev/null \
    || { echo "plan-advisor handoff failed"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role qa-specialist --from qa.md ) >/dev/null \
    || { echo "qa-specialist handoff failed"; return 1; }

  local H="$TMP/.ai/handoffs/session-121-qa-specialist.md"
  [ -f "$H" ] || { echo "FAIL: the qa-specialist handoff is not at the contract path"; return 1; }
  echo "--- qa-specialist handoff ---"; cat "$H"
  grep -q "^role: qa-specialist$" "$H" || { echo "FAIL: handoff role frontmatter wrong"; return 1; }
  grep -qE "^source-sha: [0-9a-f]{64}$" "$H" || { echo "FAIL: handoff carries no real source hash"; return 1; }
  # The recorded hash is the REAL hash of the findings, not a placeholder. Vajra hashes the
  # TRIMMED body (src/cli/next.rs: `let body = findings.trim()`), so the comparison must trim too —
  # the standing carry-forward that has bitten every session that compared raw file bytes.
  local WANT GOT
  WANT="$(printf '%s' "$(cat "$TMP/qa.md")" | shasum -a 256 | cut -d' ' -f1)"
  GOT="$(grep '^source-sha: ' "$H" | cut -d' ' -f2)"
  [ "$WANT" = "$GOT" ] || { echo "FAIL: source-sha $GOT does not hash the trimmed findings ($WANT)"; return 1; }
  echo "trimmed-body sha matches the recorded source-sha: $GOT"
  grep -q "first qa-specialist handoff" "$H" \
    || { echo "FAIL: the handoff delta does not name the producing role"; return 1; }
  if grep -q "researcher handoff" "$H"; then
    echo "FAIL: the qa-specialist's own delta is labelled with the Researcher's name"; return 1
  fi

  # --- FOUR governed handoffs, all named, K byte-identical ---
  local AFTER; AFTER="$(cd "$TMP" && "$VAJRA" next --stations 121 2>&1)"
  echo "--- AFTER (four handoffs) ---"; echo "$AFTER"
  grep -q "fleet: 4 governed handoff(s)" <<<"$AFTER" \
    || { echo "FAIL: the counter does not report four governed handoffs"; return 1; }
  for role in researcher fidelity-reviewer plan-advisor qa-specialist; do
    grep -q "$role" <<<"$(grep 'fleet:' <<<"$AFTER")" \
      || { echo "FAIL: the fleet line does not name $role"; return 1; }
  done
  grep -q "NOT counted in it" <<<"$AFTER" \
    || { echo "FAIL: the fleet line stopped disclosing that it sits outside K"; return 1; }

  local STRIPPED; STRIPPED="$(strip_fleet <<<"$AFTER")"
  if [ "$STRIPPED" != "$BEFORE" ]; then
    echo "FAIL: the report changed by more than the fleet line at FOUR handoffs"
    diff <(echo "$BEFORE") <(echo "$STRIPPED"); return 1
  fi
  echo "OK: four handoffs named beside K; the rest of the report is byte-identical to no-fleet"

  # A malformed FOURTH handoff is still named and still counts as nothing — the S113/S114 rule at a
  # count it was never exercised at (three good + one broken must read as THREE governed).
  echo "notes with no frontmatter" > "$H"
  local MIXED; MIXED="$(cd "$TMP" && "$VAJRA" next --stations 121 2>&1)"
  echo "--- MIXED (three valid, one malformed) ---"; echo "$MIXED"
  grep -q "fleet: 3 governed handoff(s)" <<<"$MIXED" \
    || { echo "FAIL: the surviving valid handoffs are miscounted"; return 1; }
  grep -q "not counted" <<<"$MIXED" || { echo "FAIL: the malformed handoff was swallowed"; return 1; }
  echo "E2E OK: fail-closed (incl. the collision word) · four governed handoffs beside an unchanged K · malformed still named"
  return 0
}
run_check "e2e-four-governed-handoffs" exec e2e_four_handoffs

# --- criterion 4: the decision is IN WRITING, and the code matches it ----------------------------
decision_recorded_and_honoured() {
  local D="docs/decisions/DECISION-007-agent-fleet.md"
  grep -q "S121 addendum" "$D" || { echo "FAIL: no S121 addendum"; return 1; }
  grep -qi 'the role key: \*\*`qa-specialist`\*\*' "$D" \
    || { echo "FAIL: the key decision is not recorded"; return 1; }
  grep -qi 'the tool grant: \*\*`Bash, Read, Write, Edit, Grep, Glob`\*\*' "$D" \
    || { echo "FAIL: the tool grant is not recorded as a decision"; return 1; }

  local ADDENDUM; ADDENDUM="$(sed -n '/^## S121 addendum/,$p' "$D")"
  [ -n "$ADDENDUM" ] || { echo "FAIL: the S121 addendum section is empty"; return 1; }
  local NREJ; NREJ="$(grep -c '^- \*\*Rejected' <<<"$ADDENDUM")"
  echo "rejected-alternative bullets inside the S121 addendum: $NREJ"
  [ "$NREJ" -ge 2 ] \
    || { echo "FAIL: the S121 addendum records $NREJ rejected alternatives; the decision needs at least 2"; return 1; }
  grep -qi 'read-only QA agent' <<<"$ADDENDUM" \
    || { echo "FAIL: the rejected read-only alternative — the one the prompt names — is not recorded"; return 1; }
  # The residual risk of the grant is disclosed, not hidden behind "the role is told not to".
  grep -qi 'residual risk' <<<"$ADDENDUM" \
    || { echo "FAIL: the Write/Edit residual risk is not disclosed"; return 1; }

  # The code matches: the key is distinct AND the bare station word resolves to nothing.
  grep -qE '^[[:space:]]*name: "qa-specialist"' src/fleet/mod.rs \
    || { echo "FAIL: the role key in code is not qa-specialist"; return 1; }
  if grep -rqE '^[[:space:]]*name: "qa"' src/; then
    echo "FAIL: a role keyed 'qa' exists — the collision was not resolved"; return 1
  fi
  echo "OK: the decision is recorded with rejected alternatives + residual risk; code matches it"
  return 0
}
run_check "decision-recorded-honoured" struct decision_recorded_and_honoured

# --- the STATION stays separate from the ROLE (structural: an absence has no output to run) ------
no_station_collision() {
  if grep -rq "qa-specialist" src/qa/ 2>/dev/null; then
    echo "FAIL: the QA STATION now knows about the role — the two were meant to stay separate"; return 1
  fi
  # Positive control: the pattern DOES match where it should, so the absence above means something.
  grep -rq "qa-specialist" src/fleet/ \
    || { echo "FAIL: the pattern matches nothing anywhere — the absence check proves nothing"; return 1; }
  # And the station module really is there to be collided with (not renamed out from under us).
  [ -f src/qa/mod.rs ] || { echo "FAIL: src/qa/mod.rs is gone — this check is vacuous"; return 1; }
  echo "OK: the QA station is untouched by the role key; the probe is non-vacuous"
  return 0
}
run_check "no-station-collision" struct no_station_collision

# --- no 8th command: the fourth role rides `init` + `next`, like the first three -----------------
# EXECUTE-BASED: runs the real binary and asserts on its real output. (The banner it greps is the
# house-wide weak check named since S69 — it reads the printed help, not the command table.)
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"
  echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "no-eighth-command" exec help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %-7s %s\n' "STEP" "CLASS" "RESULT"
printf '%-34s %-7s %s\n' "----------------------------------" "-------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
echo "CHECK CLASSES — execute-based: ${EXEC_N} · structural grep: ${STRUCT_N} · behavioral source grep: ${BEHAV_N}"
if [ "$BEHAV_N" -ne 0 ]; then
  echo "NOTE: ${BEHAV_N} behavioral source grep(s) present — each must be named in the session's fakest-green disclosure."
fi

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
