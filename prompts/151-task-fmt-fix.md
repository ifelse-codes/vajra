# Session 151 — Fix cargo fmt + guard against recurrence

## Goal

`cargo fmt --check` currently fails on `main` (4 files left unformatted by S148). Fix it and make the close-gate catch it so it cannot recur.

## Deliverables

1. Run `cargo fmt` — formatting clean on all source files.
2. Add `cargo fmt --check` as a check in `scripts/verify-closeout.sh` (exits 1 if fmt is dirty).
3. `cargo fmt --check` exits 0 on the session branch before merging.
4. `verify-closeout.sh` exits 0.

## Design

design-significant: no

design-advisor: skipped — formatting fix and a one-line guard addition; no new architecture, no ADR impact.

## Guardrails

- Scope: ONLY `cargo fmt` + the one-line `verify-closeout.sh` addition. No other changes.
- Do NOT fix anything else found while reading the files.
- The fmt violation is in `src/cli/init.rs`, `src/engine/heuristic/cargo.rs`, `src/engine/heuristic/npm.rs`, `src/engine/heuristic/pytest.rs` — all introduced by S148.

## Acceptance criteria

1. `cargo fmt --check` exits 0 on `main` after merge.
2. `verify-closeout.sh` contains a `cargo fmt --check` step that exits 1 when fmt is dirty.
3. `cargo test --lib` passes (485 tests — no regressions from the fmt run).
4. verify-closeout 15+1 GREEN (the new fmt check plus the existing 15).

## Delta

**Why now:** S150 GT found `cargo fmt --check` fails on main — this is the one 🔴 finding from the GT. S96 was a whole session fixing the same problem; S148 reintroduced it because verify-closeout had no fmt check. Fix the root cause (the missing guard), not just the symptom.

**What is NOT in scope:** the Coder station gap, the Demo-er gap, the fidelity-reviewer carry-forward rule, the cut-phase dogfood. Those are separate sessions.
