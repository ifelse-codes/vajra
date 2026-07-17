# Session 73 — Close-path RELIABILITY: fix the brakes (deflake the suite + bound the live gate runs)

> **Status:** APPROVED (founder pick at the S72 board review, 2026-07-17: "close path
> reliability. fix the brakes first" — chosen over the payload counter and the parked dogfood
> ride-along). **Type: CODE.** Since S69, closing ANY session re-runs the full test suite and
> the demo LIVE — the close path IS the product's brakes. Two real defects, both observed at
> S72's own close: (a) two `tests/hook_adapter.rs` compression tests FAIL INTERMITTENTLY
> under repeated full-suite runs (state leak suspected; observed in both directions —
> red via the gate + green direct, and the reverse), so a random red can block any close for
> no real reason; (b) the QA and Demo-er live gate runs have NO time limit (reviewer-flagged
> S69, re-flagged S71), so a hanging script hangs the close forever.

## Goal
Make every close deterministic and bounded: root-cause and FIX the `hook_adapter` flake by
isolating the leaked state (assertions stay exactly as strong — no retries, no `#[ignore]`,
no deleted tests), and give the QA + Demo-er live runners a recorded, fail-closed timeout —
a run that exceeds it is killed and BLOCKS the close naming the timeout ("a check that
cannot evaluate FAILS"; a timeout never passes a close). Normal green closes behave
exactly as today.

## Why this session
- The brakes bit us at S72's own close (one refused advance on a phantom red; a retry
  passed) — the flake taxes EVERY future session until fixed, whatever gets built next.
- The unbounded live run is the standing reviewer-flagged debt on the two slow gates
  (S69 QA · S71 Demo-er, shared runner pattern) — fail-closed but unbounded is half a brake.
- Map-to-Vajra: no new artifact, no new command — the timeout is a recorded key in the
  existing `CONSTRAINTS.yaml` verify/demo spine (scaffold-propagated, defaults on missing
  keys); the deflake is test-internal isolation.

design-significant: yes

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** the full suite runs repeatedly (a ≥10-consecutive-run loop of the previously
   flaky `hook_adapter` tests, plus the full `cargo test` at least twice) **THEN** every run
   is green — the leaked state is isolated at the ROOT (per-invocation isolation), with the
   root cause named in the module/test comments; no assertion weakened, no retry loop, no
   `#[ignore]`, no test deleted.
2. **WHEN** a QA or Demo-er live gate run exceeds the recorded timeout **THEN** the child
   process is killed and the gate BLOCKS naming the timeout and the script — never a silent
   pass, never a hang; L1 still advises on the same derived result; the skip envs keep their
   existing meaning.
3. **WHEN** the timeout is not recorded **THEN** a scaffold-default applies (recorded in
   `.ai/CONSTRAINTS.yaml` for this repo AND propagated into the `vajra init` scaffold, the
   S22/S57 pattern); a recorded value wins; pre-S73 repos stay valid with no edits.
4. **WHEN** gates run normally (green, fast scripts) **THEN** behavior is byte-for-byte
   unchanged in verdicts and wiring: all existing lib tests plus the verify-71/verify-72
   harnesses stay green; no CLI surface change, no 8th command, no new dependency, no
   second store.
5. **The fix is proven live:** `scripts/verify-session-73.sh` runs E2E cases — a
   deliberately hanging demo/verify script BLOCKS within the bound (naming the timeout), a
   green script still passes, the recorded-key-wins and default paths both exercised, and
   the deflake loop from AC-1 runs inside the harness; `scripts/demo-session-73.sh` carries
   the four `demo:<element>` markers with before → after = "a close could flake red or hang
   forever" vs "deterministic, bounded, fail-closed".

## Design (the Architect gate — recorded rationale)
- design-significant: yes — touches the shared live-runner of two governed stations (QA S69,
  Demo-er S71) inside the `--advance` gate chain locked by
  `docs/decisions/DECISION-001-governance-as-product.md` (governed stations with enforced
  handoffs). The timeout keeps the house fail-closed posture (AGENTS.md: "a check that
  cannot evaluate FAILS") — a killed run classifies as the existing
  cannot-evaluate BLOCK, never a pass, so gate semantics narrow but never loosen. The
  deflake honors `DECISION-002-fidelity-over-discipline.md`'s spirit: a gate whose evidence
  flakes is a gate whose green means less — isolation restores the evidence's meaning
  without weakening one assertion. Contract keys ride the existing CONSTRAINTS spine
  (no second store).

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Root-cause the `hook_adapter` flake (instrument the two failing tests, find the shared
   state — sidecar/tmp/env collision), fix by per-invocation isolation, name the root cause
   in comments, and add the ≥10-run green loop as the regression proof. covers: 1
2. Add the bounded runner: timeout the QA + Demo-er live runs (kill + classify as the
   existing cannot-evaluate BLOCK naming timeout + script); read the recorded key with
   scaffold defaults; keep L1/skip-env semantics untouched. covers: 2, 3
3. Record the contract: timeout key(s) in this repo's `.ai/CONSTRAINTS.yaml` + the
   `vajra init` TPL_CONSTRAINTS propagation (defaults on missing keys — pre-S73 repos
   valid). covers: 3, 4
4. Prove it: `scripts/verify-session-73.sh` (hanging-script blocks-within-bound · green
   passes · recorded-wins · default applies · deflake loop · verify-71 + verify-72 re-run
   green · lib suite green ×2) + `scripts/demo-session-73.sh` (four markers, before →
   after) + independent cold review + attestation (`--inputs-sha 73` at review time).
   covers: 1, 4, 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>

## Guardrails
- **One story:** close-path reliability. No gate-semantics changes beyond the bound (no new
  blocks, no loosened WARNs), no station features, no payload counter, no compression work.
- **Deflake = isolate, never weaken:** the two tests keep their exact assertions; fixing by
  retry/ignore/delete is a REJECT-shaped outcome.
- Timeout default must be generous (a real `cargo test` close takes minutes — the bound
  kills hangs, not slow truth); disclose the chosen default and why.
- Max 3 files per commit · approval tokens before any commit · branch
  `session-73-close-path-reliability` · ~2h cap. **S75 = the next mandatory NO-CODE GT.**

## Delta (vs ROADMAP — OpenSpec markers)
- `~` `tests/hook_adapter.rs`: intermittently flaky → deterministically green (state
  isolated, root cause named); the S72 found-live debt retired.
- `~` QA + Demo-er live runners: unbounded → bounded fail-closed (timeout kills + BLOCKS,
  naming itself); the S69/S71 reviewer-flagged debt retired.
- `+` Recorded timeout key(s) in `CONSTRAINTS.yaml` + scaffold propagation.
- `-` Nothing removed; dogfood stays PARKED by founder call
  (`prompts/parked-dogfood-ride-along.md`); payload counter stays backlog-do-not-lose.

## Deliverable
- The deflake fix + the bounded runner + `src/cli/init.rs` scaffold keys ·
  `scripts/verify-session-73.sh` + `scripts/demo-session-73.sh` ·
  `sessions/session-73-summary.md` + independent cold `sessions/session-73-review.md`
  (attested) · closeout `.ai/` sync + exactly 3 ranked S74 candidates (standing: payload
  counter [backlog] · dogfood ride-along [parked, READY-shaped] · readable brief ·
  compression fix-or-retire · depth hardening).
