# ADR-0002 — Engine trait, adapter contract, and module layout for v1 compression

- **Status:** ✅ **Accepted** — ratified by Suman 2026-06-16 (panel-recommended same day).
- **Date:** 2026-06-16
- **Phase:** Design · **Design Session 2** (defines the build-level interfaces that DS1/ADR-0001 left open).
- **Deciders:** Panel — Systems Architect · Principal Engineer · Practitioner; closed by Red-Team. Chair/facilitator: Claude Code. Ratifier: Suman.
- **Depends on:** [ADR-0001](0001-compression-delivery-mechanism.md) (delivery mechanism = CC PostToolUse hook).

---

## 1. Context & the question

ADR-0001 answered *how* compression is delivered (via the CC `PostToolUse` hook, injected through `claude --settings`). It mandated:

> *"Compression logic is a reusable ENGINE behind the locked adapter trait … The hook is the Claude Code delivery adapter; the engine is agent-neutral."*

It left the exact Rust interfaces — the Engine trait signature, the adapter's wire contract with CC, the module layout, and the heuristic dispatch strategy — to Design Session 2. That is what this ADR decides.

**Three questions for this session:**

1. What is the exact Rust interface between the engine and the adapter?
2. What is the wire protocol between `vajractl hook` and Claude Code (stdin/stdout JSON)?
3. How are the v1 modules laid out, and what classification strategy does the engine use?

---

## 2. Decisions

### 2.1 Engine trait

```rust
// engine/mod.rs  (public surface of the engine module)

/// Agent-neutral representation of a tool's output.
pub struct ToolOutput {
    pub stdout: String,
    pub stderr: String,
    pub exit_code: Option<i32>,  // None if not provided by the hook; see §5 G6
    pub interrupted: bool,
}

/// Everything the engine needs to make a compression decision.
pub struct CompressionRequest {
    pub command: String,   // from tool_input.command; empty string if absent
    pub output: ToolOutput,
}

/// The engine's verdict.
pub enum EngineDecision {
    /// Engine replaced the output. `lines_removed` is appended as a breadcrumb.
    Compressed { output: ToolOutput, lines_removed: usize },
    /// Engine chose not to compress. Adapter should pass original through.
    Passthrough,
}

/// The agent-neutral compression engine.  Implement this trait to swap engines.
pub trait Engine: Send + Sync {
    fn process(&self, req: &CompressionRequest) -> EngineDecision;
}
```

**Why `process`, not `compress`:** the engine sometimes decides *not* to compress (small output, unrecognised failure, etc.). `process` is accurate; `compress` implies a guarantee it cannot make.

**Why an enum, not `Option<ToolOutput>`:** v2 governance will need a `Block` variant. The enum makes that a free extension without a breaking change. The `Passthrough` variant also signals intent more clearly than `None`.

**Why `exit_code: Option<i32>`:** the ADR-0001 verified schema (`tool_response{stdout,stderr,interrupted,isImage,noOutputExpected}`) does not list `exit_code` explicitly. We include it as `Option` so we can handle it if CC provides it, and fall back safely if not (see G6).

**No async:** `vajractl hook` is a short-lived fork-exec process (one call per Bash tool invocation). Async overhead buys nothing; sync is simpler and starts faster.

### 2.2 ClaudeCodeHookAdapter

```rust
// adapter/claude_code.rs

pub struct ClaudeCodeHookAdapter<E: Engine> {
    engine: E,
}

impl<E: Engine> ClaudeCodeHookAdapter<E> {
    pub fn new(engine: E) -> Self;

    /// Reads one JSON object from `reader` (CC hook stdin), writes one JSON
    /// object to `writer` (CC hook stdout), returns Ok(()) on success.
    /// Callers (main) must treat any Err as "passthrough": write nothing and
    /// exit 0 so CC keeps the original output.
    pub fn run(&self, reader: impl Read, writer: impl Write) -> anyhow::Result<()>;
}
```

