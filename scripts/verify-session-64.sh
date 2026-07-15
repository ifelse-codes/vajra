#!/usr/bin/env bash
# Session 64 — The PLANNER stage (the pipeline's 2nd governed specialist).
# The Analyst governs the WHAT (intent -> the accepted next prompt); the Planner governs the HOW:
# it turns that accepted prompt into an ordered, COVERAGE-CHECKED `## Plan` *before* any code.
#   SURFACE  — `vajra next --plan NN` prints the prompt's acceptance criteria as the checklist to
#              plan against (the plan derives from the contract, not thin air).
#   GATE     — `vajra next --check-plan NN` BLOCKS (exit 1) a missing-of-a-real-plan (placeholder)
#              or an UNCOVERED plan (some acceptance criterion cited by no step), PASSES a covering
#              plan; a wholly ABSENT `## Plan` on a legacy prompt only WARNS. Wired into `--advance`
#              (L2/L3 block · L1 advise · VAJRA_SKIP_PLANNER_GATE=1 override).
# The binary SURFACES + ENFORCES a recorded `covers: N` mapping — it never AUTHORS a plan step.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="64"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

BIN="$ROOT/target/debug/vajra"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-52s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-52s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "cargo-build"   cargo build

# --- The new Planner unit tests must exist and pass ---
run_check "test-acceptance-extract"  cargo test --lib planner::tests::acceptance_criteria_extracted_and_scoped
run_check "test-covers-parse"        cargo test --lib planner::tests::cited_criteria_parses_covers_marker
run_check "test-covers-wrapped"      cargo test --lib planner::tests::covers_on_wrapped_continuation_line_is_counted
run_check "test-gate-states"         cargo test --lib planner::tests::gate_blocks_placeholder_then_uncovered_then_passes_covered
run_check "test-fresh-scaffold-plan" cargo test --lib planner::tests::fresh_scaffold_plan_is_placeholder

# --- Own the spine: no 8th command, rides `vajra next`, no new dependency, no second store ---
run_check "no-8th-command"    bash -c 'git diff --quiet main -- src/main.rs && ! grep -q planner src/main.rs'
run_check "rides-next"        bash -c "grep -q -- '--plan' '$ROOT/src/cli/next.rs' && grep -q -- '--check-plan' '$ROOT/src/cli/next.rs'"
run_check "no-new-dependency" bash -c 'git diff --quiet main -- Cargo.toml'
run_check "no-second-store"   bash -c '! test -e "'"$ROOT"'/plan.md" && ! test -d "'"$ROOT"'/plans" && ! test -e "'"$ROOT"'/spec.md" && ! test -d "'"$ROOT"'/specs"'

# ============================================================================
# Build a temp repo whose prompt for session 51 is APPROVED + well-formed + substantive-delta, so
# only the PLANNER gate is under test. Its acceptance has TWO criteria (1, 2). We then vary its
# `## Plan`.
# ============================================================================
E2E="$ARTIFACTS/e2e"; rm -rf "$E2E"; mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions"
echo "50" > "$E2E/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"   # L3 = non-interactive advance
printf '# Session Boot\n- **Number:** 50\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/50-task-x.md`\n' > "$E2E/.ai/TASK.md"
printf '# Vajra — Working Roadmap\n' > "$E2E/.ai/ROADMAP.md"
# Closing session 50 records EXACTLY 3 ranked options so the Options gate passes.
{ printf '# S50 summary\n\n## Next — ranked candidates (S51)\n\n'
  printf -- '- **A — one.**\n- **B — two.**\n- **C — three.**\n'
} > "$E2E/sessions/session-50-summary.md"

# Header of the session-51 prompt: everything EXCEPT the `## Plan`, which each case appends.
P51_HEAD=$(cat <<'P'
# Session 51 — x: a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN run THEN it surfaces.
2. WHEN uncovered THEN it blocks.
## Deliverables
- a thing
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
)
write_p51() { printf '%s\n%s\n' "$P51_HEAD" "$1" > "$E2E/prompts/51-task-x.md"; }
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-51-x )

# --- SURFACE (Acceptance #1): `--plan 51` surfaces the two acceptance criteria on a REAL prompt. ---
write_p51 "## Plan"
plan_surfaces_criteria() {
  local out; out="$( cd "$E2E" && "$BIN" next --plan 51 )"
  echo "$out" | grep -q '\[1\]' \
    && echo "$out" | grep -q '\[2\]' \
    && echo "$out" | grep -qi 'WHEN run THEN it surfaces' \
    && echo "$out" | grep -q 'covers: N'
}
run_check "e2e-plan-surfaces-criteria" plan_surfaces_criteria

