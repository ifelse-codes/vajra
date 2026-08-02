#!/usr/bin/env bash
# fleet-smoke.sh — S109 (DECISION-007): a FALSIFIABLE smoke for named-role dispatch, proven with a
# STUB agent (VAJRA_AGENT_CMD), so CI and the close-gate NEVER depend on a paid call.
#
# It stands up a throwaway governed repo on a `session-NN` branch, injects a fake agent that emits a
# canned `type:"result"` JSON, and asserts the full contract:
#   PASS cases  — known role dispatches -> a governed handoff exists, is well-formed (all frontmatter
#                 keys + a non-empty body + the ## Handoff Delta section), and records the delta.
#   FAIL-CLOSED — unknown role · missing agent command · missing task · malformed agent output all
#                 exit NON-ZERO and never leave a bogus handoff behind.
# A skipped-or-green fail-closed case is a REJECT: every negative case MUST exit non-zero.
#
# Exit 0 iff every assertion holds; non-zero (with `SMOKE FAIL: ...`) on the first breach.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

SESSION="${VAJRA_SMOKE_SESSION:-109}"
fail() { echo "SMOKE FAIL: $*" >&2; exit 1; }

# --- resolve the binary (build the debug binary if not supplied) ------------------------------------
BIN="${VAJRA_BIN:-}"
if [ -z "$BIN" ]; then
  ( cd "$ROOT" && cargo build -q ) || fail "cargo build failed"
  BIN="$ROOT/target/debug/vajra"
fi
[ -x "$BIN" ] || fail "vajra binary not executable at $BIN"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# --- the stub agents (no paid call — they just print canned JSON on stdout) --------------------------
STUB_OK="$WORK/stub-ok.sh"
cat > "$STUB_OK" <<'EOF'
#!/bin/sh
printf '%s\n' '{"type":"result","result":"Findings: prefer approach A; it is O(n) vs O(n^2).","total_cost_usd":0.0037}'
EOF
chmod +x "$STUB_OK"

STUB_BAD="$WORK/stub-bad.sh"     # emits no result object -> unparseable
cat > "$STUB_BAD" <<'EOF'
#!/bin/sh
echo "noise, not a result stream"
EOF
chmod +x "$STUB_BAD"

STUB_EMPTY="$WORK/stub-empty.sh" # emits a result object with an empty body
cat > "$STUB_EMPTY" <<'EOF'
#!/bin/sh
printf '%s\n' '{"type":"result","result":"   ","total_cost_usd":0.001}'
EOF
chmod +x "$STUB_EMPTY"

# --- a throwaway governed repo on a session branch --------------------------------------------------
REPO="$WORK/repo"
mkdir -p "$REPO/.ai"
( cd "$REPO"
  git init -q -b main
  git config user.email t@t; git config user.name t
  printf '%s\n' "$SESSION" > .ai/SESSION
  echo "seed" > seed.txt
  git add -A && git commit -qm init
  git checkout -qb "session-${SESSION}-smoke"
) || fail "could not scaffold throwaway repo"

HANDOFF="$REPO/.ai/handoffs/session-${SESSION}-researcher.md"
PASS=0
ok() { echo "  ok: $1"; PASS=$((PASS+1)); }

# ── CASE 1 · known role + stub agent → governed, well-formed, delta-tracked handoff ────────────────
( cd "$REPO" && VAJRA_AGENT_CMD="$STUB_OK" "$BIN" claude --role researcher -p "which approach is faster?" ) \
  >/dev/null 2>&1 || fail "case1: dispatch with a known role + stub agent exited non-zero"
[ -f "$HANDOFF" ] || fail "case1: no handoff written at $HANDOFF"
for key in "role: researcher" "session: ${SESSION}" "agent:" "source-sha:" "captured:" "cost_usd:"; do
  grep -q "^${key}" "$HANDOFF" || fail "case1: handoff missing frontmatter '${key}'"
