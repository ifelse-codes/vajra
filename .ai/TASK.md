# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 19 — Varta v0 (the skill) — COMPLETE

- **Type:** CODE
- **Goal:** Build Varta — the ⚡ machine-language shipped as a skill — and render Vajra's own `.ai/` as `vajra.varta`.
- **Outcome:** `varta/` = SKILL.md + GRAMMAR.varta + vajra.varta + READBACK.md. verify-session-19.sh green (10/10). Companion to `.ai/`, not a replacement.

Between sessions. Next: read `prompts/20-task-ground-truth.md`.

## Next Session

Read prompt: `prompts/20-task-ground-truth.md` — **mandatory NO-CODE ground-truth audit** (S20). After it, S21 = co-pilot loader.

## Build Queue (from ROADMAP.md, in order)

### Phase 1 — Pre-release (blocking) — COMPLETE
1–6. ~~claude · init · check · next --advance · budget guard · next e2e~~ — DONE (S07–S12)

### Phase 2 — Varta: the agent's language + the co-pilot (S18 direction)
7. ~~**Varta v0 — the skill**~~ — DONE (S19). Skill + grammar + `vajra.varta` + read-back.
8. **Co-pilot loader** *(NEXT code session — S21)* — make `⚡on(x) ⚡include` real (load context mid-session).
9. First-run "aha" — `vajra init` → visible win in 2 minutes.
- *Follow-up (deferred S19):* wire Varta into `vajra init` scaffold.

### Phase 3 — Ship — COMPLETE
~~Installer · maturity levels · legacy cleanup~~ — DONE (S13, S14, S16)

### Phase 4 — Post-launch
~~Pre-run cost estimate~~ — DONE (S17)

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE (now: S20).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
