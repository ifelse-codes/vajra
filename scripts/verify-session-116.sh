#!/usr/bin/env bash
# Verify — Session 116: the fleet's THIRD role, the Plan Advisor (founder pick at the S115 closeout).
#
# Same shape as verify-session-114.sh (the second role): the whole value of this session is that a
# third role needed NO new machinery, so these checks are aimed at the two ways that claim could be
# false — (a) a second SOURCE of role text, and (b) the third role inheriting a hardcoded detail from
# roles 1/2 that stayed invisible at one or two roles. Every negative guard has a positive control.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="116"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- toolchain: unchanged discipline ----------------------------------------------------------
run_check "cargo-build"   cargo build --all-targets
run_check "cargo-test"    cargo test --lib
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings

# The S109 fail-closed writer smoke and the S113 counter suite must BOTH still pass unchanged — this
# session adds a role, it does not get to move what the fleet already guarantees. Reusing
# verify-session-113.sh here (not -114) is deliberate: S113's checks are role-COUNT-agnostic (it
# tests the counter mechanism, never asserts "exactly N roles"), so it stays a valid regression at
# any fleet size. verify-session-114.sh's OWN `scaffolds_two_roles` check hardcodes "exactly 2 agent
# files" and goes red at three roles by construction — the precise class of one/two-element-registry
# assumption STATE.md flagged watching for at a third role. Named here, not silently routed around:
# `scripts/verify-session-114.sh` is a historical snapshot of S114's world, not a living regression
# suite, and re-running it wholesale would report a false S116 regression on a check whose numeral
# was always going to need updating as the fleet grows — the same reason S113 was framed as
# role-count-agnostic in the first place.
run_check "fleet-smoke"              bash scripts/fleet-smoke.sh
run_check "s113-counter-still-green" bash scripts/verify-session-113.sh

VAJRA="$ROOT/target/debug/vajra"

# `cargo test --lib <filter>` EXITS 0 WHEN THE FILTER MATCHES NOTHING (S112 pass 2) — a bare
# filtered run names a lock it does not hold. Reused verbatim, as required.
named_test_passed() {
  local out; out="$(cargo test --lib "$1" 2>&1)"
  echo "$out"
  grep -qE 'test result: ok\. [1-9][0-9]* passed' <<<"$out" \
    || { echo "FAIL: filter '$1' matched no test that ran and passed"; return 1; }
}
run_check "test-role-registered" \
  named_test_passed fleet::tests::plan_advisor_is_registered_with_a_non_colliding_key
run_check "test-roles-read-only" \
  named_test_passed fleet::tests::every_role_is_read_only_and_renders_its_own_tools
run_check "test-delta-names-role" \
  named_test_passed fleet::tests::compute_delta_names_the_producing_role_not_a_hardcoded_one
run_check "test-render-every-role" \
  named_test_passed fleet::tests::render_subagent_definition_is_correct_for_every_registered_role
# The guard on the guard: a filter matching nothing must FAIL, or every check above is theatre.
filter_guard_has_teeth() {
  if named_test_passed fleet::tests::this_test_does_not_exist_on_purpose >/dev/null 2>&1; then
    echo "FAIL: named_test_passed is green on a filter that matches no test"; return 1
  fi
  echo "OK: a filter matching zero tests fails, as it must"
}
run_check "test-filter-guard-has-teeth" filter_guard_has_teeth

strip_fleet() { grep -vE '^[[:space:]]*(⚠ )?fleet:'; }

