# Session 01 — Cargo Scaffold + Engine Trait

## Trigger
User picked Option A from `sessions/session-00-summary.md` after Session 00 closeout.

## Goal
Initialize the Rust crate and build the engine foundation: trait, types, constants, and G3 conformance stub. Zero compression logic — just the contract everything else builds on.

## Deliverables
1. `Cargo.toml` — crate `vajractl`, binary target, minimal deps (`anyhow`, `serde`, `serde_json`).
2. `src/main.rs` — entry point with `Subcommand` enum (`Hook`, `Launch`, `Meter`), fail-open wrapper.
3. `src/engine/mod.rs` — `Engine` trait + `ToolOutput` + `CompressionRequest` + `EngineDecision` + `LINE_CAP` + `FAIL_PASSTHROUGH_CAP`.
4. `tests/shim_stub.rs` — G3 conformance: `struct StubEngine` implements `Engine`, returns `Passthrough`. Compiles and passes.
5. `src/cli/hook.rs` — thin `hook` subcommand entry point (constructs adapter + engine, calls `run()`, fail-open).
6. `src/cli/launch.rs` — `vajra claude` launcher skeleton (args parsing, bare `claude` spawn+wait).

## Constraints Operative
- Max 3 files per atomic commit.
- No heuristics yet (that's Session 02–03).
- No adapter JSON parsing yet (that's Session 03–04).
- No meter yet (that's Session 04–05).
- `VAJRA_RAW=1` must disable hook before any stdin read.
- Use `anyhow::Result` for error propagation.
- No `async` — sync only.

## Decisions to Make (if any)
- Exact Cargo.toml dependency versions. Default to latest stable unless user specifies.
- Whether to include `clap` for CLI parsing in v1 or use manual args. **Default:** manual to minimize deps for v1; revisit if CLI grows.

## Exit Criteria
- `cargo check` exits 0.
- `cargo test` exits 0 (at least the G3 stub test passes).
- `cargo fmt -- --check` exits 0.
- Engine trait compiles with both `StubEngine` and a placeholder `DefaultEngine` (empty impl).

## Explicit Non-Goals
- No compression heuristics (cargo, git, etc.).
- No Claude Code adapter wire types.
- No settings injector merge logic.
- No meter / receipt.
- No bench fixtures.
