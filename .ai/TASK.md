# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 43 — Git-level hooks scaffolding into `vajra init` (CODE, founder pick C carry) — COMPLETE

- **Delivered:** the git-level belt scaffolded into `vajra init` (ROADMAP #17b). `src/cli/init.rs`
  emits `.githooks/pre-commit` + `pre-push` byte-identical to canonical (via `include_str!`, one
  source) + sets `core.hooksPath=.githooks` (`configure_githooks_path` — idempotent, graceful on
  non-git). `Cargo.toml` un-excludes both files. An independent **L2** layer beneath the L3
  `.claude/` hooks — closes the raw `echo > .ai/SESSION` / direct-commit / direct-push bypass.
- **Evidence:** `verify-session-43.sh` 22/22 (real `vajra init` into a temp git repo: byte-identical
  + executable + `core.hooksPath` set; scaffolded pre-commit BLOCKS on-main/>3-staged/`.ai/`-drift;
  pre-push BLOCKS push-to-main; non-git degrades gracefully; packaging ships both); `cargo test`
  111 lib (+4) + 12 adapter; clippy + fmt clean. Commits `7a9ef90` + `0f5f565`.

Between sessions. Next = S44 (CODE — `.claude/settings.json` merge on init, founder pick B).

## Next Session (S44 — CODE, founder pick B)

- **Prompt (ready):** `prompts/44-task-settings-json-merge.md` — `vajra init` merges Vajra's hooks
  into an existing `.claude/settings.json` instead of skipping it, so brownfield projects that
  already have one get the L3 hooks wired (today the enforcement moat is silently absent for that
  use case). Additive + idempotent; same class as the ADR-0003 launcher `--settings` merge.
- **Branch:** `session-44-settings-json-merge`.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S40; next = S45).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S44; do NOT start it here.
- **Enforcement is the moat** — S37→S39 closed the S36 harm; S40 audited it (harm closed, proof
  UNMEASURED); S41 fixed compression; S42 closed the `jq` fail-open; **S43 added the git-level L2
  belt to scaffolded projects; S44 wires the moat into brownfield repos that already own a
  `.claude/settings.json`.**
- **To publish from an agent session, the founder must launch with `VAJRA_ALLOW_PUBLISH=1`** (the
  guard blocks the agent otherwise, by design).
