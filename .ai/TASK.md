# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 91 — CODE (B+C) — COMPLETE

- **Goal:** (B) fix `--stations 89` Reviewer ABSENT (intermediate-commit hash mismatch); (C) add
  live `--dogfood-age` query computed from git/receipts (not STATE.md).
- **Results:** S89 Reviewer PASSED · `--dogfood-age` live · 283 lib tests · `dogfood_staleness`
  in required_audits. Cold review: `sessions/session-91-review.md`.
- Branch: `session-91-fix-attestation-and-dogfood-staleness`.

Between sessions. **Next = S92.** Options TBD; present 3 (A/B/C) + write prompt at session close.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (next = **S95**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S92; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`), chained tamper-evident (`DECISION-004`). **Pipeline = 8 governed stations.
  Dogfood (14 sessions / 3 days since S76 = 2026-07-18) is the standing highest-priority open
  item. `--dogfood-age` now derives this live from git (S91 C).**
