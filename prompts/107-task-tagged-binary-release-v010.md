# Session 107 — CODE: tagged binary release v0.1.0 — the no-Rust install path

> **Status:** APPROVED (founder pick A, S106 closeout — option ① of 3). The C→B→A order's **B**,
> completing "installable" for a stranger **without a Rust toolchain**. Written at S106 closeout per
> `end_of_session.must_write_next_prompt_before_close`.

## Goal

Ship the one install path S106 left open: a **prebuilt binary a stranger can download and run with no
Rust installed.** Push a `v0.1.0` tag → the existing `release.yml` (S10–S17) builds the 3-target
tarballs + a GitHub release → prove the downloaded binary works with the **same instrument discipline**
S106 established (a falsifiable smoke test, not a claim) → un-mark exactly that README row.

## Why this session (evidence from S106)

- S106 shipped one working install path (`cargo install --git|--path`) **and** the installability
  instrument that proves it — but that path **assumes a Rust toolchain**. A stranger without Rust still
  cannot install. The `release.yml` pipeline that produces prebuilt binaries **already exists** and has
  never been fired for a real tag.
- The README's **"Prebuilt binary … NOT YET PUBLISHED"** row is the last honest-but-unshipped install
  method that this MVP order (B) is meant to close. crates.io + brew stay deferred.

## Scope (max 1 story; ≤3 files per commit; ~2h cap)

**In:**
1. **A `v0.1.0` git tag → GitHub release** with the 3 prebuilt binary tarballs + `.sha256` files that
   `release.yml` produces (`aarch64-apple-darwin`, `x86_64-apple-darwin`, `x86_64-unknown-linux-gnu`).
   Pushing the tag is **founder-gated** (it publishes a public release) — get an explicit in-chat "yes
   push the tag" before `git push origin v0.1.0`.
2. **A download-and-run smoke** — extend `scripts/install-smoke.sh` with a `VAJRA_SMOKE_SOURCE=release`
   mode (or a sibling script) that, in a fresh temp dir, **downloads the published tarball for the host
   platform**, extracts `vajra`, then runs `vajra init` → `vajra next`, asserting each and the tarball's
   `sha256`, exiting non-zero on any failure. This is the falsifiable proof the no-Rust path works.
3. **README truth-pass** — the prebuilt-binary row loses "NOT YET PUBLISHED" and shows the real
   `releases/latest/download/...` command, verified by the release smoke. crates.io + brew stay marked.

**Out (defer):** crates.io publish (irreversible, founder-gated — a separate explicit "yes publish") ·
Homebrew tap · the real agent fleet (A) · any pipeline-station work.

## Acceptance criteria

1. A `v0.1.0` GitHub release exists with all 3 tarballs + `.sha256` files — shown by real
   `gh release view v0.1.0` output (not a claim).
2. The release smoke downloads the host-platform tarball, verifies its sha256, runs `vajra init` →
   `vajra next` from the extracted binary, and **exits non-zero if any step fails** — demonstrated live.
3. README un-marks the prebuilt-binary path (real download command) and keeps crates.io + brew marked
   NOT YET PUBLISHED. No faked paths.
4. `cargo test --lib` stays green; CI green both OS; no pipeline-station logic changed.
5. The tag is pushed only after an explicit founder token in chat; nothing published to crates.io.
6. Independent cold review (`sessions/session-107-review.md`) → ACCEPT, attested; ledger appended.

## Guardrails

- Branch `session-107-<slug>`; commits carry `VAJRA_ALLOW_COMMIT=107`.
- **A git tag + GH release is a public, outward artifact.** It is reversible (delete the release + tag),
  but treat the `git push origin v0.1.0` as an explicit-permission action — founder "yes" in chat first.
- **crates.io publish stays prohibited** absent a separate explicit founder "yes publish" — the name
  burns on first publish.
- The release smoke must fail closed: a missing asset, a sha mismatch, or a non-zero `vajra` step is a
  FAIL, never a skipped-and-green. Every "it installs" claim re-derivable by a stranger from its output.
- If `release.yml` needs a fix to run green, that is in-scope (≤3 files/commit); a package **rename** is
  not (name settled — `DECISION-006`).
