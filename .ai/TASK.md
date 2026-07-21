# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 90 — NO-CODE Ground Truth (`90 % 5 == 0`) — COMPLETE

- **Goal:** run all 9 required audits for S86–S89. Output: `sessions/session-90-ground-truth.md`.
- **Headline findings:** (1) STATE.md date error — "19+ days since S76 (2026-07-03)" cited S36's
  date; S76 was 2026-07-18; actual staleness = 13 sessions / 2–3 calendar days. (2) S89 = 5/8
  stations: Demo-er missing markers + Reviewer hash mismatch. (3) Easy-green detour, 3rd
  consecutive GT finding the same shape.
- Report: `sessions/session-90-ground-truth.md`. Branch: `session-90-closeout`.

Between sessions. **Next = S91 — fix S89 Reviewer hash mismatch + dogfood-staleness live query.**
New chat.

## Next Session (S91 — CODE, APPROVED)

- **Goal:** (B) fix `--stations 89` Reviewer ABSENT (hash mismatch for docs-only sessions); (C)
  add live `--dogfood-age` query computed from receipts (not STATE.md). Founder-approved B+C
  combination (like S39 A+B).
- Prompt: `prompts/91-task-fix-attestation-and-dogfood-staleness.md`.
- **Branch:** `session-91-<slug>`.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (next = **S95**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S91; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`), chained tamper-evident (`DECISION-004`). **Pipeline = 8 governed stations.
  Dogfood (13 sessions / 2–3 days since S76 = 2026-07-18) is the standing highest-priority open
  item. S90 GT also found S89 Reviewer hash mismatch — S91 fixes it.**
