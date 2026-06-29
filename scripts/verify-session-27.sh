#!/usr/bin/env bash
# Session 27 — Darshan: Vajra's default, surface-adaptive, glanceable human-output
# skill (skill, not renderer; pairs with Varta). Asserts the skill exists with all
# 3 surface tiers, the "never drop meaning" rule, a terminal fallback, and the boot
# wiring in .ai/AGENTS.md. No src/ touched — but keep the Rust bar green.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="27"
SKILL="$ROOT/darshan/SKILL.md"
AGENTS="$ROOT/.ai/AGENTS.md"

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

# --- Rust gates (no source change, but keep the bar) ---
run_check "cargo-fmt"        cargo fmt -- --check
run_check "cargo-clippy"     cargo clippy --all-targets -- -D warnings
run_check "cargo-test"       cargo test

# --- The skill exists and is shaped like a skill (frontmatter name+description) ---
run_check "skill-exists"        test -f "$SKILL"
run_check "skill-frontmatter"   grep -qE '^name: darshan$' "$SKILL"
run_check "skill-description"    grep -qE '^description: ' "$SKILL"

# --- The one rule, verbatim intent: never drop meaning ---
run_check "rule-never-drop"     grep -qi "never drop meaning" "$SKILL"
run_check "rule-glanceable"     grep -qi "glanceable" "$SKILL"

# --- All 3 surface tiers are present ---
run_check "tier-rich-chat"      grep -qiE "rich chat" "$SKILL"
run_check "tier-terminal"       grep -qiE "terminal */ *TUI|terminal tier|terminal / tui" "$SKILL"
run_check "tier-plain"          grep -qiE "plain */ *no-color|plain / no-color|plain / no-color" "$SKILL"

# --- A terminal fallback is taught (degrade a tier, never emit garbage) ---
run_check "terminal-fallback"   grep -qi "terminal fallback" "$SKILL"
# A worked terminal-tier example uses box-drawing (proves "show, don't tell")
run_check "box-drawing-example" grep -qF "┌" "$SKILL"

# --- Skill-not-renderer guardrail is explicit ---
run_check "skill-not-renderer"  grep -qiE "skill,? not a renderer|there is no renderer" "$SKILL"

# --- Boot wiring: Darshan is taught as the default human-output skill in AGENTS.md ---
run_check "boot-wired-agents"   grep -qi "Darshan" "$AGENTS"
run_check "boot-default-human"  grep -qiE "Default for all human output|default human output" "$AGENTS"

# --- No 8th command snuck in (max 7) ---
no_eighth_cmd() {
  # The launcher enum lives in src/cli; assert Darshan added no command variant.
  ! grep -rqiE 'Darshan' "$ROOT/src" 2>/dev/null
}
run_check "no-new-command"      no_eighth_cmd

# --- VISION.md gained the human lane ---
run_check "vision-human-lane"   grep -qi "Darshan" "$ROOT/VISION.md"

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
