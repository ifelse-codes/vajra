#!/usr/bin/env bash
# Session 63 — PAID DOGFOOD demo: show the governed loop measured as experience.
# Cumulative: prior sessions' capabilities still hold; this demo surfaces the S63 measurement.
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

bar() { printf '%s\n' "──────────────────────────────────────────────────────────────"; }

bar
echo " Vajra S63 · PAID DOGFOOD — is the governed loop good to USE?"
bar
echo " subject repo   chitra  (task: add missing CI workflows — 1 story)"
echo " model          fable-5 (account default headless) · 17 turns · 2m55s"
echo ""
echo " COST"
echo "   authoritative total_cost_usd ....... \$1.2662   <- the only number that counts"
echo "   vajra receipt (stderr) ............. \$5.9665   <- overstates 4.71x (was assumed ~8x)"
echo ""
echo " DELIVERABLE (independently re-verified — trusted nothing)"
echo "   chitra .github/workflows/ci.yml + verify + demo ... present, UNCOMMITTED"
echo "   chitra verify-session-07.sh ....................... ALL GREEN 12/12"
echo "   core tests ........................................ 116/116 pass"
echo "   commits on branch beyond main ..................... 0  (no approval token)"
echo ""
echo " GOVERNANCE FIRED"
echo "   Darshan boot ACK ......... fired    (neutral: headless has no human)"
echo "   Varta co-pilot loader .... fired    (helped: surfaced .ai/ context)"
echo "   session-guard (no-main) .. 0 blocks (dormant: agent branched correctly)"
echo "   no-autonomous-commit ..... HELD     (helped: agent stopped at the gate)"
echo "   vajra compression hook ... 0 folds  (no-op: known real-CC weakness)"
echo "   obedience ................ 100.0% (16/16 clean) — a floor, not 'better work'"
echo ""
echo " VERDICT"
echo "   net POSITIVE-to-NEUTRAL: guided + safe + in-scope; nothing hindered."
echo "   honest null on compression (0 folds) and on 'better work' (voluntary, not caught)."
echo "   dogfood_check -> GREEN (refreshed; first paid run since S52)."
bar
echo " Full evidence: sessions/session-63-dogfood.md + sessions/session-63-artifacts/"
bar
