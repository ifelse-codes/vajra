---
role: researcher
session: 149
agent: claude-code-subagent
source-sha: 21ee873f632949da32e12a47b7d8b542508d51b77ac4a0dbc19673239dbb473c
captured: 2026-09-07T03:15:00Z
cost_usd: null
---

# Session 149 — Researcher Handoff

**Task:** Evidence-gathering for the advice-influence audit across S146, S147, S148.

## Scope

Files read: `.ai/handoffs/session-146-*`, `.ai/handoffs/session-147-*`, `.ai/handoffs/session-148-*`, `sessions/session-146-summary.md`, `sessions/session-147-quiet-roles-audit.md`, `sessions/session-148-summary.md`, `.ai/handoffs/session-{146,147,148}-tech-lead.md`.

## Key findings

rec 1 — Every "carry-forward, non-blocking" label grades Hollow: 6 of 9 fidelity-reviewer recs (67%). The label removes all obligation and is functionally a polite "no."
rec 2 — Specificity predicts Changed: all Changed grades share an exact function name, constant, or tool invocation. Generic confirmatory recs grade Hollow.
rec 3 — Implementation-advisor outperforms fidelity-reviewer on influence (62% vs 22% Changed at initial evidence pass before verify-script verification).
rec 4 — S148 (narrow scope + advisor briefed before commits) had the cleanest implementation-advisor record (0 Hollow).
rec 5 — S147 summary file missing: the DOCUMENT session produced `session-147-quiet-roles-audit.md` not `session-147-summary.md`; this degraded initial grading quality for 3 impl-advisor recs (required reading the verify script instead).

## Evidence table

22 advice items graded across 6 role×session pairings.
Full evidence in `sessions/session-149-advice-influence-audit.md`.

| Session | Role | Changed | Noted | Hollow | Total |
|---|---|---|---|---|---|
| S146 | implementation-advisor | 2 | 0 | 1 | 3 |
| S146 | fidelity-reviewer | 0 | 0 | 3 | 3 |
| S147 | implementation-advisor | 7 | 0 | 0 | 7 |
| S147 | fidelity-reviewer | 1 | 0 | 2 | 3 |
| S148 | implementation-advisor | 2 | 1 | 0 | 3 |
| S148 | fidelity-reviewer | 1 | 0 | 2 | 3 |
| **Total** | | **13** | **1** | **8** | **22** |

## Recommendation input

Advice influences work when specific and pre-commit (impl-advisor). The carry-forward escape hatch is the primary hollow driver. A mechanical check would produce fake compliance; the right fix is a protocol rule banning "carry-forward" without a named target session.
