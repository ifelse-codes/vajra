# Session 03 — Claude Code Hook Adapter + Wire Types

## Trigger
User picked Option A from session closeout.

## Goal
Build the bridge between the Claude Code `PostToolUse` hook and the compression engine. Define serde wire types, implement the adapter that reads hook JSON from stdin and writes compressed JSON to stdout, and wire the `hook` CLI subcommand to use it.

## Deliverables

### 1. Type alignment with ADR-0002
- `src/engine/mod.rs` — update `ToolOutput` to add `interrupted: bool`, change `exit_code` to `Option<i32>`. Move `tool` out of `ToolOutput` into `CompressionRequest::command`.
- `src/engine/mod.rs` — change `EngineDecision::Compress { tool, output }` to `EngineDecision::Compressed { output: String, lines_removed: usize }`.
- Update all heuristic modules (`cargo.rs`, `git.rs`, `npm.rs`, `pytest.rs`, `mod.rs`, `default_engine.rs`) and tests to match new types.

### 2. `src/adapter/mod.rs` + `src/adapter/claude_code.rs`
- Wire types (serde Deserialize/Serialize):
  - `HookInput { tool_name, tool_input: HookToolInput, tool_response: HookToolResponse }`
  - `HookToolInput { command: Option<String> }`
  - `HookToolResponse { stdout, stderr, interrupted, is_image, no_output_expected, exit_code: Option<i32> }`
  - `HookOutput { hook_specific_output: Option<HookSpecificOutput> }`
  - `HookSpecificOutput { updated_tool_output: HookToolResponse }`
- `ClaudeCodeHookAdapter<E: Engine>` with `run(reader, writer) -> Result<()>`
- Pre-checks (G5–G7): `tool_name == "Bash"`, `!is_image`, `!no_output_expected`, `VAJRA_RAW` env check
- Passthrough: emit `{}` (empty JSON object) to stdout
- Compressed: construct `HookSpecificOutput` with `updated_tool_output`; append breadcrumb `[N lines hidden — set VAJRA_RAW=1 to disable]` to stdout

### 3. `src/cli/hook.rs`
- Replace StubEngine with `ClaudeCodeHookAdapter::new(DefaultEngine)`
- Read stdin, write stdout, exit 0 on success or error (fail-open)
- `VAJRA_RAW=1` check before stdin read → exit 0 immediately

### 4. `tests/hook_adapter.rs`
- Integration test: feed fixture JSON to adapter, assert output JSON shape
- Passthrough test: non-Bash tool_name → `{}`
- Compression test: Bash + cargo build fixture → `updatedToolOutput` present, stdout compressed
- VAJRA_RAW test: env var set → `{}`
- is_image test: `isImage: true` → `{}`
- Fail-open test: malformed JSON → `{}` (not error)

### 5. `scripts/verify-session-03.sh`
- Copy from template, uncomment cargo checks + test runs.

## Constraints Operative
- Max 3 files per atomic commit.
- No `async`.
- Fail-open: any adapter error → passthrough (exit 0, emit `{}`).
- `VAJRA_RAW=1` disables hook before any stdin read.
- No settings injector (Session 04).
- No meter (Session 04–05).

## Decisions to Make (if any)
- Exact breadcrumb format. ADR says: `[N lines hidden — set VAJRA_RAW=1 to disable]`. Default to ADR.
- Whether to refactor types or shim. Default: refactor to match ADR-0002 (single session, isolated commit).

## Exit Criteria
- `cargo check --all-targets` exits 0.
- `cargo test --all-targets` exits 0 (all adapter + heuristic + G3 tests pass).
- `cargo fmt -- --check` exits 0.
- `cargo clippy --all-targets -- -D warnings` exits 0.
- Adapter integration tests cover passthrough, compression, VAJRA_RAW, is_image, fail-open.

## Explicit Non-Goals
- No settings injector / `--settings` merge (Session 04).
- No `claude` binary spawn in launcher (Session 04).
- No meter / receipt (Session 04–05).
- No bench fixtures.
