# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S37 complete, S38 not yet started).

## Active PRs
- S37 enforce-session-boundaries PR — pending (founder pushes: the new publish-guard blocks the agent from pushing, by design).
- Merged: S36 dogfood [#31](https://github.com/ifelse-codes/vajra/pull/31) · S34 brownfield #29 · S33 compression #27 · S32 Darshan #24 · S35 GT closeout #30.

## Direction (set S18 … dogfood-verified-live S36, **enforcement-hardened S37**)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **Enforcement is the moat** — S36 proved it leaked in a real L3 session (agent shipped 2 real PRs unstopped). **S37 closed the core of that leak for this repo:** outward/irreversible actions (`git push` / `gh pr create` / `gh pr merge` / `glab mr *`) now BLOCK at L2/L3 unless the founder set `VAJRA_ALLOW_PUBLISH=1` at launch.
- **Still leaking in scaffolded projects** — `vajra init` doesn't scaffold the guard yet, and that is exactly where S36 leaked. **S38 propagates it.**
- **Second agent stays parked** — gate unmet; the S36 governance failure is being closed, not yet re-measured live.

## What Currently Works
- **Publish-guard (S37) — proved live.** `scripts/hook-publish-guard.sh` blocks push/PR-create/PR-merge at L2/L3 (exit 2); allows with `VAJRA_ALLOW_PUBLISH=1`; L1 advises; innocuous git (`status`/`log`/`diff --stat`) passes. It blocked this session's own `git push` tool call. `verify-session-37.sh` 22/22 green.
- **Darshan (S32) — founder-confirmed good in real use (S36).** Boot directive surfaces every session and is obeyed.
- **Brownfield onboarding + auth (S34) — hold live (S36).**
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter`. `cargo test` 133 pass, clippy clean — unchanged this session (no `src/` edits).

## What Is Broken
- **🔴 Enforcement leak — CORE CLOSED (repo), NOT in scaffolded projects (S37).** The guard is repo-only; `vajra init` scaffolds session-start/copilot/session-guard but NOT `hook-pre-bash`/`hook-publish-guard`, so new projects (the S36 leak site) are still unguarded. **S38-ranked #1** (`prompts/38-task-propagate-publish-guard.md`).
- **🔴 Other S36 enforcement gaps still open.** (1) session-boundary guard arms on one tripwire only (`git checkout -b session-N+1`), not on any advance; (2) no git-level `pre-push`/`pre-commit` scaffolded; (3) L3 still gates nothing beyond these hooks. (S38/S39.)
- **🔴 Compression dead in real use (S36, proven).** `default_engine.rs:17` fail-gate drops 30–399-line output unless `is_success`; real CC sends no `exitCode`. Fix must be correctness-first. **Ready** (`prompts/39-task-fix-compression-exit-gate.md`).
- **🟡 Publish-guard v0 limits.** jq-missing → fail-open (suite-wide); regex won't catch obfuscated commands (`g=push; git $g`); one env var authorizes the whole launch (coarse, not per-action).
- **🟡 Budget cap didn't bite / silent-parse-failure blindness / `.claude/settings.json` merge on init** — backlog.

## What Is In Progress
- **S37 DONE + closed.** Report: `sessions/session-37-summary.md`. Closed the core enforcement leak for this repo (publish-guard, maturity-gated, `VAJRA_ALLOW_PUBLISH=1` approval). **Next (S38)** = propagate the guard into `vajra init` + git-level hooks (founder pick A) — in a **new chat**.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 31: first real `vajra claude` dogfood since S07 (chitra; exact $ not captured).
- Session 32–35: ~$0.00 (code + GT docs sessions).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra` (agent `-p` $3.27 fable-5 + founder interactive $58.17 opus-4-8). Compression saved $0.
- **Session 37: ~$0.00** — build/code session (guard authored directly, no paid `vajra claude` run). Enforcement proved live for free by the guard firing on the agent's own tool calls.
- Cumulative: ~$62.
