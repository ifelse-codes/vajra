#!/usr/bin/env bash
# verify-session-99.sh — Session 99: Coder reachable unattended.
#
# Drives the REAL binary and the REAL boot hook in a throwaway repo — this session's claims are
# about observable behaviour (what `vajra init` writes, what `--stations` prints, what the launch
# environment makes the packet say), so grepping source would be hollow-green (S69).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

check() {
  local desc="$1" result="$2"
  if [ "$result" = "ok" ]; then echo "  PASS  $desc"; PASS=$((PASS + 1))
  else echo "  FAIL  $desc"; FAIL=$((FAIL + 1)); fi
}
# Every predicate ends in an `echo`, so a false result never trips `set -e`.
has()  { grep -qF "$2" "$1" && echo ok || echo fail; }
lacks() { grep -qF "$2" "$1" && echo fail || echo ok; }
sin()  { echo "$1" | grep -qF "$2" && echo ok || echo fail; }
snot() { echo "$1" | grep -qF "$2" && echo fail || echo ok; }
sre()  { echo "$1" | grep -qE "$2" && echo ok || echo fail; }

echo "=== verify-session-99: Coder reachable unattended ==="
echo

cd "$ROOT"
cargo build -q 2>/dev/null
VAJRA="$ROOT/target/debug/vajra"
check "vajra binary built" "$([ -x "$VAJRA" ] && echo ok || echo fail)"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
GOAL="ship the first slice"

# --- AC1: the scaffolded kickoff carries the station markers -----------------------------------
echo
echo "[AC1] vajra init emits a station-measurable kickoff prompt"
(
  cd "$TMP"
  git init -q -b main .
  printf 'demo-proj\n%s\nL2\n' "$GOAL" | "$VAJRA" init >/dev/null 2>&1
)
KICK="$TMP/prompts/01-task-kickoff.md"
check "prompts/01-task-kickoff.md written" "$([ -f "$KICK" ] && echo ok || echo fail)"
for h in '## Acceptance' '## Design' '## Plan' '## Execution' '## Delta'; do
  check "kickoff carries $h" "$(has "$KICK" "$h")"
done
check "founder's goal substituted into the kickoff"   "$(has "$KICK" "$GOAL")"
check "kickoff ships DRAFT (human approves first)"    "$(has "$KICK" 'Status:** DRAFT')"
check "no unsubstituted template token"               "$(lacks "$KICK" '{{NN}}')"

# --- AC2: LEGACY vs ABSENT ---------------------------------------------------------------------
echo
echo "[AC2] --stations tells convention-absent from work-absent"

# (a) A pre-marker-convention prompt — the shape chitra's prompts/00-03 still carry (S97).
cat > "$TMP/prompts/07-task-legacy.md" <<'LEGACYPROMPT'
# Session 07 — release workflow

## Goal
Ship the release workflow.

## Context
This repo was scaffolded by an older vajra.

## Deliverables
- a workflow file

## Exit Criteria
- CI green

## Guardrails
- one story
LEGACYPROMPT
OUT_LEGACY=$(cd "$TMP" && "$VAJRA" next --stations 07 2>&1)
LEGACY_LINES=$(echo "$OUT_LEGACY" | grep -c '\[LEGACY\]' || true)
check "all 4 prompt-driven stations report LEGACY (got $LEGACY_LINES)" \
  "$([ "$LEGACY_LINES" -eq 4 ] && echo ok || echo fail)"
check "report discloses UNMEASURABLE"        "$(sin "$OUT_LEGACY" 'UNMEASURABLE')"
check "report states the remedy"             "$(sin "$OUT_LEGACY" 'vajra next --advance')"
check "LEGACY never earns a passed station"  "$(sre "$OUT_LEGACY" '^  0 of 8')"

# (b) The modern-but-unfilled kickoff from AC1 must stay ABSENT — the convention IS there.
OUT_MODERN=$(cd "$TMP" && "$VAJRA" next --stations 01 2>&1)
check "modern (unfilled) prompt is NOT mis-read as legacy" "$(snot "$OUT_MODERN" '[LEGACY]')"
check "modern unfilled prompt still reports ABSENT"        "$(sin "$OUT_MODERN" '[ABSENT]')"

# (c) A missing prompt stays ABSENT — "no prompt" is already unambiguous.
OUT_NONE=$(cd "$TMP" && "$VAJRA" next --stations 42 2>&1)
check "missing prompt is ABSENT, not LEGACY"               "$(snot "$OUT_NONE" '[LEGACY]')"

