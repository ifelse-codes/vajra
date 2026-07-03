# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 37 — Close the enforcement leak — COMPLETE

- Shipped `scripts/hook-publish-guard.sh`: blocks `git push` / `gh pr create` / `gh pr merge` / `glab mr *` at L2/L3 (exit 2) unless `VAJRA_ALLOW_PUBLISH=1` set at launch; L1 advises; innocuous git passes.
- **Proved live** — the guard blocked the agent's own `git push` tool call. `verify-session-37.sh` 22/22 green. No `src/` change (bash-only), 3 files.
- **Repo-only:** `vajra init` does NOT scaffold the guard yet — that's where S36 leaked. Propagation = S38.
- Report: `sessions/session-37-summary.md`.

Between sessions. Next = S38 propagation (founder pick A).

## Next Session (S38 — propagate the guard into `vajra init`)

- **Prompt (ready):** `prompts/38-task-propagate-publish-guard.md` — scaffold `hook-publish-guard.sh` into new projects (S29 `include_str!` pattern) + a git-level `pre-push`, so the guard exists where the S36 leak happened.
- **Also ready (not picked):** `prompts/39-task-fix-compression-exit-gate.md` (compression, correctness-first) · session-boundary hardening (the other S36 slice).

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S35; **next = S40**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S38; do NOT branch/plan it here.
- **Enforcement is the moat** — S37 closed the core leak for this repo; S38 closes it in scaffolded projects.
- **To publish from an agent session, the founder must launch with `VAJRA_ALLOW_PUBLISH=1`** (the guard blocks the agent otherwise, by design).
