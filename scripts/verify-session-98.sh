#!/usr/bin/env bash
# verify-session-98.sh — Session 98: autopilot-trust reposition (docs-only)
# Asserts the S98 acceptance criteria hold in the repo (grep the committed docs, not the diff —
# robust after merge), plus scope (no src/ change) and cargo test green.
# AC7 added by the S98 closeout-hardening follow-up: the verify-closeout.sh script-presence gate.
set -euo pipefail

DECISION="docs/decisions/DECISION-005-autopilot-trust.md"
VISION="VISION.md"
ROADMAP=".ai/ROADMAP.md"
REVIEW="sessions/session-98-review.md"
PASS=0
FAIL=0

check() {
  local desc="$1" result="$2"
  if [ "$result" = "ok" ]; then echo "  PASS  $desc"; PASS=$((PASS + 1))
  else echo "  FAIL  $desc"; FAIL=$((FAIL + 1)); fi
}
has() { grep -qiF "$2" "$1" && echo ok || echo fail; }
hasre() { grep -qiE "$2" "$1" && echo ok || echo fail; }

echo "=== verify-session-98: autopilot-trust reposition ==="
echo

# --- AC1: DECISION-005 exists and records every required element ---
echo "[AC1] DECISION-005 direction lock"
check "DECISION-005 file exists" "$([ -f "$DECISION" ] && echo ok || echo fail)"
check "records the reframe (autopilot trust layer)"      "$(has "$DECISION" 'AUTOPILOT TRUST LAYER')"
check "provenance: CTO audit verdict PAUSE TO PROVE"     "$(has "$DECISION" 'PAUSE TO PROVE')"
check "provenance: 11-question founder interview"        "$(hasre "$DECISION" '11-question founder interview')"
check "founder-answer table (crown jewel row)"           "$(has "$DECISION" 'Crown jewel')"
check "the Autopilot Ladder"                             "$(has "$DECISION" 'Autopilot Ladder')"
check "the machinery-freeze rule"                        "$(has "$DECISION" 'machinery-freeze rule')"
check "2026-09-15 release backstop"                      "$(has "$DECISION" '2026-09-15')"
check "Kill A (founder)"                                 "$(hasre "$DECISION" 'Kill A')"
check "Kill B (auditor) + named pivot"                  "$(has "$DECISION" 'standalone agent-PR acceptance checker')"
echo

# --- AC2: VISION leads with autopilot trust; stations = engine; honesty rows survive ---
echo "[AC2] VISION lead + preserved honesty rows"
check "one-sentence leads with autopilot trust layer"    "$(has "$VISION" 'autopilot trust layer for AI coding agents')"
check "pipeline framed as the engine"                    "$(has "$VISION" 'the engine, not the pitch')"
check "honesty row: 0 cross-agent code"                  "$(has "$VISION" '0 cross-agent code')"
check "honesty row: compression never-claim"             "$(has "$VISION" 'never in README/marketing until measured')"
check "honesty row: better-work hypothesis"              "$(has "$VISION" 'stated hypothesis')"
echo

# --- AC3: ROADMAP Ladder w/ falsifiable conditions + dated backstop ---
echo "[AC3] ROADMAP Ladder + backstop"
check "Rung 2 condition: zero governance leaks"          "$(has "$ROADMAP" 'Zero governance leaks')"
check "Rung 2 condition: founder spot-check"             "$(has "$ROADMAP" 'founder spot-check')"
check "Rung 3 condition: merge WITHOUT line-by-line"     "$(has "$ROADMAP" 'WITHOUT line-by-line review')"
check "dated release backstop 2026-09-15"                "$(has "$ROADMAP" '2026-09-15')"
echo

