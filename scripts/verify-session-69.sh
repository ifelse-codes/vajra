#!/usr/bin/env bash
# Session 69 — The QA station (the pipeline's WORKS gate, the 6th governed station).
# "Verification = exit 0" was a house rule: verify scripts + .ai/verify/ artifacts exist by
# convention, but no gate checked a session's verify existed, ran, or passed at close.
#   SURFACE  — `vajra next --qa NN` prints session NN's recorded verify contract (expected
#              script, recorded runs, latest) read-only — nothing executes.
#   GATE     — `vajra next --check-qa NN` RE-RUNS the script LIVE and BLOCKS (exit 1) on
#              non-zero — a previously recorded green is never accepted as proof (no
#              stale-green, killed by construction: the marker here is EXECUTABLE).
#              Wired into `--advance` on the session being CLOSED
#              (L2/L3 block · L1 advise on the live result · VAJRA_SKIP_QA_GATE=1 override).
# No script (NO-CODE ground-truth / legacy) WARNS at most — the deletion dodge named plainly.
# The binary SURFACES + ENFORCES the recorded contract — it never writes or fixes a test.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="69"
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

# --- The new QA unit tests must exist and pass ---
run_check "test-patterns-verify-not-demo"  cargo test --lib qa::tests::verify_patterns_reads_verify_section_not_demo
run_check "test-patterns-fallback"         cargo test --lib qa::tests::verify_patterns_falls_back_on_missing_file_or_keys
run_check "test-contract-resolves"         cargo test --lib qa::tests::gather_contract_resolves_script_and_recorded_runs
run_check "test-no-script-never-runs"      cargo test --lib qa::tests::qa_report_no_script_warns_never_runs
run_check "test-live-green-vs-red"         cargo test --lib qa::tests::qa_report_live_green_passes_live_red_blocks
run_check "test-unevaluable-fails"         cargo test --lib qa::tests::qa_report_unevaluable_run_fails_never_silently_passes
run_check "test-runner-real-exit-codes"    cargo test --lib qa::tests::run_verify_script_returns_the_real_exit_code
run_check "test-gate-red-green-missing"    cargo test --lib qa::tests::gate_blocks_live_red_passes_live_green_warns_missing

# --- Own the spine: no 8th command, rides `vajra next`, no new dependency, no second store ---
run_check "no-8th-command"    bash -c 'git diff --quiet main -- src/main.rs && ! grep -q qa src/main.rs'
run_check "rides-next"        bash -c "grep -q -- '--qa' '$ROOT/src/cli/next.rs' && grep -q -- '--check-qa' '$ROOT/src/cli/next.rs'"
run_check "no-new-dependency" bash -c 'git diff --quiet main -- Cargo.toml'
run_check "no-second-store"   bash -c '! test -e "'"$ROOT"'/qa.md" && ! test -e "'"$ROOT"'/execution.md" && ! test -e "'"$ROOT"'/plan.md" && ! test -e "'"$ROOT"'/spec.md"'

# ============================================================================
# Temp Vajra GIT repo whose session 51 is CLOSING (SESSION=51, covered plan, no ## Execution so
# the Coder gate only WARNS, 3 ranked options) and whose session 52 prompt is APPROVED +
# well-formed — so only the QA gate is under test. Real passing/failing verify scripts drive it.
# ============================================================================
E2E="$ARTIFACTS/e2e"; rm -rf "$E2E"
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions" "$E2E/scripts"
echo "51" > "$E2E/.ai/SESSION"
# L3 = non-interactive advance; the verify section proves the gate reads the spine patterns.
{ printf 'version: 3\nmaturity: L3\n\nverify:\n'
  printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n"
  printf "  artifacts_dir: '.ai/verify/session-{NN}/'\n"
} > "$E2E/.ai/CONSTRAINTS.yaml"
printf '# Session Boot\n- **Number:** 51\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/51-task-x.md`\n' > "$E2E/.ai/TASK.md"
printf '# Vajra — Working Roadmap\n' > "$E2E/.ai/ROADMAP.md"
{ printf '# S51 summary\n\n## Next — ranked candidates (S52)\n\n'
  printf -- '- **A — one.**\n- **B — two.**\n- **C — three.**\n'
} > "$E2E/sessions/session-51-summary.md"
cat > "$E2E/prompts/52-task-y.md" <<'P'
# Session 52 — y: the next slice
> **Status:** APPROVED
## Goal
Do the next thing.
## Acceptance (testable, EARS-style)
1. WHEN run THEN it works.
## Deliverables
- a thing
## Plan
1. do it — covers: 1
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
cat > "$E2E/prompts/51-task-x.md" <<'P'
# Session 51 — x: a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN built THEN it works.
## Deliverables
- a thing
## Plan
1. build the thing — covers: 1
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-51-x )

V51="$E2E/scripts/verify-session-51.sh"
green_51() { printf 'echo "51 checks running"\nexit 0\n' > "$V51"; }
red_51()   { printf 'echo "51 checks running"\nexit 3\n' > "$V51"; }

# --- SURFACE (Acceptance #1): `--qa 51` shows the recorded contract, read-only. ---
qa_surfaces_missing_script() {
  rm -f "$V51"
  local out; out="$( cd "$E2E" && "$BIN" next --qa 51 )"
  echo "$out" | grep -q 'scripts/verify-session-51.sh' \
    && echo "$out" | grep -q 'MISSING' \
    && echo "$out" | grep -q '0 recorded runs'
}
run_check "e2e-qa-surfaces-missing-script" qa_surfaces_missing_script

