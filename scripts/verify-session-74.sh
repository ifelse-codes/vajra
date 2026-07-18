#!/usr/bin/env bash
# Session 74 — the payload counter: measure whether the PIPELINE advances.
# The meta-gap named at S25/S60/S65/S70 and STILL unbuilt: every gate measures whether the RAILS
# are followed, but NOTHING measured whether the pipeline itself advances — how many governed
# stations a session actually moved a prompt through. This session records that number, K-of-8:
#   - `vajra next --stations NN` prints, per station, PASSED/ABSENT + the count — read-only.
#   - Each PASS is DERIVED from that station's OWN classifier (never a self-asserted digit).
#   - Read-only: file/git stations reuse their gate classifier; the two LIVE stations (QA, Demo-er)
#     are read STATICALLY (recorded contract, not live re-run) — the disclosed fakest green.
#   - It becomes a mandatory GT input (pipeline_advance_check) — no new store, no 8th command.
# The load-bearing property (criterion 3): the counter can NEVER disagree with a station's own
# `--check-*` gate on the same fixture, because it reuses that gate's classifier.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="74"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

BIN="$ROOT/target/debug/vajra"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-54s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-54s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "cargo-build"   cargo build

# ============================================================================
# The stations module unit tests (Acceptance #1, #2, #3) — each PASS derived from a classifier.
# ============================================================================
run_check "test-analyst-substantive-vs-placeholder" cargo test --lib stations::tests::analyst_passes_on_substantive_delta_absent_on_placeholder
run_check "test-planner-agrees-with-plan-gate"       cargo test --lib stations::tests::planner_counter_agrees_with_plan_gate_on_same_fixture
run_check "test-architect-absent-not-significant"    cargo test --lib stations::tests::architect_absent_when_not_design_significant
run_check "test-qa-demoer-static"                    cargo test --lib stations::tests::qa_and_demoer_are_static_present_vs_absent
run_check "test-releaser-merged-and-pruned"          cargo test --lib stations::tests::releaser_passes_only_when_branch_merged_and_pruned
run_check "test-reviewer-attested-accept"            cargo test --lib stations::tests::reviewer_passes_only_on_attested_accept
run_check "test-placeholder-counts-low"              cargo test --lib stations::tests::placeholder_laden_prompt_counts_low
run_check "test-fully-filled-counts-high"            cargo test --lib stations::tests::fully_filled_session_counts_high
run_check "test-exactly-eight-stations"             cargo test --lib stations::tests::report_has_exactly_eight_stations

# ============================================================================
# E2E: the real `vajra next --stations` on live fixtures (Acceptance #1, #2, #5).
# ============================================================================
E2E="$ROOT/$ARTIFACTS/e2e"; rm -rf "$E2E"
mk_repo() { # $1 = target dir — a temp governed git repo on main with the house CONSTRAINTS + spine
  local D="$1"
  mkdir -p "$D/.ai" "$D/prompts" "$D/scripts" "$D/sessions" "$D/docs/decisions"
  { printf 'version: 3\nmaturity: L2\n\nverify:\n'
    printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n"
    printf "  artifacts_dir: '.ai/verify/session-{NN}/'\n"
    printf '\ndemo:\n'
    printf "  script_pattern: 'scripts/demo-session-{NN}.sh'\n"
    printf '  required_elements: [header, cases, summary_table, before_after]\n'
    printf '\nrelease:\n  require_merged_prior: true\n  require_main_synced: true\n  require_pruned: true\n'
  } > "$D/.ai/CONSTRAINTS.yaml"
  printf '# DECISION-001 — governed pipeline\n' > "$D/docs/decisions/DECISION-001-pipeline.md"
  ( cd "$D" && git init -q -b main . && git config user.email t@t && git config user.name t \
      && git add -A && git commit -qm init ) >/dev/null 2>&1
}

