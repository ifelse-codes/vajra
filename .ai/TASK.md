# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 26 — Enforce one-session-per-chat (CODE) — COMPLETE

- **Type:** CODE — make AGENTS.md step 10 / `one_session_per_chat: true` real.
- **Shipped:** `scripts/hook-session-guard.sh` (PreToolUse Bash) records the Claude `session_id` that owns each vajra-session (gitignored `.ai/.session-owner`) and **blocks `git checkout -b session-(N+1)-*` from the same chat that owns N** (exit 2). Maturity-gated (L1 advise / L2-L3 block), gated on `one_session_per_chat: true`. No 8th command, no new dep. verify-session-26.sh green (13/13). **PR #17 — open (merge after closeout).**
- **Founder direction:** second agent **parked in backlog** (owner-gated, not audit-gated). New next leap = **Darshan** (human-facing glanceable output skill).

Between sessions. Next: read `prompts/27-task-darshan.md`.

## Next Session

Read prompt: `prompts/27-task-darshan.md` — **S27 CODE/content: Darshan**, Vajra's default surface-adaptive *glanceable* way of showing the human (skill, not renderer; pairs with Varta — agent talks ↔ user sees). One rule = "render the richest visual this surface can handle, always glanceable, never drop meaning." 3 surface tiers (rich chat HTML · terminal ANSI/box · plain markdown). Name provisional — founder confirms at BOOT. No 8th command; ≤3 files/commit; propagation to `vajra init` may split to S28.

## Build Queue (from ROADMAP.md, in order)

### Phases 1–3 + Varta arc — COMPLETE
1–13. ~~claude · init · check · next --advance · budget guard · next e2e · Varta v0 · co-pilot loader · scaffold propagation · first-run aha · render `.ai/`→.varta · installer · maturity · legacy cleanup · pre-run estimate~~ — DONE (S07–S24).

### Next leap (re-ranked S26 — founder override of the S25 audit)
1. ~~**Enforce one-session-per-chat**~~ — DONE (S26). `scripts/hook-session-guard.sh`.
2. **Darshan — human-facing glanceable output skill (CODE/content)** — picked S26. `prompts/27-task-darshan.md`.
3. **Propagate session-guard into `vajra init`** (S26 rider) — small, well-understood.

### Backlog (parked until founder declares Vajra-on-Claude "satisfying")
- **Add second agent (Codex/Cursor)** — the north-star gap (S25), but **owner-gated**. Returns to #1 only when the founder is satisfied with Claude.
- **North-star breadth indicator** (RED until ≥2 agents) — S25 meta-finding.
- **Dogfood / verification session** — use Varta+Darshan on a real project, log friction, fix-or-defer (retired from slot 27).
- Audit ledger v2 · third agent · policy/governed-memory/MCP.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (next = S30) — audits **direction + discipline** drift.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** (now enforced by `hook-session-guard.sh`).
