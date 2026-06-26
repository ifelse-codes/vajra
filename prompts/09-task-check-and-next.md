# Session 09 — Build `vajra check` + Make `vajra next` Advance

> **Constraint override:** 2 stories in one session (user-approved).

## Trigger
User picked Options A+B from `sessions/session-08-summary.md`.

## Goal
Build two commands that complete the core workflow loop:
1. `vajra check` — drift detection + readiness scoring (read-only)
2. `vajra next` advance — bump SESSION, update pointers, print next context (write)

## Story A: `vajra check`

### Deliverables
- `vajra check` CLI command (new `src/cli/check.rs`)
- Reads `.ai/` state and compares claims against actual repo state
- Checks: SESSION file valid, required files exist, branch matches, session-boot current
- Runs `scripts/verify-session-{NN}.sh` if it exists
- Prints pass/fail checklist with readiness score
- No side effects — purely diagnostic

### Design Rules
- Output format: checklist with PASS/FAIL per check, score at end
- Exit 0 if all pass, exit 1 if any fail
- Should work in any Vajra-initialized repo (including ones created by `vajra init`)

## Story B: `vajra next` Advance

### Deliverables
- Extend existing `vajra next` from read-only dump to write mode
- Default behavior (no flag): current read-only dump (backwards compatible)
- `vajra next --advance`: bump `.ai/SESSION`, update SESSION-BOOT.md, print next context
- Guard: refuse to advance if on `main` or if verify script fails
- Interactive: confirm before writing

### Design Rules
- Must be safe — refuse if state is inconsistent (run check logic internally)
- Backwards compatible — bare `vajra next` still dumps the packet
- `--advance` is the gate for write operations

## Constraints Operative
- Max 2 assumptions. Max 2 retries.
- Max 3 files per atomic commit.
- No installer / release path work.

## Exit Criteria
- `vajra check` works in the Vajra repo itself
- `vajra next --advance` bumps SESSION in a test directory
- `vajra next` (no flag) still works as before
- `cargo test`, `cargo clippy` pass
- `scripts/demo-session-09.sh` runs (cumulative — includes init + check + next + prior)
- Session verify script passes
- Exactly 3 Session 10 options presented (Session 10 is NO-CODE ground truth)

## Explicit Non-Goals
- Budget guard
- Multi-agent launcher work
- Installer / release path