qa_surfaces_recorded_contract() {
  green_51
  mkdir -p "$E2E/.ai/verify/session-51/20260101T000000Z" \
           "$E2E/.ai/verify/session-51/20260102T000000Z"
  ln -sfn "20260102T000000Z" "$E2E/.ai/verify/session-51/latest"
  local out; out="$( cd "$E2E" && "$BIN" next --qa 51 )"
  echo "$out" | grep -q '(exists)' \
    && echo "$out" | grep -q '2 recorded runs' \
    && echo "$out" | grep -q 'latest → 20260102T000000Z' \
    && echo "$out" | grep -q 'RE-RUNS the script live'
}
run_check "e2e-qa-surfaces-recorded-contract" qa_surfaces_recorded_contract

# --- GATE (Acceptance #2): --check-qa RE-RUNS live; red BLOCKS naming the live exit code. ---
check_qa_blocks_live_red() {
  red_51
  local out; out="$( cd "$E2E" && "$BIN" next --check-qa 51 2>&1 || true )"
  ( cd "$E2E" && ! "$BIN" next --check-qa 51 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'exited 3' \
    && echo "$out" | grep -q 'recorded green'
}
run_check "e2e-check-qa-blocks-live-red" check_qa_blocks_live_red

# The no-stale-green core: recorded runs + latest all LOOK green, but the script is red NOW —
# the gate re-executes the evidence and still blocks. A recorded green is never trusted.
check_qa_kills_stale_green() {
  red_51   # recorded artifacts (incl. latest) still present from the surface case
  ( cd "$E2E" && ! "$BIN" next --check-qa 51 >/dev/null 2>&1 )
}
run_check "e2e-check-qa-kills-stale-green" check_qa_kills_stale_green

check_qa_passes_live_green() {
  green_51
  ( cd "$E2E" && "$BIN" next --check-qa 51 ) | grep -q 'READY'
}
run_check "e2e-check-qa-passes-live-green" check_qa_passes_live_green

# --- LEGACY (Acceptance #4): no script -> WARN at most, the deletion dodge named plainly. ---
check_qa_warns_no_script() {
  rm -f "$V51"
  local out; out="$( cd "$E2E" && "$BIN" next --check-qa 51 )"
  echo "$out" | grep -q 'READY' \
    && echo "$out" | grep -q 'deleting the script' \
    && echo "$out" | grep -q 'self-granted jurisdiction'
}
run_check "e2e-check-qa-warns-no-script" check_qa_warns_no_script

# ============================================================================
# GATE wired into --advance (Acceptance #3): the CLOSING session cannot advance while its
# verify does not pass a LIVE re-run.
# ============================================================================
advance_blocks_live_red() {
  red_51
  ( cd "$E2E" && ! "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "51" ]
}
run_check "e2e-advance-blocks-live-red" advance_blocks_live_red

# The documented override lets a founder proceed anyway (51 -> 52) — the QA station's OWN
# override, distinct from the other stages'. It skips the slow live run itself (disclosed).
advance_override_skips_live_run() {
  local out; out="$( cd "$E2E" && VAJRA_SKIP_QA_GATE=1 "$BIN" next --advance 2>&1 )"
  echo "$out" | grep -q 'VAJRA_SKIP_QA_GATE set' \
    && [ "$(cat "$E2E/.ai/SESSION")" = "52" ]
}
run_check "e2e-advance-override-skips-live-run" advance_override_skips_live_run

# Reset to 51, then a live-green verify -> --advance passes (51 -> 52).
advance_passes_live_green() {
  echo "51" > "$E2E/.ai/SESSION"
  green_51
  ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "52" ]
}
run_check "e2e-advance-passes-live-green" advance_passes_live_green

# At L1 the gate ADVISES on the LIVE result instead of blocking (the branch the S67 review
# taught us to exercise): the red run prints the advisory and the advance still proceeds.
advance_l1_advises() {
  echo "51" > "$E2E/.ai/SESSION"
  { printf 'version: 3\nmaturity: L1\n\nverify:\n'
    printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n"
    printf "  artifacts_dir: '.ai/verify/session-{NN}/'\n"
  } > "$E2E/.ai/CONSTRAINTS.yaml"
  red_51
  local out rc
  out="$( cd "$E2E" && echo y | "$BIN" next --advance 2>&1 )"
  rc=$?
  { printf 'version: 3\nmaturity: L3\n\nverify:\n'
    printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n"
    printf "  artifacts_dir: '.ai/verify/session-{NN}/'\n"
  } > "$E2E/.ai/CONSTRAINTS.yaml"
  [ $rc -eq 0 ] && echo "$out" | grep -q 'L1 advise' \
    && echo "$out" | grep -q 'exited 3' \
    && [ "$(cat "$E2E/.ai/SESSION")" = "52" ]
}
run_check "e2e-advance-l1-advises" advance_l1_advises

# --- Real run on THIS repo: --qa 69 surfaces this session's contract — whose script is THIS
#     file (the station dogfoods itself; `--check-qa 69` re-runs it live at close). ---
real_repo_qa_surfaces() {
  local out; out="$("$BIN" next --qa 69)"
  echo "$out" | grep -q 'scripts/verify-session-69.sh' && echo "$out" | grep -q '(exists)'
}
run_check "real-repo-qa-surfaces-69" real_repo_qa_surfaces

# --- Summary artifact carries the honest verdict (the fakest green: a green verify only proves
#     what its author chose to check; deleting the script is the named dodge) ---
summary_present() {
  local S="$ROOT/sessions/session-69-summary.md"
  [ -f "$S" ] && grep -qi 'qa' "$S" && grep -qi 'stale-green\|live re-run\|re-runs' "$S"
}
run_check "summary-artifact-present" summary_present

# --- Independent cold fidelity review exists (DECISION-002 gate) ---
run_check "cold-review-present" test -f "$ROOT/sessions/session-69-review.md"

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
else echo "RED ($PASS pass, $FAIL fail)"; exit 1
fi
