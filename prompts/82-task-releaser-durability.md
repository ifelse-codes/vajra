# Session 82 — Releaser station reads from ledger when branch is pruned (CODE)

> **Status:** APPROVED (founder pick B at S81 close).
> **Type:** CODE — one story; one Rust function changed in `src/stations/mod.rs`, no new module,
> no new command, no new dependency.

## Goal

`vajra next --stations NN` shows `[ABSENT] Releaser SHIP — branch not merged into main` for every
past session whose branch was properly merged and then pruned. This is wrong: pruning the merged
branch is the REQUIRED end-state (the S37 close step). The GT's own mandatory instrument gives a
false read on every session it measures.

**Root cause:** `releaser_status` in `src/stations/mod.rs` maps `BranchShip::NoBranch` →
`Outcome::Absent` — it cannot distinguish "pruned after merge" (good) from "never created"
(bad). The attested ACCEPT review already in the ledger (`sessions/session-NN-review.md`)
distinguishes them: a properly-closed session has one; a ghost session does not.

**Fix:** when the branch is `NoBranch`, fall back to the ledger: if there is an attested ACCEPT
review for the session → `Outcome::Passed`. No change to `releaser/mod.rs` (the `--advance` gate
already treats `NoBranch` as a warning, not a block).

## Why this session

S75 GT first flagged it. S80 GT confirmed it a second consecutive time. The station counter
(`--stations NN`) is the GT's primary pipeline-health instrument; showing ABSENT for every shipped
session is a persistent false read that undermines the instrument's credibility.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)

1. **WHEN** `--stations NN` is run on a session whose branch was merged and pruned AND whose
   `sessions/NN-review.md` carries an attested ACCEPT **THEN** `[PASSED] Releaser SHIP` with a note
   that names the ledger as the evidence source.
2. **WHEN** `--stations NN` is run on a session with no branch AND no attested ACCEPT review
   **THEN** `[ABSENT] Releaser SHIP` (no false positives — a ghost session or an unreviewed session
   cannot earn PASSED).
3. **WHEN** the branch EXISTS and is not yet merged **THEN** `[ABSENT] Releaser SHIP — branch not
   merged` (existing unmerged path unchanged).
4. **WHEN** the branch EXISTS, is merged, and main is synced and locals are pruned **THEN**
   `[PASSED] Releaser SHIP` (existing happy path unchanged).
5. `vajra next --stations 81` shows `[PASSED] Releaser SHIP` after this fix (live corpus smoke
   test: S81 is the most recent fully-closed session; its review is `sessions/session-81-review.md`
   with `Review-Inputs-SHA: c11797a9…` and `**Verdict:** ACCEPT`).
6. `cargo test --lib` stays green; at least 3 new tests added covering ACs 1–2 and the REJECT
   ledger edge-case; the existing `fully_filled_session_counts_high` test updated (it now yields 8/8
   because the fixture already has an attested ACCEPT review, which after the fix is sufficient
   evidence for PASSED; the previous comment "ceiling is 7/8" was the symptom, not the spec).

## Design (the Architect gate — recorded rationale)

- **design-significant: no** — a targeted bug fix to one helper function (`releaser_status`) inside
  an existing module (`src/stations/mod.rs`). No new Rust module, no new CLI command, no new
  dependency, no new data store. The attested review is already used by `reviewer_status` in the
  same file; this fix adds a helper (`session_attested_accept`) that reuses the same read path.
- The fix introduces a fallback chain: `Merged` → existing logic; `Unmerged` → ABSENT (unchanged);
  `NoBranch` → ledger check. The ledger is already the system's tamper-evident truth store
  (S55–S59); using it as the `NoBranch` fallback is consistent with the "existence-gate recorded
  markers" house pattern (S67+).
- `--advance` (the blocking close gate in `release_gate_for_close`) is NOT changed. It already
  treats `NoBranch` as a warning. Only the station COUNTER is fixed.

## Plan (ordered steps — cite the acceptance criteria each step covers)

1. Add `session_attested_accept(root, session) -> bool` private helper to `src/stations/mod.rs`:
   reads `sessions/session-NN-review.md`, checks for both a `review-inputs-sha` line and a
   canonical `**Verdict:** ACCEPT` via the existing `review_verdict_accept` helper.
   Rewrite `releaser_status` to match on `BranchShip` explicitly: `Merged` → existing logic,
   `Unmerged` → ABSENT unchanged, `NoBranch` → `session_attested_accept` → PASSED or ABSENT.
   `covers: 1, 2, 3, 4`

2. Update tests in `src/stations/mod.rs`:
   - Add `releaser_passes_when_no_branch_but_ledger_attested` (AC 1).
   - Add `releaser_absent_when_no_branch_and_no_ledger` (AC 2).
   - Add `releaser_absent_when_no_branch_but_ledger_rejects` (AC 2 edge-case: REJECT verdict).
   - Update `fully_filled_session_counts_high`: remove "7/8 ceiling" comment + change assertion to
     `8` (the fixture already carries an attested ACCEPT review — after the fix, Releaser PASSES).
   `covers: 6`

3. Smoke-test live: `vajra next --stations 81` → confirm `[PASSED] Releaser SHIP` and `7 of 8`
   (S81 is `design-significant: no` so Architect stays ABSENT; all other stations PASSED).
   `covers: 5`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: 8490c60
- step 2 — done: 8490c60
- step 3 — done: 90c932a

## Delta (the Analyst gate — what this session ADDS to the governed pipeline)

- `+` `releaser_status` in `src/stations/mod.rs` uses the attested ledger as fallback evidence
  when the session branch is pruned (`BranchShip::NoBranch`); properly-closed sessions now show
  `[PASSED] Releaser SHIP` instead of the incorrect `[ABSENT] Releaser SHIP — branch not merged`
- `+` `session_attested_accept` private helper added to `src/stations/mod.rs`; reuses existing
  `review_verdict_accept` — no new read path
- `+` 3 new lib tests covering the `NoBranch` ledger-fallback branch (PASSED, ABSENT, REJECT edge)
- `+` `fully_filled_session_counts_high` test corrected: 8/8 is now the honest ceiling for a
  fully-evidenced fixture (was 7/8, which was the bug)
