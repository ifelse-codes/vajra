# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 13 — Installer / Release Path — COMPLETE

- **Type:** CODE
- **Goal:** Ship `vajra` so anyone can install it in one command.
- **Output:** `sessions/session-13-summary.md`

## Next Session

Read prompt: `prompts/14-task-<slug>.md` (pending user pick from A/B/C)

## Build Queue (from ROADMAP.md, in order)

### Phase 1 — Pre-release (blocking) — COMPLETE
1. ~~Prove `vajra claude` in a real session~~ — DONE (S07)
2. ~~Build `vajra init`~~ — DONE (S08)
3. ~~Build `vajra check`~~ — DONE (S09)
4. ~~Make `vajra next` advance the session~~ — DONE (S09)
5. ~~Budget guard~~ — DONE (S11)
6. ~~Prove `vajra next` end-to-end~~ — DONE (S12)

### Phase 2 — Prove vendor-neutral
7. Add second agent (Codex or Cursor) — deep integration, not prompt template
8. Add third agent (Aider, Gemini CLI, or Kimi)

### Phase 3 — Ship
9. ~~Installer / release path~~ — DONE (S13)
10. Maturity levels L1/L2/L3 in CONSTRAINTS.yaml
11. Clean legacy `vajra launch` references

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
