#!/usr/bin/env bash
# Session 71 — The Demo-er station (the pipeline's SHOW gate, the 7th governed station).
# The sprint demo was a house rule (CONSTRAINTS.yaml#demo named a script_pattern, a template
# that did not exist on disk, and required_elements nothing read) — no gate checked a session's
# demo existed, ran, or SHOWED anything at close.
#   SURFACE  — `vajra next --demo NN` prints session NN's recorded sprint-demo contract
#              (expected script, required elements found/missing in the script text) read-only.
#   GATE     — `vajra next --check-demo NN` RE-RUNS the demo LIVE (the S69 executable-marker
#              pattern) and BLOCKS (exit 1) on a non-zero exit OR on required elements missing
#              from the LIVE output — the hollow exit-0 demo dies on the element scan.
#              Wired into `--advance` on the session being CLOSED
#              (L2/L3 block · L1 advise · VAJRA_SKIP_DEMOER_GATE=1, distinct, skips the run).
# No script (NO-CODE ground-truth / legacy) WARNS at most — the deletion dodge named plainly.
# The binary SURFACES + ENFORCES the recorded contract — it never authors or renders a demo.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="71"
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

# --- The new Demo-er unit tests must exist and pass ---
run_check "test-patterns-demo-not-verify"  cargo test --lib demoer::tests::demo_patterns_reads_demo_section_not_verify
run_check "test-patterns-recorded-wins"    cargo test --lib demoer::tests::demo_patterns_honors_a_recorded_shorter_element_list
run_check "test-patterns-fallback"         cargo test --lib demoer::tests::demo_patterns_falls_back_on_missing_file_or_keys
run_check "test-static-scan"               cargo test --lib demoer::tests::gather_contract_scans_the_script_text_statically
run_check "test-no-script-never-runs"      cargo test --lib demoer::tests::demo_report_no_script_warns_never_runs
run_check "test-red-and-unevaluable-block" cargo test --lib demoer::tests::demo_report_live_red_blocks_and_unevaluable_fails
run_check "test-hollow-green-fails-scan"   cargo test --lib demoer::tests::demo_report_hollow_green_fails_the_element_scan
run_check "test-runner-code-and-output"    cargo test --lib demoer::tests::run_demo_script_returns_exit_code_and_captured_output
run_check "test-gate-red-hollow-full"      cargo test --lib demoer::tests::gate_blocks_red_and_hollow_passes_full_warns_missing

# --- Own the spine: no 8th command, rides `vajra next`, no new dependency, no second store ---
run_check "no-8th-command"    bash -c 'git diff --quiet main -- src/main.rs && ! grep -q demoer src/main.rs'
run_check "rides-next"        bash -c "grep -q -- '--demo' '$ROOT/src/cli/next.rs' && grep -q -- '--check-demo' '$ROOT/src/cli/next.rs'"
# Cargo.toml changed this session — but ONLY the exclude-negation that ships the demo template
# with the crate. No new [dependencies] line. Branch-agnostic (S72 lesson — the QA gate
# re-runs this script LIVE at every later close, from a branch where S71 is already merged):
# pre-merge the diff vs main is exactly the one negation line; post-merge it is empty.
no_new_dependency() {
  local added n
  added="$(git diff main -- Cargo.toml | grep '^+[^+]' || true)"
  n="$(printf '%s\n' "$added" | grep -c . || true)"
  [ "$n" -eq 0 ] \
    || { [ "$n" -eq 1 ] && printf '%s' "$added" | grep -q 'demo-session-template.sh'; }
}
run_check "no-new-dependency" no_new_dependency
run_check "no-second-store"   bash -c '! test -e "'"$ROOT"'/demo.md" && ! test -e "'"$ROOT"'/qa.md" && ! test -e "'"$ROOT"'/plan.md" && ! test -e "'"$ROOT"'/spec.md"'

# --- The template gap (S70 GT finding, AC-4): the canonical file EXISTS, runs green, and
#     carries every required element marker. ---
run_check "template-exists-on-disk" test -f "$ROOT/scripts/demo-session-template.sh"
template_runs_green_with_all_markers() {
  local out; out="$(bash "$ROOT/scripts/demo-session-template.sh")" || return 1
  echo "$out" | grep -q 'demo:header' \
    && echo "$out" | grep -q 'demo:cases' \
    && echo "$out" | grep -q 'demo:summary_table' \
    && echo "$out" | grep -q 'demo:before_after'
}
run_check "template-runs-green-all-markers" template_runs_green_with_all_markers
run_check "constraints-record-before-after" bash -c "grep -q 'required_elements:.*before_after' '$ROOT/.ai/CONSTRAINTS.yaml'"

