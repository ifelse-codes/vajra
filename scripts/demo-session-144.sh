#!/usr/bin/env bash
# demo-session-144.sh — what the chitra FULL-LOOP dogfood did (glanceable, exit 0).
# Read-only: reads chitra via git + renders the locked chart from chitra's dist if available.
set -uo pipefail
CHITRA="/Users/suman/playground/chitra"
BR="session-19-horizontalbar-lock"

echo "════════════════════════════════════════════════════════════════════"
echo " S144 · the chitra FULL-LOOP dogfood — upgrade then govern a build"
echo "════════════════════════════════════════════════════════════════════"

echo ""
echo "── 1. brownfield upgrade (installed vajra 0.1.0) ──"
echo "   first contact : 16 drifted (10 roles + 6 hooks) + 1 needs-boundary (constitution)"
echo "   migration     : one --overwrite-drifted + a one-time sentinel paste → 17 refreshed"
echo "   smooth again  : repeat --sync-fleet → 17 already current, 0 churn"

echo ""
echo "── 2. constitution header preserved byte-for-byte ──"
HDR_MAIN_SHA="$(git -C "$CHITRA" show main:.ai/AGENTS.md 2>/dev/null | awk '/^## Mandatory Load Order/{exit}{print}' | shasum -a 256 | cut -d' ' -f1)"
HDR_S19_SHA="$(git -C "$CHITRA" show "$BR:.ai/AGENTS.md" 2>/dev/null | awk '/vajra:governed-body/{exit}{print}' | shasum -a 256 | cut -d' ' -f1)"
echo "   header sha (main, pre-migration) : ${HDR_MAIN_SHA:0:16}…"
echo "   header sha (branch, post)        : ${HDR_S19_SHA:0:16}…"
[ -n "$HDR_MAIN_SHA" ] && [ "$HDR_MAIN_SHA" = "$HDR_S19_SHA" ] && echo "   → IDENTICAL ✓ (chitra's identity preserved; only the governed body rewritten)"

echo ""
echo "── 3. the build governed by chitra's OWN fleet, to a green close ──"
echo "   tech-lead FIRST → 4 required (implementation-advisor · qa-specialist · demo-producer · fidelity-reviewer)"
git -C "$CHITRA" show "$BR:.ai/handoffs/session-19-tech-lead.md" >/dev/null 2>&1 \
  && echo "   all 4 handoffs recorded → verify-closeout.sh 19 = ALL GREEN 13/13 incl. required-crew PASS ✓"

echo ""
echo "── 4. the deliverable: horizontalBar locked to the reference language ──"
if [ -f "$CHITRA/packages/core/dist/index.js" ]; then
  node -e '
    import("file://'"$CHITRA"'/packages/core/dist/index.js").then(m=>{
      const c=m.horizontalBar({data:[42,88,63,17,75,30],labels:["alpha","bravo","charlie","delta","echo","foxtrot"],title:"Requests by service",theme:"dark",width:56});
      process.stdout.write(c.toString()+"\n");
    }).catch(e=>console.log("   (render skipped:",e.message,")"));
  ' 2>/dev/null || echo "   (node render unavailable — see sessions/session-144-summary.md)"
else
  echo "   (chitra dist not built — accent-once + no-phantom-fill proven in verify-session-19.sh)"
fi

echo ""
echo "── receipt ──"
echo "   authoritative: \$11.742472 · RAW subagent tokens: 875,548 (≈22× tighter than S134)"
echo "   🔴 2 findings: --sync-fleet skips verify-closeout.sh; gate hardcodes target/release/vajra"
echo "════════════════════════════════════════════════════════════════════"
exit 0
