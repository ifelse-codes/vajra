# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
`session-03-hook-adapter` — PR pending (no remote configured).

## Active PRs
None (no remote).

## What Currently Works
- Agent constitution at `.ai/AGENTS.md`. Root pointers resolve to it.
- Single-integer SoT at `.ai/SESSION` (= 03).
- Design phase complete: 4 ADRs ratified (0001–0004).
- Research and compression fixtures in `research/`.
- `VAJRA-MASTER.md` + `DESIGN-BRIEF.html` as source docs.
- Rust crate scaffold: `vajractl` compiles and passes tests (41 tests).
- Engine trait + types per ADR-0002: `CompressionRequest::command`, `ToolOutput` with `interrupted`/`Option<i32>`, `EngineDecision::Compressed { output, lines_removed }`.
- Compression heuristics (cargo, git, pytest, npm, generic) all updated to new types.
- `DefaultEngine` with fail-open `catch_unwind`; returns `Passthrough` when `lines_removed == 0`.
- `ClaudeCodeHookAdapter<E: Engine>` in `src/adapter/claude_code.rs` — reads CC hook JSON, runs engine, writes `hookSpecificOutput` or `{}`.
- Pre-checks G5–G7 (Bash-only, no image, no noOutputExpected); VAJRA_RAW bypass.
- `hook` CLI subcommand wired to `ClaudeCodeHookAdapter::new(DefaultEngine)`.
- Compression verified: `cargo build` 180→1 line (99%), `cargo test` 84→1 line (98%).
- Enforce layers L2–L5 in place. L0/L1 deferred until remote + CI exist.
- `scripts/verify-session-03.sh` passes (4/4 checks green).
- `scripts/demo-session-03.sh` — 8-case end-to-end demo.

## What Is Broken
- `LINE_CAP = 200` in code but ADR-0003 specifies 30. Carry-forward to S04.
- No remote configured — L0/L1 enforcement and `gh pr create` blocked.

## What Is In Progress
- Between sessions. Start S04 from `prompts/04-task-launcher.md` in a new chat.

## Cost Tracking
- Session 00: $0.00 (bootstrap, no API calls)
- Session 01: $0.00 (no API calls)
- Session 02: $0.00 (no API calls)
- Session 03: $0.00 (no API calls)
- Cumulative: $0.00
