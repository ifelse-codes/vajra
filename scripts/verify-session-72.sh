#!/usr/bin/env bash
# Session 72 — The Releaser station (the pipeline's SHIP gate, the 8th governed station).
# Ship hygiene was a checklist line (the S37 founder-flagged gap): a session's work SHIPS
# (PR → merge → main synced → branches pruned) on convention alone — enforced by nobody.
#   SURFACE  — `vajra next --release NN` prints session NN's ship state re-derived from LOCAL
#              git refs (branch merged into main? main vs origin/main? unpruned merged
#              session-* locals?) read-only — nothing fetched, pushed, merged, or deleted.
#   GATE     — `vajra next --check-release NN` BLOCKS (exit 1) on unmerged / behind / diverged
#              / unpruned; a repo where the state cannot be derived FAILS, never silently
#              passes. Wired into `--advance` binding on the PRIOR session
#              (L2/L3 block · L1 advise · VAJRA_SKIP_RELEASER_GATE=1, distinct).
# A fresh repo (no prior session evidence, no remote) WARNS at most — the dodge named plainly.
# The binary SURFACES + ENFORCES derived git state — it never ships anything itself.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="72"
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

# --- The new Releaser unit tests must exist and pass ---
run_check "test-contract-defaults"        cargo test --lib releaser::tests::contract_defaults_true_on_missing_file_or_section
run_check "test-contract-scoped-keys"     cargo test --lib releaser::tests::contract_reads_recorded_false_keys_scoped_to_release_section
run_check "test-ship-errs-no-git-no-main" cargo test --lib releaser::tests::ship_state_errs_outside_git_and_without_main
run_check "test-merged-vs-unmerged"       cargo test --lib releaser::tests::merged_branch_is_merged_and_unmerged_is_not
run_check "test-sync-states"              cargo test --lib releaser::tests::sync_states_derive_from_the_local_origin_ref
run_check "test-unpruned-excludes-current" cargo test --lib releaser::tests::unpruned_lists_merged_locals_and_excludes_the_current_branch
run_check "test-gate-names-each-failure"  cargo test --lib releaser::tests::gate_blocks_unmerged_behind_diverged_and_unpruned_naming_each
run_check "test-no-evidence-fails-closed" cargo test --lib releaser::tests::gate_blocks_a_session_with_no_evidence_fail_closed
run_check "test-target-skips-in-flight"   cargo test --lib releaser::tests::find_target_prefers_newest_evidence_and_skips_the_in_flight_branch
run_check "test-fresh-repo-names-dodge"   cargo test --lib releaser::tests::close_gate_on_a_fresh_repo_warns_and_names_the_dodge

# --- Own the spine: no 8th command, rides `vajra next`, no new dependency, no second store ---
run_check "no-8th-command"    bash -c 'git diff --quiet main -- src/main.rs && ! grep -q releaser src/main.rs'
run_check "rides-next"        bash -c "grep -q -- '--release' '$ROOT/src/cli/next.rs' && grep -q -- '--check-release' '$ROOT/src/cli/next.rs'"
# No new dependency and no new embedded file: Cargo.toml is UNTOUCHED this session.
run_check "no-new-dependency" git diff --quiet main -- Cargo.toml
run_check "no-second-store"   bash -c '! test -e "'"$ROOT"'/release.md" && ! test -e "'"$ROOT"'/ship.md" && ! test -e "'"$ROOT"'/demo.md" && ! test -e "'"$ROOT"'/qa.md"'
# The station spawns no network-touching or mutating subcommand: no quoted fetch/push/pull/
# clone/gh token anywhere in the module (its git calls are rev-parse / for-each-ref /
# merge-base / rev-list / branch --show-current — reads only).
run_check "no-gh-no-network-in-gate" bash -c '! grep -Eq "\"(fetch|push|pull|clone|gh)\"" src/releaser/mod.rs'
run_check "constraints-record-release" bash -c "grep -q '^release:' '$ROOT/.ai/CONSTRAINTS.yaml' && grep -q 'require_merged_prior: true' '$ROOT/.ai/CONSTRAINTS.yaml'"

# --- Scaffold propagation (AC-4, the S22/S57 pattern): a real `vajra init` records release: ---
scaffold_records_release() {
  local T; T="$(mktemp -d)"
  ( cd "$T" && git init -q . && "$BIN" init >/dev/null 2>&1 ) || { rm -rf "$T"; return 1; }
  grep -q '^release:' "$T/.ai/CONSTRAINTS.yaml" \
    && grep -q 'require_pruned: true' "$T/.ai/CONSTRAINTS.yaml"
  local rc=$?
  rm -rf "$T"
  return $rc
}
run_check "e2e-scaffold-records-release" scaffold_records_release

