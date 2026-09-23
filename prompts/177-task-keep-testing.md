# Session 177 — rudra session 09 with S176's fix in

> **Status:** APPROVED — founder picked candidate A (keep testing on rudra) at the S176 close,
> 2026-09-23, same rudra test as S172–S176.

## Type
- **CODE**, interactive. He runs rudra's session 09 (`prompts/09-task-fill-realism.md` there) for real
  under `vajra claude`; findings are COLLECTED during the run and fixed together after it closes.
  If the run finds nothing to fix, keep this session open for rudra session 10 (S176's pattern).
- **Not a ground-truth session.** `.ai/CONSTRAINTS.yaml#ground_truth_next_session: 180`.

## Before he starts
1. `cargo install --path /Users/suman/playground/vajra` — S176's fix (F70, the Planner's Dangling
   state) lives in the binary (`src/planner/mod.rs`). Without a rebuild, rudra's `--check-plan`
   still passes a brief whose Acceptance was deleted. No `vajra init --sync-fleet` is needed — S176
   changed no scaffolded file.
2. Launch: `VAJRA_ALLOW_COMMIT=09 vajra claude` (add `VAJRA_ALLOW_PUBLISH=1` only if he wants the
   agent to push and open the PR; merge stays his either way).

## What this run should exercise
- **F70 live:** if the agent's plan cites an item the brief lacks, does `--check-plan` / `--steps`
  now say so, and does the message send it to the right fix?
- **F73 watch:** does rudra's S09 brief use an acceptance shape the Planner can't read (`1)`,
  `**1.**`, numeric tables)? If so, the block names it — does it cost a retry?
- **F58, F61/F63, the `cwd`/worktree push** — still never exercised live.
- **F31** a ninth time — tech-lead dispatched first. **F66** — every required handoff git-tracked?

## Carried in
1. **Parked by the founder:** F67 (receipt misprices Opus 5.5 ~5× — the permanent fix is reading the
   tool's own cost, not new price rows) · F71 (remote branch left after a GitHub-button merge).
2. **Disclosed, needs his yes:** F70-residual (nothing at close re-runs the Planner) · F66
   (`--check-crew` disk-presence vs git-tracked).
3. **Deferred from S176:** qa-specialist recs 3 (the `--steps` hint for a Dangling plan), 4
   (`PlanState::blocks()` has no production caller), 6 (a fixture session-advance run on a dangling
   plan), 7 (sweep compares exit + reason) — `sessions/session-176-summary.md`.
4. **Parked LOW:** F47, F56, F57, F73 · **F50** not fixed in code · **F64** watch.
5. **S180 ground truth** carries S175's design-advisor recs — `prompts/180-task-ground-truth.md`.

## Findings (filled in live)
| # | Step | What happened | Severity |
|---|---|---|---|
| _ | _ | _ | _ |

## Goal
1. _From the founder's run._

## Deliverables
1. _From the founder's run, plus whatever the carried items resolve to._

## Acceptance
1. _Each item something he can check himself._

## Design
- design-significant: <yes|no — decided from the findings>

## Plan
1. <filled in from the findings>

## Guardrails
- No new gate on Vajra's own paperwork. A gate on the HANDOVER to the human needs his explicit yes.
- Findings are collected during his run and fixed after it closes; small commits, each fix shown.
- Anything not fixed goes in the findings table with a severity, never dropped.
- Guard/check changes: compare old vs new on a listed set before claiming "no regression" (S173);
  changes may only ADD. When a check finds nothing to check, ask whether it could read what was
  there (S176).
- A founder "why" question is answered with evidence, not turned into a feature (S176).
- **Merge stays strictly hand-typed.**

## Delta
- `+` whatever rudra session 09 surfaces
- `~` S176's F70 fix meets a real run for the first time
- `~` F31 watched a ninth time
- `-` nothing removed
