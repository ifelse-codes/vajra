# Session 64 — The PLANNER stage (the pipeline's 2nd governed specialist)

> **Status:** APPROVED (founder pick **A** at S63 close — build the next station). **Type: CODE.**
> The Analyst (stage one) is complete (S54+S61+S62): it governs the **WHAT** — intent → the accepted next
> PROMPT. S64 builds stage two, the **Planner**, which governs the **HOW** — it turns that accepted prompt into
> an ordered, coverage-checked **plan** *before* any code is written. This is the S60-GT "payload over
> gate-hardening" direction: advance the pipeline itself, second station on the line.

## Type
- **CODE.** Max 2 assumptions · 2 retries · ~2h · **1 story** · new chat · approval token before any commit.
- Independent cold fidelity review required (DECISION-002). **S65 = mandatory NO-CODE ground-truth** (every 5th).

## The idea (map to Vajra's OWN mechanism — do NOT add a new file/store/command by reflex)
- **The plan IS a section of the session's own contract.** The prompt (`prompts/NN-task-*.md`) is Vajra's spec;
  the Planner adds/gates a **`## Plan`** block *inside that same prompt file* — no `plan.md`, no second store
  (`feedback-distill-no-drift`, `feedback-map-concepts-to-vajra`).
- **The plan's job = coverage.** Each of the prompt's **acceptance criteria** must map to the ordered step(s)
  that will satisfy it. This is the *pre-execution* mirror of the fidelity Validator's *post-delivery* check:
  the Validator asks "did the delivery cover every requirement?"; the Planner asks "does the plan cover every
  requirement, before we start?"
- **Surface + enforce, never author** (the S54 anti-trap): the binary surfaces the acceptance checklist to plan
  against and enforces coverage — it must **not** fabricate plan steps or fake a "generated" plan.
- **Ride `vajra next`** — no 8th command (the Analyst pattern).

## Acceptance (testable, EARS-style)
1. **WHEN** the accepted prompt for session N has acceptance criteria **THEN** `vajra next --plan N` surfaces them
   as the checklist to plan against (the plan derives from the contract, not from thin air) — proven on a real
   prompt in a temp repo, not a mock.
2. **WHEN** a session's `## Plan` is missing, is a template placeholder, **or** does not cover every acceptance
   criterion **THEN** `vajra next --check-plan N` BLOCKS (exit 1); **WHEN** the plan covers every criterion **THEN**
   it PASSES. Wired into `--advance` (L2/L3 block · L1 advise · `VAJRA_SKIP_PLANNER_GATE=1` override) so a session
   cannot proceed to execution on an unplanned / uncovered contract.
3. **The binary surfaces + enforces, never authors** — there is no faked "generated" plan; a placeholder `## Plan`
   is treated as absent (mirrors S61 `DeltaState::Placeholder` and S62 options).

## Deliverables
- `src/planner/mod.rs` (or an extension of `src/analyst/`) — the plan parse + coverage check + gate, with unit
  tests (acceptance-item extraction, coverage true/false, placeholder detection).
- `src/cli/next.rs` — `--plan N` (surface the acceptance checklist) + `--check-plan N` (the gate) + the `--advance`
  wiring. No 8th command; no second store.
- `scripts/verify-session-64.sh` (exits 0) — real `--plan` / `--check-plan` / `--advance` runs in a temp git repo:
  surfaces the criteria, BLOCKS a missing/placeholder/uncovered plan, PASSES a covering plan, refuses to advance on
  an uncovered contract. Rust gates stay green (fmt/clippy/`-D warnings`/test).
- `scripts/demo-session-64.sh` + the interactive HTML demo when asked.
- `sessions/session-64-summary.md` + **an independent cold fidelity review** (`sessions/session-64-review.md`,
  attested `Review-Inputs-SHA`) + exactly 3 ranked candidates (note: **S65 is the mandatory NO-CODE GT**, so these
  rank the S66 build).

## Guardrails
- **ONE story** — the plan-coverage gate. Do NOT also build the Architect/Coder stage or harden other gates.
- **No new file/store/command** — the plan lives in the existing prompt file; the gate rides `vajra next`. If a
  second store feels necessary, STOP and ask (`feedback-map-concepts-to-vajra`).
- **Legacy prompts stay valid** — a wholly absent `## Plan` on an old prompt WARNS (non-blocking), matching the
  S61/S62 backward-compat stance; only a *placeholder* or an *uncovered* plan on a session being advanced BLOCKS.
- Darshan every human reply · Varta against the live `.ai/`. Approval token before any commit.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` The Planner stage: `vajra next --plan` (surface acceptance checklist) + `--check-plan` (coverage gate),
  wired into `--advance` — the pipeline's 2nd governed station.
- `~` Extends the Analyst's "surface + enforce, never author" pattern from the WHAT (prompt) to the HOW (plan);
  turns the Session-Loop PLAN step (step 3) from a convention into an enforced, coverage-checked gate.
- `-` Retires the standing "still one stage of a pipeline" headline — one station becomes two.
