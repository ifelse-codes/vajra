# Session 84 — Cold Fidelity Review

**Session:** 84 — typed `CannotEvaluate::{Timeout, SpawnFailure}` for the QA/Demo-er live-rerun gates (CODE)
**Reviewer:** independent cold pass (subagent, fed only the prompt + diff, no builder narrative)
**Date:** 2026-07-20

---

## Per-criterion verdict table

| # | Acceptance criterion | Verdict | Evidence |
|---|-----------------------|---------|----------|
| 1 | Spawn failure → `Err(CannotEvaluate::SpawnFailure)` (not `Timeout`), BLOCK message names it distinctly | **SHIPPED** | Read `src/gate_run.rs:174-176` (`run_streamed_inner`) and `:227-229` (`run_captured_inner`): the `.spawn()` `Err` arm returns `Err(SpawnFailure)` in both. Ran the unit tests directly: `gate_run::tests::run_streamed_spawn_failure_is_distinct_from_timeout` and `run_captured_spawn_failure_is_distinct_from_timeout`, both green, both assert `assert_ne!` against `Timeout`. Live E2E: built the binary, pointed `PATH` at a nonexistent directory, ran `vajra next --check-qa 99` / `--check-demo 99` against a synthetic temp repo — both printed `SPAWN FAILURE` distinctly and exited 1. |
| 2 | Timeout → both functions return `Err(CannotEvaluate::Timeout)`, BLOCK message names it as a timeout | **SHIPPED** | `wait_or_timeout`'s `None` arm (`gate_run.rs:180-184`, `:235-238`) kills the tree, prints `timeout_notice`, returns `Err(Timeout)`. Unit tests `run_streamed_hang_is_killed_and_blocks` / `run_captured_hang_is_killed_and_names_the_timeout` green. Live E2E: a `sleep 5` script against a 1s `timeout_secs` bound produced `TIMEOUT` in both gates' output, distinct from the SPAWN FAILURE wording above. |
| 3 | Real nonzero exit code → UNCHANGED, not reclassified as `CannotEvaluate` | **SHIPPED** | `Ok(c) => QaState::LiveRed(c)` / `DemoState::LiveRed(c)` (unchanged shape, just un-`Option`-wrapped). Unit test `run_streamed_red_returns_nonzero_code` (`exit 3` → `Ok(3)`) green. Live E2E: `exit 7` script → both gates print `exited 7`, and I confirmed neither `TIMEOUT` nor `SPAWN FAILURE` appears in that output. Additionally verified the previously-open "killed by signal, no exit code" edge myself, live (not in the diff's test suite — see Disclosed Findings #1): a script that self-`kill -9`s produces `LiveRed(1)` — `code_or_conservative` (`gate_run.rs:109-111`, `status.code().unwrap_or(1)`) falls back to a real, still-blocking code rather than a second ambiguous `None`. Confirmed by running it: `verdict: NOT READY … re-ran LIVE and exited 1`. |
| 4 | Exit 0 → unchanged (`LiveGreen`/no block), both gates | **SHIPPED** | `Ok(0)` arms unchanged in both `qa_report`/`demo_report`. Live E2E: a green verify + a demo script emitting all four `demo:<element>` markers passed clean (`--check-qa 99` and `--check-demo 99` both exit 0). |
| 5 | Both call sites (`qa/mod.rs` AND `demoer/mod.rs`) carry the fix | **SHIPPED** | Read both files end-to-end. `QaState`/`DemoState` both dropped the old `LiveRed(Option<i32>)` in favor of a `CannotEvaluate(CannotEvaluate)` variant + a bare `LiveRed(i32)` — structurally identical treatment, same BLOCK-message wording template, same `blocks()` inclusion. Neither file was left on the old `Option<i32>` shape; grepped for `Option<i32>` / `(None,` / `, None)` across all three touched files — zero hits outside one doc comment referencing the *old* shape by name. |
| 6 | `cargo test --lib` green; every old-shape test updated without weakening; new test proves `SpawnFailure`/`Timeout` are visibly different values | **SHIPPED** | Ran `cargo test --lib` myself twice (plain, and with `--test-threads=8`): **267 passed, 0 failed** both times. Cross-checked against S83's baseline of 263 — diffed `#[test]` counts per touched file between `main` and this branch: `gate_run.rs` 9→11, `qa/mod.rs` 9→10, `demoer/mod.rs` 11→12, net +4, exactly matching 263→267. Read every changed assertion in the diff: `Some(0)`→`Ok(0)`, `Some(3)`→`Ok(3)`, the old bare `None`-proves-a-kill test now asserts `Err(CannotEvaluate::Timeout)` by name (not "some Err") — no assertion was loosened. New tests (`*_spawn_failure_is_distinct_from_timeout` in `gate_run.rs`, `gate_block_message_names_timeout_distinctly_from_spawn_failure` in both `qa/mod.rs` and `demoer/mod.rs`) all use `assert_ne!`/distinct-substring checks to prove the two reasons are genuinely different values, not just two paths that stringify the same. The spawn-failure test seam (`command_for`/`run_streamed_with_program`/`run_captured_with_program`, `#[cfg(test)]`-gated) uses an absolute nonexistent path, not `std::env::set_var("PATH", …)` — confirmed no global env mutation anywhere in the diff (`grep -n "set_var"` empty). Ran the full suite twice to check for parallelism flakiness: identical pass count both times. |

---

## `cargo clippy` / `cargo fmt` / verify script

- `cargo clippy --all-targets --all-features -- -D warnings` — clean, no warnings, run independently on this branch.
- `cargo fmt --check` — clean.
- `scripts/verify-session-84.sh` — ran it fresh myself (not the builder's log): **16/16 PASS**, exits 0. It builds its own temp repo, needs no credentials, costs $0. Confirmed it also reruns the full lib suite, clippy, fmt, and a `scope-3-files-only` check (`git diff --name-only main -- src/` == exactly the 3 named files) as part of its own gate.
- `scripts/demo-session-84.sh` — ran it fresh: all four `demo:<element>` markers present, all 5 cases (`before_after`, timeout, spawn-failure, real-red-unchanged, exit-0-unchanged, regression suite) show green, exits 0.

---

## Scope / guardrails check

`git diff main...session-84-typed-cannot-evaluate --name-only`:
```
prompts/84-task-typed-cannot-evaluate.md
scripts/demo-session-84.sh
scripts/verify-session-84.sh
src/demoer/mod.rs
src/gate_run.rs
src/qa/mod.rs
```
No `src/cli/launch.rs`, no `Cargo.toml`/`Cargo.lock` (confirmed empty diff on those paths directly), no `.ai/CONSTRAINTS.yaml` key added, no new command. Matches the prompt's "one new enum + a signature change at 2 call sites, no new module/command/dependency/CONSTRAINTS key" claim exactly.

**Execution shas:** all 4 plan steps are recorded against `d0cf43f`, `b01c34e`, and `fc16aba` respectively (not `<sha>` placeholders). Confirmed all three exist in this repo's history via `git cat-file -e <sha>^{commit}`. `d0cf43f`'s own diff stat: exactly the 3 named source files, 339 lines — the actual code change, complying with the "3 files per commit" cap. All 4 plan steps ("add the enum + retype the runners", "update qa/mod.rs", "update demoer/mod.rs", "update every test + add spawn-failure coverage") landed together in this one commit rather than 4 separate ones; the commit message discloses this plainly ("one class of change across 3 tightly-coupled files") rather than hiding it. Given the change is a single coherent type-threading edit, I don't consider this a fidelity problem — the Plan's `covers:` tags map cleanly onto the diff regardless of commit granularity.

---

## Disclosed findings

1. **The signal-death edge case has no dedicated automated test — I verified it live myself, not the suite.** The prompt's Plan step 1 explicitly flags "the still-open 'process killed by signal, no exit code' edge" and asks it be resolved "the same conservative way the current code does." The shipped resolution (`code_or_conservative`, `gate_run.rs:103-111`) is a real behavior *change* from pre-S84: previously a signal-killed process (`status.code() == None`, but the process DID complete — this is not the timeout-kill path) fell into `LiveRed(None)`; now it falls into `LiveRed(1)`, a real (still-blocking) code. This is a defensible choice — it avoids reintroducing a second `Option`-shaped ambiguity, which the Design section explicitly forbade — and I confirmed it live (a `kill -9 $$` verify script produces `verdict: NOT READY … re-ran LIVE and exited 1`, correctly still blocking). But no `#[test]` in the diff exercises this path; it's only reachable by manual/live verification (mine). The BLOCK message text this produces — `"… re-ran LIVE and exited 1 …"` — also reads to an operator as if the script explicitly called `exit 1`, when it was actually killed by an external signal with a synthesized placeholder code. Low severity: the AC does not require a third named reason for this case, and the current behavior is safe (fails closed, never passes), but it is a small honesty gap worth naming — a future session could split this into its own `CannotEvaluate` variant or at least qualify the message ("no real exit code — signal death") if this edge ever becomes operationally relevant.

2. **A pre-existing (not S84-introduced) third collapse remains in `wait_or_timeout`.** `wait_or_timeout`'s `Err(_) => return None` arm (a `try_wait()` OS-level error — distinct from both a genuine timeout and a spawn failure) is indistinguishable from a real timeout by the caller, and gets classified `Err(CannotEvaluate::Timeout)`. This predates S84 (introduced at S73) and is not one of the two failure modes this session's ACs target, so it is out of scope here — noted only so it doesn't get mistaken for something this diff introduced or missed.

Neither finding blocks acceptance; both are the class of thing the prompt itself asks reviewers to watch for ("disclosed, not hidden"), and both are strictly narrower/lower-severity than what the six numbered ACs actually require.

---

## What was NOT built

Nothing from the prompt was skipped. All 6 acceptance criteria are shipped; the two disclosed findings above are pre-existing or genuinely out-of-scope edge-case refinements, not missing deliverables.

---

**Verdict:** ACCEPT

All six acceptance criteria are shipped and independently verified by running the real code — not trusting the diff, the commit messages, or any builder self-report: `cargo test --lib` (267, +4, confirmed no hidden test deletions via per-file test-count diffing against `main`), `cargo clippy -D warnings`, `cargo fmt --check`, a fresh run of `scripts/verify-session-84.sh` (16/16), a fresh run of `scripts/demo-session-84.sh`, and manual live E2E runs of `vajra next --check-qa/--check-demo` against a synthetic temp repo covering all 4 matrix cases plus the signal-death edge case the prompt flagged as still-open. No scope creep (diff touches exactly the 3 named files plus the prompt/scripts), no new dependency/command/CONSTRAINTS key, no weakened test, and the new SpawnFailure test is deterministic and thread-safe (no global `PATH` mutation — confirmed by grep and by re-running the full suite twice with no flakiness).

**Review-Inputs-SHA:** 0e172ca700ac46b0c8720cee11364c883da4ade0ef1ddb55349324ba761e5b9f
