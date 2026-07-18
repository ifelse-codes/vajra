# Session 75 — Ground Truth (mandatory NO-CODE, every 5th; last = S70)

> **Status:** APPROVED (founder standing "all approved"; the 5th-session GT is mandatory —
> `NN % 5 == 0`). **Type is FIXED: NO-CODE ground-truth.** No source-code edits, no commits to
> `src/`/scripts, no PRs (hook-enforced; a `session-75-closeout` / `-enforcement` branch is the only
> code-exempt path, for authorized hardening). Lead lens = **A** (below); founder may re-aim to B or
> C in this chat with one line — but **all 9 `required_audits` run in full regardless of lens** (the
> lens is the lead question, not a scope cut).

## Goal
Run the mandatory 5th-session ground-truth over the S71→S74 arc (Demo-er · Releaser · close-path
reliability · the payload counter). Answer all 9 audits — **including the new
`pipeline_advance_check`, whose first real reading is this GT's headline** — judge whether the
pipeline is genuinely advancing or the machinery is outgrowing the payload, and hand the founder
exactly 3 ranked S76 CODE candidates. No code.

## Why this session
`NN % 5 == 0` → mandatory audit. Catch **both** classes of drift (CONSTRAINTS `drift_axes`):
1. **Direction drift** — are we building the right thing? (`vision_alignment`, `roadmap_alignment`)
2. **Discipline drift** — did we honor the contract, and does the contract still serve the vision?
   (`state_drift`, `knowledge_staleness`, `constraint_violation_review`, `constitution_review`,
   `cost_review`, `dogfood_check`, `pipeline_advance_check`)
**Meta-check:** did this audit's own mechanism miss a kind of drift? (The trap S20 caught — and the
recurring one: for four GTs the payload counter was *recommended and unbuilt*; S74 finally built it,
so the meta-gap should now CLOSE. Verify that it actually does.)

## Lead lens — A: the crew is complete + reliable + now MEASURED. Does the payload move?
The core 8-station crew is built (S54→S72), the close path is reliable (S73), and S74 built the
instrument the last four GTs kept asking for: `vajra next --stations NN`, a derived K-of-8.
Interrogate honestly, using the counter's OWN first reading:
- **Run `vajra next --stations NN` for every session that has a prompt (S54→S74)** and read the
  SHAPE, not just the numbers. Is the pipeline advancing (stations demonstrably passed climbing as
  the crew was built), or does the payload sit flat while the machinery grew? Name any station
  ABSENT across many sessions — that is a systemic gap, not per-session noise.
- **The self-granted-jurisdiction / form-floor debt class is now SEVEN+ gates wide** (Options ·
  Planner digit-tag · Architect form floor · Coder deletion-dodge · QA hollow-green · Demo-er
  marker-stuffing · Releaser refs-gone) **plus the S74 static-QA/Demo counter read** (a `--stations`
  QA/Demo PASS is gate-*eligible*, not live-green — disclosed). Is the honest-floor posture still
  honest *enough*, or is measured-breadth now papering over unhardened depth?
- **Dogfood is PARKED by founder call (S73), last paid run S63** — by S75 that is twelve sessions
  back. Per the dogfood questions: no run = no "experience" verdict; report the parked-decision's
  AGE against the decision, do not treat it as drift, and do not guess a satisfaction verdict.

## The audits (run every one — answer its question list in CONSTRAINTS `#ground_truth`)
- `vision_alignment` · `roadmap_alignment` — is the north-star still right; with the crew complete +
  measured, is the highest-leverage S76 hardening depth, dogfooding, or something the counter surfaces?
- `state_drift` — does `.ai/STATE.md` match reality after S74 (8-station crew · the payload counter ·
  S74 PR)?
- `knowledge_staleness` — §6 changelog bloat (left flat at S65+S70) and the carried readable-roadmap
  one-pager: does the counter reduce or increase the founder's notebook-wall pain? Re-decide the one-pager.
- `constraint_violation_review` · `constitution_review` — any rule now blocking the vision?
  (meta-check; include: is "one story per session" still right now the crew is complete?)
- `cost_review` + `dogfood_check` — cost ledger honest? Dogfood parked; state the parked-decision's age.
- **`pipeline_advance_check` (NEW, S74) — the headline.** Read `--stations` across S54→S74; state
  whether the pipeline demonstrably advanced, from the counter's evidence, never guessed.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** the GT runs **THEN** all 9 `required_audits` are answered with a per-audit 🟢/🟡/🔴 +
   the meta-check, written to `sessions/session-75-ground-truth.md` (a non-author can read the
   verdict table).
2. **WHEN** the audits complete **THEN** the report states a verdict on lead lens A (does the payload
   move?) and lists **exactly 3 ranked S76 CODE candidates** (A/B/C, each with why + risk).
3. **The headline read is measured, not guessed** — the `pipeline_advance_check` cites the actual
   `vajra next --stations NN` output for the sessions read, and `dogfood_check` states the parked
   decision's age from the cost ledger — never estimated.

## Design (the Architect gate — recorded rationale)
- design-significant: no — NO-CODE ground-truth: audits + a report, no interface, module, or
  behavior change.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Run all 9 `required_audits` + the meta-check, recording a 🟢/🟡/🔴 per audit and the evidence
   (SESSION, tests, ledger head, cost ledger, verify runs) into the GT report. covers: 1, 3
2. Run `vajra next --stations NN` across S54→S74, read the shape, and write the
   `pipeline_advance_check` verdict from that output — the headline, measured. covers: 3
3. Write the lens-A verdict and exactly 3 ranked S76 CODE candidates (A/B/C, why + risk); founder
   signs off before code resumes. covers: 1, 2

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>

## Guardrails
- **NO CODE.** No `src/`/scripts edits, no commits outside a `-closeout`/`-enforcement` branch,
  no PRs. (The QA + Demo-er gates will WARN at S75's close — no `verify-session-75.sh` / demo by
  design; that firing is itself evidence the NO-CODE path behaves as specified.)
- Own the `.ai/` spine — no second store, no unapproved 8th command. Darshan every human reply ·
  Varta live.
- The lens is the lead question, not a scope cut — every audit runs in full.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` A seventh ground-truth (S75) auditing the S71→S74 arc (Demo-er · Releaser · close-path
  reliability · the payload counter), with the first real `pipeline_advance_check` reading.
- `~` Shifts the lead question from S70's "is the crew deep enough?" to "the crew is complete and
  now MEASURED — does the payload actually move, or did the machinery outgrow it?"
- `-` Retires the four-GT meta-gap "no audit measures whether the pipeline advances" — S74 built the
  counter and this GT wires it in; verify the gap is genuinely closed, not merely relabeled.

## Deliverable
- `sessions/session-75-ground-truth.md` — every audit answered, the meta-check, a verdict on lens A,
  and **3 ranked S76 CODE candidates** (standing, founder "let the GT decide": typed cannot-evaluate
  + depth hardening · paid dogfood ride-along [needs un-park] · whatever the counter reading surfaces;
  the GT ranks with evidence).
- **No** `verify-session-75.sh` / demo (NO-CODE). Closeout still runs `scripts/verify-closeout.sh`
  (exit 0).
