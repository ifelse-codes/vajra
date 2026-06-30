#!/usr/bin/env bash
# Session 28 — Propagate Darshan into `vajra init` (session-guard split to S29).
# A freshly-`init`ed project must inherit the Darshan human-output skill + the
# AGENTS.md Speaking Skills boot pointer, byte-identical to canonical (S22 pattern).
# Proven end-to-end: actually scaffold into a temp git repo and assert the files.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="28"
CANON_SKILL="$ROOT/darshan/SKILL.md"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-36s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-36s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"            cargo fmt -- --check
run_check "cargo-clippy"         cargo clippy --all-targets -- -D warnings
run_check "cargo-test"           cargo test
# The two new scaffold tests must exist and pass.
run_check "test-darshan-verbatim"  cargo test scaffold_ships_darshan_skill_verbatim
run_check "test-darshan-wired"     cargo test scaffold_wires_darshan_into_constitution

# --- End-to-end: a real `vajra init` inherits Darshan ---
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT
( cd "$SCRATCH" && git init -q )
# Drive the interactive prompts: project name, goal, maturity (blank -> L2).
printf 'demo-proj\nbuild it\n\n' | ( cd "$SCRATCH" && "$ROOT/target/debug/vajra" init ) >/dev/null 2>&1 || true

run_check "e2e-skill-present"    test -f "$SCRATCH/darshan/SKILL.md"
run_check "e2e-skill-byte-identical" cmp -s "$SCRATCH/darshan/SKILL.md" "$CANON_SKILL"
run_check "e2e-agents-speaking"  grep -qi "Speaking Skills" "$SCRATCH/.ai/AGENTS.md"
run_check "e2e-agents-points-darshan" grep -q "darshan/SKILL.md" "$SCRATCH/.ai/AGENTS.md"
# Regression: the S22 co-pilot propagation still works.
run_check "e2e-copilot-still-wired" grep -q "hook-copilot-loader.sh" "$SCRATCH/.claude/settings.json"

# --- Skill-not-renderer holds: no Rust code renders Darshan (only include_str! + copy) ---
no_render() { ! grep -rqiE 'fn .*render.*darshan|darshan.*render' "$ROOT/src" 2>/dev/null; }
run_check "skill-not-renderer"   no_render

# --- No 8th command: exactly 7 real subcommand dispatch arms (help is meta) ---
seven_commands() {
  local n
  n=$(grep -cE '^[[:space:]]*"[a-z]+" => Subcommand::' "$ROOT/src/main.rs")
  [ "$n" -eq 7 ]
}
run_check "no-eighth-command"    seven_commands

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-36s %s\n' "STEP" "RESULT"
printf '%-36s %s\n' "------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
