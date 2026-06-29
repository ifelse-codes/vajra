#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="21"
HOOK="$ROOT/scripts/hook-copilot-loader.sh"

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

# Run the hook with a JSON payload + isolated debounce dir.
# Sets global HOOK_OUT (combined stdout+stderr); RETURNS the hook's exit code.
# Call it directly (never inside $(...)) so the caller can read both $? and $HOOK_OUT.
HOOK_OUT=""
call_hook() { # $1=json $2=project_dir $3=state_dir
  HOOK_OUT=$(printf '%s' "$1" | VAJRA_COPILOT_STATE_DIR="$3" CLAUDE_PROJECT_DIR="$2" bash "$HOOK" 2>&1)
}

edit_json() { printf '{"tool_name":"Edit","tool_input":{"file_path":"%s"},"session_id":"verify"}' "$1"; }
bash_json() { printf '{"tool_name":"Bash","tool_input":{"command":"%s"},"session_id":"verify"}' "$1"; }

# --- Deliverable 1: the loader exists and is wired ---
run_check "hook-exists-exec"   test -x "$HOOK"
run_check "wired-twice" bash -c 'test "$(grep -c "hook-copilot-loader.sh" .claude/settings.json)" -eq 2'
run_check "copilot-section"    grep -qE '^copilot:' .ai/CONSTRAINTS.yaml
run_check "rules-present" bash -c 'test "$(grep -cE "^[[:space:]]*-[[:space:]]*\".*=>.*\"" .ai/CONSTRAINTS.yaml)" -ge 3'

# --- Deliverable 2: ⚡on FIRES on matching work (the co-pilot) ---
fire_on_match() {
  local sd rc; sd=$(mktemp -d)
  call_hook "$(edit_json "$ROOT/src/engine/default_engine.rs")" "$ROOT" "$sd"; rc=$?
  rm -rf "$sd"
  [ "$rc" -eq 2 ] || { echo "expected exit 2 (enforce), got $rc"; return 1; }
  echo "$HOOK_OUT" | grep -q "0003-settings-injector" || { echo "missing ADR-0003 include"; return 1; }
  echo "$HOOK_OUT" | grep -qF ".ai/KNOWLEDGE.md"       || { echo "missing KNOWLEDGE include"; return 1; }
  echo "$HOOK_OUT" | grep -qF "⚡on(src/engine/*)"      || { echo "missing ⚡on banner"; return 1; }
}
run_check "fires-on-path-match" fire_on_match

cmd_match() {
  local sd rc; sd=$(mktemp -d)
  call_hook "$(bash_json "git commit -m wip")" "$ROOT" "$sd"; rc=$?
  rm -rf "$sd"
  [ "$rc" -eq 2 ] || { echo "git commit should fire, got $rc"; return 1; }
  echo "$HOOK_OUT" | grep -qF ".ai/STATE.md" || { echo "missing STATE.md include"; return 1; }
}
run_check "fires-on-cmd-match" cmd_match

# --- Deliverable 3: does NOT fire on non-matching work ---
no_fire() {
  local sd rc; sd=$(mktemp -d)
  call_hook "$(edit_json "$ROOT/README.md")" "$ROOT" "$sd"; rc=$?
  rm -rf "$sd"
  [ "$rc" -eq 0 ] || { echo "non-match should pass (0), got $rc"; return 1; }
  [ -z "$HOOK_OUT" ] || { echo "non-match should be silent, got: $HOOK_OUT"; return 1; }
}
run_check "silent-on-non-match" no_fire

# --- Deliverable 4: per-session debounce (fire once, then quiet) ---
debounce() {
  local sd rc; sd=$(mktemp -d)
  call_hook "$(edit_json "$ROOT/src/engine/default_engine.rs")" "$ROOT" "$sd"      # 1st: fires
  call_hook "$(edit_json "$ROOT/src/engine/heuristic/cargo.rs")" "$ROOT" "$sd"; rc=$?
  rm -rf "$sd"
  [ "$rc" -eq 0 ] || { echo "debounced call should pass (0), got $rc"; return 1; }
  [ -z "$HOOK_OUT" ] || { echo "debounced call should be silent, got: $HOOK_OUT"; return 1; }
}
run_check "debounce-once-per-session" debounce

# --- Deliverable 5: the enforce-vs-advise GATE is maturity-gated ---
advise_at_l1() {
  local d sd rc; d=$(mktemp -d); mkdir -p "$d/.ai"
  printf 'maturity: L1\ncopilot:\n  on:\n    - "src/engine/* => a.md | why"\n' > "$d/.ai/CONSTRAINTS.yaml"
  sd=$(mktemp -d)
  call_hook "$(edit_json "$d/src/engine/x.rs")" "$d" "$sd"; rc=$?
  rm -rf "$d" "$sd"
  [ "$rc" -eq 0 ] || { echo "L1 must NOT block, got $rc"; return 1; }
  echo "$HOOK_OUT" | grep -q "consider loading" || { echo "L1 missing advisory text"; return 1; }
}
run_check "gate-advises-at-l1" advise_at_l1

# --- Deliverable 6: every ⚡include target actually exists (anti-rot) ---
includes_exist() {
  local missing=0 f rhs
  while IFS= read -r line; do
    rhs=$(echo "$line" | sed -E 's/^[^=]*=>[[:space:]]*//; s/[[:space:]]*\|.*//')
    local OLDIFS="$IFS"; IFS=','
    for f in $rhs; do
      f=$(echo "$f" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
      [ -n "$f" ] && [ ! -f "$ROOT/$f" ] && { echo "missing include target: $f"; missing=1; }
    done
    IFS="$OLDIFS"
  done < <(grep -E '^[[:space:]]*-[[:space:]]*".*=>.*"' .ai/CONSTRAINTS.yaml | sed -E 's/^[[:space:]]*-[[:space:]]*"(.*)"[[:space:]]*$/\1/')
  [ "$missing" -eq 0 ]
}
run_check "include-targets-exist" includes_exist

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
