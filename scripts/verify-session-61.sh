#!/usr/bin/env bash
# Session 61 — The ANALYST's Generate + Delta half, made REAL (pays down the S54 REJECT).
# Two changes, one story:
#   J3  GENERATE updates the spine — `vajra next --scaffold NN <slug>` writes the prompt AND
#       repoints `.ai/TASK.md` at it (previously only a `println!` advised it).
#   J4  DELTA is enforced, not grepped — a placeholder `## Delta` (the scaffold's untouched
#       `<...>`) now BLOCKS the advance at L2/L3; only a substantive delta passes. This REPLACES
#       the S54 "fakest green" (`grep -q '## Delta'`, trivially true) with a substantive assertion.
# Out of scope (stated plainly): Intake / Options — the NOT-BUILT intent->A/B/C front half = S62.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="61"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

BIN="$ROOT/target/debug/vajra"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-46s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-46s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "cargo-build"   cargo build

# --- The new unit tests must exist and pass (delta states + the pointer write) ---
run_check "test-delta-states"       cargo test --lib analyst::tests::delta_states_absent_placeholder_substantive
run_check "test-gate-placeholder"   cargo test --lib analyst::tests::gate_blocks_placeholder_delta_passes_substantive
run_check "test-draft-then-passes"  cargo test --lib analyst::tests::gate_blocks_draft_then_passes_when_approved
run_check "test-scaffold-points"    cargo test --lib cli::next::tests::scaffold_and_point_writes_prompt_and_repoints_task

# --- Own the spine: no 8th command, rides `vajra next`, no new dependency, no second store ---
run_check "no-8th-command"    bash -c 'git diff --quiet main -- src/main.rs && ! grep -q analyst src/main.rs'
run_check "rides-next"        grep -q -- '--scaffold' "$ROOT/src/cli/next.rs"
run_check "no-new-dependency" bash -c 'git diff --quiet main -- Cargo.toml'
run_check "no-second-store-in-repo" bash -c '! test -e "'"$ROOT"'/spec.md" && ! test -d "'"$ROOT"'/specs" && ! test -e "'"$ROOT"'/SPEC.md"'

# --- The S54 "fakest green" is retired: delta is asserted by BEHAVIOR below
#     (e2e-placeholder-delta-blocks + e2e-substantive-delta-advances), not by a heading grep. ---

# ============================================================================
# End-to-end: the Analyst's Generate + Delta half in a throwaway Vajra repo.
# ============================================================================
E2E="$ARTIFACTS/e2e"; rm -rf "$E2E"; mkdir -p "$E2E/.ai" "$E2E/prompts"
echo "76" > "$E2E/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"   # L3 = non-interactive advance
printf '# Session Boot\n- **Number:** 76\n' > "$E2E/.ai/SESSION-BOOT.md"
# The canonical `.ai/TASK.md` pointer format (what `vajra init` scaffolds) — a `Read prompt:` line.
printf '# Current Task Pointer\n\nRead prompt: `prompts/76-task-x.md`\n\n## Always-True\n- keep this prose\n' \
  > "$E2E/.ai/TASK.md"
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-76-x )

PROMPT="$E2E/prompts/77-task-demo-stage.md"

# 1. GENERATE — scaffold prompt 77 AND (J3) repoint .ai/TASK.md at it.
run_check "e2e-scaffold-runs" bash -c "cd '$E2E' && '$BIN' next --scaffold 77 demo-stage"
run_check "e2e-prompt-created" test -f "$PROMPT"
# J3 / Acceptance #1: the TASK.md pointer now NAMES the new prompt (the gap S54 left as a println!).
run_check "e2e-task-pointer-updated" \
  grep -q '`prompts/77-task-demo-stage.md`' "$E2E/.ai/TASK.md"
run_check "e2e-old-pointer-gone" bash -c "! grep -q '76-task-x' '$E2E/.ai/TASK.md'"
# Idempotent + prose-safe: unrelated lines survive the pointer rewrite.
run_check "e2e-pointer-keeps-prose" grep -q 'keep this prose' "$E2E/.ai/TASK.md"
# It is Vajra's prompt format, not a spec.md — the scaffold created NO second store.
run_check "e2e-no-spec-md" bash -c '! test -e "'"$E2E"'/spec.md" && ! test -d "'"$E2E"'/specs"'

# 2. DELTA — approve the prompt, but its delta is still the scaffold PLACEHOLDER.
sed -i.bak 's/DRAFT/APPROVED/' "$PROMPT" && rm -f "$PROMPT.bak"
# Acceptance #2a: an APPROVED, well-formed prompt with a PLACEHOLDER delta is BLOCKED (S61) —
# the advance refuses and SESSION stays 76. This is the substantive replacement for the grep.
gate_blocks_placeholder_delta() {
  ( cd "$E2E" && ! "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "76" ]
}
run_check "e2e-placeholder-delta-blocks" gate_blocks_placeholder_delta
# The refusal itself (the --advance stderr, not just --validate) names the placeholder delta.
# Capture the output first so `set -o pipefail` isn't tripped by advance's expected non-zero exit.
e2e_block_reason_is_placeholder() {
  local adv val
  adv="$( cd "$E2E" && "$BIN" next --advance 2>&1 || true )"
  val="$( cd "$E2E" && "$BIN" next --validate 77 2>&1 || true )"
  echo "$adv" | grep -qi placeholder && echo "$val" | grep -qi placeholder
}
run_check "e2e-block-reason-is-placeholder" e2e_block_reason_is_placeholder

# 3. Record a REAL delta -> the advance passes (76 -> 77).
sed -i.bak 's/<what this session ADDS that did not exist>/a real, recorded addition vs ROADMAP/' "$PROMPT"
rm -f "$PROMPT.bak"
gate_allows_substantive_delta() {
  ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "77" ]
}
run_check "e2e-substantive-delta-advances" gate_allows_substantive_delta

# 4. Legacy compat: a well-formed prompt with NO `## Delta` at all only WARNS (never blocks) —
#    legacy prompts stay valid; only the Analyst's own placeholder is blocked.
printf '# S78\n> Status: APPROVED\n## Goal\ng\n## Deliverables\n- d\n## Acceptance\n1. a\n## Guardrails\n- x\n' \
  > "$E2E/prompts/78-task-legacy.md"
legacy_no_delta_advances() {
  ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "78" ]
}
run_check "e2e-legacy-no-delta-advances" legacy_no_delta_advances

# --- Real run on THIS repo: the S61 prompt validates as well-formed + substantive-delta ---
run_check "real-repo-validate-61" bash -c "'$BIN' next --validate 61"

# --- Summary artifact carries the honest verdict (1-of-5 -> 3-of-5; Intake/Options still open) ---
summary_present() {
  local S="$ROOT/sessions/session-61-summary.md"
  [ -f "$S" ] \
    && grep -qi 'delta'  "$S" \
    && grep -qi 'pointer' "$S" \
    && grep -qi '3 of 5\|3-of-5\|3/5' "$S" \
    && grep -qi 'intake' "$S"
}
run_check "summary-artifact-present" summary_present

# --- Independent cold fidelity review exists (DECISION-002 gate) ---
run_check "cold-review-present" test -f "$ROOT/sessions/session-61-review.md"

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
printf '%-46s %s\n' "STEP" "RESULT"
printf '%-46s %s\n' "----------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
