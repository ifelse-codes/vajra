# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S39 complete, S40 not yet started).

## Active PRs
- S39 harden-guards PR — **pending** (founder pushes: the publish-guard blocks the agent, by design). Push: `VAJRA_ALLOW_PUBLISH=1 git push -u origin session-39-harden-guards`, then open PR to `main`.
- Merged: S38 propagate-publish-guard #33 · S37 enforce-session-boundaries [#32](https://github.com/ifelse-codes/vajra/pull/32) · S36 dogfood #31 · S34 brownfield #29 · S33 compression #27 · S32 Darshan #24 · S35 GT closeout #30.

## Direction (set S18 … dogfood-verified-live S36, enforcement-hardened S37, propagated S38, **corrected S39**)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **Enforcement is the moat, and it must be correct.** S36 proved it leaked (agent shipped 2 real PRs unstopped). S37 closed the core, S38 propagated it into `vajra init`, **S39 made the guards correct (publish-guard over-block fixed) + more complete (session-guard now arms on `vajra next --advance`, not just `checkout -b` — the S36 root cause).**
- **Next: S40 mandatory NO-CODE ground-truth, lens = enforcement-completeness** — did the S37→S39 guard work converge, or are the residual gaps real leaks? Meta-check for direction drift after three enforcement-plumbing sessions.
- **Second agent stays parked** — gate unmet + unmeasured; the S36 governance failure is being closed, not yet re-measured live.

## What Currently Works
- **Publish-guard, corrected (S39-B) — proved 13/13.** `hook-publish-guard.sh` strips quoted spans before classifying, so a trigger phrase inside a message/arg (`git commit -m "…git push…"`, `echo "gh pr create"`, `--body`) no longer false-blocks; every real unquoted `git push` / `gh pr create|merge` / `glab mr *` (incl. force, compound `cd && push`, quoted-branch-arg) still blocks at L2/L3 (exit 2). Fail-safe: over-block > leak.
- **Session-guard, armed on advance (S39-A) — proved.** `hook-session-guard.sh` now fires on `vajra next --advance` (target = `.ai/SESSION` + 1), not just `git checkout -b session-(N+1)`; same same-chat N→N+1 ownership block; quote-strips so a message can't false-arm. Fresh chat / plain `next` / a SESSION *read* all pass. Checkout boundary (S26/S29) holds, no regression.
- **Both hooks stay byte-identical in `vajra init`** — `include_str!`-embedded; the existing scaffold drift unit tests + a fresh E2E `cmp` confirm scaffolded copies == canonical after the S39 edits.
- **Publish-guard (S37) + propagation (S38), Darshan (S32/S36-confirmed), brownfield+auth (S34)** — all hold.
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` (21 files greenfield) · `vajra estimate` · `vajra meter`. `cargo test` 133 pass, clippy clean, fmt clean.

## What Is Broken
- **🟡 Publish-guard v0 limits.** Heredoc-body phrase still over-blocks (fail-safe, accepted); jq-missing → fail-open; obfuscated `g=push; git $g` evades; one env var authorizes the whole launch (coarse, not per-action).
- **🟡 Session-guard: raw `echo N > .ai/SESSION` bypass.** Deliberately out of S39-A's bounded scope (the guard arms on `vajra next --advance`, the sanctioned advance; a Bash hook can't see the Rust `fs::write`). Belongs to the git-level `pre-commit`/`pre-push` belt (ROADMAP #17).
- **🔴 No git-level `pre-push`/`pre-commit` scaffolded** (S38 split, ROADMAP #17) — L3 gates nothing beyond the `.claude/` hooks; a belt-and-suspenders L2 layer for scaffolded projects.
- **🔴 Compression dead in real use (S36, proven).** `default_engine.rs:17` fail-gate drops 30–399-line output unless `is_success`; real CC sends no `exitCode`. Fix must be correctness-first. **Ready** (`prompts/41-task-fix-compression-exit-gate.md`).
- **🟡 Budget cap didn't bite / silent-parse-failure blindness / `.claude/settings.json` merge on init** — backlog.

## What Is In Progress
- **S39 DONE + closed.** Report: `sessions/session-39-summary.md`. Hardened both guards (B: publish-guard over-block fixed; A: session-guard arms on advance) — founder-combined A+B, ordered B→A, each a separate ≤3-file commit (`08c1cfe`, `c87d302`); `verify-session-39.sh` 37/37 green; 3 files. **Next (S40)** = mandatory NO-CODE ground-truth, lens = enforcement-completeness — in a **new chat**.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 31: first real `vajra claude` dogfood since S07 (chitra; exact $ not captured).
- Session 32–35: ~$0.00 (code + GT docs sessions).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra` (agent `-p` $3.27 fable-5 + founder interactive $58.17 opus-4-8). Compression saved $0.
- Session 37: ~$0.00 — build/code session (guard authored directly, no paid `vajra claude` run).
- Session 38: ~$0.00 — build/code session (propagation authored + local E2E `vajra init`, no paid run).
- **Session 39: ~$0.00** — build/code session (both guard fixes authored directly; verified with `cargo test` + shell-driven hook payloads + a local E2E `vajra init`, no paid `vajra claude` run).
- Cumulative: ~$62. **No real `vajra claude` spend since S36 — the dogfood gate stays unmeasured (S40 must flag it).**
