# Session 38 — Propagate the publish-guard into `vajra init` (+ git-level pre-push)

> Founder pick after S37. S37 shipped `scripts/hook-publish-guard.sh` and closed the enforcement
> leak **for the vajra repo itself** — but the S36 leak happened in a **scaffolded brownfield
> project** (`/private/tmp/chitra`), which only had the three scaffolded hooks. Until the guard is
> in `vajra init`, every project Vajra scaffolds is still wide open to the exact S36 failure.
> Branch: `session-38-propagate-publish-guard`.

## The gap (proven S37)
`src/cli/init.rs` scaffolds only `hook-session-start.sh`, `hook-copilot-loader.sh`, and
`hook-session-guard.sh` into `.ai/hooks/` (see `init.rs:342-344`). It does **not** scaffold
`hook-pre-bash.sh` or the new `hook-publish-guard.sh`. So a freshly `vajra init`'d project has
**no block** on `git push` / `gh pr create` / `gh pr merge` — the S36 leak, un-fixed where it
actually occurred.

## Guiding principle
**Enforcement is the moat, and it must travel.** A scaffolded project is where real autonomous
sessions run; the guard that protects the vajra repo (S37) must be inherited by every project
`vajra init` touches. Same shape as the S29 session-guard propagation — one canonical source, a
byte-identical scaffolded copy, no hand-copy (honors S19/S22).

## Scope (1 story, ≤3 files) — confirm the slice at BOOT
**Primary slice: propagate `hook-publish-guard.sh` into `vajra init`** (the S29 pattern, exactly):
1. `const TPL_HOOK_PUBLISH_GUARD = include_str!("../../scripts/hook-publish-guard.sh")` +
   `fx(".ai/hooks/hook-publish-guard.sh", TPL_HOOK_PUBLISH_GUARD)` in the emit list (executable,
   byte-identical).
2. Add the guard to `TPL_CLAUDE_SETTINGS`'s existing PreToolUse Bash hooks array (beside the
   session-guard), pointing at `$CLAUDE_PROJECT_DIR/.ai/hooks/hook-publish-guard.sh`.
3. **Packaging (same gotcha as S22/S29):** the hook is `include_str!`'d from outside `src/` and
   `scripts/*` is excluded → `Cargo.toml` needs a per-file negation `!scripts/hook-publish-guard.sh`
   (verify via `cargo package --list`).
4. Scaffold tests: guard emitted verbatim + executable · wired into settings.json · (reuse the S29
   test shapes).

**If git-level `pre-push` is a second story, SPLIT it** (the S28 precedent) → S39. Scaffolding a
tracked `.githooks/pre-push` (block push on scaffolded projects as a belt-and-suspenders L2 layer)
touches `.githooks/` + init wiring + a `git config core.hooksPath` step — likely its own session.
Pick ONE slice this session; keep to ≤3 files.

## Proof discipline
- `cargo test` scaffold tests pass; a real `vajra init` into a temp dir emits the guard and its
  scaffolded copy actually blocks a `git push` payload at L2 (exit 2) — reuse the S29
  end-to-end pattern (`verify-session-29.sh` drove the scaffolded guard for real).
- `scripts/verify-session-38.sh` green; `cargo test` + clippy clean.
- Byte-identical check: scaffolded `.ai/hooks/hook-publish-guard.sh` == canonical
  `scripts/hook-publish-guard.sh` (the S22 `cmp`/drift guard).

## Guardrails
- Branch `session-38-propagate-publish-guard` from `main`.
- Max 2 assumptions / 2 retries / ≤3 files / ~2h. New chat (S37 → S38 boundary).
- **To push/PR this session, launch with `VAJRA_ALLOW_PUBLISH=1`** — the S37 guard now blocks the
  agent otherwise (as intended).

## Ranked follow-ons (own sessions, do NOT cram in)
- **S39** — harden the session boundary (arm the guard on *any* advance, not just `checkout -b`) —
  the other S36 enforcement slice. No prompt yet.
- Git-level `pre-push`/`pre-commit` scaffolding (if split from this session).
- Compression fail-gate, correctness-first (`prompts/39-task-fix-compression-exit-gate.md`, ready).
- Boot-packet cost trim (~$32 cache-read / $58 session — the "<5% footprint" rule).
- Publish-guard v0 limits: jq-missing fail-open, obfuscated-command evasion, per-launch (not
  per-action) approval granularity.
