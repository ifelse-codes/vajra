# Session 106 — CODE: make it installable (v0.1) — Summary

**Type:** CODE (the C→B→A order's **B**). **Branch:** `session-106-installable-v01`. **PR:** #111.
**Cost:** ~$0 (local build/test/review; no `vajra claude` paid run this session).

## Goal (from `prompts/106-task-installable-v01.md`)

Close the biggest slice of the stranger-shippability gap: **one install path that works from a clean
checkout**, an **instrument that proves it** (the S105 meta-check blind spot), and a **README
truth-pass** — proven, not felt.

## Goal achieved? YES.

- **Install path works today** — `cargo install --git https://github.com/ifelse-codes/vajra` (no clone)
  or clone + `cargo install --path .`. Discovery: `Cargo.toml` was **already release-correct**
  (`vajractl` crate, `vajra` binary, v0.1.0) — the S105 "paper-only / Cargo.toml untouched" note was
  stale. So the gap was never the crate metadata; it was the **absence of proof**.
- **The missing instrument shipped** — `scripts/install-smoke.sh`: fresh temp install → fresh-dir
  `vajra init` → `vajra next`, each asserted inside a time budget, **exits non-zero on any failure**.
  Proven both ways live: **7/7 PASS on the real tree (12s)**; **FAIL → exit 1 on a broken source**.
- **README truth-pass** — the working one-liner replaces the unproven claim and points at the
  instrument; crates.io / brew / prebuilt-binary rows stay honestly `NOT YET PUBLISHED`.

## Evidence

| Check | Result |
|---|---|
| `bash scripts/install-smoke.sh` (path) | `SMOKE PASS (7 checks, 0 fail)`, exit 0, 12s |
| `VAJRA_SMOKE_PATH=<empty> … install-smoke.sh` | `SMOKE FAIL (2 pass, 5 fail)`, exit 1 (falsifiable) |
| `bash scripts/verify-session-106.sh` | `ALL GREEN (5 pass, 0 fail)` — test-lib + fmt + clippy + smoke + readme-truth |
| `bash scripts/demo-session-106.sh` | exit 0, all 4 sprint-demo markers |
| `git diff --stat main..HEAD` | README.md + 3 new scripts; **0 src/, 0 Cargo.\*** |

## Fidelity map (every numbered requirement → what shipped)

| # | Requirement | Status | Evidence |
|---|---|---|---|
| AC1 | Clean-checkout install → runnable `vajra`, shown by real output | **SHIPPED** | smoke PASS 7/7; `Cargo.toml` `vajractl`/bin `vajra` |
| AC2 | `install-smoke.sh` fresh-dir install→init→next, asserts each, exits non-zero on fail | **SHIPPED** | falsification → exit 1; separate install-root + project-dir mktemps |
| AC3 | README shows only working paths; unshipped stay NOT YET PUBLISHED | **SHIPPED** | `readme-truth-pass` PASS; 3 rows still marked |
| AC4 | `cargo test --lib` green; no pipeline-station logic changed | **SHIPPED** | verify ALL GREEN; diff has 0 `src/` |
| AC5 | Nothing published to crates.io without a founder token | **SHIPPED** | no `cargo publish`; no tag; no name burned |
| AC6 | Independent cold review → ACCEPT, attested, ledger | **SHIPPED** | `session-106-review.md` ACCEPT, `Review-Inputs-SHA 07b962af…` |

## What I did NOT build (stated plainly)

- **No no-Rust install path.** The working path needs Rust/cargo. A **prebuilt binary** (the
  `release.yml` tag path) is deferred → an S107 option.
- **No crates.io publish, no git tag** — both deferred (crates.io is irreversible, founder-gated).
- **The `--dogfood-age` recurse-into-subdirs durable fix** (S105 residual) — not in scope; still open.

## The fakest "green" here (disclosed, from the cold review)

The smoke test's **default** proves `cargo install --path` (the local tree); the README's **headline**
`cargo install --git <remote>` is only exercised under `VAJRA_SMOKE_SOURCE=git`. They are structurally
identical (one Cargo.toml, one `vajractl` crate, one `vajra` bin) and the gap is disclosed in the script
header — a floor, not a deception — but it is the one place where "proven" leans on an equivalence claim
rather than the default run. Secondary: `within-budget` is a post-hoc assertion, not a hard per-step
timeout (a true infinite hang wouldn't be killed).

## Next: exactly 3 options (A/B/C)

**A — Tagged binary release `v0.1.0` (the no-Rust install path).** *Goal:* push a `v0.1.0` tag so the
existing `release.yml` builds 3-target prebuilt binaries + a GH release, un-marking the "prebuilt binary
NOT YET PUBLISHED" row so a stranger **without Rust** can install. *Why:* finishes "B installable" for
real — the current path assumes a Rust toolchain. *Risk:* a GH release is a public artifact (reversible,
but outward-facing); still no crates.io burn. Founder-gated.

**B — `vajra --version` + smoke version-pin + quickstart truth-pass.** *Goal:* add a real `--version`/`-V`
(today a stranger gets usage), have the smoke test pin `0.1.0`, and verify the README "How You Use It"
block end-to-end. *Why:* the smallest, safest installability-polish slice; strengthens a stranger's
first-run confidence. *Risk:* low; touches `src/main.rs` (arg parsing only, no pipeline logic).

**C — `--dogfood-age` recurse-into-subdirs (close the S105 code residual).** *Goal:* make `dogfood_age()`
scan recurse into per-run subdirs so future dogfoods needn't hand-add an aggregate receipt. *Why:* makes
the dogfood instrument self-maintaining; closes a named 🟡. *Risk:* low; `src/dogfood/mod.rs` only, fully
test-covered.

**Recommendation:** **A** — it is the one remaining slice that changes *who* can install (no-Rust
strangers), finishing the installable-MVP; B and C are polish that can ride a later session.
