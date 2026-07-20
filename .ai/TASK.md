# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 85 — Ground Truth (mandatory NO-CODE, every 5th) — COMPLETE

- **Goal:** audit the S81→S84 arc (execution-sha closeout guard · Releaser ledger fallback ·
  read-only-headless UX warning · typed `CannotEvaluate`). Lead lens A: did four hardening/UX
  sessions advance the pipeline, or repeat the S80-flagged easy-green-detour pattern? Delivered.
- **Headline:** `--stations` S80→S84 = dead flat 7/8 across S81-S84. Lens A: easy-green detour
  CONFIRMED, 2nd consecutive GT. Attestation substring-check re-ranked 🥇 for S86 (live exploit
  surface, 3 sessions of disclosure). Dogfood escalated to 🔴 (8 sessions / 17 days stale).
- 9 audits: vision 🟡 · roadmap 🟡 · state 🟢 · knowledge 🟡 · constraints 🟢 · constitution 🟡 ·
  cost 🟢 · dogfood 🔴 · pipeline_advance 🔴.
- Report: `sessions/session-85-ground-truth.md`. Prompt: `prompts/85-task-ground-truth.md`.
- **No code, no commits outside `session-85-closeout`, no PR for the report itself** — bundled
  into the docs-only closeout PR.

Between sessions. **Next = S86 — CODE, harden the attestation check.** New chat.

## Next Session (S86 — CODE, founder pick A, APPROVED)
- **Goal:** `reviewer_status`/`session_attested_accept` (`src/stations/mod.rs`) currently accept
  any review file containing the LABEL `Review-Inputs-SHA` anywhere, without checking the value —
  a forged/stale/recycled attestation silently passes. Fix: recompute-and-compare against the
  canonical hash (mirrors `verify-closeout.sh#check_review_attestation`'s already-correct logic),
  or read the S59 ledger's already-computed hash (recommended — avoids the merge-base collapse
  `canonical_inputs_sha()` hits post-merge, S83 finding). Design fork left to S86's own Architect
  step.
- Prompt: `prompts/86-task-harden-attestation-check.md`.
- **Branch:** `session-86-harden-attestation-check`. One story, no new command/CONSTRAINTS key.

## Always-True Reminders
- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (next = **S90**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S86; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`) + chained tamper-evident (`DECISION-004`). **Pipeline = 8 governed stations,
  unchanged by S85 (NO-CODE). S86 hardens the attestation gate's actual security property (hash
  recompute, not a label match) — the highest-live-risk item the S85 GT surfaced.**
