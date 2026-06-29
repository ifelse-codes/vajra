# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 27 — Darshan: the human's glanceable output skill (CODE/content) — COMPLETE

- **Type:** CODE/content — Darshan, Vajra's default surface-adaptive glanceable human-output skill (skill, not renderer; pairs with Varta — agent talks ↔ user sees).
- **Shipped:** `darshan/SKILL.md` (boot ritual + one rule "render the richest visual this surface can handle; always glanceable; never drop meaning" + 3 tiers [rich chat HTML/SVG · terminal ANSI/box · plain markdown] + before/after for chat + terminal). Boot-wired via a **Speaking Skills** pointer in `.ai/AGENTS.md`. `VISION.md` gained the human lane. No 8th command, no `src/` change, no new dep. verify-session-27.sh green (18/18). **PR #18 — open (merge after closeout).**
- **Decisions:** name **Darshan** confirmed at BOOT; `vajra init` propagation **deferred to S28** (1-story cap).

Between sessions. Next: read `prompts/28-task-init-propagation.md`.

## Next Session

Read prompt: `prompts/28-task-init-propagation.md` — **S28 CODE: propagate Darshan + the S26 session-guard into `vajra init`** (the S22 pattern), so every scaffolded project inherits the full enforced + glanceable loop. **Scope risk:** if both artifacts exceed 1 story, do Darshan-only S28 and split the session-guard to S29.

## Build Queue (from ROADMAP.md, in order)

### Phases 1–3 + Varta arc — COMPLETE
1–13. ~~claude · init · check · next --advance · budget guard · next e2e · Varta v0 · co-pilot loader · scaffold propagation · first-run aha · render `.ai/`→.varta · installer · maturity · legacy cleanup · pre-run estimate~~ — DONE (S07–S24).

### Next leap (re-ranked S26 — founder override of the S25 audit)
1. ~~**Enforce one-session-per-chat**~~ — DONE (S26). `scripts/hook-session-guard.sh`.
2. ~~**Darshan — human-facing glanceable output skill**~~ — DONE (S27). `darshan/SKILL.md` + AGENTS.md boot pointer.
3. **Propagate Darshan + session-guard into `vajra init`** — picked S28. `prompts/28-task-init-propagation.md`.

### Backlog (parked until founder declares Vajra-on-Claude "satisfying")
- **Add second agent (Codex/Cursor)** — the north-star gap (S25), but **owner-gated**. Returns to #1 only when the founder is satisfied with Claude.
- **Dogfood / verification session** — use Varta+Darshan on a real project, log friction, fix-or-defer. Strong candidate once propagation lands.
- **North-star breadth indicator** (RED until ≥2 agents) — S25 meta-finding.
- Audit ledger v2 · third agent · policy/governed-memory/MCP.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (next = S30) — audits **direction + discipline** drift.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** (enforced by `hook-session-guard.sh`).
