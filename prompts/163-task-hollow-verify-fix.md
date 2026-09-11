# Session 163 — Fix hollow verify checks (F09 + F08)

> **Status:** APPROVED — founder pick (2026-09-11, post S162 closeout)

## Type
- **CODE** (~2h cap)

## Goal

Two open audit findings that are naturally paired:

**Finding 09 — Hollow verify checks:** Several recent `verify-session-N.sh` scripts prove AC delivery by grepping source files for function names or string patterns rather than running the feature. A grep that finds `"is_code_session"` in `verify-closeout.sh` proves the name is there — not that the gate actually fires. S162 established the correct pattern (subprocess invocation against a synthetic fixture). S163 applies it to the most hollow recent sessions.

**Finding 08 — Tightening-delta not falsified:** When a gate is tightened, there is no proof that the NEW check catches what the OLD one missed. F08 is addressed at zero extra cost during F09 fixes: for each hollow grep converted, a falsifiability comment or test must show what the old grep would have accepted that the new behavioral test rejects.

## Target scripts

These are the sessions with hollow source-proximity greps in their verify scripts — in priority order:

| Script | Hollow checks | Why hollow |
|--------|--------------|------------|
| `verify-session-158.sh` | `grep -q "is_code_session" scripts/verify-closeout.sh`; `grep -q "check_demo_markers" scripts/verify-closeout.sh` | Proves the string exists in source, not that the gate fires on a code session |
| `verify-session-157.sh` | `grep -q "cross_check_accepts_dispatch_from_non_session_branch" src/dispatch/mod.rs`; `grep -q '!b.starts_with("session-")' src/dispatch/mod.rs` | Proves the test name and code pattern are in source, not that the fix is correct |
| `verify-session-154.sh` | `grep -q 'has_plan_steps' scripts/verify-closeout.sh`; `grep -q 'S154' scripts/verify-closeout.sh` | Proves string presence in source file |

Do NOT touch `verify-session-159.sh` (DOCUMENT session — content greps are appropriate for doc delivery) or `verify-session-156.sh` (same). Leave all passing checks unchanged; only convert the hollow greps.

## Acceptance criteria

| AC | Criterion |
|----|-----------|
| AC1 | `verify-session-158.sh` — the two source-grep checks replaced with behavioral tests: run `verify-closeout.sh` against a fixture with and without `is_code_session`/demo-marker behavior, check exit codes |
| AC2 | `verify-session-157.sh` — the two source-grep checks replaced with `cargo test` invocations that run the named tests and confirm they pass |
| AC3 | `verify-session-154.sh` — hollow source greps replaced with behavioral equivalents (run the binary or the gate, check output) |
| AC4 | For each converted check: a `# FALSIFIABILITY` comment (or a negative fixture test) shows concretely what the old grep would have accepted that the new test rejects — this closes F08 for these checks |
| AC5 | All three patched scripts still exit 0 on the current codebase |
| AC6 | `scripts/verify-session-163.sh` exits 0; it must contain zero source-proximity greps (every check must invoke a binary, run a test suite, or exercise a subprocess) |

## Guardrails

- **Do not expand scope.** Fix only the listed hollow checks in the three named scripts. Do not refactor passing checks, rename variables, or add new checks beyond what the ACs require.
- **AC4 is mandatory, not optional.** A converted check without a falsifiability proof does not satisfy F08. The proof can be a comment, a negative fixture, or a note in the script — but it must name a concrete input that the old grep would have passed and the new test rejects.
- **AC5 is a non-regression gate.** Run each patched script in full; all previously-passing checks must still pass.
- **verify-session-163.sh must be 100% behavioral.** No `grep -q "string" src/file.rs` patterns. Every AC check must invoke a real executable or exercise the actual code path.
- Max 3 files per atomic commit.

## Plan

1. Fix `verify-session-158.sh` — convert 2 hollow greps to behavioral fixture tests. covers: 1, 4
2. Fix `verify-session-157.sh` — convert 2 hollow greps to `cargo test` invocations. covers: 2, 4
3. Fix `verify-session-154.sh` — convert hollow source greps to binary/gate invocations. covers: 3, 4
4. Confirm AC5: run all three patched scripts, capture output, confirm exit 0. covers: 5
5. Write `scripts/verify-session-163.sh` — 100% behavioral, exits 0. covers: 6

## Execution

- step 1 — done: 63a929e
- step 2 — done: 63a929e
- step 3 — done: 63a929e
- step 4 — done: 63a929e
- step 5 — done: 65ba748

## Design

design-significant: no — no new interface contract or ADR. This session changes verify script methodology, not the gates themselves.
design-advisor: skipped — design-significant: no; methodology change only, no architecture decision.

## Crew

tech-lead to dispatch first (mandatory). fidelity-reviewer required (DECISION-002; no self-cert). qa-specialist required — must confirm converted checks are genuinely behavioral (not just renamed greps) and that falsifiability proofs are concrete. design-advisor: skipped — design-significant: no.

## Delta

S162 proved the behavioral-test pattern works end-to-end. S163 applies it retroactively to the sessions most at risk: if `verify-closeout.sh` is ever refactored and `is_code_session` is renamed, `verify-session-158.sh` silently turns hollow-green — a category of silent failure the S162 pattern eliminates. F08 gets its falsifiability proofs as a byproduct of doing F09 properly.
