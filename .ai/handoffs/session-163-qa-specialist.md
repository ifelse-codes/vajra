---
role: qa-specialist
session: 163
agent: claude-code-subagent
source-sha: 65ba74802d0d73766418e69b8e4e4920507171ac
captured: 2026-09-11T03:25:00Z
cost_usd: null
---

# QA Specialist handoff — session 163

**Brief:** Confirm that converted verify checks are genuinely behavioral (not just renamed greps) and that falsifiability proofs are concrete.

## Findings

- **8 of 10 checks EXECUTE-BASED; 2 hollow (AC5 + AC6 in initial commit)** — FIXED IN FINAL COMMIT (65ba748): AC5 now uses `_AC5_PASS` tracker conditioned on sub-check results; AC6 uses awk self-scan.
- **check_demo_markers-in-main-sequence**: hollow source grep (pre-existing, not added by S163) — BACKLOG.
- **All 5 FALSIFIABILITY comments CONCRETE** — each names the exact scenario where the old grep would silently pass while the new test catches the regression.
- **AC6 factual claim verified**: no executable `grep -q "string" src/file` in verify-163.sh (awk self-scan exit=0).
- **AC3 FALSIFIABILITY most precise**: correctly identifies `has_plan_steps` as a local variable inside `check_execution_shas`, not a callable function.

## Classification of all 10 checks in verify-session-163.sh

| Check | Type |
|-------|------|
| ac1-is_code_session-exempts-document | execute-based (--demo-only subprocess) |
| ac1-check_demo_markers-passes-with-markers | execute-based (--demo-only subprocess) |
| ac2-non-session-branch-test-passes | execute-based (cargo test) |
| ac2-different-session-guard-test-passes | execute-based (cargo test) |
| ac3-s154-tightening-blocks-via-live-entry | execute-based (--check-exec-shas subprocess) |
| ac4-verify-158-exits-0-with-behavioral-checks | execute-based (bash subprocess) |
| ac4-verify-157-exits-0-with-behavioral-checks | execute-based (bash subprocess) |
| ac4-verify-154-exits-0-with-behavioral-checks | execute-based (bash subprocess) |
| ac5-non-regression-all-three-exit-0 | execute-based (derived from _AC5_PASS) |
| ac6-zero-source-proximity-greps-in-163 | execute-based (awk self-scan) |

## Handoff Delta

**From S162 qa-specialist:** S162 QA confirmed the waiver-path behavioral tests invoked real subprocess calls. S163 QA extends that: confirms 10/10 checks are execute-based AND that the FALSIFIABILITY comments name real counterexamples (not just restating what the check does differently).
