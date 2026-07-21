# Session 92 — Dogfood: paid `vajra claude` ride-along on chitra S08

> **Status:** APPROVED (founder pick A, S91 close).

## Goal

Run `vajra claude` end-to-end on a real bounded task in `/Users/suman/playground/chitra` — a
Vajra-managed repo. Chitra is on S08 (next after S07 CI workflows). The task for S08 is
**`release.yml` — the npm publish workflow on tag.** Measure the full 8-station governed pipeline
as a lived experience. Record the receipt, station check, and `--dogfood-age` output. The dogfood
gap is 🔴 for 14 sessions (since S76 = 2026-07-18) — this session closes it.

This is a **DOGFOOD** session, not a CODE session. The deliverable is evidence (artefacts +
measured report), not Vajra `src/` changes. `VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes`.

## Target repo

`/Users/suman/playground/chitra` — a Vajra-governed project, currently on S07 (complete).
Next session: **chitra S08** — `release.yml` publish workflow.

**chitra S08 task (what the governed agent will do):**
- Add `.github/workflows/release.yml` that triggers on `v*` tag push
- Runs the existing CI jobs (core · docs · chart-drift) as a prerequisite
- Publishes `@chitra/core` to npm (`pnpm publish --access public`, `NODE_AUTH_TOKEN` secret)
- Scope: a single workflow file + any wiring changes; no new library code

**Why release.yml:** it is the highest-leverage bounded task in the chitra backlog, fits in one
session, and produces a real concrete diff — exactly the shape needed to exercise the governed
pipeline under real conditions.

## What to measure (Vajra governance layer)

1. **Receipt** — `sessions/session-92-artifacts/receipt.stderr.txt` (or `vajra-receipt.txt`) +
   `run-result.json` with `total_cost_usd` (the S78 tee path, `vajra claude -p`).
2. **Station check** — run `vajra next --stations 92` at chitra S08 close; record K-of-8 output.
3. **Dogfood age** — run `vajra next --dogfood-age` after the run; should now show S92 as the
   most recent dogfood session.
4. **Obedience** — which gates fired, which (if any) were bypassed, and why.

## How to run

From the Vajra repo root (not chitra):
```
cd /Users/suman/playground/vajra
vajra claude -p "chitra S08 task: add .github/workflows/release.yml (npm publish on tag). 
See /Users/suman/playground/chitra/.ai/ for context. Branch: session-08-release-workflow. 
New chat constraints apply. Follow the Vajra governance gates."
```

Or launch from within chitra:
```
cd /Users/suman/playground/chitra
vajra claude   # then provide the S08 task prompt interactively
```

The receipt artefacts must be saved to Vajra's `sessions/session-92-artifacts/`, not chitra's.

## Acceptance Criteria

1. `vajra claude` ran at least one real paid turn (non-zero `total_cost_usd` in `run-result.json`
   or the receipt shows a non-zero model call). `covers: 1`
2. `sessions/session-92-artifacts/receipt.stderr.txt` (or `vajra-receipt.txt`) + `run-result.json`
   exist and are committed to the branch. `covers: 1`
3. `vajra next --stations 92` output is recorded in the ground-truth report. `covers: 3`
4. `vajra next --dogfood-age` output recorded after the run. `covers: 4`
5. Governance obedience documented: which gates fired, which were bypassed and why. `covers: 5`
6. `sessions/session-92-ground-truth.md` exists with verdict rows for: cost, stations, obedience,
   dogfood_staleness (post-run `--dogfood-age` output), chitra-S08-outcome. `covers: all`
7. Chitra S08 (the governed task): `release.yml` exists in chitra repo and chitra's CI passes
   (or a disclosed partial with explicit gap). `covers: 7`

## Design

design-significant: **no** — no Vajra `src/` changes. The Vajra governance layer is exercised as
a black-box tool over the chitra subject repo.

## Plan

1. Read chitra `.ai/` context (SESSION=07, TASK, STATE, ROADMAP) to confirm S08 readiness.
   Confirm chitra's branch is main and working tree is clean. `covers: 7`
2. Launch `vajra claude` (from chitra or Vajra root) with the S08 task prompt. Let the governed
   agent open a session-08-release-workflow branch, produce the `release.yml`, write verify +
   demo scripts, and attempt closeout. `covers: 1, 7`
3. Capture the receipt artefacts into `sessions/session-92-artifacts/`. Verify `total_cost_usd`
   is present in `run-result.json`. `covers: 1, 2`
4. At session close, run `vajra next --stations 92` and `vajra next --dogfood-age`. Record both
   outputs verbatim. `covers: 3, 4`
5. Document governance obedience: did the agent follow session guard, commit gate, closeout gate?
   Any bypasses? `covers: 5`
6. Write `sessions/session-92-ground-truth.md`. `covers: 6`

## Guardrails

- Max 2 assumptions · max 2 retries · max 1 story.
- **DOGFOOD session:** `VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes` — no `## Execution` shas
  required for this (Vajra S92) session. The chitra S08 sub-session follows its own closeout rules.
- No fidelity review required for Vajra S92 (DOGFOOD, no src/ deliverable).
- Vajra branch: `session-92-dogfood-paid-pipeline`. **New chat.**
- Chitra S08 branch: `session-08-release-workflow` (inside the chitra repo).
- If chitra S08 does NOT reach a ACCEPT closeout, document the failure honestly — the dogfood
  evidence is still valid. Do not forge or skip chitra's own gates.
- Artefacts go in **Vajra's** `sessions/session-92-artifacts/`, not chitra's sessions dir.

## Delta (Analyst gate)

- `+` `sessions/session-92-artifacts/` — receipt + run-result.json (evidence)
- `+` `sessions/session-92-ground-truth.md` — measured dogfood report
- `~` `.ai/STATE.md`, `ROADMAP.md`, `SESSION-BOOT.md`, `TASK.md`, `SESSION` — closeout sync only
- (chitra S08 changes live entirely in `/Users/suman/playground/chitra`, not in this repo)
