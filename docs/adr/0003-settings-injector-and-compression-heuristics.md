# ADR-0003 — `--settings` injector design and compression engine heuristics

- **Status:** ✅ **Accepted** — ratified by Suman 2026-06-16 (panel-recommended same day).
- **Date:** 2026-06-16
- **Phase:** Design · **Design Session 3.**
- **Deciders:** Panel — Systems Architect · Principal Engineer · Practitioner; closed by Red-Team. Chair/facilitator: Claude Code. Ratifier: Suman.
- **Depends on:** [ADR-0001](0001-compression-delivery-mechanism.md) (G2 hook-merge contract); [ADR-0002](0002-engine-trait-adapter-contract-module-layout.md) (G8 minimum contract; Engine trait + ToolOutput types).

---

## 1. Context & the questions

ADR-0002 G8 deferred the `--settings` injector implementation to DS3 with a stated minimum contract:

> *"The `--settings` injector MUST merge Vajra's `PostToolUse.Bash` hook entry with any pre-existing hooks found in BOTH `~/.claude/settings.json` (global) and `.claude/settings.json` (project). If the CC schema does not support an array of hooks for a single tool event, Vajra MUST warn and skip injection for that session."*

ADR-0002 also left the compression heuristics — their algorithms, line-cap constants, and per-tool contracts — to DS3.

**Two question clusters for this session:**

**A — Injector:** How does `vajra claude` merge settings without violating G2? What file, which paths, what error handling, what process model?

**B — Heuristics:** What are the line-cap constants? What do the universal pre-rules look like? What does each per-tool heuristic guarantee?

---

## 2. Decisions

### 2.1 Settings injector design

#### 2.1.1 File path, not JSON string

`claude --settings` accepts a file path (also JSON string, but that introduces shell-escaping hazards). v1 uses a **tempfile**. No JSON string injection.

#### 2.1.2 Tempfile type with Drop-based cleanup

```rust
// cli/launch.rs

struct TempSettings { path: PathBuf }

impl TempSettings {
    fn write(hooks: serde_json::Value) -> anyhow::Result<Self> {
        let path = std::env::temp_dir()
            .join(format!("vajra-{}.json", uuid_simple()));
        let payload = serde_json::json!({ "hooks": hooks });
        std::fs::write(&path, serde_json::to_string_pretty(&payload)?)?;
        Ok(Self { path })
    }
    fn path(&self) -> &Path { &self.path }
}

impl Drop for TempSettings {
    fn drop(&mut self) { let _ = std::fs::remove_file(&self.path); }
}
```

The launcher uses `std::process::Command::spawn() + wait()` — **not `exec()`** — so the Rust process stays alive, `Drop` runs on exit, and the tempfile is cleaned up. The one-process-layer overhead is negligible.

#### 2.1.3 What the tempfile contains

The tempfile contains **only the `hooks` key** — not the full settings. This assumes CC treats `--settings` as an additive layer (the earlier global/project/local layers still apply for model, permissions, etc.). If this assumption is wrong the conformance test (G9) will catch it.

```json
{ "hooks": { "PostToolUse": [ ...merged_entries... ] } }
```

#### 2.1.4 Merge algorithm

```
global_hooks  = read_hooks("~/.claude/settings.json")     // or {} if absent/malformed
project_hooks = read_hooks(".claude/settings.json")        // CWD; walk up to git root
local_hooks   = read_hooks(".claude/settings.local.json")  // CWD

merged = concat(global_hooks.PostToolUse,
                project_hooks.PostToolUse,
                local_hooks.PostToolUse)

// Dedup: skip if "vajractl" already appears in any hook command field
unless merged.any(|entry| entry.hooks.any(|h| h.command.contains("vajractl"))):
    merged.append(vajra_hook_entry())

write_tempfile({ "PostToolUse": merged })
```

`vajra_hook_entry()`:
```json
{ "matcher": "Bash", "hooks": [{ "type": "command", "command": "vajractl hook" }] }
```

**Dedup check:** scan for `"vajractl"` as a substring in command fields (not the full `"vajractl hook"` string). This handles aliased paths (`/usr/local/bin/vajractl hook`) and nested calls.

#### 2.1.5 Error handling ladder (all "soft fail" → run bare `claude`)

| Condition | Action |
|---|---|
| `vajractl` not found in PATH | **Fatal exit** with message; don't create tempfile |
| `claude` not found in PATH | Fatal exit with message |
| Settings file exists but malformed JSON | Warn one line to stderr; skip injection; run bare `claude` |
| Settings schema mismatch (G9) | Warn one line; skip injection; run bare `claude` |
| Tempfile write fails | Warn one line; skip injection; run bare `claude` |

