# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 42 — Git-level hooks + `jq`-preflight (CODE, founder pick C) — Gap 1 COMPLETE

- **Delivered (Gap 1):** `jq`-preflight, fail-closed (AGENTS.md L147). A byte-identical block after `set -euo pipefail` in all 5 `jq`-parsing hooks — `jq` missing → L2/L3 `exit 2` (block, was `exit 0`), L1 `exit 0` (advise). Reads maturity via `grep`/`awk` (not `jq`), so it travels inside the `include_str!`'d copies → scaffolded projects inherit it, no `init.rs` change.
- **Evidence:** `verify-session-42.sh` 31/31 (all 5 hooks under a `jq`-less `PATH` shim; zero regression with `jq` present; block identical across all 5; `vajra init` scaffolds it baked in); `cargo test` + clippy + fmt clean. Commits `f3778b5` + `f15edb6`.
- **Carry-forward:** Gap 2 (git-level `.githooks/` scaffolding into `vajra init`) is a second story → S43.

Between sessions. Next = S43 (CODE — Gap 2: git-level hooks scaffolding into `vajra init`, founder pick).

## Next Session (S43 — CODE, founder pick / S42 carry)

- **Prompt (ready):** `prompts/43-task-git-level-hooks-scaffold.md` — scaffold `.githooks/pre-push` + `pre-commit` (via `include_str!`, byte-identical) + set `core.hooksPath` into `vajra init` (ROADMAP #17b) as an independent L2 belt beneath the L3 `.claude/` hooks. Closes the raw-`echo > .ai/SESSION` bypass at the right layer.
- **Branch:** `session-43-git-level-hooks-scaffold`.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S40; next = S45).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S43; do NOT start it here.
- **Enforcement is the moat** — S37→S39 closed the S36 harm; S40 audited it (harm closed, proof not, gate UNMEASURED); S41 fixed the compression quiet-bonus for the git family; **S42 closed the constitution 🔴 (`jq` fail-open → fail-closed); S43 adds the git-level L2 belt to scaffolded projects.**
- **To publish from an agent session, the founder must launch with `VAJRA_ALLOW_PUBLISH=1`** (the guard blocks the agent otherwise, by design).
