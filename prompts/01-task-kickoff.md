# Session 01 — first-session: first session

> **Status:** DRAFT — the Analyst gate (`vajra next --advance`) BLOCKS starting this session
> while DRAFT. Flip to `APPROVED` once the human signs off (an approval token recorded here,
> the same trust model as a commit-approval; tamper-evidence is the later cross-stage ledger).

## Type
- **CODE** | **NO-CODE**. Max 2 assumptions · 2 retries · ~2h · 1 story · new chat · approval
  token before any commit.

## Goal
first session

## Deliverables
- <artifact 1 — the thing that ships>
- <artifact 2>
- `scripts/verify-session-01.sh` (exits 0)
- `sessions/session-01-summary.md` + exactly 3 ranked next candidates

## Acceptance (what must be answered — testable, EARS-style)
1. <A criterion the verify script can assert green/red — WHEN <x> THEN <observable y>.>
2. <A criterion a non-author could check by running one command.>
3. <The honest verdict this session must state plainly.>

## Design (the Architect gate — record the decision, cite the ADR/DECISION it rests on)
- design-significant: <yes — new/changed interface, new module, or an ADR deviation | no — pure fix>
- <rationale — why this shape and not the alternative, citing the ADR/DECISION ids it rests on; the Architect gate BLOCKS a design-significant prompt until this is substantive>
- design-advisor: <skipped — why this session needs no design review | DELETE this line and dispatch the role instead>

## Plan (ordered steps — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)
1. <first ordered step — replace me; annotate which acceptance criteria it satisfies>
2. <next step — the Planner gate BLOCKS until every acceptance criterion above is covered>

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha — the real commit that landed this step; the Coder gate BLOCKS closing the session until every numbered plan step records a commit that EXISTS>

## Guardrails
- Slice to ONE story. Own the `.ai/` spine — no second store, no unapproved 8th command.
- Darshan every human reply · Varta against the live `.ai/`.
- <session-specific guardrail>

## Delta (vs ROADMAP — OpenSpec markers)
- `+` <what this session ADDS that did not exist>
- `~` <what it CHANGES about existing behaviour>
- `-` <what it REMOVES / retires / supersedes>
