#!/usr/bin/env bash
# demo-session-163.sh — S163: fix hollow verify checks (F09 + F08)
# Re-runs the key behavioral conversions as live evidence.
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

echo "demo:header"
echo "=== Session 163 Demo: Hollow → Behavioral Verify Checks ==="
echo ""

echo "demo:cases"
echo "--- Case 1: is_code_session exempts DOCUMENT session (AC1) ---"
TMPDIR_DOC="$(mktemp -d)"
mkdir -p "$TMPDIR_DOC/.ai" "$TMPDIR_DOC/prompts" "$TMPDIR_DOC/scripts"
echo "99" > "$TMPDIR_DOC/.ai/SESSION"
printf '## Type\n**DOCUMENT**\n' > "$TMPDIR_DOC/prompts/99-task-fixture.md"
printf '#!/usr/bin/env bash\necho "no markers"\n' > "$TMPDIR_DOC/scripts/demo-session-99.sh"
chmod +x "$TMPDIR_DOC/scripts/demo-session-99.sh"
CLAUDE_PROJECT_DIR="$TMPDIR_DOC" bash scripts/verify-closeout.sh --demo-only 99 >/dev/null 2>&1 && \
  echo "RESULT: exit 0 — DOCUMENT session exempt (is_code_session works)" || \
  echo "RESULT: UNEXPECTED FAIL"
rm -rf "$TMPDIR_DOC"

echo ""
echo "--- Case 2: check_demo_markers passes with all 4 markers (AC1) ---"
TMPDIR_MK="$(mktemp -d)"
mkdir -p "$TMPDIR_MK/.ai" "$TMPDIR_MK/prompts" "$TMPDIR_MK/scripts"
echo "99" > "$TMPDIR_MK/.ai/SESSION"
printf '## Type\n**CODE**\n' > "$TMPDIR_MK/prompts/99-task-fixture.md"
printf '#!/usr/bin/env bash\necho "demo:header"\necho "demo:cases"\necho "demo:summary_table"\necho "demo:before_after"\n' \
  > "$TMPDIR_MK/scripts/demo-session-99.sh"
chmod +x "$TMPDIR_MK/scripts/demo-session-99.sh"
OUT_MK="$(CLAUDE_PROJECT_DIR="$TMPDIR_MK" bash scripts/verify-closeout.sh --demo-only 99 2>&1)"
rm -rf "$TMPDIR_MK"
echo "$OUT_MK" | grep -q "DEMO: PASS" && \
  echo "RESULT: DEMO: PASS — check_demo_markers fires and all 4 markers confirmed" || \
  echo "RESULT: UNEXPECTED FAIL"

echo ""
echo "--- Case 3: S154 tightening blocks real-plan + no-exec (AC3) ---"
TMPDIR_154="$(mktemp -d)"
mkdir -p "$TMPDIR_154/.ai" "$TMPDIR_154/prompts"
echo "154" > "$TMPDIR_154/.ai/SESSION"
printf '# S154\n> **Status:** APPROVED\n## Plan\n1. a real step covers: 1\n' \
  > "$TMPDIR_154/prompts/154-task-test.md"
CLAUDE_PROJECT_DIR="$TMPDIR_154" bash scripts/verify-closeout.sh --check-exec-shas 154 >/dev/null 2>&1 && \
  echo "RESULT: UNEXPECTED PASS (should have blocked)" || \
  echo "RESULT: exit non-zero — S154 tightening BLOCKS real-plan + no-exec"
rm -rf "$TMPDIR_154"

echo ""
echo "demo:summary_table"
echo "┌───────────────────────────────────────────────────────┐"
echo "│  S163 Hollow → Behavioral Conversion Summary          │"
echo "├────────────────┬──────────────────────────────────────┤"
echo "│ Script          │ Converted                           │"
echo "├────────────────┼──────────────────────────────────────┤"
echo "│ verify-158      │ 2 greps → --demo-only fixtures      │"
echo "│ verify-157      │ 2 greps → cargo test invocations    │"
echo "│ verify-154      │ 2 greps → --check-exec-shas fixture │"
echo "│ verify-163      │ NEW: 10/10 behavioral checks        │"
echo "└────────────────┴──────────────────────────────────────┘"

echo ""
echo "demo:before_after"
echo "BEFORE (hollow):  grep -q 'is_code_session' scripts/verify-closeout.sh"
echo "AFTER (behavioral): CLAUDE_PROJECT_DIR=<fixture> bash scripts/verify-closeout.sh --demo-only 99"
echo ""
echo "The old check found a string. The new check runs the real gate."
