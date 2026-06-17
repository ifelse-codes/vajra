# CLAUDE.md — Cross-Agent Entry Point

> Stop. Read `.ai/AGENTS.md` before any action.

Full constitution at `.ai/AGENTS.md`. Mandatory load order:

1. `.ai/AGENTS.md`
2. `.ai/SESSION`
3. `.ai/SESSION-BOOT.md`
4. `.ai/TASK.md`
5. `.ai/STATE.md`
6. `.ai/CONSTRAINTS.yaml`
7. `.ai/KNOWLEDGE.md`
8. `.ai/ROADMAP.md`
9. `prompts/NN-task-<slug>.md`

Hard rules headline: no `main` commits · no autonomous commits · max 2 assumptions / 2 retries / 1 story / 3 files per commit / ~2h cap · every 5th session NO-CODE · closeout not done until `scripts/verify-closeout.sh` exits 0.
