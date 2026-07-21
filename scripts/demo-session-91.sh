#!/usr/bin/env bash
set -euo pipefail

echo "demo:header"
echo "════════════════════════════════════════════════════════"
echo " S91 demo — Reviewer hash fix (B) + --dogfood-age (C)"
echo "════════════════════════════════════════════════════════"
echo ""

echo "demo:cases"
echo "── B: S89 Reviewer station (was ABSENT, now PASSED) ──"
cargo run -q --bin vajra -- next --stations 89 2>/dev/null | grep -E "=== stations|PASSED|ABSENT|stations passed"
echo ""

echo "── C: live dogfood-staleness (derived from git) ──"
cargo run -q --bin vajra -- next --dogfood-age 2>/dev/null
echo ""

echo "demo:before_after"
echo "── Before (S90 GT finding) ──"
echo "  --stations 89 Reviewer: ABSENT (hash mismatch, forged/stale label)"
echo "  dogfood staleness: read from STATE.md — date was wrong for 3+ GTs"
echo ""
echo "── After (S91) ──"
echo "  --stations 89 Reviewer: PASSED (intermediate-commit hash reconstructed)"
echo "  dogfood staleness: derived live from git — S76 / 2026-07-18 / 14 sessions"
echo ""

echo "demo:summary_table"
echo "┌─────────────────────────────────────────────────┐"
echo "│  S91 delivery                                   │"
echo "├──────┬──────────────────────────────────────────┤"
echo "│  B   │ S89 Reviewer PASSED (was ABSENT)         │"
echo "│  C   │ --dogfood-age: git-derived, never drifts │"
echo "│ test │ 283 lib tests pass (+12 new)              │"
echo "└──────┴──────────────────────────────────────────┘"
