# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 06 — Vision Alignment — IN PROGRESS

- **Branch:** `session-06-align-vision`
- **Goal:** Align all docs, roadmap, and positioning to the vendor-neutral, workflow-first vision.

## Build Queue (from ROADMAP.md, in order)

After this session, the next sessions should build these in order:

1. Prove `vajra claude` in a real session (settings injection + hook + receipt)
2. Build `vajra init` — scaffold `.ai/` directory in a new repo
3. Build `vajra verify` — CLI wrapper for `scripts/verify-session-{NN}.sh`
4. Build `vajra check` — drift detection against `.ai/STATE.md`
5. Make `vajra next` advance the session (bump SESSION, update pointers, print next context)
6. Prove `vajra next` end-to-end in a real multi-step project
7. Add a second agent to prove vendor-neutral is real
8. Installer / release path
9. Clean legacy `vajra launch` references

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
