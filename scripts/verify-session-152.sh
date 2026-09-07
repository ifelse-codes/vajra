#!/usr/bin/env bash
# verify-session-152.sh — S152: obedience-skip + carry-forward rules + S149 audit
set -euo pipefail

PASS=0; FAIL=0
ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

AGENTS=".ai/AGENTS.md"
ROADMAP=".ai/ROADMAP.md"
AUDIT="sessions/session-152-carryforward-audit.md"

# C1: AGENTS.md contains the obedience-skip rule section
if grep -q "Obedience Protocol" "$AGENTS"; then
  ok "C1: Obedience Protocol section present in AGENTS.md"
else
  bad "C1: MISSING — 'Obedience Protocol' section not found in AGENTS.md"
fi

# C2: AGENTS.md obedience rule requires what/why/when
if grep -q "deferred:" "$AGENTS" && grep -q "refused:" "$AGENTS"; then
  ok "C2: AGENTS.md references deferred: and refused: dispositions"
else
  bad "C2: AGENTS.md missing deferred:/refused: in obedience section"
fi

# C3: AGENTS.md contains the carry-forward rule section
if grep -q "Carry-Forward Rule" "$AGENTS"; then
  ok "C3: Carry-Forward Rule section present in AGENTS.md"
else
  bad "C3: MISSING — 'Carry-Forward Rule' section not found in AGENTS.md"
fi

# C4: Carry-forward rule bans unnamed targets (must mention 'NOT-BUILT' or equivalent)
if grep -A20 "Carry-Forward Rule" "$AGENTS" | grep -q "NOT-BUILT\|not acceptable\|hollow"; then
  ok "C4: Carry-forward rule names consequence (NOT-BUILT / hollow)"
else
  bad "C4: Carry-forward rule missing consequence for unnamed carry-forward"
fi

# C5: Audit doc exists and is non-empty
if [ -f "$AUDIT" ] && [ -s "$AUDIT" ]; then
  ok "C5: Audit document exists and is non-empty"
else
  bad "C5: MISSING — $AUDIT not found or empty"
fi

# C6: Audit doc contains all 8 items (look for items 1-8 headers or numbered list)
COUNT=$(grep -c "^## Item [1-8]" "$AUDIT" 2>/dev/null || echo 0)
if [ "$COUNT" -eq 8 ]; then
  ok "C6: Audit doc contains all 8 items (found $COUNT ## Item N sections)"
else
  bad "C6: Audit doc has $COUNT/8 'Item N' sections"
fi

# C7: No item left undisposed (every item must have Disposition: RETIRED or ASSIGNED)
DISPOSED=$(grep -c "Disposition:" "$AUDIT" 2>/dev/null || echo 0)
if [ "$DISPOSED" -eq 8 ]; then
  ok "C7: All 8 items have a Disposition: line ($DISPOSED found)"
else
  bad "C7: Only $DISPOSED/8 items have a Disposition: line"
fi

# C8: ROADMAP contains S153 entry for the assigned items
if grep -q "S153" "$ROADMAP"; then
  ok "C8: ROADMAP references S153 for assigned carry-forward items"
else
  bad "C8: ROADMAP missing S153 entry for assigned items"
fi

# C9: verify-closeout.sh check (structural — confirm it exists and is non-empty)
if [ -f "scripts/verify-closeout.sh" ] && [ -s "scripts/verify-closeout.sh" ]; then
  ok "C9: verify-closeout.sh present and non-empty"
else
  bad "C9: verify-closeout.sh missing or empty"
fi

echo ""
echo "=== S152 verify: $PASS PASS / $FAIL FAIL ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
