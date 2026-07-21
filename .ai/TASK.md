# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 87 — Fill S76's unfilled Execution shas (CODE, docs-only) — COMPLETE

- **Goal:** `prompts/76-task-dogfood-ride-along.md`'s `## Execution` section carried 4 unfilled
  `<sha>` placeholders since before the S81 closeout-gate existed to catch them. Match each Plan
  step to the commit that actually delivers its substance and fill in the real shas. Delivered.
- **Headline:** matched by reading every candidate commit's real diff, not the "(N/4)"
  commit-message numbering (confirmed scrambled relative to Plan-step order, as the prompt warned).
  A real, unplanned side effect surfaced live while proving AC3: filling in S76's shas retroactively
  un-attests S76's OWN review (S86's `canonical_inputs_sha` hashes live prompt bytes, not a
  review-time snapshot) — disclosed immediately, not fixed here, and picked as the S88 target.
- Independent cold review: **pass 1 REJECT** (this session's OWN verify/demo scripts didn't actually
  prove what they claimed for AC3/AC5 — a real hollow-green instance) → fixed in-session → **pass 2
  ACCEPT**, adversarially re-verified by the same reviewer. Mirrors the S67 two-pass pattern.
- Report: `sessions/session-87-review.md`. Summary: `sessions/session-87-summary.md`. Prompt:
  `prompts/87-task-fix-s76-execution-shas.md`.

Between sessions. **Next = S88 — CODE, fix `canonical_inputs_sha` to hash a review-time snapshot.**
New chat.

## Next Session (S88 — CODE, founder pick A, APPROVED)

- **Goal:** both hashing call sites (`src/stations/mod.rs#attested_hash_outcome`/`read_prompt`,
  `scripts/verify-closeout.sh#canonical_inputs_sha`) read the prompt file's CURRENT live bytes, never
  a snapshot from review time. Fix: read each candidate's prompt bytes from that candidate's OWN
  commit tree, not one shared live read. Re-validate against the real historical Verified/
  Unverifiable split (S76 must flip back to Verified — the direct proof the fix works).
- Prompt: `prompts/88-task-fix-canonical-inputs-sha-snapshot.md`.
- **Branch:** `session-88-fix-canonical-inputs-sha-snapshot`. One story, no new command/CONSTRAINTS
  key, no change to the hash's shape — only which prompt bytes feed it.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (next = **S90**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S88; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`) + chained tamper-evident (`DECISION-004`). **Pipeline = 8 governed stations.
  S87 closed the oldest standing record-hygiene debt (S76's Execution shas) — but in doing so, LIVE
  PROOF surfaced that DECISION-003's attestation hash is not actually review-time-stable: it hashes
  the prompt file's current bytes, so ANY future edit to a historical prompt un-attests that
  session's review. S88 fixes the root cause. Dogfood remains 🔴 (11 sessions / 18+ days stale) and
  founder-un-parkable — not picked again this round, watch it keep aging.**
