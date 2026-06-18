# Review — Session 02

## Verdict
NEEDS_FIXES

## Issues

1. File: `src/engine/default_engine.rs`
   Problem: `DefaultEngine` does NOT fail-open on heuristic panic. The spec requires `On heuristic panic → EngineDecision::Passthrough (fail-open)`, but `decide()` unconditionally calls `heuristic.compress(request)` without `std::panic::catch_unwind` or any safeguard.
   Suggested fix: Wrap `heuristic.compress(request)` in `std::panic::catch_unwind` (or equivalent). On panic, return `EngineDecision::Passthrough`.

2. File: `src/engine/heuristic/cargo.rs:91`
   Problem: Typo in `compress_cargo_test_fail`: `trimmed.ends_with("fAILED")` (lowercase `f`) will never match real cargo output. This condition is dead code.
   Suggested fix: Remove the `|| trimmed.ends_with("fAILED")` clause entirely, or fix the typo to `FAILED` (redundant since the preceding check already covers it).

3. File: `src/engine/heuristic/mod.rs:57`
   Problem: `GenericHeuristic` truncation marker uses `[N lines hidden]` but the spec explicitly requires `[N hidden]`.
   Suggested fix: Change the format string from `"… [{} lines hidden] …"` to `"… [{} hidden] …"`.

4. File: `src/engine/heuristic/git.rs:47`
   Problem: `GitLogHeuristic` uses `lines.len() - head_count - tail_count` without `saturating_sub`, which could theoretically panic if `head_count + tail_count > lines.len()`. In practice `lines.len() > LINE_CAP (200)` and `head+tail = 20`, so this won't panic, but `saturating_sub` is safer and consistent with `GenericHeuristic`.
   Suggested fix: Use `lines.len().saturating_sub(head_count + tail_count)` for the hidden count.

## Checks

| Check | Result |
|-------|--------|
| Implementation matches spec (overall) | PASS with gaps noted above |
| `cargo check --all-targets` | PASS |
| `cargo test --all-targets` | PASS (33 tests passed) |
| `cargo fmt -- --check` | PASS |
| `cargo clippy --all-targets -- -D warnings` | PASS |
| `EngineDecision::Compress` has `output: String` | PASS (`src/engine/mod.rs:6`) |
| `DefaultEngine` calls `select_heuristic` and wraps output | PASS |
| `select_heuristic` dispatches by `starts_with` on `tool_output.tool` | PASS (spec says "regex" but user's checklist #8 confirms `starts_with`) |
| `GenericHeuristic` head+tail truncates with `[N hidden]` | FAIL — uses `[N lines hidden]` |
| `CargoBuildHeuristic` on exit 0 folds compile spam to summary | PASS |
| `CargoTestHeuristic` on exit 0 drops `test … ok` noise | PASS |
| Git heuristics passthrough appropriately | PASS |
| Unit tests in each heuristic module (`#[cfg(test)]`) | PASS |
| Integration fixture tests in `tests/heuristic_fixtures.rs` | PASS |
| `DefaultEngine` fail-open on panic | FAIL — no panic handling |
| Code quality / unused imports | PASS — no unused imports detected |
