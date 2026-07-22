# Session 96 — CI green: fix the rustfmt 1.9.0 drift

> **Status:** APPROVED (founder-directed after S95 close — CI red on main; fmt-fix sequenced before
> the dogfood, which moved to S97).

## Goal

Make `main`'s CI green. The only failing step is `cargo fmt --check` on **3 pre-existing drifted
files** — `src/cli/next.rs`, `src/dogfood/mod.rs`, `src/stations/mod.rs`. rustfmt **1.9.0-stable**
reformats them; they were committed under an older rustfmt. Red since ~S92; **not** introduced by any
recent feature (S95 was NO-CODE). Fix = run `cargo fmt`, commit the reformatting, nothing else.

**Zero logic change.** This is a formatting-only session. Confirmed at S95 close: with the 3 files
reformatted, `cargo clippy -- -D warnings` = clean (exit 0) and `cargo test --lib` = 286 — so `cargo
fmt` is the entire fix and CI will go fully green (fmt → clippy → test).

**Bonus (relevant to the S95 finding):** this is a real CODE session, so its `## Execution` shas get
populated — a live, honest chance to make the **Coder station PASS** (S95 found it dark 4-for-4).
Fill the shas at closeout; don't waive them.

## Why this session

- CI has been red on `main` since S92; the founder flagged it after S95. A green main is basic
  hygiene and the S97 dogfood's Releaser gate wants a synced/green prior.
- It is a bounded, mechanical, single-story fix — exactly one commit of `cargo fmt` output.

## Scope

- **Touch only what `cargo fmt` changes** — the 3 files above. Do **not** hand-edit formatting, do
  **not** refactor, do **not** touch logic. If `cargo fmt` wants to change a 4th file, STOP and
  report (the drift set was exactly 3 at S95 close).
- Pin the toolchain: verify `rustfmt --version` is **1.9.0-stable** (CI uses `dtolnay/rust-toolchain@stable`).
  A different rustfmt could produce a different diff and re-break CI.

## Acceptance Criteria

1. `cargo fmt --check` exits 0 (no diff) across the whole crate. `covers: 1`
2. `cargo clippy --all-targets -- -D warnings` exits 0. `covers: 2`
3. `cargo test --lib` stays green (286, or higher if new tests — none expected). `covers: 3`
4. Exactly the 3 known files changed; `git diff --stat` shows no `src/` file beyond
   `next.rs` / `dogfood/mod.rs` / `stations/mod.rs`, and no non-`src/` code change. `covers: 4`
5. CI on the PR (both `ubuntu-latest` and `macos-latest`) is green. `covers: 5`

## Design

design-significant: **no** — formatting-only; no new mechanism, command, or ADR deviation.
Cite `docs/decisions/DECISION-001-governance-as-product.md`.

## Plan

1. Confirm `rustfmt --version` = 1.9.0-stable; run `cargo fmt --check` to re-confirm the 3-file
   drift set is unchanged. `covers: 4`
2. Run `cargo fmt`; inspect `git diff` to confirm formatting-only (no token/logic changes). `covers: 1, 4`
3. Run `cargo clippy --all-targets -- -D warnings` + `cargo test --lib`; both green. `covers: 2, 3`
4. Commit (`VAJRA_ALLOW_COMMIT=96`), push, open PR; confirm CI green on both OS. `covers: 5`
5. Fill this session's `## Execution` shas at closeout (Coder station). `covers: (coder)`

## Execution

- step 1 — done: <sha>
- step 2 — done: <sha>

## Guardrails

- Max 2 assumptions · max 2 retries · max 1 story · ~2h cap.
- **CODE session** — the fidelity gate + `## Execution` shas apply (no waiver). Independent cold
  review is trivial here (formatting-only diff) but still required per DECISION-002.
- Vajra branch: `session-96-fmt-drift-fix`. **New chat.** `VAJRA_ALLOW_COMMIT=96` per commit.
- Do not reformat unrelated files to "tidy up" — scope is the 3 drifted files only.

## Delta (Analyst gate)

- `~` `src/cli/next.rs`, `src/dogfood/mod.rs`, `src/stations/mod.rs` — `cargo fmt` reformatting only
- `~` `.ai/STATE.md`, `ROADMAP.md`, `SESSION-BOOT.md`, `TASK.md`, `SESSION` — closeout sync only
- `+` `scripts/verify-session-96.sh` / `demo-session-96.sh` — assert fmt/clippy/test green + show the fix
