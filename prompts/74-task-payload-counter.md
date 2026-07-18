# Session 74 — The payload counter: measure whether the PIPELINE advances

> **Status:** DRAFT — recommended S74 pick (agent's call, pending founder confirmation at the S73
> board review). **Type: CODE.** The meta-gap named at S25, S60, S65, and S70 and STILL unbuilt:
> every gate measures whether the RAILS are followed (branch, files, tests-green, fidelity), but
> NOTHING measures whether the PIPELINE itself advances — how many governed stations a session
> actually moved a prompt through. A GT cannot answer "is the pipeline progressing?" because no
> number records it. S73 fixed the brakes, so the machinery is now trustworthy enough to instrument.

## Goal
Record, per session, how many of the 8 governed stations a prompt DEMONSTRABLY passed — derived
from evidence already in the repo (the prompt's filled marker sections + the gates that fired at
`--advance`), never a self-asserted digit. Surface it (`vajra next --stations NN`) and make it a
GT input, so "did the pipeline advance?" becomes a measured question. No new store, no 8th command.

design-significant: yes

## Acceptance (testable — every criterion is cited by a `## Plan` step)
1. **WHEN** `vajra next --stations NN` runs **THEN** it prints, per station (Analyst/Architect/
   Planner/Coder/QA/Demo-er/Releaser/Reviewer), PASSED / ABSENT derived from the SAME evidence the
   station gates use (a filled, non-placeholder marker section that its `--check-*` would accept),
   plus a count "K of 8" — read-only, nothing executes.
2. **WHEN** a station's evidence is a placeholder / missing **THEN** it counts ABSENT (never
   PASSED) — the count can only be earned by evidence a gate would accept, not by the section
   merely existing.
3. **WHEN** the count is derived **THEN** it reuses each station's existing classifier (no
   re-implementation of the checks; a station's rule and its counter must never disagree).
4. **WHEN** a GT runs **THEN** the station count for recent sessions is an available input
   (recorded where the GT reads it), so the pipeline-advance question is measured, not guessed —
   retiring the S25/S60/S65/S70 meta-gap.
5. **The fix is proven:** `scripts/verify-session-74.sh` (a fully-filled prompt counts 8/8; a
   placeholder-laden one counts low; the counter agrees with each `--check-*` verdict on the same
   fixture; no CLI/dep/store change) + `scripts/demo-session-74.sh` (four `demo:<element>` markers,
   before → after = "no number says whether the pipeline advances" vs "K-of-8, derived from gate
   evidence") + independent cold review + attestation (`--inputs-sha 74`).

## Design (the Architect gate — recorded rationale)
- design-significant: yes — introduces the first PIPELINE-level metric across all eight stations,
  the measurement `DECISION-001` implies but the roadmap never built. It must reuse each station's
  classifier (house rule: one source of truth per gate) so the counter can never drift from the
  gates — a counter that re-implements the checks would be a second, forgeable digit-tag (the S64
  Planner lesson). Cite an existing spine record; do not invent a new artifact.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. A `stations` module that, for session NN, calls each station's existing classifier over the
   repo and maps PASSED/ABSENT — no new checks. covers: 1, 3
2. `vajra next --stations NN` surfaces the per-station table + "K of 8" count, read-only. covers: 1, 2
3. Record the count where the GT reads it (the S30 dogfood_check pattern — a GT input, not a new
   store); wire the placeholder→ABSENT rule to the shared classifiers. covers: 2, 4
4. Prove it: `scripts/verify-session-74.sh` + `scripts/demo-session-74.sh` + cold review +
   attestation. covers: 4, 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>

## Guardrails
- **One story:** the pipeline-advance metric. No station-behavior changes, no gate-semantics
  changes, no compression work, no dogfood run.
- **Derive, never assert:** the count reuses the gates' own classifiers; a hand-typed or
  section-exists-only count is a REJECT-shaped outcome (the S64 digit-tag lesson).
- Max 3 files per commit · approval tokens before any commit · branch
  `session-74-payload-counter` · ~2h cap. **S75 = the next mandatory NO-CODE GT** (the one after).

## Delta (vs ROADMAP — OpenSpec markers)
- `+` A pipeline-advance metric (`--stations NN`, K-of-8) derived from gate evidence — the
  S25/S60/S65/S70 recommended-but-unbuilt counter, finally built.
- `-` Nothing removed; dogfood stays PARKED; the S73 typed-cannot-evaluate seam stays a candidate.

## Deliverable
- The `stations` module + `--stations` surface + GT-input wiring · `scripts/verify-session-74.sh` +
  `scripts/demo-session-74.sh` · `sessions/session-74-summary.md` + independent cold
  `sessions/session-74-review.md` (attested) · closeout `.ai/` sync + exactly 3 ranked S75-GT
  framing notes (S75 is a NO-CODE GT — the counter's first real reading is its headline).
