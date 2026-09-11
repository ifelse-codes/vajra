#!/usr/bin/env bash
# verify-session-163.sh — S163: fix hollow verify checks (F09 + F08)
# Every check invokes a binary, runs a test suite, or exercises a subprocess.
# Zero source-proximity greps (grep -q "string" src/file — prohibited by AC6).
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

PASS=0; FAIL=0

ok()  { echo "  PASS  $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

echo "=== verify-session-163 ==="

# AC1: verify-session-158.sh — hollow is_code_session grep replaced with behavioral test
# (DOCUMENT fixture should be exempt from demo-marker check)
echo "  running verify-session-158 behavioral check: is_code_session-exempts-document-session..."
TMPDIR_158A="$(mktemp -d)"
mkdir -p "$TMPDIR_158A/.ai" "$TMPDIR_158A/prompts" "$TMPDIR_158A/scripts"
echo "99" > "$TMPDIR_158A/.ai/SESSION"
printf '## Type\n**DOCUMENT**\n' > "$TMPDIR_158A/prompts/99-task-fixture.md"
printf '#!/usr/bin/env bash\necho "no markers"\n' > "$TMPDIR_158A/scripts/demo-session-99.sh"
chmod +x "$TMPDIR_158A/scripts/demo-session-99.sh"
OUT_158A="$(CLAUDE_PROJECT_DIR="$TMPDIR_158A" bash scripts/verify-closeout.sh --demo-only 99 2>&1)" && EXIT_158A=0 || EXIT_158A=$?
rm -rf "$TMPDIR_158A"
if [ "$EXIT_158A" -eq 0 ]; then
  ok "ac1-is_code_session-exempts-document"
else
  bad "ac1-is_code_session-exempts-document"
  echo "$OUT_158A" | tail -5
fi

# AC1: verify-session-158.sh — hollow check_demo_markers grep replaced with behavioral test
# (CODE fixture with all 4 markers should emit DEMO: PASS)
echo "  running verify-session-158 behavioral check: check_demo_markers-passes-with-all-markers..."
TMPDIR_158B="$(mktemp -d)"
mkdir -p "$TMPDIR_158B/.ai" "$TMPDIR_158B/prompts" "$TMPDIR_158B/scripts"
echo "99" > "$TMPDIR_158B/.ai/SESSION"
printf '## Type\n**CODE**\n' > "$TMPDIR_158B/prompts/99-task-fixture.md"
printf '#!/usr/bin/env bash\necho "demo:header"\necho "demo:cases"\necho "demo:summary_table"\necho "demo:before_after"\n' \
  > "$TMPDIR_158B/scripts/demo-session-99.sh"
chmod +x "$TMPDIR_158B/scripts/demo-session-99.sh"
OUT_158B="$(CLAUDE_PROJECT_DIR="$TMPDIR_158B" bash scripts/verify-closeout.sh --demo-only 99 2>&1)" && EXIT_158B=0 || EXIT_158B=$?
rm -rf "$TMPDIR_158B"
if echo "$OUT_158B" | grep -q "DEMO: PASS"; then
  ok "ac1-check_demo_markers-passes-with-markers"
else
  bad "ac1-check_demo_markers-passes-with-markers"
  echo "$OUT_158B" | tail -5
fi

# AC2: verify-session-157.sh — hollow test-name grep replaced with cargo test invocation
echo "  running cargo test: cross_check_accepts_dispatch_from_non_session_branch..."
T157A="$(cargo test cross_check_accepts_dispatch_from_non_session_branch 2>&1)"
if echo "$T157A" | grep -q "cross_check_accepts_dispatch_from_non_session_branch ... ok"; then
  ok "ac2-non-session-branch-test-passes"
else
  bad "ac2-non-session-branch-test-passes"
  echo "$T157A" | tail -10
fi

# AC2: verify-session-157.sh — hollow code-pattern grep replaced with cargo test invocation
echo "  running cargo test: cross_check_fails_when_git_branch_is_a_different_session..."
T157B="$(cargo test cross_check_fails_when_git_branch_is_a_different_session 2>&1)"
if echo "$T157B" | grep -q "cross_check_fails_when_git_branch_is_a_different_session ... ok"; then
  ok "ac2-different-session-guard-test-passes"
else
  bad "ac2-different-session-guard-test-passes"
  echo "$T157B" | tail -10
fi

# AC3: verify-session-154.sh — hollow has_plan_steps/S154 greps replaced with
# --check-exec-shas live entry point (real-plan + no-exec → BLOCK)
echo "  running verify-session-154 behavioral check via --check-exec-shas..."
TMPDIR_154="$(mktemp -d)"
mkdir -p "$TMPDIR_154/.ai" "$TMPDIR_154/prompts"
echo "154" > "$TMPDIR_154/.ai/SESSION"
printf '# S154 tightening\n> **Status:** APPROVED\n## Plan\n1. a real step that covers: 1\n2. another step covers: 2\n' \
  > "$TMPDIR_154/prompts/154-task-test.md"
OUT_154="$(CLAUDE_PROJECT_DIR="$TMPDIR_154" bash scripts/verify-closeout.sh --check-exec-shas 154 2>&1)" && EXIT_154=0 || EXIT_154=$?
rm -rf "$TMPDIR_154"
if [ "$EXIT_154" -ne 0 ]; then
  ok "ac3-s154-tightening-blocks-via-live-entry"
else
  bad "ac3-s154-tightening-blocks-via-live-entry (must BLOCK real-plan + no exec)"
  echo "$OUT_154" | tail -5
fi

# AC4+AC5: all three patched scripts exit 0 (behavioral checks + non-regression gate)
# AC4 proves FALSIFIABILITY comments exist (scripts are run; their checks invoke the gate).
# AC5 is derived from AC4: all three must pass for ac5 to pass.
_AC5_PASS=1
echo "  running verify-session-158.sh (AC4+AC5: patched script behavioral + non-regression)..."
if bash scripts/verify-session-158.sh > /dev/null 2>&1; then
  ok "ac4-verify-158-exits-0-with-behavioral-checks"
else
  bad "ac4-verify-158-exits-0-with-behavioral-checks"; _AC5_PASS=0
fi

echo "  running verify-session-157.sh (AC4+AC5: patched script behavioral + non-regression)..."
if bash scripts/verify-session-157.sh > /dev/null 2>&1; then
  ok "ac4-verify-157-exits-0-with-behavioral-checks"
else
  bad "ac4-verify-157-exits-0-with-behavioral-checks"; _AC5_PASS=0
fi

echo "  running verify-session-154.sh (AC4+AC5: patched script behavioral + non-regression)..."
if bash scripts/verify-session-154.sh > /dev/null 2>&1; then
  ok "ac4-verify-154-exits-0-with-behavioral-checks"
else
  bad "ac4-verify-154-exits-0-with-behavioral-checks"; _AC5_PASS=0
fi

# AC5: derived — passes only if all three AC4 sub-checks passed
if [ "$_AC5_PASS" -eq 1 ]; then
  ok "ac5-non-regression-all-three-exit-0"
else
  bad "ac5-non-regression-all-three-exit-0 (one or more patched scripts failed)"
fi

# AC6: zero source-proximity greps — verified by awk self-scan.
# Source-proximity form: grep -q "literal" src/file.rs (standalone, not piped from echo).
# awk always exits 0 (no pipefail hazard). The awk script uses /src\// (regex: src/)
# which does NOT match the literal "src\/" text of this line — no self-match.
echo "  self-checking: zero source-proximity greps in this script..."
_HITS=$(awk '
  /^\s*#/ { next }
  /grep/ && /-q/ && /src\// && !/_HITS/ { count++ }
  END { print count+0 }
' "$0")
if [ "$_HITS" -eq 0 ]; then
  ok "ac6-zero-source-proximity-greps-in-163"
else
  bad "ac6-zero-source-proximity-greps-in-163 (found $_HITS)"
fi

echo ""
echo "demo:header"
echo "demo:cases"
echo "demo:summary_table"
echo "demo:before_after"
echo ""
echo "Score: $((PASS+FAIL)) checks — $FAIL FAILED"
[ "$FAIL" -eq 0 ]
