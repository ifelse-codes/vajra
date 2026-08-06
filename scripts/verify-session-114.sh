#!/usr/bin/env bash
# Verify — Session 114: the fleet's SECOND role, the Fidelity Reviewer (founder pick A at S113).
#
# S113 chose the role from evidence; S114 builds it. The whole value of this session is that a
# second role needed NO new machinery — so these checks are aimed at the two ways that claim could
# be false:
#   (a) a second SOURCE of role text (a hand-maintained copy of the prompt, the exact drift
#       `fleet::ROLES` exists to kill), and
#   (b) the second role inheriting the first one's hardcoded details (its tool grant, its name in
#       the handoff delta) — invisible while only one role existed.
# Every negative guard below is paired with a positive control: a check that says "X was not built"
# proves nothing unless the same pattern matches the thing that WAS.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="114"
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

# The S109 fail-closed writer smoke and the S113 counter suite must BOTH still pass unchanged —
# this session adds a role, it does not get to move what the fleet already guarantees.
run_check "fleet-smoke"          bash scripts/fleet-smoke.sh
run_check "s113-counter-still-green" bash scripts/verify-session-113.sh

VAJRA="$ROOT/target/debug/vajra"

# `cargo test --lib <filter>` EXITS 0 WHEN THE FILTER MATCHES NOTHING (S112 pass 2) — a bare
# filtered run names a lock it does not hold. Reused verbatim, as the S114 prompt requires.
named_test_passed() {
  local out; out="$(cargo test --lib "$1" 2>&1)"
  echo "$out"
  grep -qE 'test result: ok\. [1-9][0-9]* passed' <<<"$out" \
    || { echo "FAIL: filter '$1' matched no test that ran and passed"; return 1; }
}
run_check "test-role-registered" \
  named_test_passed fleet::tests::fidelity_reviewer_is_registered_with_a_non_colliding_key
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

# --- criterion 1: a fresh `vajra init` scaffolds TWO agent files, both a RENDERING of one source --
# Proven by RUNNING init, never by reading the code. Byte-equality against this repo's own committed
# copies is what makes "one source" a check: a hand-edit to either file (the drift this session is
# about) turns this red.
scaffolds_two_roles() { local TMP; TMP="$(mktemp -d)"; _scaffolds_two_roles "$TMP"; local rc=$?; rm -rf "$TMP"; return $rc; }
_scaffolds_two_roles() {
  local TMP="$1"
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null ) || { echo "vajra init failed"; return 1; }
  echo "--- scaffolded agents ---"; ls -1 "$TMP/.claude/agents/"

  local N; N="$(find "$TMP/.claude/agents" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
  [ "$N" = "2" ] || { echo "FAIL: expected 2 scaffolded agent files, got $N"; return 1; }
  [ -f "$TMP/.claude/agents/researcher.md" ] || { echo "FAIL: researcher not scaffolded"; return 1; }
  [ -f "$TMP/.claude/agents/fidelity-reviewer.md" ] || { echo "FAIL: fidelity-reviewer not scaffolded"; return 1; }

  # The scaffolded reviewer carries the CONTRACT, not a stub — the three grades, the fakest green,
  # and the pre-stage-input relationship to the record of record (deliverable 5).
  local F="$TMP/.claude/agents/fidelity-reviewer.md"
  grep -q "^name: fidelity-reviewer$" "$F" || { echo "FAIL: wrong subagent name"; return 1; }
  grep -q "SHIPPED / PARTIAL / NOT-BUILT" "$F" || { echo "FAIL: no per-requirement grading contract"; return 1; }
  grep -q "FAKEST GREEN" "$F" || { echo "FAIL: the fakest-green instruction is missing"; return 1; }
  grep -q "PRE-STAGE INPUT" "$F" || { echo "FAIL: the pre-stage-input decision is not in the role text"; return 1; }
  grep -q "sessions/session-NN-review.md" "$F" || { echo "FAIL: the record of record is not named"; return 1; }
  grep -q "vajra next --role fidelity-reviewer --from" "$F" || { echo "FAIL: wrong handoff command"; return 1; }

  # Read-only, per-role: the reviewer's grant is strictly local reads, and it is NOT the
  # researcher's (which would mean the tool list is still hardcoded to role #1).
  grep -q "^tools: Read, Grep, Glob$" "$F" || { echo "FAIL: reviewer tool grant is not read-only-local"; return 1; }
  grep -q "^tools: Read, Grep, Glob, WebSearch, WebFetch$" "$TMP/.claude/agents/researcher.md" \
    || { echo "FAIL: researcher's own tool grant changed"; return 1; }
  if grep -qE '^tools:.*(Write|Edit|Bash|NotebookEdit)' "$TMP/.claude/agents/"*.md; then
    echo "FAIL: a fleet role was granted a write/exec tool"; return 1
  fi

  # This repo's committed copies must be exactly what init renders — a rendering, not a duplicate.
  diff -u "$TMP/.claude/agents/researcher.md" "$ROOT/.claude/agents/researcher.md" \
    || { echo "FAIL: the repo's researcher.md has drifted from the render"; return 1; }
  diff -u "$TMP/.claude/agents/fidelity-reviewer.md" "$ROOT/.claude/agents/fidelity-reviewer.md" \
    || { echo "FAIL: the repo's fidelity-reviewer.md has drifted from the render"; return 1; }
  echo "OK: two roles scaffolded, both byte-identical to this repo's committed copies"
  return 0
}
run_check "init-scaffolds-two-roles" scaffolds_two_roles

