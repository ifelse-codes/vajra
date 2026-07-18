# Session 73 — Close-path RELIABILITY: fix the brakes

**Type:** CODE (founder pick at the S72 board review: "close path reliability. fix the brakes
first" — over the payload counter and the parked dogfood ride-along). **Spend ~$0** (docs/code +
one cold-review subagent).

## What shipped
Since S69 every close RE-RUNS the full test suite and the demo LIVE — the close path IS the
product's brakes. Two real defects, both observed at S72's own close, are retired:

- **(a) The flake — fixed at the ROOT.** Two `tests/hook_adapter.rs` compression tests failed
  intermittently under repeated full-suite runs. Root cause: `std::env` is process-WIDE and Rust
  runs `#[test]`s on parallel threads; `passthrough_vajra_raw_env`'s `set_var("VAJRA_RAW")` leaked
  into a concurrently-running fold test, flipping its fold → passthrough → random red on
  `assert_ne!(out, "{}")`. Fix: a `static ENV_LOCK` the one env-mutating test AND every
  fold-asserting reader take, so they never overlap (closes both the concurrent and the sequential
  window). **No assertion weakened, no retry, no `#[ignore]`, no test deleted.** A ≥10-run
  consecutive loop + full `cargo test` ×2 are the regression proof.
- **(b) The unbounded live run — bounded, fail-closed.** The QA (S69) and Demo-er (S71) gates
  re-ran a script with NO time limit → a hung script hung the close forever. New shared
  `src/gate_run.rs`: `run_streamed` (QA, live) + `run_captured` (Demo-er, output for the element
  scan) bound the run by a recorded wall-clock timeout; a run past the bound is KILLED (whole
  process group, Unix — so a hung script's orphaned grandchildren die and can't block the reader
  threads) and returns `None` = cannot-evaluate, which each gate already classifies as a BLOCK.
  `timeout_notice` names the timeout + script in the killed run's output (never a silent `None`).
  The timeout **narrows** the gate (can never PASS a close), never loosens it.
- **The contract rides the spine.** `verify.timeout_secs` / `demo.timeout_secs` recorded in this
  repo AND propagated into the `vajra init` scaffold (the S22/S57 pattern); a recorded value wins,
  a missing key resolves to the built-in default (**600s — generous on purpose: kills HANGS, not
  slow truth**), section-scoped. Pre-S73 repos stay valid with no edits. **No CLI change, no 8th
  command, no new dependency, no second store.**

## Proof
- `cargo test --lib` **239 passed** (+10 at S73: 9 `gate_run` + 1 init-propagation; the ≥10-run
  deflake loop lives in the `hook_adapter` integration binary, not `--lib`). fmt/clippy clean.
- `scripts/verify-session-73.sh` **all green (33 checks)** — the deflake 10×-loop + full suite ×2;
  a hanging verify/demo script BLOCKS within a recorded 1s bound naming the timeout (recorded 1s
  WINS over the 600s default, proven by wall-clock `elapsed<20s` on a `sleep 30` script); a green
  script still passes; the default path passes; scaffold records the key via a real `vajra init`;
  **verify-71 + verify-72 re-run green** (AC-4); no CLI/dep/store change; per-commit file cap ≤3.
- `scripts/demo-session-73.sh` — four `demo:<element>` markers, before → after = "a close could
  flake red or hang forever" vs "deterministic, bounded, fail-closed"; live cases run green.
- **Independent cold review ACCEPT (13/13 SHIPPED)**, attested
  `1bfb4593…` — and it earned its place: it caught that the `timeout_notice` changes to
  `gate_run.rs` were uncommitted while the two scripts depending on them were committed (HEAD
  internally inconsistent). **Fixed in-session** (`S73 step 2c`), then re-attested on the complete
  delivery.

## Fakest green (disclosed)
The QA streamed path collapses *timeout* and *spawn-failure* into the same `None`; the gate's
structured blocking *reason* is generic ("could not be evaluated"), and "TIMEOUT" reaches the close
only via an `eprintln!` side-channel — naming-is-a-print, not a typed state. Satisfies the contract
(the block output names the timeout + script, asserted with a real two-token grep; both cases
BLOCK), and the captured/Demo-er path is stronger (the notice folds into the returned text). Carried
as a candidate hardening (a typed `CannotEvaluate::{Timeout, SpawnFailure}`), not a required fix.

## House lessons
- **A committed script must not depend on an uncommitted source change** — HEAD must be internally
  consistent at every commit; the cold review's diff-vs-disk check is what surfaced it.
- The bounded-runner is a **shared** primitive (`gate_run.rs`) for the two live gates, not a
  duplicated poll loop — the S69/S71 "shared runner pattern" made real.
- Killing a hung bash script means killing its **process group**, not just the direct child, or an
  orphaned `sleep` keeps the captured pipe open and blocks the reader threads.
- **A gate re-run must NOT inherit the operator's stdin** — found live at this close: `run_captured`
  left stdin inherited (the old Demo-er `.output()` nulled it), so the Demo-er gate silently
  swallowed the `--advance` confirm keystroke. Fixed (`Stdio::null()` for both runners + regression
  test) and re-attested with the same cold reviewer (verdict unchanged). `Command::output()` nulls
  stdin; a hand-rolled piped spawn does not — restore it explicitly.

## Branch / next
- Branch `session-73-close-path-reliability` → `main` (PR — founder call to merge). The Releaser
  gate is LIVE from this close: merge the PR, sync main, prune `session-72-*` locals before/at the
  next close.
- **S75 = the next mandatory NO-CODE ground-truth.**

## Next — ranked candidates (S74)
- **A — Payload counter (the pipeline-advance metric) [recommended].** *Goal:* a single recorded
  count of how many governed stations a session actually moved through, so a GT can measure whether
  the PIPELINE advances (not just whether rails are followed). *Why pick this:* recommended at
  S25/S60/S65/S70 and STILL unbuilt — the one meta-gap no gate measures; the brakes are now fixed,
  so the machinery is trustworthy enough to instrument. *Risk:* defining "advanced a stage" without
  it becoming another self-asserted digit-tag.
- **B — Dogfood ride-along (parked, READY-shaped).** *Goal:* founder drives one real paid task
  through the full 8-station pipeline; agent measures receipt/folds/gates-fired/obedience. *Why
  pick this:* last paid run was S63 (6-station era, $1.27) — the crew is complete and now
  reliable; the deferral condition is long met. *Risk:* founder-time-gated (needs the founder to
  drive); ~$1–5 spend.
- **C — Typed cannot-evaluate + depth hardening.** *Goal:* replace the shared `None` with
  `CannotEvaluate::{Timeout, SpawnFailure}` so the gate's structured reason names the timeout as a
  first-class state (retires this session's fakest green), and take one bite of the
  seven-gate-wide self-granted-jurisdiction class. *Why pick this:* closes the disclosed S73 seam
  while it's fresh. *Risk:* incremental hardening, lower leverage than measuring the pipeline.