# --- GATE (Acceptance #2): --check-plan BLOCKS placeholder / uncovered, PASSES covering. ---
# Placeholder plan (the scaffold `<...>`) -> BLOCK (exit 1).
check_plan_blocks_placeholder() {
  write_p51 $'## Plan (ordered — cite `covers: N`)\n1. <first step — replace me>\n2. <next step>'
  ( cd "$E2E" && ! "$BIN" next --check-plan 51 >/dev/null 2>&1 )
}
run_check "e2e-check-plan-blocks-placeholder" check_plan_blocks_placeholder

# Uncovered plan (only criterion 1 cited) -> BLOCK, reason names the missing 2.
check_plan_blocks_uncovered() {
  write_p51 $'## Plan\n1. build the thing — covers: 1\n2. some other step'
  local out; out="$( cd "$E2E" && "$BIN" next --check-plan 51 2>&1 || true )"
  ( cd "$E2E" && ! "$BIN" next --check-plan 51 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'does not cover' \
    && echo "$out" | grep -q '2'
}
run_check "e2e-check-plan-blocks-uncovered" check_plan_blocks_uncovered

# Covering plan (both criteria cited) -> PASS (READY, exit 0).
check_plan_passes_covering() {
  write_p51 $'## Plan\n1. surface — covers: 1\n2. gate — covers: 2'
  ( cd "$E2E" && "$BIN" next --check-plan 51 ) | grep -q 'READY'
}
run_check "e2e-check-plan-passes-covering" check_plan_passes_covering

# Absent `## Plan` on a legacy prompt -> WARN only (READY, exit 0).
check_plan_warns_absent() {
  printf '%s\n' "$P51_HEAD" > "$E2E/prompts/51-task-x.md"   # header, no ## Plan at all
  local out; out="$( cd "$E2E" && "$BIN" next --check-plan 51 )"
  echo "$out" | grep -q 'READY' && echo "$out" | grep -qi 'no .*Plan'
}
run_check "e2e-check-plan-warns-absent" check_plan_warns_absent

# ============================================================================
# GATE wired into --advance: a session cannot proceed to execution on an uncovered contract.
# ============================================================================
# Uncovered plan for 51 -> --advance refuses, SESSION stays 50.
advance_blocks_uncovered() {
  write_p51 $'## Plan\n1. only-one — covers: 1'
  ( cd "$E2E" && ! "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "50" ]
}
run_check "e2e-advance-blocks-uncovered" advance_blocks_uncovered

# The documented override lets a founder proceed anyway (50 -> 51).
advance_override_skips_gate() {
  write_p51 $'## Plan\n1. only-one — covers: 1'
  ( cd "$E2E" && VAJRA_SKIP_PLANNER_GATE=1 "$BIN" next --advance ) \
    && [ "$(cat "$E2E/.ai/SESSION")" = "51" ]
}
run_check "e2e-advance-override-skips-gate" advance_override_skips_gate

# Reset to 50, then a COVERING plan -> --advance passes (50 -> 51).
advance_passes_covering() {
  echo "50" > "$E2E/.ai/SESSION"
  write_p51 $'## Plan\n1. surface — covers: 1\n2. gate — covers: 2'
  ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "51" ]
}
run_check "e2e-advance-passes-covering" advance_passes_covering

# --- Real run on THIS repo: --plan 64 surfaces this session's own 3 criteria; --check-plan 64
#     READY (this prompt now carries a covering `## Plan` — the Planner dogfooded on its own contract). ---
real_repo_plan_surfaces() {
  "$BIN" next --plan 64 | grep -q '\[3\]'
}
run_check "real-repo-plan-surfaces-64" real_repo_plan_surfaces
run_check "real-repo-check-plan-64"    bash -c "'$BIN' next --check-plan 64 | grep -q READY"

# --- Summary artifact carries the honest verdict (station one -> two; the honest limit) ---
summary_present() {
  local S="$ROOT/sessions/session-64-summary.md"
  [ -f "$S" ] \
    && grep -qi 'planner' "$S" \
    && grep -qi 'coverage\|covers' "$S"
}
run_check "summary-artifact-present" summary_present

# --- Independent cold fidelity review exists (DECISION-002 gate) ---
run_check "cold-review-present" test -f "$ROOT/sessions/session-64-review.md"

# --- Hard rule: no commit on this branch touches >3 files (<=3 files per atomic commit) ---
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
printf '%-52s %s\n' "STEP" "RESULT"
printf '%-52s %s\n' "----------------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
