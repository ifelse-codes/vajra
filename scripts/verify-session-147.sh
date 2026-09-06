#!/usr/bin/env bash
# verify-session-147.sh — S147 Quiet Roles Audit deliverables.
#
# SUITE DECLARATION: All 11 checks are STRUCTURAL. S147 delivers documents only
# (no executable product). No execute-based checks are added — structural is correct
# for a document-only session; adding fabricated execute-based checks would be hollow.
#
# FIDELITY GAPS (things this suite CANNOT verify — read before trusting a green run):
#   1. Verbatim accuracy: that advice blocks are genuine quotes, not paraphrases.
#   2. Judgment correctness: that Changed/Noted/Hollow labels are accurate.
#   3. Changed incorporation: that advice labeled Changed actually landed in S148.
#   4. Dispatch authenticity: that dispatches ran vs. author-fabricated advice.
# The fidelity-reviewer cold read is the only gate for these properties.
#
# FAKEST GREEN (disclosed): C3 (judgment-per-role) confirms the author typed a bold
# judgment label per role section; it cannot confirm the judgment is accurate or that
# the advice was real.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

SESSION="147"
TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  if "$@" > "$ARTIFACTS/${NAME}.log" 2>&1; then
    echo "  PASS  $NAME"; PASS=$((PASS+1)); RESULTS+=("PASS $NAME")
  else
    echo "  FAIL  $NAME (see $ARTIFACTS/${NAME}.log)"; FAIL=$((FAIL+1)); RESULTS+=("FAIL $NAME")
  fi
}

AUDIT="$ROOT/sessions/session-147-quiet-roles-audit.md"
ROLES=(researcher plan-advisor requirements-analyst demo-producer release-coordinator)

echo "=== verify-session-147 ==="

# C1: audit file exists (structural)
c1_audit_file_exists() {
  [ -f "$AUDIT" ] || { echo "MISSING: $AUDIT"; return 1; }
}
run_check "C1-audit-file-exists" c1_audit_file_exists

# C2: all 5 role names appear as H2 headings in the audit (structural)
# Uses H2 heading detection, not just substring — a role name in prose doesn't count.
c2_five_roles_in_audit() {
  [ -f "$AUDIT" ] || return 1
  for role in "${ROLES[@]}"; do
    if ! grep -qi "^## ${role}" "$AUDIT"; then
      echo "MISSING H2 heading for role: $role"
      return 1
    fi
  done
}
run_check "C2-five-roles-as-headings" c2_five_roles_in_audit

# C3: each role section contains a bold judgment label (structural — see FAKEST GREEN above)
check_role_has_judgment() {
  local role="$1"
  # Matches: **Changed**, **Judgment: Changed**, Judgment: Changed (any form in the section)
  awk -v role="$role" '
    BEGIN { in_section=0; found=0 }
    /^## / { if (in_section) exit; if (tolower($0) ~ tolower(role)) in_section=1; next }
    in_section && (/\*\*(Judgment: )?(Changed|Noted|Hollow|INCOMPLETE)\*\*/ || /Judgment: (Changed|Noted|Hollow|INCOMPLETE)/) { found=1; exit }
    END { exit (found ? 0 : 1) }
  ' "$AUDIT"
}
c3_judgment_per_role() {
  [ -f "$AUDIT" ] || return 1
  for role in "${ROLES[@]}"; do
    if ! check_role_has_judgment "$role"; then
      echo "MISSING judgment label in section: $role"
      return 1
    fi
  done
}
run_check "C3-judgment-per-role" c3_judgment_per_role

