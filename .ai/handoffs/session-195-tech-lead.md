---
role: tech-lead
session: 195
agent: claude-code-subagent (verified: toolu_012e5wx55cEjjqkjZteEYoTD; text-sha: 19240dbc8fe469921af60339e1cc0e99df79f164462b7db6100db64437134c4e)
source-sha: 2e7dab4e8e2566e84ddfad9c47405efa0ba99c386dcb1d1ed7aaee1aad8681f0
captured: 2026-10-12T17:28:54Z
cost_usd: null
---

# Tech-lead handoff — session 195

**Read:** /Users/suman/playground/vajra/prompts/195-task-ground-truth.md, /Users/suman/playground/vajra/.ai/CONSTRAINTS.yaml (`ground_truth:` block, 13 required_audits), /Users/suman/playground/vajra/.ai/handoffs/session-190-tech-lead.md (the precedent), /Users/suman/playground/vajra/sessions/session-194-summary.md, /Users/suman/playground/vajra/src/mandate/mod.rs (`DESIGN_ADVISOR_MANDATE_FROM_SESSION = 133`), /Users/suman/playground/vajra/src/fidelity/mod.rs (mandatory from S131, with no exemption for any session type).

The code already makes two roles mandatory for S195: design-advisor (from S133) and fidelity-reviewer (from S131). Ground-truth sessions get no exemption, so the close blocks without both, whatever I propose. I add release-coordinator for two reasons. It is the single judge of every `obeyed:` answer (founder, 2026-10-03), and `stranger_check` / Goal 4 ("can he be confident yet?") fall in its area. This is the same crew as S185 and S190. The other six roles have nothing to work on in a NO-CODE session. That is a money call, not a judgment that they are unworthy.

The token budgets below are instructions I trust each role to follow. Vajra cannot enforce them mid-run, and nothing stops a role from reading more. A narrow brief is what keeps the cost down.

### Crew

crew researcher — deferred-budget — budget: 250000 tokens — The Haiku question has to be answered from rudra S20's own evidence, and that evidence is already in session-194-summary.md (210/210 Haiku replies, 0 Agent calls, RED 17/5, the self-written "INDEPENDENT" ACCEPT). The main session reads it directly. A researcher's natural brief here (comparing models, testing other cheap models) is broad. S134 measured ~6M raw tokens for one broad dispatch and 19.2M for three, which hit a $20/mo cap. The three required roles below already come to ~320k tokens. Keep this for the rudra S21 Opus-vs-Haiku comparison.

crew requirements-analyst — deferred-budget — budget: 100000 tokens — The prompt already lists everything: 13 named audits, the checklist items, 4 acceptance lines. Spending ~100k to restate it back to the session buys no new artifact. Keep it for the CODE session that acts on this review's picks.

crew plan-advisor — deferred-budget — budget: 100000 tokens — `## Plan` is still a placeholder, and this session's plan is "fill one report". There is no multi-step build to sequence. Carry the full allowance to S196.

crew implementation-advisor — deferred-budget — budget: 120000 tokens — No source edits are allowed (`forbid_code_changes: true`), so there is no implementation path to advise on. Carry the allowance to the known-bug session (F125 first).

crew qa-specialist — deferred-budget — budget: 100000 tokens — This session writes no verify-195 script. The evidence the acceptance asks for is live command output pasted into the report by the main session. Carry the allowance to S196.

crew demo-producer — deferred-budget — budget: 80000 tokens — A NO-CODE review produces no demo script, so this role has nothing to build. Carry the full allowance forward.

crew design-advisor — required — budget: 120000 tokens — Mandatory by the code (S195 ≥ 133), and also really needed. Most checklist picks are design calls: F125 (what proves "this is the close" on a `-closeout` branch), F123's remaining routes, F121's named limits, the `latest` folder-vs-link question, and the Haiku question's "more gates vs fewer steps vs named supported models". Brief: the prompt, the S194 summary's Findings and limits sections, and DECISION-007/011 plus the ADR-0004 S194 addendum. No repo tour.

crew fidelity-reviewer — required — budget: 120000 tokens — Mandatory by the code (S195 ≥ 131). In this session it is also the guard against the project grading itself, the same thing S20 did on Haiku. Brief: the prompt's Deliverables/Acceptance plus the diff that creates `sessions/session-195-ground-truth.md`. One cold pass.

crew release-coordinator — required — budget: 80000 tokens — The one judge of every `obeyed:` answer, in a single pass (founder, 2026-10-03). It also owns `stranger_check` (downloads, stars, issues as real numbers) and the Goal 4 confidence question. Brief: the stranger_check questions, the report's Goal 4 section, and the `## Advice` dispositions. Nothing more.

### Recommendations

rec 1 — Answer the Haiku question from the S194 summary's own lines (tool counts, the RED tally, F122's row), quoted with their sources, and keep "more gates" separate from new policing of Vajra's own paperwork.
The founder's 2026-09-15 rule bans new checks on Vajra's own paperwork. Gates that protect a user's project (F121, F123) are a different class. The report should say which class each option falls in. "Name the models Vajra supports" is a legitimate answer and should be weighed, not dismissed.

rec 2 — Run the four live-evidence audits first and paste the raw output: `stranger-check.sh`, `scaffold-drift.sh`, `vajra next --stations 195`, `vajra next --dogfood-age`.
These are the audits most likely to be filled in from memory. Grep each log for WAIVED/N/A before calling anything green (S178 lesson).

rec 3 — Dispatch design-advisor once, after drafting the checklist picks, and give it only the design-flavored items (F125, F123 routes, F121 limits, `latest` link, Haiku options).
One narrow pass. Do not re-dispatch for wording.

rec 4 — Dispatch fidelity-reviewer only after the report draft is committed, and give it the prompt's Deliverables/Acceptance plus that diff, not the author's account of why it is complete.

rec 5 — Route every `obeyed:` answer in `## Advice` through ONE release-coordinator pass, with its judge lines unfenced as `obeyed-check … implemented:`. No per-claim judging.

rec 6 — Before close, confirm that all three required roles have real handoffs under `.ai/handoffs/session-195-*.md`, recorded from the handback text and never from a raw `.output` file (F120). Write the report on a `-closeout` branch, and note in the report that this branch name is exactly the F125 hole.
The session is using the opening it is reviewing, and the report should say so plainly ("named, not closed").

## Handoff Delta
- `+` new: first tech-lead handoff for this session (6227 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
