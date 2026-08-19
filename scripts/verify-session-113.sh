#!/usr/bin/env bash
# Verify — Session 113: make fleet work visible to the counter (founder pick A at the S112 closeout).
#
# The counter could not see the fleet at all: a session that dispatched a named agent, governed its
# findings and consumed them downstream scored exactly the same `K of 8` as one that did none of it.
# S113 reports fleet evidence BESIDE K (design shape (c)) — so the checks here are behavioural and
# they are TWO-SIDED: the same command in the same repo must (a) gain a fleet line when a governed
# handoff exists, and (b) leave the K line and every other byte untouched. A check that only proved
# (a) would let a silent redefinition of K pass, which is the failure this session exists to avoid.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="113"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-32s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-32s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- toolchain: unchanged discipline ----------------------------------------------------------
run_check "cargo-build"   cargo build --all-targets
run_check "cargo-test"    cargo test --lib
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings

# --- the S109 fail-closed writer smoke must still hold (this session only READS) ----------------
run_check "fleet-smoke"   bash scripts/fleet-smoke.sh

VAJRA="$ROOT/target/debug/vajra"

# `cargo test --lib <filter>` EXITS 0 WHEN THE FILTER MATCHES NOTHING, so a bare filtered run is
# green after that test is renamed or deleted — it names a lock it does not hold (S112 cold-review
# pass 2). Reused verbatim from scripts/verify-session-112.sh, as the S113 prompt requires.
named_test_passed() {
  local out; out="$(cargo test --lib "$1" 2>&1)"
  echo "$out"
  grep -qE 'test result: ok\. [1-9][0-9]* passed' <<<"$out" \
    || { echo "FAIL: filter '$1' matched no test that ran and passed"; return 1; }
}
run_check "test-absent-renders-nothing" \
  named_test_passed stations::tests::fleet_evidence_absent_renders_nothing_and_leaves_k_untouched
run_check "test-governed-beside-k" \
  named_test_passed stations::tests::fleet_evidence_reports_a_governed_handoff_beside_k_without_changing_k
run_check "test-malformed-not-counted" \
  named_test_passed stations::tests::fleet_evidence_names_a_malformed_handoff_and_never_counts_it
# Added after cold-review pass 2: every OTHER check writes at most one handoff, so a station that
# started passing on `governed.len() >= 2` would keep the whole suite green — and two handoffs is
# the normal state the moment the chosen second role is built.
run_check "test-k-invariant-any-fleet" \
  named_test_passed stations::tests::k_is_invariant_under_any_amount_of_fleet_evidence
# The guard on the guard: a filter matching nothing must FAIL, or every check above is theatre.
filter_guard_has_teeth() {
  if named_test_passed stations::tests::this_test_does_not_exist_on_purpose >/dev/null 2>&1; then
    echo "FAIL: named_test_passed is green on a filter that matches no test"; return 1
  fi
  echo "OK: a filter matching zero tests fails, as it must"
}
run_check "test-filter-guard-has-teeth" filter_guard_has_teeth

# Strip exactly the S113 fleet line(s) — anchored, not a bare `grep -v fleet:` substring filter,
# which would silently swallow any future station line that happens to contain the word (cold-review
# finding F8: the strongest check in this suite must not be able to hide the difference it exists to
# catch).
strip_fleet() { grep -vE '^[[:space:]]*(⚠ )?fleet:'; }