**No `AgentAdapter` trait in v1.** There is one adapter in v1; abstracting prematurely adds noise. The `Engine` trait already satisfies ADR-0001 G3 (the stubbed shim conformance test implements `Engine`, not an adapter trait). An adapter trait is a v2 task when a second agent requires it.

### 2.3 Wire protocol (CC hook stdin → stdout)

**Stdin** (one JSON object, parsed in full before processing):

```rust
#[derive(Deserialize)]
struct HookInput {
    tool_name: String,
    tool_input: HookToolInput,
    tool_response: HookToolResponse,
}

#[derive(Deserialize)]
struct HookToolInput {
    command: Option<String>,
}

#[derive(Deserialize)]
struct HookToolResponse {
    stdout: String,
    stderr: String,
    interrupted: bool,
    #[serde(rename = "isImage")]     is_image: bool,
    #[serde(rename = "noOutputExpected")] no_output_expected: bool,
    exit_code: Option<i32>,  // include; treat absent as unknown (see G6)
}
```

**Stdout** (one JSON object):

```rust
#[derive(Serialize)]
struct HookOutput {
    // Absent key → CC keeps original output (passthrough).
    #[serde(rename = "hookSpecificOutput", skip_serializing_if = "Option::is_none")]
    hook_specific_output: Option<HookSpecificOutput>,
}

#[derive(Serialize)]
struct HookSpecificOutput {
    #[serde(rename = "updatedToolOutput")]
    updated_tool_output: HookToolResponse,
}
```

**Passthrough wire signal:** emit `{}` to stdout (serialises `HookOutput { hook_specific_output: None }`). Do NOT exit non-zero — that risks a user-visible error. Do NOT emit `{"hookSpecificOutput":{}}` — the absent `updatedToolOutput` key has undefined CC behaviour; the absent top-level key is safer and confirmed by the ADR-0001 experiment.

**Breadcrumb format (appended to `stdout` in the `Compressed` case):**
```
[N lines hidden — set VAJRA_RAW=1 before `vajra claude` to disable]
```
Appended as the last line of `stdout`, separated by `\n`. The count `N` is `EngineDecision::Compressed.lines_removed`.

### 2.4 Adapter pre-checks (before calling engine)

The adapter runs these in order before dispatching to the engine. Any match → passthrough immediately:

1. `tool_name != "Bash"` — not a Bash tool result; don't touch it.
2. `tool_response.is_image` — binary image output; engine can't compress it.
3. `tool_response.no_output_expected` — CC flagged this as intentionally empty.
4. `VAJRA_RAW` env var set — user requested lossless mode for this call.

### 2.5 Classification strategy (inside DefaultEngine)

**Command dispatch** (first-token matching, then refinements):

```
command string
  → strip to basename of first token (handles /usr/bin/cargo, ./cargo)
  → compound-command check: if command contains &&, ||, |, ;, `...`, $(...) → GenericHeuristic
  → match basename:
      "cargo"         → CargoHeuristic
      "pytest"        → PytestHeuristic
      "python"/"python3" AND command contains "-m pytest" or "pytest" → PytestHeuristic
      "npm"/"npx"/"yarn" → NpmHeuristic
      "git"           → GitHeuristic
      "docker"/"docker-compose" → DockerHeuristic
      _               → GenericHeuristic
```

**Internal `Heuristic` trait (NOT public):**

```rust
// engine/default.rs  (private)
trait Heuristic {
    fn process(&self, output: &ToolOutput) -> EngineDecision;
}
```

Each heuristic is a unit struct in `engine/heuristics/<name>.rs`. The `DefaultEngine` owns no state (heuristics are stateless); `process()` constructs the right heuristic and calls it. `DefaultEngine` implements the public `Engine` trait.

**Why compound-command fallback:** `cargo build && echo done` has `cargo` as the first token but mixed output the cargo heuristic won't recognise correctly on failure. Generic (head+tail truncation) is safe; a wrong tool-specific heuristic is not.

### 2.6 Module layout