# A fully-filled prompt (substantive Delta · significant+spine-citing Design · covering Plan ·
# Execution trace naming $2 as the sha).
write_full_prompt() { # $1 = repo, $2 = sha
  cat > "$1/prompts/40-task-fixture.md" <<EOF
# Session 40 — fixture

> **Status:** APPROVED

design-significant: yes

## Acceptance
1. **WHEN** x **THEN** y
2. **WHEN** a **THEN** b

## Design
Rests on DECISION-001 — the governed pipeline; real recorded rationale here.

## Plan
1. do the first thing. covers: 1
2. do the second thing. covers: 2

## Execution
- step 1 — done: $2
- step 2 — done: $2

## Delta
- \`+\` a real new capability the session adds
EOF
}

mk_repo "$E2E"
# Land scripts + review, commit, then fill the Execution trace with the real HEAD sha.
printf '#!/usr/bin/env bash\ntrue\n' > "$E2E/scripts/verify-session-40.sh"
printf '#!/usr/bin/env bash\necho demo:header demo:cases demo:summary_table demo:before_after\n' > "$E2E/scripts/demo-session-40.sh"
printf '**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** abc123\n' > "$E2E/sessions/session-40-review.md"
write_full_prompt "$E2E" "placeholder"
( cd "$E2E" && git add -A && git commit -qm "s40 scaffold" ) >/dev/null 2>&1
SHA="$(cd "$E2E" && git rev-parse HEAD)"
write_full_prompt "$E2E" "$SHA"
# Merge + prune a session-40 branch so the Releaser derives a shipped (merged+pruned) state.
( cd "$E2E" && git checkout -qb session-40-x && git add -A && git commit -qm "s40 work" \
    && git checkout -q main && git merge -q --no-ff session-40-x -m "merge 40" \
    && git branch -D session-40-x ) >/dev/null 2>&1

# The filled fixture counts HIGH (the seven non-SHIP stations pass; SHIP needs a synced origin,
# absent here, so the honest no-remote ceiling is 7/8).
filled_counts_high() {
  local out; out="$(cd "$E2E" && "$BIN" next --stations 40)"
  echo "$out" | grep -q '7 of 8 stations passed' || return 1
  echo "$out" | grep -qE '\[PASSED\] Analyst'   || return 1
  echo "$out" | grep -qE '\[PASSED\] Coder'      || return 1
  echo "$out" | grep -qE '\[PASSED\] Reviewer'   || return 1
}
run_check "e2e-filled-fixture-counts-7-of-8" filled_counts_high

# The counter AGREES with each `--check-*` gate on the SAME fixture (criterion 3 — never disagree):
# every station the counter marks PASSED, its own gate does NOT block.
counter_agrees_with_gates() {
  ( cd "$E2E" && "$BIN" next --check-design 40 >/dev/null 2>&1 ) || return 1   # Architect PASSED ⇒ gate ok
  ( cd "$E2E" && "$BIN" next --check-plan   40 >/dev/null 2>&1 ) || return 1   # Planner  PASSED ⇒ gate ok
  ( cd "$E2E" && "$BIN" next --check-exec   40 >/dev/null 2>&1 ) || return 1   # Coder    PASSED ⇒ gate ok
}
run_check "e2e-counter-agrees-with-check-gates" counter_agrees_with_gates

# A placeholder-laden prompt counts 0/8, and its Planner ABSENT AGREES with a BLOCKING --check-plan.
PH="$ROOT/$ARTIFACTS/e2e-ph"; rm -rf "$PH"; mk_repo "$PH"
cat > "$PH/prompts/40-task-ph.md" <<'EOF'
# Session 40 — placeholder

design-significant: yes

## Acceptance
1. do x

## Design
<why>

## Plan
1. <step>

## Execution
- step 1 — done: <sha>

## Delta
- `+` <what this session ADDS…>
EOF
placeholder_counts_zero_and_agrees() {
  local out; out="$(cd "$PH" && "$BIN" next --stations 40)"
  echo "$out" | grep -q '0 of 8 stations passed' || return 1
  echo "$out" | grep -qE '\[ABSENT\] Planner'    || return 1
  # The counter's Planner ABSENT must AGREE with a BLOCKING --check-plan (exit 1).
  ( cd "$PH" && ! "$BIN" next --check-plan 40 >/dev/null 2>&1 ) || return 1
}
run_check "e2e-placeholder-counts-0-and-agrees" placeholder_counts_zero_and_agrees

# The surface is read-only: `--stations` always exits 0 (a report, not a gate).
run_check "e2e-stations-exits-zero-on-placeholder" bash -c "cd '$PH' && '$BIN' next --stations 40 >/dev/null"

# ============================================================================
# Own the spine (Acceptance #5): no CLI surface change, no 8th command, no new dep, no new store.
# ============================================================================
run_check "no-main-surface-change" git diff --quiet main -- src/main.rs
run_check "no-8th-command"         bash -c "! grep -q 'stations' src/main.rs"
run_check "no-new-dependency"      git diff --quiet main -- Cargo.toml
run_check "no-second-store"        bash -c "! test -e '$ROOT/stations.md' && ! test -e '$ROOT/.ai/stations'"
# The GT input rides the existing CONSTRAINTS spine — no new file.
run_check "gt-input-wired"         bash -c "grep -q 'pipeline_advance_check' '$ROOT/.ai/CONSTRAINTS.yaml'"
# The counter is on the LIVE repo too (dogfood): --stations runs here and names all 8 lanes.
run_check "stations-live-on-repo"  bash -c "'$BIN' next --stations 73 | grep -q 'of 8 stations passed'"

# ============================================================================
# Prior harnesses stay green (Acceptance #5): verify-71/72/73 re-run unchanged.
# ============================================================================
run_check "verify-71-still-green" bash "$ROOT/scripts/verify-session-71.sh"
run_check "verify-72-still-green" bash "$ROOT/scripts/verify-session-72.sh"
run_check "verify-73-still-green" bash "$ROOT/scripts/verify-session-73.sh"

# --- Session artifacts + hard rules ---
summary_present() {
  local S="$ROOT/sessions/session-74-summary.md"
  [ -f "$S" ] && grep -qi 'station\|payload\|K-of-8\|K of 8' "$S"
}
run_check "summary-artifact-present" summary_present
run_check "cold-review-present"      test -f "$ROOT/sessions/session-74-review.md"

per_commit_file_cap() {
  local sha n
  for sha in $(git rev-list main..HEAD 2>/dev/null || true); do
    n=$(git show --name-only --format= "$sha" | grep -c . || true)
    [ "$n" -le 3 ] || return 1
  done
  return 0
}
run_check "per-commit-file-cap" per_commit_file_cap

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-54s %s\n' "STEP" "RESULT"
printf '%-54s %s\n' "------------------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1
fi
