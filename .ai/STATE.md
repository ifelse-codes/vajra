# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S01 complete, S02 not yet started).

## Active PRs
None.

## What Currently Works
- Agent constitution at `.ai/AGENTS.md`. Root pointers resolve to it.
- Single-integer SoT at `.ai/SESSION` (= 01).
- Design phase complete: 4 ADRs ratified (0001–0004).
- Research and compression fixtures in `research/`.
- `VAJRA-MASTER.md` + `DESIGN-BRIEF.html` as source docs.
- Rust crate scaffold: `vajractl` compiles and passes tests.
- Engine trait + types + constants defined in `src/engine/mod.rs`.
- G3-conformant `StubEngine` + placeholder `DefaultEngine`.
- CLI skeleton: `Hook`, `Launch`, `Meter` subcommands with fail-open wrapper.
- Verify script for Session 01 runs and passes.

## What Is Broken
- Nothing in protocol.

## What Is In Progress
- Between sessions. Start S02 from `sessions/session-01-summary.md` after picking A/B/C.

## Cost Tracking
- Session 00: $0.00 (bootstrap, no API calls)
- Session 01: $0.00 (no API calls)
- Cumulative: $0.00
