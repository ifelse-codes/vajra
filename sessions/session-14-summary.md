# Session 14 Summary — Maturity Levels (L1/L2/L3)

## Goal
Add tiered enforcement maturity to CONSTRAINTS.yaml so users can grow from report-only to auto-advance.

## Goal Achieved?
Yes. All 5 deliverables shipped.

## Evidence
- `MaturityLevel` enum (L1/L2/L3) with parser in `src/maturity/mod.rs` — 11 unit tests
- `vajra check` reads maturity: L1 prints WARN + exits 0, L2/L3 prints FAIL + exits 1
- `vajra next --advance` skips interactive confirm at L3
- `vajra init` prompts for maturity level, writes to generated CONSTRAINTS.yaml
- Hook scripts (`hook-pre-bash.sh`, `hook-pre-write.sh`) read maturity — L1 = warn-only
- Maturity model documented in `.ai/KNOWLEDGE.md`
- `maturity: L2` added to this repo's own CONSTRAINTS.yaml
- 96 tests pass, clippy clean, verify script 9/9 green
- PR: [vajra#2](https://github.com/ifelse-codes/vajra/pull/2)

## Commits
1. `fc8c1ee` — feat: add MaturityLevel enum and parser (L1/L2/L3)
2. `1fe4b8d` — feat: wire maturity into check (L1=warn) and next (L3=auto-advance)
3. `e707570` — feat: add maturity prompt to vajra init scaffolding
4. `b02ad5f` — feat: hook scripts respect maturity level (L1=warn-only)
5. `cdda617` — docs: maturity levels in KNOWLEDGE.md + verify/demo scripts for S14

## Next Session Options

### A. Ground Truth Audit (S15 — mandatory NO-CODE)
- **Goal:** S15 is `15 % 5 == 0` — mandatory no-code audit session.
- **Why pick this:** Required by constraints. Audit state drift, stale facts, roadmap priority, cost review after 14 sessions of work.
- **Key risk:** None — it's mandatory.

### B. Clean Legacy References (after S15)
- **Goal:** Remove `vajra launch` alias and all references from code and docs.
- **Why pick this:** Small, clean scope. Removes dead code before adding new features. Ships a tidier crate.
- **Key risk:** Low — mostly grep + delete. Risk of missing a reference.

### C. Add Second Agent — Codex (after S15)
- **Goal:** Prove `vajra codex` works with OpenAI Codex CLI. Deep integration, not a prompt template.
- **Why pick this:** The vendor-neutral claim is Vajra's north star — this is the first proof it's real.
- **Key risk:** High — Codex CLI's hook/config mechanism may differ significantly from Claude Code. Research needed.
