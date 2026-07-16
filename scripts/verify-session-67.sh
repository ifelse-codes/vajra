#!/usr/bin/env bash
# Session 67 — The ARCHITECT stage (the pipeline's DESIGN gate).
# The Analyst governs the WHAT (S54+S61+S62); the Planner the HOW-plan (S64); the Architect governs
# the DESIGN decision between them: a design-significant session must RECORD its rationale first.
#   SURFACE  — `vajra next --design NN` prints the locked design spine (docs/adr/ + docs/decisions/)
#              as the checklist the `## Design` rationale must cite from, current citations marked.
#   GATE     — `vajra next --check-design NN` BLOCKS (exit 1) a design-significant prompt (recorded
#              `design-significant: yes` marker — never guessed) whose `## Design` is missing or a
#              placeholder/uncited; PASSES a substantive spine-citing rationale; a non-significant
#              or legacy prompt WARNS at most. Wired into `--advance`
#              (L2/L3 block · L1 advise · VAJRA_SKIP_ARCHITECT_GATE=1 override).
# The binary SURFACES + ENFORCES a recorded rationale — it never AUTHORS a design.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="67"
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

# --- The new Architect unit tests must exist and pass ---
run_check "test-significance-marker"  cargo test --lib architect::tests::significance_marker_is_recorded_never_guessed
run_check "test-not-significant"      cargo test --lib architect::tests::not_significant_never_blocks
run_check "test-missing-blocks"       cargo test --lib architect::tests::significant_without_section_is_missing_and_blocks
run_check "test-placeholder-blocks"   cargo test --lib architect::tests::significant_placeholder_or_uncited_blocks
run_check "test-gate-states"          cargo test --lib architect::tests::gate_blocks_missing_and_placeholder_passes_substantive
run_check "test-fresh-scaffold"       cargo test --lib architect::tests::fresh_scaffold_design_is_unrecorded_not_blocking

# --- Own the spine: no 8th command, rides `vajra next`, no new dependency, no second store ---
run_check "no-8th-command"    bash -c 'git diff --quiet main -- src/main.rs && ! grep -q architect src/main.rs'
run_check "rides-next"        bash -c "grep -q -- '--design' '$ROOT/src/cli/next.rs' && grep -q -- '--check-design' '$ROOT/src/cli/next.rs'"
run_check "no-new-dependency" bash -c 'git diff --quiet main -- Cargo.toml'
run_check "no-second-store"   bash -c '! test -e "'"$ROOT"'/design.md" && ! test -d "'"$ROOT"'/designs" && ! test -e "'"$ROOT"'/spec.md" && ! test -d "'"$ROOT"'/specs"'

# ============================================================================
# Build a temp repo whose prompt for session 51 is APPROVED + well-formed + substantive-delta +
# covered-plan, so only the ARCHITECT gate is under test. Its design spine has one ADR + one
# DECISION. We then vary its `## Design`.
# ============================================================================
E2E="$ARTIFACTS/e2e"; rm -rf "$E2E"
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions" "$E2E/docs/adr" "$E2E/docs/decisions"
echo "50" > "$E2E/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"   # L3 = non-interactive advance
printf '# Session Boot\n- **Number:** 50\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/50-task-x.md`\n' > "$E2E/.ai/TASK.md"
printf '# Vajra — Working Roadmap\n' > "$E2E/.ai/ROADMAP.md"
printf '# ADR-0001: The engine contract\n' > "$E2E/docs/adr/0001-engine-contract.md"
printf '# index\n' > "$E2E/docs/adr/README.md"
printf '# DECISION-001: Governance as product\n' > "$E2E/docs/decisions/DECISION-001-governance.md"
# Closing session 50 records EXACTLY 3 ranked options so the Options gate passes.
{ printf '# S50 summary\n\n## Next — ranked candidates (S51)\n\n'
  printf -- '- **A — one.**\n- **B — two.**\n- **C — three.**\n'
} > "$E2E/sessions/session-50-summary.md"

# Header of the session-51 prompt: Analyst + Planner gates all green; each case appends a design.
P51_HEAD=$(cat <<'P'
# Session 51 — x: a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN run THEN it surfaces the spine.
2. WHEN significant + placeholder THEN it blocks.
## Deliverables
- a thing
## Plan
1. surface — covers: 1
2. gate — covers: 2
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a real recorded change
P
)
write_p51() { printf '%s\n%s\n' "$P51_HEAD" "$1" > "$E2E/prompts/51-task-x.md"; }
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-51-x )

# --- SURFACE (Acceptance #1): `--design 51` lists the spine, marking the prompt's citations. ---
design_surfaces_spine() {
  write_p51 $'## Design\n- design-significant: yes — new interface\n- rests on ADR-0001.'
  local out; out="$( cd "$E2E" && "$BIN" next --design 51 )"
  echo "$out" | grep -q '\[✓\] ADR-0001' \
    && echo "$out" | grep -q '\[ \] DECISION-001' \
    && echo "$out" | grep -q 'SUBSTANTIVE'
}
run_check "e2e-design-surfaces-spine" design_surfaces_spine

