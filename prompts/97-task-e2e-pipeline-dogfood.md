# Session 97 — Dogfood: end-to-end 8-station pipeline on chitra

> **Status:** APPROVED (founder pick A, S95 GT close; resequenced S96→S97 so the S96 CI fmt-fix lands first).

## Goal

Drive a **real bounded task through all 8 governed stations to a genuine ACCEPT closeout** via
`vajra claude` — and measure whether the *pipeline* (not just the launcher) is usable end-to-end.
The S95 GT found the **Coder station dark 4-for-4** (S91–S94, including two code-shipping sessions)
and that S92 only ever exercised **2/8** — so the pipeline has **never** been dogfooded end-to-end.
This session closes that gap.

**Primary question:** when a governed session actually ships code, does the workflow naturally
populate the Coder `## Execution` shas (and QA / Demo-er / Releaser / Reviewer) — reaching a high
K-of-8 — or does the Coder gate stay dark because the marker workflow is impractical? **Diagnose the
Coder-dark pattern with live evidence, don't guess.**

This is a **DOGFOOD** session, not a Vajra CODE session. Deliverable = evidence (artefacts +
measured report), not Vajra `src/` changes. `VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes`.

## Target repo & state (read before launching)

`/Users/suman/playground/chitra` — a Vajra-governed project. **It is currently mid-flight:**
`.ai/SESSION` = 07, but the working tree is on branch `session-08-release-workflow` with
**uncommitted** S08 artifacts (`.github/workflows/release.yml`, `scripts/verify-session-08.sh`,
`scripts/demo-session-08.sh`) and a stray `pbcopy` file. This is the leftover of S92's ride-along —
the governed sub-session opened S08, built `release.yml`, and **never closed out** (S92 = 2/8, the
agent correctly refused an autonomous commit).

**This dangling state IS the test.** Resume chitra S08 and drive it to a real ACCEPT closeout —
that path forces the Coder / QA / Demo-er / Releaser / Reviewer stations the earlier sessions never
reached. Clean up the stray `pbcopy`. If S08 is judged unrecoverable, reset to a clean chitra `main`
and pick one fresh bounded task (agent's call, documented) — but prefer completing S08.

## What to measure (Vajra governance layer)

1. **Full station shape** — run `vajra next --stations 08` in chitra at close; record K-of-8. The
   target is **Coder PASSED** (populated `## Execution` shas) and the highest honest K reachable.
2. **Coder-dark diagnosis** — the load-bearing finding. Did the `## Execution` `step N — done: <sha>`
   markers get written naturally, or did they need coaxing? Is the workflow impractical? Record it.
3. **Receipt** — `sessions/session-97-artifacts/receipt.stderr.txt` + `run-result.json` with
   `total_cost_usd` (the S78 tee path, `vajra claude -p`).
4. **Dogfood age** — `vajra next --dogfood-age` after the run; should now show **S97** most recent.
5. **Obedience** — which gates fired, which (if any) were bypassed, and why.

## How to run

From the Vajra repo root:
```
cd /Users/suman/playground/vajra
vajra claude -p "Resume chitra S08 (session-08-release-workflow): finish .github/workflows/release.yml,
write ## Execution step->sha markers, run verify + demo, reach a real ACCEPT closeout through all
8 Vajra stations. See /Users/suman/playground/chitra/.ai/ for context. Follow the governance gates —
do not bypass, do not autonomous-commit; surface the marker to me for approval."
```
Or launch interactively from within chitra (`cd /Users/suman/playground/chitra && vajra claude`).
Receipt artefacts save to **Vajra's** `sessions/session-97-artifacts/`, not chitra's.

## Acceptance Criteria

1. `vajra claude` ran at least one real paid turn (non-zero `total_cost_usd` in `run-result.json`
   or a non-zero model call in the receipt). `covers: 1`
2. `sessions/session-97-artifacts/receipt.stderr.txt` + `run-result.json` exist and are committed. `covers: 1`
3. `vajra next --stations 08` (chitra) output recorded verbatim in the report, with the Coder
   station verdict called out explicitly. `covers: 3`
4. `vajra next --dogfood-age` output recorded after the run. `covers: 4`
5. The **Coder-dark diagnosis** is stated plainly: did `## Execution` shas populate naturally? If
   not, the concrete reason + a recommendation. `covers: 5`
6. Governance obedience documented: which gates fired, which were bypassed and why. `covers: 6`
7. `sessions/session-97-summary.md` (dogfood report) exists with verdict rows for: cost, stations
   (K-of-8 + Coder), Coder-dark diagnosis, obedience, dogfood_staleness, chitra-S08-outcome. `covers: all`
8. Chitra S08 outcome disclosed honestly: either a real ACCEPT closeout (`release.yml` + chitra CI
   green + full station shape), or a disclosed partial with the explicit gap. `covers: 7`

## Design

design-significant: **no** — no Vajra `src/` changes. The Vajra governance layer is exercised as a
black-box tool over the chitra subject repo. Cite `docs/decisions/DECISION-001-governance-as-product.md`.

## Plan

1. Read chitra `.ai/` context (SESSION, TASK, STATE, ROADMAP) + inspect the dangling S08 branch.
   Decide: resume S08 (preferred) or reset + fresh task. Clean the stray `pbcopy`. `covers: 7`
2. Launch `vajra claude` with the resume prompt. Let the governed agent finish `release.yml`, write
   `## Execution` shas, run verify + demo, and drive a real closeout through the stations. `covers: 1, 7`
3. Capture receipt artefacts into `sessions/session-97-artifacts/`. Confirm `total_cost_usd`. `covers: 1, 2`
4. At close, run `vajra next --stations 08` (chitra) + `vajra next --dogfood-age`. Record verbatim,
   Coder verdict called out. `covers: 3, 4`
5. Diagnose the Coder-dark pattern: did shas populate naturally? Why / why not? `covers: 5`
6. Document obedience; write `sessions/session-97-summary.md`. `covers: 6, all`

## Guardrails

- Max 2 assumptions · max 2 retries · max 1 story · ~2h cap.
- **DOGFOOD session:** `VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes` — no Vajra `## Execution` shas
  for this (Vajra S97) session. The chitra S08 sub-session follows its OWN closeout rules (and its
  Coder shas ARE the measurement — do not waive chitra's).
- No fidelity review required for Vajra S97 (DOGFOOD, no `src/` deliverable).
- Vajra branch: `session-97-e2e-pipeline-dogfood`. **New chat.**
- Chitra sub-session: `session-08-release-workflow` (inside the chitra repo). Do not forge or skip
  chitra's gates; if S08 can't reach ACCEPT, document the failure — the dogfood evidence still holds.
- Artefacts go in **Vajra's** `sessions/session-97-artifacts/`, not chitra's.

## Delta (Analyst gate)

- `+` `sessions/session-97-artifacts/` — receipt + run-result.json (evidence)
- `+` `sessions/session-97-summary.md` — measured end-to-end dogfood report
- `~` `.ai/STATE.md`, `ROADMAP.md`, `SESSION-BOOT.md`, `TASK.md`, `SESSION` — closeout sync only
- (chitra S08 changes live entirely in `/Users/suman/playground/chitra`, not in this repo)
