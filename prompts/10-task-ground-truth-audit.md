# Session 10 — Ground Truth Audit (NO-CODE)

> **NO-CODE session.** No source edits, no commits, no PRs. Audit only.

## Goal
Full state + roadmap audit. Verify all `.ai/` files reflect reality, roadmap priorities match what's built, cost is tracked, and no drift has compounded.

## Required Audits (per CONSTRAINTS.yaml)
1. **State drift** — compare `.ai/STATE.md` claims against actual repo state (run commands, read files, verify each claim)
2. **Knowledge staleness** — review `.ai/KNOWLEDGE.md` for facts that are outdated or missing
3. **Roadmap priority** — review `.ai/ROADMAP.md` ordering, verify `[x]` marks match reality, flag any misordered items
4. **Constraint violation review** — scan recent sessions for any constraint violations that were missed
5. **Cost review** — verify cumulative cost tracking is accurate

## Additional Focus Areas
- SESSION-BOOT.md — does it accurately describe the repo state?
- TASK.md — is the pointer correct for the next session?
- AGENTS.md — does the "today in code" section reflect reality?
- Cross-reference: do all `.ai/` files tell a consistent story?

## Output
- `sessions/session-10-ground-truth.md` — findings, corrections needed, sign-off

## Exit Criteria
- All 5 required audits completed
- Ground truth summary written
- User signs off before code resumes in S11
