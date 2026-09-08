#!/usr/bin/env bash
# Demo: Session 153 — 4 carry-forward items
set -euo pipefail

echo "=== S153 Demo: carry-forward items ==="
echo ""

echo "--- 1. Handoff condensation transparency (AGENTS.md) ---"
grep -A3 "Handoff Condensation Transparency" .ai/AGENTS.md | head -6
echo ""

echo "--- 2. Hollow-advice retirement standard (AGENTS.md) ---"
grep -A3 "Hollow-Advice Retirement Standard" .ai/AGENTS.md | head -6
echo ""

echo "--- 3. DOCUMENT-session verify script standard (AGENTS.md) ---"
grep -A3 "DOCUMENT-Session Verify Script Standard" .ai/AGENTS.md | head -6
echo ""

echo "--- 4. FAIL_PASSTHROUGH_CAP guardrail test (cargo) ---"
cargo test --lib cargo_build_fail_passthrough_cap_governs_threshold --quiet 2>&1
echo ""

echo "=== Demo complete ==="
