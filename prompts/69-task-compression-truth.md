# Session 69 — Compression truth: make it fold for real, or retire the claim — CODE

> **Status:** APPROVED (founder delegated the S69 pick at S68 close — "no preference" → agent call
> per `feedback-guide-dont-menu`; standing "all approved"). **Type: CODE.** One story.
> Branch `session-69-<slug>` from `main`, new chat. **S70 = the mandatory NO-CODE GT** (next).

## Goal
End the product's one standing false implication: compression. S63's paid run measured **0 folds**
on real Claude Code output while the product still implies token savings. This session is a
timeboxed **fix-or-retire**: make the cargo/npm/pytest heuristics fold real captured CC transcripts
where provably safe (the S33-found `exit_code == Some(0)` gap — real CC never sends it, so those
heuristics always passthrough), MEASURE the result on the real corpus, and make every claim
(README / VISION / receipt wording) match the measured number — or, if folds stay ~0, **retire the
savings claim entirely**. Either exit is a win; an unmeasured claim is the only losing exit.

## Why this session
- **Truth-in-claims is the product.** The pitch is *provable* governance; a tool whose own README
  implies savings measured at $0 contradicts its thesis (same class as the S66 receipt fix).
- **The gap is known and bounded.** S33 named it: cargo/npm/pytest branch on `exit_code ==
  Some(0)`, a field real CC omits → they take the `_fail` passthrough. S41 already unblocked the
  git family with `preserves_failure_signal()` scoping — the pattern to follow exists.

## Acceptance (testable — EARS-style; every criterion is cited by a `## Plan` step below)
1. **WHEN** the engine processes the captured real-CC fixtures (S63 artifacts + `research/`
   fixtures) **THEN** cargo/npm/pytest outputs fold where provably safe, with no dependence on the
   never-sent `exit_code` field — fold counts measured and printed, not asserted.
2. **WHEN** a heuristic cannot prove the fold preserves the failure signal **THEN** it passes
   through unchanged (correctness-first — compression never gambles; memory
   `vajra-compression-correctness-first`).
3. **WHEN** the session closes **THEN** every savings claim in README/VISION/receipt matches the
   measured reality: a real measured number, or the claim REMOVED (retire path) — no unmeasured
   savings implication survives anywhere.
4. **WHEN** `scripts/verify-session-69.sh` runs **THEN** it proves fold-on-real-fixtures +
   passthrough-on-unsafe + the claim-truth check (the docs carry either the measured number or no
   claim); exit 0.

## Design (the Architect gate — recorded rationale)
- design-significant: yes — changes the engine heuristics' success-inference contract
- The heuristics' fold/passthrough gate moves from the never-sent `exit_code` field to the
  engine's inferred success, inside ADR-0003's LINE_CAP / failure-aware passthrough contract and
  ADR-0001's PostToolUse hook delivery (neither is re-opened — this corrects an input assumption,
  not the architecture). The retire path follows DECISION-001's honesty posture: governance is the
  product, so a claim the loop cannot demonstrate is removed rather than softened.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Study `src/engine/*` + ADR-0003; replace the `exit_code == Some(0)` gating in the cargo/npm/
   pytest heuristics with inferred-success scoping (the S41 `preserves_failure_signal()` move),
   unit-tested against captured fixtures. covers: 1, 2
2. Measure the fold rate on the real corpus (S63 artifacts + `research/` JSONL fixtures); record
   the number in the summary + demo. covers: 1
3. Truth pass over README / VISION.md / receipt wording: write the measured number, or excise the
   savings claim (retire) if folds stay ~0 — decided in-session by the measurement. covers: 3
4. `scripts/verify-session-69.sh` + `scripts/demo-session-69.sh` proving folds, passthrough, and
   claim-truth E2E. covers: 4

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha — the real commit that landed this step; the Coder gate BLOCKS closing the session until every numbered plan step records a commit that EXISTS>

## Guardrails
- **One story, hard timebox.** Fix-or-retire is DECIDED THIS SESSION by the measurement — no
  "fix later" third exit. Max 3 files per atomic commit. No new dependency, no 8th command.
- **Compression never gambles** (S36 founder directive): fold only where provably safe, else
  passthrough. Correctness + agent experience > token savings.
- **Fakest-green risk (name it in the summary):** "measured" on a cherry-picked corpus — the
  measurement must run on the captured REAL transcripts (S63 + research/), not synthetic fixtures.
- Fidelity review (DECISION-002): independent cold pass fed only this prompt + the delivery diff;
  attested; two-pass if a closable hole is found (S67 precedent).

## Delta (vs ROADMAP — OpenSpec markers)
- `~` Engine heuristics gate on inferred success (the S33 gap closed), inside the ADR-0003 contract.
- `+` A measured fold number on real transcripts — or a formally retired claim (either is new truth).
- `-` Retires the standing 🟡 "compression is a no-op on real CC / product implies savings it
  doesn't deliver" (S63 finding) — the last credibility debt named blocking-the-pitch-class.

## Deliverable
- `src/engine/*` (bounded) + `scripts/verify-session-69.sh` (green) + `scripts/demo-session-69.sh`
  + README/VISION/receipt truth edits + `sessions/session-69-summary.md` +
  `sessions/session-69-review.md` (independent ACCEPT, attested).
- Carries forward: **S70 = mandatory NO-CODE GT** (every 5th; last = S65). Standing candidates
  beyond: semantic-check hardening (the self-granted-jurisdiction class) · fable-5 real price ·
  the pipeline-payload counter (recommended S25/S60/S65) · 2nd agent (owner-gated) · install path.
