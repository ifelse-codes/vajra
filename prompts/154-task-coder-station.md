# Session 154 — coder-station: make the CODER station pass

> **Status:** APPROVED — all approved (founder, 2026-09-08)

## Type
- **CODE**. Max 2 assumptions · 2 retries · ~2h · 1 story · new chat · approval token before any commit.

## Goal

Make S154 the first CODE session to pass the CODER station by: (1) tightening
`check_execution_shas` in verify-closeout.sh so that CODE sessions with a real plan but no
`## Execution` section BLOCK instead of WARN, (2) adding one AGENTS.md rule that names the
obligation explicitly, and (3) filling in S154's own `## Execution` at close (the self-bind).

## Background

The CODER station (`src/coder/mod.rs`, S68) enforces `step N — done: <sha>` traces in
`## Execution`. It has been in the repo since S68; no CODE session has ever passed it.

Root cause (three-part): (a) Agents write prompts without `## Execution` sections.
(b) `check_execution_shas` in verify-closeout.sh treats a missing section as WARN (OK) rather
than BLOCK — so closeout stays green. (c) No AGENTS.md rule names the obligation.

The Rust gate (`ExecState::NoExecution`) also only WARNS for a missing section. This is
intentional for LEGACY prompts (pre-S68). But new prompts that carry a real `## Plan` are not
legacy — they are agents forgetting to add the section.

Fix: detect "real plan steps present, `## Execution` absent" in the bash guard and upgrade that
case from WARN to BLOCK for non-waivered sessions. The Rust gate stays as-is (legacy compat).

## Deliverables

1. `scripts/verify-closeout.sh`: `check_execution_shas` blocks when a prompt has real (non-
   placeholder) numbered `## Plan` steps AND no `## Execution` section AND no closeout waiver.
2. `.ai/AGENTS.md`: one rule in the CODE session close checklist naming the obligation
   ("populate `## Execution` with `step N — done: <sha>` before close").
3. `scripts/verify-session-154.sh` — exits 0; at least one execute-based check that the new
   blocking behavior fires on a synthetic prompt with a real plan but no `## Execution`.
4. S154's own `## Execution` filled with real commit shas — the self-bind proof.
5. `scripts/verify-closeout.sh` exits 0 (16+ checks ALL GREEN).

## Design

design-significant: no

design-advisor: skipped — tightening an existing bash guard and adding a prose rule;
no new module, no new command, no ADR impact.

## Guardrails

- Do NOT change `src/coder/mod.rs` — the Rust gate's WARN-for-NoExecution is intentional for
  legacy compat. The fix is in the bash layer (verify-closeout.sh) and AGENTS.md only.
- Do NOT add a new top-level command. Rides `scripts/verify-closeout.sh` + `vajra next --exec`.
- Max scope: the 3 deliverables above + self-bind. Nothing else.
- The bash detection for "real plan step" must mirror the Rust gate: a line matching `^N. text`
  where text does NOT start with `<` (the placeholder marker). Do not call `vajra next --exec`
  from inside verify-closeout.sh (circular if binary is missing).

## Acceptance criteria

1. WHEN verify-closeout.sh runs on a prompt with real numbered `## Plan` steps but no
   `## Execution` section (and no waiver) THEN `check_execution_shas` exits non-zero (BLOCK).
2. WHEN verify-closeout.sh runs on a prompt with no `## Plan` steps (or placeholder-only steps)
   THEN `check_execution_shas` still passes (N/A — nothing to trace).
3. WHEN verify-closeout.sh runs on a prompt with `## Execution` already filled (no `done: <sha>`
   placeholders) THEN `check_execution_shas` passes (existing behavior preserved).
4. `.ai/AGENTS.md` contains a prose rule in the close checklist naming `## Execution`.
5. `scripts/verify-closeout.sh` exits 0 on this session's branch (ALL GREEN).
6. `vajra next --exec 154` reports RECORDED (every plan step below has a real sha).

## Plan (ordered steps — cite the acceptance criteria each step covers)

1. Upgrade `check_execution_shas` in verify-closeout.sh to BLOCK when real plan steps exist but
   `## Execution` section is absent (adds plan-step detection to the existing bash guard). covers: 1, 2, 3
2. Add AGENTS.md rule in the close-checklist section. covers: 4
3. Write `scripts/verify-session-154.sh` with execute-based tests for AC1 and AC2 (synthetic
   prompt fixtures in the script). covers: 1, 2, 3
4. Fill in `## Execution` with real commit shas after all work lands (self-bind). covers: 5, 6

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: 87feba8
- step 2 — done: 87feba8
- step 3 — done: 1abba8d
- step 4 — done: 1abba8d

## Delta (vs ROADMAP — OpenSpec markers)

- `~` `check_execution_shas` in verify-closeout.sh: WARN-for-NoExecution → BLOCK when real plan
  steps are present (backward-compat preserved for placeholder-only or no-plan prompts).
- `+` AGENTS.md rule: `## Execution` population is named as a mandatory close step.
- `+` S154 is the first CODE session to pass the CODER station (`ExecState::Recorded`).
