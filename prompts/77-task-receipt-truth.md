# Session 77 — Receipt truth on real runs: stop the receipt lying about dollars

> **Status:** APPROVED — founder pick **A** of 3 ranked S77 candidates at the S76 dogfood close
> (`sessions/session-76-summary.md`). Executes the sharpest gap the S76 paid ride-along exposed:
> **on the runs users actually make, the receipt cannot tell the truth about cost.**
> **Type: CODE — within ADR-0004 (meter/receipt); a pricing-table + JSONL-parse fix, no new command.**

## Why this session
- S76's two paid headless runs both produced **`$14.39` / `$12.18` "total" figures that are not the
  bill** — model was `claude-fable-5` (absent from `meter::MODEL_PRICING` → priced at the opus upper
  bound) AND the JSONL carried **no `total_cost_usd`** (0 `type:result` lines; regression vs S63). With no
  authoritative figure to fall back to, the receipt's dollar number is pure opus-priced overstatement.
- Evidence is captured: `sessions/session-76-artifacts/run1|run2/receipt.stderr.txt` + the local raw
  `run.jsonl` transcripts (the S76 dogfood dataset). Use them as fixtures — do not spend on new runs.
- Map-to-Vajra: the fix rides `src/meter/` (ADR-0004), no new artifact/command. S66 built the
  authoritative-vs-estimate split; S77 makes it actually resolve to a truthful number on real runs.

design-significant: no

## Design (the Architect gate — recorded rationale)
- design-significant: no — a fix within ADR-0004's meter/receipt design: (1) add fable-5 to the pricing
  table (real rates if obtainable, else a documented flagged-but-not-opus handling), and (2) locate where
  cost actually lives in a real headless/interactive JSONL and read it — or, if it genuinely is absent,
  make the receipt say so usefully instead of printing a misleading estimate. No ADR deviation.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** a `claude-fable-5` transcript is metered **THEN** its estimate is **no longer the opus upper
   bound** — fable-5 is in `meter::MODEL_PRICING` with real rates (cite the source), or, if the rates are
   unpublished, a documented decision that stops the opus-priced overstatement (and the receipt says so).
2. **WHEN** the S76 headless JSONL fixture is metered **THEN** the receipt's dollar behaviour is correct:
   if an authoritative figure exists anywhere in the transcript the meter reads it; if it genuinely does
   not, the receipt states "no authoritative cost available" rather than presenting an estimate as a total.
3. **WHEN** the root cause of the missing `total_cost_usd` is investigated **THEN** the finding is recorded
   (nesting artifact vs CC-version change vs cost-on-a-different-line) — repaired if reading it is possible,
   documented as a known limit if not. No guessing.
4. **WHEN** the change lands **THEN** a regression test uses a real S76-captured fixture (fable-5 +
   headless, no `type:result`) proving the new behaviour; `cargo test --lib` stays green.
5. **WHEN** S77 closes **THEN** `verify-session-77.sh` proves the meter change + the fixture test, and
   `demo-session-77.sh` shows before→after (opus-priced $14.39 misleading estimate → truthful/flagged
   figure) with the four `demo:<element>` markers.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Investigate the S76 fixtures: where (if anywhere) does cost live in the headless/interactive JSONL;
   confirm fable-5 is the model; decide fable-5 rate handling. covers: 1, 3
2. Add fable-5 to `meter::MODEL_PRICING` (real rates + source, or documented flagged handling); adjust the
   receipt so an unpriced/unknown model never reads as an authoritative total. covers: 1, 2
3. Repair the meter to read an authoritative figure if it exists on a non-`result` line; else make the
   receipt state "no authoritative cost available" instead of a misleading estimate. covers: 2, 3
4. Add the regression test on the real S76 fixture; write `verify-session-77.sh` + `demo-session-77.sh`;
   summary + independent cold review + attestation (`Review-Inputs-SHA`). covers: 4, 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: 086a1b6  (investigation: root-cause comment + real fixture landed with the fix)
- step 2 — done: 086a1b6  (fable-5 priced; receipt no-authoritative headline)
- step 3 — done: 086a1b6  (authoritative read = documented known limit; on-disk transcript carries none)
- step 4 — done: 35a6165  (regression test in 086a1b6; verify-session-77 11/11 + demo 4/4 in 35a6165)

## Guardrails
- **One story:** receipt truth. No new command, no compression work, no station changes.
- Use the S76 captured fixtures — **no new paid runs** to reproduce this.
- Honest constraint (S76): fable-5 real rates may be unpublished → an acceptable outcome is "flag clearly
  / stop opus-pricing," not necessarily "price to the cent." Never claim a precision you don't have.
- Max 3 files per commit · branch `session-77-receipt-truth` · ~2h cap.

## Delta (vs ROADMAP — OpenSpec markers)
- `~` `meter::MODEL_PRICING`: fable-5 added / unknown-model handling hardened.
- `~` receipt: an estimate is never presented as a total when no authoritative figure exists.
- `+` a regression fixture from the S76 dogfood (fable-5 + headless-no-result).
- `-` Nothing removed; S66's authoritative-vs-estimate split is extended, not replaced.

## Deliverable
- `src/meter/` change + regression test · `scripts/verify-session-77.sh` + `scripts/demo-session-77.sh` ·
  `sessions/session-77-summary.md` + independent cold `sessions/session-77-review.md` (attested) ·
  closeout `.ai/` sync + exactly 3 ranked S78 candidates (standing: read-only-headless UX + typed nulls ·
  --stations ship durability · whatever this session surfaces).
