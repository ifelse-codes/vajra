# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 20 — Ground-truth audit (NO-CODE) — COMPLETE

- **Type:** NO-CODE (`20 % 5 == 0`)
- **Goal:** Re-read all `.ai/`; audit drift, staleness, roadmap, cost since S15.
- **Outcome:** 7 findings (1 critical, 1 high, 5 low). **Headline:** the GT audit was blind to *direction* drift (vision + roadmap) — hardened this session (`CONSTRAINTS.yaml` + `AGENTS.md`). Report: `sessions/session-20-ground-truth.md`.

Between sessions. Next: read `prompts/21-task-copilot-loader.md`.

## Next Session

Read prompt: `prompts/21-task-copilot-loader.md` — **S21 CODE: the co-pilot loader** (make `⚡on(x) ⚡include` fire via a CC hook) + propagate the new GT audits into the `vajra init` scaffold + answer "does Varta enforce or advise?".

## Build Queue (from ROADMAP.md, in order)

### Phase 1 — Pre-release (blocking) — COMPLETE
1–6. ~~claude · init · check · next --advance · budget guard · next e2e~~ — DONE (S07–S12)

### Phase 2 — Varta: the agent's language + the co-pilot (S18 direction)
7. ~~**Varta v0 — the skill**~~ — DONE (S19). **Language only:** `varta/SKILL.md` + `GRAMMAR.varta` (9 constructs), spoken from the live `.ai/`. The hand-written `vajra.varta` companion was **dropped** (drift + lost config). verify-session-19.sh green (9/9).
8. **Co-pilot loader** *(NEXT — S21)* — make `⚡on(x) ⚡include` fire mid-session via a CC hook. Riders: scaffold-propagation of the new GT audits + the Varta enforce-or-advise gate.
9. First-run "aha" — `vajra init` → visible win in 2 minutes.
- *Follow-up (deferred S19):* wire Varta into `vajra init` scaffold (folds into item 8's rider).

### Phase 3 — Ship — COMPLETE
~~Installer · maturity levels · legacy cleanup · pre-run cost estimate~~ — DONE (S13, S14, S16, S17)

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth — now audits **direction + discipline** drift. Next: S25.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
