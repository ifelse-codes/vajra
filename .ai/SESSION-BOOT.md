# Session Boot

## Current Session
- **Number:** 108 — COMPLETE
- **Type:** **CODE** — publish to crates.io + Homebrew tap; the C→B→A order's **B**, now COMPLETE
  (founder pick B at S107 closeout).
- **Goal:** un-mark the last two README install rows by making them real — publish `vajractl` to
  crates.io and stand up a Homebrew tap for the `v0.1.0` release — each proven by a falsifiable install.
- **Verdict:** **DELIVERED (goal achieved).** `vajractl 0.1.0` is **live on crates.io** (fresh-dir
  `cargo install vajractl` → `init`→`next`, **7/7 SMOKE PASS**; API `max_version 0.1.0`). Public tap
  **`ifelse-codes/homebrew-tap`** with `Formula/vajra.rb` (real `v0.1.0` sha256 for arm64/x86_64 macOS +
  x86_64 Linux); proven `brew install ifelse-codes/tap/vajra` (**11/11 SMOKE PASS**, sha256-verified).
  `install-smoke.sh` gained `crates` + `brew` modes, both **fail-closed**. README un-marks both rows
  (nothing left NOT YET PUBLISHED). `Cargo.toml` excludes 2 stray root HTML files. **No `src/`; no
  station logic changed.** verify **10/10**; demo exit 0 (4 markers). Independent cold review **ACCEPT**,
  attested `f5a97e8b…`. Irreversible `cargo publish` ran only after founder "yes publish" (founder did
  `cargo login` themselves; token never handled); tap created only after "yes tap".
- **Report:** `sessions/session-108-summary.md` · review: `sessions/session-108-review.md` · next
  prompt: `prompts/109-task-fleet-slice-1-researcher.md`. **Date last updated:** 2026-08-01.

## Repo State Snapshot
- `.ai/SESSION` = 108. CODE: `Cargo.toml` + `Formula/vajra.rb` + `README.md` +
  `scripts/install-smoke.sh` (crates+brew modes) + 2 new scripts (`verify-session-108.sh`,
  `demo-session-108.sh`); **zero `src/`**. Commits carry `VAJRA_ALLOW_COMMIT=108`.
- **PR #113** (`session-108-publish-crates-brew`) → main. S107 **#112** merged. Remote: `origin` →
  `https://github.com/ifelse-codes/vajra`. New public repo: `ifelse-codes/homebrew-tap` (the tap).

## Next Session
- **Number:** 109 — **CODE: fleet slice 1 — one real named agent (Researcher) as a governed step**
  (founder pick A, "start the fleet"). Dispatch one named role with a role-scoped prompt +
  delta-tracked handoff, proven with a **stub agent** (no paid call); **design-significant** → author
  `DECISION-007`; **ride an existing command (no 8th)**. Prompt:
  `prompts/109-task-fleet-slice-1-researcher.md`.
- **Guardrail:** max 7 top-level commands — an 8th needs a separate explicit founder "yes". No paid run
  required (prove plumbing with a stub); a real paid Researcher run is deferred + founder-gated.

## Carry-Forwards
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S109.
- **Communicate in the plainest English** (founder request S103) — translate all jargon.
- **v0.1 is installable FOUR ways, all MEASURED:** `cargo install --git|--path` (S106), prebuilt binary
  (S107), `cargo install vajractl` from crates.io (S108), `brew install ifelse-codes/tap/vajra` (S108).
  Residual 🟡: the brew smoke tests a LOCAL copy of the formula, not the published tap (S108 fakest
  green); x86_64 tarballs proven by arch+checksum, never executed; positive installs proven by artifact
  + cold reviewer, not the offline gate.
- **`--dogfood-age` durable fix still open (🟡):** make `dogfood_age()` recurse into per-run subdirs
  (`src/dogfood/mod.rs:63-66`). **`vajra --version` gap (🟡):** a stranger gets usage, not a version.
- **crates.io is PUBLISHED — `vajractl` name BURNED.** Any future crates.io action stays founder-gated.
- **Untracked stragglers** (standing founder call): `sessions/session-9*-artifacts/*`,
  `sessions/session-10{2,3,7,8}-artifacts/*`. (`vajra-cto-audit-*.html` + `first-mate.html` now excluded
  from the crate package; still untracked in the tree.)
