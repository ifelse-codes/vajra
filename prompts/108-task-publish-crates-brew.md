# Session 108 — CODE: publish to crates.io + Homebrew tap — finish every install channel

> **Status:** APPROVED (founder pick B, S107 closeout — option ② of 3). Completes "installable" for the
> two channels S106/S107 left `NOT YET PUBLISHED`. Written at S107 closeout per
> `end_of_session.must_write_next_prompt_before_close`.

## Goal

Un-mark the **last two** README install rows by making them real: publish the `vajractl` crate to
crates.io, and stand up a Homebrew tap whose formula installs the `v0.1.0` prebuilt binary. Prove each
with the same falsifiable-instrument discipline (a real install, not a claim), then un-mark exactly those
two rows. After this, every install method in the README works.

## Why this session (evidence from S107)

- S106 shipped the Rust install path; S107 shipped the no-Rust prebuilt-binary path (`v0.1.0` release
  live, 3 tarballs + `.sha256`, download-and-run proven 11/11). The README's **crates.io** and
  **Homebrew** rows are the only two still `NOT YET PUBLISHED`.
- crates.io publish is the one **irreversible** step left (the name burns on first publish) — it needs an
  explicit founder token, exactly like the S107 tag push did.

## Scope (max 1 story; ≤3 files per commit; ~2h cap)

**In:**
1. **crates.io publish of `vajractl`** — verify packaging with `cargo publish --dry-run` first (fix any
   missing `description`/`license`/`repository`/`readme` metadata in `Cargo.toml`), then `cargo publish`
   **only after an explicit in-chat founder "yes publish"**. Prove it: a fresh-dir `cargo install
   vajractl` from crates.io → `vajra` runs. Extend `install-smoke.sh` with a `VAJRA_SMOKE_SOURCE=crates`
   mode (or a sibling) that does this, fail-closed.
2. **Homebrew tap + formula** — create/point a tap repo (e.g. `ifelse-codes/homebrew-tap`) with a formula
   that downloads the `v0.1.0` release tarball for the host arch + verifies its `sha256`, installing
   `vajra`. Prove it: `brew install <tap>/vajra` (or `brew install --formula ./Formula/vajra.rb`) →
   `vajra` runs. crates.io + brew both get a falsifiable smoke path.
3. **README truth-pass** — the crates.io and brew rows lose `NOT YET PUBLISHED` and show the real,
   verified commands. Nothing left faked.

**Out (defer):** the real agent fleet (A) · any pipeline-station work · a formula for non-release
(source) builds · bottling.

## Acceptance criteria

1. `vajractl` is live on crates.io at `0.1.0` — shown by real `cargo search vajractl` / a fresh-dir
   `cargo install vajractl` that runs `vajra`, not a claim.
2. The Homebrew tap installs a working `vajra` from the `v0.1.0` release — demonstrated live (`brew
   install …` → `vajra --help`/`vajra init`), with the tarball `sha256` verified by the formula.
3. Both smoke paths **exit non-zero on any failure** (missing crate, sha mismatch, non-zero `vajra`).
4. README un-marks crates.io + brew (real commands); no row silently dropped; no faked paths.
5. `cargo test --lib` green; CI green both OS; no pipeline-station logic changed.
6. crates.io `cargo publish` runs **only** after an explicit founder token in chat; the tap repo is
   created only with founder awareness (public repo).
7. Independent cold review (`sessions/session-108-review.md`) → ACCEPT, attested; ledger chain intact.

## Guardrails

- Branch `session-108-<slug>`; commits carry `VAJRA_ALLOW_COMMIT=108`.
- **crates.io publish is IRREVERSIBLE — the name `vajractl` burns on first publish.** Do NOT run
  `cargo publish` (even a reserve) without a separate explicit founder "yes publish" in chat.
  `cargo publish --dry-run` is safe and expected first.
- Creating the tap repo + pushing a formula are **public, outward** actions — founder "yes" in chat first
  (reversible: delete the repo).
- A package **rename** is out (name settled — `DECISION-006`). If `Cargo.toml` needs publish metadata,
  that is in-scope (≤3 files/commit).
- Every "it installs" claim must be re-derivable by a stranger from the smoke output — fail closed on a
  missing asset, a sha mismatch, or a non-zero `vajra` step, never a skipped-and-green.