# --- the no-second-source guard (with its positive control) -------------------------------------
# The role text must live in exactly ONE hand-maintained place: src/fleet/mod.rs. Anything else that
# carries the sentence is a copy — and a copy is the drift DECISION-007 forbids. `.claude/agents/`
# is excluded because it is a RENDERING, and the check above already proves it is byte-identical to
# what init produces.
one_source_of_role_text() {
  local HITS
  # THIS script is excluded, and only this one: any literal probe sentence necessarily appears in
  # the file that greps for it, so a checker matching itself is noise, not a finding. Everything
  # else in the repo is in scope. `.claude/agents/` is excluded because it is a rendering, already
  # proven byte-identical to `vajra init` output above; `docs/decisions/` quotes the decision, which
  # is a record, not a source the binary reads.
  HITS="$(grep -rl "you are not its replacement" --include='*.rs' --include='*.md' --include='*.sh' \
            . 2>/dev/null | grep -v '^\./target/' | grep -v '^\./\.claude/agents/' \
            | grep -v '^\./docs/decisions/' | grep -v '^\./scripts/verify-session-114\.sh$' | sort)"
  echo "carriers of the reviewer prompt text:"; echo "$HITS"
  # Positive control: the pattern DOES find the one legitimate source. Without this, a typo in the
  # pattern would make "no second copy" trivially true.
  grep -q '^\./src/fleet/mod\.rs$' <<<"$HITS" \
    || { echo "FAIL: the pattern does not even match the canonical source — it proves nothing"; return 1; }
  local N; N="$(grep -c . <<<"$HITS")"
  [ "$N" = "1" ] || { echo "FAIL: role text lives in $N places, not 1"; return 1; }
  echo "OK: the reviewer's prompt text exists in exactly one hand-maintained file"
  return 0
}
run_check "one-source-of-role-text" one_source_of_role_text

# --- criterion 2 + 3, END-TO-END in a throwaway repo --------------------------------------------
# Fail-closed for the new role, then TWO governed handoffs in one session — the count that did not
# exist when the S113 invariant was written.
e2e_two_handoffs() { local TMP; TMP="$(mktemp -d)"; _e2e_two_handoffs "$TMP"; local rc=$?; rm -rf "$TMP"; return $rc; }
_e2e_two_handoffs() {
  local TMP="$1"
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null ) || { echo "vajra init failed"; return 1; }
  echo "114" > "$TMP/.ai/SESSION"

  # A NON-DEGENERATE fixture: some stations must actually pass, or "K unchanged" compares two
  # floor-state reports and could not notice a station flipping (S113 cold-review F2).
  mkdir -p "$TMP/prompts"
  cat > "$TMP/prompts/114-task-fixture.md" <<'FIXTURE'
