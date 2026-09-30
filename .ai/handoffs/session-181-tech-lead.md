---
role: tech-lead
session: 181
agent: claude-code-subagent (verified: toolu_01FKwnuQJ88H8BgvrQ4UF22N; text-sha: 54d4b7511d10c5cfbb6fc15825891aa8c3850c619b12ffb6526ede69cbd663de)
source-sha: c8d45a8080dc999e2e07a6baaa98dd56577f996e2db5999bb8cbd864b88d8952
captured: 2026-09-30T02:30:17Z
cost_usd: null
---

# Tech-lead handoff — session 181

In phase 1 the gate accepts only `required` or `deferred-budget`, so I used only those two. Each budget is an instruction I am trusting the role to follow. Vajra cannot stop a role mid-run when it passes its budget.

The money facts behind the deferrals:
- S134 measured about 6M raw tokens for each broadly-briefed dispatch.
- The monthly plan cap was hit in late September (F82).
- The founder asked for one independent review per session.
- The build (five parts plus a first cold review that REJECTed) is already committed, so the work-shaping roles have nothing left to shape.

Design-advisor versus a recorded reasoned skip. I chose a design-advisor, cheap and narrow. Parts 3–5 change close gates: `session_type` fails closed, `vajra approve` reads an approval record, and named waivers replace `VAJRA_CLOSEOUT_WAIVER=N`. The `## Design` section still says "to be decided by the design-advisor". A skip written now would rest on the main session's own say-so about gates it just built, and the first review already REJECTed this build once. A one-pass advisor that only settles `design-significant: yes` and names the ADR or DECISION each part deviates from is cheap and gives the reviewer something to grade against.

crew researcher — deferred-budget — budget: 150000 tokens — The build is committed and the evidence is already in `sessions/session-180-ground-truth.md`. A dispatch would stack about 0.15M on a capped plan (F82), and the one review slot goes to the fidelity-reviewer.
crew requirements-analyst — deferred-budget — budget: 100000 tokens — The acceptance criteria are already numbered and concrete, and the code exists. About 0.1M for a second look on a capped plan buys nothing the reviewer will not grade.
crew design-advisor — required — budget: 150000 tokens — Parts 3–5 change gates and the `## Design` marker is still open. Brief it on the S181 prompt and the ADR/DECISION records for the close gate, the approval gate and the waiver gate, and have it settle `design-significant` and name the record each part deviates from.
crew plan-advisor — deferred-budget — budget: 100000 tokens — The build is done, so a plan check now would only be retrospective. If the main session writes `## Plan` and `## Execution` with `covers:` markers from the commits, this costs nothing. About 0.1M is not worth it on a capped plan.
crew implementation-advisor — deferred-budget — budget: 250000 tokens — The code is committed and the first review's REJECT was fixed. A code-level dispatch reading the shared helper and 6 sites would cost about 0.25M, and the fidelity-reviewer covers the same ground.
crew qa-specialist — deferred-budget — budget: 200000 tokens — The verify script already runs 13 real-run checks and `verify-closeout.sh` must exit 0 on the branch. A second checker costs about 0.2M and breaks the one-review rule.
crew demo-producer — deferred-budget — budget: 80000 tokens — The demo script is already committed (f43184e). About 0.08M to produce a demo is not affordable with one review slot.
crew fidelity-reviewer — required — budget: 400000 tokens — The mandatory fresh cold pass over the fixed build, because code after an ACCEPT or REJECT needs a new review (F81). Narrow brief: the S181 prompt, `git diff main...HEAD` over the named files, and the output of the real-run verify checks. No whole-repo read.
crew release-coordinator — deferred-budget — budget: 80000 tokens — The founder hand-types the merge and does not want publishing this session. About 0.08M for a release pass is not affordable.

rec 1 — Before dispatching the design-advisor, write a one-line list per part (3, 4, 5) naming the existing ADR or DECISION it changes, and hand the advisor that list plus the prompt only. Tell it the 150k figure is an instruction, not a cap.
A narrow brief is what keeps this dispatch cheap. If the main session cannot name a record for a part, the advisor's job is to say so.

rec 2 — Fill `## Plan` and `## Execution` from the existing commits with `covers:` and `step N — done: <sha>` markers, without a plan-advisor. Use the real shas (for example f43184e, 07130cd, 2fbc2cf).
The coder gate checks that each sha exists. The plan then costs no dispatch.

rec 3 — Give the fidelity-reviewer the disclosed limits to grade: Part 4 is bar-raising, not tamper-proof, and Part 5 keeps `VAJRA_CLOSEOUT_WAIVER=N` with a warning. Also give it the Part 2 proof that S181 is not ground truth, S185 is, and `ground_truth_next_session: 180` is unchanged.
The first REJECT came from claims that outran the code. A written list of what is and is not claimed keeps this pass to one round.

rec 4 — Run `scripts/verify-closeout.sh` on the branch before the merge, and pass `--inputs-sha 181` when recording the review. Run any acceptance probes in a scratchpad repo, not in Vajra's own tree.
Once main absorbs the branch, the merge-base collapses (S83). The attestation gotcha from S69 applies.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (4990 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
