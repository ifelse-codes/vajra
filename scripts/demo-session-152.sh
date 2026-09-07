#!/usr/bin/env bash
# demo-session-152.sh — S152: obedience-skip + carry-forward rules
set -euo pipefail

AGENTS=".ai/AGENTS.md"
AUDIT="sessions/session-152-carryforward-audit.md"

echo "=== S152 Demo: Governance Rules + Carry-Forward Audit ==="
echo ""

echo "--- D1: Obedience Protocol rule (from AGENTS.md) ---"
grep -A12 "Obedience Protocol" "$AGENTS" | head -12
echo ""

echo "--- D2: Carry-Forward Rule (from AGENTS.md) ---"
grep -A8 "Carry-Forward Rule" "$AGENTS" | head -8
echo ""

echo "--- D3: S149 audit disposition summary ---"
grep "Disposition:" "$AUDIT"
echo ""

echo "--- D4: ROADMAP S153 entry ---"
grep -A5 "S153" ".ai/ROADMAP.md" | head -6
echo ""

echo "=== Demo complete ==="
