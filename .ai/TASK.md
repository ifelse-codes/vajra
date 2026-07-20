# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 79 — Re-price the stale static opus rate (CODE) — COMPLETE

- **Within ADR-0004 (meter/receipt), a compiled-in pricing-value change, no new command:**
  `src/meter/mod.rs` gets specific-before-generic `MODEL_PRICING` entries for
  `claude-opus-4-8`/`-4-7`/`-4-6` at the confirmed current rate $5/$25 per MTok (sourced live from
  the `claude-api` skill, cached 2026-06-24); the generic `claude-opus-4` fallback now explicitly
  means legacy/unconfirmed opus (4.0/4.1/4.5) and keeps the historical $15/$75. `src/cli/estimate.rs`
  `DEFAULT_MODEL` bumped from the bare `"claude-opus-4"` to `"claude-opus-4-8"` — the actual
  interactive-path fix, since `vajra estimate` is the only cost figure an interactive user sees.
- **Result:** `vajra estimate` now prices at $5/MTok input, $25/MTok output (was $15/$75 — a ~3x
  overstatement). `UNKNOWN_MODEL_PRICING` unchanged numerically, reconfirmed as an upper bound.
- Read prompt: `prompts/79-task-stale-opus-reprice.md`. Reports: `sessions/session-79-summary.md` +
  `-review.md` (ACCEPT, attested `c6111ba5…`). `verify-session-79.sh` 11/11; demo 4 markers.
- `cargo test --lib` **258** (+2). **Spend ~$0** (compiled-in rate correction, no paid run).

Between sessions. **Next = S80 — the mandatory NO-CODE ground truth** (every 5th session). **New
chat.**

## Next Session (S80 — NO-CODE ground truth, mandatory)
- Every 5th session is a mandatory NO-CODE ground truth: `forbid_code_changes: true`,
  `forbid_commits: true`, `forbid_prs: true`. Run all 9 `required_audits` from
  `.ai/CONSTRAINTS.yaml#ground_truth` (vision, roadmap, state, knowledge, constraints, constitution,
  cost, dogfood, pipeline_advance_check).
- `prompts/80-task-ground-truth.md` to be authored at S79 closeout, per the standard template.
- Standing questions for S80: is dogfood still 🟡 aging (no paid `vajra claude` run since S76)? Does
  `vajra next --stations NN` show the pipeline advancing, or has 5 sessions of receipt-accuracy work
  (S76→S79) been the shortest path? **S81 resumes CODE** from S80's ranked candidates (standing: A
  `--stations` durability, B read-only-headless UX + typed `CannotEvaluate`, C readable-roadmap
  one-pager — see `sessions/session-79-summary.md`).

## Always-True Reminders
- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (next = **S80**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S80; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`) + chained tamper-evident (`DECISION-004`). **Pipeline = 8 governed stations + a
  receipt that RECOVERS the true $ on headless runs (S78), stays honestly null on interactive
  (S77), and now prices the interactive estimate correctly (S79).** **Receipt arc S76→S77→S78→S79
  is fully CLOSED.**