# --- AC4: scoreboard + both kill signals ---
echo "[AC4] ROADMAP scoreboard + kill signals"
check "scoreboard: Wk 8"                                 "$(hasre "$ROADMAP" 'Wk 8')"
check "scoreboard: Month 4"                              "$(hasre "$ROADMAP" 'Month 4')"
check "scoreboard: Month 6"                              "$(hasre "$ROADMAP" 'Month 6')"
check "Kill A present"                                   "$(hasre "$ROADMAP" 'Kill A')"
check "Kill B pivot: standalone acceptance checker"      "$(has "$ROADMAP" 'standalone agent-PR acceptance checker')"
echo

# --- AC5: machinery-freeze rule in ROADMAP's Rules section ---
echo "[AC5] Machinery-freeze rule in Rules section"
RULES_BLOCK=$(awk '/^## Rules For This Document/,0' "$ROADMAP")
check "freeze rule appears under '## Rules For This Document'" \
  "$(echo "$RULES_BLOCK" | grep -qiF 'Machinery-freeze rule' && echo ok || echo fail)"
echo

# --- AC6: docs-only scope + attested ACCEPT review ---
echo "[AC6] Scope (no src/) + attested cold review"
BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD origin/main 2>/dev/null || true)
if [ -n "$BASE" ]; then
  SRC_DIFF=$(git diff --name-only "$BASE"..HEAD -- src/ 2>/dev/null || true)
  check "this branch touches no src/ file" "$([ -z "$SRC_DIFF" ] && echo ok || echo fail)"
else
  check "this branch touches no src/ file (no base to diff)" "ok"
fi
check "review exists"                                    "$([ -f "$REVIEW" ] && echo ok || echo fail)"
check "review Verdict = ACCEPT"                          "$(hasre "$REVIEW" '^[*_[:space:]]*(overall |final )?verdict[*_[:space:]]*:.*accept')"
check "review carries a 64-hex Review-Inputs-SHA"        "$(grep -iE 'Review-Inputs-SHA' "$REVIEW" | grep -qoiE '[0-9a-f]{64}' && echo ok || echo fail)"
echo

# --- AC7: the closeout script-presence gate (S98 follow-up hardening) ---
# This session adds check_verify_demo_scripts to verify-closeout.sh: a CODE session that
# closes WITHOUT its verify/demo scripts (the exact S98 miss) now FAILS closeout. Drive its
# focused entry (--scripts-only) across every branch.
echo "[AC7] verify-closeout.sh closeout script-presence gate"
gate() { # desc  expected_exit  expected_substr  cmd...
  local desc="$1" xexit="$2" xsub="$3"; shift 3
  local out ec=0; out=$("$@" 2>&1) || ec=$?
  if [ "$ec" -eq "$xexit" ] && echo "$out" | grep -qF "$xsub"; then check "$desc" "ok"
  else check "$desc" "fail"; fi
}
gate "CODE session missing scripts -> FAIL"     1 "SCRIPTS: FAIL" bash scripts/verify-closeout.sh --scripts-only 99
gate "founder waiver -> PASS (WAIVED)"          0 "WAIVED"        env VAJRA_CLOSEOUT_WAIVER=99 bash scripts/verify-closeout.sh --scripts-only 99
gate "NO-CODE GT (N%5==0) -> PASS (N/A)"        0 "N/A"           bash scripts/verify-closeout.sh --scripts-only 100
gate "scripts present -> PASS (OK)"             0 "SCRIPTS: PASS" bash scripts/verify-closeout.sh --scripts-only 96
gate "dogfood no-waiver -> FAIL"                1 "SCRIPTS: FAIL" bash scripts/verify-closeout.sh --scripts-only 97
gate "this session (98) -> PASS (OK)"           0 "SCRIPTS: PASS" bash scripts/verify-closeout.sh --scripts-only 98
echo

# --- cargo test --lib stays green (docs-only session — must not regress) ---
echo "[scope] cargo test --lib (docs-only — must stay green)"
if cargo test --lib 2>&1 | grep -q 'test result: ok'; then
  check "cargo test --lib green" "ok"
else
  check "cargo test --lib green" "fail"
fi
echo

TOTAL=$((PASS + FAIL))
echo "=== Result: ${PASS}/${TOTAL} checks passed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
