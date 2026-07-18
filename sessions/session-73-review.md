# Session 73 — Independent Cold Fidelity Review

> **DECISION-002 gate.** Run in a fresh subagent with NO repo context. Cold inputs only: the
> contract (`prompts/73-task-close-path-reliability.md`) + the delivery diff (`git diff main HEAD`
> excluding sessions/·prompts/·.ai state). Adversarial framing; expected score withheld. The
> builder never grades itself.

## Method controls
- Fresh subagent, own context; fed only the contract + the delivery diff.
- Self-narrative excluded (no summary / STATE / SESSION-BOOT / memory in the inputs).
- Adversarial framing: *assume the builder silently re-scoped to whatever yields a green
  checkmark; find the fakest checkmark.* No expected verdict supplied.
- Requirement extraction spanned ALL requirement-bearing sections (Acceptance · Plan · Guardrails
  · Deliverable), not just "Deliverable".

## Process note (surfaced BY the reviewer — material, and fixed in-session)
The delivery diff first handed to the reviewer was a **stale intermediate snapshot**: it showed
`src/gate_run.rs` WITHOUT `timeout_notice` and a `verify-session-73.sh` referencing a
`run_captured_hang_is_killed_and_names_the_timeout` test absent from that same snapshot — because
the `timeout_notice` changes to `gate_run.rs` were sitting UNCOMMITTED while the two scripts that
depend on them had been committed (HEAD was internally inconsistent). The reviewer caught the
inconsistency, confirmed the real on-disk state, and judged the actual shipped code. **Fixed in
session:** the missing `gate_run.rs` changes were committed (`S73 step 2c`), HEAD is now consistent,
and the attestation below is computed on the final, complete delivery.

## Per-requirement verdict (13 of 13 SHIPPED)

| # | Requirement | Verdict | Evidence |
|---|-------------|---------|----------|
| 1 | AC-1/Plan-1: deflake at the ROOT; root cause named; ≥10-run loop + full `cargo test` ×2 green | SHIPPED | `static ENV_LOCK: Mutex<()>` + `env_guard()`; root cause "`std::env` is process-WIDE" in comments; `deflake-10x-consecutive-green` + `deflake-full-suite-run-2/3` |
| 2 | AC-1: no assertion weakened, no retry, no `#[ignore]`, no test deleted | SHIPPED | assertions intact; zero `#[ignore]` attribute lines; verify-73 asserts `assert_ne!` count ≥4 + anchored no-ignore grep |
| 3 | AC-1: leak closed sequentially too (not just concurrently) | SHIPPED | setter holds the guard across `set_var`→`remove_var`; every fold reader takes the same lock — no overlap window |
| 4 | AC-2/Plan-2: timeout KILLS the child and BLOCKS (never silent pass / hang) | SHIPPED | `wait_or_timeout` + `kill_tree` (process-group SIGKILL) → `None` → `LiveRed(None)` blocks |
| 5 | AC-2/AC-5: the block NAMES the timeout + script | SHIPPED (nuance) | `timeout_notice()` → streamed eprintln, captured folded into text; unit test + verify-73 grep BOTH `TIMEOUT` and the script name |
| 6 | AC-2: L1 still advises; skip envs keep meaning | SHIPPED | gate signatures unchanged; only the injected closure carries the timeout; dispatch/skip-env untouched (main.rs unchanged) |
| 7 | AC-3: unrecorded→default; recorded WINS; section-scoped | SHIPPED | `gate_timeout()` + three tests (default · recorded-wins-scoped · malformed/0→default) |
| 8 | AC-3: recorded in this repo AND propagated to `vajra init`; pre-S73 repos valid | SHIPPED | `timeout_secs: 600` in both sections; scaffold + `scaffold_records_the_gate_timeout_bound` |
| 9 | AC-4: normal green byte-identical | SHIPPED | streamed inherits stdio; captured echoes same stdout-then-stderr bytes; `Some(0)` path unchanged |
| 10 | AC-4: no CLI change, no 8th command, no new dep, no second store | SHIPPED | main.rs + Cargo.toml UNCHANGED; no `gate_run` in main.rs; no qa/demo/timeout `.md` store |
| 11 | AC-5/Plan-4: verify-73 E2E cases (hang-blocks · green · recorded-wins · default · deflake loop · verify-71/72 · lib ×2) | SHIPPED | all named checks present; hang cases assert `elapsed<20` on a `sleep 30` → really killed at bound |
| 12 | AC-5: demo-73 four `demo:<element>` markers + before→after | SHIPPED | all four markers present; before="flake red or hang forever" → after="deterministic, bounded, fail-closed" |
| 13 | Guardrails: one story · ≤3 files/commit · generous default disclosed | SHIPPED | commits ≤3 files each; `DEFAULT_TIMEOUT_SECS=600` disclosed "kills HANGS, not slow truth" |

**Count: 13 of 13 SHIPPED.**

## Fakest green (named)
The **QA (streamed) path collapses *timeout* and *spawn-failure* into the same `None`**, and the
gate's structured blocking *reason* for either is the generic "could not be evaluated (no exit
code)" — the word "TIMEOUT" reaches the close only via an adjacent `eprintln!`, a stderr
side-channel, not a first-class typed state. It still satisfies the contract (the live block output
names the timeout + script, asserted on both tokens with a real grep, and both cases correctly
BLOCK), and the captured/Demo-er path is stronger (the notice is folded into the returned `text`, so
it survives into the structured scan). It is the thinnest seam in an otherwise solid build — a
naming-is-a-print, not a weakened gate. Carried forward as a candidate hardening (a typed
`CannotEvaluate::{Timeout, SpawnFailure}`), disclosed, not a required fix for this contract.

## Verdict

**Verdict:** ACCEPT

A faithful build of the whole contract, not one slice dressed as the whole. Both named defects are
retired at the root — env-lock isolation for the flake; a bounded, fail-closed, process-group-killing
shared runner for both live gates — the bound rides the existing CONSTRAINTS spine with scaffold
propagation and section-scoped precedence, and every guardrail (no new command/dep/store, ≤3
files/commit, generous disclosed default, byte-identical green path) holds.

## Post-review builder fix (disclosed) + reviewer re-confirmation
After the ACCEPT, a real defect surfaced LIVE at the close (which a static review could not observe
at runtime): `run_captured` left the child's stdin INHERITED, whereas the old Demo-er `.output()`
nulled it — so the Demo-er gate re-run silently swallowed the `--advance` confirm keystroke (an
AC-4 "byte-identical wiring" regression). The builder fixed it (`bash()` now sets
`Stdio::null()` for both runners + a `run_captured_does_not_inherit_stdin` regression test) and sent
**only the delta** back to the same cold reviewer. Its re-confirmation: *"ACCEPT stands — unchanged.
The stdin delta is a strict correctness fix that restores Demo-er's prior wiring and hardens QA,
with a real regression test. It resolves the residual caveat on my byte-identical finding (#9) and
introduces no fidelity concern or gate-loosening. Count remains 13 of 13 SHIPPED."* The attestation
below is recomputed on the delivery INCLUDING the fix.

**Review-Inputs-SHA:** 1bfb459326121674b8898f0ed69c8fa04f7dabbfe566cc4f0aa72e563f44d191
