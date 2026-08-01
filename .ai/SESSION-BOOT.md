# Session Boot

## Current Session
- **Number:** 107 — COMPLETE
- **Type:** **CODE** — tagged binary release v0.1.0; the no-Rust install path; the C→B→A order's **B**
  completion (founder pick A at S106 closeout).
- **Goal:** ship the one install path S106 left open — a prebuilt binary a stranger downloads and runs
  with **no Rust** — proven by a falsifiable instrument, not a claim.
- **Verdict:** **DELIVERED (goal achieved).** The **`v0.1.0` GitHub release is live** — 3 prebuilt
  tarballs + `.sha256` (`aarch64-apple-darwin`, `x86_64-apple-darwin`, `x86_64-unknown-linux-gnu`).
  `install-smoke.sh` gained `VAJRA_SMOKE_SOURCE=release` (detect host → download → sha256 verify →
  extract → `init`→`next`, **fail-closed**), proven live **11/11**. README un-marks the prebuilt row;
  crates.io + brew stay NOT YET PUBLISHED. **In-scope `release.yml` fix:** the first tag run stalled on
  the scarce `macos-13` Intel runner → `x86_64-apple-darwin` now cross-compiles on `macos-latest` (pure
  Rust, safe; reviewer confirmed `file` → genuine x86_64). **No `src/`; no crates.io publish.** verify
  7/7; demo exit 0 (4 markers). Independent cold review **ACCEPT**, attested `836cdfec…`.
- **Report:** `sessions/session-107-summary.md` · review: `sessions/session-107-review.md` · next
  prompt: `prompts/108-task-publish-crates-brew.md`. **Date last updated:** 2026-08-01.

## Repo State Snapshot
- `.ai/SESSION` = 107. CODE: `.github/workflows/release.yml` + `README.md` + `scripts/install-smoke.sh`
  (release mode) + 2 new scripts (`verify-session-107.sh`, `demo-session-107.sh`); **zero `src/`**.
  Commits carry `VAJRA_ALLOW_COMMIT=107`.
- **PR #112** (`session-107-tagged-binary-release`) → main. S106 **#111** merged. Remote: `origin` →
  `https://github.com/ifelse-codes/vajra`. **`v0.1.0` tag** points at `718ec68` (must stay reachable —
  merge #112 with a merge commit, not squash).

## Next Session
- **Number:** 108 — **CODE: publish to crates.io + Homebrew tap** (founder pick B). Publish `vajractl`
  to crates.io + a tap formula installing the `v0.1.0` release binary → prove each with a falsifiable
  smoke → un-mark the last two README rows. Prompt: `prompts/108-task-publish-crates-brew.md`.
- **Guardrail:** `cargo publish` is **IRREVERSIBLE** (the name `vajractl` burns on first publish) — get an
  explicit founder "yes publish" in chat first. `cargo publish --dry-run` is safe. The tap is a public repo.

## Carry-Forwards
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S108.
- **Communicate in the plainest English** (founder request S103) — translate all jargon.
- **v0.1 is installable 3 ways, all MEASURED:** `cargo install` (S106), prebuilt binary (S107). Residual
  🟡: the x86_64 tarballs are proven by arch + checksum, never *executed* (the arm64 box can't run them);
  the positive live download is proven by a captured artifact + the cold reviewer, not the offline gate.
- **`--dogfood-age` durable fix still open (🟡):** make `dogfood_age()` recurse into per-run subdirs
  (`src/dogfood/mod.rs:63-66`).
- **`vajra --version` gap (🟡):** a stranger gets usage, not a version string.
- **Untracked stragglers** (standing founder call): `sessions/session-9*-artifacts/*`,
  `sessions/session-10{2,3,7}-artifacts/*`, `vajra-cto-audit-2026-07-22.html`, `first-mate.html`.
