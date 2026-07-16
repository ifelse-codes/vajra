# Session 69 — The QA stage: verification becomes a real checkpoint — CODE

> **Status:** APPROVED (founder pick at S68 close — "Finish the crew, QA next"; standing
> "all approved"). **Type: CODE.** One story. Branch `session-69-<slug>` from `main`, new chat.
> **S70 = the mandatory NO-CODE GT** (next). Supersedes `69-task-compression-truth.md` (removed;
> compression fix-or-retire stays a carried candidate).

## Goal
Make **QA** the pipeline's 6th governed station. Today "verification = exit 0" is a house rule:
`scripts/verify-session-NN.sh` + `.ai/verify/` artifacts exist by convention, but **no gate
enforces them** — `verify-closeout.sh` never checks that a session's verify script exists, ran,
or passed; a session could close with a missing or red verify and nothing would block. The QA
station closes that: `vajra next --qa NN` **surfaces** the session's QA contract (script present?
recorded runs? latest state?); `--check-qa NN` **RE-RUNS the script live** and BLOCKS (exit 1)
on non-zero — a recorded green is never trusted, the evidence is re-executed (no stale-green).
Rides `vajra next` (no 8th command); enforces the **existing** `CONSTRAINTS.yaml#verify` contract
(`script_pattern`, `artifacts_dir`) — no new store, no new file type. Surfaces + enforces, never
authors a test.

## Why this session
- **Founder direction: finish the crew.** 5 stations govern WHAT/DESIGN/HOW/DID/REVIEW; nothing
  governs WORKS. QA is the named next crew member (Demo-er, Releaser follow, one per session).
- **The pattern is proven, upgraded once.** Delta (S61), `covers:` (S64), `design-significant:`
  (S67), `done: <sha>` (S68) all enforce a RECORDED thing, existence-gated. QA goes one step
  stronger where it can: the verify script is *executable* evidence, so the gate re-runs it
  instead of trusting a recorded marker — "a check that cannot evaluate FAILS" (AGENTS.md).

## Acceptance (testable — EARS-style; every criterion is cited by a `## Plan` step below)
1. **WHEN** `vajra next --qa NN` runs **THEN** it surfaces session NN's QA contract from the
   existing spine: the expected script path (`scripts/verify-session-NN.sh`, exists or not), the
   recorded artifacts (`.ai/verify/session-NN/`, `latest` run or none), and the classified state —
   derived from the recorded contract, not thin air.
2. **WHEN** `vajra next --check-qa NN` runs and the script EXISTS **THEN** the gate RE-RUNS it
   live and blocks (exit 1) on a non-zero exit — a previously recorded green is not accepted as
   proof; passes (exit 0) only on a live green.
3. **WHEN** a session whose verify script is missing/red is CLOSED via `vajra next --advance`
   **THEN** the QA gate BLOCKS at L2/L3 (exit non-zero), advises at L1, and honors
   `VAJRA_SKIP_QA_GATE=1` alone (distinct from the other stages' overrides).
4. **WHEN** a session has no verify script (NO-CODE ground-truth sessions, legacy sessions)
   **THEN** the gate WARNS at most — and the warning names the dodge plainly (deleting the script
   downgrades the gate: the known self-granted-jurisdiction class, disclosed).
5. **WHEN** `scripts/verify-session-69.sh` runs **THEN** it proves surface + block-on-red +
   pass-on-green + legacy-warn + advance-wiring in a temp repo with real passing and failing
   verify scripts; exit 0.

## Design (the Architect gate — recorded rationale)
- design-significant: yes — new module `src/qa/` + new `vajra next --qa/--check-qa` surface
- Sixth governed station per DECISION-001's station shape, riding `vajra next` per ADR-0002's
  thin-CLI module layout (no 8th command, no new dependency). It enforces the contract
  `CONSTRAINTS.yaml#verify` already records (`script_pattern` + `artifacts_dir` + exit-0) — the
  scripts and `.ai/verify/` artifacts ARE the store; adding a `qa.md` would be a second store.
  One deliberate upgrade over the S61/S64/S67/S68 recorded-marker shape, per DECISION-002's
  evidence-over-claim posture: the marker here is *executable*, so `--check-qa` re-runs it live
  rather than trusting a recorded green — the stale-green (S68's pre-session-sha analogue) is
  killed by construction. The gate binds on the session being CLOSED (the S62/S68 stance —
  verification proves the session's own build).

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. New `src/qa/mod.rs` (registered in `lib.rs`): resolve the session's script path + artifacts
   dir from the spine patterns, classify `QaState` (NoScript → legacy WARN naming the dodge ·
   script present + live run red → BLOCK · live green → PASS), with the runner capturing the
   script's real exit code. covers: 1, 4
2. CLI in `src/cli/next.rs`: `vajra next --qa NN` (surface the contract read-only, no execution)
   · `--check-qa NN` (re-run live, gate, exit 1) · wire into `--advance` on the CLOSING session
   with `VAJRA_SKIP_QA_GATE=1` (L2/L3 block · L1 advise). covers: 2, 3
3. `scripts/verify-session-69.sh` + `scripts/demo-session-69.sh`: temp repo carrying one passing
   and one failing `verify-session-NN.sh`; prove surface, live-block, live-pass, legacy-warn, and
   both advance outcomes E2E. covers: 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha — the real commit that landed this step; the Coder gate BLOCKS closing the session until every numbered plan step records a commit that EXISTS>

## Guardrails
- **One story.** New `src/qa/mod.rs` + `src/cli/next.rs` + `src/lib.rs` + verify/demo. Max 3 files
  per atomic commit. No 8th command, no new dependency, no second store (no `qa.md`, no test
  authoring — the binary never writes or fixes a test).
- **Honest runtime cost:** `--check-qa` executes the session's verify script (cargo build/test —
  slow); that is the point (live evidence), but say it plainly in the surface output.
- **Fakest-green risk (name it in the summary):** the self-granted-jurisdiction class again — no
  script → WARN (AC 4's mandated legacy/NO-CODE compat), so deleting the script dodges the gate;
  and a green verify script only proves what the script's author chose to check. QA verifies the
  session's checks pass, not that the checks are sufficient.
- Fidelity review (DECISION-002): independent cold pass fed only this prompt + the delivery diff;
  attested; two-pass if a closable hole is found (S67 precedent).

## Delta (vs ROADMAP — OpenSpec markers)
- `+` Pipeline gains station QA/WORKS — the 6th governed station (surface the verify contract +
  re-run it live as a blocking gate on close).
- `~` "Verification = exit 0" upgrades from a house rule (convention + closeout blind spot) to an
  enforced, live-executed gate riding `vajra next`.
- `-` Retires the gap "nothing checks that verify-session-NN.sh exists/ran/passed at close."

## Deliverable
- `src/qa/mod.rs` + `src/cli/next.rs` + `src/lib.rs` + `scripts/verify-session-69.sh` (green) +
  `scripts/demo-session-69.sh` + `sessions/session-69-summary.md` + `sessions/session-69-review.md`
  (independent ACCEPT, attested).
- Carries forward: **crew next** = Demo-er, then Releaser (one per session, founder direction) ·
  compression fix-or-retire (the 0-fold claim) · semantic-check hardening · fable-5 price ·
  pipeline-payload counter · readable-roadmap one-pager (derived, never hand-kept) · 2nd agent
  (owner-gated) · install path. **S70 = mandatory NO-CODE GT** (every 5th; last = S65).
