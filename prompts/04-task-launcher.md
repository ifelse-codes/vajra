# Session 04 — CLI Launcher + `--settings` Injector

## Trigger
User picked Option A from session 03 closeout.

## Goal
Implement `vajra launch` — spawn `claude` with a temp `--settings` file that injects
`vajra hook` as the PostToolUse hook, making Vajra transparent to the user.
After this session, `vajra launch <args>` is a drop-in replacement for `claude <args>`.

## Source of Truth
ADR-0003 §2.1 (injector design) governs all decisions here. Read it before coding.

## Deliverables

### 1. `src/launcher/mod.rs` (new module)

#### `TempSettings` struct with `Drop`-based cleanup
```rust
struct TempSettings { path: PathBuf }

impl TempSettings {
    fn write(hooks: serde_json::Value) -> anyhow::Result<Self>;
    fn path(&self) -> &Path;
}

impl Drop for TempSettings {
    fn drop(&mut self) { let _ = std::fs::remove_file(&self.path); }
}
```
- Tempfile in `std::env::temp_dir()` named `vajra-<random>.json`
- Content: `{ "hooks": { "PostToolUse": [...merged_entries...] } }`
- Use `rand` or time-based suffix for uniqueness (no new dep preferred — use
  `std::time::SystemTime` nanos as hex string)

#### Settings merge function
```
fn merge_hook_settings() -> anyhow::Result<serde_json::Value>
```
Read order (soft-fail on absent/malformed, warn to stderr):
1. `~/.claude/settings.json` (global)
2. `.claude/settings.json` (project root — walk up to git root)
3. `.claude/settings.local.json` (project root)

Concat all `hooks.PostToolUse` arrays found.

**G9 validation:** before using any file's `PostToolUse`, check it is a JSON array.
On type mismatch → `eprintln!("[vajra] warning: ...")` + skip that file's hooks.

**Dedup check:** if any existing hook entry's `command` field contains `"vajractl"`,
skip injecting the Vajra entry (already present).

**Vajra hook entry to inject:**
```json
{ "matcher": "Bash", "hooks": [{ "type": "command", "command": "vajractl hook" }] }
```

#### Error handling ladder (ADR-0003 §2.1.5)
| Condition | Action |
|---|---|
| `vajractl` not in PATH | Fatal: print message, exit 1 |
| `claude` not in PATH | Fatal: print message, exit 1 |
| Settings file malformed JSON | Warn to stderr, skip that file |
| G9 schema mismatch | Warn to stderr, skip injection, run bare `claude` |
| Tempfile write fails | Warn to stderr, run bare `claude` |

`VAJRA_DEBUG=1` → print tempfile path + content to stderr before spawn.

### 2. `src/cli/launch.rs` (replace stub)
```rust
pub fn run(args: &[String]) -> Result<()>
```
- Call `merge_hook_settings()`
- Write `TempSettings`
- Spawn `claude --settings <tempfile_path> <args...>` with inherited stdio
- `wait()` — **not `exec()`** (Drop must run for tempfile cleanup)
- Exit with child's exit code (propagate non-zero)

`src/cli/mod.rs` currently passes no args to `launch::run()` — update the call site
to forward `std::env::args().skip(2).collect()` (skip `vajra launch`).

### 3. `src/lib.rs`
Add `pub mod launcher`.

### 4. `tests/launcher.rs` (new integration test file)
- `merge_skips_injection_if_vajractl_present` — settings JSON already has `"vajractl"` → no second entry
- `merge_injects_entry_when_absent` — clean settings → vajra hook entry added
- `merge_warns_and_skips_malformed_post_tool_use` — `PostToolUse` is `{}` not array → skip (G9)
- `temp_settings_drop_removes_file` — `TempSettings` written, then dropped → file gone
- `merge_reads_global_and_project` — two files merged correctly

Note: do NOT spawn `claude` in tests — it may not be installed in CI. Test the
`merge_hook_settings()` function directly with fixture JSON files under `tests/fixtures/`.

### 5. `tests/fixtures/` (new directory)
- `settings_clean.json` — `{}` (no hooks)
- `settings_with_bash_hook.json` — existing PostToolUse Bash hook, no vajractl
- `settings_with_vajractl.json` — PostToolUse already has vajractl hook
- `settings_bad_post_tool_use.json` — PostToolUse is `{}` (G9 violation)

### 6. Fix `LINE_CAP` discrepancy
ADR-0003 §2.2 specifies `LINE_CAP = 30`, but `src/engine/mod.rs` currently has
`LINE_CAP = 200`. The two constants have different semantics — resolve this before S04
ships. Either update the constant to 30 (and update all tests that rely on 200) or
document why 200 is the correct value and amend the ADR note in KNOWLEDGE.md.

### 7. `scripts/verify-session-04.sh`
Copy from template, uncomment the four cargo checks.

## Constraints Operative
- `spawn() + wait()` — NOT `exec()` (Drop must run; ADR-0003 §3.1)
- Max 3 files per atomic commit
- No async
- Fail-open ladder: any injector failure → run bare `claude` (never block the user)
- Do NOT spawn `claude` in tests

## Decisions Already Made (ADR-0003)
- Tempfile approach (not `--settings` JSON string) — shell escaping hazard
- Dedup by `"vajractl"` substring (not exact match)
- `spawn()+wait()` over `exec()` for Drop cleanup
- Tempfile contains only `{ "hooks": ... }` key
- `git diff` always passthrough

## Open Questions to Resolve at Code Time (ADR-0003 §6)
- Does `--settings` behave as additive or full replacement? → Verify with a live CC
  invocation. If replacement: extend tempfile to merge ALL settings keys.
- Does CC support multiple hooks with same `matcher: "Bash"`? → Check CC docs or
  test with CC v2.1.177. If not: detect pre-existing Bash hook and warn + skip.

## Exit Criteria
- `cargo check --all-targets` exits 0
- `cargo test --all-targets` exits 0
- `cargo fmt -- --check` exits 0
- `cargo clippy --all-targets -- -D warnings` exits 0
- Launcher unit tests cover: inject, skip-dedup, G9 validation, Drop cleanup

## Explicit Non-Goals
- Spawning `claude` in tests (may not be installed)
- Meter / receipt (Session 04–05)
- Bench fixtures / tripwire (Session 05)
- Docker heuristic (backlog)
