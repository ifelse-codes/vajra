# Session 67 — The Architect stage (pipeline station, the DESIGN gate) — CODE

> **Status:** APPROVED (founder pick A at S66 close; standing "all approved"). **Type: CODE.** One story.
> Branch `session-67-<slug>` from `main`, new chat. Closes the pipeline's DESIGN gap (S64/S65 deferred).

## Goal
Add the pipeline's **Architect** — a governed DESIGN gate that runs on the accepted prompt: it
**surfaces** the design-significant surface a session touches (the relevant locked ADRs) and
**enforces** that a design-significant session records a real design rationale **before** the plan/code,
never authoring the design itself. The Analyst governs the **WHAT**, the Planner the **HOW-plan**; the
Architect governs the **DESIGN decision** that sits between them. Rides `vajra next` (no 8th command),
owns the existing `.ai/` + `docs/adr/` + `prompts/` spine (no new store, no `design.md`).

## Why this session
- **The pipeline's sharpest gap.** S65 GT: 3 real stations (WHAT · HOW-plan · REVIEW); the middle —
  DESIGN — is unbuilt. The Planner checks a plan covers the acceptance criteria, but nothing checks that
  a session which changes an interface / adds a module / deviates from a **locked ADR** recorded *why*.
- **Vajra already has the design record.** `docs/adr/` + `docs/decisions/` + the AGENTS.md ADR table are
  the design spine (ADR-0001…0005, DECISION-001…004). The Architect **enforces a recorded** design
  decision, the same "enforce a RECORDED thing" move S61 (Delta) and S64 (coverage) made — not a new artifact.

## Acceptance (testable — EARS-style; every criterion is cited by a `## Plan` step below)
1. **WHEN** `vajra next --design NN` runs on an accepted prompt **THEN** it surfaces the design context
   for that session — the locked ADRs/decisions relevant to the touched surface — as the checklist the
   design rationale must address (design derives from the recorded spine, not thin air).
2. **WHEN** a prompt is **design-significant** (declares new/changed interface, a new module, or an ADR
   deviation — detected from a recorded marker in the prompt, not guessed) **AND** carries no real
   `## Design` rationale (absent or placeholder) **THEN** `vajra next --check-design NN` BLOCKS (exit 1).
3. **WHEN** a design-significant prompt carries a substantive `## Design` rationale (non-placeholder,
   references the relevant ADR/decision) **THEN** `--check-design NN` PASSES (exit 0).
4. **WHEN** a prompt is not design-significant (a pure fix/no-interface-change) **THEN** the gate does not
   block — it WARNS at most (backward-compatible with legacy prompts, mirroring the Analyst/Planner stance).
5. **WHEN** the Architect gate is wired into `vajra next --advance` **THEN** it blocks a design-significant
   session with no recorded design at L2/L3, advises at L1, and honors a `VAJRA_SKIP_ARCHITECT_GATE=1`
   override distinct from the Analyst's and Planner's, so each stage overrides alone.
6. **WHEN** `scripts/verify-session-67.sh` runs **THEN** it proves surface + block-placeholder +
   pass-substantive + non-significant-warn + advance-wiring in a temp git repo; exit 0.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. New `src/architect/mod.rs` (registered in `lib.rs`): parse the prompt's design-significance marker +
   `## Design` rationale → `DesignState{NotSignificant, Missing, Placeholder, Substantive}`; surface the
   relevant ADRs from `docs/adr/` + `docs/decisions/`. covers: 1, 2, 3, 4
2. CLI in `src/cli/next.rs`: `vajra next --design NN` (surface) · `--check-design NN` (gate) · wire the
   gate into `--advance` with the `VAJRA_SKIP_ARCHITECT_GATE=1` override. covers: 2, 3, 5
3. The Analyst `PROMPT_TEMPLATE` gains a placeholder `## Design` (symmetric with the S61 Delta / S64 Plan
   placeholders) so a fresh design-significant prompt BLOCKS until filled; legacy/non-significant WARN. covers: 4
4. `scripts/verify-session-67.sh` + `scripts/demo-session-67.sh` proving all five behaviors E2E. covers: 6

## Guardrails
- **One story.** New `src/architect/mod.rs` + `src/cli/next.rs` + `src/analyst/mod.rs` (template) +
  `src/lib.rs` + verify/demo. Max 3 files per atomic commit. **No 8th command** (rides `vajra next`).
  No new dependency. No second store (no `design.md`, no `designs/`).
- **Surface + enforce, never author.** A Rust binary cannot make a design decision; it enforces that a
  *recorded, non-placeholder* rationale exists and references the relevant ADR — exactly like the Planner's
  `covers:` digit-tag. Name this as the fakest green in the summary (form, not semantic correctness).
- Fidelity review (DECISION-002): independent cold pass fed only this prompt + the delivery diff. Attested.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` Pipeline gains station DESIGN — the Architect gate (surface ADRs + enforce a recorded design rationale).
- `~` The pipeline goes from 3 governed stations (WHAT · HOW-plan · REVIEW) to 4 (adds DESIGN).
- `-` Retires the S64/S65 "pipeline middle (DESIGN) is unbuilt" gap.

## Deliverable
- `src/architect/mod.rs` + `src/cli/next.rs` + `src/analyst/mod.rs` + `src/lib.rs` +
  `scripts/verify-session-67.sh` (green) + `scripts/demo-session-67.sh` + `sessions/session-67-summary.md`
  + `sessions/session-67-review.md` (independent ACCEPT, attested).
- Carries forward: **S68 candidates** — the Coder handoff (governed CODE stage, closes the last gap) ·
  fix/retire compression 0-fold · strengthen a gate beyond a recorded-marker digit-tag.
