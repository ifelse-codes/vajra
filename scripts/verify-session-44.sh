#!/usr/bin/env bash
# Session 44 — merge into an existing `.claude/settings.json` on `vajra init` (founder pick B).
#
# The gap (S34 finding): `vajra init` followed a skip-if-present convention for every file.
# For `.claude/settings.json` that was wrong — a brownfield project that already had one kept
# it untouched, so Vajra's hooks (SessionStart Darshan boot; PreToolUse co-pilot + session-guard
# + publish-guard; Edit|Write co-pilot) were NEVER wired. The scaffolded `.ai/hooks/` files all
# existed but nothing fired them → the whole L3 enforcement moat was silently absent for exactly
# the primary use case.
#
# The fix: for `.claude/settings.json` ONLY, init now MERGES Vajra's hook groups into the user's
# file additively + idempotently (every other file keeps skip-if-present). Malformed existing
# JSON is left untouched with a loud warning (never silently overwritten).
#
# Proof strategy: a real `vajra init` into a temp dir with a PRE-EXISTING `.claude/settings.json`
# (carrying a user hook + an unrelated top-level key) → assert the user's hook + key survive AND
# all four Vajra hooks are now wired AND the result is valid JSON. Run init twice → no duplicate
# Vajra entries. A greenfield dir (no settings) still writes the canonical file (regression). A
# malformed pre-existing file is preserved byte-for-byte with a warning. Plus the Rust gates.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="44"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

VAJRA="$ROOT/target/debug/vajra"

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

# --- Rust gates (init.rs unit tests assert the merge is additive, idempotent, preserves user
#     keys/hooks, and rejects malformed/non-object JSON) ---
run_check "cargo-fmt"     cargo fmt -- --check
run_check "cargo-clippy"  cargo clippy --all-targets -- -D warnings
run_check "cargo-test"    cargo test
run_check "cargo-build"   cargo build

VALID_JSON() { jq -e . "$1" >/dev/null 2>&1; }
grep_count() { grep -c "$1" "$2" 2>/dev/null || echo 0; }

# A realistic pre-existing user file: unrelated top-level key + user SessionStart hook +
# user PreToolUse Bash group — the merge must preserve all three.
USER_SETTINGS='{
  "model": "claude-opus-4",
  "hooks": {
    "SessionStart": [ { "hooks": [ { "type": "command", "command": "echo user-boot" } ] } ],
    "PreToolUse": [ { "matcher": "Bash", "hooks": [ { "type": "command", "command": "echo user-bash" } ] } ]
  }
}'

VAJRA_HOOKS=(hook-session-start.sh hook-copilot-loader.sh hook-session-guard.sh hook-publish-guard.sh)

# =====================================================================================
# E2E 1: real `vajra init` into a BROWNFIELD dir with a pre-existing settings.json → merge.
# =====================================================================================
BROWN=$(mktemp -d)
GREEN=$(mktemp -d)
BAD=$(mktemp -d)
trap 'rm -rf "$BROWN" "$GREEN" "$BAD"' EXIT

mkdir -p "$BROWN/.claude"
printf '%s\n' "$USER_SETTINGS" > "$BROWN/.claude/settings.json"
printf '{}\n' > "$BROWN/package.json"   # makes it a real brownfield project
SETTINGS="$BROWN/.claude/settings.json"

printf 'demo-proj\nbuild it\n\n' | ( cd "$BROWN" && "$VAJRA" init ) >/dev/null 2>&1 || true

run_check "merge-output-valid-json"       VALID_JSON "$SETTINGS"
run_check "merge-keeps-user-key"          grep -q "claude-opus-4" "$SETTINGS"
run_check "merge-keeps-user-sessionstart" grep -q "echo user-boot" "$SETTINGS"
run_check "merge-keeps-user-pretooluse"   grep -q "echo user-bash" "$SETTINGS"
for h in "${VAJRA_HOOKS[@]}"; do
  run_check "merge-wires-$h"              grep -q "$h" "$SETTINGS"
done

# =====================================================================================
# E2E 2: idempotence — a second `vajra init` must not duplicate Vajra entries.
# =====================================================================================
printf 'demo-proj\nbuild it\n\n' | ( cd "$BROWN" && "$VAJRA" init ) >/dev/null 2>&1 || true
guard_once()   { [ "$(grep_count hook-session-guard.sh "$SETTINGS")" = "1" ]; }
publish_once() { [ "$(grep_count hook-publish-guard.sh "$SETTINGS")" = "1" ]; }
start_once()   { [ "$(grep_count hook-session-start.sh  "$SETTINGS")" = "1" ]; }
copilot_twice(){ [ "$(grep_count hook-copilot-loader.sh "$SETTINGS")" = "2" ]; }
user_boot_once() { [ "$(grep_count "echo user-boot" "$SETTINGS")" = "1" ]; }
run_check "idempotent-session-guard-once" guard_once
run_check "idempotent-publish-guard-once" publish_once
run_check "idempotent-session-start-once" start_once
run_check "idempotent-copilot-twice"      copilot_twice
run_check "idempotent-user-hook-once"     user_boot_once

# =====================================================================================
# E2E 3: greenfield (no pre-existing settings) still writes the canonical file (regression).
# =====================================================================================
printf 'demo-proj\nbuild it\n\n' | ( cd "$GREEN" && "$VAJRA" init ) >/dev/null 2>&1 || true
GSETTINGS="$GREEN/.claude/settings.json"
run_check "greenfield-writes-settings"    test -f "$GSETTINGS"
run_check "greenfield-valid-json"         VALID_JSON "$GSETTINGS"
greenfield_has_all_hooks() {
  for h in "${VAJRA_HOOKS[@]}"; do grep -q "$h" "$GSETTINGS" || return 1; done
}
run_check "greenfield-has-all-vajra-hooks" greenfield_has_all_hooks
run_check "greenfield-is-clean"            bash -c '! grep -q "echo user" "'"$GSETTINGS"'"'

# =====================================================================================
# E2E 4: a malformed pre-existing settings.json is left UNTOUCHED with a warning (fail loud,
#         never silently overwrite the user's file); init still exits 0.
# =====================================================================================
mkdir -p "$BAD/.claude"
printf '{ this is not valid json\n' > "$BAD/.claude/settings.json"
BAD_BEFORE=$(cat "$BAD/.claude/settings.json")
BAD_RC=0
printf 'demo-proj\nbuild it\n\n' | ( cd "$BAD" && "$VAJRA" init ) > "$ARTIFACTS/malformed-init.log" 2>&1 || BAD_RC=$?
run_check "malformed-init-exits-zero"     test "$BAD_RC" = "0"
malformed_untouched() { [ "$(cat "$BAD/.claude/settings.json")" = "$BAD_BEFORE" ]; }
run_check "malformed-file-untouched"      malformed_untouched
run_check "malformed-warns-loudly"        grep -q "left untouched" "$ARTIFACTS/malformed-init.log"

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-46s %s\n' "STEP" "RESULT"
printf '%-46s %s\n' "----------------------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