# ============================================================================
# Temp Vajra GIT repo with a REAL bare origin (file transport — no network). Session 41 is
# CLOSING (SESSION=41, green verify so QA passes, covered prompts 41+42, 3 ranked options, no
# demo script so the Demo-er WARNs) and the work happens on session-42-y — the in-flight
# branch — so the Releaser gate binds on 41, exactly the real close shape.
# ============================================================================
E2E_BASE="$ROOT/$ARTIFACTS/e2e"; rm -rf "$E2E_BASE"
ORIGIN="$E2E_BASE/origin.git"
E2E="$E2E_BASE/repo"
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions" "$E2E/scripts"
git init -q --bare "$ORIGIN"

write_constraints() { # $1 = maturity, $2/$3/$4 = release keys (default true)
  { printf 'version: 3\nmaturity: %s\n\nverify:\n' "$1"
    printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n"
    printf "  artifacts_dir: '.ai/verify/session-{NN}/'\n"
    printf '\ndemo:\n'
    printf "  script_pattern: 'scripts/demo-session-{NN}.sh'\n"
    printf '  required_elements: [header, cases, summary_table, before_after]\n'
    printf '\nrelease:\n'
    printf '  require_merged_prior: %s\n' "${2:-true}"
    printf '  require_main_synced: %s\n' "${3:-true}"
    printf '  require_pruned: %s\n' "${4:-true}"
  } > "$E2E/.ai/CONSTRAINTS.yaml"
}
write_constraints L3
echo "41" > "$E2E/.ai/SESSION"
printf '# Session Boot\n- **Number:** 41\n' > "$E2E/.ai/SESSION-BOOT.md"
printf '# Current Task Pointer\n\nRead prompt: `prompts/41-task-x.md`\n' > "$E2E/.ai/TASK.md"
printf '# Vajra — Working Roadmap\n' > "$E2E/.ai/ROADMAP.md"
{ printf '# S41 summary\n\n## Next — ranked candidates (S42)\n\n'
  printf -- '- **A — one.**\n- **B — two.**\n- **C — three.**\n'
} > "$E2E/sessions/session-41-summary.md"
for NN in 41 42; do
cat > "$E2E/prompts/${NN}-task-x.md" <<'P'
# Session NN — x: a slice
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
done
printf 'exit 0\n' > "$E2E/scripts/verify-session-41.sh"
( cd "$E2E" && git init -qb main && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init \
    && git remote add origin "$ORIGIN" && git push -q origin main \
    && git checkout -qb session-41-x \
    && echo work > f41.txt && git add -A && git commit -qm "s41 work" \
    && git push -q origin session-41-x \
    && git checkout -qb session-42-y )

# --- SURFACE (Acceptance #1): read-only, and PROVEN read-only — refs identical before/after,
#     and no fetch ran (FETCH_HEAD never appears). Session 41 is not yet merged here. ---
release_surface_read_only() {
  local before after out
  before="$(cd "$E2E" && git for-each-ref)"
  out="$(cd "$E2E" && "$BIN" next --release 41)"
  after="$(cd "$E2E" && git for-each-ref)"
  [ "$before" = "$after" ] \
    && [ ! -e "$E2E/.git/FETCH_HEAD" ] \
    && echo "$out" | grep -q 'NOT merged into main' \
    && echo "$out" | grep -q 'read-only' \
    && echo "$out" | grep -q 'last fetch'
}
run_check "e2e-release-surface-read-only" release_surface_read_only

