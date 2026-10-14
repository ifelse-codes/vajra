---
role: tech-lead
session: 197
agent: claude-code-subagent (verified: toolu_01UMiBVf3sCCA7jdrpwHx3eC; text-sha: c68dd5095d4b41d3505bf293472e6a0d25828c1ac93102e852537b624372a28b)
source-sha: e6587e6449ea658f81860982f8f15daa74a93c0f68b7579dac5d4578c0bd552d
captured: 2026-10-14T16:47:51Z
cost_usd: null
---

# Tech-lead handoff — session 197

Tech-lead brief: Session 197

Session 197 is a CODE session with one story: the known-bug list. F125 and N17 come first, then F116, F118, F119 and N10. The prompt says `design-significant: yes` because F125 changes a guard and the approvals contract (DECISION-011). So the design-advisor is really needed this time, not just a skip line, and it should run before any code. The other four fixes are small and follow existing records. Three roles are required: the design-advisor (needed now), plus the two the close always needs. The rest are deferred for money reasons. The prompt's own split rule stays: if F125's design grows, move F118 to a later session.

What I read:
- /Users/suman/playground/vajra/prompts/197-task-known-bugs.md (in full)
- /Users/suman/playground/vajra/.ai/handoffs/session-196-tech-lead.md and /Users/suman/playground/vajra/.ai/handoffs/session-195-tech-lead.md (the pattern)
- /Users/suman/playground/vajra/src/mandate/mod.rs `mandate_gate` (line 284). The design-advisor has been mandatory since S133.
- /Users/suman/playground/vajra/src/crew/mod.rs lines 373-394. Every role marked `required` here must leave a real, verified handoff. A skip line does not count for a required role.
- /Users/suman/playground/vajra/scripts/hook-pre-bash.sh lines 43-69. The opening is `*-closeout|*-enforcement) GT=0`. A branch with no `session-NN` also leaves GT at 0, which is N17.

How I sized the budgets:
- S196 used fidelity-reviewer 1.2M + release-coordinator 0.4M and closed green. I keep both numbers.
- I add a narrow design-advisor at 0.3M: F125/N17 only, about 5 named files, plus a one-line answer on the other four fixes.
- S134's three broad dispatches used 19.2M raw tokens and hit the monthly limit.
- Founder rulings: one cold reviewer, one judge, small scope, less ceremony.

Required crew: design-advisor 0.3M + fidelity-reviewer 1.2M + release-coordinator 0.4M, about 1.9M in total.

These budgets are written instructions I am trusting each role to follow. Vajra cannot stop a role partway through a run, so they are not hard limits.

crew researcher — deferred-budget — budget: 200000 tokens — Every bug already has its evidence in ROADMAP's known-bugs list and in the S195 ground truth. ~0.2M would take the crew from ~1.9M to ~2.1M to find things that are already written down. S134: 19.2M for three broad dispatches hit the cap.
crew requirements-analyst — deferred-budget — budget: 150000 tokens — The founder picked this list. AC1–AC6 already give one real-run check per bug. ~0.15M (~1.9M to ~2.05M) would only restate it.
crew design-advisor — required — budget: 300000 tokens — `design-significant: yes`. Brief: F125 + N17 only. Read scripts/hook-pre-bash.sh, scripts/hook-pre-write.sh (same opening), scripts/lib-ground-truth.sh, the approvals guard / `vajra approve` code, and DECISION-011 (S188 + S181 addenda). Weigh S195's pick (a founder `vajra approve NN --close` record) against "the ground-truth report is already committed", asking of each: can the agent type it? Say whether `*-enforcement` falls under the same fix. Write the DECISION-011 S197 addendum text. Give one line each on whether F116/F118/F119/N10 need more design than their existing records.
crew plan-advisor — deferred-budget — budget: 150000 tokens — The order is set by the prompt (F125 first, F118 is the one to split out), and the plan is five short fixes. ~0.15M (~1.9M to ~2.05M) adds nothing to that.
crew implementation-advisor — deferred-budget — budget: 400000 tokens — The traps are named in recs 4–6. ~0.4M (~1.9M to ~2.3M) would repeat them. Write a reasoned skip line for it.
crew qa-specialist — deferred-budget — budget: 400000 tokens — AC6 already requires real-run rows in scripts/verify-session-197.sh, red at eceb6d5, and the fidelity-reviewer runs them at both ends. ~0.4M (to ~2.3M) would do that a second time.
crew demo-producer — deferred-budget — budget: 200000 tokens — These are bug fixes that show up in the verify output and the summary. ~0.2M (to ~2.1M) would buy a demo nobody asked for.
crew fidelity-reviewer — required — budget: 1200000 tokens — One cold review, mandatory at close. Read only: the prompt (with `## Advice`), sessions/session-197-summary.md, the DECISION-011 S197 addendum and the branch diff. Run `bash scripts/verify-session-197.sh` at eceb6d5 and at the tip, and check each row goes red there for its own bug's reason. Run the full `cargo test` once. Check that AC1's run happens in a temp `vajra init` project and that the scaffold copies carry the fix. Check AC5's negative case. Also judge any recs the release-coordinator makes.
crew release-coordinator — required — budget: 400000 tokens — The one judge of every `obeyed:` answer, in a single pass. Read only `## Advice` and the commit each answer names. Write the judge lines unfenced, in the `obeyed-check … implemented:` shape.

rec 1 — Dispatch the design-advisor on F125 + N17 before writing any F125 code, and commit the DECISION-011 S197 addendum before the fix.
Why: `design-significant: yes`. Without a real handoff for a required role, the crew gate blocks the close.

rec 2 — Use the existing `vajra approve` record and its before/after guard to unlock the `-closeout` branch. Do not build a new mechanism.
Why: S181/S188 already gave the founder controls the agent cannot type. Committed report text, by contrast, is something the agent types itself.

rec 3 — Fix both hooks (hook-pre-bash.sh and hook-pre-write.sh) and the copies `vajra init` / `--sync-fleet` scaffold. Prove AC1 in a temp `vajra init` project, not on Vajra itself.
Why: if only Vajra's own copy is fixed, every user project still has the hole.

rec 4 — Make each verify row a real run of the built binary. Confirm it fails at eceb6d5 with that bug's own message. AC5 needs both halves: Vajra passes, and an unmarked hollow grep still fails check 6.
Why: S122, a fixture that goes red for the wrong reason proves nothing.

rec 5 — Commit `.ai/approvals/session-197.json` (untracked right now) with the session's work, and use it as AC2's live case: check `--steps` before and after that commit.
Why: this is F116 happening on this very branch.

rec 6 — Run the full `cargo test` before pushing. Then push in this order: stamp, close, push, through the S196 push belt. Record whether the belt let a real GREEN push through.
Why: S187 (CI caught what the close skips), and the S196 review's fakest green.

rec 7 — If the session runs past about 1h on F125, move F118 to a later session in writing. Any new bug found on the way gets filed, not fixed.
Why: the prompt's own guardrails and the founder's "small scope".

rec 8 — Run the crew in this order: design-advisor, then the build, then one fidelity-reviewer (on a REJECT, one fresh pass), then one release-coordinator. Keep `## Delta` above `## Advice`. Record handoffs from the handback text. Write a reasoned skip line for each deferred role.
Why: one review, one judge, F120, and S195's ordering lesson.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (7042 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