# --- Scaffold propagation (AC-4, the S22/S57 include_str! pattern): a real `vajra init`
#     inherits the template byte-identically + a 4-element demo contract. ---
scaffold_propagates_template() {
  local T; T="$(mktemp -d)"
  ( cd "$T" && git init -q . && "$BIN" init >/dev/null 2>&1 ) || { rm -rf "$T"; return 1; }
  diff -q "$ROOT/scripts/demo-session-template.sh" "$T/scripts/demo-session-template.sh" >/dev/null \
    && grep -q 'required_elements:.*before_after' "$T/.ai/CONSTRAINTS.yaml"
  local rc=$?
  rm -rf "$T"
  return $rc
}
run_check "e2e-scaffold-propagates-template" scaffold_propagates_template

# ============================================================================
# Temp Vajra GIT repo whose session 51 is CLOSING (SESSION=51, covered plan, no ## Execution so
# the Coder gate only WARNS, 3 ranked options, live-GREEN verify so QA passes) and whose session
# 52 prompt is APPROVED + covered — so only the Demo-er gate is under test. Real green / red /
# hollow / partial demo scripts drive it.
# ============================================================================
E2E="$ARTIFACTS/e2e"; rm -rf "$E2E"
mkdir -p "$E2E/.ai" "$E2E/prompts" "$E2E/sessions" "$E2E/scripts"
echo "51" > "$E2E/.ai/SESSION"
write_constraints() { # $1 = maturity, $2 = demo script_pattern (optional)
  # NB: the default is assigned separately — a brace-y default inside ${2:-...} would be cut
  # at its first `}` by bash's parameter expansion.
  local pat="${2:-}"
  [ -n "$pat" ] || pat='scripts/demo-session-{NN}.sh'
  { printf 'version: 3\nmaturity: %s\n\nverify:\n' "$1"
    printf "  script_pattern: 'scripts/verify-session-{NN}.sh'\n"
    printf "  artifacts_dir: '.ai/verify/session-{NN}/'\n"
    printf '\ndemo:\n'
    printf "  script_pattern: '%s'\n" "$pat"
    printf '  required_elements: [header, cases, summary_table, before_after]\n'
  } > "$E2E/.ai/CONSTRAINTS.yaml"
}
write_constraints L3
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
printf 'echo "51 checks running"\nexit 0\n' > "$E2E/scripts/verify-session-51.sh"
( cd "$E2E" && git init -q && git config user.email t@t && git config user.name t \
    && git add -A && git commit -qm init && git checkout -q -b session-51-x )

D51="$E2E/scripts/demo-session-51.sh"
full_51() {
  printf 'echo "demo:header S51"\necho "demo:before_after old vs new"\necho "demo:cases 1"\necho "demo:summary_table"\nexit 0\n' > "$D51"
}
red_51()     { printf 'echo "demo:header S51"\nexit 3\n' > "$D51"; }
hollow_51()  { printf 'echo "all done, trust me"\nexit 0\n' > "$D51"; }
partial_51() { printf 'echo "demo:header S51"\necho "demo:cases 1"\necho "demo:summary_table"\nexit 0\n' > "$D51"; }

# --- SURFACE (Acceptance #1): `--demo 51` shows the recorded contract, read-only. ---
demo_surfaces_missing_script() {
  rm -f "$D51"
  local out; out="$( cd "$E2E" && "$BIN" next --demo 51 )"
  echo "$out" | grep -q 'scripts/demo-session-51.sh' \
    && echo "$out" | grep -q 'MISSING' \
    && echo "$out" | grep -q '✗ before_after'
}
run_check "e2e-demo-surfaces-missing-script" demo_surfaces_missing_script

# Read-only is proven, not assumed: a demo that would leave a sentinel file if executed
# leaves none after `--demo`, and the static scan marks found vs missing elements.
demo_surface_is_read_only() {
  printf 'touch "%s/EXECUTED"\necho "demo:header only"\n' "$E2E" > "$D51"
  local out; out="$( cd "$E2E" && "$BIN" next --demo 51 )"
  [ ! -e "$E2E/EXECUTED" ] \
    && echo "$out" | grep -q '✓ header' \
    && echo "$out" | grep -q '✗ cases' \
    && echo "$out" | grep -q 'read-only'
}
run_check "e2e-demo-surface-is-read-only" demo_surface_is_read_only

