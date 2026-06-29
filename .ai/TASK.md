# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 21 — The co-pilot loader (CODE) — COMPLETE

- **Type:** CODE
- **Goal:** make `⚡on(x) ⚡include` *fire* mid-session — the first enforcing use of Varta.
- **Outcome:** loader shipped (`scripts/hook-copilot-loader.sh` + `copilot.on` rules in `CONSTRAINTS.yaml` + settings wiring). verify-session-21.sh green (10/10). **Decision gate answered: Varta ENFORCES** (L2/L3 exit-2 block, L1 advise) — on-wedge. Proven live: blocked a real `git commit` mid-session. Report: `sessions/session-21-summary.md`. PR #11.

Between sessions. Next: read `prompts/22-task-scaffold-propagation.md`.

## Next Session

Read prompt: `prompts/22-task-scaffold-propagation.md` — **S22 CODE: scaffold propagation** (make `vajra init` emit the S20 GT audits + the S21 co-pilot loader, so every project inherits them). The deferred S21 rider.

## Build Queue (from ROADMAP.md, in order)

### Phase 1 — Pre-release (blocking) — COMPLETE
1–6. ~~claude · init · check · next --advance · budget guard · next e2e~~ — DONE (S07–S12)

### Phase 2 — Varta: the agent's language + the co-pilot (S18 direction)
7. ~~**Varta v0 — the skill**~~ — DONE (S19). **Language only:** `varta/SKILL.md` + `GRAMMAR.varta` (9 constructs), spoken from the live `.ai/`. The hand-written `vajra.varta` companion was **dropped** (drift + lost config). verify-session-19.sh green (9/9).
8. ~~**Co-pilot loader**~~ — DONE (S21). `⚡on(x) ⚡include` fires via PreToolUse hook; **Varta enforces** (L2/L3 block, L1 advise). Rider (scaffold propagation) **split to S22**.
8a. **Scaffold propagation** *(NEXT — S22)* — `vajra init` emits the S20 GT audits + the S21 co-pilot loader. The deferred S21 rider + the S19 "wire Varta into init" follow-up.
9. First-run "aha" — `vajra init` → visible win in 2 minutes.

### Phase 3 — Ship — COMPLETE
~~Installer · maturity levels · legacy cleanup · pre-run cost estimate~~ — DONE (S13, S14, S16, S17)

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth — now audits **direction + discipline** drift. Next: S25.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
