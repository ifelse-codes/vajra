#!/usr/bin/env bash
# verify-session-55.sh — S55 NO-CODE ground-truth: prove the fidelity auditor's BRAIN by re-auditing S54.
# Docs-only session (no src/ change). Verify checks the deliverables exist, the ground-truth covers all 8
# required_audits + the meta-check, the cold review is a real per-requirement fidelity pass with an
# honest REJECT, the reviewer skill (brain) is present, and exactly 3 ranked S56 candidates lead with the
# fidelity gate. Presence/consistency only — enforcement (teeth) is S56.
set -euo pipefail
cd "$(dirname "$0")/.."

PASS=0; FAIL=0
ok(){ echo "  ok   $1"; PASS=$((PASS+1)); }
no(){ echo "  FAIL $1"; FAIL=$((FAIL+1)); }
has(){ grep -qiE "$2" "$1" 2>/dev/null && ok "$3" || no "$3"; }

echo "=== S55 verify — fidelity auditor brain (NO-CODE ground-truth) ==="

# --- Deliverables exist ---
GT=sessions/session-55-ground-truth.md
RV=sessions/session-55-review.md
SK=reviewer/SKILL.md
[ -f "$GT" ] && ok "ground-truth present" || no "ground-truth present"
[ -f "$RV" ] && ok "cold review present"  || no "cold review present"
[ -f "$SK" ] && ok "reviewer/SKILL.md (brain) present" || no "reviewer/SKILL.md (brain) present"

# --- ground-truth: all 8 required_audits + meta-check + dogfood-of-self + 3 candidates ---
for A in vision_alignment roadmap_alignment state_drift knowledge_staleness \
         constraint_violation_review constitution_review cost_review dogfood_check; do
  has "$GT" "$A" "GT audit: $A"
done
has "$GT" 'META-CHECK|meta-check'             'GT: meta-check present'
has "$GT" 'Eat the dog food|self.?graded|dogfood'  'GT: S55 self-fidelity check present'
has "$GT" '3 ranked candidates for S56|candidates for S56' 'GT: 3 S56 candidates section'
has "$GT" 'DECISION-002'                      'GT: ties to DECISION-002'
has "$GT" 'write-guard|hook-pre-write'        'GT: records the write-guard whitelist finding'

# --- cold review: real per-requirement fidelity pass, honest REJECT, independence recorded ---
has "$RV" 'SHIPPED'                           'review: SHIPPED verdicts'
has "$RV" 'PARTIAL'                           'review: PARTIAL verdicts'
has "$RV" 'NOT-BUILT'                         'review: NOT-BUILT verdicts'
has "$RV" 'REJECT'                            'review: overall REJECT (honest, not rubber-stamp)'
has "$RV" 'fakest green'                      'review: fakest-green callout'
has "$RV" 'withheld|independence|cold'        'review: independence controls recorded'
has "$RV" 'Reconciliation|withheld'           'review: reconciles withheld D4/D5 honestly'
has "$RV" '1 of|one.?third|≈1|~1'             'review: quantifies the shortfall (≈1 of 5 core)'

# --- reviewer skill (brain): one rule, independence, procedure, honest limits ---
has "$SK" 'one rule|Trust the diff'           'skill: the one rule'
has "$SK" 'independen'                        'skill: independence section'
has "$SK" 'SHIPPED / PARTIAL / NOT-BUILT|SHIPPED / PARTIAL' 'skill: verdict vocabulary'
has "$SK" 'ACCEPT / REJECT|ACCEPT.*REJECT'    'skill: overall ACCEPT/REJECT'
has "$SK" 'Honest limit|do not overclaim'     'skill: honest limits'
has "$SK" 'Boot ritual'                       'skill: boot ritual (like Darshan/Varta)'
has "$SK" 'DECISION-002'                      'skill: cites DECISION-002'

# --- exactly 3 ranked S56 candidates, top = the fidelity gate ---
CAND=$(grep -cE '^### (🥇|🥈|🥉|[ABC] —|A —|B —|C —)' "$GT" 2>/dev/null || echo 0)
[ "$CAND" -eq 3 ] && ok "exactly 3 ranked S56 candidates ($CAND)" || no "exactly 3 ranked S56 candidates (got $CAND)"
grep -qE '🥇 A .*fidelity gate' "$GT" && ok "top candidate = build the fidelity gate (teeth)" \
  || no "top candidate = build the fidelity gate (teeth)"

# --- NO-CODE: no src/ change this session (committed or working tree) ---
SRC_DIRTY=0
git diff --name-only main...HEAD 2>/dev/null | grep -qE '^src/' && SRC_DIRTY=1
git status --porcelain 2>/dev/null | grep -qE ' src/' && SRC_DIRTY=1
[ "$SRC_DIRTY" -eq 0 ] && ok "NO-CODE honored (no src/ change)" || no "NO-CODE honored (no src/ change)"

# --- .ai/ consistency ---
if [ -x scripts/hook-drift-guard.sh ]; then
  scripts/hook-drift-guard.sh --quiet && ok ".ai/ drift-guard clean" || no ".ai/ drift-guard clean"
fi

echo "---"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || { echo "RED"; exit 1; }
echo "ALL GREEN"