Verbose details behind `VAJRA_DEBUG=1` (print tempfile path + content, extended warnings).

#### 2.1.6 Minimum hook schema (CC settings — pinned for G9)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "<string>",
        "hooks": [{ "type": "command", "command": "<string>" }]
      }
    ]
  }
}
```

G9 validation: before merging, check that any `hooks.PostToolUse` value in the settings files is an **array** (not object, not null). On type mismatch → schema has drifted → warn + skip injection.

---

### 2.2 Heuristic constants

```rust
// engine/mod.rs  (public, shared by DefaultEngine and tests)

/// Output shorter than this passes through unconditionally.
pub const LINE_CAP: usize = 30;

/// Failed output shorter than this passes through verbatim (mid-debug safety).
/// Matches the "< ~400 lines" rule from compression-fixtures/SPEC.md §4.
pub const FAIL_PASSTHROUGH_CAP: usize = 400;
```

Rationale for 30: `git log --oneline -40` at 21 lines passes through; `ls -R src` at 46 lines compresses. 30 is the validated split point from the real fixture corpus.

Rationale for 400: from SPEC.md §4 ("exit ≠ 0 AND < ~400 lines → passthrough verbatim — the agent is mid-debug"). Rounded to 400 for a clean constant.

---

### 2.3 Universal pre-rules in `DefaultEngine::process()`

```rust
pub fn process(&self, req: &CompressionRequest) -> EngineDecision {
    let line_count = req.output.stdout.lines().count();

    // Pre-rule 1: small output — never compress
    if line_count < LINE_CAP {
        return EngineDecision::Passthrough;
    }

    // Pre-rule 2: unconfirmed failure, small enough — passthrough (mid-debug)
    if !is_success(&req.output) && line_count < FAIL_PASSTHROUGH_CAP {
        return EngineDecision::Passthrough;
    }

    // Pre-rule 3: compound command — use generic heuristic (safe, no misclassification)
    if is_compound(&req.command) {
        return GenericHeuristic.process(&req.output, line_count);
    }

    // Dispatch to tool-specific heuristic
    dispatch(&req.command).process(&req.output, line_count)
}
```

`is_compound`: returns `true` if the command string contains `&&`, `||`, `|`, `;`, `` ` ``, or `$(`.

---

### 2.4 `is_success` (G6 implementation)

```rust
fn is_success(output: &ToolOutput) -> bool {
    match output.exit_code {
        Some(0)  => true,
        Some(_)  => false,
        None if output.interrupted => false,
        None => infer_success(output),
    }
}

fn infer_success(output: &ToolOutput) -> bool {
    // Scan the last 5 stdout lines for unambiguous success markers
    let tail: Vec<&str> = output.stdout.lines().rev().take(5).collect();
    let tail_text = tail.join("\n");

    if tail_text.contains("Finished dev") || tail_text.contains("Finished release")
        || tail_text.contains("Finished test") || tail_text.contains("Finished bench") {
        return true;
    }
    if tail_text.contains("test result: ok") {
        return true;
    }
    if tail_text.contains(" passed") && !tail_text.contains(" failed")
        && !tail_text.contains(" error") {
        return true;
    }

    // Any error signals in stderr → not success
    if output.stderr.contains("error:") || output.stdout.contains("error[E") {
        return false;
    }

    false  // uncertain → conservative → treat as failure
}
```

This is conservative: returns `false` when uncertain, which triggers a passthrough (never a wrong compression). The cost is occasional missed compression on exotic success outputs. Correct tradeoff for v1.

---

### 2.5 Heuristic dispatch

```rust
fn dispatch(command: &str) -> Box<dyn Heuristic> {
    // Strip to basename, handle absolute paths
    let first_token = command.split_whitespace().next().unwrap_or("");
    let base = std::path::Path::new(first_token)
        .file_name().and_then(|n| n.to_str()).unwrap_or(first_token);

    match base {
        "cargo" => {
            let sub = cargo_subcommand(command);
            match sub {
                "build" | "test" | "check" | "run" | "bench" => Box::new(CargoHeuristic),
                "clippy" if !command.contains("--fix") => Box::new(CargoHeuristic),
                _ => Box::new(GenericHeuristic),  // fmt, fix, publish → generic (pass-through by line cap anyway)
            }
        }
        "pytest"              => Box::new(PytestHeuristic),
        "python" | "python3"  => {
            if command.contains("-m pytest") || command.contains("pytest") {
                Box::new(PytestHeuristic)
            } else {
                Box::new(GenericHeuristic)
            }
        }
        "npm" | "npx" | "yarn" | "pnpm" => Box::new(NpmHeuristic),
        "git"                 => Box::new(GitHeuristic),
        "docker" | "docker-compose" | "docker compose" => Box::new(DockerHeuristic),
        _                     => Box::new(GenericHeuristic),
    }
}

fn cargo_subcommand(command: &str) -> &str {
    // Skip toolchain flags (+nightly) and global flags (--workspace, --quiet) to find subcommand
    command.split_whitespace().skip(1)
        .find(|t| !t.starts_with('+') && !t.starts_with('-'))
        .unwrap_or("")
}
```

