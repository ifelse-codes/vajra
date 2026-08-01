# Session Boot

## Current Session
- **Number:** 106 — COMPLETE
- **Type:** **CODE** — make it installable (v0.1); the C→B→A order's **B** (founder pick ①).
- **Goal:** one install path that works from a clean checkout + the missing **installability
  instrument** + a README truth-pass — proven, not felt.
- **Verdict:** **DELIVERED (goal achieved).** `cargo install --git|--path` → `vajractl` crate, `vajra`
  binary (Cargo.toml was already release-correct — the S105 "paper-only" note was stale). Shipped
  `scripts/install-smoke.sh` (fresh install → `vajra init` → `vajra next`, asserts each, **exits
  non-zero on any fail**; proven both ways — 7/7 PASS on the real tree, FAIL→exit 1 on a broken
  source). README truth-pass: working one-liner proven; crates.io / brew / prebuilt rows stay NOT YET
  PUBLISHED. **No `src/` changes; no crates.io publish; no tag.** verify 5/5; demo exit 0 (4 markers).
  Independent cold review **ACCEPT**, attested `07b962af…`.
- **Report:** `sessions/session-106-summary.md` · review: `sessions/session-106-review.md` · next
  prompt: `prompts/107-task-tagged-binary-release-v010.md`. **Date last updated:** 2026-07-31.

## Repo State Snapshot
- `.ai/SESSION` = 106. CODE: `README.md` + 3 new scripts (`install-smoke.sh`, `verify-session-106.sh`,
  `demo-session-106.sh`); **zero `src/`**. Commits carry `VAJRA_ALLOW_COMMIT=106`.
- **PR #111** (`session-106-installable-v01`) → main. S105 follow-up **#110** merged (un-blind
  `--dogfood-age`). Remote: `origin` → `https://github.com/ifelse-codes/vajra`.

## Next Session
- **Number:** 107 — **CODE: tagged binary release v0.1.0** (founder pick A, the C→B→A order's **B**
  completion). Push a `v0.1.0` tag → `release.yml` builds 3-target prebuilt binaries + a GH release →
  a **download-and-run smoke** proves the no-Rust install path → un-mark that README row. Prompt:
  `prompts/107-task-tagged-binary-release-v010.md`.
- **Guardrail:** the `git push origin v0.1.0` publishes a **public GH release** — get an explicit
  founder "yes push the tag" in chat first. **crates.io stays prohibited** absent a separate "yes publish".

## Carry-Forwards
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S107.
- **Communicate in the plainest English** (founder request S103) — translate all jargon.
- **Installability is now MEASURED** (S106 instrument). Residual 🟡: the smoke default proves `--path`;
  the README headline `--git` remote path runs only under `VAJRA_SMOKE_SOURCE=git` (structurally
  identical, disclosed) · `within-budget` is post-hoc, not a hard timeout.
- **`--dogfood-age` durable fix still open (🟡):** make `dogfood_age()` recurse into per-run subdirs
  (`src/dogfood/mod.rs:63-66`) so future dogfoods needn't hand-add an aggregate receipt. (S107-alt C.)
- **`vajra --version` gap (🟡):** a stranger gets usage, not a version string. (S107-alt B.)
- **Untracked stragglers** (standing founder call): `sessions/session-9*-artifacts/*`,
  `sessions/session-10{2,3}-artifacts/*`, `vajra-cto-audit-2026-07-22.html`, `first-mate.html`.
