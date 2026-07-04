# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
`session-43-git-level-hooks-scaffold` — S43 (git-level belt scaffolded into `vajra init`) complete;
commits `7a9ef90` (feature: init.rs + Cargo.toml) + `0f5f565` (proof: verify). PR pending (founder
pushes — the publish-guard blocks the agent, by design). (Between vajra-sessions otherwise: S44 not
yet started.)

## Active PRs
- S43 git-level-hooks-scaffold PR — **pending** (founder pushes: the publish-guard blocks the agent).
  Push: `VAJRA_ALLOW_PUBLISH=1 git push -u origin session-43-git-level-hooks-scaffold`, then open PR to `main`.
- Merged: S42 `jq`-preflight [#37](https://github.com/ifelse-codes/vajra/pull/37) · S41 compression
  fail-gate [#36](https://github.com/ifelse-codes/vajra/pull/36) · S40 GT closeout [#35](https://github.com/ifelse-codes/vajra/pull/35)
  · S39 harden-guards [#34](https://github.com/ifelse-codes/vajra/pull/34) · S38 propagate-publish-guard #33.

## Direction (set S18 … enforcement-hardened S37–S39, audited S40, compression fixed S41, jq fail-closed S42, git-belt scaffolded S43)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **Enforcement is the moat — S40 verdict stands: the S36 harm is closed, the proof is not.** Every S36
  outward action (push / 2× PR create+merge) BLOCKS, scaffolded (S38); the moat is **test-verified, not
  live-verified** — the dogfood gate is UNMEASURED (~$0 `vajra claude` since S36). A live re-dogfood
  (ROADMAP #17a) stays the missing verification.
- **S43 added the git-level L2 belt to scaffolded projects** — `vajra init` now scaffolds
  `.githooks/pre-commit` + `pre-push` + `core.hooksPath`, an independent layer beneath the L3
  `.claude/` hooks. Closes the raw `echo > .ai/SESSION` / direct-commit / direct-push bypass at the
  right layer. Enforcement-completeness (the S40 finding #2, bounded + high-leverage).
- **S42 closed the constitution 🔴** — the `jq`-missing → fail-open leak is fail-closed on all 5
  `jq`-parsing hooks. **S41 fixed the compression fail-gate, correctness-first** — the git family folds
  regardless of `exitCode`; the generic path stays conservative.
- **Second agent stays parked** — cross-agent breadth still zero code (S25, 18 sessions stale); the
  S40 meta-check flags Claude-only depth accumulating.

## What Currently Works
- **Git-level belt scaffolded into `vajra init` (S43).** `src/cli/init.rs` emits `.githooks/pre-commit`
  + `pre-push` byte-identical to the canonical `.githooks/*` (via `include_str!`, one source) + sets
  `core.hooksPath=.githooks` (`configure_githooks_path`: idempotent — existing hooksPath left as-is;
  non-git dir = documented no-op). `.githooks` in the dir-creation list + `SCAFFOLD_OWNED`; `Cargo.toml`
  un-excludes both files. An independent **L2** layer beneath the L3 `.claude/` hooks. verify-session-43.sh
  22/22 (real `vajra init` into a temp git repo: byte-identical + executable + hooksPath set; scaffolded
  pre-commit BLOCKS on-main/>3-staged/`.ai/`-drift, pre-push BLOCKS push-to-main, clean cases pass;
  non-git degrades; packaging ships both). **NOTE (intended):** after `vajra init` on a fresh greenfield
  repo on `main`, the first `git commit` is blocked by the scaffolded main-guard — branch `session-NN-*`
  first (byte-identical to Vajra's own belt).
- **`jq`-preflight, fail-closed on all 5 `jq`-parsing hooks (S42).** `jq` missing → L2/L3 `exit 2`
  (block), L1 `exit 0` (advise); reads maturity via `grep`/`awk`, travels inside the `include_str!`'d
  copies. verify-session-42.sh 31/31.
- **Compression folds the git family regardless of `exitCode` (S41).** The fail-gate applies only when
  `!heuristic.preserves_failure_signal()`; the git family declares it `true`. verify-session-41.sh 20/20.
- **Publish-guard, correct + scaffolded (S37→S39-B).** Blocks `git push` / `gh pr create|merge` / `glab mr *`
  at L2/L3 unless `VAJRA_ALLOW_PUBLISH=1`; strips quoted spans first. **Session-guard, armed on advance
  (S39-A) + scaffolded (S29).** Fires on `git checkout -b session-(N+1)` and `vajra next --advance`.
- **The vajra repo's own git belt** — `.githooks/pre-commit` + `pre-push`, `core.hooksPath=.githooks`.
  **NOW scaffolded into `vajra init` too (S43).**
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter`.
  `cargo test` 111 lib (+4) + 12 adapter + integration pass; clippy clean; fmt clean.

## What Is Broken
- **🔴 Brownfield `.claude/settings.json` skipped on init → L3 hooks never wired (S34 finding → S44).**
  A brownfield repo that already has `.claude/settings.json` gets it *skipped* (skip-if-present) → the
  scaffolded `.ai/hooks/` are never fired → the whole L3 enforcement moat is silently absent for exactly
  the primary use case. **Next session (founder pick B).**
- **🟡 cargo/npm/pytest never fold on real CC (S33/S41 carry).** Those heuristics branch on
  `exit_code == Some(0)`, which real CC never sends → `_fail` passthrough under 300/400 lines. Own future
  compression session.
- **🟡 Accepted publish-guard v0 limits.** Heredoc-body phrase over-blocks (fail-safe); obfuscated
  `g=push; git $g` evades (non-adversarial threat model); one env var authorizes the whole launch (coarse).
- **🟡 Budget cap didn't bite / silent-parse-failure blindness / boot-packet cost** — backlog.

## What Is In Progress
- **S43 DONE + closed.** Git-level belt scaffolded into `vajra init` (`7a9ef90` + `0f5f565`); verify
  22/22; ~$0. Founder pick for next: **S44 = `.claude/settings.json` merge on init (pick B).** **Next
  (S44)** = `prompts/44-task-settings-json-merge.md` — in a **new chat**.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 31: first real `vajra claude` dogfood since S07 (chitra; exact $ not captured).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra`. Compression saved $0.
- Session 32–35, 37–43: ~$0.00 each — build/code + NO-CODE GT sessions; S41–S43 proven via replay /
  `PATH`-shim / temp-repo E2E, no paid `vajra claude` run.
- Cumulative: ~$62. **No real `vajra claude` spend since S36 — the dogfood gate stays UNMEASURED
  (S40 flagged it; live re-verify still owed for the S41 compression + S42 `jq` + S43 git-belt changes).**
