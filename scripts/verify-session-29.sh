#!/usr/bin/env bash
# Session 29 — Propagate the one-session-per-chat guard into `vajra init`.
# A freshly-`init`ed project must inherit scripts/hook-session-guard.sh (byte-identical,
# executable), the PreToolUse(Bash) wiring, `one_session_per_chat: true`, and a `.gitignore`
# for `.ai/.session-owner`. Closes the second half of the S28 split (S22/S28 pattern).
# Proven end-to-end: actually scaffold into a temp git repo and assert the wiring.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="29"
CANON_HOOK="$ROOT/scripts/hook-session-guard.sh"

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
# The four new scaffold tests must exist and pass.
run_check "test-guard-verbatim"  cargo test scaffold_ships_session_guard_verbatim
run_check "test-guard-wired"     cargo test scaffold_wires_session_guard_into_settings
run_check "test-flag-emitted"    cargo test scaffold_emits_one_session_per_chat_flag
run_check "test-gitignore-owner" cargo test scaffold_gitignores_session_owner

# --- Packaging: the include_str!'d hook must ship with `cargo install` (S22 gotcha) ---
guard_in_package() { cargo package --list --allow-dirty 2>/dev/null | grep -q '^scripts/hook-session-guard.sh$'; }
run_check "guard-in-cargo-package" guard_in_package

# --- End-to-end: a real `vajra init` inherits the session-guard ---
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT
( cd "$SCRATCH" && git init -q )
# Drive the interactive prompts: project name, goal, maturity (blank -> L2).
printf 'demo-proj\nbuild it\n\n' | ( cd "$SCRATCH" && "$ROOT/target/debug/vajra" init ) >/dev/null 2>&1 || true

run_check "e2e-guard-present"        test -f "$SCRATCH/scripts/hook-session-guard.sh"
run_check "e2e-guard-executable"     test -x "$SCRATCH/scripts/hook-session-guard.sh"
run_check "e2e-guard-byte-identical" cmp -s "$SCRATCH/scripts/hook-session-guard.sh" "$CANON_HOOK"
run_check "e2e-settings-wires-guard" grep -q "hook-session-guard.sh" "$SCRATCH/.claude/settings.json"
run_check "e2e-flag-true"            grep -q "one_session_per_chat: true" "$SCRATCH/.ai/CONSTRAINTS.yaml"
run_check "e2e-gitignore-owner"      grep -q ".ai/.session-owner" "$SCRATCH/.gitignore"
# Regression: S22 co-pilot + S28 Darshan propagation still hold.
run_check "e2e-copilot-still-wired"  grep -q "hook-copilot-loader.sh" "$SCRATCH/.claude/settings.json"
run_check "e2e-darshan-still-shipped" test -f "$SCRATCH/darshan/SKILL.md"

# --- The scaffolded guard actually enforces in the fresh project ---
# First checkout records the owning chat; the SAME chat's N->N+1 checkout is blocked (exit 2 at L2).
guard_blocks_same_chat() {
  local owner; owner=$(mktemp)
  printf '{"tool_name":"Bash","tool_input":{"command":"git checkout -b session-02-x"},"session_id":"chatA"}' \
    | VAJRA_SESSION_OWNER_FILE="$owner" bash "$SCRATCH/scripts/hook-session-guard.sh" >/dev/null 2>&1 || true
  # Now the same chat tries to cross 02 -> 03: must be blocked (exit 2).
  printf '{"tool_name":"Bash","tool_input":{"command":"git checkout -b session-03-y"},"session_id":"chatA"}' \
    | VAJRA_SESSION_OWNER_FILE="$owner" bash "$SCRATCH/scripts/hook-session-guard.sh" >/dev/null 2>&1
  local rc=$?
  rm -f "$owner"
  [ "$rc" -eq 2 ]
}
run_check "scaffolded-guard-enforces" guard_blocks_same_chat

# --- Enforcement-not-renderer holds: `init` only *embeds* the guard (include_str!) and wires
# config strings — it never spawns or parses it. (Contrast the co-pilot, which first_run_aha
# spawns.) Assert: exactly one include_str! of the guard, and no Command runs it. ---
guard_embedded_not_executed() {
  grep -q 'include_str!("../../scripts/hook-session-guard.sh")' "$ROOT/src/cli/init.rs" \
    && ! grep -qE 'Command::new\("bash"\)[^;]*hook-session-guard|arg\([^)]*hook-session-guard' "$ROOT/src/cli/init.rs"
}
run_check "enforcement-not-renderer" guard_embedded_not_executed

# --- No 8th command: exactly 7 real subcommand dispatch arms ---
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
