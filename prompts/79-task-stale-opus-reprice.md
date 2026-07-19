# Session 79 — Re-price the stale static opus rate (receipt-accuracy pass)

> **Status:** APPROVED — founder pick **A** of the 3 ranked S78 candidates
> (`sessions/session-78-summary.md`). Finishes the receipt-accuracy story S76→S78 for the
> interactive / token-*estimate* path S78 left untouched.
> **Type: CODE — extends ADR-0004 (meter/receipt); a compiled-in pricing-value change, no new command.**

## Why this session
- S77 surfaced the debt; S78 recovered the AUTHORITATIVE cost for headless runs but did NOT touch
  the token *estimate*. That estimate still prices the `claude-opus-4` prefix at **$15/$75 per MTok**
  (the opus-4.0/4.1 era), while the current **opus-4-8 is $5/$25** — so on interactive runs (which
  have no result stream, so the estimate IS the only figure) the receipt now *overstates* opus by
  ~3×.
- Founder-direction nuance (memory `vajra-receipt-pricing-from-tool`): the binding rule is "don't
  reconstruct the AUTHORITATIVE bill from a price list — read the tool's own cost." This session does
  NOT violate it: it only sharpens the clearly-labeled `[estimate]` fallback used when no
  authoritative figure exists. The authoritative path (S66/S78) stays the real answer wherever a
  `total_cost_usd` is available.
- Confirm the exact current rates via the `claude-api` skill at session time (do not hard-code from
  memory) — this is a "read the source of truth, then set the constant" pass.

design-significant: no

## Design (the Architect gate — recorded rationale)
- design-significant: no — this is a compiled-in RATE VALUE change within ADR-0004's existing
  `meter::MODEL_PRICING` table (the ADR explicitly says pricing is compiled-in, update the binary on
  a price change). No new data flow, no new field, no new command, no spine decision — so no ADR and
  no substantive `## Design` is required (the Architect gate passes on `design-significant: no`).
- One design question to settle IN this session (not an architecture change, a table-ordering
  choice): the `claude-opus-4` prefix matches opus-4-0/4-1/4-5/4-8 alike, but 4.0/4.1 were $15/$75
  and 4-8 is $5/$25. `pricing_for` returns the FIRST matching prefix, so a more specific
  `claude-opus-4-8` entry placed BEFORE the generic `claude-opus-4` prices current opus correctly
  while older opus keeps its historical rate. Decide + document the chosen granularity.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** the meter prices a current opus model id (e.g. `claude-opus-4-8`) **THEN** it uses the
   real current rate (confirmed via the `claude-api` skill; expected $5/$25 per MTok), NOT the stale
   $15/$75 — proven by a unit test over a known-token fixture with a hand-calculated dollar figure.
2. **WHEN** an OLDER opus id that genuinely billed at the historical rate is priced **THEN** it is
   handled per the documented granularity decision (either kept at its historical rate via a
   specific-before-generic prefix, or explicitly folded — the choice is recorded, not silent).
3. **WHEN** a model is absent from `MODEL_PRICING` **THEN** `UNKNOWN_MODEL_PRICING` still prices it
   at an intentional UPPER bound so the estimate never *undercounts* — this session must not turn the
   unknown fallback into an undercount. (Re-confirm what the correct upper bound is now.)
4. **WHEN** the change lands **THEN** `cargo test --lib` stays green and a regression test locks the
   corrected opus figure; the S66/S78 authoritative-path tests are unaffected (the estimate change
   never touches a run that has an authoritative `total_cost_usd`).
5. **WHEN** S79 closes **THEN** `verify-session-79.sh` proves the corrected rate + the unknown
   upper-bound invariant, and `demo-session-79.sh` shows the before→after (a $15/$75 opus estimate →
   the corrected $5/$25) with the four `demo:<element>` markers.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Load the `claude-api` skill; confirm current opus (opus-4-8) input/output rates and the correct
   opus upper bound for `UNKNOWN_MODEL_PRICING`. Record the sourced figures + cache date in-code.
   covers: 1, 3
2. Update `meter::MODEL_PRICING` (and the granularity decision for older opus ids) + re-confirm
   `UNKNOWN_MODEL_PRICING` stays an upper bound; keep the unknown-model labeling intact. covers: 1, 2, 3
3. Add/adjust regression tests (corrected opus figure via hand calc; unknown-model still upper-bound;
   authoritative-path tests untouched); keep `cargo test --lib` green. covers: 2, 4
4. Write `verify-session-79.sh` + `demo-session-79.sh`; summary + independent cold review +
   attestation (`Review-Inputs-SHA`). covers: 4, 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>

## Guardrails
- **One story:** correct the stale opus *estimate* rate. No new command; no launcher/capture change
  (S78 owns that); no station changes; do NOT weaken the S78 authoritative path.
- **Sourced, not guessed:** the rate must come from the `claude-api` skill / model catalog with a
  recorded cache date — this is the whole point (fix a wrong number by reading the source of truth).
- **Keep the unknown fallback an UPPER bound** — an unknown model must never be *undercounted*
  (criterion 3); it stays labeled, never billed.
- Max 3 files per commit · branch `session-79-stale-opus-reprice` · ~2h cap.

## Delta (vs ROADMAP — OpenSpec markers)
- `~` `meter::MODEL_PRICING`: the `claude-opus-4` rate is corrected from $15/$75 to the current
  opus-4-8 $5/$25 (sourced), with a documented granularity choice for older opus ids.
- `~` `UNKNOWN_MODEL_PRICING`: re-confirmed as an intentional upper bound (corrected if the upper
  bound itself moved).
- `-` Nothing removed; the authoritative (S66/S78) path and the estimate-labeling are untouched.

## Deliverable
- `src/meter/mod.rs` rate change + regression test · `scripts/verify-session-79.sh` +
  `scripts/demo-session-79.sh` · `sessions/session-79-summary.md` + independent cold
  `sessions/session-79-review.md` (attested) · closeout `.ai/` sync + exactly 3 ranked S80-onward
  candidates (note: **S80 is the mandatory NO-CODE ground truth** — S79's closeout hands off to it).