# --- END-TO-END, in a throwaway repo: the counter's output changes ONLY by the fleet line --------
# No fixture is hand-placed on disk: the handoff is written by the real `vajra next --role` writer.
e2e_counter() { local TMP; TMP="$(mktemp -d)"; _e2e_counter "$TMP"; local rc=$?; rm -rf "$TMP"; return $rc; }
_e2e_counter() {
  local TMP="$1"
  ( cd "$TMP" && git init -q . && "$VAJRA" init >/dev/null </dev/null ) || { echo "vajra init failed"; return 1; }
  echo "113" > "$TMP/.ai/SESSION"

  # A NON-DEGENERATE repo: a real prompt so some stations actually PASS (K=2 here). In an empty
  # repo every classifier sits at its floor, so "the report is unchanged" would compare two
  # saturated outputs and could not notice fleet evidence flipping a station (cold-review F2).
  mkdir -p "$TMP/prompts"
  cat > "$TMP/prompts/113-task-fixture.md" <<'FIXTURE'
# Session 113 — fixture

## Acceptance
1. **WHEN** a governed handoff exists **THEN** the counter names it
2. **WHEN** none exists **THEN** the counter says nothing

## Design
- design-significant: no

## Plan
1. derive the evidence. covers: 1
2. render it beside K. covers: 2

## Delta
- `+` fleet evidence beside the K-of-8 counter
FIXTURE

  local BEFORE AFTER
  BEFORE="$(cd "$TMP" && "$VAJRA" next --stations 113 2>&1)" || { echo "--stations failed (before)"; return 1; }
  echo "--- BEFORE ---"; echo "$BEFORE"

  # Absence is SILENT: a session with no fleet work must read exactly as it did before S113.
  if grep -qi "fleet" <<<"$BEFORE"; then
    echo "FAIL: --stations mentions the fleet when there is no handoff"; return 1
  fi
  # The comparison below is only meaningful if the counter is LIVE here — at least one station
  # must be passing, or "unchanged" is trivially true (cold-review F2).
  grep -qE "^  [1-9] of 8 stations passed" <<<"$BEFORE" \
    || { echo "FAIL: fixture repo has 0 passing stations — the byte-identity check would be vacuous"; return 1; }

  printf 'ANSWER: ANTHROPIC_API_KEY is the only auth that survives a fresh no-TTY shell.\nclaude setup-token is the subscription alternative.\n' > "$TMP/findings.md"
  ( cd "$TMP" && "$VAJRA" next --role researcher --from findings.md ) >/dev/null \
    || { echo "governing the handoff failed"; return 1; }

  AFTER="$(cd "$TMP" && "$VAJRA" next --stations 113 2>&1)" || { echo "--stations failed (after)"; return 1; }
  echo "--- AFTER ---"; echo "$AFTER"

  # (a) fleet work is now VISIBLE, named by role, and says plainly it is not part of K.
  grep -q "fleet: 1 governed handoff(s) — researcher" <<<"$AFTER" \
    || { echo "FAIL: governed handoff not surfaced by the counter"; return 1; }
  grep -q "NOT counted in it" <<<"$AFTER" \
    || { echo "FAIL: the fleet line does not disclose that it is outside K"; return 1; }

  # (b) K is untouched — and not just the number: EVERY other byte of the report is identical.
  # Strip the added fleet line(s) from AFTER and require byte-equality with BEFORE. This is what
  # makes "K stays comparable" a check rather than a claim.
  local STRIPPED; STRIPPED="$(strip_fleet <<<"$AFTER")"
  if [ "$STRIPPED" != "$BEFORE" ]; then
    echo "FAIL: the report changed by more than the fleet line"; diff <(echo "$BEFORE") <(echo "$STRIPPED"); return 1
  fi
  echo "OK: AFTER minus the fleet line is byte-identical to BEFORE"

  # A DIFFERENT session is untouched by session 113's handoff.
  local OTHER; OTHER="$(cd "$TMP" && "$VAJRA" next --stations 112 2>&1)"
  if grep -qi "fleet" <<<"$OTHER"; then
    echo "FAIL: session 112 shows session 113's handoff"; return 1
  fi

  # DERIVED, not merely present: a file at the handoff path that fails the contract must be NAMED
  # and must NOT read as fleet work done (acceptance criterion 2).
  echo "just some notes, no frontmatter" > "$TMP/.ai/handoffs/session-113-researcher.md"
  local BROKEN; BROKEN="$(cd "$TMP" && "$VAJRA" next --stations 113 2>&1)"
  echo "--- MALFORMED ---"; echo "$BROKEN"
  grep -q "not counted" <<<"$BROKEN" \
    || { echo "FAIL: malformed handoff swallowed"; return 1; }
  if grep -q "governed handoff(s)" <<<"$BROKEN"; then
    echo "FAIL: a malformed handoff read as governed fleet work"; return 1
  fi
  local BROKEN_STRIPPED; BROKEN_STRIPPED="$(strip_fleet <<<"$BROKEN")"
  [ "$BROKEN_STRIPPED" = "$BEFORE" ] \
    || { echo "FAIL: a malformed handoff moved something other than the fleet line"; return 1; }

  echo "E2E OK: absent silent · governed handoff visible beside K · K byte-identical · other sessions unaffected · malformed named, never counted"
  return 0
}
run_check "e2e-counter" e2e_counter