# --- GATE (Acceptance #2): --check-design BLOCKS missing / placeholder / uncited. ---
# Recorded significant but NO ## Design section at all -> BLOCK (exit 1).
check_design_blocks_missing() {
  write_p51 $'design-significant: yes — new interface'
  local out; out="$( cd "$E2E" && "$BIN" next --check-design 51 2>&1 || true )"
  ( cd "$E2E" && ! "$BIN" next --check-design 51 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'NO `## Design`'
}
run_check "e2e-check-design-blocks-missing" check_design_blocks_missing

# Significant + template-placeholder rationale -> BLOCK.
check_design_blocks_placeholder() {
  write_p51 $'## Design\n- design-significant: yes — new interface\n- <rationale — replace me>'
  ( cd "$E2E" && ! "$BIN" next --check-design 51 >/dev/null 2>&1 )
}
run_check "e2e-check-design-blocks-placeholder" check_design_blocks_placeholder

# Significant + real text citing NO ADR/DECISION (spine exists) -> BLOCK.
check_design_blocks_uncited() {
  write_p51 $'## Design\n- design-significant: yes — new interface\n- because it felt right.'
  local out; out="$( cd "$E2E" && "$BIN" next --check-design 51 2>&1 || true )"
  ( cd "$E2E" && ! "$BIN" next --check-design 51 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'spine-citing'
}
run_check "e2e-check-design-blocks-uncited" check_design_blocks_uncited

# --- PASS (Acceptance #3): a substantive, spine-citing rationale -> READY (exit 0). ---
check_design_passes_substantive() {
  write_p51 $'## Design\n- design-significant: yes — new interface\n- mirrors DECISION-001; rides ADR-0001.'
  ( cd "$E2E" && "$BIN" next --check-design 51 ) | grep -q 'READY'
}
run_check "e2e-check-design-passes-substantive" check_design_passes_substantive

# --- NON-SIGNIFICANT (Acceptance #4): explicit `no` passes; a legacy prompt WARNS at most. ---
check_design_passes_not_significant() {
  write_p51 $'## Design\n- design-significant: no — pure fix'
  ( cd "$E2E" && "$BIN" next --check-design 51 ) | grep -q 'READY'
}
run_check "e2e-check-design-passes-no" check_design_passes_not_significant

check_design_warns_legacy() {
  printf '%s\n' "$P51_HEAD" > "$E2E/prompts/51-task-x.md"   # no marker, no ## Design at all
  local out; out="$( cd "$E2E" && "$BIN" next --check-design 51 )"
  echo "$out" | grep -q 'READY' && echo "$out" | grep -qi 'does not record design significance'
}
run_check "e2e-check-design-warns-legacy" check_design_warns_legacy

# ============================================================================
# GATE wired into --advance (Acceptance #5): a design-significant session cannot proceed to
# execution without a recorded design rationale.
# ============================================================================
# Significant + placeholder design for 51 -> --advance refuses, SESSION stays 50.
advance_blocks_undesigned() {
  write_p51 $'## Design\n- design-significant: yes — new interface\n- <rationale — replace me>'
  ( cd "$E2E" && ! "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "50" ]
}
run_check "e2e-advance-blocks-undesigned" advance_blocks_undesigned

# The documented override lets a founder proceed anyway (50 -> 51) — the Architect's own override,
# NOT the Analyst's/Planner's (each stage overrides alone).
advance_override_skips_gate() {
  write_p51 $'## Design\n- design-significant: yes — new interface\n- <rationale — replace me>'
  ( cd "$E2E" && VAJRA_SKIP_ARCHITECT_GATE=1 "$BIN" next --advance ) \
    && [ "$(cat "$E2E/.ai/SESSION")" = "51" ]
}
run_check "e2e-advance-override-skips-gate" advance_override_skips_gate

# Reset to 50, then a SUBSTANTIVE design -> --advance passes (50 -> 51).
advance_passes_substantive() {
  echo "50" > "$E2E/.ai/SESSION"
  write_p51 $'## Design\n- design-significant: yes — new interface\n- rides ADR-0001 per DECISION-001.'
  ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "51" ]
}
run_check "e2e-advance-passes-substantive" advance_passes_substantive

# --- Real run on THIS repo: --design 67 surfaces the real spine with this prompt's citations
#     marked; --check-design 67 READY (this prompt dogfoods its own gate: it records
#     design-significant: yes + a spine-citing rationale). ---
real_repo_design_surfaces() {
  local out; out="$("$BIN" next --design 67)"
  echo "$out" | grep -q '\[✓\] ADR-0002' && echo "$out" | grep -q '\[✓\] DECISION-001'
}
run_check "real-repo-design-surfaces-67" real_repo_design_surfaces
run_check "real-repo-check-design-67"    bash -c "'$BIN' next --check-design 67 | grep -q READY"

# --- The Analyst scaffold now carries the ## Design placeholder (symmetric with Delta/Plan) ---
scaffold_carries_design() {
  local T; T="$(mktemp -d)"
  ( cd "$T" && mkdir -p .ai && "$BIN" next --scaffold 10 demo-slug >/dev/null 2>&1 )
  grep -q 'design-significant:' "$T/prompts/10-task-demo-slug.md"
  local RC=$?; rm -rf "$T"; return $RC
}
run_check "scaffold-carries-design-placeholder" scaffold_carries_design

# --- Summary artifact carries the honest verdict (the fakest green: form, not semantics) ---
summary_present() {
  local S="$ROOT/sessions/session-67-summary.md"
  [ -f "$S" ] \
    && grep -qi 'architect' "$S" \
    && grep -qi 'design-significant\|design rationale' "$S"
}
run_check "summary-artifact-present" summary_present

# --- Independent cold fidelity review exists (DECISION-002 gate) ---
run_check "cold-review-present" test -f "$ROOT/sessions/session-67-review.md"

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
