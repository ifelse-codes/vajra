---
role: tech-lead
session: 168
agent: claude-code-subagent (verified: toolu_011qmvhc4eFCac9SVzjJf8Yo)
source-sha: 99ccf94528ceba9f89cc7aa1e5e39b0b000cbec84af3df379bbc0edd95179e40
captured: 2026-09-14T13:19:48Z
cost_usd: null
---

# Tech-lead handoff — session 168

# Tech-lead handoff: session 168

**Brief:** Session 168 is a CODE session to finish the demo work. `dk_check` must run a real command. Vajra fills in the demo's numbers itself. The Demo-er gate checks that the demo reached `demo:complete` and that its `demo:fact` lines match what Vajra works out at close. Then vajractl 0.2.0 ships on the founder's go. There is a ~2h cap and $0 of paid runs.

The crew is three required roles, the same three the brief names. The other six are deferred on cost. That is a money call, not a judgement that they are not needed.

**About the format:** you asked for required / optional / not-needed. This gate accepts only `required` or `deferred-budget`, and it refuses `optional` and `not-needed`. So each "weigh it" role below is marked `deferred-budget` with the cost reasoning.

**About budgets:** every budget is an instruction the role is trusted to follow. Vajra cannot stop a role that runs over.

crew design-advisor — required — budget: 120000 tokens — the prompt says design-significant: yes, and the AC5 open question (how the gate knows a demo is built on the kit, and whether `complete`/`fact` join `demo.required_elements` when CONSTRAINTS.yaml is never synced) must be decided on the record before step 2
crew demo-producer — required — budget: 80000 tokens — AC10 requires a real dispatch on this session's demo; its S167 brief was never run, and S167's tech-lead deferred it to exactly this session
crew fidelity-reviewer — required — budget: 300000 tokens — a cold review before merge across 14 criteria; the gate change affects every Vajra project, and AC1/AC4/AC13 are the places a green could be faked or a release marked done without shipping
crew implementation-advisor — deferred-budget — budget: 100000 tokens — the three required roles already come to ~500k; S134 measured ~6M raw tokens per broad dispatch and 19.2M hit the monthly cap; the recursion guard and the fact comparison are already acceptance criteria with required tests (AC2, AC4), which the fidelity review grades
crew qa-specialist — deferred-budget — budget: 80000 tokens — same ~500k already committed; AC12 requires every verify check to run the real binary and name what it catches, scaffold-drift.sh already scans for hollow greps, and the cold review checks it again
crew release-coordinator — deferred-budget — budget: 80000 tokens — same ~500k already committed; the S167 release-coordinator handoff already wrote the order for this exact 0.2.0 release (recs 1–5), plan step 11 cites it, and S168 does not change how releasing works
crew researcher — deferred-budget — budget: 40000 tokens — same ~500k already committed; the brief names every file and line to change, so a research pass would repeat what is already known
crew requirements-analyst — deferred-budget — budget: 40000 tokens — same ~500k already committed; the spec is founder-approved and has 14 testable criteria
crew plan-advisor — deferred-budget — budget: 40000 tokens — same ~500k already committed; the 11-step plan covers every criterion with `covers:` markers

Recommendations:
1. rec 1 — Give design-advisor only the AC5 question plus DECISION-008, DECISION-009, the CONSTRAINTS.yaml `demo` block and `demo_gate_with` in src/demoer/mod.rs, and ask it to rule on the opt-out hole.
   - **The hole:** if a demo counts as "built on the kit" only when it prints a marker or sources the kit, a faker can skip that step. The demo then drops back to the old four-marker rule and fakes a PASS again.
   - **What to ask:** is the warning that names the downgrade enough, or must a demo that sources the kit be unable to skip the new checks?
2. rec 2 — Dispatch demo-producer after step 6 updates its brief and a first draft of `scripts/demo-session-168.sh` exists. Point it at three files only: the template, `demo-kit.sh`, and the draft. Answer its recommendations in `## Advice` before the cold review.
3. rec 3 — Give fidelity-reviewer the prompt, the diff and `scripts/verify-session-168.sh`, and ask it to look hardest at three criteria:
   - **AC1:** is a bare PASS really refused?
   - **AC4:** do the fixtures fail for the right reason, and can the fallback to the old rule be used to dodge the new checks?
   - **AC13:** is the release graded NOT-BUILT unless it is live?

   Commit every handoff before computing `--inputs-sha`. Run `verify-closeout.sh` on this branch before merge.
4. rec 4 — Because release-coordinator is deferred, copy the S167 release-coordinator recs 1–5 into step 11, updated for v0.2.0 and the session-168 branch, and answer each one in `## Advice`. The five recs are:
   - a separate PR for the version bump, with the tag on that merge
   - no leftover local branches that could hide an unmerged deletion
   - `VAJRA_SMOKE_RELEASE_TAG=v0.2.0` and `VAJRA_SMOKE_FORMULA` pointed at the tap's formula
   - a hand check that `demo-kit.sh` is scaffolded from the published crate
   - `cargo publish` typed by the founder only
5. rec 5 — If the ~2h cap hits, cut the release (step 11) first, never the gate change. Grade AC13 NOT-BUILT with the reason, and name the release in the summary as the next candidate.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (5210 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
