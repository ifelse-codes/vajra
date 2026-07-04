# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 41 — Fix the compression fail-gate (CODE, founder pick B) — COMPLETE

- **Delivered:** compression fail-gate fixed correctness-first. The gate now runs *after* heuristic selection and applies only when `!heuristic.preserves_failure_signal()`. The git family folds regardless of `exitCode` (git log head+tail; git status/diff passthrough); the generic path stays conservative; failures are never hidden.
- **Evidence:** `verify-session-41.sh` 20/20; regression tests from real-shape payloads (no `exitCode`); `cargo test` 107 lib + 12 adapter; clippy + fmt clean; live-proven for $0 via `vajra hook`. Commits `98376db` (fix) + `a5086a6` (proof).
- **Carry-forward:** cargo/npm/pytest still branch on `exit_code == Some(0)` → never fold on real CC (own future compression session).

Between sessions. Next = S42 (CODE — C: git-level hooks scaffolding + `jq`-preflight, founder pick).

## Next Session (S42 — CODE, founder pick C)

- **Prompt (ready):** `prompts/42-task-git-level-hooks-jq-preflight.md` — scaffold `.githooks/pre-push` + `pre-commit` + `core.hooksPath` into `vajra init` (ROADMAP #17) **and** bundle the S40 `jq`-missing → fail-open fix (fail-closed preflight; AGENTS.md L147). **Recommended split at BOOT:** Gap 1 (jq-preflight) first, Gap 2 (git-level scaffold) second — carry to S43 if both won't fit one clean session.
- **Branch:** `session-42-git-level-hooks-jq-preflight`.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S40; next = S45).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S42; do NOT start it here.
- **Enforcement is the moat** — S37→S39 closed the S36 harm; S40 audited it (harm closed, proof not, gate UNMEASURED); **S41 fixed the compression quiet-bonus for the git family; S42 hardens enforcement (git-level belt + jq fail-closed).**
- **To publish from an agent session, the founder must launch with `VAJRA_ALLOW_PUBLISH=1`** (the guard blocks the agent otherwise, by design).
