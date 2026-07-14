#!/usr/bin/env bash
# Session 62 — The ANALYST's Intake + Options half, made REAL (finishes the S54 REJECT).
# Two changes, one story — the binary SURFACES + ENFORCES, it never AUTHORS:
#   J1  INTAKE  — `vajra next --intake` (and the head of `--scaffold`) surfaces the REAL inputs the
#                 author must fold into the Goal: the prior `.ai/SESSION` + the ROADMAP "Next builds"
#                 block. The job comes from context, not a bare slug (the S54 "takes a literal slug").
#   J2  OPTIONS — the gate ENFORCES a RECORDED count: a session summary must carry EXACTLY 3 ranked
#                 next candidates (end_of_session.must_present_n_options). `vajra next --check-options
#                 NN` BLOCKS (exit 1) on 2 or 4, PASSES on 3; `--advance` blocks closing a session
#                 whose summary records the wrong count. Same "enforce a recorded thing" move S61 made
#                 for Delta — the binary does NOT compute/author the options.
# Moves the S54 cold review 3-of-5 -> 5-of-5 (Gate S54 · Generate+Delta S61 · Intake+Options S62).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="62"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

BIN="$ROOT/target/debug/vajra"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-48s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-48s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "cargo-build"   cargo build

# --- The new unit tests must exist and pass (intake extraction + options counting/gate) ---
run_check "test-extract-next-builds"  cargo test --lib analyst::tests::extract_next_builds_collects_only_the_block
run_check "test-gather-intake"        cargo test --lib analyst::tests::gather_intake_reads_session_and_roadmap
run_check "test-count-options"        cargo test --lib analyst::tests::count_ranked_options_counts_distinct_letters
run_check "test-options-gate"         cargo test --lib analyst::tests::options_gate_blocks_wrong_count_passes_three_warns_absent

# --- Own the spine: no 8th command, rides `vajra next`, no new dependency, no second store ---
run_check "no-8th-command"    bash -c 'git diff --quiet main -- src/main.rs && ! grep -q analyst src/main.rs'
run_check "rides-next"        bash -c "grep -q -- '--intake' '$ROOT/src/cli/next.rs' && grep -q -- '--check-options' '$ROOT/src/cli/next.rs'"
run_check "no-new-dependency" bash -c 'git diff --quiet main -- Cargo.toml'
run_check "no-second-store-in-repo" bash -c '! test -e "'"$ROOT"'/spec.md" && ! test -d "'"$ROOT"'/specs" && ! test -e "'"$ROOT"'/SPEC.md"'

# ============================================================================
# End-to-end J1 (INTAKE): a real run surfaces the prior session + ROADMAP next-builds.
# ============================================================================
E2E="$ARTIFACTS/e2e"; rm -rf "$E2E"; mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions"
echo "40" > "$E2E/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"   # L3 = non-interactive advance
printf '# Session Boot\n- **Number:** 40\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/40-task-x.md`\n\n## Always-True\n- keep this prose\n' \
  > "$E2E/.ai/TASK.md"
# A ROADMAP with a real "Next builds" block + a later **Prior entry carrying a stray `1.` to ignore.
cat > "$E2E/.ai/ROADMAP.md" <<'ROADMAP'
# Vajra — Working Roadmap

### Next builds — ranked

Intro prose (not a list item).

1. **🥇 build the planner stage — the second pipeline specialist.**
2. **🥈 a paid dogfood run — measure the experience.**
3. **🥉 harden the gate — signer + ledger-verify.**

**Prior · Session 39 — a past entry.**
1. a stray numbered line that must NOT be surfaced.
ROADMAP
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-41-x )

# J1 / Acceptance #1: --intake prints the prior session number + the ROADMAP next-builds items.
intake_surfaces_inputs() {
  local out
  out="$( cd "$E2E" && "$BIN" next --intake )"
  echo "$out" | grep -q 'prior session (.ai/SESSION): 40' \
    && echo "$out" | grep -q 'planner stage' \
    && echo "$out" | grep -q 'paid dogfood run' \
    && echo "$out" | grep -q 'harden the gate' \
    && ! echo "$out" | grep -q 'must NOT be surfaced'
}
run_check "e2e-intake-surfaces-inputs" intake_surfaces_inputs

