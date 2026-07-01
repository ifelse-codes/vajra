#!/usr/bin/env bash
# Session 32 — Darshan enforcement: advised -> enforced.
# The SessionStart boot packet must surface the Darshan speaking skill IN the boot output
# every session (was only a prose row in AGENTS.md the agent skipped — S31 #1), and a fresh
# `vajra init` must inherit that surfacing byte-identically (S22/S28/S29 include_str! pattern).
# Proven end-to-end: run the real boot hook + scaffold into a temp git repo and assert.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="32"
CANON_HOOK="$ROOT/scripts/hook-session-start.sh"
MARKER="SPEAKING SKILL · DARSHAN"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-38s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-38s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"            cargo fmt -- --check
run_check "cargo-clippy"         cargo clippy --all-targets -- -D warnings
run_check "cargo-test"           cargo test

# --- Core: the real boot hook surfaces Darshan IN the packet (advised -> enforced) ---
# Capture once to a here-string; piping the hook straight into `grep -q` makes grep close
# the pipe early -> the hook's `cat` takes SIGPIPE -> pipefail reports the pipeline failed
# even on a match. Grepping captured output avoids that false RED.
BOOT_OUT="$(CLAUDE_PROJECT_DIR="$ROOT" bash "$CANON_HOOK" 2>/dev/null)"
run_check "boot-surfaces-darshan" grep -q "$MARKER" <<<"$BOOT_OUT"
# The one rule + a speak-back ACK must both be present (not just a bare pointer).
run_check "boot-has-one-rule"     grep -q "richest visual this surface" <<<"$BOOT_OUT"
run_check "boot-has-speak-back"   grep -q "ACK NOW" <<<"$BOOT_OUT"

# --- Packaging: the include_str!'d hook must ship with `cargo install` (S22 gotcha) ---
hook_in_package() { cargo package --list --allow-dirty 2>/dev/null | grep -q '^scripts/hook-session-start.sh$'; }
run_check "hook-in-cargo-package" hook_in_package

# --- One-source: init embeds the canonical hook verbatim, never an inline copy ---
init_embeds_canonical() {
  grep -q 'include_str!("../../scripts/hook-session-start.sh")' "$ROOT/src/cli/init.rs"
}
run_check "init-embeds-canonical" init_embeds_canonical

# --- End-to-end: a real `vajra init` inherits the Darshan-surfacing boot hook ---
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT
( cd "$SCRATCH" && git init -q )
printf 'demo-proj\nbuild it\n\n' | ( cd "$SCRATCH" && "$ROOT/target/debug/vajra" init ) >/dev/null 2>&1 || true

run_check "e2e-hook-present"          test -f "$SCRATCH/scripts/hook-session-start.sh"
run_check "e2e-hook-executable"       test -x "$SCRATCH/scripts/hook-session-start.sh"
run_check "e2e-hook-byte-identical"   cmp -s "$SCRATCH/scripts/hook-session-start.sh" "$CANON_HOOK"
run_check "e2e-scaffold-surfaces-darshan" grep -q "$MARKER" "$SCRATCH/scripts/hook-session-start.sh"
run_check "e2e-settings-wires-hook"   grep -q "hook-session-start.sh" "$SCRATCH/.claude/settings.json"
# Regression: S27/S28 Darshan skill + S22/S29 propagation still hold.
run_check "e2e-darshan-still-shipped" test -f "$SCRATCH/darshan/SKILL.md"
run_check "e2e-copilot-still-wired"   grep -q "hook-copilot-loader.sh" "$SCRATCH/.claude/settings.json"
run_check "e2e-guard-still-shipped"   test -f "$SCRATCH/scripts/hook-session-guard.sh"

# --- Skill-not-renderer holds: init only *embeds* + copies; nothing in Rust runs/parses
# the boot hook or draws Darshan. Assert no Command spawns the hook. ---
not_a_renderer() {
  ! grep -qE 'Command::new\("bash"\)[^;]*hook-session-start|arg\([^)]*hook-session-start' "$ROOT/src/cli/init.rs"
}
run_check "skill-not-renderer" not_a_renderer

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
printf '%-38s %s\n' "STEP" "RESULT"
printf '%-38s %s\n' "--------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