# C4: each role section has at least 3 non-blank content lines (structural)
check_role_section_length() {
  local role="$1"
  local count
  count=$(awk -v role="$role" '
    /^## / { if (in_section) exit; if (tolower($0) ~ tolower(role)) { in_section=1; next } }
    in_section && /[^[:space:]]/ && !/^#/ { count++ }
    END { print count+0 }
  ' "$AUDIT")
  if [ "$count" -lt 3 ]; then
    echo "FAIL: $role section has only $count non-blank content lines (need >= 3)"
    return 1
  fi
}
c4_no_empty_role_sections() {
  [ -f "$AUDIT" ] || return 1
  for role in "${ROLES[@]}"; do
    check_role_section_length "$role" || return 1
  done
}
run_check "C4-no-empty-role-sections" c4_no_empty_role_sections

# C5: audit is at least 100 lines (structural — structural floor, not quality)
c5_audit_min_lines() {
  [ -f "$AUDIT" ] || return 1
  local lines
  lines=$(wc -l < "$AUDIT")
  if [ "$lines" -lt 100 ]; then
    echo "FAIL: audit has only $lines lines (need >= 100)"
    return 1
  fi
  echo "audit lines: $lines"
}
run_check "C5-audit-min-100-lines" c5_audit_min_lines

# C6: S148 prompt exists, exactly one match, non-empty (structural)
c6_s148_prompt_exists() {
  local files=("$ROOT"/prompts/148-task-*.md)
  if [ "${#files[@]}" -ne 1 ]; then
    echo "FAIL: expected exactly 1 prompts/148-task-*.md, found ${#files[@]}"
    return 1
  fi
  if [ ! -f "${files[0]}" ]; then
    echo "FAIL: no file matches prompts/148-task-*.md"
    return 1
  fi
  if [ ! -s "${files[0]}" ]; then
    echo "FAIL: ${files[0]} is empty"
    return 1
  fi
  echo "S148 prompt: ${files[0]}"
}
run_check "C6-s148-prompt-exists" c6_s148_prompt_exists

# C7: S148 prompt has a ## Goal section (structural)
c7_s148_has_goal() {
  local files=("$ROOT"/prompts/148-task-*.md)
  [ -f "${files[0]}" ] || return 1
  grep -q "^## Goal" "${files[0]}" || { echo "FAIL: no ## Goal section in S148 prompt"; return 1; }
}
run_check "C7-s148-has-goal" c7_s148_has_goal

# C8: S148 prompt has an ## Acceptance Criteria section (structural)
c8_s148_has_acceptance() {
  local files=("$ROOT"/prompts/148-task-*.md)
  [ -f "${files[0]}" ] || return 1
  grep -q "^## Acceptance Criteria" "${files[0]}" || { echo "FAIL: no ## Acceptance Criteria in S148 prompt"; return 1; }
}
run_check "C8-s148-has-acceptance" c8_s148_has_acceptance

# C9: S148 prompt has a design-significant: marker (structural)
c9_s148_design_significant() {
  local files=("$ROOT"/prompts/148-task-*.md)
  [ -f "${files[0]}" ] || return 1
  grep -q "design-significant:" "${files[0]}" || { echo "FAIL: no design-significant: marker in S148 prompt"; return 1; }
}
run_check "C9-s148-design-significant" c9_s148_design_significant

# C10: required governance handoffs exist (.ai/handoffs/session-147-<role>.md) (structural)
# Includes qa-specialist (this dispatch) per qa-specialist rec 7.
c10_required_handoffs_exist() {
  for role in tech-lead design-advisor plan-advisor implementation-advisor qa-specialist fidelity-reviewer; do
    local f="$ROOT/.ai/handoffs/session-147-${role}.md"
    if [ ! -f "$f" ]; then
      echo "MISSING handoff: $f"
      return 1
    fi
  done
}
run_check "C10-required-handoffs-exist" c10_required_handoffs_exist

# C11: no Rust src/ changes in this session branch (structural)
c11_no_src_rust_changes() {
  local base
  base=$(git merge-base HEAD origin/main 2>/dev/null) || {
    # fail safe: if origin/main is unreachable, block rather than skip
    echo "FAIL: cannot compute merge-base (origin/main unreachable)"
    return 1
  }
  local changed
  changed=$(git diff "$base"..HEAD --name-only 2>/dev/null | grep '^src/.*\.rs$' || true)
  if [ -n "$changed" ]; then
    echo "FAIL: Rust source files modified in this session:"
    echo "$changed"
    return 1
  fi
  echo "no src/*.rs changes: OK"
}
run_check "C11-no-src-rust-changes" c11_no_src_rust_changes

# --- Summary ---
echo ""
echo "Results:"
for r in "${RESULTS[@]}"; do echo "  $r"; done
echo ""
TOTAL=$((PASS + FAIL))
echo "=== $PASS/$TOTAL PASS (structural suite) ==="

# Check class tally
EXEC=0; STRUCT=11
echo "Check classes: ${EXEC} execute-based | ${STRUCT} structural"

if [ "$FAIL" -gt 0 ]; then exit 1; fi
