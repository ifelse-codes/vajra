#!/usr/bin/env bash
# fleet-smoke.sh — S109 (DECISION-007): a FALSIFIABLE smoke for the named-role fleet, subagent model.
# No paid call, no live agent — it proves Vajra's TWO governance jobs with plain files:
#   1. `vajra init` SCAFFOLDS the role as a native Claude Code subagent (`.claude/agents/<name>.md`)
#      rendered from the ONE canonical source (fleet::ROLES).
#   2. `vajra next --role <name> --from <findings>` GOVERNS a subagent's findings into a delta-tracked,
#      validated handoff in the `.ai/` spine.
# Fail-closed cases (a skipped-or-green here is a REJECT): unknown role · missing --from · missing
# findings file · empty findings — each MUST exit non-zero and leave no bogus handoff.
#
# Exit 0 iff every assertion holds; non-zero (with `SMOKE FAIL: ...`) on the first breach.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

SESSION="${VAJRA_SMOKE_SESSION:-109}"
fail() { echo "SMOKE FAIL: $*" >&2; exit 1; }

BIN="${VAJRA_BIN:-}"
if [ -z "$BIN" ]; then
  ( cd "$ROOT" && cargo build -q ) || fail "cargo build failed"
  BIN="$ROOT/target/debug/vajra"
fi
[ -x "$BIN" ] || fail "vajra binary not executable at $BIN"

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
REPO="$WORK/repo"; mkdir -p "$REPO"
( cd "$REPO"
  git init -q -b main; git config user.email t@t; git config user.name t
  # `vajra init` scaffolds .ai/ + .claude/agents/. Feed the prompts non-interactively.
  printf 'smoke\nfirst session\nL2\n' | "$BIN" init >/dev/null 2>&1 || true
  git add -A && git commit -q --no-verify -m init
  git checkout -qb "session-${SESSION}-smoke"
) || fail "could not scaffold throwaway repo"

AGENT_DEF="$REPO/.claude/agents/researcher.md"
HANDOFF="$REPO/.ai/handoffs/session-${SESSION}-researcher.md"
PASS=0
ok() { echo "  ok: $1"; PASS=$((PASS+1)); }

# ── CASE 1 · `vajra init` scaffolded the role as a native Claude Code subagent ─────────────────────
[ -f "$AGENT_DEF" ] || fail "case1: vajra init did not scaffold $AGENT_DEF"
grep -q "^name: researcher" "$AGENT_DEF" || fail "case1: subagent def missing 'name: researcher'"
grep -q "^description:" "$AGENT_DEF" || fail "case1: subagent def missing a description"
grep -q "You are the Researcher" "$AGENT_DEF" || fail "case1: subagent def missing the canonical role prompt"
grep -q "vajra next --role researcher --from" "$AGENT_DEF" || fail "case1: subagent def does not point at the governed handoff"
ok "vajra init scaffolds .claude/agents/researcher.md (canonical prompt + handoff pointer)"

# ── CASE 2 · govern a subagent's findings → a well-formed, delta-tracked handoff ────────────────────
printf 'Findings: prefer approach A; it is O(n) vs O(n^2).\n' > "$WORK/findings.txt"
( cd "$REPO" && "$BIN" next --role researcher --from "$WORK/findings.txt" ) >/dev/null 2>&1 \
  || fail "case2: governing a findings file exited non-zero"
[ -f "$HANDOFF" ] || fail "case2: no handoff written at $HANDOFF"
for key in "role: researcher" "session: ${SESSION}" "agent:" "source-sha:" "captured:" "cost_usd:"; do
  grep -q "^${key}" "$HANDOFF" || fail "case2: handoff missing frontmatter '${key}'"
done
grep -q "## Handoff Delta" "$HANDOFF" || fail "case2: handoff missing '## Handoff Delta' section"
grep -q "prefer approach A" "$HANDOFF" || fail "case2: findings body not captured into handoff"
grep -Eq "^source-sha: [0-9a-f]{64}$" "$HANDOFF" || fail "case2: source-sha is not a 64-hex digest"
grep -q "\`+\` new" "$HANDOFF" || fail "case2: first handoff must record a '+ new' delta"
ok "govern findings -> governed handoff (frontmatter + body + delta), source-sha is 64-hex"

# ── CASE 3 · re-run → delta flips to '~ re-run' (DELTA-tracked, not overwritten blind) ──────────────
( cd "$REPO" && "$BIN" next --role researcher --from "$WORK/findings.txt" ) >/dev/null 2>&1 \
  || fail "case3: re-run exited non-zero"
grep -q "\`~\` re-run" "$HANDOFF" || fail "case3: a re-run must record a '~ re-run' delta"
ok "re-run -> '~ re-run' delta recorded"

# ── CASE 4 (FAIL-CLOSED) · unknown role → non-zero ─────────────────────────────────────────────────
if ( cd "$REPO" && "$BIN" next --role nope-not-a-role --from "$WORK/findings.txt" ) >/dev/null 2>&1; then
  fail "case4: an UNKNOWN role returned 0 — not fail-closed"
fi
ok "unknown role -> exit non-zero"

# ── CASE 5 (FAIL-CLOSED) · missing --from → non-zero ───────────────────────────────────────────────
if ( cd "$REPO" && "$BIN" next --role researcher ) >/dev/null 2>&1; then
  fail "case5: a dispatch with NO --from returned 0 — not fail-closed"
fi
ok "missing --from -> exit non-zero"

# ── CASE 6 (FAIL-CLOSED) · missing findings file → non-zero ────────────────────────────────────────
if ( cd "$REPO" && "$BIN" next --role researcher --from "$WORK/does-not-exist.txt" ) >/dev/null 2>&1; then
  fail "case6: a MISSING findings file returned 0 — not fail-closed"
fi
ok "missing findings file -> exit non-zero"

# ── CASE 7 (FAIL-CLOSED) · empty findings → non-zero AND no bogus handoff in a fresh repo ──────────
BADREPO="$WORK/badrepo"; mkdir -p "$BADREPO"
( cd "$BADREPO"
  git init -q -b main; git config user.email t@t; git config user.name t
  printf 'smoke\nfirst\nL2\n' | "$BIN" init >/dev/null 2>&1 || true
  git add -A; git commit -q --no-verify -m init; git checkout -qb "session-${SESSION}-bad" ) || fail "case7: scaffold failed"
printf '   \n' > "$WORK/empty.txt"
if ( cd "$BADREPO" && "$BIN" next --role researcher --from "$WORK/empty.txt" ) >/dev/null 2>&1; then
  fail "case7: EMPTY findings returned 0 — not fail-closed"
fi
[ -f "$BADREPO/.ai/handoffs/session-${SESSION}-researcher.md" ] \
  && fail "case7: a handoff was written despite empty findings"
ok "empty findings -> exit non-zero, no handoff written"

echo "SMOKE PASS: fleet named-role subagent governance — ${PASS}/7 checks (scaffold + 2 governed + 4 fail-closed)"