# --- GATE (Acceptance #2): --check-demo RE-RUNS live; red BLOCKS naming the live exit code. ---
check_demo_blocks_live_red() {
  red_51
  local out; out="$( cd "$E2E" && "$BIN" next --check-demo 51 2>&1 || true )"
  ( cd "$E2E" && ! "$BIN" next --check-demo 51 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'exited 3' \
    && echo "$out" | grep -q 'recorded green'
}
run_check "e2e-check-demo-blocks-live-red" check_demo_blocks_live_red

# The hollow-green kill (the station's own fakest-green class): exit 0 with nothing shown
# passes the RUN but dies on the ELEMENT SCAN of the live output.
check_demo_blocks_hollow_green() {
  hollow_51
  local out; out="$( cd "$E2E" && "$BIN" next --check-demo 51 2>&1 || true )"
  ( cd "$E2E" && ! "$BIN" next --check-demo 51 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'hollow' \
    && echo "$out" | grep -q 'header, cases, summary_table, before_after'
}
run_check "e2e-check-demo-blocks-hollow-green" check_demo_blocks_hollow_green

# One missing element (no before_after — the sprint-demo core) blocks and NAMES it.
check_demo_blocks_missing_before_after() {
  partial_51
  local out; out="$( cd "$E2E" && "$BIN" next --check-demo 51 2>&1 || true )"
  ( cd "$E2E" && ! "$BIN" next --check-demo 51 >/dev/null 2>&1 ) \
    && echo "$out" | grep -q 'shows no before_after'
}
run_check "e2e-check-demo-names-missing-element" check_demo_blocks_missing_before_after

check_demo_passes_full_live() {
  full_51
  ( cd "$E2E" && "$BIN" next --check-demo 51 ) | grep -q 'READY'
}
run_check "e2e-check-demo-passes-full-live" check_demo_passes_full_live

# "A check that cannot evaluate FAILS": an unreadable script and a signal-killed script both
# BLOCK — never a silent pass.
check_demo_fails_closed_unrunnable() {
  printf 'echo hi\n' > "$D51"; chmod 000 "$D51"
  local rc1=0; ( cd "$E2E" && "$BIN" next --check-demo 51 >/dev/null 2>&1 ) || rc1=$?
  chmod 644 "$D51"
  printf 'kill -9 $$\n' > "$D51"
  local rc2=0 out
  out="$( cd "$E2E" && "$BIN" next --check-demo 51 2>&1 )" || rc2=$?
  [ "$rc1" -ne 0 ] && [ "$rc2" -ne 0 ] && echo "$out" | grep -q 'cannot evaluate\|could not be evaluated'
}
run_check "e2e-check-demo-fails-closed-unrunnable" check_demo_fails_closed_unrunnable

# --- LEGACY (Acceptance #3): no script -> WARN at most, the deletion dodge named plainly. ---
check_demo_warns_no_script() {
  rm -f "$D51"
  local out; out="$( cd "$E2E" && "$BIN" next --check-demo 51 )"
  echo "$out" | grep -q 'READY' \
    && echo "$out" | grep -q 'deleting the script' \
    && echo "$out" | grep -q 'self-granted jurisdiction'
}
run_check "e2e-check-demo-warns-no-script" check_demo_warns_no_script

# ============================================================================
# GATE wired into --advance (Acceptance #3): the CLOSING session cannot advance while its
# sprint demo does not run green LIVE with every element shown.
# ============================================================================
advance_blocks_live_red_demo() {
  red_51
  ( cd "$E2E" && ! "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "51" ]
}
run_check "e2e-advance-blocks-live-red-demo" advance_blocks_live_red_demo

advance_blocks_hollow_demo() {
  hollow_51
  ( cd "$E2E" && ! "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "51" ]
}
run_check "e2e-advance-blocks-hollow-demo" advance_blocks_hollow_demo

# The Demo-er's OWN override (distinct from the other stages'): skips the slow live run itself
# (disclosed in the output), and the advance proceeds (51 -> 52).
advance_demoer_override_skips_live_run() {
  red_51
  local out; out="$( cd "$E2E" && VAJRA_SKIP_DEMOER_GATE=1 "$BIN" next --advance 2>&1 )"
  echo "$out" | grep -q 'VAJRA_SKIP_DEMOER_GATE set' \
    && echo "$out" | grep -q 'live demo re-run skipped' \
    && [ "$(cat "$E2E/.ai/SESSION")" = "52" ]
}
run_check "e2e-advance-demoer-override" advance_demoer_override_skips_live_run

# Override distinctness, direction 1: the Demo-er's skip does NOT skip QA — a red verify still
# blocks the close even with VAJRA_SKIP_DEMOER_GATE=1.
demoer_skip_does_not_skip_qa() {
  echo "51" > "$E2E/.ai/SESSION"
  full_51
  printf 'exit 3\n' > "$E2E/scripts/verify-session-51.sh"
  ( cd "$E2E" && ! VAJRA_SKIP_DEMOER_GATE=1 "$BIN" next --advance >/dev/null 2>&1 ) \
    && [ "$(cat "$E2E/.ai/SESSION")" = "51" ]
}
run_check "e2e-demoer-skip-does-not-skip-qa" demoer_skip_does_not_skip_qa

# Override distinctness, direction 2: QA's skip (and the Analyst/Coder ones) does NOT skip the
# Demo-er — a red demo still blocks the close with every OTHER stage's override set.
other_skips_do_not_skip_demoer() {
  printf 'exit 0\n' > "$E2E/scripts/verify-session-51.sh"
  red_51
  ( cd "$E2E" && ! VAJRA_SKIP_QA_GATE=1 VAJRA_SKIP_ANALYST_GATE=1 VAJRA_SKIP_CODER_GATE=1 \
      VAJRA_SKIP_ARCHITECT_GATE=1 VAJRA_SKIP_PLANNER_GATE=1 "$BIN" next --advance >/dev/null 2>&1 ) \
    && [ "$(cat "$E2E/.ai/SESSION")" = "51" ]
}
run_check "e2e-other-skips-do-not-skip-demoer" other_skips_do_not_skip_demoer

# A full live sprint demo -> --advance passes (51 -> 52).
advance_passes_full_live_demo() {
  full_51
  ( cd "$E2E" && "$BIN" next --advance ) && [ "$(cat "$E2E/.ai/SESSION")" = "52" ]
}
run_check "e2e-advance-passes-full-live-demo" advance_passes_full_live_demo

# No demo script at close (NO-CODE ground-truth / legacy): WARN in the gate's own output — the
# dodge named — and the advance proceeds.
advance_no_script_warns_and_passes() {
  echo "51" > "$E2E/.ai/SESSION"
  rm -f "$D51"
  local out; out="$( cd "$E2E" && "$BIN" next --advance 2>&1 )"
  echo "$out" | grep -q 'no demo script recorded' \
    && echo "$out" | grep -q 'self-granted jurisdiction' \
    && [ "$(cat "$E2E/.ai/SESSION")" = "52" ]
}
run_check "e2e-advance-no-script-warns-passes" advance_no_script_warns_and_passes

# At L1 the gate ADVISES on the LIVE result instead of blocking: the red demo prints the
# advisory and the advance still proceeds.
advance_l1_advises() {
  echo "51" > "$E2E/.ai/SESSION"
  write_constraints L1
  red_51
  local out rc=0
  out="$( cd "$E2E" && echo y | "$BIN" next --advance 2>&1 )" || rc=$?
  write_constraints L3
  [ $rc -eq 0 ] && echo "$out" | grep -q 'L1 advise' \
    && echo "$out" | grep -q 'exited 3' \
    && [ "$(cat "$E2E/.ai/SESSION")" = "52" ]
}
run_check "e2e-advance-l1-advises" advance_l1_advises

# The RECORDED contract wins over defaults: a custom script_pattern is honored, and a recorded
# 3-element list does not demand before_after (a pre-S71 scaffold stays valid).
recorded_contract_wins() {
  echo "51" > "$E2E/.ai/SESSION"
  { printf 'version: 3\nmaturity: L3\n\ndemo:\n'
    printf "  script_pattern: 'scripts/show-{NN}.sh'\n"
    printf '  required_elements: [header, cases, summary_table]\n'
  } > "$E2E/.ai/CONSTRAINTS.yaml"
  printf 'echo "demo:header"\necho "demo:cases"\necho "demo:summary_table"\n' > "$E2E/scripts/show-51.sh"
  local out; out="$( cd "$E2E" && "$BIN" next --check-demo 51 )"
  local rc=$?
  write_constraints L3
  [ $rc -eq 0 ] && echo "$out" | grep -q 'scripts/show-51.sh' && echo "$out" | grep -q 'READY'
}
run_check "e2e-recorded-contract-wins" recorded_contract_wins

# --- Real run on THIS repo: --demo 71 surfaces this session's contract — whose script is
#     scripts/demo-session-71.sh (the station dogfoods itself), and a LIVE --check-demo 71
#     passes: S71's own demo runs green with all four elements shown. ---
real_repo_demo_surfaces() {
  local out; out="$("$BIN" next --demo 71)"
  echo "$out" | grep -q 'scripts/demo-session-71.sh' && echo "$out" | grep -q '(exists)'
}
run_check "real-repo-demo-surfaces-71" real_repo_demo_surfaces
run_check "real-repo-check-demo-71-live-green" "$BIN" next --check-demo 71

# --- Summary artifact carries the honest verdict (the fakest green: elements are emitted
#     markers — printing them is not demonstrating; deleting the script is the named dodge) ---
summary_present() {
  local S="$ROOT/sessions/session-71-summary.md"
  [ -f "$S" ] && grep -qi 'demo' "$S" && grep -qi 'hollow\|element scan\|marker' "$S"
}
run_check "summary-artifact-present" summary_present

# --- Independent cold fidelity review exists (DECISION-002 gate) ---
run_check "cold-review-present" test -f "$ROOT/sessions/session-71-review.md"

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
