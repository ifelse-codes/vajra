---
role: implementation-advisor
session: 148
agent: claude-code-subagent (verified: toolu_01WQsYaGvYfWQvi6TkmEAX4C)
source-sha: 7e9ea66f9c8e4d2a1b3c5f7e9a0b2d4f6e8c0a2b
captured: 2026-09-06T16:00:00Z
cost_usd: null
---

# Session 148 — Implementation-Advisor Handoff

**Role:** implementation-advisor
**Session:** 148 — Close Test-Runner Compression Gaps
**Brief scope:** `src/engine/heuristic/mod.rs`, `src/engine/heuristic/npm.rs`, `src/engine/heuristic/cargo.rs`, `src/engine/heuristic/pytest.rs`

---

## Implementation Brief

### Gap A — bare `jest` dispatch

The existing dispatch table in `src/engine/heuristic/mod.rs` dispatches on `npm test` and `npm run test`; bare `jest` is absent. Add a new dispatch arm BEFORE the `npm` arm:

```rust
} else if cmd.starts_with("jest") {
    Box::new(npm::JestHeuristic)
}
```

Add `JestHeuristic` as a new struct in `src/engine/heuristic/npm.rs`. The existing `NpmTestHeuristic` is the model — copy its structure, swap the detection pattern from `Tests:.*passed` (jest canonical summary line), and implement `compress` targeting jest output shape. Key constraint from AC5: if no `Tests:` summary line is found, return input unchanged (non-matching passthrough).

### Gap B — fail-path threshold for 30-399 line outputs

Three heuristics must change:
- `CargoTestHeuristic`, `PytestHeuristic`, `NpmTestHeuristic` all need `preserves_failure_signal() → true` — this overrides the engine's fail-gate, which otherwise passes through anything > 0 failures unchanged.
- Internal `compress_*_fail` functions use a hardcoded `400` threshold; lower to a shared constant `FAIL_COMPRESS_FLOOR = 20` (defined in `mod.rs`).

### Shared helpers in `mod.rs`

Three shared items to add to `src/engine/heuristic/mod.rs`:
- `pub const FAIL_COMPRESS_FLOOR: usize = 20;`
- `pub fn fold_notice(dropped: usize) -> String` — produces `[vajra] N lines folded — set VAJRA_RAW=1 to see full output`
- `pub fn is_failure_line(line: &str) -> bool` — case-sensitive substring check for `FAILED`, `PANIC`, `panicked at`, `✕` (U+2715)

Using shared helpers prevents per-heuristic format drift (AC4 requires exact notice format across all three).

---

## Recommendations

rec 1 — keep `compress_jest_family_fail` and `compress_jest_pass` as separate functions (not one `compress` that branches); the pytest/cargo precedent is cleaner and makes unit testing the two paths independently straightforward.

rec 2 — the verify script and tests must assert that the compressed output is **shorter** than the input, not just that failure lines are present. A passthrough masquerading as compression (returning all lines) would satisfy AC3/AC4 but violate AC7. Add a `shorter_than_input` assertion in each compress-path test.

rec 3 — `compress_cargo_build_fail` in `cargo.rs` should keep its threshold at `FAIL_PASSTHROUGH_CAP` (not lowered to `FAIL_COMPRESS_FLOOR`) — it is a build heuristic, not a test heuristic; AC7 applies only to test heuristics.

---

## Files touched

- `src/engine/heuristic/mod.rs` — shared constants + helpers + dispatch arm
- `src/engine/heuristic/npm.rs` — JestHeuristic + NpmTestHeuristic gap-B fix
- `src/engine/heuristic/cargo.rs` — CargoTestHeuristic gap-B fix
- `src/engine/heuristic/pytest.rs` — PytestHeuristic gap-B fix

## Handoff Delta
- `+` new: first implementation-advisor handoff for session 148