# --- criterion 1: a fresh `vajra init` scaffolds THREE agent files, all a RENDERING of one source --
# Proven by RUNNING init, never by reading the code. Byte-equality against this repo's own committed
# copies is what makes "one source" a check.
scaffolds_three_roles() { local TMP; TMP="$(mktemp -d)"; _scaffolds_three_roles "$TMP"; local rc=$?; rm -rf "$TMP"; return $rc; }
_scaffolds_three_roles() {
  local TMP="$1"
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null ) || { echo "vajra init failed"; return 1; }
  echo "--- scaffolded agents ---"; ls -1 "$TMP/.claude/agents/"

  local N; N="$(find "$TMP/.claude/agents" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
  [ "$N" = "3" ] || { echo "FAIL: expected 3 scaffolded agent files, got $N"; return 1; }
  [ -f "$TMP/.claude/agents/researcher.md" ] || { echo "FAIL: researcher not scaffolded"; return 1; }
  [ -f "$TMP/.claude/agents/fidelity-reviewer.md" ] || { echo "FAIL: fidelity-reviewer not scaffolded"; return 1; }
  [ -f "$TMP/.claude/agents/plan-advisor.md" ] || { echo "FAIL: plan-advisor not scaffolded"; return 1; }

  # The scaffolded plan-advisor carries the CONTRACT, not a stub — the covers: N marker shape and the
  # proposal-not-record relationship.
  local F="$TMP/.claude/agents/plan-advisor.md"
  grep -q "^name: plan-advisor$" "$F" || { echo "FAIL: wrong subagent name"; return 1; }
  grep -q 'covers: N' "$F" || { echo "FAIL: no covers: N contract"; return 1; }
  grep -q "never the plan of record" "$F" || { echo "FAIL: the proposal-not-record decision is not in the role text"; return 1; }
  grep -q "vajra next --role plan-advisor --from" "$F" || { echo "FAIL: wrong handoff command"; return 1; }

  # Read-only, per-role: NOT granted write/exec, and its grant did not silently inherit anyone else's.
  grep -q "^tools: Read, Grep, Glob$" "$F" || { echo "FAIL: plan-advisor tool grant is not read-only-local"; return 1; }
  if grep -qE '^tools:.*(Write|Edit|Bash|NotebookEdit)' "$TMP/.claude/agents/"*.md; then
    echo "FAIL: a fleet role was granted a write/exec tool"; return 1
  fi

  # This repo's committed copies must be exactly what init renders — a rendering, not a duplicate.
  for f in researcher.md fidelity-reviewer.md plan-advisor.md; do
    diff -u "$TMP/.claude/agents/$f" "$ROOT/.claude/agents/$f" \
      || { echo "FAIL: the repo's $f has drifted from the render"; return 1; }
  done

  # EXACTLY the rendered set — a hand-written extra file would be a real, boot-loadable, second
  # source of role text sitting in the one place nothing looks (S114 cold-review finding, reproduced
  # here at three roles).
  local REPO_AGENTS RENDERED
  REPO_AGENTS="$(cd "$ROOT/.claude/agents" && ls -1 | sort)"
  RENDERED="$(cd "$TMP/.claude/agents" && ls -1 | sort)"
  echo "--- repo .claude/agents/ ---"; echo "$REPO_AGENTS"
  if [ "$REPO_AGENTS" != "$RENDERED" ]; then
    echo "FAIL: .claude/agents/ holds files vajra init does not render — a hand-maintained agent definition is a second source"
    diff <(echo "$RENDERED") <(echo "$REPO_AGENTS"); return 1
  fi
  echo "OK: three roles scaffolded, byte-identical to this repo's copies, and the repo's agent directory is EXACTLY the rendered set"
  return 0
}
run_check "init-scaffolds-three-roles" scaffolds_three_roles

# --- the no-second-source guard (with its positive control) -------------------------------------
# The role text must live in exactly ONE hand-maintained place: src/fleet/mod.rs. The probe sentence
# is chosen to sit UNBROKEN on one Rust source line — a phrase split across a `\`-continuation is
# invisible to grep (the exact trap the S114 script's own comment names), so this one avoids it.
one_source_of_role_text() {
  local HITS
  HITS="$(grep -rl "Do not invent criteria you were not given" . 2>/dev/null \
            | grep -v '^\./target/' | grep -v '^\./\.git/' | grep -v '^\./\.ai/verify/' \
            | grep -v '^\./\.claude/agents/' | grep -v '^\./docs/decisions/' \
            | grep -v '^\./sessions/' | grep -v '^\./scripts/verify-session-116\.sh$' | sort)"
  echo "carriers of the plan-advisor prompt text:"; echo "$HITS"
  grep -q '^\./src/fleet/mod\.rs$' <<<"$HITS" \
    || { echo "FAIL: the pattern does not even match the canonical source — it proves nothing"; return 1; }
  local N; N="$(grep -c . <<<"$HITS")"
  [ "$N" = "1" ] || { echo "FAIL: role text lives in $N places, not 1"; return 1; }
  echo "OK: the plan-advisor's prompt text exists in exactly one hand-maintained file"
  return 0
}
run_check "one-source-of-role-text" one_source_of_role_text

