#!/usr/bin/env bash
# =====================================================================================
# fixture-session-135.sh — falsifiability for the Crew gate (the tech-lead's decision).
#
# A green check proves nothing until you have watched it go red. S122: a fixture that goes
# red for the WRONG reason is glued on, so every plant here turns the suite red **through
# the crew test that OWNS it** — a named `cargo test` filter, never "somewhere". Every plant
# asserts its own edit LANDED before its result is trusted (S127/S128); a plant that silently
# no-ops reports false comfort. And S134: the POSITIVE CONTROL asserts a CLEAN EXIT 0, not
# just one green line — a sandbox missing one file made the exit-code half of every S134
# assertion meaningless.
#
# Four plants and two controls:
#   P1  parse_crew_row accepts `not-needed` as Required  -> no-off-switch test RED   (acc 3)
#   P2  parse_crew stops requiring all nine specialists  -> all-nine test RED        (acc 2)
#   P3  crew_gate stops refusing a skipped tech-lead      -> skipped-tech-lead RED    (acc 1)
#   P4  raw_tokens drops cache_read (the S134 45x bug)    -> reconciliation test RED  (acc 6)
#   C   a printed MESSAGE reworded, no behaviour changed  -> every test stays GREEN   (S122)
#   POS baseline crew suite                               -> CLEAN exit 0             (S134)
#
# The control C is the point: the crew tests bind to DEFECT VALUES, not to message text, so
# rewording a sentence must not move them. A fixture that also went red on C would be diffing
# bytes, not governing a contract.
#
# Usage:  bash scripts/fixture-session-135.sh
# Exit:   0 = every plant fired through its OWN test, the control stayed green, and the
#             positive control exited 0 cleanly.
# =====================================================================================

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

PASS=0; FAIL=0
pass() { printf '  %-58s %s\n' "$1" "PASS"; PASS=$((PASS+1)); }
fail() { printf '  %-58s %s\n' "$1" "FAIL"; FAIL=$((FAIL+1)); [ -n "${2:-}" ] && echo "        └─ $2"; return 0; }

SRC="src/crew/mod.rs"

# The tree must be clean for the file this fixture edits and restores in place.
DIRTY="$(git status --porcelain -- "$SRC" 2>/dev/null)"
if [ -n "$DIRTY" ]; then
  echo "BLOCK: uncommitted changes in $SRC — this fixture restores from a disk copy, not from git."
  printf '%s\n' "$DIRTY"
  exit 1
fi

BACKUP="$(mktemp -d "${TMPDIR:-/tmp}/vajra-fix135-XXXXXX")"
cp "$SRC" "$BACKUP/mod.rs"
restore() { cp "$BACKUP/mod.rs" "$SRC"; rm -rf "$BACKUP"; }
trap restore EXIT

# Run one named crew test; return 0 if it PASSES, 1 if it FAILS.
run_test() { cargo test --lib "crew::tests::$1" >/dev/null 2>&1; }

# assert a plant LANDED (the mutated source contains a marker string), then that the owning
# test now FAILS. Restores the source afterwards so plants never stack.
plant_makes_test_fail() {
  local NAME="$1" LANDED_MARKER="$2" TEST="$3"
  if ! grep -qF "$LANDED_MARKER" "$SRC"; then
    fail "$NAME" "plant did not land — marker '$LANDED_MARKER' absent (a silent no-op)"
    cp "$BACKUP/mod.rs" "$SRC"; return 0
  fi
  if run_test "$TEST"; then
    fail "$NAME" "owning test $TEST still PASSED with the bypass planted — it does not bite"
  else
    pass "$NAME"
  fi
  cp "$BACKUP/mod.rs" "$SRC"
}

echo "=== fixture-135 — does the Crew gate actually bite? ==="
echo ""

# Baseline: the suite is green to start (so a later RED is the plant, not a pre-existing break).
if cargo test --lib "crew::" >/dev/null 2>&1; then
  pass "baseline: the crew suite is GREEN before any plant"
