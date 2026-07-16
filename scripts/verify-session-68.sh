#!/usr/bin/env bash
# Session 68 — The CODER handoff (the pipeline's CODE/execution gate, the LAST station).
# The Analyst governs the WHAT; the Architect the DESIGN; the Planner the HOW-plan; the Coder
# governs the DID — the execution trace from the covered plan to the commits that landed it.
#   SURFACE  — `vajra next --exec NN` prints session NN's numbered plan steps as the execution
#              checklist, each step's recorded state marked (done <sha> / fake / unrecorded).
#   GATE     — `vajra next --check-exec NN` BLOCKS (exit 1) when any numbered plan step lacks a
#              recorded `step N — done: <sha>` whose sha EXISTS (`git cat-file -e` — the S67
#              existence lesson, git-shaped); a legacy prompt (no `## Execution`) WARNS at most.
#              Wired into `--advance` on the session being CLOSED
#              (L2/L3 block · L1 advise · VAJRA_SKIP_CODER_GATE=1 override).
# The binary SURFACES + ENFORCES a recorded trace — it never CODES and never judges semantics.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="68"
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

# --- The new Coder unit tests must exist and pass ---
run_check "test-execution-record-parse"  cargo test --lib coder::tests::execution_record_parses_step_done_sha
run_check "test-legacy-never-blocks"     cargo test --lib coder::tests::no_plan_and_no_execution_never_block
run_check "test-unrecorded-blocks"       cargo test --lib coder::tests::unrecorded_step_blocks
run_check "test-fake-sha-unrecorded"     cargo test --lib coder::tests::fake_sha_is_classified_unrecorded
run_check "test-recorded-passes"         cargo test --lib coder::tests::fully_recorded_passes
run_check "test-commit-exists-real-git"  cargo test --lib coder::tests::commit_exists_gates_against_the_real_repo
run_check "test-fresh-scaffold"          cargo test --lib coder::tests::fresh_scaffold_is_no_plan_not_blocking

# --- Own the spine: no 8th command, rides `vajra next`, no new dependency, no second store ---
run_check "no-8th-command"    bash -c 'git diff --quiet main -- src/main.rs && ! grep -q coder src/main.rs'
run_check "rides-next"        bash -c "grep -q -- '--exec' '$ROOT/src/cli/next.rs' && grep -q -- '--check-exec' '$ROOT/src/cli/next.rs'"
run_check "no-new-dependency" bash -c 'git diff --quiet main -- Cargo.toml'
run_check "no-second-store"   bash -c '! test -e "'"$ROOT"'/execution.md" && ! test -d "'"$ROOT"'/runs" && ! test -e "'"$ROOT"'/plan.md" && ! test -e "'"$ROOT"'/spec.md"'

# ============================================================================
# Build a temp GIT repo whose session 51 is CLOSING (SESSION=51, covered plan, 3 ranked options)
# and whose session 52 prompt is APPROVED + well-formed, so only the CODER gate is under test.
# Real commits give real shas; 9999999 is the made-up one.
# ============================================================================
E2E="$ARTIFACTS/e2e"; rm -rf "$E2E"
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions"
echo "51" > "$E2E/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"   # L3 = non-interactive advance
printf '# Session Boot\n- **Number:** 51\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/51-task-x.md`\n' > "$E2E/.ai/TASK.md"
printf '# Vajra — Working Roadmap\n' > "$E2E/.ai/ROADMAP.md"
# Closing session 51 records EXACTLY 3 ranked options so the Options gate passes.
{ printf '# S51 summary\n\n## Next — ranked candidates (S52)\n\n'
  printf -- '- **A — one.**\n- **B — two.**\n- **C — three.**\n'
} > "$E2E/sessions/session-51-summary.md"
# Session 52's prompt: Analyst/Architect/Planner gates all green (the into-gates are not under test).
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

# Header of the CLOSING session-51 prompt: covered plan of 2 steps; each case appends ## Execution.
P51_HEAD=$(cat <<'P'
# Session 51 — x: a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN built THEN it surfaces.
2. WHEN gated THEN it blocks.
## Deliverables
- a thing
## Plan
1. build the thing — covers: 1
2. gate the thing — covers: 2
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
)
write_p51() { printf '%s\n%s\n' "$P51_HEAD" "$1" > "$E2E/prompts/51-task-x.md"; }
write_p51 ""
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-51-x )
REAL=$(cd "$E2E" && git rev-parse --short HEAD)
FAKE="9999999"

# --- SURFACE (Acceptance #1): `--exec 51` lists the plan steps with each recorded state. ---
exec_surfaces_checklist() {
  write_p51 $'## Execution\n- step 1 — done: '"$REAL"$'\n- step 2 — done: '"$FAKE"
  local out; out="$( cd "$E2E" && "$BIN" next --exec 51 )"
  echo "$out" | grep -q "\[✓\] step 1 — done: $REAL" \
    && echo "$out" | grep -q "\[✗\] step 2 — done: $FAKE" \
    && echo "$out" | grep -q 'classified unrecorded'
}
run_check "e2e-exec-surfaces-checklist" exec_surfaces_checklist

