# Session 12 Summary — E2E `vajra next` Proof

## Goal
Prove `vajra next` drives a real multi-step project loop start to finish.

## Goal Achieved?
Yes. Walked a 3-session loop (init → next → work → advance → repeat) with automatic prompt pointer updates at each transition.

## Evidence
- `scripts/verify-session-12.sh` — automated e2e loop proof (5/5 PASS)
- `scripts/demo-session-12.sh` — cumulative demo showing all prior + new capabilities
- Manual walkthrough captured in conversation: S01 → S02 → S03 → S04 (no-prompt warning)

## Bugs Found and Fixed

| Bug | Impact | Fix |
|---|---|---|
| `--advance` didn't update `Read prompt:` pointer | Agent couldn't find next session's prompt after advance | Scan `prompts/` for `{NN}-task-*.md`, update TASK.md + SESSION-BOOT.md |
| SIGPIPE panic when piping `vajra next` through `head`/`grep` | Exit code 101 instead of graceful truncation | Reset SIGPIPE to SIG_DFL via libc at startup |

## Changes
- `src/cli/next.rs` — `find_next_prompt()` + `update_prompt_pointer()` + 3 new tests (total 7)
- `src/main.rs` — `reset_sigpipe()` at startup
- `Cargo.toml` — added `libc` (unix-only)
- `src/budget/mod.rs` — cargo fmt only

## What's Next — 3 Options

### A: Add second agent (Codex or Cursor)
- **Goal:** Prove `vajra <agent>` works with something other than Claude Code
- **Why:** Phase 2 starts here — vendor-neutral is Vajra's wedge
- **Risk:** Codex/Cursor hook APIs may differ significantly from Claude Code

### B: Installer / release path
- **Goal:** `cargo install vajractl` + Homebrew + one-liner in README
- **Why:** Can't get users without a frictionless install
- **Risk:** Signing, CI pipeline, cross-platform builds are new territory

### C: Clean legacy `vajra launch` references
- **Goal:** Remove the `launch` alias and all references from code/docs
- **Why:** Low-risk cleanup before shipping; reduces confusion
- **Risk:** Minimal — but low impact too
