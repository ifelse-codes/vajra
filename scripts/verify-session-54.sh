#!/usr/bin/env bash
# Session 54 — The ANALYST stage (the pipeline's first governed specialist).
# Turns a vague intent into the NEXT GOVERNED PROMPT (Vajra's own spec = prompts/NN-task-<slug>.md),
# NOT a foreign spec.md. Rides `vajra next` (no 8th command, max-7 cap), owns the .ai/+prompts/ spine.
# The enforcement: advancing INTO session N+1 is BLOCKED unless its prompt is present, well-formed,
# and APPROVED (not DRAFT). Borrow Engine folded Spec Kit structure + Kiro/EARS testable acceptance +
# OpenSpec +/~/- deltas INTO the prompt format. Honest edge: approval is a recorded Status: marker
# (same trust model as a commit-approval token); tamper-evidence is the later cross-stage ledger.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="54"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

BIN="$ROOT/target/debug/vajra"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-42s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-42s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test

# --- Analyst unit tests must exist and pass ---
run_check "test-scaffold-draft"     cargo test --lib analyst::tests::scaffold_is_well_formed_and_draft
run_check "test-gate-draft-approve" cargo test --lib analyst::tests::gate_blocks_draft_then_passes_when_approved
run_check "test-gate-malformed"     cargo test --lib analyst::tests::gate_blocks_malformed_prompt
run_check "test-gate-no-prompt"     cargo test --lib analyst::tests::gate_blocks_when_no_prompt
run_check "test-delta-warns"        cargo test --lib analyst::tests::missing_delta_warns_not_blocks
run_check "test-second-store"       cargo test --lib analyst::tests::detect_second_store_flags_spec_md

# --- No 8th command: main.rs dispatch untouched; Analyst rides `vajra next` ---
run_check "no-8th-command"  bash -c 'git diff --quiet main -- src/main.rs && ! grep -q analyst src/main.rs'
run_check "rides-next"      grep -q -- '--scaffold' "$ROOT/src/cli/next.rs"
# --- No new dependency (S21 rule): Cargo.toml unchanged vs main ---
run_check "no-new-dependency" bash -c 'git diff --quiet main -- Cargo.toml'
# --- Own the spine: Vajra's own tree has NO foreign second store (spec.md / specs/) ---
run_check "no-second-store-in-repo" bash -c '! test -e "'"$ROOT"'/spec.md" && ! test -d "'"$ROOT"'/specs" && ! test -e "'"$ROOT"'/SPEC.md"'

# --- Build the binary the E2E drives ---
run_check "cargo-build" cargo build

# ============================================================================
# End-to-end: the Analyst in a throwaway Vajra repo (intent -> prompt -> gate -> advance).
# ============================================================================
E2E="$ARTIFACTS/e2e"; rm -rf "$E2E"; mkdir -p "$E2E/.ai" "$E2E/prompts"
echo "76" > "$E2E/.ai/SESSION"
printf 'version: 3\nmaturity: L3\n' > "$E2E/.ai/CONSTRAINTS.yaml"   # L3 = non-interactive advance
printf '# Session Boot\n- **Number:** 76\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Task\nRead prompt: `prompts/76-task-x.md`\n' > "$E2E/.ai/TASK.md"
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-76-x )

# 1. SCAFFOLD — generate the next prompt (77) from the Borrow-Engine template.
run_check "e2e-scaffold-runs" bash -c "cd '$E2E' && '$BIN' next --scaffold 77 demo-stage"
PROMPT="$E2E/prompts/77-task-demo-stage.md"
run_check "e2e-prompt-created" test -f "$PROMPT"
# The generated prompt carries the full borrow-engine shape (Vajra's format, NO new file type).
run_check "e2e-has-goal"         grep -q '## Goal' "$PROMPT"
run_check "e2e-has-deliverables" grep -q '## Deliverables' "$PROMPT"
run_check "e2e-has-acceptance"   grep -qi 'Acceptance' "$PROMPT"
run_check "e2e-has-guardrails"   grep -q '## Guardrails' "$PROMPT"
run_check "e2e-has-delta"        grep -q '## Delta' "$PROMPT"
run_check "e2e-scaffold-draft"   grep -qi 'Status:.*DRAFT' "$PROMPT"
# It is Vajra's prompt format, not a spec.md — the scaffold created NO second store.
run_check "e2e-no-spec-md"       bash -c '! test -e "'"$E2E"'/spec.md" && ! test -d "'"$E2E"'/specs"'

# 2. VALIDATE — a DRAFT prompt reports NOT READY (exit 1).
run_check "e2e-validate-draft-not-ready" bash -c "cd '$E2E' && ! '$BIN' next --validate 77"

# 3. GATE — advancing INTO 77 is BLOCKED while DRAFT (SESSION must stay 76).
gate_blocks_draft() {
  ( cd "$E2E" && ! "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "76" ]
}
run_check "e2e-gate-blocks-draft" gate_blocks_draft

# 4. APPROVE — flip Status to APPROVED (the human sign-off the gate waits for).
sed -i.bak 's/DRAFT/APPROVED/' "$PROMPT" && rm -f "$PROMPT.bak"
run_check "e2e-validate-approved-ready" bash -c "cd '$E2E' && '$BIN' next --validate 77"

# 5. ADVANCE — an approved, well-formed prompt lets the advance through (76 -> 77).
gate_allows_approved() {
  ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "77" ]
}
run_check "e2e-gate-allows-approved" gate_allows_approved

# 6. MALFORMED — a prompt missing required sections is BLOCKED (goal-only 78).
printf '# S78\n## Goal\nonly a goal\n' > "$E2E/prompts/78-task-y.md"
malformed_blocks() {
  ( cd "$E2E" && ! "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "77" ]
}
run_check "e2e-gate-blocks-malformed" malformed_blocks

# 7. OVERRIDE — the gate is escapable ONLY via the explicit env override (documented).
override_advances() {
  ( cd "$E2E" && VAJRA_SKIP_ANALYST_GATE=1 "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "78" ]
}
run_check "e2e-override-advances" override_advances

# --- Real run on THIS repo: the S54 prompt validates as well-formed (a non-author could read it) ---
run_check "real-repo-validate-54" bash -c "'$BIN' next --validate 54"

# --- Summary artifact carries the honest verdict (gate-holds + prompt-as-spec + trust boundary) ---
summary_present() {
  local S="$ROOT/sessions/session-54-summary.md"
  [ -f "$S" ] \
    && grep -qi 'gate' "$S" \
    && grep -qi 'prompt' "$S" \
    && grep -qi 'spec.md' "$S"
}
run_check "summary-artifact-present" summary_present

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
printf '%-42s %s\n' "STEP" "RESULT"
printf '%-42s %s\n' "------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
