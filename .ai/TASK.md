# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 83 — Warn before a headless read-only run (CODE) — COMPLETE

- **Goal:** `vajra claude -p "..."` with no permission-mode flag now prints an advisory stderr
  warning before `claude` is spawned — headless Claude Code has no approval channel, so every
  Write/Edit/Bash call is silently denied. Closes the S76-dogfood-observed gap carried across 5
  sessions (S73/S76/S77/S78/S81). Delivered.
- **Verify:** `scripts/verify-session-83.sh` **11/11** · `cargo test --lib` **263** · all gates pass.
- Cold review ACCEPT (`sessions/session-83-review.md`), 6/6 SHIPPED.
- Prompt: `prompts/83-task-readonly-headless-warning.md`. Summary: `sessions/session-83-summary.md`.
- **PR:** [#81](https://github.com/ifelse-codes/vajra/pull/81) — merged, branch pruned.

Between sessions. **Next = S84 — typed `CannotEvaluate::{Timeout, SpawnFailure}` (founder pick A
at S83 close).** New chat.

## Next Session (S84 — CODE, APPROVED)
- **Goal:** `src/gate_run.rs`'s `run_streamed`/`run_captured` collapse "the gate script hung past
  its bound" and "the child process never spawned" into the same untyped `None` — the S73
  fakest-green finding, carried across 7 sessions (S76-S83). Add `CannotEvaluate::{Timeout,
  SpawnFailure}`, propagate the typed distinction into `src/qa/mod.rs` + `src/demoer/mod.rs` so
  both gates' BLOCK messages name which failure mode occurred.
- **Scope split:** the other half of S82's candidate B — S83 shipped the read-only-headless UX
  warning; S84 is this half.
- Prompt: `prompts/84-task-typed-cannot-evaluate.md`.
- **S85 = the next mandatory NO-CODE GT** (`85 % 5 == 0`).

## Always-True Reminders
- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (next = **S85**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S84; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`) + chained tamper-evident (`DECISION-004`). **Pipeline = 8 governed stations + a
  receipt that RECOVERS the true $ on headless runs (S78), stays honestly null on interactive
  (S77), and prices the interactive estimate correctly (S79). S81 hardened the closeout gate; S82
  fixed the station counter's own Releaser false-read; S83 warns before a headless launch hits the
  silent read-only wall.**