# --- REAL DATA, this repo: S111's genuine subagent-derived handoff is counted-beside, S110's absence is silent
real_handoff_beside_k() {
  local OUT_111 OUT_110
  OUT_111="$("$VAJRA" next --stations 111 2>&1)"
  OUT_110="$("$VAJRA" next --stations 110 2>&1)"
  echo "--- stations 111 ---"; echo "$OUT_111"
  echo "--- stations 110 ---"; echo "$OUT_110"
  grep -q "fleet: 1 governed handoff(s) — researcher" <<<"$OUT_111" \
    || { echo "FAIL: real S111 handoff not visible to the counter"; return 1; }
  # The K line still reads as it always did (the number itself is whatever the gates derive).
  grep -qE "^  [0-9] of 8 stations passed" <<<"$OUT_111" \
    || { echo "FAIL: the K line changed shape"; return 1; }
  if grep -qi "fleet" <<<"$OUT_110"; then
    echo "FAIL: session 110 (no handoff) mentions the fleet"; return 1
  fi
  return 0
}
run_check "real-handoff-beside-k" real_handoff_beside_k

# --- the second role is CHOSEN and recorded, and NOT built (criterion 4 + the non-goal) ---------
second_role_recorded_not_built() {
  local D="docs/decisions/DECISION-007-agent-fleet.md"
  grep -q "S113 addendum" "$D" || { echo "FAIL: no S113 addendum in DECISION-007"; return 1; }
  grep -qi "second role is the \*\*Reviewer\*\*" "$D" \
    || { echo "FAIL: the addendum does not name the chosen role"; return 1; }
  grep -qi "Alternatives considered, and why each loses" "$D" \
    || { echo "FAIL: the addendum records no rejected alternatives (a pick without reasoning)"; return 1; }
  # NOT built: no reviewer role anywhere in the source, no scaffolded reviewer subagent file.
  # `[[:space:]]`, never `\s`: BSD/macOS `grep -E` treats `\s` as a literal `s`, so the pattern
  # would silently fail to match indented Rust and the guard would report "not built" while a role
  # existed (cold-review F3). Searched across all of `src/`, not one file, so moving the role
  # definition cannot dodge it.
  # Guard on the guard: the SAME pattern must match the role that DOES exist, or it proves nothing
  # about the role that must not.
  grep -rqE '^[[:space:]]*name: "resea' src/ \
    || { echo "FAIL: the not-built pattern does not even match the existing researcher role"; return 1; }
  if grep -rqE '^[[:space:]]*name: "review' src/; then
    echo "FAIL: a reviewer role was BUILT — this session only chooses it"; return 1
  fi
  if [ -f ".claude/agents/reviewer.md" ]; then
    echo "FAIL: .claude/agents/reviewer.md exists — the role was built, not just chosen"; return 1
  fi
  echo "OK: Reviewer chosen with reasoning + rejected alternatives; no role code shipped"
  return 0
}
run_check "second-role-chosen-only" second_role_recorded_not_built

# --- no 8th command: the counter's fleet line rides `next`, like everything else the fleet does --
help_lists_seven() {
  local help; help="$("$VAJRA" --help 2>&1)"
  echo "$help"
  grep -q "vajra <init|claude|check|next|estimate|hook|meter>" <<<"$help"
}
run_check "no-eighth-command" help_lists_seven

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-32s %s\n' "STEP" "RESULT"
printf '%-32s %s\n' "--------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
