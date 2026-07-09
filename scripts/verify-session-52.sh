#!/usr/bin/env bash
# verify-session-52.sh — S52 value gap on a HARDER task (real dist-build A/B on chitra, PAID).
# Measurement/reporting session: no Vajra src/ change. Verify checks the deliverables exist,
# the summary is complete + honest, the A/B evidence is present, and .ai/ is consistent.
set -euo pipefail
cd "$(dirname "$0")/.."

PASS=0; FAIL=0
ok(){ echo "  ok   $1"; PASS=$((PASS+1)); }
no(){ echo "  FAIL $1"; FAIL=$((FAIL+1)); }
has(){ grep -qiE "$2" "$1" 2>/dev/null && ok "$3" || no "$3"; }

echo "=== S52 verify — value gap on a HARDER task (chitra dist-build A/B) ==="

SUM=sessions/session-52-summary.md
[ -f "$SUM" ] && ok "summary present" || no "summary present"
has "$SUM" 'rubric'                       'summary: rubric declared'
has "$SUM" 'constraint-adherence'         'summary: constraint-adherence axis (the S52-new axis)'
has "$SUM" 'Arm A'                        'summary: Arm A recorded'
has "$SUM" 'Arm B'                        'summary: Arm B recorded'
has "$SUM" 'verdict'                      'summary: honest verdict'
has "$SUM" 'n=2'                          'summary: n=2 caveat stated'
has "$SUM" 'null'                         'summary: null result stated (not rescued)'
has "$SUM" 'tsbuildinfo|\.d\.ts'          'summary: the shared build defect recorded'
has "$SUM" 'dogfood'                      'summary: dogfood refresh recorded'
has "$SUM" '1\.4041|1\.40'                'summary: Arm A cost logged'
has "$SUM" '1\.2570|1\.25|1\.26'          'summary: Arm B cost logged'
has "$SUM" '11\.7|8\.3|receipt'           'summary: receipt-overstatement re-confirmed'
has "$SUM" 'candidates for S53'           'summary: 3 S53 candidates'

ART=sessions/session-52-artifacts
for f in armA.metrics.json armB.metrics.json armA-refusal.metrics.json chitra-gt.metrics.json \
         task-prompt.txt rubric-baseline.md ab-deliverable-comparison.md armA.build.mjs armA.tsconfig.build.json; do
  [ -f "$ART/$f" ] && ok "artifact $f" || no "artifact $f"
done

# both build-arm metrics JSONs parse and record a non-error paid run
for arm in A B; do
  python3 -c "import json; d=json.load(open('$ART/arm${arm}.metrics.json')); assert d['is_error'] is False; assert d['total_cost_usd']>0" \
    && ok "metrics arm$arm: successful paid run" || no "metrics arm$arm: successful paid run"
done

# Arm A landed build config carries the correction (incremental:false — the reproducibility fix)
grep -q '"incremental": false' "$ART/armA.tsconfig.build.json" && ok "Arm A deliverable: reproducibility fix folded in" \
  || no "Arm A deliverable: reproducibility fix folded in"

# next prompt written + TASK pointer updated
ls prompts/53-task-*.md >/dev/null 2>&1 && ok "S53 prompt written" || no "S53 prompt written"

# no accidental Vajra src/ change this session (measurement session)
if git rev-parse --git-dir >/dev/null 2>&1; then
  if git diff --name-only main...HEAD 2>/dev/null | grep -qE '^src/'; then
    no "no Vajra src/ change (measurement session)"
  else
    ok "no Vajra src/ change (measurement session)"
  fi
fi

# .ai/ consistency
if [ -x scripts/hook-drift-guard.sh ]; then
  scripts/hook-drift-guard.sh --quiet && ok ".ai/ drift-guard clean" || no ".ai/ drift-guard clean"
fi

echo "---"
echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ] || { echo "RED"; exit 1; }
echo "ALL GREEN"
