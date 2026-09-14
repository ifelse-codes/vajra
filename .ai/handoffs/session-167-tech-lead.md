---
role: tech-lead
session: 167
agent: claude-code-subagent (verified: toolu_01CTqXMVfVrUvp9B9dUhV38K)
source-sha: 3d6b0e1108d04352f999612070f7decfb3bde838cd8866971f1f78eab943b22d
captured: 2026-09-14T08:06:17Z
cost_usd: null
---

# Tech-lead handoff — session 167

**Brief:** CODE session 167 — every Vajra demo plays as a rich story in the terminal (demo kit, rich template outline, retire the interactive_html rule, demo-producer brief, kit + template onto --sync-fleet, release). Crew kept tight for cost: three required roles; seven deferred on budget (a cost call, not "not needed").

crew design-advisor — required — budget: 150000 tokens — the prompt says design-significant: yes, and the open question (every existing project's template is unstamped, so it needs --overwrite-drifted) must be decided on the record before step 2
crew fidelity-reviewer — required — budget: 300000 tokens — cold review before merge; 11 criteria, AC10 at risk of being marked done without a release, and a verify script built on the kit could pass without checking anything real
crew release-coordinator — required — budget: 100000 tokens — a crates.io publish cannot be undone, three channels must go out in order, and the old merged session-167-adhoc-fixes branch could wrongly pass this session's ship checks
crew implementation-advisor — deferred-budget — budget: 120000 tokens — briefs for the three required roles already come to ~550k; the fill() byte-identical risk is already a named guardrail with a required test
crew qa-specialist — deferred-budget — budget: 100000 tokens — AC9 plus the cold fidelity pass already check for hollow greps
crew demo-producer — deferred-budget — budget: 80000 tokens — worth running on its new brief in S168, when the gate changes
crew researcher — deferred-budget — budget: 60000 tokens — the prototype already covers the research
crew requirements-analyst — deferred-budget — budget: 60000 tokens — the founder approved the spec and it has 11 testable criteria
crew plan-advisor — deferred-budget — budget: 60000 tokens — the 10-step plan covers every criterion

Recommendations:
1. rec 1 — dispatch design-advisor with just the open question, DECISION-007/008 and src/cli/init.rs SYNC_HOOKS.
2. rec 2 — dispatch release-coordinator before step 10, to write the release order and prove the ship checks read this branch.
3. rec 3 — give fidelity-reviewer the prompt, the diff and scripts/verify-session-167.sh; look hardest at AC2, AC6, AC10.
4. rec 4 — write in the summary that demo-producer's new brief was never run.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (2351 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
