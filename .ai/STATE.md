# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
`session-40-closeout` — S40 ground-truth (NO-CODE) complete; doc-only, suffix-exempt. (Between vajra-sessions otherwise: S41 not yet started.)

## Active PRs
- S40 GT closeout PR — **pending** (founder pushes: the publish-guard blocks the agent, by design). Push: `VAJRA_ALLOW_PUBLISH=1 git push -u origin session-40-closeout`, then open PR to `main`.
- Merged: S39 harden-guards [#34](https://github.com/ifelse-codes/vajra/pull/34) · S38 propagate-publish-guard #33 · S37 enforce-session-boundaries [#32](https://github.com/ifelse-codes/vajra/pull/32) · S36 dogfood #31 · S35 GT closeout #30.

## Direction (set S18 … enforcement-hardened S37, propagated S38, corrected S39, **audited S40**)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **Enforcement is the moat — S40 verdict: the harm the S36 leak caused is closed, the proof is not.** Every S36 outward action (push / 2× PR create+merge) now BLOCKS, scaffolded (S38); but the moat is **test-verified, not live-verified** — the dogfood gate is UNMEASURED (~$0 `vajra claude` since S36).
- **S41 = compression fail-gate, correctness-first** (founder pick B); **S42 = git-level hooks scaffolding + `jq`-preflight** (founder pick C). A live re-dogfood (GT candidate A, not picked) stays the missing verification of the moat.
- **Second agent stays parked** — cross-agent breadth still zero code (S25, 15 sessions stale); the S40 meta-check flags Claude-only depth accumulating.

## What Currently Works
- **Publish-guard, correct + scaffolded (S37→S39-B).** `hook-publish-guard.sh` blocks `git push` (any form) / `gh pr create|merge` / `glab mr *` at L2/L3 (exit 2) unless `VAJRA_ALLOW_PUBLISH=1`; strips quoted spans first so a trigger phrase inside a message/arg no longer false-blocks. Scaffolded byte-identical into `vajra init` (S38). **S40 confirmed: every S36 outward action now blocks.**
- **Session-guard, armed on advance (S39-A) + scaffolded (S29).** `hook-session-guard.sh` fires on `git checkout -b session-(N+1)` **and** `vajra next --advance` (target = `.ai/SESSION`+1); same same-chat N→N+1 block; quote-strips so a message can't false-arm. **S40 live data point:** creating `session-40-closeout` did NOT false-block (same-session-number checkout allowed correctly).
- **Both guards byte-identical in `vajra init`** — `include_str!`-embedded; scaffold-drift unit tests hold.
- **The vajra repo's own git belt** — `.githooks/pre-commit` (blocks main commits, >3 staged files, `.ai/` drift) + `pre-push` (blocks push to main/master), `core.hooksPath=.githooks`. **NOT scaffolded into `vajra init`** (ROADMAP #17 → S42/C).
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter`. `cargo test` 133 pass, clippy clean, fmt clean.

## What Is Broken
- **🔴 `jq`-missing → fail-open (S40 constitution finding).** All hooks parse the payload with `jq`; if `jq` is absent, `CMD` is empty → `exit 0` → the guard passes everything. Violates AGENTS.md L147 ("a check that cannot evaluate FAILS; never silently pass"). Fix = `jq`-preflight / fail-closed. **Folds into S42/C.**
- **🔴 No git-level `pre-push`/`pre-commit` scaffolded** (ROADMAP #17 → S42/C) — scaffolded projects have only the `.claude/` L3 hooks; a raw `echo N > .ai/SESSION` write bypasses the Bash session-guard. Bounded (the publish-guard blocks the outward *harm* regardless); the git belt is the right layer.
- **🔴 Compression dead in real use (S36, proven).** `default_engine.rs:17` fail-gate drops 30–399-line output unless `is_success`; real CC sends no `exitCode`. **S41 fixes it, correctness-first** (`prompts/41-task-fix-compression-exit-gate.md`).
- **🟡 Accepted publish-guard v0 limits.** Heredoc-body phrase over-blocks (fail-safe); obfuscated `g=push; git $g` evades (non-adversarial threat model); one env var authorizes the whole launch (coarse, not per-action).
- **🟡 Budget cap didn't bite / silent-parse-failure blindness / `.claude/settings.json` merge on init** — backlog.

## What Is In Progress
- **S40 DONE + closed.** Ground-truth report: `sessions/session-40-ground-truth.md` (8 audits + lens-A leak/limit ranking + dogfood verdict + 3 ranked candidates). Founder pick: **S41 = B (compression), S42 = C (git-level hooks + jq fix).** **Next (S41)** = compression fail-gate, correctness-first — in a **new chat**.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 31: first real `vajra claude` dogfood since S07 (chitra; exact $ not captured).
- Session 32–35: ~$0.00 (code + GT docs sessions).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra` (agent `-p` $3.27 fable-5 + founder interactive $58.17 opus-4-8). Compression saved $0.
- Session 37–39: ~$0.00 each — build/code sessions (guards authored + verified via `cargo test` + shell-driven hook payloads + local E2E `vajra init`, no paid `vajra claude` run).
- **Session 40: ~$0.00** — NO-CODE ground-truth (audit + doc closeout only).
- Cumulative: ~$62. **No real `vajra claude` spend since S36 — the dogfood gate stays UNMEASURED (S40 flagged it; live re-verify still owed).**
