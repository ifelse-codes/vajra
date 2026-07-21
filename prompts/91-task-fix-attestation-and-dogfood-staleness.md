# Session 91 — Fix S89 Reviewer hash mismatch + dogfood-staleness live query

> **Status:** APPROVED (founder pick B+C, S90 GT).

## Goal

Two bounded fixes, ordered B → C (B banks first; smaller/clearer scope):

**B** — Diagnose and fix why `--stations 89` shows Reviewer ABSENT (hash mismatch) for a
docs-only session. The S89 review exists and has a `Review-Inputs-SHA`, but `canonical_inputs_sha`
cannot reconstruct a matching diff. Either fix the reconstruction path for non-src sessions, or add
an explicit waiver path for docs-only/NO-CODE sessions that have a genuine ACCEPT review.

**C** — Add a live `sessions-since-dogfood` query computed from receipts (not STATE.md). The S90
GT found that STATE.md's "19+ days since S76 (2026-07-03)" was wrong — S36's date was cited
instead of S76's. A live derived query (reading `total_cost_usd > 0` from the receipt JSONL) would
prevent recurrence and make dogfood staleness a measurable GT input alongside `--stations`.

## Why this session

S90 GT found:
1. The S89 ledger chain has a break — `--stations 89` Reviewer = ABSENT (hash mismatch). Docs-only
   sessions may have a structural gap in `canonical_inputs_sha` reconstruction.
2. STATE.md's dogfood-staleness date was wrong for at least 3 consecutive GTs because the date was
   read from state docs, not derived from git/receipts. A live query closes this permanently.

Combined per founder direction (deliberate `max 1 story` override, like S39 A+B). B → C order so B
banks first if C overruns.

## Scope

- `src/stations/mod.rs` (or wherever `canonical_inputs_sha` / Reviewer station logic lives) — B
- `src/` — new `--dogfood-age` flag on `vajra next` (or `vajra check`), reading receipt JSONL — C
- `CONSTRAINTS.yaml` — add `dogfood_staleness` to `ground_truth.required_audits` inputs — C
- No new top-level command (max 7 cap honored)

## Acceptance Criteria

1. `vajra next --stations 89` shows Reviewer PASSED (or an explicit disclosed-waiver state, not
   ABSENT-by-hash-mismatch). `covers: 1`
2. The fix handles docs-only sessions generally — not just a one-off S89 patch. `covers: 1`
3. `vajra next --dogfood-age` (or equivalent) prints sessions-since-last-paid-run and
   calendar-days, derived live from receipt JSONL (not from STATE.md). `covers: 2`
4. The output names the session number of the last paid run and its date. `covers: 2`
5. `cargo test --lib` stays green (271+ tests). `covers: 5`
6. Cold independent review: ACCEPT on both B and C deliverables. `covers: (fidelity gate)`

## Design

design-significant: **yes** — B changes the Reviewer station's truth criteria (what counts as a
verified ACCEPT for non-src sessions); C adds a new derived metric command. Both touch the
governance contracts.

Spine records to cite: `docs/adr/` — check existing ADRs for any that cover the attestation
mechanism or receipt design (ADR-0004 covers meter/receipt; ADR-0003 covers settings injector).
If neither covers the docs-only waiver or the staleness query shape, a `docs/decisions/` record
may be appropriate (or amend an existing one).

## Plan

1. Reproduce the S89 Reviewer ABSENT by running `vajra next --stations 89` and reading the
   hash-match code path. Identify whether the gap is in `canonical_inputs_sha` reconstruction or
   in how docs-only diffs are identified. `covers: 1`
2. Fix or waive: if docs-only diffs are reconstructable, fix the reconstruction; if not, add an
   explicit disclosed waiver state (e.g. `ReviewerState::WaivedDocsOnly`) so the break is visible
   but not a false ABSENT. `covers: 1, 2`
3. Add `vajra next --dogfood-age` (or wire into `vajra check`): scan all session receipt files,
   find the last one with `total_cost_usd > 0`, report session number + date + sessions-elapsed +
   calendar-days-elapsed. `covers: 3, 4`
4. Update `CONSTRAINTS.yaml#ground_truth` to list `dogfood_staleness` alongside
   `pipeline_advance_check` as a required live query. `covers: (closes S90 meta-check gap)`
5. `cargo test --lib` green. Add tests for: (a) the new Reviewer waiver/fix path; (b) the
   dogfood-age query against a fixture receipt JSONL. `covers: 5`
6. Cold independent review (subagent, fed only prompt + diff). `covers: 6`

## Execution

*(Fill in `step N — done: <sha>` as steps complete.)*

## Guardrails

- Max 2 assumptions · max 2 retries · max 1 story (founder-overridden to B+C, like S39).
- B → C order. If C overruns, ship B alone and defer C.
- Branch: `session-91-<slug>`. New chat.
- No 8th top-level command.
- Closeout on the session branch (not `session-91-closeout` — this is a CODE session).
- `VAJRA_CLOSEOUT_WAIVER` NOT used — this is a CODE session; fill `## Execution` shas.

## Delta (Analyst gate)

- `~` `src/stations/mod.rs` (or adjacent): Reviewer station — docs-only waiver or hash fix
- `~` `src/` — new `--dogfood-age` query
- `~` `.ai/CONSTRAINTS.yaml` — `dogfood_staleness` in `required_audits`
- `~` tests for both paths