```
vajractl/
  Cargo.toml
  src/
    main.rs                  ← CLI entry: subcommands, fail-open wrapper
    cli/
      hook.rs                ← `vajractl hook` subcommand (the CC PostToolUse handler)
      launch.rs              ← `vajra claude` launcher + --settings injector
    engine/
      mod.rs                 ← Engine trait, ToolOutput, CompressionRequest, EngineDecision (public)
      default.rs             ← DefaultEngine + dispatch fn (pub(crate))
      heuristics/
        mod.rs
        cargo.rs
        generic.rs
        git.rs
        pytest.rs
        npm.rs
    adapter/
      claude_code.rs         ← ClaudeCodeHookAdapter + wire types (serde structs)
    meter/
      mod.rs                 ← JSONL cost calculator (Design Session 3)
  tests/
    hook_adapter.rs          ← integration: feed raw fixture JSON → assert output JSON
    engine_fixtures.rs       ← unit: raw/* → expected/* (from compression-fixtures/SPEC.md)
    shim_stub.rs             ← G3 conformance: stub Engine impl compiles + satisfies trait
  bench/
    fixtures/
      cost_fixture.jsonl     ← JSONL-RECON §6 fixture (schema tripwire)
      pricing.toml           ← pinned price table
```

**Single crate, no workspace split.** The engine is not consumed by another binary in v1. A workspace split would create crate overhead with no benefit. Revisit when v2 adds a second binary or a published library.

### 2.7 `main.rs` fail-open contract

```rust
fn main() {
    let args = cli::parse();
    match args.subcommand {
        Subcommand::Hook => {
            // VAJRA_RAW check happens here (before any stdin read)
            if std::env::var("VAJRA_RAW").is_ok() {
                std::process::exit(0);  // CC keeps original
            }
            let adapter = ClaudeCodeHookAdapter::new(DefaultEngine::new());
            if let Err(e) = adapter.run(io::stdin(), io::stdout()) {
                eprintln!("[vajra] hook error (passthrough): {e}");
                std::process::exit(0);  // fail-open
            }
        }
        Subcommand::Launch(args) => cli::launch::run(args),
    }
}
```

The adapter MUST NOT call `process::exit` — it must return `Result` so tests can call `run()` without killing the test runner.

---

## 3. Rationale (decisive points)

1. **`process()` not `compress()`** — the engine is a decision function. Naming it accurately prevents the assumption that it always compresses, which would make the `Passthrough` path feel wrong.
2. **Enum return, not `Option`** — v2 governance adds `Block`. Adding a variant to an enum is non-breaking; changing `Option<ToolOutput>` to a 3-case type is a refactor.
3. **No `AgentAdapter` trait in v1** — ADR-0001 G3 requires a stubbed conformance test for the *engine*, not the adapter. A second adapter trait would be a premature abstraction with no concrete second implementor.
4. **`{}` as passthrough** — not exiting non-zero (risk of user-visible error) and not `{"hookSpecificOutput":{}}` (undefined behaviour for absent `updatedToolOutput`). The cleanest safe signal.
5. **Compound command fallback** — silent misclassification of `cargo build && echo done` would apply the cargo heuristic to mixed output. Generic is always safe; a false-positive tool-specific heuristic is a task-success risk (the kill metric).
6. **Single crate** — one binary in v1; module boundaries give the same logical separation as separate crates without the overhead.

---

## 4. What this costs — accepted trade-offs

- **No adapter trait in v1** means v2 must introduce it as a refactor (not a free extension). Accepted: the Engine trait already proves the rail; the adapter is thin protocol glue that will be obvious to extract.
- **`exit_code: Option<i32>`** means the failure-detection rule is slightly conservative (see G6). Accepted: false-passthrough (keeping output verbatim when we could have compressed it) is always safer than false-compression.
- **Heuristics are a private trait** — they cannot be extended by downstream users in v1. Accepted: v1 heuristic coverage is fixed to the `compression-fixtures/SPEC.md` corpus; user-extensible heuristics are a v2+ feature.

---

## 5. Guardrails this ADR MANDATES (release-blocking for v1)

*(G1–G4 are inherited from ADR-0001 and remain in force.)*