else
  fail "baseline: the crew suite is RED before any plant" "fix the suite before trusting this fixture"
  echo ""; echo "fixture-135: $PASS passed, $FAIL failed"; exit 1
fi

# --- P1: the no-off-switch bypass — accept `not-needed` as required -----------------------------
# Replace the UnknownVerdict arm so any unknown verdict silently becomes Required.
perl -0pi -e 's/other => \{\n\s*return Some\(Err\(\(\n\s*role,\n\s*CrewRowDefect::UnknownVerdict\(other\.to_string\(\)\),\n\s*\)\)\)\n\s*\}/other => { let _ = other; CrewKind::Required \/\/ PLANT_P1_OFFSWITCH/s' "$SRC"
plant_makes_test_fail "P1 no-off-switch bypass -> UnknownVerdict test RED" "PLANT_P1_OFFSWITCH" "an_inadmissible_verdict_is_refused_by_value"

# --- P2: stop requiring all nine specialists ---------------------------------------------------
# Force the missing-roles branch to think nothing is ever missing.
perl -0pi -e 's/if !missing\.is_empty\(\) \{/if false \{ \/\/ PLANT_P2_NOTNINE\n    if !missing.is_empty() \&\& false \{/s' "$SRC"
plant_makes_test_fail "P2 all-nine requirement dropped -> all-nine test RED" "PLANT_P2_NOTNINE" "parse_crew_requires_all_nine_and_rejects_duplicates"

# --- P3: stop refusing a skipped tech-lead -----------------------------------------------------
# Neuter the skipped-tech-lead block so a `tech-lead: skipped` marker is treated as a pass.
perl -0pi -e 's/if let Some\(reason\) = tl\.skipped \{/if let Some(reason) = tl.skipped { let _ = reason; \/\/ PLANT_P3_SKIP\n    if false {/s' "$SRC"
plant_makes_test_fail "P3 skipped tech-lead no longer refused -> skip test RED" "PLANT_P3_SKIP" "a_skipped_tech_lead_is_refused_not_passed"

# --- P4: the S134 45x bug — drop cache reads from raw_tokens ------------------------------------
perl -0pi -e 's/u\("input_tokens"\) \+ u\("output_tokens"\) \+ u\("cache_read_input_tokens"\)/u("input_tokens") + u("output_tokens") + 0 * u("cache_read_input_tokens") \/* PLANT_P4_NOCACHE *\//s' "$SRC"
plant_makes_test_fail "P4 cache reads dropped (S134 45x bug) -> reconciliation RED" "PLANT_P4_NOCACHE" "raw_tokens_reconciles_with_s134_recorded_figures"

# --- C: the control — reword a printed message, change no behaviour -----------------------------
# The refusal SENTENCE for an unknown verdict is user-facing text; the tests bind to the VALUE.
perl -0pi -e 's/phase 1 admits ONLY/phase one permits solely/s' "$SRC"
if ! grep -qF "phase one permits solely" "$SRC"; then
  fail "C control plant landed" "the reword did not apply — the control proves nothing"
  cp "$BACKUP/mod.rs" "$SRC"
else
  if cargo test --lib "crew::" >/dev/null 2>&1; then
    pass "C control: rewording a MESSAGE keeps every crew test GREEN (value-bound, S122)"
  else
    fail "C control: a mere reword turned the suite RED" "the tests are diffing bytes, not governing behaviour"
  fi
  cp "$BACKUP/mod.rs" "$SRC"
fi

# --- POS: the positive control — baseline suite exits 0 CLEANLY (S134) --------------------------
# Not "one green line": the whole crew suite must exit 0, restored to pristine source.
if cargo test --lib "crew::" >/dev/null 2>&1; then
  CODE=0; else CODE=$?; fi
if [ "${CODE:-1}" -eq 0 ]; then
  pass "POS positive control: pristine crew suite exits 0 CLEANLY (not just one green line)"
else
  fail "POS positive control: pristine crew suite did not exit 0 (exit ${CODE})" "the plants did not fully restore"
fi

echo ""
echo "fixture-135: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
