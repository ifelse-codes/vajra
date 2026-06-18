# Session 02 — Compression Heuristics

## Trigger
User picked Option A from `sessions/session-01-summary.md` after Session 01 closeout.

## Goal
Implement tool-specific compression heuristics for cargo, git, pytest, npm, and a generic fallback. Each heuristic is a standalone module that detects its tool from stdout/stderr and applies lossy-but-safe folding rules.

## Deliverables

### 1. `src/engine/heuristic/mod.rs`
- `pub trait Heuristic: Send + Sync { fn detect(&self, request: &CompressionRequest) -> bool; fn compress(&self, request: &CompressionRequest) -> String; }`
- `pub fn select_heuristic(request: &CompressionRequest) -> Box<dyn Heuristic>` — dispatches by regex on `request.tool_output.tool`
- `pub struct GenericHeuristic;` — fallback: if lines > LINE_CAP, head+tail truncation with `[N hidden]`

### 2. `src/engine/heuristic/cargo.rs`
- `pub struct CargoBuildHeuristic;` — detects `"cargo build"`, folds exit-0 `Compiling` spam to `✓ cargo build — Finished ... (N crates compiled)`
- `pub struct CargoTestHeuristic;` — detects `"cargo test"`:
  - exit 0: collapse `test … ok` to count-per-suite summary
  - exit ≠ 0: keep every failing test name + panic trace verbatim, collapse passing to count
- Unit tests with fixtures from `research/compression-fixtures/raw/`

### 3. `src/engine/heuristic/git.rs`
- `pub struct GitLogHeuristic;` — passthrough if ≤ LINE_CAP, otherwise head+tail summary
- `pub struct GitStatusHeuristic;` — always passthrough (decision-critical)
- `pub struct GitDiffStatHeuristic;` — always passthrough (already narrowed)
- Unit tests with fixtures

### 4. `src/engine/heuristic/pytest.rs`
- `pub struct PytestHeuristic;` — fold pass details to counts, keep failures verbatim, drop header/compilation noise on exit 0

### 5. `src/engine/heuristic/npm.rs`
- `pub struct NpmTestHeuristic;` — fold npm test pass output, preserve failures verbatim

### 6. `src/engine/heuristic/tests.rs` (integration)
- Table-driven tests: `compress(raw_fixture_path) == expected` for every fixture in `research/compression-fixtures/`
- Lossless invariant test: raw lines == decompress(compress(raw)) (stub, full in Session 03)
- Passthrough gate test: small output never modified

### 7. `src/engine/default_engine.rs`
- `pub struct DefaultEngine; impl Engine for DefaultEngine` — calls `select_heuristic(request).compress(request)`, wraps in `EngineDecision::Compress { tool }`
- On heuristic panic → `EngineDecision::Passthrough` (fail-open)

### 8. `scripts/verify-session-02.sh`
- Copy from template, uncomment cargo checks. Add `run_check "cargo-test-fixtures" cargo test --test fixture_tests` if separate test target exists, else use `cargo test --all-targets`.

## Constraints Operative
- Max 3 files per atomic commit.
- No adapter JSON parsing (Session 03–04).
- No meter (Session 04–05).
- No `async`.
- Use `anyhow::Result`.
- Every heuristic module must have `#[cfg(test)]` unit tests with real fixture data.
- Fail-open: if heuristic panics or can't classify → passthrough.

## Decisions to Make (if any)
- Fixture file path strategy. Default: read at compile time via `include_str!` so tests are hermetic.
- Whether to put fixture tests in `tests/` or `#[cfg(test)]` in modules. Default: `#[cfg(test)]` in each heuristic module for unit tests; integration in `tests/compress_fixtures.rs`.
- Whether to share a `strip_ansi` helper across heuristics. Default: yes, in `heuristic/mod.rs` as `pub(crate) fn`.

## Exit Criteria
- `cargo check --all-targets` exits 0.
- `cargo test --all-targets` exits 0 (all heuristic unit tests + integration tests pass).
- `cargo fmt -- --check` exits 0.
- `cargo clippy --all-targets -- -D warnings` exits 0.
- Every fixture in `research/compression-fixtures/raw/` has a corresponding test that asserts compressed output matches expected shape.

## Explicit Non-Goals
- No JSON adapter wire types.
- No settings injector merge logic.
- No meter / receipt.
- No bench fixtures or tripwire.
- No real `claude` spawn in launch.rs.
- No lossless decompress (stub only; full in Session 03).
