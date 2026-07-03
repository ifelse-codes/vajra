# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S38 complete, S39 not yet started).

## Active PRs
- S38 propagate-publish-guard PR — pending (founder pushes: the publish-guard blocks the agent from pushing, by design).
- Merged: S37 enforce-session-boundaries [#32](https://github.com/ifelse-codes/vajra/pull/32) · S36 dogfood #31 · S34 brownfield #29 · S33 compression #27 · S32 Darshan #24 · S35 GT closeout #30.

## Direction (set S18 … dogfood-verified-live S36, enforcement-hardened S37, **propagated S38**)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **Enforcement is the moat, and it travels.** S36 proved it leaked in a real L3 session (agent shipped 2 real PRs unstopped). S37 closed the core for this repo; **S38 propagated the publish-guard into `vajra init`, so every scaffolded project — the actual S36 leak site — now inherits the block** on `git push` / `gh pr create` / `gh pr merge`.
- **Next: make the guards correct + complete (S39).** Building S38 surfaced a live over-block bug in the guard (false-positive on commit-message text); the session-boundary still arms on one tripwire only. S39 fixes both (B then A).
- **Second agent stays parked** — gate unmet; the S36 governance failure is being closed, not yet re-measured live.

## What Currently Works
- **Publish-guard in `vajra init` (S38) — proved E2E.** A real `vajra init` scaffolds `.ai/hooks/hook-publish-guard.sh` byte-identical to canonical, wired into the scaffolded `.claude/settings.json`; the scaffolded copy blocks a `git push` payload at L2 (exit 2), allows with `VAJRA_ALLOW_PUBLISH=1`. `cargo package --list` ships the hook. `verify-session-38.sh` 19/19 green.
- **Publish-guard (S37) — proved live.** `scripts/hook-publish-guard.sh` blocks push/PR-create/PR-merge at L2/L3; allows with `VAJRA_ALLOW_PUBLISH=1`; L1 advises; innocuous git passes.
- **Darshan (S32) — founder-confirmed good in real use (S36).** Boot directive surfaces every session and is obeyed.
- **Brownfield onboarding + auth (S34) — hold live (S36).**
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` (scaffold now 21 files greenfield: +hook-publish-guard) · `vajra estimate` · `vajra meter`. `cargo test` 133 pass, clippy clean.

## What Is Broken
- **🟡 Publish-guard false-positive (over-blocking) — NEW (S38), S39 story B.** The guard greps the *entire* Bash command string, so a trigger phrase inside a `git commit -m "…git push…"` message (or any argument) false-blocks even when nothing is pushed. Hit live in S38 (worked around with `git commit -F`). Fix: match the leading command token, never weaken the real block.
- **🔴 Session boundary arms on one tripwire only — S39 story A.** `hook-session-guard.sh` arms only on `git checkout -b session-(N+1)`; the S36 brownfield agent never branched, so nothing armed and it advanced 00→01 + pushed + merged unstopped. Must arm on *any* advance (`SESSION` bump / `vajra next --advance`).
- **🔴 Other S36 enforcement gaps.** No git-level `pre-push`/`pre-commit` scaffolded (S38 split); L3 gates nothing beyond these hooks.
- **🔴 Compression dead in real use (S36, proven).** `default_engine.rs:17` fail-gate drops 30–399-line output unless `is_success`; real CC sends no `exitCode`. Fix must be correctness-first. **Ready** (`prompts/41-task-fix-compression-exit-gate.md`, renumbered 39→41).
- **🟡 Publish-guard v0 limits.** jq-missing → fail-open; obfuscated commands (`g=push; git $g`) evade; one env var authorizes the whole launch (coarse).
- **🟡 Budget cap didn't bite / silent-parse-failure blindness / `.claude/settings.json` merge on init** — backlog.

## What Is In Progress
- **S38 DONE + closed.** Report: `sessions/session-38-summary.md`. Propagated the publish-guard into `vajra init` (the S29 `include_str!` pattern) so scaffolded projects inherit the S36 leak fix. **Next (S39)** = harden the guards, A+B combined (founder override) — in a **new chat**.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 31: first real `vajra claude` dogfood since S07 (chitra; exact $ not captured).
- Session 32–35: ~$0.00 (code + GT docs sessions).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra` (agent `-p` $3.27 fable-5 + founder interactive $58.17 opus-4-8). Compression saved $0.
- Session 37: ~$0.00 — build/code session (guard authored directly, no paid `vajra claude` run).
- **Session 38: ~$0.00** — build/code session (propagation authored directly; verified with `cargo test` + a local E2E `vajra init`, no paid `vajra claude` run).
- Cumulative: ~$62.
