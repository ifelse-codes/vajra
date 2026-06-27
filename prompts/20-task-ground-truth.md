# Session 20 — Ground Truth Audit (NO-CODE)

## Goal
Mandatory no-code audit. Re-read all `.ai/` state, check for drift, stale facts, roadmap accuracy, and cost review after 5 sessions since the last ground truth (S15). Confirm the Varta direction is real, then rerank toward the chosen S21 build.

## Context
- S20 is `20 % 5 == 0` — mandatory NO-CODE session per CONSTRAINTS.yaml.
- No source-code edits, no commits, no PRs allowed (hook-enforced).
- Last ground truth was S15. Five sessions have passed since (S16–S19).
- S19 shipped **Varta v0** (the skill): `varta/SKILL.md`, `varta/GRAMMAR.varta`, `varta/vajra.varta`, `varta/READBACK.md`. Read these first — they are new operating context.
- **S21 direction picked by the user: the co-pilot loader** (make `⚡on(x) ⚡include` real). This audit should rerank the roadmap toward it.

## Required Audits
1. **State drift** — does `.ai/` agree with reality? SESSION (=19), BOOT, TASK, STATE all consistent? Is `varta/` reflected anywhere it should be?
2. **Knowledge staleness** — any facts in KNOWLEDGE.md wrong or outdated? Is the Varta v0 fact captured correctly?
3. **Roadmap priority** — is Phase 2 order still right? Item 7 (Varta v0) should be `[x]`. Is item 8 (co-pilot loader) the correct next, given the user's S21 pick? Rerank if needed.
4. **Constraint violation review** — were any constraints bent in S16–S19? (S19 was docs-only — confirm no Rust drift, ≤3 files/commit held.)
5. **Cost review** — cumulative spend still ~$0.46 and accurate?

## Varta-specific checks (new this audit)
- Is the 9-construct grammar still the right set after one real authoring pass? Note any construct that felt missing or unused.
- Does `vajra.varta` stay in sync with `.ai/CONSTRAINTS.yaml` / ADRs, or has the companion already drifted from source?
- Pre-work for S21: what runtime hook would actually fire an `⚡on(...)` load? Sketch (no code) where it would live (`src/launcher` vs a new `vajra` subcommand vs a CC hook).

## Output
- `sessions/session-20-ground-truth.md`

## Constraints
- NO source-code edits
- NO commits
- NO PRs
- Hook-enforced via `hook-pre-bash.sh` and `hook-pre-write.sh`
