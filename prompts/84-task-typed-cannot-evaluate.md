# Session 84 — Typed `CannotEvaluate::{Timeout, SpawnFailure}` (CODE)

> **Status:** APPROVED (founder pick A at S83 close).
> **Type:** CODE — one new enum in `src/gate_run.rs` + a signature change propagated to its two
> call sites (`src/qa/mod.rs`, `src/demoer/mod.rs`). No new module, no new command, no new
> dependency, no new CONSTRAINTS.yaml key.
> **Scope note:** this is the other half of the S82 candidate B that S83 split — S83 shipped the
> read-only-headless UX warning; this session ships the typed-`CannotEvaluate` half, already
> scoped and design-noted since S73.

## Goal

`src/gate_run.rs`'s `run_streamed`/`run_captured` (S73) bound the QA and Demo-er gates' live
re-runs with a wall-clock timeout — a real, necessary safety net. But both functions collapse two
structurally different failure modes into the same `None`: **the script hung past its bound and
was killed** (a slow-truth problem — the timeout is generous on purpose) vs **the child process
never spawned at all** (an environment problem — bash missing, permission denied, a broken
`root`/`script` path). Every downstream BLOCK message — `QaState::LiveRed(None)` /
`DemoState::LiveRed(None)` — prints the same generic "could not be evaluated (no exit code)",
so an operator debugging a blocked close cannot tell which of two very different problems they're
looking at. This is the S73 fakest-green finding, disclosed at the time and carried forward
through S76/S77/S78/S81/S82/S83 as a known, un-fixed debt.

**Root cause:** `run_streamed`/`run_captured` return `Option<i32>` — `None` is used for both the
`.spawn()` `Err` branch and the `wait_or_timeout` `None` (killed) branch (`src/gate_run.rs:117-130`,
`146-176`). The type itself cannot distinguish them; only a stderr side-channel message
(`timeout_notice`, printed only on the timeout path) hints at which happened, and nothing in the
returned value lets a caller act on the distinction.

**Fix:** introduce `CannotEvaluate { Timeout, SpawnFailure }` and change `run_streamed`/
`run_captured` to return `Result<i32, CannotEvaluate>` (and `(Result<i32, CannotEvaluate>,
String)` respectively) instead of `Option<i32>`. Propagate the typed distinction through
`QaState`/`DemoState` so both gates' BLOCK messages name which failure mode occurred.

## Why this session

Named explicitly in S73's own closeout as a disclosed limitation, re-surfaced in every session's
STATE.md "What Is Broken" list since (S76 through S83 — 7 consecutive sessions), and split off
from S82's candidate B specifically so it would not get lost in the read-only-headless UX story
(S83). It is the last standing item from the S73 QA/Demo-er live-gate arc.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)

1. **WHEN** the gate's child process fails to spawn (e.g. the `bash` binary cannot be found/exec'd)
   **THEN** `run_streamed`/`run_captured` return `Err(CannotEvaluate::SpawnFailure)` (not
   `Timeout`), and the QA/Demo-er BLOCK message names it as a spawn failure, distinct from a
   timeout message.
2. **WHEN** the child runs past its recorded `timeout_secs` bound and is killed **THEN** both
   functions return `Err(CannotEvaluate::Timeout)`, and the BLOCK message names it as a timeout —
   same user-facing meaning as today's `timeout_notice`, now backed by a typed value instead of a
   bare `None`.
3. **WHEN** the script runs to completion with a real nonzero exit code **THEN** behavior is
   UNCHANGED: still blocks, still names the real code — this is NOT a `CannotEvaluate` case and
   must not become one.
4. **WHEN** the script exits 0 **THEN** behavior is unchanged (`LiveGreen`/no block), for both
   gates.
5. Both call sites carry the fix — `src/qa/mod.rs` (`QaState`/`qa_report`/`qa_gate_with`) AND
   `src/demoer/mod.rs` (`DemoState`/`demo_report`) — not just one gate typed and the other left on
   the old `Option<i32>` shape.
6. `cargo test --lib` stays green. Every existing `gate_run.rs`/`qa/mod.rs`/`demoer/mod.rs` test
   that asserted on the old `Option<i32>`/`None` shape is updated to the new type WITHOUT
   weakening what it proves (a timeout test must still prove a *timeout*, not merely "some
   Err"). At least one NEW test proves `SpawnFailure` and `Timeout` produce visibly DIFFERENT
   values (not two paths that both happen to stringify the same).

## Design (the Architect gate — recorded rationale)

- **design-significant: no** — one new enum + a return-type change at 2 existing call sites, same
  class of change as S81's execution-sha guard and S82's `BranchShip` match restructure. No new
  module, CLI command, dependency, or data store; no CONSTRAINTS.yaml key (this is error-signal
  precision, not a new governance rule).
- `CannotEvaluate` lives in `src/gate_run.rs` beside the functions it types — the same module that
  already owns `timeout_notice`/`kill_tree`/`wait_or_timeout`, so the two failure modes are named
  where they're actually distinguished (the `.spawn()` `Err` arm vs the `wait_or_timeout` `None`
  arm), not invented downstream from a guess.
