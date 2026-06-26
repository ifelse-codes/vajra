# Session 15 — Ground Truth Audit (NO-CODE)

## Goal
Mandatory no-code audit. Re-read all `.ai/` state, check for drift, stale facts, roadmap accuracy, and cost review after 14 sessions of code work.

## Context
- S15 is `15 % 5 == 0` — mandatory NO-CODE session per CONSTRAINTS.yaml.
- No source-code edits, no commits, no PRs allowed (hook-enforced).
- Last ground truth was S10. Five code sessions have passed since (S11–S14).

## Required Audits
1. **State drift** — does `.ai/` agree with reality? SESSION, BOOT, TASK, STATE all consistent?
2. **Knowledge staleness** — any facts in KNOWLEDGE.md that are wrong or outdated?
3. **Roadmap priority** — is the roadmap order still correct? Any items to rerank?
4. **Constraint violation review** — have any constraints been bent or broken in S11–S14?
5. **Cost review** — cumulative spend still accurate?

## Output
- `sessions/session-15-ground-truth.md`

## Constraints
- NO source-code edits
- NO commits
- NO PRs
- Hook-enforced via `hook-pre-bash.sh` and `hook-pre-write.sh`
