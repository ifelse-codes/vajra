#!/usr/bin/env bash
# Session 34 — Brownfield onboarding (S31 finding #3, last of the three core breakages).
# 1. `vajra init` on an existing codebase emits a guided session-0 brief
#    (prompts/00-task-brownfield-onboarding.md), sets .ai/SESSION=00, and points
#    TASK.md/SESSION-BOOT.md at it — the agent studies the repo and fills
#    KNOWLEDGE.md/STATE.md with reality before any feature work.
# 2. Scaffolded hooks land in .ai/hooks/ (Vajra's own), never in the project's scripts/.
# 3. `vajra claude` fails fast with a clear message when no Claude Code credentials
#    exist (presence-only check: env key / credentials file / oauthAccount / Keychain;
#    VAJRA_SKIP_AUTH_CHECK=1 bypasses).
# Meta-rule (S31): advised -> enforced, third instance. E2E checks below run the real
# binary against a real-shaped brownfield repo — not just unit-test greps.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="34"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-34s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-34s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# --- Rust gates ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "cargo-build"   cargo build

BIN="$ROOT/target/debug/vajra"

# --- E2E: brownfield repo gets the session-0 onboarding path ---
run_check "e2e-brownfield-session-zero" bash -c '
  set -e
  T=$(mktemp -d); trap "rm -rf \"$T\"" EXIT
  mkdir -p "$T/.git" "$T/src"
  echo "print(42)" > "$T/src/app.py"; echo "{}" > "$T/package.json"
  ( cd "$T" && printf "\n\n\n" | "'"$BIN"'" init >/dev/null 2>&1 )
  [ "$(cat "$T/.ai/SESSION")" = "00" ]
  [ -f "$T/prompts/00-task-brownfield-onboarding.md" ]
  grep -q "00-task-brownfield-onboarding" "$T/.ai/TASK.md"
  grep -q "00-task-brownfield-onboarding" "$T/.ai/SESSION-BOOT.md"
  grep -q "KNOWLEDGE.md" "$T/prompts/00-task-brownfield-onboarding.md"
  grep -q "Docs only"    "$T/prompts/00-task-brownfield-onboarding.md"
  [ -f "$T/prompts/01-task-kickoff.md" ]
'

# --- E2E: greenfield repo is untouched by the new path (still session 01) ---
run_check "e2e-greenfield-still-01" bash -c '
  set -e
  T=$(mktemp -d); trap "rm -rf \"$T\"" EXIT
  mkdir -p "$T/.git"
  ( cd "$T" && printf "\n\n\n" | "'"$BIN"'" init >/dev/null 2>&1 )
  [ "$(cat "$T/.ai/SESSION")" = "01" ]
  [ ! -e "$T/prompts/00-task-brownfield-onboarding.md" ]
  grep -q "01-task-kickoff" "$T/.ai/TASK.md"
'

# --- E2E: hooks live in .ai/hooks/, never the project scripts/; settings agree ---
run_check "e2e-hooks-out-of-scripts" bash -c '
  set -e
  T=$(mktemp -d); trap "rm -rf \"$T\"" EXIT
  mkdir -p "$T/.git" "$T/scripts"; echo "own package" > "$T/scripts/build.sh"
  ( cd "$T" && printf "\n\n\n" | "'"$BIN"'" init >/dev/null 2>&1 )
  for h in hook-session-start.sh hook-copilot-loader.sh hook-session-guard.sh; do
    [ -x "$T/.ai/hooks/$h" ]
    [ ! -e "$T/scripts/$h" ]
  done
  grep -q "\$CLAUDE_PROJECT_DIR/.ai/hooks/hook-session-start.sh" "$T/.claude/settings.json"
  ! grep -q "scripts/hook-" "$T/.claude/settings.json"
'

# --- E2E: auth pre-check fails fast without credentials, and the bypass works ---
# A fake HOME + failing `security` + fake `claude` isolate the check from this machine.
run_check "e2e-auth-precheck-fails-fast" bash -c '
  set -e
  T=$(mktemp -d); trap "rm -rf \"$T\"" EXIT
  mkdir -p "$T/bin" "$T/home"
  printf "#!/bin/sh\nexit 1\n" > "$T/bin/security"
  printf "#!/bin/sh\nexit 0\n" > "$T/bin/claude"
  chmod +x "$T/bin/security" "$T/bin/claude"
  OUT=$(env PATH="$T/bin:$PATH" HOME="$T/home" ANTHROPIC_API_KEY= VAJRA_SKIP_AUTH_CHECK= \
        "'"$BIN"'" claude 2>&1) && exit 1 || true
  echo "$OUT" | grep -q "no Claude Code credentials found"
  env PATH="$T/bin:$PATH" HOME="$T/home" ANTHROPIC_API_KEY= VAJRA_SKIP_AUTH_CHECK=1 VAJRA_QUIET=1 \
      "'"$BIN"'" claude >/dev/null 2>&1
'

# --- Unit coverage for the new logic exists ---
run_check "unit-brownfield-tests" bash -c \
  'grep -q "fn scaffold_existing_code_gets_session_zero" src/cli/init.rs &&
   grep -q "fn scaffold_hooks_land_in_ai_hooks_not_scripts" src/cli/init.rs'
run_check "unit-auth-tests" bash -c \
  'grep -q "fn auth_evidence_accepts_oauth_account_marker" src/cli/launch.rs'

# --- ≤3 files per atomic commit (constitution cap), every commit on this branch ---
run_check "three-file-cap-per-commit" bash -c '
  for c in $(git log main..HEAD --format=%H 2>/dev/null); do
    n=$(git diff-tree --no-commit-id --name-only -r "$c" | wc -l | tr -d " ")
    [ "$n" -le 3 ] || exit 1
  done
'

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
