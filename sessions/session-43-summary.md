# Session 43 — Git-level hooks scaffolding into `vajra init` (Gap 2, founder pick C carry) — DONE

## Goal
Founder pick C, second half. S42 delivered Gap 1 (`jq`-preflight, fail-closed). Gap 2 was carried
(distinct story; `max_stories:1`). This session ships it: scaffold the tracked git belt into
`vajra init` as an independent **L2** layer beneath the L3 `.claude/` hooks — closing the raw
`echo N > .ai/SESSION` / direct-commit / direct-push bypass at the git layer.

## Delivered — the git-level belt in `vajra init` (ROADMAP #17b)
The **vajra repo** already runs a tracked belt: `.githooks/pre-commit` (blocks main-commits /
>3 staged / `.ai/` drift) + `.githooks/pre-push` (blocks push to `main|master`), activated by
`git config core.hooksPath .githooks`. **Scaffolded projects got only the L3 `.claude/` hooks** —
so a raw `.ai/SESSION` write or a direct commit/push bypassed the Bash guards entirely.

**Fix (mirrors the proven S22/S29/S38 one-source `include_str!` pattern), 3 files:**
- `src/cli/init.rs`:
  - `TPL_GITHOOK_PRE_COMMIT` / `TPL_GITHOOK_PRE_PUSH` = `include_str!("../../.githooks/…")` —
    byte-identical to the canonical files, one source, no drift.
  - Two `fx()` emits → `.githooks/pre-commit` + `pre-push`, **executable**.
  - `configure_githooks_path(root)` — sets `core.hooksPath=.githooks` in a git repo; **idempotent
    + graceful**: an existing (repo-local) `core.hooksPath` is left as-is (init's skip-if-present
    convention); a non-git dir is a documented no-op (prints the manual activation line, never
    fails init).
  - `.githooks` added to the dir-creation list **and** `SCAFFOLD_OWNED` (so a re-run stays
    greenfield, not misdetected as brownfield).
  - 4 new scaffold unit tests: verbatim + executable · `core.hooksPath` set in a git repo ·
    existing `core.hooksPath` respected · non-git dir emits the belt without crashing.
- `Cargo.toml`: `!.githooks/pre-commit` + `!.githooks/pre-push` un-exclude (`.githooks/` is
  excluded) so `cargo install` compiles the `include_str!` and both files ship.

**Scope discipline:** the canonical hooks were scaffolded **byte-identical** — no refactor of the
existing hooks (prompt directive).

## Evidence
- `scripts/verify-session-43.sh` — **22/22 GREEN.** Real `vajra init` into a temp **git** repo:
  both hooks byte-identical + executable + `core.hooksPath=.githooks`; drives the scaffolded
  **pre-commit to actually BLOCK** on-main / >3-staged / `.ai/` drift (clean case passes) and the
  scaffolded **pre-push to BLOCK** push-to-main (feature passes). Real `vajra init` into a temp
  **non-git** dir degrades gracefully (files emitted, exit 0, no `.git`). Packaging
  (`cargo package --list` ships both) + Rust gates included.
- `cargo test` **111 lib** (+4) + 12 adapter pass; `clippy -D warnings` + `fmt --check` clean.
- Commits `7a9ef90` (feature: init.rs + Cargo.toml) + `0f5f565` (proof: verify). ≤3 files each. ~$0.

## Behavior change to note (documented, intended)
After `vajra init` into a fresh greenfield repo on `main`, the **first `git commit` is now blocked**
by the scaffolded pre-commit's main-guard — the user must `git checkout -b session-NN-<slug>` first.
This is byte-identical to Vajra's own belt and enforces "never commit to `main`" (correct by design).

## Carry-forwards
- **Dogfood gate still UNMEASURED** (S40) — the moat + S41 compression + S42 `jq` + this S43 git-belt
  are all test/replay-verified, **not live-verified**. Re-dogfood (#17a) still owed.
- **cargo/npm/pytest exit-code fold gap** (S41 carry) — own compression session.
- **`.claude/settings.json` merge on init** (S34 finding) — brownfield repos with an existing
  settings.json get it skipped → L3 hooks never wired. Backlog, unchanged.
- **S45 is the next mandatory NO-CODE ground-truth** (every 5th; last = S40).

## Next options (exactly 3 — A/B/C, from ROADMAP)
- **A — Re-dogfood: live-verify the moat (ROADMAP #17a) [RECOMMENDED].** Goal: run the real
  `vajra claude` loop against a scaffolded L3 project and prove the publish-guard + session-guard +
  git-belt block a live agent's push / PR / advance / main-commit — render the founder-satisfaction
  gate verdict with evidence. Why: the moat is now hardened S37→S43 but entirely test/replay-verified;
  the dogfood gate has been UNMEASURED since S36 and flagged by every GT (S30/S35/S40). This is the
  one missing proof. Risk: costs real $ (S36 ≈ $61) — use the S36 method (`-p` + payload replay first,
  interactive only if needed) and `VAJRA_ALLOW_PUBLISH` care.
- **B — `.claude/settings.json` merge on init (S34 finding).** Goal: `vajra init` merges into an
  existing `.claude/settings.json` instead of skipping it, so brownfield projects that already have
  one get the scaffolded hooks wired. Why: today the whole enforcement moat is silently absent for
  exactly the primary (brownfield) use case. Bounded, 1-story. Risk: JSON merge semantics (same class
  as the ADR-0003 launcher merge) — must not clobber the user's hooks.
- **C — Trim the boot-packet cost (ROADMAP #18).** Goal: shrink the heavy constitution/boot packet
  toward the stated "<5% context footprint" rule (the ~$32 cache-read that dominated the S36 $58
  session). Why: compression saves ~$0, so the boot packet is the real cost lever. Risk: trimming
  context risks dropping a load-bearing rule the agent then ignores — distill without drift.
