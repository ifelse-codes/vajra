# Session 83 — Warn before a headless run hits the read-only wall (CODE)

> **Status:** APPROVED (founder pick B at S82 close).
> **Type:** CODE — one story; one new function + one call-site wire in `src/cli/launch.rs`, no
> new module, no new command, no new dependency.
> **Scope note:** the S82 summary's candidate B bundled two sub-stories and flagged "may need
> splitting." This session takes the **read-only-headless UX** half only — it is the half with a
> real, observed failure (S76 dogfood run 1 burned a paid headless call against a silent wall).
> The typed `CannotEvaluate::{Timeout,SpawnFailure}` half (`src/gate_run.rs`) is carried forward
> as the natural S84 follow-on, not dropped.

## Goal

`vajra claude -p "..."` with no permission-mode flag is a **read-only agent**: headless Claude
Code has no approval channel, so every Write/Edit/Bash tool call is silently denied. Nothing in
`vajra claude` says so before the run starts. S76's paid dogfood ride-along hit exactly this wall
on run 1 — spent real money, got nothing written, and only diagnosed it after the fact by reading
the transcript. `vajra` already computes `is_headless(args)` for the S78 cost-capture logic; this
session adds one more check next to it and prints a warning before the process is even spawned.

**Root cause:** `src/cli/launch.rs::run()` never inspects `args` for a permission-mode flag —
`is_headless` exists only to gate the tee/cost-capture path (S78), not to warn the user.

**Fix:** a new `has_permission_flag(args) -> bool` — the same exact-token-scan style as
`is_headless` (no new dependency, no substring false-positives) — checked right after `headless`
is computed. `headless && !has_permission_flag(args)` prints one clear stderr warning before
`command` is ever spawned. Advisory only: it never blocks, never exits, never mutates `args`.

## Why this session

Documented directly in `sessions/session-76-dogfood.md` ("🔴 The read-only wall (run 1)") and
carried as a debt across 5 sessions (S73/S76/S77/S78/S81 all deferred it). It is the one gap in
this arc with a real dollar cost already paid, not a theoretical one.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)

1. **WHEN** `vajra claude -p "..."` is invoked with NEITHER `--dangerously-skip-permissions` NOR
   `--permission-mode <mode>` present in argv **THEN** a stderr warning prints BEFORE `claude` is
   spawned, naming (a) that Write/Edit/Bash calls will be silently denied and (b) the two flags
   that fix it.
2. **WHEN** `--dangerously-skip-permissions` is present (exact token, anywhere in argv) **THEN**
   no warning prints.
3. **WHEN** `--permission-mode` is present (exact token, any following value) **THEN** no warning
   prints — vajra does not second-guess WHICH mode the user chose, only whether they made a
   permission decision at all.
4. **WHEN** the run is interactive (no `-p`/`--print`) **THEN** no warning prints regardless of
   permission flags — the TTY is its own approval channel; this is a headless-only gap.
5. The warning is advisory only: it never changes the exit code, never blocks the launch, never
   mutates `args` before they reach `command.args(args)` — a real headless read-only probe (asking
   a question, not requesting a write) is a legitimate use case, not an error.
6. `cargo test --lib` stays green; new unit tests cover ACs 1–4 directly against the detection
   function (mirrors `is_headless_detects_print_flags_only`'s existing style — no live process
   spawn needed).

## Design (the Architect gate — recorded rationale)

- **design-significant: no** — one pure function (`has_permission_flag`) beside the existing
  `is_headless`, one `eprintln!` call site inside `run()`. No new module, CLI command, dependency,
  or data store.
- Detection is a plain exact-token scan (`args.iter().any(|a| a == "...")`) — the same pattern
  `is_headless` already uses at `src/cli/launch.rs:68-70`. No new parsing dependency; consistent
  with the house rule (this file already avoids substring matches — see the existing `-p buried
  in a value string` test).
- Placed in `run()` right after `let headless = is_headless(args);` (line 32) — BEFORE the
  `match merge_hook_settings()...` branch, so the warning fires on both the settings-injection-ok
  and settings-injection-failed paths identically (it must not depend on which branch runs).
- Advisory, not enforcement: unlike the QA/Demo-er/Releaser gates (which block a *close*), this is
  a pre-flight UX nudge on a *launch* — there is no governance decision here, no waiver needed, no
  CONSTRAINTS.yaml key. A read-only headless probe is sometimes exactly what the user wants.

## Plan (ordered steps — cite the acceptance criteria each step covers)

1. Add `has_permission_flag(args: &[String]) -> bool` to `src/cli/launch.rs`, beside
   `is_headless`: `true` if `--dangerously-skip-permissions` or `--permission-mode` appears as an
   exact token anywhere in `args`. `covers: 2, 3`

2. In `run()`, right after `let headless = is_headless(args);`, add:
   ```rust
   if headless && !has_permission_flag(args) {
       eprintln!("{}", readonly_headless_warning());
   }
   ```
   with `readonly_headless_warning() -> String` (or a `const`) naming: no approval channel in
   headless mode, every Write/Edit/Bash call will be silently denied, and the fix
   (`--dangerously-skip-permissions` or `--permission-mode <mode>`). `covers: 1, 4, 5`

3. Add unit tests mirroring `is_headless_detects_print_flags_only`'s style: a
   `has_permission_flag` test covering ACs 2–3 (present/absent, exact-token not substring), and a
   thin integration-style test (call the same warn-or-not decision the runtime uses, e.g. by
   extracting `headless && !has_permission_flag(args)` into a small testable helper if that reads
   cleaner than re-deriving it inline) covering ACs 1 and 4 together. `covers: 6`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: 17279d8
- step 2 — done: 17279d8
- step 3 — done: 17279d8

## Delta (the Analyst gate — what this session ADDS to the governed pipeline)

- `+` `vajra claude -p ...` with no permission-mode flag now prints a stderr warning BEFORE
  spawning Claude Code, naming the read-only wall and the fix — closes the S76-observed gap where
  a paid headless run could silently do nothing
- `+` `has_permission_flag` helper added to `src/cli/launch.rs`, same exact-token-scan style as
  the existing `is_headless`
- `+` new unit tests covering the warn/no-warn matrix (permission flag present/absent ×
  headless/interactive)

## Guardrails

- **One story:** the read-only-headless warning only. Do NOT touch `src/gate_run.rs` or the
  QA/Demo-er `None` cannot-evaluate typing — that is the deferred S84 half.
- **Advisory, never enforcing:** no new exit code, no new block, no CONSTRAINTS.yaml key, no
  waiver mechanism. If this session finds itself adding governance around the warning, that is
  scope creep — stop and flag it.
- **No new dependency, no new command:** `vajra claude` behavior only.