- `QaState::LiveRed` and `DemoState::LiveRed` currently carry `Option<i32>` where `None` meant
  "unevaluable" and `Some(code)` meant "a real nonzero exit" — conflating "no code" with "code
  present" inside ONE variant is the same shape of bug one level up. Prefer splitting into a
  distinct `CannotEvaluate(CannotEvaluate)` variant (or equivalent) so `LiveRed` only ever carries
  a REAL exit code and can drop its own `Option` wrapper — decide the exact shape when touching
  the code, but do not leave a second `Option<i32>`-shaped ambiguity in the new design.
- **Test-injection seam (existing, keep it):** `qa_report`/`demo_report` already take `run: impl
  FnOnce(&str) -> Option<i32>` (soon `Result<i32, CannotEvaluate>`) precisely so gate-message
  classification is testable without spawning a process — keep using that seam for `QaState`/
  `DemoState` tests. For `gate_run.rs`'s OWN tests (proving `run_streamed`/`run_captured` return
  `SpawnFailure` for a genuine spawn failure), do **not** mutate the process-global `PATH` env var
  to force a missing-binary condition — `cargo test --lib` runs this suite's tests in parallel
  threads in one process, and other tests elsewhere in the suite spawn real subprocesses
  (`keychain_has_credentials`, the launch tests); a global env mutation is a flakiness landmine.
  Instead, make the spawned program name injectable at the point `bash()` builds its `Command` (a
  `#[cfg(test)]`-only seam is fine — e.g. an internal helper that takes the program name, with
  `bash()` calling it with `"bash"` and a test calling it with an absolute, guaranteed-nonexistent
  path), so a spawn failure is deterministic and thread-safe without touching global state.

## Plan (ordered steps — cite the acceptance criteria each step covers)

1. Add `CannotEvaluate { Timeout, SpawnFailure }` to `src/gate_run.rs` (derive at least `Debug,
   Clone, Copy, PartialEq, Eq`). Change `run_streamed` to return `Result<i32, CannotEvaluate>` —
   the `.spawn()` `Err` arm returns `Err(SpawnFailure)`, the `wait_or_timeout` `None` arm (after
   `kill_tree` + `timeout_notice`) returns `Err(Timeout)`, the `Some(status)` arm returns
   `Ok(status.code().unwrap_or(...))` (decide the still-open "process killed by signal, no exit
   code" edge the same conservative way the current code does). Change `run_captured` to return
   `(Result<i32, CannotEvaluate>, String)` with the same two `Err` arms. `covers: 1, 2`

2. Update `src/qa/mod.rs`: `qa_report`'s injected closure type becomes `impl FnOnce(&str) ->
   Result<i32, CannotEvaluate>`; `QaState` gains a way to carry the typed reason for an
   unevaluable run (new variant or reshaped `LiveRed`) instead of `LiveRed(None)`; `qa_gate_with`'s
   BLOCK message for the unevaluable case names Timeout vs SpawnFailure distinctly; the real-code
   nonzero case keeps its existing message wording. Update `run_verify_script`/`qa_gate`'s call
   into `gate_run::run_streamed` for the new return type. `covers: 3, 4, 5`

3. Update `src/demoer/mod.rs` the same way — `demo_report`, `DemoState`, `run_demo_script`/
   `demo_gate`'s call into `gate_run::run_captured`, same typed BLOCK-message split. `covers: 5`

4. Update every existing test in `gate_run.rs`/`qa/mod.rs`/`demoer/mod.rs` that referenced the old
   `Option<i32>`/`None` shape to the new types, preserving exactly what each proved (a timeout
   test still proves a timeout, a red-exit test still proves the real code, a hang-is-killed test
   still proves the kill). Add the injectable-program-name seam (or equivalent) and a new test
   proving a genuine spawn failure yields `Err(CannotEvaluate::SpawnFailure)`, visibly distinct
   from `Err(CannotEvaluate::Timeout)`. `covers: 1, 2, 6`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>

## Delta (the Analyst gate — what this session ADDS to the governed pipeline)

- `+` `CannotEvaluate::{Timeout, SpawnFailure}` — the QA and Demo-er gates' live-rerun BLOCK
  messages now name which of two structurally different failure modes occurred, closing the S73
  fakest-green finding carried across 7 sessions (S76-S83)
- `+` `run_streamed`/`run_captured` return a typed `Result` instead of an ambiguity-hiding
  `Option<i32>`
- `+` new spawn-failure test coverage in `gate_run.rs`, deterministic and thread-safe (no global
  env mutation)

## Guardrails

- **One story:** the typed `CannotEvaluate` distinction only, in `gate_run.rs` + its two call
  sites (`qa/mod.rs`, `demoer/mod.rs`). Do NOT touch `src/cli/launch.rs` (S83's story, already
  shipped) or the S76 sha placeholders or the attestation substring-check (the other two S83+
  candidates, not picked this session).
- **No new dependency, no new command, no new CONSTRAINTS.yaml key:** this is error-signal
  precision inside existing gates, not a new governance rule or a new surface.
- **No global env mutation in tests:** see the Design section's flakiness note — use an
  injectable program-name seam or equivalent, not `std::env::set_var("PATH", ...)`.
- **S85 = the next mandatory NO-CODE ground truth** (`85 % 5 == 0`) regardless of this session's
  outcome — do not schedule additional CODE work past S84 in this same chat.
