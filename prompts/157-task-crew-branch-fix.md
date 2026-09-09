# Session 157 — Crew gate: fix tech-lead provenance false-negative

> **Status:** APPROVED — S156 A/B/C pick A (2026-09-09)

## Type
- **CODE** (~1h cap)

## Goal

Fix the `required-crew` gate false-negative: when the tech-lead is dispatched before the session branch is checked out (still on `main`), its subagent transcript records `gitBranch: "main"` instead of `session-{N}-*`. The `cross_check` in `src/dispatch/mod.rs` rejects this as "belongs to a different session" — blocking a valid dispatch.

The fix: add one new match arm to `cross_check` that accepts any dispatch whose `gitBranch` is not a `session-*` branch at all (e.g. `main`, `develop`). Such a dispatch happened before the session branch was created — not a replay from a different session. The tool-use ID cross-check already binds identity; the branch check's only job is preventing replay from another session's `session-*` branch.

## File to change

`src/dispatch/mod.rs` — the `cross_check` function, lines ~132-142.

### Exact change (insert one arm before the catch-all `Err`)

```rust
// existing: exact session-branch match passes
Some(b) if b.starts_with(&expected_prefix) => Ok(()),

// NEW arm: non-session branch (e.g. "main") — dispatched before branching, accept
Some(b) if !b.starts_with("session-") => Ok(()),

// existing: a session-* branch for a DIFFERENT session, reject
Some(b) => Err(format!(
    "subagent transcript recorded gitBranch {b:?}, not a {expected_prefix}* branch — \
     this dispatch belongs to a different session"
)),
// existing: no branch recorded
None => Err(
    "subagent transcript records no gitBranch — cannot bind it to this session".to_string(),
),
```

## Acceptance criteria

| AC | Criterion |
|----|-----------|
| AC1 | `cargo test` passes (all existing tests green; no regressions). |
| AC2 | New test `cross_check_accepts_dispatch_from_non_session_branch` passes — confirms `gitBranch: "main"` is accepted for a valid dispatch. |
| AC3 | Existing test `cross_check_fails_when_git_branch_is_a_different_session` still passes — `gitBranch: "session-93-*"` for session 157 is still rejected. |
| AC4 | `cargo build --release` succeeds. |
| AC5 | `verify-closeout.sh` exits 0 (N=157). |

## New test to add (in `src/dispatch/mod.rs` tests block)

```rust
#[test]
fn cross_check_accepts_dispatch_from_non_session_branch() {
    // Tech-lead dispatched from main before the session branch was created.
    let calls = [call("t1", "tech-lead")];
    let metas = [meta("t1", "tech-lead", Some("main"))];
    assert_eq!(cross_check("tech-lead", 157, "t1", &calls, &metas), Ok(()));
    // Other non-session branches are also accepted.
    let metas2 = [meta("t1", "tech-lead", Some("develop"))];
    assert_eq!(cross_check("tech-lead", 157, "t1", &calls, &metas2), Ok(()));
}
```

## Guardrails

- Edit only `src/dispatch/mod.rs` (the fix is one new match arm + one new test).
- Do not weaken the existing `session-*` replay check — only non-session branches get the new pass.
- Do not change `cross_check`'s signature or return type.

## Plan

1. Add the new match arm to `cross_check` in `src/dispatch/mod.rs`. covers: 2,3
2. Add `cross_check_accepts_dispatch_from_non_session_branch` test in the same file. covers: 2
3. Run `cargo test` — confirm all tests pass. covers: 1,2,3
4. Run `cargo build --release`. covers: 4

## Design

design-significant: no
design-advisor: skipped — one new match arm in an existing match block; no architectural surface, no new data structure, no ADR impact. Tech-lead explicitly marked design-advisor as deferred-budget for this reason.

## Delta

S155 GT flagged the tech-lead provenance false-negative as systemic: if tech-lead is dispatched before the session branch is created, the gate rejects a valid handoff. S156 used `VAJRA_CLOSEOUT_WAIVER=156` as a workaround. This session closes the root cause so future sessions don't need the waiver.

## Advice

obeyed: 78eed2e — tech-lead rec 1: new arm inserted strictly between starts_with arm and catch-all; no None arm added before it.
obeyed: 78eed2e — tech-lead rec 2: cargo test run before cargo build --release; both green.
obeyed: 78eed2e — tech-lead rec 3: ## Execution filled with step SHAs as work lands.

obeyed: 78eed2e — impl-advisor rec 1: single new match arm inserted at correct position; no other function code changed.
obeyed: 78eed2e — impl-advisor rec 2: new test covers both "main" and "develop"; single file change.
obeyed: 78eed2e — impl-advisor rec 3: cross_check_fails_when_git_branch_is_a_different_session confirmed green before recording SHA.

## Execution

step 1 — done: 78eed2e
step 2 — done: 78eed2e