# --- GATE (Acceptance #2): unmerged prior branch BLOCKS, naming the branch. ---
check_release_blocks_unmerged() {
  local out; out="$(cd "$E2E" && "$BIN" next --check-release 41 2>&1 || true)"
  ( cd "$E2E" && ! "$BIN" next --check-release 41 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'session-41-x' \
    && echo "$out" | grep -q 'NOT an ancestor'
}
run_check "e2e-check-release-blocks-unmerged" check_release_blocks_unmerged

# --- Wired into --advance (Acceptance #3): the close refuses while 41 is unshipped. ---
advance_blocks_unmerged() {
  ( cd "$E2E" && ! "$BIN" next --advance >/dev/null 2>&1 ) \
    && [ "$(cat "$E2E/.ai/SESSION")" = "41" ]
}
run_check "e2e-advance-blocks-unmerged" advance_blocks_unmerged

# --- Merge 41 (a human act, done here by the fixture) but leave the local branch → the prune
#     step is still unfinished: BLOCKS naming the leftover. ---
check_release_blocks_unpruned() {
  ( cd "$E2E" && git checkout -q main && git merge -q --no-ff session-41-x -m "merge s41" \
      && git push -q origin main && git checkout -q session-42-y )
  local out; out="$(cd "$E2E" && "$BIN" next --check-release 41 2>&1 || true)"
  ( cd "$E2E" && ! "$BIN" next --check-release 41 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'unpruned' \
    && echo "$out" | grep -q 'session-41-x' \
    && echo "$out" | grep -q 'git branch -d'
}
run_check "e2e-check-release-blocks-unpruned" check_release_blocks_unpruned

# --- Prune the local; the origin remote-tracking ref remains the merge evidence → READY. ---
check_release_passes_shipped() {
  ( cd "$E2E" && git branch -qd session-41-x )
  local out; out="$(cd "$E2E" && "$BIN" next --check-release 41)"
  echo "$out" | grep -q 'READY' && echo "$out" | grep -q 'origin/session-41-x'
}
run_check "e2e-check-release-passes-shipped" check_release_passes_shipped

# --- main BEHIND origin/main (a push landed elsewhere; local main not synced) BLOCKS. ---
check_release_blocks_behind() {
  ( cd "$E2E" && git checkout -q main && git commit -q --allow-empty -m "remote-only" \
      && git push -q origin main && git reset -q --hard HEAD~1 && git checkout -q session-42-y )
  local out; out="$(cd "$E2E" && "$BIN" next --check-release 41 2>&1 || true)"
  ( cd "$E2E" && ! "$BIN" next --check-release 41 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'behind origin/main' \
    && echo "$out" | grep -q 'S37'
}
run_check "e2e-check-release-blocks-behind" check_release_blocks_behind

# --- main DIVERGED from origin/main BLOCKS; syncing main clears it. ---
check_release_blocks_diverged() {
  ( cd "$E2E" && git checkout -q main && git commit -q --allow-empty -m "local-only" \
      && git checkout -q session-42-y )
  local out; out="$(cd "$E2E" && "$BIN" next --check-release 41 2>&1 || true)"
  local blocked=0
  ( cd "$E2E" && ! "$BIN" next --check-release 41 >/dev/null 2>&1 ) && blocked=1
  ( cd "$E2E" && git checkout -q main && git reset -q --hard origin/main \
      && git checkout -q session-42-y )
  [ "$blocked" = "1" ] && echo "$out" | grep -q 'DIVERGED' \
    && ( cd "$E2E" && "$BIN" next --check-release 41 >/dev/null 2>&1 )
}
run_check "e2e-check-release-blocks-diverged" check_release_blocks_diverged

# --- main AHEAD only (local merge not pushed): disclosed, NOT blocked — publishing is a human
#     act the gate must not perform (the contract blocks on behind/diverged). ---
ahead_only_warns_not_blocks() {
  ( cd "$E2E" && git checkout -q main && git commit -q --allow-empty -m "unpushed" \
      && git checkout -q session-42-y )
  local out rc=0
  out="$(cd "$E2E" && "$BIN" next --check-release 41 2>&1)" || rc=$?
  ( cd "$E2E" && git checkout -q main && git reset -q --hard origin/main \
      && git checkout -q session-42-y )
  [ "$rc" = "0" ] && echo "$out" | grep -q 'ahead of origin/main' \
    && echo "$out" | grep -q 'not pushed'
}
run_check "e2e-ahead-only-warns-not-blocks" ahead_only_warns_not_blocks

# --- Advance passes once shipped (merged + synced + pruned): 41 → 42. ---
advance_passes_shipped() {
  ( cd "$E2E" && "$BIN" next --advance >/dev/null 2>&1 ) \
    && [ "$(cat "$E2E/.ai/SESSION")" = "42" ]
}
run_check "e2e-advance-passes-shipped" advance_passes_shipped

# --- Override distinctness, direction 1: every OTHER stage's skip does NOT skip the Releaser —
#     a red ship still blocks the close. (Recreate the unpruned leftover as the red state.) ---
other_skips_do_not_skip_releaser() {
  echo "41" > "$E2E/.ai/SESSION"
  ( cd "$E2E" && git branch -q session-41-x main )
  ( cd "$E2E" && ! VAJRA_SKIP_QA_GATE=1 VAJRA_SKIP_ANALYST_GATE=1 VAJRA_SKIP_CODER_GATE=1 \
      VAJRA_SKIP_ARCHITECT_GATE=1 VAJRA_SKIP_PLANNER_GATE=1 VAJRA_SKIP_DEMOER_GATE=1 \
      "$BIN" next --advance >/dev/null 2>&1 ) \
    && [ "$(cat "$E2E/.ai/SESSION")" = "41" ]
}
run_check "e2e-other-skips-do-not-skip-releaser" other_skips_do_not_skip_releaser

# --- The Releaser's OWN override: the check still runs (cheap git reads — its findings print),
#     the env bypasses only the block, and the advance proceeds (41 → 42), disclosed. ---
releaser_override_bypasses_block() {
  local out; out="$(cd "$E2E" && VAJRA_SKIP_RELEASER_GATE=1 "$BIN" next --advance 2>&1)"
  echo "$out" | grep -q 'VAJRA_SKIP_RELEASER_GATE set' \
    && echo "$out" | grep -q 'unpruned' \
    && [ "$(cat "$E2E/.ai/SESSION")" = "42" ]
}
run_check "e2e-releaser-override-bypasses-block" releaser_override_bypasses_block

# --- Override distinctness, direction 2: the Releaser's skip does NOT skip QA — a red verify
#     still blocks the close even with VAJRA_SKIP_RELEASER_GATE=1. ---
releaser_skip_does_not_skip_qa() {
  echo "41" > "$E2E/.ai/SESSION"
  printf 'exit 3\n' > "$E2E/scripts/verify-session-41.sh"
  local rc=0
  ( cd "$E2E" && VAJRA_SKIP_RELEASER_GATE=1 "$BIN" next --advance >/dev/null 2>&1 ) || rc=$?
  printf 'exit 0\n' > "$E2E/scripts/verify-session-41.sh"
  [ "$rc" != "0" ] && [ "$(cat "$E2E/.ai/SESSION")" = "41" ]
}
run_check "e2e-releaser-skip-does-not-skip-qa" releaser_skip_does_not_skip_qa

# --- L1 advises on the derived result instead of blocking (red ship still prints). ---
advance_l1_advises() {
  write_constraints L1
  local out rc=0
  out="$(cd "$E2E" && echo y | "$BIN" next --advance 2>&1)" || rc=$?
  write_constraints L3
  [ "$rc" = "0" ] && echo "$out" | grep -q 'L1 advise' \
    && echo "$out" | grep -q 'unpruned' \
    && [ "$(cat "$E2E/.ai/SESSION")" = "42" ]
}
run_check "e2e-advance-l1-advises" advance_l1_advises

# --- The recorded contract wins: require_pruned/require_merged_prior false → the same leftover
#     and even an unmerged branch stop blocking (keys read from CONSTRAINTS.yaml#release). ---
contract_false_keys_honored() {
  echo "41" > "$E2E/.ai/SESSION"
  # A genuinely UNMERGED session-41-x (one commit not on main): with merged_prior + pruned
  # not required and main synced, the gate must be READY. Stage ONLY the work file — an
  # `add -A` would commit the fixture's dirty .ai/ files onto the scratch branch and the
  # checkout back would revert the contract keys under test.
  ( cd "$E2E" && git branch -qD session-41-x && git checkout -qb session-41-x main \
      && echo u > u.txt && git add u.txt && git commit -qm "unmerged work" \
      && git checkout -q session-42-y )
  write_constraints L3 false true false
  local out rc=0
  out="$(cd "$E2E" && "$BIN" next --check-release 41)" || rc=$?
  write_constraints L3
  [ "$rc" = "0" ] && echo "$out" | grep -q 'READY'
}
run_check "e2e-contract-false-keys-honored" contract_false_keys_honored

# --- Pruned everywhere (local AND remote-tracking gone — the real post-prune shape) with the
#     prompt as surviving evidence: READY, the vacuous-ancestry dodge NAMED. ---
pruned_with_prompt_warns_ready() {
  ( cd "$E2E" && git branch -qD session-41-x && git branch -qrd origin/session-41-x )
  local out; out="$(cd "$E2E" && "$BIN" next --check-release 41)"
  echo "$out" | grep -q 'READY' \
    && echo "$out" | grep -q 'pruned after merge is the desired end-state' \
    && echo "$out" | grep -q 'self-granted jurisdiction'
}
run_check "e2e-pruned-with-prompt-warns-ready" pruned_with_prompt_warns_ready

# --- No evidence at all for the named session → fail-closed BLOCK, never a silent pass. ---
no_evidence_fails_closed() {
  local out; out="$(cd "$E2E" && "$BIN" next --check-release 33 2>&1 || true)"
  ( cd "$E2E" && ! "$BIN" next --check-release 33 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'no evidence' \
    && echo "$out" | grep -q 'cannot evaluate'
}
run_check "e2e-no-evidence-fails-closed" no_evidence_fails_closed

# --- "A check that cannot evaluate FAILS": a .ai dir that is not a git repo, and a git repo
#     with neither main nor master, both BLOCK. ---
underivable_fails_closed() {
  local T1 T2 rc1=0 rc2=0
  T1="$(mktemp -d)"; mkdir -p "$T1/.ai"; write_constraints_at "$T1"
  ( cd "$T1" && "$BIN" next --check-release 41 >/dev/null 2>&1 ) || rc1=$?
  T2="$(mktemp -d)"; mkdir -p "$T2/.ai"; write_constraints_at "$T2"
  ( cd "$T2" && git init -qb trunk . && git config user.email t@t && git config user.name t \
      && git commit -q --allow-empty -m init ) >/dev/null 2>&1
  local out; out="$(cd "$T2" && "$BIN" next --check-release 41 2>&1 || true)"
  ( cd "$T2" && "$BIN" next --check-release 41 >/dev/null 2>&1 ) || rc2=$?
  rm -rf "$T1" "$T2"
  [ "$rc1" != "0" ] && [ "$rc2" != "0" ] && echo "$out" | grep -q 'no main'
}
write_constraints_at() {
  printf 'version: 3\nmaturity: L3\n\nrelease:\n  require_merged_prior: true\n' > "$1/.ai/CONSTRAINTS.yaml"
}
run_check "e2e-underivable-fails-closed" underivable_fails_closed

# --- FRESH repo (Acceptance #3): no prior session branch/prompt, no remote → the --advance
#     gate WARNS at most, names the dodge, and the close proceeds. ---
fresh_repo_warns_and_passes() {
  local F; F="$(mktemp -d)"
  mkdir -p "$F/.ai" "$F/prompts"
  printf 'version: 3\nmaturity: L3\n' > "$F/.ai/CONSTRAINTS.yaml"
  echo "41" > "$F/.ai/SESSION"
  printf '# Session Boot\n- **Number:** 41\n' > "$F/.ai/SESSION-BOOT.md"
  printf '# Task\n\nRead prompt: `prompts/42-task-y.md`\n' > "$F/.ai/TASK.md"
  cat > "$F/prompts/42-task-y.md" <<'P'
# Session 42 — y: the next slice
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
  ( cd "$F" && git init -qb main && git config user.email t@t && git config user.name t \
      && git add -A && git commit -qm init && git checkout -qb session-42-y )
  local out; out="$(cd "$F" && "$BIN" next --advance 2>&1)"
  local rc=$?
  local after; after="$(cat "$F/.ai/SESSION")"
  rm -rf "$F"
  [ "$rc" = "0" ] && [ "$after" = "42" ] \
    && echo "$out" | grep -q 'no prior session with a branch or prompt' \
    && echo "$out" | grep -q 'self-granted jurisdiction'
}
run_check "e2e-fresh-repo-warns-and-passes" fresh_repo_warns_and_passes

# --- Real run on THIS repo: --release 71 surfaces the prior session's ship state read-only
#     (the station dogfoods itself at this very close — the S72 --advance binds on 71). ---
real_repo_release_surfaces() {
  local out; out="$("$BIN" next --release 71)"
  echo "$out" | grep -q 'ship state for session 71' \
    && echo "$out" | grep -q 'read-only'
}
run_check "real-repo-release-surfaces-71" real_repo_release_surfaces

# --- Summary artifact carries the honest verdict (fakest green: ancestry is not the reviewed
#     PR; pruned-unmerged is invisible; origin/main is only as fresh as the last fetch) ---
summary_present() {
  local S="$ROOT/sessions/session-72-summary.md"
  [ -f "$S" ] && grep -qi 'releaser\|ship' "$S" && grep -qi 'ancestry\|last fetch\|pruned' "$S"
}
run_check "summary-artifact-present" summary_present

# --- Independent cold fidelity review exists (DECISION-002 gate) ---
run_check "cold-review-present" test -f "$ROOT/sessions/session-72-review.md"

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
