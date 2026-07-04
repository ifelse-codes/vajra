# Session 43 — Git-level hooks scaffolding into `vajra init` (Gap 2, founder pick C carry)

> Founder pick C, second half. S42 delivered Gap 1 (`jq`-preflight, fail-closed — all 5 hooks).
> Gap 2 was carried (it is a distinct story; `max_stories:1`). This session ships it.
> Branch: `session-43-git-level-hooks-scaffold`.

## The gap (S40 finding #2, ROADMAP #17b — high-leverage, bounded)
The **vajra repo** already has a tracked git belt: `.githooks/pre-commit` (blocks main-commits /
>3 staged files / `.ai/` drift) + `.githooks/pre-push` (blocks push to main/master), wired via
`git config core.hooksPath .githooks`. **Scaffolded projects get only the `.claude/` L3 hooks** —
so a raw `echo N > .ai/SESSION` write or a direct `git push` bypasses the Bash guards entirely.
This git-level belt is an **independent L2 layer beneath** the L3 `.claude/` hooks (defense-in-depth,
AGENTS.md "Defense-in-Depth Layers" table L2). It also closes the S39/S40 bounded carry-forward
(raw `.ai/SESSION` write) at the right layer.

## The fix — scaffold the belt into `vajra init`
Mirror the proven S22/S28/S29/S38 one-source `include_str!` pattern (`src/cli/init.rs`):
1. `const TPL_GITHOOK_PRE_PUSH = include_str!("../../.githooks/pre-push")` +
   `const TPL_GITHOOK_PRE_COMMIT = include_str!("../../.githooks/pre-commit")` (byte-identical,
   one source — the same canonical files the vajra repo runs).
2. Emit both to `.githooks/` in the scaffolded project, **executable** (the `fx(...)` emit path).
3. Set `core.hooksPath` for the scaffolded project — decide the mechanism (a) `git config
   core.hooksPath .githooks` run once during `init` if `.git` exists, or (b) documented + a
   `[core] hooksPath` note if not a git repo yet. Prefer (a); handle the not-a-git-repo case
   gracefully (init already runs on brownfield + greenfield).
4. **Packaging:** `.githooks/*` is `include_str!`'d from outside `src/` — check `Cargo.toml`'s
   `exclude`/`include`; add the same per-file negation gotcha (S22/S29/S38) if excluded, verify via
   `cargo package --list`.

## Scope discipline (the real risk)
- **≤3 files / 1 story.** Expected touch: `src/cli/init.rs` (+ maybe `Cargo.toml`) + `scripts/
  verify-session-43.sh`. Keep it to the scaffold-the-belt story; do NOT also refactor the existing
  hooks.
- **Idempotence:** `init` re-run on an already-scaffolded project must not clobber or double-set
  `core.hooksPath`; a project with an existing `core.hooksPath` or existing `.githooks/` needs a
  documented decision (skip vs overwrite — match init's existing skip-if-present convention).

## Proof discipline (required)
- A real `vajra init` into a temp **git** repo → assert `.githooks/pre-push` + `pre-commit` are
  **byte-identical** to the canonical `.githooks/*` sources, **executable**, and `core.hooksPath`
  is set to `.githooks`.
- Drive the scaffolded `pre-commit` to actually **block** a main-commit / >3-staged / `.ai/`-drift,
  and the scaffolded `pre-push` to **block** a push to main (the verify-39 temp-repo pattern).
- A real `vajra init` into a temp **non-git** dir → assert it degrades gracefully (no crash;
  documented behavior).
- New scaffold unit tests in `src/cli/init.rs` (verbatim + executable + wired), same shape as the
  S29/S38 tests. `scripts/verify-session-43.sh` green; `cargo test` + clippy + fmt clean.

## Guardrails
- Branch `session-43-git-level-hooks-scaffold` from `main`. New chat.
- Max 2 assumptions / 2 retries / ≤3 files / ~2h.
- To push/PR, the founder launches with `VAJRA_ALLOW_PUBLISH=1` (the publish-guard blocks the agent).

## Explicitly OUT of scope (carry-forwards)
- **Live re-dogfood of the moat** (ROADMAP #17a) — the moat + S41 compression + S42 `jq`-preflight
  are all test/replay-verified, not live-verified. Own session, costs real $.
- **cargo/npm/pytest exit-code fold gap** (S41 carry) — own compression session.
- **`.claude/settings.json` merge on init**, **silent-parse-failure blindness**, **boot cache-write
  cost** — backlog, unchanged.
- Note: **S45 is the next mandatory NO-CODE ground-truth** (every 5th; last = S40).
