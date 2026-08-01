# Session 107 — CODE: tagged binary release v0.1.0 (the no-Rust install path)

**Type:** CODE · **Branch:** `session-107-tagged-binary-release` · **PR:** #112 · **Cost:** ~$0 (local
build/test + one cold-review subagent; no paid `vajra claude` run).

## Goal — ACHIEVED

Ship the one install path S106 left open: a **prebuilt binary a stranger downloads and runs with no Rust
toolchain.** Push `v0.1.0` → `release.yml` builds 3 tarballs + a GitHub release → prove the download-and-run
path with the same falsifiable-instrument discipline → un-mark exactly that README row.

**Delivered:** the `v0.1.0` release is **live** with all 3 tarballs + `.sha256`; `install-smoke.sh` gained a
`VAJRA_SMOKE_SOURCE=release` mode (download → sha256 verify → extract → `init`→`next`, fail-closed); the
README un-marks the prebuilt row (real command), crates.io + brew stay `NOT YET PUBLISHED`. Independent cold
review **ACCEPT**, attested `836cdfec…`.

## Fidelity map (every prompt requirement → evidence)

| AC | Requirement | Status | Evidence |
|----|-------------|--------|----------|
| AC1 | `v0.1.0` release, 3 tarballs + `.sha256`, real `gh` output | **SHIPPED** | `gh release view v0.1.0` → 6 assets, all `uploaded` (run `30685309887` all-green) |
| AC2 | Release smoke downloads host tarball, verifies sha, runs init→next, exits non-zero on fail — live | **SHIPPED** | `SMOKE PASS (11/11)` live on arm64 (`sessions/session-107-artifacts/release-smoke-live.txt`); nonexistent-tag → exit 1; byte-flip → sha `did NOT match` (reviewer-verified) |
| AC3 | README un-marks prebuilt (real cmd); crates.io + brew stay marked; no faked paths | **SHIPPED** | README L21–39; crates.io + brew still `NOT YET PUBLISHED`; `verify-107 readme-truth-pass` PASS |
| AC4 | `cargo test --lib` green; CI green; no pipeline-station logic changed | **SHIPPED** | `cargo test --lib` 296 passed; diff = release.yml + README + 3 scripts, **no `src/`** |
| AC5 | Tag pushed only after founder token; nothing to crates.io | **SHIPPED** | Founder directed the push in chat; no `cargo publish`; name not burned |
| AC6 | Independent cold review → ACCEPT, attested; ledger appended | **SHIPPED** | `sessions/session-107-review.md`, attested `836cdfec…`; ledger appended at closeout |

**Bonus (in-scope) — `release.yml` fix:** the first tag run stalled because the `macos-13` (Intel) runner
sat queued indefinitely while the other two targets built in ~22–31s. Fix: build `x86_64-apple-darwin` by
**cross-compiling on `macos-latest`** (pure-Rust, no C deps → safe). Reviewer ran `file` on the released
binary → genuine `Mach-O x86_64`. Re-run all-green.

## What I did NOT build (stated plainly)

- **The x86_64 binaries are proven by architecture + checksum, never executed.** The smoke runs only the
  host-platform tarball (aarch64 here); the cross-compiled macOS x86_64 binary can't run on the arm64 CI
  runner. `file` + sha256 pass, so runtime failure is unlikely, but "an Intel-Mac stranger can install *and
  run*" is asserted, not executed. **This is the fakest green** — within contract (AC2 scopes to host
  tarball; demo case 4 flags the real download as informational), honestly disclosed.
- **The blocking close-gate is offline** — it asserts the fail-closed (404→exit 1) path and greps the
  release-mode code, but the positive live download is deliberately out of the gate (a gate must not depend
  on the network). The positive path is proven by a captured artifact + the cold reviewer, not the gate.
- **crates.io + Homebrew stay unpublished** (out of scope; irreversible / founder-gated).

## Verify / demo

- `verify-session-107.sh` → **7/7 GREEN** (suite + fmt + clippy · path smoke · release-mode present ·
  release-mode fails-closed · README truth).
- `demo-session-107.sh` → **exit 0**, all 4 sprint-demo elements; case 4 downloads the real release live
  (`SMOKE PASS 11/11`).

## Next — exactly 3 options (A/B/C), drawn from ROADMAP

- **A — Start the real agent fleet (the C→B→A order's A).** Goal: stand up the first *named parallel* agent
  stage (e.g. researcher/coder/QA) riding the existing evidence-gates. Why: installable v0.1 is now DONE
  (Rust path S106 + no-Rust path S107) — A is the north-star payload. Risk: large; needs a design pass
  (ADR) before code, likely a multi-session arc.
- **B — Finish distribution: publish crates.io + Homebrew tap.** Goal: un-mark the last two README rows so
  `cargo install vajractl` / `brew install` actually work. Why: completes "installable" for every channel.
  Risk: **crates.io publish is IRREVERSIBLE (name burns on first publish)** — hard founder gate; brew needs
  a tap repo.
- **C — Installability polish (S107-alt B + C).** Goal: `vajra --version` prints a version (not usage), and
  `dogfood_age()` recurses into per-run subdirs (`src/dogfood/mod.rs:63-66`). Why: closes two standing 🟡
  carry-forwards; small, low-risk, `src/`-level. Risk: low payload — housekeeping, not north-star.

*(S110 is the next mandatory NO-CODE ground-truth — every 5th session.)*
