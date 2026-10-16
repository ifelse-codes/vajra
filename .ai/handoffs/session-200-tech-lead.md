---
role: tech-lead
session: 200
agent: claude-code-subagent (verified: toolu_01JP1iX13Rq5M7ccXuv4WsZK; text-sha: 9cc22e9f7e6840dc301ab0f012cddce203cb8eea61b08248bd623167090800c7)
source-sha: 4bb2f3a11920e5c80df5471408d85048c9e9811e64162e7b3f733a48133769b3
captured: 2026-10-16T15:48:53Z
cost_usd: null
---

# Tech-lead handoff — session 200

# Tech-lead handoff — session 200

**Read:** /Users/suman/playground/vajra/prompts/200-task-ground-truth.md, /Users/suman/playground/vajra/.ai/handoffs/session-195-tech-lead.md (the precedent), /Users/suman/playground/vajra/src/mandate/mod.rs (lines 360–444: the design-advisor mandate from S133 is met either by a handoff OR by a recorded `design-advisor: skipped — <reason>` line in the prompt. A skip passes, and a loud warning is printed only when the prompt also says `design-significant: yes`).

A note on the format first. You asked for required / optional / skip. This phase's gate accepts only `required` or `deferred-budget`, with a number on every line. So "skip" below is written as `deferred-budget` with the cost reasoning attached.

The crew is two roles, down from S195's three. fidelity-reviewer stays because the code requires it from S131 and because it stops the project grading itself. release-coordinator stays because it is the single judge of every `obeyed:` answer (founder rule) and owns `stranger_check` / Goal 4. design-advisor drops from required to deferred. The prompt says `design-significant: no`. Most of this checklist is "keep in backlog" or "drop": F127/F123 routes, F97, S188 gaps and `/clear` are all already named-not-closed by founder rule. N22/N23 are wording mismatches in old verify scripts, and the two "at session start" items are things to look at, not design calls. The mandate is met by a one-line recorded skip, which fits the founder's "prefer removing ceremony". The remaining six roles have nothing to work on in a NO-CODE session.

The budgets are instructions I trust each role to follow. They are not caps, and Vajra cannot enforce them mid-run. A narrow brief with named files is what keeps the cost down.

### Crew

crew researcher — deferred-budget — budget: 200000 tokens — The close-truth question means reading four `.ai/verify/closeout/<stamp>/result` files and four summaries. The main session can do that in a few reads. S134 measured ~6M raw tokens for one broad dispatch and 19.2M for three, which hit a $20/mo cap. The two required roles already come to ~200k. Keep this for the next rudra session's evidence comparison.

crew requirements-analyst — deferred-budget — budget: 100000 tokens — The prompt already lists 13 audits, the checklist and 4 acceptance lines. Restating them would cost ~100k and produce no new artifact. Carry it to S201, the code session that acts on these picks.

crew design-advisor — deferred-budget — budget: 100000 tokens — The money: ~100k on top of ~200k already required, for a checklist that has no open design fork (`design-significant: no`). Every design item on it is named-not-closed by founder rule. The mandate allows a recorded skip (mandate/mod.rs Rung 3), so the session must write `design-advisor: skipped — <reason>` under `## Design`. Carry the allowance to S201 if it takes on N23 (the rudra sync-fleet lag), which is the one item with a real design question.

crew plan-advisor — deferred-budget — budget: 80000 tokens — The plan is "fill one report". There is no build to put in order. Carry it to S201.

crew implementation-advisor — deferred-budget — budget: 100000 tokens — `forbid_code_changes`: no source edits, so there is no implementation path to advise on. Carry it to S201.

crew qa-specialist — deferred-budget — budget: 80000 tokens — There is no verify-200 script to write. The main session supplies the evidence as live command output pasted into the report. Carry it to S201.

crew demo-producer — deferred-budget — budget: 60000 tokens — A review-only session has no demo to build. Carry the full allowance forward.

crew fidelity-reviewer — required — budget: 120000 tokens — The code requires it from S131, with no exemption for ground-truth sessions. It is the cold check against the project grading its own homework. Brief: the prompt's Deliverables and Acceptance, plus the diff that creates `sessions/session-200-ground-truth.md`. One pass, no repo tour.

crew release-coordinator — required — budget: 80000 tokens — The one judge of all `obeyed:` answers in a single pass (founder, 2026-10-03). It also owns `stranger_check` (real download, star and issue numbers) and Goal 4 ("can the founder be confident yet?"). Brief: the stranger_check questions, the report's Goal 4 section, and the `## Advice` dispositions. Nothing more.

### Recommendations

rec 1 — Do the two "at session start" checks before writing any file: run `vajra next --steps` to see whether S199 review rec 5's sign-off step hides the later steps, and run `readlink .ai/verify/closeout/latest` for S199 release-coordinator rec 1. Paste both raw outputs.
Writing the report changes the state these two checks look at. Do them first or the evidence is lost.

rec 2 — For the close-truth question, name the result-file path for each of S196–S199, paste its verdict lines, and put the summary's own words next to them. Grep each file for WAIVED/N/A before calling a session green.
This is the question's first use (N14). The S178 lesson was that hand-written "verified" stamps hid WAIVED checks.

rec 3 — Satisfy the design-advisor mandate with one line under `## Design`, `design-advisor: skipped — <reason>`, and do not dispatch it.
The skip passes at Rung 3 of mandate/mod.rs. One line is less ceremony than a ~100k dispatch for a checklist with no open design question.

rec 4 — When picking N22 and N23, weigh "drop" as a real option: retire or freeze the old per-session verify scripts instead of rewording them each time the wording moves.
Rewording verify-178/179 to match is the "update the old paperwork" loop the founder asked to stop (2026-09-15, "prefer removing ceremony"). Dropping is the founder's call, so set it out as a choice.

rec 5 — Order the dispatches: report draft, then fidelity-reviewer (once, on that diff), then answer every tech-lead and fidelity rec in `## Advice`, then ONE release-coordinator pass with unfenced `obeyed-check … implemented:` lines.
Where possible, answer the release-coordinator's own recs with `deferred:` (path alone) so they need no second judging pass. If one is answered `obeyed:`, a narrow fidelity pass judges it, because the release-coordinator cannot judge its own recs.

rec 6 — Record every handoff from the handback text, never from a raw `.output` file (F120). Commit the report only after the founder's `vajra approve 200 --close`.
Before close, check that `.ai/handoffs/session-200-{tech-lead,fidelity-reviewer,release-coordinator}.md` all exist.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (6597 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
