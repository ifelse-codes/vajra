# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 09 — Build `vajra check` + Make `vajra next` Advance — COMPLETE

- **Branch:** `session-09-check-and-next`
- **Goal:** Build `vajra check` (drift detection + readiness scoring) + `vajra next --advance` (bump SESSION, update pointers).

## Next Session

Read prompt: `prompts/10-task-ground-truth-audit.md`

## Build Queue (from ROADMAP.md, in order)

### Phase 1 — Pre-release (blocking)
1. ~~Prove `vajra claude` in a real session~~ — DONE (S07)
2. ~~Build `vajra init`~~ — DONE (S08)
3. ~~Build `vajra check`~~ — DONE (S09)
4. ~~Make `vajra next` advance the session~~ — DONE (S09)
5. Budget guard — `budget_cap_usd` in CONSTRAINTS.yaml, enforced in launcher
6. Prove `vajra next` end-to-end in a real multi-step project

### Phase 2 — Prove vendor-neutral
7. Add second agent (Codex or Cursor) — deep integration, not prompt template
8. Add third agent (Aider, Gemini CLI, or Kimi)

### Phase 3 — Ship
9. Installer / release path (`cargo install vajractl`, Homebrew)
10. Maturity levels L1/L2/L3 in CONSTRAINTS.yaml
11. Clean legacy `vajra launch` references

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
