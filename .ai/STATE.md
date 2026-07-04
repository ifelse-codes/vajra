# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
`session-42-git-level-hooks-jq-preflight` — S42 Gap 1 (`jq`-preflight, fail-closed) complete;
commits `f3778b5` (3 scaffolded enforce hooks) + `f15edb6` (2 repo GT hooks + verify). Gap 2
(git-level scaffold) carried to S43. (Between vajra-sessions otherwise: S43 not yet started.)

## Active PRs
- S42 `jq`-preflight PR — **pending** (founder pushes: the publish-guard blocks the agent, by design). Push: `VAJRA_ALLOW_PUBLISH=1 git push -u origin session-42-git-level-hooks-jq-preflight`, then open PR to `main`.
- Merged: S41 compression fail-gate [#36](https://github.com/ifelse-codes/vajra/pull/36) · S40 GT closeout [#35](https://github.com/ifelse-codes/vajra/pull/35) · S39 harden-guards [#34](https://github.com/ifelse-codes/vajra/pull/34) · S38 propagate-publish-guard #33 · S37 enforce-session-boundaries [#32](https://github.com/ifelse-codes/vajra/pull/32).

## Direction (set S18 … enforcement-hardened S37–S39, audited S40, compression fixed S41, jq fail-closed S42)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **Enforcement is the moat — S40 verdict stands: the S36 harm is closed, the proof is not.** Every S36 outward action (push / 2× PR create+merge) now BLOCKS, scaffolded (S38); the moat is **test-verified, not live-verified** — the dogfood gate is UNMEASURED (~$0 `vajra claude` since S36). A live re-dogfood (S40 GT candidate A / ROADMAP #17a) stays the missing verification.
- **S42 closed the constitution 🔴** — the suite-wide `jq`-missing → fail-open leak (AGENTS.md L147) is now fail-closed on all 5 `jq`-parsing hooks; a `jq`-less environment blocks (L2/L3) instead of passing everything. Enforcement-completeness.
- **S41 fixed the compression fail-gate, correctness-first** — the git family folds regardless of `exitCode`; the generic path stays conservative; failures never hidden. The "quiet bonus," not the moat.
- **Second agent stays parked** — cross-agent breadth still zero code (S25, 17 sessions stale); the S40 meta-check flags Claude-only depth accumulating.

## What Currently Works
- **`jq`-preflight, fail-closed on all 5 `jq`-parsing hooks (S42).** A byte-identical block after `set -euo pipefail` in `hook-publish-guard` / `hook-session-guard` / `hook-copilot-loader` / `hook-pre-bash` / `hook-pre-write`: `jq` missing → L2/L3 `exit 2` (block), L1 `exit 0` (advise). Reads maturity via `grep`/`awk` (own `_VROOT`/`_VMAT` locals, not `jq`), so it travels inside the `include_str!`'d hook copies — the 3 scaffolded hooks inherit it with no `init.rs` change. verify-session-42.sh 31/31 (5 hooks under a `jq`-less `PATH` shim; zero regression with `jq` present; block identical across all 5; `vajra init` scaffolds it baked in).
- **Compression folds the git family regardless of `exitCode` (S41).** `default_engine.rs` selects the heuristic BEFORE the fail-gate and applies the gate only when `!heuristic.preserves_failure_signal()`. The git family (git log head+tail; git status / git diff --stat passthrough) declares it `true` → folds even when real CC omits `exitCode`. verify-session-41.sh 20/20.
- **Publish-guard, correct + scaffolded (S37→S39-B).** Blocks `git push` / `gh pr create|merge` / `glab mr *` at L2/L3 (exit 2) unless `VAJRA_ALLOW_PUBLISH=1`; strips quoted spans first. Byte-identical in `vajra init` (S38).
- **Session-guard, armed on advance (S39-A) + scaffolded (S29).** Fires on `git checkout -b session-(N+1)` **and** `vajra next --advance`; same-chat N→N+1 block; quote-strips.
- **The vajra repo's own git belt** — `.githooks/pre-commit` (blocks main commits, >3 staged files, `.ai/` drift) + `pre-push` (blocks push to main/master), `core.hooksPath=.githooks`. **NOT YET scaffolded into `vajra init`** (ROADMAP #17b → S43).
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter`. `cargo test` 107 lib + 12 adapter + integration pass; clippy clean; fmt clean.

## What Is Broken
- **🔴 No git-level `pre-push`/`pre-commit` scaffolded** (ROADMAP #17b → S43) — scaffolded projects have only the `.claude/` L3 hooks; a raw `echo N > .ai/SESSION` write bypasses the Bash session-guard. Bounded (the publish-guard blocks the outward *harm* regardless); the git belt is the right layer. **Next session.**
- **🟡 cargo/npm/pytest never fold on real CC (S33/S41 carry).** Those heuristics branch on `exit_code == Some(0)`, which real CC never sends → they take the `_fail` branch (passthrough under 300/400 lines) regardless of the S41 fix. Not unblocked in S41 by design (misleading `"errors present"` path). Own future compression session.
- **🟡 Accepted publish-guard v0 limits.** Heredoc-body phrase over-blocks (fail-safe); obfuscated `g=push; git $g` evades (non-adversarial threat model); one env var authorizes the whole launch (coarse).
- **🟡 Budget cap didn't bite / silent-parse-failure blindness / `.claude/settings.json` merge on init** — backlog.

## What Is In Progress
- **S42 Gap 1 DONE + closed.** `jq`-preflight fail-closed on all 5 hooks (`f3778b5` + `f15edb6`); verify 31/31; ~$0. Gap 2 (git-level scaffold) carried. Founder pick for next: **S43 = Gap 2 (git-level hooks scaffolding into `vajra init`)**. **Next (S43)** = `prompts/43-task-git-level-hooks-scaffold.md` — in a **new chat**.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 31: first real `vajra claude` dogfood since S07 (chitra; exact $ not captured).
- Session 32–35: ~$0.00 (code + GT docs sessions).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra` (agent `-p` $3.27 fable-5 + founder interactive $58.17 opus-4-8). Compression saved $0.
- Session 37–40: ~$0.00 each — build/code + NO-CODE GT sessions (no paid `vajra claude` run).
- Session 41: ~$0.00 — fold table proven for $0 via `vajra hook` payload replay (S36 method).
- **Session 42: ~$0.00** — `jq`-preflight proven via `PATH`-shim under `verify-session-42.sh`; no paid `vajra claude` run.
- Cumulative: ~$62. **No real `vajra claude` spend since S36 — the dogfood gate stays UNMEASURED (S40 flagged it; live re-verify still owed, now also owed for the S41 compression + S42 `jq` changes).**
