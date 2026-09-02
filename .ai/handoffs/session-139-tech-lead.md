---
role: tech-lead
session: 139
agent: claude-code-subagent (verified: toolu_01V1oCg4tS296S7VFP5u2JNS)
source-sha: ad1d4280510ba0461bacdb7913d5aff66d2a94a309bbe6060b60f8cf4298b51a
captured: 2026-09-02T04:56:17Z
cost_usd: null
---

# Tech-lead handoff — session 139

## Crew decision — Vajra session 139

A PHASE-1 CODE session that adds one mechanical `check_required_crew` gate to `verify-closeout.sh`, mirroring the two sibling checks already in the file, plus a falsifiability fixture and the self-binding proof that S139's own close passes the new gate. On a $20/month plan where S134 hit the 19.2M raw-token cap on three BROAD dispatches, I mark exactly three roles `required` — the same shape S135 (the session that built this very gate) ran and closed under: design-advisor (design-significant is declared), implementation-advisor (the independent judge of the obeyed dispositions), and fidelity-reviewer (mandatory at close, S131). The other six are deferred on money, not worth — each is already produced by the session's own `--advance` close-path gate, so a paid dispatch buys spend and no new evidence. Every required role's handoff must land this session because S139's OWN close now runs `check_required_crew` — that is criterion 3, the self-binding test.

crew researcher — deferred-budget — budget: 150000 tokens — The mechanism is a verbatim mirror of `check_obeyed_judgments` calling a `vajra next --check-*` binary gate that already exists (`crew_gate`, S135); there is no new external surface, API, or prior art to survey. A dispatch adds ~150K raw tokens and zero new evidence; on a $20 plan (19.2M cap, hit mid-session at S134's three broad dispatches) the three required roles already consume the affordable envelope, so this waits on cost, not on worth.

crew requirements-analyst — deferred-budget — budget: 150000 tokens — The WHAT is fixed and narrow — five EARS-style acceptance criteria already in the prompt and enforced live by the Analyst `--advance` gate. A separate paid dispatch (~150K raw) duplicates the session's own gate with no new artifact; deferred so the three required dispatches fit under the monthly cap S134 exhausted.

crew design-advisor — required — budget: 200000 tokens — The prompt declares `design-significant: yes` (this changes WHERE the crew binding is enforced, adding it to the close path CLAUDE.md depends on), so the S133 mandate binds: either a real design-advisor handoff or a recorded skip must satisfy `check_design_advisor_mandate`. A real dispatch is the on-message choice for the session that makes `required` bind — it needs an independent look at the mirror choice (obeyed-style header vs design-mandate-style), where `check_required_crew` inserts into `main()`'s check list, and the fail-closed ordering. Brief is named files only (`scripts/verify-closeout.sh` §check_obeyed_judgments/§check_design_advisor_mandate, `src/crew/mod.rs`, the prompt); S135's design-advisor came in ~155K raw on such a brief, so ~200K.

crew plan-advisor — deferred-budget — budget: 150000 tokens — The HOW is a four-step ordered `## Plan` in the prompt, each step citing the acceptance criteria it covers, and enforced live by the Planner `--check-plan` gate. A paid dispatch (~150K raw) buys no evidence the gate does not already produce; on the $20 cap it is deferred behind the three required roles, arithmetic not worth.

crew implementation-advisor — required — budget: 300000 tokens — If the design-advisor makes recommendations, the session must answer them in `## Advice`, and any `obeyed:` disposition must carry an INDEPENDENT `obeyed-check` — which `check_obeyed_judgments` binds on at this very close. Vajra refuses a self-graded verdict, so the judge may not be the design-advisor. That independent judgment is load-bearing provenance work this session; brief is narrow (the design handoff + the closing diff), so ~300K raw — the same figure S135 held it to.

crew qa-specialist — deferred-budget — budget: 150000 tokens — The QA station re-runs `verify-session-139.sh` LIVE as a blocking close-gate (S69, acceptance 5); the executable evidence is produced by the session's own `--advance` QA gate, not by a paid dispatch. A separate ~150K-raw run reproduces what the script already proves; deferred on the cap.

crew demo-producer — deferred-budget — budget: 150000 tokens — `demo-session-139.sh` (the four sprint markers, acceptance 5) and the Demo-er `--advance` gate already produce the sprint demo; a paid dispatch (~150K raw) adds no artifact the script does not. Deferred so the three required roles stay under the affordable share of the 19.2M monthly envelope.

crew fidelity-reviewer — required — budget: 400000 tokens — A cold, independent adversarial review of the finished delivery is MANDATORY at close (S131), and this session ships real code with a gate that must bind on itself — exactly the class of change that has slipped through green before (S138). Required. Brief is the prompt plus the attested closing diff (`--inputs-sha 139`), so ~400K raw — tight, not the millions a whole-repo read would cost. Note the disclosed out-of-scope limit: the review's OWN self-certification (a well-formed review file passes `check_fidelity_review` regardless of author, S138B) is NOT this session's problem to solve.

crew release-coordinator — deferred-budget — budget: 150000 tokens — The ship-gate (S72 Releaser) is an `--advance` close-path gate, not a paid dispatch; PR mechanics are the session's own closeout (branch, `VAJRA_ALLOW_COMMIT=139`, pre-merge full verify, S83). A ~150K-raw dispatch doubles nothing but spend; deferred with the arithmetic, since three required dispatches already fill the affordable share of the cap.

rec 1 — Run exactly three paid dispatches this session: design-advisor, implementation-advisor, fidelity-reviewer. This is the affordable envelope after S134 hit the 19.2M cap on three broad dispatches, and it is the same crew S135 (the session that built `crew_gate`) closed under. Every one of the three must produce a real governed handoff — S139's own close runs `check_required_crew`, so a missing required handoff blocks the close (criterion 3, the whole point).

rec 2 — Keep every dispatch brief to NAMED FILES, never "read the repo" (S134; $20/mo). For design-advisor and implementation-advisor: `scripts/verify-closeout.sh` (only `check_obeyed_judgments` and `check_design_advisor_mandate`), `src/crew/mod.rs`, and the prompt. For fidelity-reviewer: the prompt plus the attested closing diff (`vajra next --inputs-sha 139`), not the tree. Hold all three to the ~155K-raw order of magnitude S135's named-file dispatches hit.

rec 3 — Answer all six `deferred-budget` lines in `## Advice` as `deferred:` with the money arithmetic, not `refused:`. These roles are deferred on cost this session; the phase-2 worth judgement is not granted yet (phase 1 has no off switch — `src/crew/mod.rs` refuses `not-needed`). The three `required` lines are dispositions the session satisfies by DISPATCHING, not by answering.

rec 4 — Have implementation-advisor (not design-advisor) record the `obeyed-check` for every `obeyed:` disposition the session enters against a design-advisor recommendation. `check_obeyed_judgments` binds at this close and Vajra refuses a self-graded verdict; an unjudged or self-graded `obeyed:` blocks the close. A reasoned `refused:` or `deferred:` needs no independent judge, so only actually-obeyed recs pull in the implementation-advisor's judgment.

rec 5 — Make the gate BIND ON S139 ITSELF and make the fixture fail for the RIGHT reason. Per acceptance 3, S139's own `verify-closeout.sh` must pass `check_required_crew` with this tech-lead handoff plus the three required handoffs on disk; per acceptance 2 (S122 bar), the falsifiability fixture must go RED specifically because a required-role handoff is absent and GREEN once present, with the positive control asserting a clean exit 0 (S134 bar).

## Handoff Delta
- `+` new: first tech-lead handoff for this session (7762 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
