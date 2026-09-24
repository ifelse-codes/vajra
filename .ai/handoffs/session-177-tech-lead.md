---
role: tech-lead
session: 177
agent: claude-code-subagent (verified: toolu_01Ww3YyCvP1Kv2DMVJGY8k4p)
source-sha: 8f05a124319b2e2757759f881a313363dd386f4776f61cbf098087dcbfc5e6d0
captured: 2026-09-24T09:21:38Z
cost_usd: null
---

# Tech-lead handoff — session 177

# Tech-lead crew dispatch — session 177 (F74: scaffold close check reads ground_truth_next_session)

The session needs one specialist: fidelity-reviewer. The other eight are `deferred-budget`. The fix is small: the ~10-line S175 helper from `scripts/verify-closeout.sh` (lines 51-62) copied into `scripts/verify-closeout-scaffold.sh`, swapped in at two places (lines 273 and 372), then a rebuild, a sync into rudra and one fixture. Every other place that decides ground truth already reads `ground_truth_next_session`; the scaffold is the only one still hard-coding `N % 5`.

Every budget below is an instruction the role is trusted to follow, not a hard limit.

crew researcher — deferred-budget — budget: 100000 tokens — nothing about this fix is unknown (S175 already wrote the helper); a broad dispatch (~6M raw tokens, S134) buys no answer.
crew requirements-analyst — deferred-budget — budget: 100000 tokens — the F74 row plus the founder's pick already state "done" (S10 gets the checks, S15 exempt, a missing key behaves as before).
crew design-advisor — deferred-budget — budget: 200000 tokens — copies an existing design (the S175 helper) to one more place; record a reasoned skip rather than pay for a dispatch.
crew plan-advisor — deferred-budget — budget: 100000 tokens — the plan is 4 steps: port the helper, rebuild, sync into rudra, add the fixture.
crew implementation-advisor — deferred-budget — budget: 250000 tokens — shell quirks are a real risk (`10#$N`, `set -u`), but the fixture covers it; fidelity-reviewer is paid first.
crew qa-specialist — deferred-budget — budget: 200000 tokens — the QA station re-runs the executable checks live at close, and the session writes the S10/S15 fixture itself.
crew demo-producer — deferred-budget — budget: 150000 tokens — the only visible result is one fixture; a demo dispatch costs more than the fix.
crew fidelity-reviewer — required — budget: 400000 tokens — the close gate forces it. Brief it narrowly on (1) the scaffold diff, (2) the fixture and its output, (3) proof the rudra sync landed.
crew release-coordinator — deferred-budget — budget: 100000 tokens — a single-file scaffold fix on a session branch, no release cut.

rec 1 — Require only fidelity-reviewer, briefed tightly on the scaffold diff, the fixture output and the rudra sync proof. The other eight stay `deferred-budget` (founder: "ceremony is a cost").

rec 2 — Record `design-advisor: skipped — <reason>` in `prompts/177-task-keep-testing.md` rather than dispatching; name DECISION-007's S175 addendum as the record this session reverses. If judged `design-significant: yes`, cite DECISION-007 and add an addendum.

rec 3 — Because implementation-advisor is deferred, the fixture must prove all three cases on the scaffold as written into rudra: key 15 + S10 → CODE checks; key 15 + S15 → N/A; key missing → the old `N % 5` answers across a spread of session numbers. Pattern: `scripts/verify-session-175.sh` (AC1a).

rec 4 — One fidelity-reviewer pass; a second only if the first REJECTs (S168/S173 turned repeat rounds into hours).

## Handoff Delta
- `+` new: first tech-lead handoff for session 177 — one required role (fidelity-reviewer), eight deferred-budget, 4 recs.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (3286 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
