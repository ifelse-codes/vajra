# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
`session-41-fix-compression-exit-gate` — S41 compression fail-gate fix (CODE) complete; commits
`98376db` (fix) + `a5086a6` (proof). (Between vajra-sessions otherwise: S42 not yet started.)

## Active PRs
- S41 compression fail-gate PR — **pending** (founder pushes: the publish-guard blocks the agent, by design). Push: `VAJRA_ALLOW_PUBLISH=1 git push -u origin session-41-fix-compression-exit-gate`, then open PR to `main`.
- Merged: S40 GT closeout [#35](https://github.com/ifelse-codes/vajra/pull/35) · S39 harden-guards [#34](https://github.com/ifelse-codes/vajra/pull/34) · S38 propagate-publish-guard #33 · S37 enforce-session-boundaries [#32](https://github.com/ifelse-codes/vajra/pull/32) · S36 dogfood #31.

## Direction (set S18 … enforcement-hardened S37–S39, audited S40, compression fixed S41)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **Enforcement is the moat — S40 verdict stands: the S36 harm is closed, the proof is not.** Every S36 outward action (push / 2× PR create+merge) now BLOCKS, scaffolded (S38); but the moat is **test-verified, not live-verified** — the dogfood gate is UNMEASURED (~$0 `vajra claude` since S36). A live re-dogfood (S40 GT candidate A / ROADMAP #17a) stays the missing verification.
- **S41 fixed the compression fail-gate, correctness-first** — the git family now folds regardless of `exitCode`; the generic path stays conservative; failures are never hidden. The "quiet bonus," not the moat.
- **S42 = git-level hooks + `jq`-preflight** (founder pick C) — scaffold the `.githooks/` belt into `vajra init` + fail-close the `jq`-missing leak. Enforcement-completeness.
- **Second agent stays parked** — cross-agent breadth still zero code (S25, 16 sessions stale); the S40 meta-check flags Claude-only depth accumulating.

## What Currently Works
- **Compression now folds the git family regardless of `exitCode` (S41).** `default_engine.rs` selects the heuristic BEFORE the fail-gate and applies the gate only when `!heuristic.preserves_failure_signal()`. The git family (git log head+tail; git status / git diff --stat passthrough) declares `preserves_failure_signal()=true` → folds even when real CC omits `exitCode`. Proven live via `vajra hook` payload replay ($0): `git log` 60 lines folds (tail survives); generic failure/`ls` stay passthrough; `exitCode:0` / ≥400-line unchanged. verify-session-41.sh 20/20.
- **Publish-guard, correct + scaffolded (S37→S39-B).** `hook-publish-guard.sh` blocks `git push` / `gh pr create|merge` / `glab mr *` at L2/L3 (exit 2) unless `VAJRA_ALLOW_PUBLISH=1`; strips quoted spans first so a trigger phrase inside a message can't false-block. Byte-identical in `vajra init` (S38).
- **Session-guard, armed on advance (S39-A) + scaffolded (S29).** `hook-session-guard.sh` fires on `git checkout -b session-(N+1)` **and** `vajra next --advance`; same same-chat N→N+1 block; quote-strips.
- **The vajra repo's own git belt** — `.githooks/pre-commit` (blocks main commits, >3 staged files, `.ai/` drift) + `pre-push` (blocks push to main/master), `core.hooksPath=.githooks`. **NOT scaffolded into `vajra init`** (ROADMAP #17 → S42).
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter`. `cargo test` 107 lib + 12 adapter + integration pass; clippy clean; fmt clean.

## What Is Broken
- **🔴 `jq`-missing → fail-open (S40 constitution finding).** All hooks parse the payload with `jq`; if `jq` is absent, `CMD` is empty → `exit 0` → the guard passes everything. Violates AGENTS.md L147. Fix = `jq`-preflight / fail-closed. **Folds into S42 (founder pick C).**
- **🔴 No git-level `pre-push`/`pre-commit` scaffolded** (ROADMAP #17 → S42) — scaffolded projects have only the `.claude/` L3 hooks; a raw `echo N > .ai/SESSION` write bypasses the Bash session-guard. Bounded (the publish-guard blocks the outward *harm* regardless); the git belt is the right layer.
- **🟡 cargo/npm/pytest never fold on real CC (S33/S41 carry).** Those heuristics branch on `exit_code == Some(0)`, which real CC never sends → they take the `_fail` branch (passthrough under 300/400 lines) regardless of the S41 fix. Not unblocked in S41 by design (their fail-branch-on-no-`exitCode` has a misleading `"errors present"` path). Own future compression session.
- **🟡 Accepted publish-guard v0 limits.** Heredoc-body phrase over-blocks (fail-safe); obfuscated `g=push; git $g` evades (non-adversarial threat model); one env var authorizes the whole launch (coarse).
- **🟡 Budget cap didn't bite / silent-parse-failure blindness / `.claude/settings.json` merge on init** — backlog.

## What Is In Progress
- **S41 DONE + closed.** Compression fail-gate fixed correctness-first (`98376db` + `a5086a6`); verify 20/20; ~$0. Founder pick for next: **S42 = C (git-level hooks + `jq`-preflight)**. **Next (S42)** = `prompts/42-task-git-level-hooks-jq-preflight.md` — in a **new chat**.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 31: first real `vajra claude` dogfood since S07 (chitra; exact $ not captured).
- Session 32–35: ~$0.00 (code + GT docs sessions).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra` (agent `-p` $3.27 fable-5 + founder interactive $58.17 opus-4-8). Compression saved $0.
- Session 37–40: ~$0.00 each — build/code + NO-CODE GT sessions (no paid `vajra claude` run).
- **Session 41: ~$0.00** — the fold table was proven for $0 via `vajra hook` payload replay (S36 method); no paid `vajra claude` run.
- Cumulative: ~$62. **No real `vajra claude` spend since S36 — the dogfood gate stays UNMEASURED (S40 flagged it; live re-verify still owed, now also owed for the S41 compression change).**