# --- criteria 2 + 3, END-TO-END in a throwaway repo ----------------------------------------------
# Fail-closed for the new role, the key collision, then THREE governed handoffs in one session.
e2e_three_handoffs() { local TMP; TMP="$(mktemp -d)"; _e2e_three_handoffs "$TMP"; local rc=$?; rm -rf "$TMP"; return $rc; }
_e2e_three_handoffs() {
  local TMP="$1"
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null ) || { echo "vajra init failed"; return 1; }
  echo "116" > "$TMP/.ai/SESSION"

  mkdir -p "$TMP/prompts"
  cat > "$TMP/prompts/116-task-fixture.md" <<'FIXTURE'
# Session 116 — fixture

## Acceptance
1. **WHEN** three roles have governed handoffs **THEN** the counter names all three
2. **WHEN** the plan-advisor role is unknown **THEN** the writer fails closed

## Design
- design-significant: no

## Plan
1. register the third role. covers: 1
2. govern its handoff. covers: 2

## Delta
- `+` the fleet's third named role
FIXTURE

  local BEFORE; BEFORE="$(cd "$TMP" && "$VAJRA" next --stations 116 2>&1)" || { echo "--stations failed"; return 1; }
  echo "--- BEFORE (no fleet work) ---"; echo "$BEFORE"
  grep -qi "fleet" <<<"$BEFORE" && { echo "FAIL: fleet mentioned with no handoff"; return 1; }
  grep -qE "^  [1-9] of 8 stations passed" <<<"$BEFORE" \
    || { echo "FAIL: fixture has 0 passing stations — the byte-identity check would be vacuous"; return 1; }

  # --- fail-closed, the collision + the standard three ---
  printf 'PLAN: 1. do the thing — covers: 1\n2. do the other thing — covers: 2\n' > "$TMP/plan.md"
  : > "$TMP/empty.md"
  ( cd "$TMP" && "$VAJRA" next --role planner --from plan.md ) >/dev/null 2>&1 \
    && { echo "FAIL: the bare key 'planner' was accepted — the collision was not resolved"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role plan-advisor ) >/dev/null 2>&1 \
    && { echo "FAIL: --role without --from was accepted"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role plan-advisor --from empty.md ) >/dev/null 2>&1 \
    && { echo "FAIL: empty findings were accepted"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role plan-advisor --from nope.md ) >/dev/null 2>&1 \
    && { echo "FAIL: a missing findings file was accepted"; return 1; }
  echo "OK: unknown role (the collision word) · missing --from · empty findings · missing file all fail closed"

  # --- the real writer, all three roles ---
  printf 'ANSWER: ANTHROPIC_API_KEY is the only auth that survives a fresh no-TTY shell.\n' > "$TMP/findings.md"
  printf 'VERDICT: ACCEPT. 6 of 6 requirements SHIPPED.\nFakest green: the counter counts files, not agents.\n' > "$TMP/review.md"
  ( cd "$TMP" && "$VAJRA" next --role researcher --from findings.md ) >/dev/null \
    || { echo "researcher handoff failed"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer --from review.md ) >/dev/null \
    || { echo "reviewer handoff failed"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role plan-advisor --from plan.md ) >/dev/null \
    || { echo "plan-advisor handoff failed"; return 1; }

  local H="$TMP/.ai/handoffs/session-116-plan-advisor.md"
  [ -f "$H" ] || { echo "FAIL: the plan-advisor handoff is not at the contract path"; return 1; }
  echo "--- plan-advisor handoff ---"; cat "$H"
  grep -q "^role: plan-advisor$" "$H" || { echo "FAIL: handoff role frontmatter wrong"; return 1; }
  grep -qE "^source-sha: [0-9a-f]{64}$" "$H" || { echo "FAIL: handoff carries no real source hash"; return 1; }
  grep -q "first plan-advisor handoff" "$H" \
    || { echo "FAIL: the handoff delta does not name the producing role"; return 1; }
  if grep -q "researcher handoff" "$H"; then
    echo "FAIL: the plan-advisor's own delta is labelled with the Researcher's name"; return 1
  fi

  # --- criterion 3: THREE governed handoffs, all named, K byte-identical ---
  local AFTER; AFTER="$(cd "$TMP" && "$VAJRA" next --stations 116 2>&1)"
  echo "--- AFTER (three handoffs) ---"; echo "$AFTER"
  grep -q "fleet: 3 governed handoff(s)" <<<"$AFTER" \
    || { echo "FAIL: the counter does not report three governed handoffs"; return 1; }
  for role in researcher fidelity-reviewer plan-advisor; do
    grep -q "$role" <<<"$(grep 'fleet:' <<<"$AFTER")" \
      || { echo "FAIL: the fleet line does not name $role"; return 1; }
  done
  grep -q "NOT counted in it" <<<"$AFTER" \
    || { echo "FAIL: the fleet line stopped disclosing that it sits outside K"; return 1; }

  local STRIPPED; STRIPPED="$(strip_fleet <<<"$AFTER")"
  if [ "$STRIPPED" != "$BEFORE" ]; then
    echo "FAIL: the report changed by more than the fleet line at THREE handoffs"
    diff <(echo "$BEFORE") <(echo "$STRIPPED"); return 1
  fi
  echo "OK: three handoffs named beside K; the rest of the report is byte-identical to no-fleet"

  # A malformed THIRD handoff is still named and still counts as nothing — the S113/S114 rule holds
  # at a count it was never exercised at (two good + one broken must read as TWO governed).
  echo "notes with no frontmatter" > "$H"
  local MIXED; MIXED="$(cd "$TMP" && "$VAJRA" next --stations 116 2>&1)"
  echo "--- MIXED (two valid, one malformed) ---"; echo "$MIXED"
  grep -q "fleet: 2 governed handoff(s)" <<<"$MIXED" \
    || { echo "FAIL: the surviving valid handoffs are miscounted"; return 1; }
  grep -q "not counted" <<<"$MIXED" || { echo "FAIL: the malformed handoff was swallowed"; return 1; }
  echo "E2E OK: fail-closed (incl. the collision word) · three governed handoffs beside an unchanged K · malformed still named"
  return 0
}
run_check "e2e-three-governed-handoffs" e2e_three_handoffs

