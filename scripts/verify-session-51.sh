#!/usr/bin/env bash
# verify-session-51.sh — S51 value-gap measurement (real-task A/B on chitra, PAID).
# Measurement/reporting session: no Vajra src/ change. Verify checks the deliverables
# exist, the summary is complete, the A/B evidence is present, and .ai/ is consistent.
set -euo pipefail
cd "$(dirname "$0")/.."

PASS=0; FAIL=0
ok(){ echo "  ok   $1"; PASS=$((PASS+1)); }
no(){ echo "  FAIL $1"; FAIL=$((FAIL+1)); }
has(){ grep -qiE "$2" "$1" 2>/dev/null && ok "$3" || no "$3"; }

echo "=== S51 verify — value gap (chitra A/B) ==="

SUM=sessions/session-51-summary.md
[ -f "$SUM" ] && ok "summary present" || no "summary present"
has "$SUM" 'rubric'                     'summary: rubric declared'
has "$SUM" 'Arm A'                      'summary: Arm A recorded'
has "$SUM" 'Arm B'                      'summary: Arm B recorded'
has "$SUM" 'Verdict'                    'summary: honest verdict'
has "$SUM" 'n=1'                        'summary: n=1 caveat stated'
has "$SUM" 'dogfood'                    'summary: dogfood refresh recorded'
has "$SUM" '0\.8127|0\.81'             'summary: Arm A cost logged'
has "$SUM" '0\.6813|0\.68'             'summary: Arm B cost logged'
has "$SUM" 'candidates for S52'         'summary: 3 S52 candidates'

ART=sessions/session-51-artifacts
for f in armA.readme.diff armB.readme.diff armA.metrics.json armB.metrics.json task-prompt.txt; do
  [ -f "$ART/$f" ] && ok "artifact $f" || no "artifact $f"
done

# both metrics JSONs parse and record a non-error paid run
for arm in A B; do
  python3 -c "import json,sys; d=json.load(open('$ART/arm${arm}.metrics.json')); assert d['is_error'] is False; assert d['total_cost_usd']>0" \
    && ok "metrics arm$arm: successful paid run" || no "metrics arm$arm: successful paid run"
done

# next prompt written + TASK pointer updated
[ -f prompts/52-task-value-gap-harder.md ] && ok "S52 prompt written" || no "S52 prompt written"

# .ai/ consistency (SESSION == SESSION-BOOT Number; TASK references session or between-sessions)
if [ -x scripts/hook-drift-guard.sh ]; then
  scripts/hook-drift-guard.sh --quiet && ok ".ai/ drift-guard clean" || no ".ai/ drift-guard clean"
fi

echo "---"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || { echo "RED"; exit 1; }
echo "ALL GREEN"
