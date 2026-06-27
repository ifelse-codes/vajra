# Session 17 — Pre-Run Cost Estimate

## Goal
Add a `vajra estimate` command that predicts token spend before running a session, so users can decide whether to proceed given their budget.

## Context
- The meter already parses session JSONL and prints honest cost breakdowns after a session.
- Budget guard enforces `budget.cap_usd` after session exit.
- This fills the gap: users currently can't see projected cost *before* committing to a session.
- Inspired by Loop Engineering's `loop-cost` (competitive analysis in `research/COMPETITIVE-LEARNINGS.md`).

## Deliverables

### Core: `vajra estimate`
- Reads the current prompt file (`prompts/NN-task-<slug>.md`) and `.ai/` context to estimate input token count
- Uses compiled-in pricing (same as meter) to project cost
- Prints a one-line estimate: `Estimated session cost: ~$X.XX (N input tokens @ $Y/MTok)`
- Warns if estimate exceeds `budget.cap_usd` remaining balance

### Design questions to resolve
- Should it factor in historical session cost averages from past JSONL files?
- Should it estimate output tokens (harder — requires heuristics or historical ratios)?
- What's the minimum viable version vs. the full version?

## Constraints
- Standard CODE session rules apply
- Max 3 files per atomic commit
- Must stay under 7 top-level commands (this would be #7)
- Branch: `session-17-pre-run-cost-estimate`
