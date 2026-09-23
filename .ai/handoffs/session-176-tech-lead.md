---
role: tech-lead
session: 176
agent: claude-code-subagent (verified: toolu_018R9v3mrK3XqgZZF8tDzAPg)
source-sha: 6f5d1c0dada61875e8126733d6f14f5479f76506d49e30ca48955264ea2e1783
captured: 2026-09-23T16:39:40Z
cost_usd: null
---

# Tech-lead handoff — session 176

# Tech-lead crew dispatch — session 176

**The session:** one small Rust fix in `src/planner/mod.rs`. `plan_coverage_against` (lines 209–259) checks only criteria→citations, never citations→criteria (does every `covers: N` exist in `## Acceptance`?). When rudra S08's agent wiped its own Acceptance section, the Planner said READY — zero criteria means nothing is "missing". The fix is a new blocking variant. Compiler-enforced consumers (exhaustive matches): `src/stations/mod.rs:245–249`, `plan_gate` (planner 302–313), `format_plan_checklist` (planner 371–379). **`PlanState::blocks()` (61–63) is NOT exhaustive** — a `matches!` list; a new variant omitted there compiles and silently doesn't block. `cli/next.rs:512/524/1871` go through `plan_gate` — fine.

**The real risk is false blocks on legitimate prompts, not the fix itself.** This is a guard change (S173 needed nine passes). At-risk: older Vajra prompts whose Acceptance uses a shape the parser doesn't read as numbered (`AC1a`, bullets, wrapped) but whose plan cites `covers: N`; plan prose mentioning `covers:` on a continuation line (line 235 scans continuations). All 9 rudra prompts use numbered `## Acceptance (testable, EARS-style)`, so the risk is concentrated in the 176 Vajra prompts.

**Gap the fix does not close:** F70's own row says no close check re-runs the Planner. After this fix `--check-plan`/`--steps` say NOT READY, but a mid-session self-wipe is still only caught if someone looks. A close re-run = a new gate on Vajra's own paperwork → needs the founder's explicit yes (Guardrails). Record, don't build.

**Budgets are instructions trusted per role**, not a fence Vajra enforces mid-flight.

crew researcher — deferred-budget — budget: 60000 tokens — Money: the two required roles already sum to ~0.85M; S134 hit the monthly cap at 19.2M raw from three broad dispatches, so every added dispatch is real spend. The facts are already on the page (F70 row, planner/mod.rs:209–259, the consumer list above); research would re-derive them for ~0.06M more.
crew requirements-analyst — deferred-budget — budget: 60000 tokens — Money: ~0.91M vs ~0.85M required. The founder's "FIX" plus Acceptance 1–5 are already specific and testable; a second pass costs about what reading them costs.
crew design-advisor — deferred-budget — budget: 100000 tokens — Money: ~0.95M vs ~0.85M required. One enum variant following the existing `Uncovered(Vec<u32>)` pattern, no new component → likely design-significant: no. The one real design question (which state wins when criteria are missing AND citations dangle) is written as rec 3.
crew plan-advisor — deferred-budget — budget: 60000 tokens — Money: ~0.91M vs ~0.85M required. Deliverables 1–3 and criteria 1–5 map almost one-to-one onto 3–4 plan steps.
crew implementation-advisor — deferred-budget — budget: 120000 tokens — Money: ~0.97M vs ~0.85M required. ~30 lines + tests; its one real trap (the non-exhaustive `blocks()`) is written as rec 2; the regression risk is better settled by qa-specialist running old vs new than by an advisor reading code.
crew qa-specialist — required — budget: 300000 tokens — A guard change; S173's lesson is "no regression" must be an independent listed-set old-vs-new comparison. Build before/after, run `vajra next --check-plan NN` over every `prompts/*-task-*.md` here and in `~/playground/rudra/prompts` (01–09), list every flipped verdict with its reason; re-create rudra S08's wipe (old READY, new NOT READY); run the three rec-4 edge fixtures. Read only planner/mod.rs, stations/mod.rs and the two prompt dirs.
crew demo-producer — deferred-budget — budget: 100000 tokens — Money: ~0.95M vs ~0.85M required. `scripts/demo-session-176.sh` is already an author deliverable; the re-created S08 before/after replay IS the demo.
crew fidelity-reviewer — required — budget: 550000 tokens — Mandatory every session (DECISION-007 S131 addendum) and this is a blocking-check change of the high-scrutiny class. Fed the prompt, the diff, and qa-specialist's flipped-verdict list; room for up to two passes on a small diff.
crew release-coordinator — deferred-budget — budget: 60000 tokens — Money: ~0.91M vs ~0.85M required. Push + PR; founder merges by hand; the release path is unchanged and F71 (remote pruning) is parked.

rec 1 — Require only qa-specialist and fidelity-reviewer; defer the other seven on cost as reasoned above.
rec 2 — Add the new variant to `PlanState::blocks()` (planner/mod.rs:61–63) with a direct unit test; it is the one place the compiler won't catch the omission. Acceptance 5 also depends on the stations arm returning not-`passed`.
rec 3 — Decide and test which state wins when a plan both misses criteria and cites non-existent ones (criteria 1–5, plan cites 1,2,3,7). Recommend: dangling first, or one message naming both — dangling is the stronger brief-was-cut signal. Lock it with a test.
rec 4 — Seed three edge fixtures before claiming "no regression": (a) an `## Acceptance` heading in a non-numbered shape (bullets/`AC1`) with a plan citing `covers: 1`; (b) plan prose mentioning `covers:` on a continuation line; (c) no criteria and a plan citing nothing — must stay Covered (adds-only). If the sweep flips a real Vajra prompt of shape (a), fix the message or narrow the rule — never hide the prompt from the check (S173).
rec 5 — Record, do not build, the residual F70 gap in the findings table with a severity: nothing at close re-runs the Planner; a close re-run needs the founder's explicit yes.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (5608 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
