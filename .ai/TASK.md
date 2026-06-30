# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 31 — Dogfood / Verification (CODE → docs-only, option C) — COMPLETE

- **Type:** CODE dogfood / verification. Ran the real `vajra claude` loop for the first time since S07, against an existing TS pnpm monorepo (`chitra`).
- **Gate verdict:** **DO NOT promote the second agent.** Three shipped `[x]`-done features are dead in the real loop (S30 false-green shape, proven 3×), ranked by daily satisfaction:
  1. **Darshan not obeyed** — prose pointer, never enforced; agent dumps walls of text (felt every reply). **→ S32 fixes this first.**
  2. **Compression never fires** on real CC — adapter `HookInput` camelCase vs real CC snake_case top-level; pinned against a captured payload. Exact 2-file fix, low daily $ impact.
  3. **Brownfield onboarding unguided** — init works on existing repos but no learn-the-codebase session; hooks pollute the project's `scripts/`.
- **Meta-finding:** 2 of 3 are Vajra violating its own "enforcement, not prompts" wedge (value shipped as advisory text the agent ignores).
- **Outcome (option C, founder-directed):** record findings in the governance docs; do NOT cram all three fixes into one session (1-story discipline). Report: `sessions/session-31-summary.md`; detail in `.ai/KNOWLEDGE.md` S31.

Between sessions. Next: read `prompts/32-task-darshan-enforcement.md`.

## Next Session

Read prompt: `prompts/32-task-darshan-enforcement.md` — **S32 CODE: Darshan enforcement.** Make the agent load + follow `darshan/SKILL.md` every session (min: surface it in the SessionStart boot packet; design stronger enforcement). Move Darshan from *advised* → *enforced*. One story, ≤3 files.

## Build Queue (from ROADMAP.md, in order — fix the core, ranked by satisfaction)

1. **Darshan enforcement (S32)** — finding #1, most-felt.
2. **Compression schema fix** — finding #2, exact 2-file fix vs the captured payload.
3. **Brownfield onboarding** — finding #3.
4. **Add second agent (Codex/Cursor)** — stays parked until the core is fixed.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S30; next = S35) — audits **direction + discipline** drift.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** (enforced by `hook-session-guard.sh`, now in `vajra init` too).
- **Every fix moves a feature from *advised* → *enforced*** (S31 meta-finding — Vajra's own wedge).