done
grep -q "## Handoff Delta" "$HANDOFF" || fail "case1: handoff missing '## Handoff Delta' section"
grep -q "Findings: prefer approach A" "$HANDOFF" || fail "case1: agent body not captured into handoff"
# source-sha must be a real 64-hex digest, not the 'unavailable' fallback.
grep -Eq "^source-sha: [0-9a-f]{64}$" "$HANDOFF" || fail "case1: source-sha is not a 64-hex digest"
grep -q "\`+\` new" "$HANDOFF" || fail "case1: first handoff must record a '+ new' delta"
ok "known role -> governed handoff (frontmatter + body + delta), source-sha is 64-hex"

# ── CASE 2 · re-run → delta flips to '~ re-run' (the artifact is DELTA-tracked, not overwritten blind)
( cd "$REPO" && VAJRA_AGENT_CMD="$STUB_OK" "$BIN" claude --role researcher -p "again" ) >/dev/null 2>&1 \
  || fail "case2: re-run dispatch exited non-zero"
grep -q "\`~\` re-run" "$HANDOFF" || fail "case2: a re-run must record a '~ re-run' delta"
ok "re-run -> '~ re-run' delta recorded"

# ── CASE 3 (FAIL-CLOSED) · unknown role → non-zero ─────────────────────────────────────────────────
if ( cd "$REPO" && VAJRA_AGENT_CMD="$STUB_OK" "$BIN" claude --role nope-not-a-role -p "x" ) >/dev/null 2>&1; then
  fail "case3: an UNKNOWN role returned 0 — not fail-closed"
fi
ok "unknown role -> exit non-zero"

# ── CASE 4 (FAIL-CLOSED) · missing agent command → non-zero ────────────────────────────────────────
if ( cd "$REPO" && VAJRA_AGENT_CMD="/no/such/agent/binary" "$BIN" claude --role researcher -p "x" ) >/dev/null 2>&1; then
  fail "case4: a MISSING agent command returned 0 — not fail-closed"
fi
ok "missing agent command -> exit non-zero"

# ── CASE 5 (FAIL-CLOSED) · missing task (no -p) → non-zero ──────────────────────────────────────────
if ( cd "$REPO" && VAJRA_AGENT_CMD="$STUB_OK" "$BIN" claude --role researcher ) >/dev/null 2>&1; then
  fail "case5: a dispatch with NO task returned 0 — not fail-closed"
fi
ok "missing task -> exit non-zero"

# ── CASE 6 (FAIL-CLOSED) · malformed agent output → non-zero AND no bogus handoff written ───────────
BADREPO="$WORK/badrepo"; mkdir -p "$BADREPO/.ai"
( cd "$BADREPO"
  git init -q -b main; git config user.email t@t; git config user.name t
  printf '%s\n' "$SESSION" > .ai/SESSION; echo s > s.txt; git add -A; git commit -qm init
  git checkout -qb "session-${SESSION}-bad" ) || fail "case6: could not scaffold bad repo"
if ( cd "$BADREPO" && VAJRA_AGENT_CMD="$STUB_BAD" "$BIN" claude --role researcher -p "x" ) >/dev/null 2>&1; then
  fail "case6: MALFORMED agent output returned 0 — not fail-closed"
fi
[ -f "$BADREPO/.ai/handoffs/session-${SESSION}-researcher.md" ] \
  && fail "case6: a handoff was written despite unparseable agent output"
ok "malformed agent output -> exit non-zero, no handoff written"

# ── CASE 7 (FAIL-CLOSED) · empty-body result → non-zero ────────────────────────────────────────────
if ( cd "$BADREPO" && VAJRA_AGENT_CMD="$STUB_EMPTY" "$BIN" claude --role researcher -p "x" ) >/dev/null 2>&1; then
  fail "case7: an EMPTY-body result returned 0 — not fail-closed"
fi
ok "empty-body result -> exit non-zero"

echo "SMOKE PASS: fleet named-role dispatch — ${PASS}/7 checks (2 governed handoffs + 5 fail-closed)"
