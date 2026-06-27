# Session 16 — Clean Legacy References + Fix S15 Drift

## Goal
Two small items in one session: remove the legacy `vajra launch` alias and fix all 4 findings from the S15 ground truth audit.

## Context
- Roadmap item #12: `vajra launch` still exists as an alias for `vajra claude` in `src/main.rs:32` and help text at `src/main.rs:99`.
- S15 ground truth found 4 issues to fix (0 high, 2 medium, 2 low).

## Deliverables

### Part 1 — Clean legacy `vajra launch`
- Remove `"launch"` match arm from `src/main.rs`
- Remove `launch` from help/usage text
- Remove or rename `src/cli/launch.rs` if it's only used for the launch alias
- Verify no other references to `vajra launch` remain in code or docs

### Part 2 — Fix S15 audit findings
1. **STATE.md:** PR #2 is merged, not "pending merge" — update Active PRs section
2. **ROADMAP.md:** Move Installer and Maturity Levels from "Does NOT Work Yet" to "What Works Today"
3. **KNOWLEDGE.md §7:** Fix breadcrumb format from `[N lines hidden — set VAJRA_RAW=1 to disable]` to match actual code: `[vajra: N lines folded — VAJRA_RAW=1 before 'vajra claude' to see full output]`
4. **S11 verify:** Confirm `roadmap-clean` check passes after fix #2

## Constraints
- Standard CODE session rules apply
- Max 3 files per atomic commit
- Branch: `session-16-cleanup-and-drift-fix`