# The generate step (--scaffold) also surfaces the intake before writing the prompt.
scaffold_surfaces_intake() {
  local out
  out="$( cd "$E2E" && "$BIN" next --scaffold 41 planner-stage )"
  echo "$out" | grep -q 'analyst intake' \
    && echo "$out" | grep -q 'prior session (.ai/SESSION): 40' \
    && echo "$out" | grep -q 'scaffolded prompts/41-task-planner-stage.md'
}
run_check "e2e-scaffold-surfaces-intake" scaffold_surfaces_intake

# ============================================================================
# End-to-end J2 (OPTIONS): the gate BLOCKS on 2/4 recorded options, PASSES on exactly 3.
# ============================================================================
SUM="$E2E/sessions/session-62-summary.md"
sum_with() {   # sum_with A B C ...  -> write a summary with a candidates section of those options
  { printf '# Session 62 summary\n\n## Next — ranked candidates (S63)\n\n'
    for L in "$@"; do printf -- '- **%s 🥇 — a candidate.**\n  *Goal:* do the thing.\n' "$L"; done
  } > "$SUM"
}

# 2 options -> BLOCK (exit 1) and the reason names the count.
options_gate_blocks_two() {
  sum_with A B
  local out; out="$( cd "$E2E" && "$BIN" next --check-options 62 2>&1 || true )"
  ( cd "$E2E" && ! "$BIN" next --check-options 62 >/dev/null 2>&1 ) \
    && echo "$out" | grep -qi 'not exactly 3'
}
run_check "e2e-options-blocks-2" options_gate_blocks_two

# 4 options -> BLOCK.
options_gate_blocks_four() {
  sum_with A B C D
  ( cd "$E2E" && ! "$BIN" next --check-options 62 >/dev/null 2>&1 )
}
run_check "e2e-options-blocks-4" options_gate_blocks_four

# Exactly 3 -> PASS (exit 0, READY).
options_gate_passes_three() {
  sum_with A B C
  ( cd "$E2E" && "$BIN" next --check-options 62 ) | grep -q 'READY'
}
run_check "e2e-options-passes-3" options_gate_passes_three

# ============================================================================
# End-to-end J2 wired into --advance: closing a session on the wrong option count BLOCKS.
# ============================================================================
# Build an APPROVED, well-formed, substantive-delta prompt for the NEXT session (41) so the prompt
# gate passes and only the OPTIONS gate (on the closing session, 40) is under test.
cat > "$E2E/prompts/41-task-planner-stage.md" <<'P'
# Session 41 — planner-stage: a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Deliverables
- a thing
## Acceptance
1. it works
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
# Closing session 40 has a 2-option summary -> --advance refuses, SESSION stays 40.
advance_blocks_wrong_options() {
  { printf '# S40 summary\n\n## Next — ranked candidates (S41)\n\n'
    printf -- '- **A — one.**\n- **B — two.**\n'
  } > "$E2E/sessions/session-40-summary.md"
  ( cd "$E2E" && ! "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "40" ]
}
run_check "e2e-advance-blocks-wrong-options" advance_blocks_wrong_options

# Fix to exactly 3 -> --advance passes (40 -> 41).
advance_passes_three_options() {
  { printf '# S40 summary\n\n## Next — ranked candidates (S41)\n\n'
    printf -- '- **A — one.**\n- **B — two.**\n- **C — three.**\n'
  } > "$E2E/sessions/session-40-summary.md"
  ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "41" ]
}
run_check "e2e-advance-passes-3-options" advance_passes_three_options

# --- Real run on THIS repo: intake surfaces this repo's inputs; S61 summary has exactly 3 options ---
run_check "real-repo-intake"          bash -c "'$BIN' next --intake | grep -q 'prior session (.ai/SESSION): 61'"
run_check "real-repo-check-options-61" bash -c "'$BIN' next --check-options 61 | grep -q READY"

# --- Summary artifact carries the honest verdict (3-of-5 -> 5-of-5; REJECT ACCEPT-able) ---
summary_present() {
  local S="$ROOT/sessions/session-62-summary.md"
  [ -f "$S" ] \
    && grep -qi 'intake'  "$S" \
    && grep -qi 'option'  "$S" \
    && grep -qi '5 of 5\|5-of-5\|5/5' "$S"
}
run_check "summary-artifact-present" summary_present

# --- Independent cold fidelity review exists (DECISION-002 gate) ---
run_check "cold-review-present" test -f "$ROOT/sessions/session-62-review.md"

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
printf '%-48s %s\n' "STEP" "RESULT"
printf '%-48s %s\n' "------------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