# --- criterion 4: the decision is IN WRITING, and the code matches it ----------------------------
decision_recorded_and_honoured() {
  local D="docs/decisions/DECISION-007-agent-fleet.md"
  grep -q "S116 addendum" "$D" || { echo "FAIL: no S116 addendum"; return 1; }
  grep -qi 'the role key: \*\*`plan-advisor`\*\*' "$D" \
    || { echo "FAIL: the key decision is not recorded"; return 1; }

  local ADDENDUM; ADDENDUM="$(sed -n '/^## S116 addendum/,$p' "$D")"
  [ -n "$ADDENDUM" ] || { echo "FAIL: the S116 addendum section is empty"; return 1; }
  local NREJ; NREJ="$(grep -ci "rejected" <<<"$ADDENDUM")"
  echo "rejected-alternative lines inside the S116 addendum: $NREJ"
  [ "$NREJ" -ge 2 ] \
    || { echo "FAIL: the S116 addendum records $NREJ rejected alternatives; the decision needs at least 2"; return 1; }

  # The code matches: the key is distinct AND the bare station word resolves to nothing.
  grep -qE '^[[:space:]]*name: "plan-advisor"' src/fleet/mod.rs \
    || { echo "FAIL: the role key in code is not plan-advisor"; return 1; }
  if grep -rqE '^[[:space:]]*name: "planner"' src/; then
    echo "FAIL: a role keyed 'planner' exists — the collision was not resolved"; return 1
  fi

  # The Planner STATION must stay untouched — the role and the station were meant to stay separate,
  # same as the Reviewer precedent.
  if grep -rq "plan-advisor" src/planner/ 2>/dev/null; then
    echo "FAIL: the Planner STATION now knows about the role — the two were meant to stay separate"; return 1
  fi
  echo "OK: the decision is recorded with rejected alternatives; code matches it"
  return 0
}
run_check "decision-recorded-honoured" decision_recorded_and_honoured

# --- no 8th command: the third role rides `init` + `next`, like the first two --------------------
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"
  echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "no-eighth-command" help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
