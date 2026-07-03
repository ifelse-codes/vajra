# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 38 — Propagate the publish-guard into `vajra init` — COMPLETE

- `src/cli/init.rs` now scaffolds `hook-publish-guard.sh` into `.ai/hooks/` via `include_str!` (byte-identical), wired into `TPL_CLAUDE_SETTINGS`'s PreToolUse Bash array; `Cargo.toml` un-excludes the hook so `cargo install` compiles it. Every scaffolded project inherits the block on `git push` / `gh pr create` / `gh pr merge` — the S36 leak closed where it actually happened.
- **Proved E2E** — a real `vajra init` into a temp repo scaffolds the guard byte-identical and it blocks a `git push` payload at L2 (exit 2). `verify-session-38.sh` 19/19 green. 3 files.
- **New finding (recorded):** the publish-guard over-blocks on a trigger phrase inside a commit message → S39 story B.
- Report: `sessions/session-38-summary.md`.

Between sessions. Next = S39 (harden the guards — founder combined A+B).

## Next Session (S39 — harden the guards, A+B combined)

- **Prompt (ready):** `prompts/39-task-harden-guards.md` — **B first** (fix the publish-guard false-positive: match the command token, not the whole line), **then A** (arm the session-guard on *any* advance, not just `checkout -b` — the S36 root cause). Deliberate owner override of `max 1 story`; ordered so B banks first.
- **Then:** S40 = mandatory NO-CODE ground-truth. S41 (leading) = compression fail-gate (`prompts/41-task-fix-compression-exit-gate.md`).

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S35; **next = S40**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S39; do NOT branch/plan it here.
- **Enforcement is the moat** — S37 closed the leak for this repo; S38 closed it in scaffolded projects; S39 makes the guards *correct* (fix over-block) + *complete* (arm on any advance).
- **To publish from an agent session, the founder must launch with `VAJRA_ALLOW_PUBLISH=1`** (the guard blocks the agent otherwise, by design).
