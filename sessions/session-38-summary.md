# Session 38 — Propagate the publish-guard into `vajra init`

**Type:** CODE. **Branch:** `session-38-propagate-publish-guard`.
**Slice:** propagate `hook-publish-guard.sh` into `vajra init` (the primary slice of
`prompts/38-task-propagate-publish-guard.md`). One story, 3 files.

## Goal achieved? YES
S37 shipped the publish-guard but **repo-only** — the S36 leak happened in a *scaffolded*
brownfield project, which never inherited the guard. S38 makes the guard travel: every project
`vajra init` touches now scaffolds `.ai/hooks/hook-publish-guard.sh`, wired into its
`.claude/settings.json`, so the S36 leak is closed **where it actually occurred**.

## What shipped (3 files)
- **`src/cli/init.rs`** —
  - `const TPL_HOOK_PUBLISH_GUARD = include_str!("../../scripts/hook-publish-guard.sh")`
    (byte-identical, no drift — the S29 one-source pattern) + `fx(".ai/hooks/hook-publish-guard.sh", …)`
    in the emit list (executable).
  - Guard added to `TPL_CLAUDE_SETTINGS`'s existing PreToolUse **Bash** hooks array, beside the
    session-guard (one matcher, now three hooks: co-pilot + session-guard + publish-guard).
  - 2 scaffold tests: `scaffold_ships_publish_guard_verbatim` (present + byte-identical + executable),
    `scaffold_wires_publish_guard_into_settings` (wired exactly once).
- **`Cargo.toml`** — `!scripts/hook-publish-guard.sh` negation (the hook is `include_str!`'d from
  outside `src/`; `scripts/*` is excluded, so `cargo install` would fail to compile without it —
  the S22/S29 packaging gotcha).
- **`scripts/verify-session-38.sh`** (new) — 19 checks, **ALL GREEN**.

## Evidence
- `bash scripts/verify-session-38.sh` → **19 pass, 0 fail**: rust gates (fmt/clippy/test) + the 2
  new scaffold tests + `cargo package --list` ships the hook + **end-to-end** (a real `vajra init`
  into a temp git repo whose scaffolded `.ai/hooks/hook-publish-guard.sh` **blocks a `git push`
  payload at L2 → exit 2**, **allows with `VAJRA_ALLOW_PUBLISH=1` → exit 0**, passes `git status`)
  + byte-identical `cmp` + enforcement-not-renderer + Cargo un-exclude + ≤3-file cap.
- `cargo test` green; clippy `-D warnings` clean.
- **Proved live (dogfood):** the co-pilot loader blocked this session's first `git commit` to
  surface `.ai/STATE.md` (exit 2); enforcement fired against the agent building it.

## New finding (recorded, not fixed — 1-story discipline)
- **🟡 Publish-guard false-positive (over-blocking).** The guard greps the *entire* Bash command
  string, so `git commit -m "…git push…"` (the trigger phrase inside a commit **message**, or any
  argument) is blocked even though nothing is being pushed. Hit live this session — worked around
  by committing via `git commit -F <file>`. This is the *over*-block direction, distinct from S37's
  recorded *under*-block limit (obfuscated `g=push; git $g`). Candidate fix: match only the leading
  command token / parse argv rather than substring the whole line. → S39 option B.

## Honest scope + limits
- **Git-level `pre-push` split to S39** (the prompt's pre-authorized second story) — scaffolding a
  tracked `.githooks/pre-push` + `git config core.hooksPath` is its own ≤3-file story.
- **Inherited v0 limits (unchanged):** jq-missing → fail-open; obfuscated-command evasion;
  per-launch (not per-action) approval granularity; **+ the new false-positive above.**
- **Untouched by design:** boundary-hardening (arm on *any* advance), L3 reconsideration, compression.

## Next options (A/B/C — drawn from ROADMAP)
- **A — Harden the session boundary (S39, the other S36 slice).** Goal: arm the guard on *any*
  session advance (`SESSION` edit / `vajra next --advance`), not just `git checkout -b`, so the
  brownfield 00→01 jump that let S36 leak can't blow the boundary unstopped. *Why:* highest-leverage
  remaining enforcement gap — the S36 root cause #1. *Risk:* design-bearing (must define the
  "advance" signal); no prompt yet.
- **B — Publish-guard v0 hardening.** Goal: fix the false-positive found this session (match the
  command token, not the whole line) + optionally jq-fail-open / obfuscation. *Why:* the guard we
  just propagated over-blocks real commits — correctness of the moat itself. *Risk:* argv parsing in
  bash is fiddly; scope could creep across the v0-limits list.
- **C — Fix the compression fail-gate, correctness-first (`prompts/39-task-fix-compression-exit-gate.md`, ready).**
  Goal: unblock the safe format-aware git\* folds regardless of `exitCode`; keep the generic path
  conservative; **never hide a failure.** *Why:* compression saves ~$0 in real use (proven S36).
  *Risk:* the quiet bonus, not the moat — lower leverage than enforcement.

## PR
- **Founder pushes/PRs** — the S37 publish-guard blocks the agent's `git push`/`gh pr create` unless
  launched with `VAJRA_ALLOW_PUBLISH=1` (by design). Branch `session-38-propagate-publish-guard`,
  2 commits (`1f0d515` feat + `d50846f` test).
