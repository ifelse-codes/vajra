#!/usr/bin/env bash
# verify-session-158.sh — S158: demo enforcement
# Checks: AC1 (check_verify_demo_scripts is CODE-type-aware), AC2 (check_demo_markers in closeout),
#         AC3 (cargo test), AC4 (cargo build --release), AC5 (S158 demo exits 0 + all 4 markers)
set -euo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

PASS=0; FAIL=0

ok()  { echo "  PASS  $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

named_test_passed() {
  local out="$1" name="$2"
  echo "$out" | grep -q "${name} ... ok" && echo "$out" | grep -qE "test result: ok\. [1-9][0-9]* passed"
}

echo "=== verify-session-158 ==="

# AC1: is_code_session helper present in verify-closeout.sh
if grep -q "is_code_session" scripts/verify-closeout.sh; then
  ok "is_code_session-present"
else
  bad "is_code_session-present (helper not found in verify-closeout.sh)"
fi

# AC1 behavioral: check_demo_markers blocks on marker-free CODE session
TMPDIR_BH="$(mktemp -d)"
mkdir -p "$TMPDIR_BH/.ai" "$TMPDIR_BH/prompts" "$TMPDIR_BH/scripts"
echo "99" > "$TMPDIR_BH/.ai/SESSION"
printf '## Type\n**CODE**\n' > "$TMPDIR_BH/prompts/99-task-fixture.md"
printf '#!/usr/bin/env bash\necho "no markers"\n' > "$TMPDIR_BH/scripts/demo-session-99.sh"
chmod +x "$TMPDIR_BH/scripts/demo-session-99.sh"
BHAV_OUT="$(CLAUDE_PROJECT_DIR="$TMPDIR_BH" bash scripts/verify-closeout.sh --demo-only 99 2>&1)" && BHAV_EXIT=0 || BHAV_EXIT=$?
rm -rf "$TMPDIR_BH"
if [ "$BHAV_EXIT" -ne 0 ] || echo "$BHAV_OUT" | grep -q "DEMO: FAIL"; then
  ok "check_demo_markers-blocks-marker-free-code-session"
else
  bad "check_demo_markers-blocks-marker-free-code-session (should FAIL but did not)"
  echo "$BHAV_OUT" | tail -5
fi

# AC2: check_demo_markers function present in verify-closeout.sh
if grep -q "check_demo_markers" scripts/verify-closeout.sh; then
  ok "check_demo_markers-present"
else
  bad "check_demo_markers-present (function not found in verify-closeout.sh)"
fi

# AC2: check_demo_markers wired into main sequence
MAIN_SEQ=$(awk '/^check_session_file$/,/^check_review_attestation$/' scripts/verify-closeout.sh)
if echo "$MAIN_SEQ" | grep -q "check_demo_markers"; then
  ok "check_demo_markers-in-main-sequence"
else
  bad "check_demo_markers-in-main-sequence"
fi

# AC2: DOCUMENT session is exempt — is_code_session returns false for document type
if grep -q "document" scripts/verify-closeout.sh && grep -q "is_code_session" scripts/verify-closeout.sh; then
  ok "document-session-exempt"
else
  bad "document-session-exempt (is_code_session or document exemption missing from verify-closeout.sh)"
fi

# AC3: cargo test
echo "  running cargo test..."
TEST_OUT=$(cargo test 2>&1)
if echo "$TEST_OUT" | grep -q "^test result: ok"; then
  ok "cargo-test-all-green"
else
  bad "cargo-test-all-green"
  echo "$TEST_OUT" | tail -20
fi

# AC4: cargo build --release
echo "  running cargo build --release..."
if cargo build --release 2>&1; then
  ok "cargo-build-release"
else
  bad "cargo-build-release"
fi

# AC5: demo-session-158.sh exists and is non-empty
if [ -f scripts/demo-session-158.sh ] && [ -s scripts/demo-session-158.sh ]; then
  ok "demo-script-158-present"
else
  bad "demo-script-158-present (scripts/demo-session-158.sh missing or empty)"
fi

# AC5: demo-session-158.sh exits 0 and emits all 4 required markers
echo "  running demo-session-158.sh..."
DEMO_OUT=$(bash scripts/demo-session-158.sh 2>&1) && DEMO_EXIT=0 || DEMO_EXIT=$?
if [ "$DEMO_EXIT" -eq 0 ]; then
  ok "demo-exits-0"
else
  bad "demo-exits-0 (exit code: $DEMO_EXIT)"
fi

for marker in header cases summary_table before_after; do
  if echo "$DEMO_OUT" | grep -q "demo:${marker}"; then
    ok "demo-marker-${marker}"
  else
    bad "demo-marker-${marker} (missing from demo output)"
  fi
done

# AC2 live: --demo-only on S158 passes
echo "  running verify-closeout.sh --demo-only 158..."
CLOSEOUT_DEMO=$(bash scripts/verify-closeout.sh --demo-only 158 2>&1) && CDX=0 || CDX=$?
if echo "$CLOSEOUT_DEMO" | grep -q "DEMO: PASS"; then
  ok "closeout-demo-only-158-pass"
else
  bad "closeout-demo-only-158-pass"
  echo "$CLOSEOUT_DEMO" | tail -5
fi

echo ""
echo "Score: $((PASS+FAIL)) checks — $FAIL FAILED"
[ "$FAIL" -eq 0 ]
