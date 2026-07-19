# Session 78 — Recover the true $: capture Claude Code's own end-of-session cost

> **Status:** APPROVED — founder pick **A** of the 3 ranked S77 candidates
> (`sessions/session-77-summary.md`). Closes the receipt arc: **S77 stopped the lie (no more
> opus-priced fake total); S78 recovers the truth** — read the coding tool's OWN authoritative cost.
> **Type: CODE — extends ADR-0004 (meter/receipt) with a capture path in the launcher; no new command.**

## Why this session
- S77's root-cause finding: the JSONL vajra meters is the on-disk CC **session transcript**, which
  never carries `total_cost_usd`. That figure is emitted only on the terminal `type:"result"` line of a
  headless `claude -p --output-format json|stream-json` **stdout stream** — an artifact vajra does not
  capture. So real headless runs get "no authoritative cost available" (honest, but not the truth).
- Founder direction (memory `vajra-receipt-pricing-from-tool`): fix the receipt by **reading the coding
  tool's own end-of-session cost** (Claude Code first), NOT by maintaining Vajra's own price list. S78
  is that fix for headless runs — capture the `-p` result line and feed its `total_cost_usd` to the
  meter S66 already built (`SessionCost.authoritative_dollars`).
- Uses the S76 captured fixtures + a fresh minimal local check; **no large new paid runs** (a tiny
  headless `-p` smoke run to capture one real `type:"result"` line is acceptable if needed and cheap).

design-significant: yes

## Design (the Architect gate — recorded rationale)
- design-significant: yes — this ADDS a cost-input source to ADR-0004's data flow: today the launcher
  spawns `claude`, waits, and meters the on-disk transcript (`docs/adr/0004-meter-receipt-design.md`);
  S78 also captures the headless `-p` **stdout result line** and hands its `total_cost_usd` to the
  existing S66 reader. It is an EXTENSION of ADR-0004 (the receipt already prefers an authoritative
  `total_cost_usd` over the token estimate — S66), NOT a deviation: no new ADR, same
  `SessionCost.authoritative_dollars` field, same headline logic. Scope guard: **interactive runs are
  unchanged** — they have no result stream, so they keep S77's honest "no authoritative cost available".

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** `vajra claude` runs a headless `-p` invocation whose stdout carries a terminal
   `type:"result"` line with `total_cost_usd` **THEN** the receipt headline is that authoritative
   figure (S66's `authoritative_dollars` path), not "no authoritative cost available" and not the token
   estimate.
2. **WHEN** the run is interactive (no `-p`, no result stream) **THEN** behaviour is unchanged from S77
   — the on-disk transcript is metered and, absent a `total_cost_usd`, the receipt still says "no
   authoritative cost available". No regression to S77's honesty.
3. **WHEN** the capture path is added **THEN** it does not corrupt the user-visible stdout of the run
   (the agent's own output must pass through untouched — capture by tee/inspection, never by swallowing).
4. **WHEN** the change lands **THEN** a regression test proves the authoritative figure is read from a
   real captured `type:"result"` line (a small real fixture), and the interactive/no-result path still
   yields the honest headline; `cargo test --lib` stays green.
5. **WHEN** S78 closes **THEN** `verify-session-78.sh` proves the capture + both paths, and
   `demo-session-78.sh` shows the before→after (S77 "no authoritative cost available" → S78 a real
   `$… total`) with the four `demo:<element>` markers.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Locate where the launcher spawns/waits on `claude` (`src/cli/launch.rs`) and how headless `-p` +
   `--output-format` are (or can be) detected; decide capture mechanism (tee stdout vs post-hoc parse).
   covers: 1, 3
2. Capture the terminal `type:"result"` line's `total_cost_usd` on headless runs and feed it to the
   meter as `authoritative_dollars`; leave interactive runs on the on-disk transcript path. covers: 1, 2, 3
3. Add the regression test (real captured `type:"result"` fixture → authoritative headline; no-result
   fixture → honest headline); keep `cargo test --lib` green. covers: 2, 4
4. Write `verify-session-78.sh` + `demo-session-78.sh`; summary + independent cold review + attestation
   (`Review-Inputs-SHA`). covers: 4, 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>

## Guardrails
- **One story:** recover the authoritative cost on headless runs. No new command; no re-pricing of the
  static table (the stale-opus debt is a separate pass); no station changes.
- **Never swallow the agent's stdout** — the user's own run output must be untouched (criterion 3).
- Honest constraint: interactive runs genuinely have no authoritative figure — do NOT fabricate one;
  S77's "no authoritative cost available" stays correct there (criterion 2).
- Prefer the S76 fixtures; a single cheap headless `-p` smoke run to capture one real result line is OK.
- Max 3 files per commit · branch `session-78-recover-true-cost` · ~2h cap.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` launcher captures the headless `-p` `type:"result"` line and feeds `total_cost_usd` to the meter.
- `~` receipt: the S66 authoritative path now actually fires on real headless runs (its happy path).
- `-` Nothing removed; S77's honest no-authoritative fallback stays for interactive/no-result runs.

## Deliverable
- `src/cli/launch.rs` (+ `src/meter/` if needed) change + regression test · `scripts/verify-session-78.sh`
  + `scripts/demo-session-78.sh` · `sessions/session-78-summary.md` + independent cold
  `sessions/session-78-review.md` (attested) · closeout `.ai/` sync + exactly 3 ranked S79 candidates
  (standing: read-only-headless UX + typed nulls · `--stations` ship durability · stale-opus re-pricing).