# --- GATE (Acceptance #2+3): --check-exec BLOCKS unrecorded and fake-sha traces. ---
check_exec_blocks_unrecorded() {
  write_p51 $'## Execution\n- step 1 — done: '"$REAL"
  local out; out="$( cd "$E2E" && "$BIN" next --check-exec 51 2>&1 || true )"
  ( cd "$E2E" && ! "$BIN" next --check-exec 51 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'step(s) 2'
}
run_check "e2e-check-exec-blocks-unrecorded" check_exec_blocks_unrecorded

check_exec_blocks_fake_sha() {
  write_p51 $'## Execution\n- step 1 — done: '"$REAL"$'\n- step 2 — done: '"$FAKE"
  ( cd "$E2E" && ! "$BIN" next --check-exec 51 >/dev/null 2>&1 )
}
run_check "e2e-check-exec-blocks-fake-sha" check_exec_blocks_fake_sha

# --- PASS: every step records a commit that EXISTS -> READY (exit 0). ---
check_exec_passes_recorded() {
  write_p51 $'## Execution\n- step 1 — done: '"$REAL"$'\n- step 2 — done: '"$REAL"
  ( cd "$E2E" && "$BIN" next --check-exec 51 ) | grep -q 'READY'
}
run_check "e2e-check-exec-passes-recorded" check_exec_passes_recorded

# --- LEGACY (Acceptance #4): no ## Execution section -> WARN at most; no plan -> WARN. ---
check_exec_warns_legacy() {
  write_p51 ""
  local out; out="$( cd "$E2E" && "$BIN" next --check-exec 51 )"
  echo "$out" | grep -q 'READY' && echo "$out" | grep -qi 'no `## Execution`'
}
run_check "e2e-check-exec-warns-legacy" check_exec_warns_legacy

check_exec_warns_no_plan() {
  printf '# Session 51 — x\n> **Status:** APPROVED\n## Goal\ng\n' > "$E2E/prompts/51-task-x.md"
  local out; out="$( cd "$E2E" && "$BIN" next --check-exec 51 )"
  echo "$out" | grep -q 'READY' && echo "$out" | grep -qi 'nothing to trace'
}
run_check "e2e-check-exec-warns-no-plan" check_exec_warns_no_plan

# ============================================================================
# GATE wired into --advance (Acceptance #3+5): the CLOSING session cannot advance with an
# unrecorded/fake execution trace.
# ============================================================================
advance_blocks_unrecorded() {
  write_p51 $'## Execution\n- step 1 — done: '"$REAL"$'\n- step 2 — done: '"$FAKE"
  ( cd "$E2E" && ! "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "51" ]
}
run_check "e2e-advance-blocks-unrecorded" advance_blocks_unrecorded

# The documented override lets a founder proceed anyway (51 -> 52) — the Coder's OWN override,
# distinct from the other stages' (each stage overrides alone).
advance_override_skips_gate() {
  ( cd "$E2E" && VAJRA_SKIP_CODER_GATE=1 "$BIN" next --advance ) \
    && [ "$(cat "$E2E/.ai/SESSION")" = "52" ]
}
run_check "e2e-advance-override-skips-gate" advance_override_skips_gate

# Reset to 51, then a fully recorded trace -> --advance passes (51 -> 52).
advance_passes_recorded() {
  echo "51" > "$E2E/.ai/SESSION"
  write_p51 $'## Execution\n- step 1 — done: '"$REAL"$'\n- step 2 — done: '"$REAL"
  ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "52" ]
}
run_check "e2e-advance-passes-recorded" advance_passes_recorded

# At L1 the gate ADVISES instead of blocking (the unexercised branch the S67 review flagged —
# exercised here): an unrecorded trace prints the advisory and the advance still proceeds.
advance_l1_advises() {
  echo "51" > "$E2E/.ai/SESSION"
  printf 'version: 3\nmaturity: L1\n' > "$E2E/.ai/CONSTRAINTS.yaml"
  write_p51 $'## Execution\n- step 1 — done: '"$REAL"$'\n- step 2 — done: '"$FAKE"
  local out; out="$( cd "$E2E" && echo y | "$BIN" next --advance 2>&1 )"
  local rc=$?
  printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"
  [ $rc -eq 0 ] && echo "$out" | grep -q 'L1 advise' \
    && [ "$(cat "$E2E/.ai/SESSION")" = "52" ]
}
run_check "e2e-advance-l1-advises" advance_l1_advises

# --- Real run on THIS repo: --exec 68 surfaces this session's plan; --check-exec 68 READY
#     (this prompt dogfoods its own gate: its ## Execution records real landed commits). ---
real_repo_exec_surfaces() {
  local out; out="$("$BIN" next --exec 68)"
  echo "$out" | grep -q 'step 1' && echo "$out" | grep -q 'prompts/68-task-coder-handoff.md'
}
run_check "real-repo-exec-surfaces-68" real_repo_exec_surfaces
run_check "real-repo-check-exec-68"    bash -c "'$BIN' next --check-exec 68 | grep -q READY"

# --- The Analyst scaffold now carries the ## Execution placeholder (symmetric with Plan/Design) ---
scaffold_carries_execution() {
  local T; T="$(mktemp -d)"
  ( cd "$T" && mkdir -p .ai && "$BIN" next --scaffold 10 demo-slug >/dev/null 2>&1 )
  grep -q '## Execution' "$T/prompts/10-task-demo-slug.md" \
    && grep -q 'done:' "$T/prompts/10-task-demo-slug.md"
  local RC=$?; rm -rf "$T"; return $RC
}
run_check "scaffold-carries-execution-placeholder" scaffold_carries_execution

# --- Summary artifact carries the honest verdict (the fakest green: form+existence, not semantics) ---
summary_present() {
  local S="$ROOT/sessions/session-68-summary.md"
  [ -f "$S" ] && grep -qi 'coder' "$S" && grep -qi 'done:\|execution trace' "$S"
}
run_check "summary-artifact-present" summary_present

# --- Independent cold fidelity review exists (DECISION-002 gate) ---
run_check "cold-review-present" test -f "$ROOT/sessions/session-68-review.md"

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