- **G5 — `tool_name` pre-check.** The adapter MUST check `tool_name == "Bash"` before calling the engine. Any other tool name → passthrough. This is belt-and-suspenders (the hook is registered on Bash only) but guards against future hook-registration widening.

- **G6 — Compress only on confirmed success.** The engine MUST only apply tool-specific compression when it can confirm the command succeeded. Confirmation hierarchy (in order):
  1. `exit_code == Some(0)` — explicit zero exit.
  2. `exit_code == None && interrupted == false && output contains an unambiguous success marker` (e.g., `Finished dev profile` in cargo output) — inferred success.
  3. Anything else → passthrough.
  This prevents silently compressing failure output when `exit_code` is absent from the hook payload.

- **G7 — `VAJRA_RAW` is checked at two layers.** (a) In `vajractl hook`: check at startup before reading stdin, exit 0 immediately. (b) In `vajra claude` launcher: if `VAJRA_RAW` is set in the environment at launch time, skip hook injection entirely. Both layers are tested.

- **G8 — Settings merge minimum contract (implementation deferred to DS3).** The `--settings` injector MUST merge Vajra's `PostToolUse.Bash` hook entry with any pre-existing hooks found in BOTH `~/.claude/settings.json` (global) and `.claude/settings.json` (project). If the CC settings schema does not support an array of hooks for a single tool event, Vajra MUST warn to stderr and skip injection for that session (fallback: run bare `claude` without the hook). DS3 resolves the implementation; this ADR locks the minimum safe contract.

---

## 6. Open implementation questions (NOT decisions — resolve at code time)

- **Does CC's PostToolUse hook payload include `exit_code`?** The ADR-0001 experiment verified `{stdout, stderr, interrupted, isImage, noOutputExpected}`. If `exit_code` is absent, G6's inferred-success rule is the fallback. Verify against CC v2.1.177 fixture in `bench/fixtures/`.
- **What is CC's exact passthrough behaviour for `{}`?** The experiment confirmed `updatedToolOutput` replaces output when present. Verify that its absence is a clean passthrough (not an error). Add to G1 conformance test.
- **Does `claude --settings` accept a raw JSON string or only a file path?** If file-only, the launcher must write a tempfile and clean it up. If JSON-string, the tempfile is optional. Verify from CC CLI reference.

---

## 7. Consequences (for the build)

The next implementation units, in order:

1. **`engine/mod.rs`** — `Engine` trait + `ToolOutput` + `CompressionRequest` + `EngineDecision`. No heuristics yet; just the types + trait.
2. **`tests/shim_stub.rs`** — G3 conformance: a no-op `struct StubEngine;` that implements `Engine` and returns `Passthrough`. Proves the trait compiles and is implementable before any heuristic exists.
3. **`engine/heuristics/`** + **`engine/default.rs`** — `DefaultEngine` with the real heuristics (cargo, git, generic, pytest, npm), driven by the `compression-fixtures/SPEC.md` corpus.
4. **`adapter/claude_code.rs`** — `ClaudeCodeHookAdapter` with the wire types + pre-checks + `run()`. Tested via `tests/hook_adapter.rs` with real fixture JSON.
5. **`cli/hook.rs`** — thin entry point: pre-checks, constructs adapter + engine, calls `run()`, fail-open wrapper.
6. **`cli/launch.rs`** — `vajra claude` launcher + `--settings` injector (G2/G8 merge logic — detailed design in DS3).
7. **`meter/`** — JSONL cost calculator (detailed design in DS3+).

---

## 8. Method note

Three specialist lenses wrote blind (Round 1) and reached unanimous agreement on the major structural decisions (enum return, no adapter trait in v1, `{}` passthrough, single crate). Cross-examination was used to resolve two details: the compound-command dispatch fallback (Practitioner finding, adopted without dissent) and the settings-merge scope (deferred to DS3 with a stated minimum contract). The Red-Team added two guardrails (G5 `tool_name` pre-check; G6 confirmed-success rule) and clarified the `exit_code` gap as an open implementation question, not a blocker. No reversal of major decisions.
