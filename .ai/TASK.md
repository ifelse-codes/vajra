# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 84 — Typed `CannotEvaluate::{Timeout, SpawnFailure}` (CODE) — COMPLETE

- **Goal:** the QA/Demo-er gates' live re-run collapsed "the script hung past its bound" and "the
  process never spawned" into the same untyped `None`. Both `gate_run::run_streamed`/
  `run_captured` now return `Result<i32, CannotEvaluate>`; both gates' BLOCK messages name TIMEOUT
  vs SPAWN FAILURE distinctly. Closes the S73 fakest-green finding carried across 7 sessions
  (S76-S83). Delivered.
- **Verify:** `scripts/verify-session-84.sh` **16/16** · `cargo test --lib` **267** · all gates pass.
- Cold review ACCEPT (`sessions/session-84-review.md`), 6/6 SHIPPED.
- Prompt: `prompts/84-task-typed-cannot-evaluate.md`. Summary: `sessions/session-84-summary.md`.
- **PR:** [#83](https://github.com/ifelse-codes/vajra/pull/83) — merged, branch pruned.

Between sessions. **Next = S85 — mandatory NO-CODE ground truth (`85 % 5 == 0`).** New chat.

## Next Session (S85 — NO-CODE ground truth, APPROVED)
- **Goal:** audit the S81→S84 arc (execution-sha closeout guard · Releaser ledger fallback ·
  read-only-headless UX warning · typed `CannotEvaluate`). Lead lens A: did four hardening/UX
  sessions advance the pipeline, or repeat the S80-flagged easy-green-detour pattern? Dogfood is
  now 8 sessions stale since S76 (2026-07-03) — state the exact age, do not guess a satisfaction
  verdict. All 9 `required_audits` run in full regardless of lens.
- Prompt: `prompts/85-task-ground-truth.md`.
- **No code, no commits outside a `-closeout`/`-enforcement` branch, no PRs.**

## Always-True Reminders
- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (this one = **S85**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S85; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`) + chained tamper-evident (`DECISION-004`). **Pipeline = 8 governed stations + a
  receipt that RECOVERS the true $ on headless runs (S78), stays honestly null on interactive
  (S77), and prices the interactive estimate correctly (S79). S81 hardened the closeout gate; S82
  fixed the station counter's own Releaser false-read; S83 warns before a headless launch hits the
  silent read-only wall; S84 types the QA/Demo-er cannot-evaluate BLOCK reason.**