# --- AC3: commit pre-authorization on BOTH agent-facing surfaces --------------------------------
echo
echo "[AC3] commit pre-authorization is surfaced, and mirrors the guard"
BRANCH=$(git -C "$ROOT" branch --show-current 2>/dev/null || echo "")
SESS=$(echo "$BRANCH" | grep -oE '^session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
if [ -z "$SESS" ]; then
  check "AC3 evaluable (must run on a session-NN-* branch)" "fail"
else
  OTHER=$((10#$SESS - 1))

  # `vajra next` — the handoff packet.
  P_NONE=$(cd "$ROOT" && env -u VAJRA_ALLOW_COMMIT "$VAJRA" next 2>/dev/null | head -12 || true)
  check "packet: no marker -> REQUIRED"        "$(sin "$P_NONE" 'commit approval: REQUIRED')"
  check "packet: names the unattended route"   "$(sin "$P_NONE" 'VAJRA_ALLOW_COMMIT=NN vajra claude')"

  P_OK=$(cd "$ROOT" && VAJRA_ALLOW_COMMIT="$SESS" "$VAJRA" next 2>/dev/null | head -12 || true)
  check "packet: matching marker -> PRE-GRANTED" "$(sin "$P_OK" 'commit approval: PRE-GRANTED')"
  check "packet: discloses it is advisory"       "$(sin "$P_OK" 'Advisory')"

  P_BAD=$(cd "$ROOT" && VAJRA_ALLOW_COMMIT="$OTHER" "$VAJRA" next 2>/dev/null | head -12 || true)
  check "packet: wrong-session marker -> NOT VALID HERE" "$(sin "$P_BAD" 'NOT VALID HERE')"

  # The SessionStart boot packet — the surface a headless run always reads.
  H_NONE=$(cd "$ROOT" && env -u VAJRA_ALLOW_COMMIT bash scripts/hook-session-start.sh 2>/dev/null | tail -5 || true)
  check "boot hook: no marker -> REQUIRED"          "$(sin "$H_NONE" '[commit approval] REQUIRED')"
  H_OK=$(cd "$ROOT" && VAJRA_ALLOW_COMMIT="$SESS" bash scripts/hook-session-start.sh 2>/dev/null | tail -5 || true)
  check "boot hook: matching marker -> PRE-GRANTED" "$(sin "$H_OK" '[commit approval] PRE-GRANTED')"
  H_BAD=$(cd "$ROOT" && VAJRA_ALLOW_COMMIT="$OTHER" bash scripts/hook-session-start.sh 2>/dev/null | tail -5 || true)
  check "boot hook: wrong-session -> NOT VALID HERE" "$(sin "$H_BAD" '[commit approval] NOT VALID HERE')"

  # The two surfaces must classify the SAME launch env into the same category — a real cross-
  # surface comparison (not two booleans already asserted equal). Extract the category word from
  # each surface and diff them, for all three env conditions.
  cat_of() { # stdin -> REQUIRED | PRE-GRANTED | NOTVALID | UNKNOWN
    if   echo "$1" | grep -q 'PRE-GRANTED'; then echo PRE-GRANTED
    elif echo "$1" | grep -q 'NOT VALID';  then echo NOTVALID
    elif echo "$1" | grep -q 'REQUIRED';   then echo REQUIRED
    else echo UNKNOWN; fi
  }
  for pair in "NONE:$P_NONE|$H_NONE" "OK:$P_OK|$H_OK" "BAD:$P_BAD|$H_BAD"; do
    tag=${pair%%:*}; rest=${pair#*:}; pcat=$(cat_of "${rest%%|*}"); hcat=$(cat_of "${rest##*|}")
    check "surfaces agree for env $tag ($pcat)" \
      "$([ "$pcat" = "$hcat" ] && [ "$pcat" != UNKNOWN ] && echo ok || echo fail)"
  done

  # REAL parity with the enforcing guard (not asserted from memory): drive hook-commit-guard.sh
  # with a git-commit PreToolUse payload under each env, forcing enforcement (VAJRA_ENFORCE_COMMIT=1
  # past this repo's `commit_guard: off`). The guard's decision — allow(0) / block(2) — must match
  # what the packet told the agent. This is the check the S99 review demanded.
  GUARD="$ROOT/scripts/hook-commit-guard.sh"
  PAYLOAD='{"tool_input":{"command":"git commit -m x"}}'
  guard_exit() { # $@ = extra env spec placed FIRST (so `-u NAME` options precede assignments)
    local ec=0
    echo "$PAYLOAD" | env "$@" CLAUDE_PROJECT_DIR="$ROOT" VAJRA_ENFORCE_COMMIT=1 bash "$GUARD" >/dev/null 2>&1 || ec=$?
    echo "$ec"
  }
  E_OK=$(guard_exit "VAJRA_ALLOW_COMMIT=$SESS")
  E_BAD=$(guard_exit "VAJRA_ALLOW_COMMIT=$OTHER")
  E_NONE=$(guard_exit -u VAJRA_ALLOW_COMMIT)
  check "guard ALLOWs (0) when packet says PRE-GRANTED"       "$([ "$E_OK" = "0" ] && echo ok || echo fail)"
  check "guard BLOCKs (2) when packet says NOT VALID HERE"    "$([ "$E_BAD" = "2" ] && echo ok || echo fail)"
  check "guard BLOCKs (2) when packet says REQUIRED"          "$([ "$E_NONE" = "2" ] && echo ok || echo fail)"
fi

# --- Regression: the suite stays green ----------------------------------------------------------
echo
echo "[scope] cargo test --lib"
if cargo test --lib 2>&1 | grep -q 'test result: ok'; then check "cargo test --lib green" "ok"
else check "cargo test --lib green" "fail"; fi

echo
TOTAL=$((PASS + FAIL))
echo "=== Result: ${PASS}/${TOTAL} checks passed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
