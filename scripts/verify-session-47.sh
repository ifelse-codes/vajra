#!/usr/bin/env bash
# Session 47 — The mid-run co-pilot MURMUR: proactive, non-blocking guidance (direction B).
# S21 shipped the co-pilot LOADER (PreToolUse, reactive, blocks at exit 2). This session ships the
# missing proactive half: hook-copilot-murmur.sh (UserPromptSubmit) surfaces the copilot.on context
# relevant to the working-tree changes as an ADVISORY (exit 0 — never blocks). It reuses the loader's
# rule-parse + per-session debounce but inverts the posture (guide, don't cop). Propagated into
# `vajra init` via include_str! (byte-identical, S22 pattern) + wired on UserPromptSubmit; un-excluded
# in Cargo.toml so `cargo install` ships it. Proven end-to-end: a real `vajra init` emits the murmur
# and its scaffolded copy actually murmurs a matching change (exit 0) and debounces.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="47"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

CANON_HOOK="$ROOT/scripts/hook-copilot-murmur.sh"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-40s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-40s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test

# --- The two new scaffold unit tests must exist and pass ---
run_check "test-murmur-verbatim" cargo test scaffold_ships_copilot_murmur_verbatim
run_check "test-murmur-wired"    cargo test scaffold_wires_murmur_into_user_prompt_submit

# --- Posture invariant: the murmur must NEVER block (no exit 2 in the canonical source) ---
run_check "murmur-never-blocks"  bash -c '! grep -q "exit 2" "'"$CANON_HOOK"'"'

# --- Packaging: the include_str!'d hook must ship with `cargo install` (S22 gotcha) ---
murmur_in_package() { cargo package --list --allow-dirty 2>/dev/null | grep -q '^scripts/hook-copilot-murmur.sh$'; }
run_check "murmur-in-cargo-package" murmur_in_package

# --- Enforcement-not-renderer: init only *embeds* the murmur (include_str!) — it never spawns it ---
murmur_embedded_not_executed() {
  grep -q 'include_str!("../../scripts/hook-copilot-murmur.sh")' "$ROOT/src/cli/init.rs" \
    && ! grep -qE 'Command::new[^;]*hook-copilot-murmur|arg\([^)]*hook-copilot-murmur' "$ROOT/src/cli/init.rs"
}
run_check "enforcement-not-renderer" murmur_embedded_not_executed

# --- Cargo.toml un-excludes the hook so `cargo install` compiles it ---
run_check "cargo-toml-unexcludes" grep -q '!scripts/hook-copilot-murmur.sh' "$ROOT/Cargo.toml"

# --- Build the binary the E2E drives ---
run_check "cargo-build" cargo build

# --- End-to-end: a real `vajra init` inherits the murmur ---
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT
( cd "$SCRATCH" && git init -q )
# Drive the interactive prompts: project name, goal, maturity (blank -> L2).
printf 'demo-proj\nbuild it\n\n' | ( cd "$SCRATCH" && "$ROOT/target/debug/vajra" init ) >/dev/null 2>&1 || true

SCAFFOLDED="$SCRATCH/.ai/hooks/hook-copilot-murmur.sh"
run_check "e2e-murmur-present"        test -f "$SCAFFOLDED"
run_check "e2e-murmur-executable"     test -x "$SCAFFOLDED"
run_check "e2e-murmur-byte-identical" cmp -s "$SCAFFOLDED" "$CANON_HOOK"
run_check "e2e-settings-userpromptsubmit" grep -q "UserPromptSubmit" "$SCRATCH/.claude/settings.json"
run_check "e2e-settings-wires-murmur"     grep -q "hook-copilot-murmur.sh" "$SCRATCH/.claude/settings.json"
# Regression: the loader + guards the murmur sits beside are still wired.
run_check "e2e-loader-still-wired"    grep -q "hook-copilot-loader.sh"  "$SCRATCH/.claude/settings.json"
run_check "e2e-publish-guard-wired"   grep -q "hook-publish-guard.sh"   "$SCRATCH/.claude/settings.json"
run_check "e2e-session-guard-wired"   grep -q "hook-session-guard.sh"   "$SCRATCH/.claude/settings.json"

# --- The scaffolded murmur actually behaves: advisory, matches work-in-play, debounces ---
# In the fresh scaffold the untracked prompt files are "work in play", so the scaffolded `prompts/*`
# rule is the deterministic match. fire_murmur runs the scaffolded hook against SCRATCH and prints
# its stdout.
fire_murmur() { # <maturity> <state-dir>
  CLAUDE_PROJECT_DIR="$SCRATCH" VAJRA_GUARD_MATURITY="$1" VAJRA_COPILOT_STATE_DIR="$2" \
    bash "$SCAFFOLDED" <<<'{"session_id":"v47"}'
}

# (a) Matching work in play -> murmurs the right include, exit 0 (advisory).
murmurs_matching_work() {
  local sd out rc
  sd=$(mktemp -d); set +e
  out=$(fire_murmur L2 "$sd"); rc=$?
  set -e; rm -rf "$sd"
  [ "$rc" = 0 ] && printf '%s' "$out" | grep -q "prompts/\*" && printf '%s' "$out" | grep -q ".ai/TASK.md"
}
run_check "murmur-fires-on-match" murmurs_matching_work

# (b) Advisory at EVERY maturity — even L3 must NOT block (exit 0). This is the direction-B lane.
advisory_at_l3() {
  local sd rc
  sd=$(mktemp -d); set +e
  fire_murmur L3 "$sd" >/dev/null; rc=$?
  set -e; rm -rf "$sd"
  [ "$rc" = 0 ]
}
run_check "murmur-advisory-at-L3" advisory_at_l3

# (c) Per-session debounce — same state dir fires once, second turn is silent.
debounces_per_session() {
  local sd out2 rc
  sd=$(mktemp -d); set +e
  fire_murmur L2 "$sd" >/dev/null            # first turn (fires)
  out2=$(fire_murmur L2 "$sd"); rc=$?        # second turn (must be silent)
  set -e; rm -rf "$sd"
  [ "$rc" = 0 ] && [ -z "$out2" ]
}
run_check "murmur-debounces" debounces_per_session

# (d) Quiet when nothing matches — a minimal repo whose only changes match no rule -> stays silent.
quiet_when_no_match() {
  local q sd out rc
  q=$(mktemp -d)
  ( cd "$q" && git init -q ) >/dev/null 2>&1
  mkdir -p "$q/.ai" && cp "$SCRATCH/.ai/CONSTRAINTS.yaml" "$q/.ai/"
  : > "$q/notes.txt"     # untracked; matches neither prompts/* nor cmd:git commit
  sd=$(mktemp -d); set +e
  out=$(CLAUDE_PROJECT_DIR="$q" VAJRA_GUARD_MATURITY=L2 VAJRA_COPILOT_STATE_DIR="$sd" \
    bash "$SCAFFOLDED" <<<'{"session_id":"q"}'); rc=$?
  set -e; rm -rf "$q" "$sd"
  [ "$rc" = 0 ] && [ -z "$out" ]
}
run_check "murmur-quiet-no-match" quiet_when_no_match

# --- Hard rule: no commit on this branch touches >3 files (≤3 files per atomic commit) ---
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
printf '%-40s %s\n' "STEP" "RESULT"
printf '%-40s %s\n' "----------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