---

### 2.6 Per-heuristic contracts

All heuristics receive `(&ToolOutput, line_count: usize)` and return `EngineDecision`. The internal `Heuristic` trait is **not public** — it's a private abstraction inside `engine/default.rs`.

**Breadcrumb format (amended by Red-Team):** the breadcrumb appears as a **header line** before the compressed content, not a mid-separator. Format:

```
[vajra: N lines folded — VAJRA_RAW=1 before `vajra claude` to see full output]
```

This signals intent to the agent and prevents it from misinterpreting the compressed content as a truncated artifact.

#### `CargoHeuristic`

| Subcommand | Condition | Output |
|---|---|---|
| `build` | success | `✓ cargo build — <Finished line verbatim>` (1 line) |
| `test` | all pass | `[vajra: N lines folded…]\n✓ cargo test — all green in Xs\n  <test result: lines verbatim>` |
| `test` | large fail (≥ 400 lines) | `[vajra: N lines folded…]\n<FAILED blocks + panics verbatim>\n<failures: section verbatim>` |
| `check` / `run` / `bench` | success | `[vajra: N lines folded…]\n<last 5 lines>` |

Cargo `Finished` line pattern: `Finished (dev|release|test|bench) [...]  target(s) in <time>`.
Cargo test failure block: from `---- <module>::<name> stdout ----` through next `----` or `failures:`.
`cargo fmt`, `fix`, `publish` and unknown subcommands → `GenericHeuristic`.

#### `GitHeuristic`

| Invocation | Rule |
|---|---|
| `git log` large | first 10 commit lines + `[N more commits — use git log to see all]` |
| `git status` large | group by status type; emit counts + 3-file sample per group |
| `git diff` (full content) | **passthrough always** — content IS the signal |
| `git diff --stat` / `--name-only` | below LINE_CAP anyway (pre-rule handles) |
| anything else | `GenericHeuristic` |

`git diff` with content is always passthrough. Users running large diffs can use `git diff --stat` first to narrow scope (the agent already knows this).

#### `PytestHeuristic`

| Condition | Output |
|---|---|
| All pass | `[vajra: N lines folded…]\n✓ pytest — N passed in Xs` |
| Large fail (≥ 400 lines) | `[vajra: N lines folded…]\n<FAILED + tracebacks verbatim>` |

Pytest `PASSED` lines: `PASSED src/...::test_name`. Fold all. Keep `FAILED`, `ERROR`, summary line, and `=====` sections.

#### `NpmHeuristic`

| Invocation | Rule |
|---|---|
| `npm install` success | keep last 5 lines (added count + audit summary); fold download/extract progress |
| `npm test` / `npm run <script>` | cargo-style: pass → 1-liner; large fail → verbatim |
| Any `npm error` / `ERR!` lines | **always keep verbatim**, regardless of size |

#### `DockerHeuristic`

| Condition | Rule |
|---|---|
| `docker build` success | keep `Successfully built` / `Successfully tagged` final lines; fold layer download/cache lines |
| `docker run` success | `GenericHeuristic` |
| Failure | pre-rule handles (< 400 lines → passthrough) |

#### `GenericHeuristic`

```
[vajra: N lines folded — VAJRA_RAW=1 before `vajra claude` to see full output]
<first 10 lines of stdout>
<last 10 lines of stdout>
```

For large failure (≥ 400 lines + exit ≠ 0): first 5 + last 15 (bias toward tail — errors usually land at end).

If `lines_removed == 0` (output was exactly 20 lines after head+tail): return `Passthrough` instead of `Compressed` with an empty breadcrumb.

---

## 3. Rationale

