#!/usr/bin/env bash
# verify-session-53.sh — S53 reframe Vajra around GOVERNANCE as the product (NO-CODE positioning).
# Docs/memory-only session: no src/ change. Verify checks the deliverables exist, the reframe is
# HONEST (differentiator verdict recorded, aspirational parts flagged, B kept as hypothesis not rescued),
# and .ai/ is consistent.
set -euo pipefail
cd "$(dirname "$0")/.."

PASS=0; FAIL=0
ok(){ echo "  ok   $1"; PASS=$((PASS+1)); }
no(){ echo "  FAIL $1"; FAIL=$((FAIL+1)); }
has(){ grep -qiE "$2" "$1" 2>/dev/null && ok "$3" || no "$3"; }

echo "=== S53 verify — reframe to governance as the product (NO-CODE) ==="

# --- VISION.md: leads with governance, honest about what is NOT real ---
V=VISION.md
[ -f "$V" ] && ok "VISION present" || no "VISION present"
has "$V" 'governance'                         'VISION: leads with governance'
has "$V" 'provabl'                            'VISION: "provable" rule-following framed'
has "$V" 'aspirational|0 cross-agent|not built|unbuilt|not shipped' 'VISION: cross-agent/ledger flagged NOT real'
has "$V" 'CLAUDE\.md.*git hook|git hook.*CLAUDE\.md|differentiator' 'VISION: differentiator test present'
has "$V" 'gh pr create'                       'VISION: names the concrete edge git hooks miss'
has "$V" 'hypothesis'                         'VISION: "better work" kept as a hypothesis (not led)'
has "$V" 'ICP|who pays|job-to-be-done|regulated' 'VISION: ICP / who-pays stated'
has "$V" 'multi-agent SDLC pipeline|governed multi-agent' 'VISION: pipeline north-star present'
has "$V" 'Analyst'                            'VISION: Analyst stage named'
has "$V" 'reference design|Serena'            'VISION: borrow-vs-dependency stated'
has "$V" 'delta'                              'VISION: delta tracking present'

# --- DECISION-001: supersedes the S46 B-lock, records the honest verdict ---
D=docs/decisions/DECISION-001-governance-as-product.md
[ -f "$D" ] && ok "DECISION-001 present" || no "DECISION-001 present"
has "$D" 'supersede'                          'DECISION: supersedes (not erases) the S46 B-lock'
has "$D" 'S46'                                'DECISION: cites the S46 lock it reverses'
has "$D" 'n=2'                                'DECISION: n=2 evidence cited'
has "$D" 'PARTIAL PASS|PASSES'                'DECISION: differentiator verdict recorded'
has "$D" 'risk'                               'DECISION: honest risks recorded'
has "$D" 'revisit'                            'DECISION: keeps the door open (revisit condition)'
has "$D" 'Refinement|pipeline'               'DECISION: pipeline refinement recorded'

# --- ROADMAP: re-ranked around the governed multi-agent SDLC pipeline; Analyst = S54 #1 ---
R=.ai/ROADMAP.md
has "$R" 'governed multi-agent SDLC pipeline|pipeline' 'ROADMAP: re-ranked around the pipeline'
has "$R" 'Analyst'                            'ROADMAP: Analyst stage ranked'
has "$R" 'S54 #1|Analyst stage|one governed stage per session' 'ROADMAP: explicit S54 #1 (Analyst)'
has "$R" 'reference design'                   'ROADMAP: Spec Kit/OpenSpec/BMAD = reference designs'

# --- summary: honest verdict + 3 ranked S54 candidates ---
S=sessions/session-53-summary.md
[ -f "$S" ] && ok "summary present" || no "summary present"
has "$S" 'differentiator'                     'summary: differentiator verdict'
has "$S" 'PARTIAL PASS|PASSES|FAILS'          'summary: explicit pass/fail on the gate'
has "$S" 'candidates for S54|S54 candidates'  'summary: 3 S54 candidates'
has "$S" 'hypothesis'                         'summary: B kept as hypothesis, not rescued'
has "$S" 'Analyst'                            'summary: S54 = the Analyst stage'

# --- next prompt written (Analyst stage; ledger prompt superseded) + NO-CODE guarantee ---
[ -f prompts/54-task-analyst-stage.md ] && ok "S54 Analyst prompt written" || no "S54 Analyst prompt written"
[ ! -f prompts/54-task-ledger-extract-present.md ] && ok "superseded ledger prompt removed" || no "superseded ledger prompt removed"

# NO-CODE: no src/ change this session
if git rev-parse --git-dir >/dev/null 2>&1; then
  if git diff --name-only main...HEAD 2>/dev/null | grep -qE '^src/'; then
    no "NO-CODE honored (no src/ change)"
  else
    ok "NO-CODE honored (no src/ change)"
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