# Session 114 — fixture

## Acceptance
1. **WHEN** two roles have governed handoffs **THEN** the counter names both
2. **WHEN** the reviewer role is unknown **THEN** the writer fails closed

## Design
- design-significant: no

## Plan
1. register the second role. covers: 1
2. govern its handoff. covers: 2

## Delta
- `+` the fleet's second named role
FIXTURE

  local BEFORE; BEFORE="$(cd "$TMP" && "$VAJRA" next --stations 114 2>&1)" || { echo "--stations failed"; return 1; }
  echo "--- BEFORE (no fleet work) ---"; echo "$BEFORE"
  grep -qi "fleet" <<<"$BEFORE" && { echo "FAIL: fleet mentioned with no handoff"; return 1; }
  grep -qE "^  [1-9] of 8 stations passed" <<<"$BEFORE" \
    || { echo "FAIL: fixture has 0 passing stations — the byte-identity check would be vacuous"; return 1; }

  # --- fail-closed, the same three ways as slice 1 (criterion 2) ---
  printf 'VERDICT: ACCEPT. 6 of 6 requirements SHIPPED.\nFakest green: the counter counts files, not agents.\n' > "$TMP/review.md"
  : > "$TMP/empty.md"
  ( cd "$TMP" && "$VAJRA" next --role reviewer --from review.md ) >/dev/null 2>&1 \
    && { echo "FAIL: the bare key 'reviewer' was accepted — the collision was not resolved"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer ) >/dev/null 2>&1 \
    && { echo "FAIL: --role without --from was accepted"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer --from empty.md ) >/dev/null 2>&1 \
    && { echo "FAIL: empty findings were accepted"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer --from nope.md ) >/dev/null 2>&1 \
    && { echo "FAIL: a missing findings file was accepted"; return 1; }
  echo "OK: unknown role · missing --from · empty findings · missing file all fail closed"

  # --- the real writer, both roles ---
  printf 'ANSWER: ANTHROPIC_API_KEY is the only auth that survives a fresh no-TTY shell.\n' > "$TMP/findings.md"
  ( cd "$TMP" && "$VAJRA" next --role researcher --from findings.md ) >/dev/null \
    || { echo "researcher handoff failed"; return 1; }
  ( cd "$TMP" && "$VAJRA" next --role fidelity-reviewer --from review.md ) >/dev/null \
    || { echo "reviewer handoff failed"; return 1; }

  local H="$TMP/.ai/handoffs/session-114-fidelity-reviewer.md"
  [ -f "$H" ] || { echo "FAIL: the reviewer handoff is not at the contract path"; return 1; }
  echo "--- reviewer handoff ---"; cat "$H"
  grep -q "^role: fidelity-reviewer$" "$H" || { echo "FAIL: handoff role frontmatter wrong"; return 1; }
  grep -qE "^source-sha: [0-9a-f]{64}$" "$H" || { echo "FAIL: handoff carries no real source hash"; return 1; }
  # The S114 drift fix, checked behaviourally: the delta names THIS role, not the Researcher.
  grep -q "first fidelity-reviewer handoff" "$H" \
    || { echo "FAIL: the handoff delta does not name the producing role"; return 1; }
  if grep -q "researcher handoff" "$H"; then
    echo "FAIL: the reviewer's own delta is labelled with the Researcher's name"; return 1
  fi

  # --- criterion 3: TWO governed handoffs, both roles named, K byte-identical ---
  local AFTER; AFTER="$(cd "$TMP" && "$VAJRA" next --stations 114 2>&1)"
  echo "--- AFTER (two handoffs) ---"; echo "$AFTER"
  grep -q "fleet: 2 governed handoff(s)" <<<"$AFTER" \
    || { echo "FAIL: the counter does not report two governed handoffs"; return 1; }
  grep -q "researcher" <<<"$(grep 'fleet:' <<<"$AFTER")" \
    || { echo "FAIL: the fleet line does not name the researcher"; return 1; }
  grep -q "fidelity-reviewer" <<<"$(grep 'fleet:' <<<"$AFTER")" \
    || { echo "FAIL: the fleet line does not name the fidelity-reviewer"; return 1; }
  grep -q "NOT counted in it" <<<"$AFTER" \
    || { echo "FAIL: the fleet line stopped disclosing that it sits outside K"; return 1; }

  local STRIPPED; STRIPPED="$(strip_fleet <<<"$AFTER")"
  if [ "$STRIPPED" != "$BEFORE" ]; then
    echo "FAIL: the report changed by more than the fleet line at TWO handoffs"
    diff <(echo "$BEFORE") <(echo "$STRIPPED"); return 1
  fi
  echo "OK: two handoffs named beside K; the rest of the report is byte-identical to no-fleet"

  # A malformed SECOND handoff is still named and still counts as nothing — the S113 rule holds at
  # a count it was never exercised at (one good + one broken must read as ONE governed).
  echo "notes with no frontmatter" > "$H"
  local MIXED; MIXED="$(cd "$TMP" && "$VAJRA" next --stations 114 2>&1)"
  echo "--- MIXED (one valid, one malformed) ---"; echo "$MIXED"
  grep -q "fleet: 1 governed handoff(s) — researcher" <<<"$MIXED" \
    || { echo "FAIL: the surviving valid handoff is miscounted"; return 1; }
  grep -q "not counted" <<<"$MIXED" || { echo "FAIL: the malformed handoff was swallowed"; return 1; }
  echo "E2E OK: fail-closed · two governed handoffs beside an unchanged K · malformed still named"
  return 0
}
run_check "e2e-two-governed-handoffs" e2e_two_handoffs

