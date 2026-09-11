#!/usr/bin/env bash
# verify-session-166.sh — S166: fix Analyst + Coder station gaps
# Every check is behavioral: invokes real scripts/binaries against real fixtures.
# FALSIFIABILITY: each check names the specific failure it would catch.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

BIN="target/release/vajra"

# ---------------------------------------------------------------------------
# AC1: Analyst station PASSED for session 166
# FALSIFIABILITY: if ## Delta had no +/~/- markers, --stations would show ABSENT.
# ---------------------------------------------------------------------------
if [ ! -x "$BIN" ]; then
  bad "AC1: binary missing — run cargo build --release"
else
  out="$("$BIN" next --stations 166 2>&1)"
  if echo "$out" | grep -q "\[PASSED\] Analyst"; then
    ok "AC1: Analyst station PASSED for session 166"
  else
    bad "AC1: Analyst station not PASSED — got: $(echo "$out" | grep -i analyst)"
  fi
fi

# ---------------------------------------------------------------------------
# AC2: check_execution_shas BLOCKs a prose 'done:' entry (S166 gate fix)
# FALSIFIABILITY: before S166, done: (text) passed the old '<' grep.
# We create a temporary prompt with a parenthetical done: and verify it BLOCKs.
# ---------------------------------------------------------------------------
FIXTURE_DIR="$(mktemp -d)"
cleanup() { rm -rf "$FIXTURE_DIR"; }
trap cleanup EXIT

FAKE_PROMPTS="$FIXTURE_DIR/prompts"
mkdir -p "$FAKE_PROMPTS"

cat > "$FAKE_PROMPTS/99-task-prose-test.md" << 'PROMPT'
# Session 99 — prose-test: check prose done: is blocked
> Status: APPROVED
## Goal
Test that prose done: entries are caught.
## Deliverables
- a thing
## Acceptance
1. prose done: BLOCKs
## Guardrails
- one story
## Plan
1. do a thing
## Execution
- step 1 — done: (verify + scripts: see next commit)
## Delta
- `+` test addition
PROMPT

prose_out="$(CLAUDE_PROJECT_DIR="$FIXTURE_DIR" bash scripts/verify-closeout.sh --check-exec-shas 99 2>&1)" && true || true

if echo "$prose_out" | grep -q "BAD-SHA"; then
  ok "AC2a: prose done: produces BAD-SHA marker"
else
  bad "AC2a: prose done: did NOT produce BAD-SHA marker — old gap still present"
fi

if echo "$prose_out" | grep -q "EXEC-SHAS: FAIL"; then
  ok "AC2b: prose done: causes EXEC-SHAS: FAIL"
else
  bad "AC2b: prose done: did NOT cause EXEC-SHAS: FAIL"
fi

# ---------------------------------------------------------------------------
# AC3: check_execution_shas PASSes a real 7-char hex SHA
# FALSIFIABILITY: if the SHA regex was wrong, a real SHA would also BLOCK.
# ---------------------------------------------------------------------------
cat > "$FAKE_PROMPTS/98-task-sha-test.md" << 'PROMPT'
# Session 98 — sha-test: real SHA should pass
> Status: APPROVED
## Goal
Test that real SHAs pass.
## Deliverables
- a thing
## Acceptance
1. real SHA passes
## Guardrails
- one story
## Plan
1. do a thing
## Execution
- step 1 — done: cc4b742
## Delta
- `+` test
PROMPT

sha_out="$(CLAUDE_PROJECT_DIR="$FIXTURE_DIR" bash scripts/verify-closeout.sh --check-exec-shas 98 2>&1)" && true || true

if echo "$sha_out" | grep -q "EXEC-SHAS: PASS"; then
  ok "AC3: real 7-char SHA causes EXEC-SHAS: PASS"
else
  bad "AC3: real SHA did NOT pass — got: $sha_out"
fi

# ---------------------------------------------------------------------------
# AC4: session-164-summary.md exists with exactly 3 ranked A/B/C candidates
# FALSIFIABILITY: missing file or wrong count would fail the options gate.
# ---------------------------------------------------------------------------
if [ -f "sessions/session-164-summary.md" ]; then
  ok "AC4a: sessions/session-164-summary.md exists"
  abc=$(grep -cE '^\- \*\*[ABC] ' sessions/session-164-summary.md 2>/dev/null || true)
  if [ "$abc" -eq 3 ]; then
    ok "AC4b: session-164-summary.md has 3 A/B/C options"
  else
    bad "AC4b: session-164-summary.md options count unexpected (count=$abc)"
  fi
else
  bad "AC4a: sessions/session-164-summary.md missing"
fi

# ---------------------------------------------------------------------------
# AC5: S164 prompt prose step is now caught (not silently passed)
# FALSIFIABILITY: before S166, --check-exec-shas 164 would PASS; now it must FAIL.
# ---------------------------------------------------------------------------
s164_out="$(bash scripts/verify-closeout.sh --check-exec-shas 164 2>&1)" && true || true
if echo "$s164_out" | grep -q "EXEC-SHAS: FAIL"; then
  ok "AC5: S164 prose step 2 is now caught by the patched gate"
else
  bad "AC5: S164 prose step 2 still not caught — patch incomplete"
fi

# ---------------------------------------------------------------------------
# AC6 (non-regression): S163 real SHAs still pass
# FALSIFIABILITY: regression in SHA regex would block valid prior sessions.
# ---------------------------------------------------------------------------
s163_out="$(bash scripts/verify-closeout.sh --check-exec-shas 163 2>&1)" && true || true
if echo "$s163_out" | grep -q "EXEC-SHAS: PASS"; then
  ok "AC6: S163 real SHAs still pass (non-regression)"
else
  bad "AC6: S163 real SHAs now blocked — regression in SHA check"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== verify-session-166.sh ==="
echo "PASS: $PASS  FAIL: $FAIL"
[ "$FAIL" -eq 0 ] && echo "ALL PASS — exit 0" && exit 0
echo "FAILURES — exit 1" && exit 1
