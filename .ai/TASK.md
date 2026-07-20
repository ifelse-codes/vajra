# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 81 — Harden verify-closeout: execution-sha placeholder guard (CODE) — COMPLETE

- **Goal:** Add `check_execution_shas` to `scripts/verify-closeout.sh`; retroactively fix
  `prompts/79-task-stale-opus-reprice.md`. Both delivered.
- **Verify:** `scripts/verify-session-81.sh` **7/7** · `cargo test --lib` **258** · all gates pass.
- Cold review ACCEPT (`sessions/session-81-review.md`), attested `c11797a9…`.
- Prompt: `prompts/81-task-execution-sha-guard.md`. Summary: `sessions/session-81-summary.md`.

Between sessions. **Next = S82 — founder picks from 3 ranked candidates (see SESSION-BOOT.md).** New chat.

## Next Session (S82 — CODE, founder pick pending)
- Candidates: **A** S76 sha retroactive fix · **B** `--stations` Releaser durability · **C**
  read-only-headless UX + typed `CannotEvaluate`.
- Prompt to be written after founder picks.
- **S85 = the next mandatory NO-CODE GT** (`85 % 5 == 0`).

## Always-True Reminders
- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (next = **S85**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S82; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`) + chained tamper-evident (`DECISION-004`). **Pipeline = 8 governed stations + a
  receipt that RECOVERS the true $ on headless runs (S78), stays honestly null on interactive
  (S77), and prices the interactive estimate correctly (S79). S81 hardened the closeout gate.**