# --- criterion 4: both decisions are IN WRITING, and the code matches them ----------------------
decisions_recorded_and_honoured() {
  local D="docs/decisions/DECISION-007-agent-fleet.md"
  grep -q "S114 addendum" "$D" || { echo "FAIL: no S114 addendum"; return 1; }
  grep -q 'the role key: \*\*`fidelity-reviewer`\*\*' "$D" \
    || { echo "FAIL: the key decision is not recorded"; return 1; }
  grep -q "pre-stage input, one record of record" "$D" \
    || { echo "FAIL: the double-record decision is not recorded"; return 1; }
  grep -qi "Rejected" "$D" || { echo "FAIL: decisions recorded with no rejected alternative"; return 1; }

  # The code matches decision 1: the key is distinct AND the bare station word resolves to nothing.
  grep -qE '^[[:space:]]*name: "fidelity-reviewer"' src/fleet/mod.rs \
    || { echo "FAIL: the role key in code is not fidelity-reviewer"; return 1; }
  if grep -rqE '^[[:space:]]*name: "reviewer"' src/; then
    echo "FAIL: a role keyed 'reviewer' exists — the collision was not resolved"; return 1
  fi

  # The code matches decision 2: the record of record is untouched. No gate learns to read a
  # handoff — verify-closeout.sh still reads sessions/session-NN-review.md and nothing else.
  grep -q "session-\$SESSION-review.md\|session-.*-review.md" scripts/verify-closeout.sh \
    || { echo "FAIL: positive control — the closeout gate no longer names the review artifact"; return 1; }
  if grep -q "handoffs/" scripts/verify-closeout.sh; then
    echo "FAIL: the closeout gate now reads a handoff — two competing records of the verdict"; return 1
  fi
  if grep -rq "fidelity-reviewer" src/stations/ 2>/dev/null; then
    echo "FAIL: the Reviewer STATION now knows about the role — the two were meant to stay separate"; return 1
  fi
  echo "OK: both decisions recorded with rejected alternatives; code matches both"
  return 0
}
run_check "decisions-recorded-honoured" decisions_recorded_and_honoured

# --- no 8th command: the second role rides `init` + `next`, like the first -----------------------
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