1. **`spawn() + wait()` not `exec()`** — `exec()` replaces the process image; `Drop` never runs; tempfile leaks. `spawn() + wait()` keeps the Rust process alive for cleanup. Overhead is one extra process layer per `vajra claude` invocation, which happens once per session.
2. **Only `hooks` key in tempfile** — writing the full merged settings (model, permissions, env, etc.) requires reading and understanding every CC settings key, a maintenance burden. Writing only `hooks` is correct IF `--settings` is additive. The G9 conformance test validates the assumption.
3. **Dedup by `"vajractl"` substring** — exact string match (`"vajractl hook"`) fails for absolute path aliases. Substring on the binary name is correct and still specific enough to avoid false positives.
4. **Breadcrumb as header, not mid-separator** — the Red-Team correctly observed that mid-separator breadcrumbs look like truncation artifacts. A header line clearly signals intentional folding before the agent reads the content.
5. **`git diff` always passthrough** — the Practitioner identified that compressing diff content removes the information the agent is reviewing. The agent explicitly chose to run `git diff` to read the content. Folding it is precisely the "compressed away the thing I needed" failure mode from SPEC.md §3.
6. **LINE_CAP=30** — validated against the real fixture corpus: git log (21 lines) passthrough, ls -R (46 lines) compressed. 30 is the confirmed boundary.
7. **FAIL_PASSTHROUGH_CAP=400** — from SPEC.md §4 verbatim. Named constant rather than inline magic number.

---

## 4. What this costs — accepted trade-offs

- **`infer_success` may miss exotic success patterns** (tools that print non-standard completion messages). These fall to `is_success = false → Passthrough` when < 400 lines. Cost: missed compression opportunity, not incorrect compression. Accepted.
- **`docker build` compression is shallow** — Docker layer heuristics are not in the v1 fixture corpus. The `DockerHeuristic` is a best-effort implementation; we don't have a fixture to validate against. Accepted for v1; add to v2 fixture corpus.
- **`spawn() + wait()` adds one process layer** — process creation overhead is negligible (< 1 ms on modern hardware). Accepted.
- **Tempfile in `/tmp/`** — on OS crash or `SIGKILL`, tempfile leaks. OS cleans `/tmp/` on reboot. The tempfile contains only hook config, no secrets. Accepted.

---

## 5. Guardrails this ADR MANDATES (release-blocking for v1)

*(G1–G8 inherited and in force.)*

- **G9 — Settings schema validation before merge.** Before merging any settings file, validate that `hooks.PostToolUse` (if present) is a JSON array. On any other type (object, string, null) → warn one line to stderr, skip injection, run bare `claude`. The expected schema shape is pinned in `bench/fixtures/cc_settings_schema.json` and validated in CI.

---

## 6. Open implementation questions (resolve at code time)

- **Does `--settings` behave as an additive layer or a replacement?** Verify with a minimal test: `claude --settings '{"model":"foo"}' --version` — does CC error on unknown model (replacement, full validation) or ignore it (additive)? If replacement: extend the injector to read + merge ALL settings keys, not just hooks. Until verified, the tempfile-with-only-hooks approach is the v1 implementation.
- **Does CC support multiple hooks with the same matcher (`Bash`) in the `PostToolUse` array?** If not, G2 requires detecting a pre-existing Bash hook and refusing injection (with a warning). Verify against CC v2.1.177 with a two-entry test.
- **`exit_code` field in `tool_response`** — still unconfirmed. Pin in the G1 conformance fixture. The `infer_success` fallback covers the absence case.

---

## 7. Consequences (for the build)

DS3 completes the design of every v1 component except the meter/receipt (DS4). The build order from ADR-0002 §7 is now fully specified:

1. `engine/mod.rs` — trait + types (LINE_CAP + FAIL_PASSTHROUGH_CAP constants here)
2. `tests/shim_stub.rs` — G3 conformance (StubEngine)
3. `engine/heuristics/` — cargo, git, generic, pytest, npm, docker (in that order; each paired with its SPEC.md fixture test)
4. `engine/default.rs` — DefaultEngine with pre-rules + dispatch
5. `adapter/claude_code.rs` — HookAdapter wire types + pre-checks + run()
6. `cli/hook.rs` — entry point
7. `cli/launch.rs` — launcher + settings injector (TempSettings, merge, spawn+wait)
8. `bench/fixtures/cc_settings_schema.json` — G9 fixture
9. `meter/` — JSONL cost (Design Session 4)

---

## 8. Method note

Three lenses were unanimous on all major decisions in Round 1. Cross-examination refined three points: (1) dedup check changed to substring `"vajractl"` (PE finding); (2) `git diff` changed to always-passthrough (Practitioner finding, accepted without dissent); (3) breadcrumb position changed from mid-separator to header (Red-Team finding). Red-Team added G9 (settings schema validation) and mandated `spawn()+wait()` over `exec()`. No reversals.
