# Session 68 — The Coder handoff (pipeline station, the governed CODE stage) — CODE

> **Status:** APPROVED (founder pick A at S67 close; standing "all approved"). **Type: CODE.** One story.
> Branch `session-68-<slug>` from `main`, new chat. Closes the pipeline's LAST station gap (S65-named).

## Goal
Add the pipeline's **Coder** — a governed CODE/execution gate on the session being CLOSED: it
**surfaces** the covered plan as the execution checklist and **enforces** that each plan step is
recorded as executed by a commit that **exists** (`step N — done: <sha>` in an `## Execution`
section inside the prompt), never doing the coding itself. The Analyst governs the WHAT, the
Architect the DESIGN, the Planner the HOW-plan; the Coder governs the DID — the execution trace
from plan to commits. Rides `vajra next` (no 8th command), owns the existing `.ai/` + `prompts/`
spine (no new store, no `execution.md`).

## Why this session
- **The last station.** S65 GT named DESIGN + CODE as the two missing stations; S67 shipped DESIGN.
  Today nothing checks that the covered plan was *executed* — a session can close with a green plan
  and commits that did something else entirely (fidelity catches the delivery; nothing traces steps→commits).
- **The move is proven, with the S67 lesson baked in.** Delta (S61), `covers:` (S64), and
  `design-significant:` (S67) all enforce a RECORDED marker; S67's cold review proved markers must be
  **existence-gated** — so a recorded `done: <sha>` only counts when the sha resolves in the repo
  (`git cat-file -e`), the git-verifiable mirror of the spine-existence check.

## Acceptance (testable — EARS-style; every criterion is cited by a `## Plan` step below)
1. **WHEN** `vajra next --exec NN` runs **THEN** it surfaces session NN's plan steps as the execution
   checklist with each step's recorded state (done `<sha>` / unrecorded) — the trace derives from the
   recorded contract, not thin air.
2. **WHEN** a plan step is recorded `done: <sha>` **THEN** the sha only counts if it EXISTS in the
   repo (`git cat-file -e`) — a made-up sha is classified unrecorded (the S67 existence lesson).
3. **WHEN** a session with a covered `## Plan` is CLOSED via `vajra next --advance` **AND** any plan
   step is unrecorded/fake-sha **THEN** the Coder gate BLOCKS at L2/L3 (exit non-zero), advises at
   L1, and honors `VAJRA_SKIP_CODER_GATE=1` alone (distinct from the other stages' overrides).
4. **WHEN** a prompt has no `## Plan` or no `## Execution` section (legacy) **THEN** the gate WARNS
   at most — backward-compatible, mirroring the Analyst/Planner/Architect stance.
5. **WHEN** `scripts/verify-session-68.sh` runs **THEN** it proves surface + block-unrecorded +
   block-fake-sha + pass-recorded + advance-wiring in a temp git repo; exit 0.

## Design (the Architect gate — recorded rationale)
- design-significant: yes — new module `src/coder/` + new `vajra next --exec/--check-exec` surface
- Fourth application of the pipeline's "enforce a RECORDED thing" shape (DECISION-001's governed
  stations; DECISION-002's evidence-over-claim posture): the execution trace is a recorded
  `done: <sha>` marker, existence-gated against git the way S67 gates citations against the spine —
  a recorded claim must name a thing that exists. Rides `vajra next` as a sibling of `planner`/
  `architect` per ADR-0002's thin-CLI module layout — no 8th command, no new store (the prompt IS
  the execution record; git IS the evidence), no new dependency. The gate binds on the CLOSING
  session (like the S62 Options gate), not the advancing-into one — execution happens during the
  session being closed.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. New `src/coder/mod.rs` (registered in `lib.rs`): parse the prompt's `## Execution` records
   (`step N — done: <sha>`), verify each sha via `git cat-file -e`, classify
   `ExecState{NoPlan, Unrecorded(Vec<u32>), Recorded}`; legacy prompts degrade to WARN. covers: 1, 2, 4
2. CLI in `src/cli/next.rs`: `vajra next --exec NN` (surface the checklist) · `--check-exec NN`
   (gate, exit 1) · wire into `--advance` on the CLOSING session with the `VAJRA_SKIP_CODER_GATE=1`
   override. covers: 1, 3
3. The Analyst `PROMPT_TEMPLATE` gains a placeholder `## Execution` (symmetric with Delta/Plan/
   Design placeholders) so a fresh prompt records the contract shape. covers: 4
4. `scripts/verify-session-68.sh` + `scripts/demo-session-68.sh` proving all behaviors E2E in a
   temp git repo (real commits, real + fake shas). covers: 5

## Guardrails
- **One story.** New `src/coder/mod.rs` + `src/cli/next.rs` + `src/analyst/mod.rs` (template) +
  `src/lib.rs` + verify/demo. Max 3 files per atomic commit. **No 8th command** (rides `vajra next`).
  No new dependency. No second store (no `execution.md`, no `runs/`).
- **Surface + enforce, never author.** The binary cannot code and cannot judge that a commit
  *semantically* executes a step; it enforces that a recorded step→commit mapping exists and the
  commits are real. Name this as the fakest green in the summary (an author can `done:` any real
  sha — form + existence, not semantics).
- Fidelity review (DECISION-002): independent cold pass fed only this prompt + the delivery diff.
  Attested; two-pass if the first finds a closable hole (S67 precedent).

## Delta (vs ROADMAP — OpenSpec markers)
- `+` Pipeline gains station CODE — the Coder gate (surface the plan checklist + enforce a recorded,
  existence-gated step→commit execution trace).
- `~` The pipeline goes from 4 governed stations (WHAT · DESIGN · HOW-plan · REVIEW) to the full 5
  (adds DID/CODE) — the station spine the vision names is complete.
- `-` Retires the S65 "governed CODE handoff is unbuilt" gap (the last station gap).

## Deliverable
- `src/coder/mod.rs` + `src/cli/next.rs` + `src/analyst/mod.rs` + `src/lib.rs` +
  `scripts/verify-session-68.sh` (green) + `scripts/demo-session-68.sh` + `sessions/session-68-summary.md`
  + `sessions/session-68-review.md` (independent ACCEPT, attested).
- Carries forward: **S69 candidates** — fix/retire compression 0-fold · semantic-check hardening
  (one gate past its form floor) · receipt/pricing polish (real fable-5 price). **S70 = mandatory NO-CODE GT.**
