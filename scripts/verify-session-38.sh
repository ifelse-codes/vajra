#!/usr/bin/env bash
# Session 38 — Propagate the publish-guard into `vajra init`.
# S37 shipped hook-publish-guard.sh but only for the vajra repo. The S36 leak happened in a
# scaffolded brownfield project, so the guard must be inherited by every project `vajra init`
# touches. This session embeds it via include_str! (S29 pattern), wires it into the scaffolded
# .claude/settings.json, and un-excludes it in Cargo.toml so `cargo install` ships it.
# Proven end-to-end: a real `vajra init` into a temp repo emits the guard and its scaffolded
# copy actually blocks a `git push` payload at L2 (exit 2).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="38"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

CANON_HOOK="$ROOT/scripts/hook-publish-guard.sh"

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
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test

# --- The two new scaffold unit tests must exist and pass ---
run_check "test-guard-verbatim" cargo test scaffold_ships_publish_guard_verbatim
run_check "test-guard-wired"    cargo test scaffold_wires_publish_guard_into_settings

# --- Packaging: the include_str!'d hook must ship with `cargo install` (S22 gotcha) ---
guard_in_package() { cargo package --list --allow-dirty 2>/dev/null | grep -q '^scripts/hook-publish-guard.sh$'; }
run_check "guard-in-cargo-package" guard_in_package

# --- Build the binary the E2E drives ---
run_check "cargo-build" cargo build

# --- End-to-end: a real `vajra init` inherits the publish-guard ---
SCRATCH=$(mktemp -d)
trap 'rm -rf "$SCRATCH"' EXIT
( cd "$SCRATCH" && git init -q )
# Drive the interactive prompts: project name, goal, maturity (blank -> L2).
printf 'demo-proj\nbuild it\n\n' | ( cd "$SCRATCH" && "$ROOT/target/debug/vajra" init ) >/dev/null 2>&1 || true

SCAFFOLDED="$SCRATCH/.ai/hooks/hook-publish-guard.sh"
run_check "e2e-guard-present"        test -f "$SCAFFOLDED"
run_check "e2e-guard-executable"     test -x "$SCAFFOLDED"
run_check "e2e-guard-byte-identical" cmp -s "$SCAFFOLDED" "$CANON_HOOK"
run_check "e2e-settings-wires-guard" grep -q "hook-publish-guard.sh" "$SCRATCH/.claude/settings.json"
# Regression: the S26/S29 session-guard + S22 co-pilot wiring still hold.
run_check "e2e-session-guard-wired"  grep -q "hook-session-guard.sh" "$SCRATCH/.claude/settings.json"
run_check "e2e-copilot-still-wired"  grep -q "hook-copilot-loader.sh" "$SCRATCH/.claude/settings.json"

# --- The scaffolded guard actually enforces in the fresh project ---
# git push is BLOCKED at L2 without approval (exit 2); ALLOWED with VAJRA_ALLOW_PUBLISH=1 (exit 0).
# fire_guard drives the scaffolded hook and returns ITS exit code.
fire_guard() { # <maturity> <allow> <command>
  local json
  json=$(printf '%s' "$3" | jq -Rs '{tool_name:"Bash",tool_input:{command:.}}')
  CLAUDE_PROJECT_DIR="$SCRATCH" VAJRA_GUARD_MATURITY="$1" VAJRA_ALLOW_PUBLISH="$2" \
    bash "$SCAFFOLDED" <<<"$json" >/dev/null 2>&1
}
expect_guard() { # <expected-rc> <maturity> <allow> <command>
  local expected="$1"; shift; local rc
  set +e; fire_guard "$@"; rc=$?; set -e
  [ "$rc" = "$expected" ]
}
run_check "scaffolded-blocks-push-L2"    expect_guard 2 L2 ""  "git push origin main"
run_check "scaffolded-allows-with-env"   expect_guard 0 L2 "1" "git push origin main"
run_check "scaffolded-passes-git-status" expect_guard 0 L2 ""  "git status"

# --- Enforcement-not-renderer: init only *embeds* the guard (include_str!) and wires config
# strings — it never spawns or parses it (contrast the co-pilot, which first_run_aha spawns). ---
guard_embedded_not_executed() {
  grep -q 'include_str!("../../scripts/hook-publish-guard.sh")' "$ROOT/src/cli/init.rs" \
    && ! grep -qE 'Command::new[^;]*hook-publish-guard|arg\([^)]*hook-publish-guard' "$ROOT/src/cli/init.rs"
}
run_check "enforcement-not-renderer" guard_embedded_not_executed

# --- Cargo.toml un-excludes the hook so `cargo install` compiles it ---
run_check "cargo-toml-unexcludes" grep -q '!scripts/hook-publish-guard.sh' "$ROOT/Cargo.toml"

# --- ≤3 files changed vs main (feature slice) ---
run_check "three-file-cap" bash -c \
  '[ "$(git diff --name-only main... 2>/dev/null | wc -l | tr -d " ")" -le 3 ] || \
   [ "$(git status --porcelain 2>/dev/null | wc -l | tr -d " ")" -le 3 ]'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-38s %s\n' "STEP" "RESULT"
printf '%-38s %s\n' "--------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
