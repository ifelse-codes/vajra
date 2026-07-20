# Session 84 — Typed `CannotEvaluate::{Timeout, SpawnFailure}` — summary

**Type:** CODE — one new enum (`src/gate_run.rs`) + a return-type change propagated to its two
call sites (`src/qa/mod.rs`, `src/demoer/mod.rs`). No new module, command, dependency, or
CONSTRAINTS.yaml key. Founder pick A at S83 close — the other half of S82's candidate B split.

## Headline

The QA and Demo-er gates' live re-run (S73) bounds a script by a recorded wall-clock timeout, but
both `run_streamed`/`run_captured` collapsed two structurally different failure modes into the
same untyped `None`: **the script hung past its bound and was killed** (a slow-truth problem) vs
**the child process never spawned at all** (an environment problem — bash missing, permission
denied, a broken path). Every downstream BLOCK message printed the same generic "could not be
evaluated (no exit code)" — the S73 fakest-green finding, disclosed at the time and carried
across 7 sessions (S76–S83) without a fix. Both runners now return `Result<i32, CannotEvaluate>`,
and both gates' BLOCK messages name which failure mode occurred.

## What shipped

- **`CannotEvaluate { Timeout, SpawnFailure }`** (`src/gate_run.rs`) — lives beside the functions
  it types, alongside `timeout_notice`/`kill_tree`/`wait_or_timeout`.
- **`run_streamed`/`run_captured` retyped** — `Result<i32, CannotEvaluate>` /
  `(Result<i32, CannotEvaluate>, String)`. The `.spawn()` `Err` arm returns `SpawnFailure`; the
  killed-timeout arm returns `Timeout`; a real exit code is unchanged.
- **The signal-death edge** (a process that exits before the timeout but without a numeric code,
  killed by an external signal that is *not* our own timeout kill): resolved conservatively via
  `code_or_conservative(status) = status.code().unwrap_or(1)` — a real, still-blocking exit code,
  never a second ambiguous `None`.
- **Test-only injectable program-name seam** (`command_for`, `run_streamed_with_program`,
  `run_captured_with_program`, all `#[cfg(test)]`-gated except the shared `command_for`) — forces
  a deterministic spawn failure via an absolute nonexistent path, with **no global `PATH`
  mutation** (the Design section's flakiness guard: other tests in the suite spawn real
  subprocesses in parallel threads).
- **`QaState`/`DemoState` reshaped**: both drop their own `LiveRed(Option<i32>)` ambiguity for a
  `CannotEvaluate(CannotEvaluate)` variant + a `LiveRed(i32)` that only ever carries a real exit
  code. `qa_gate_with`/`demo_gate_with`'s BLOCK message now names `TIMEOUT` or `SPAWN FAILURE`
  distinctly instead of one generic "no exit code" line.
- **4 new tests**: 2 in `gate_run.rs` (`run_streamed_spawn_failure_is_distinct_from_timeout`,
  `run_captured_spawn_failure_is_distinct_from_timeout`) proving the two reasons are visibly
  different values via `assert_ne!`, and 1 each in `qa/mod.rs`/`demoer/mod.rs`
  (`gate_block_message_names_timeout_distinctly_from_spawn_failure`) proving the two BLOCK
  messages differ in wording, not just internal type.
- **`scripts/verify-session-84.sh`** (16 checks) + **`scripts/demo-session-84.sh`** (four
  `demo:<element>` markers) — both drive the REAL `vajra next --check-qa/--check-demo` gate path
  end-to-end against a synthetic temp repo (empty `PATH` for spawn failure, a `sleep` past a 1s
  bound for timeout), so the E2E proof costs $0 and needs no credentials.

## Proof

- `bash scripts/verify-session-84.sh` → **16/16 PASS**, including live E2E for both cannot-evaluate
  reasons on both gates.
- `cargo test --lib` → **267 passed** (+4 over `main`'s 263).
- `cargo clippy --all-targets --all-features -- -D warnings` and `cargo fmt --check` → clean.
- Scope: `git diff --name-only main -- src/` == exactly `src/demoer/mod.rs`, `src/gate_run.rs`,
  `src/qa/mod.rs` — no drift into `launch.rs`, the S76 sha debt, or the attestation check.

## Fidelity map (prompt requirement → delivery)

| # | Requirement | Verdict | Evidence |
|---|-------------|---------|----------|
| 1 | Spawn failure → `Err(SpawnFailure)`, BLOCK names it distinctly | **SHIPPED** | Unit tests + live E2E (empty `PATH`) on both gates |
| 2 | Timeout → `Err(Timeout)`, BLOCK names it as a timeout | **SHIPPED** | Unit tests + live E2E (`sleep` past bound) on both gates |
| 3 | Real nonzero exit code → UNCHANGED, not `CannotEvaluate` | **SHIPPED** | `Ok(c) => LiveRed(c)`; live E2E `exit 7` names "exited 7", no TIMEOUT/SPAWN FAILURE text |
| 4 | Exit 0 → unchanged (`LiveGreen`/no block) | **SHIPPED** | Live E2E green pass, both gates |
| 5 | Both call sites carry the fix | **SHIPPED** | `qa/mod.rs` + `demoer/mod.rs` both reshaped identically |
| 6 | `cargo test --lib` green; no weakened assertion; new test proves the two reasons are visibly different | **SHIPPED** | 267 (+4); every old `Option`/`None` assertion re-typed to name the real value, none loosened |

**NOT built:** nothing from the prompt was skipped. The independent cold review
(`sessions/session-84-review.md`) confirms all 6 numbered criteria SHIPPED — ACCEPT.

## Honest limits (fakest green, reviewer-sharpened)

- **The signal-death edge has no dedicated automated test** — the prompt's Plan flagged it as
  "still-open," and the shipped resolution (`code_or_conservative`, real fallback code `1`) is
  verified correct by the cold reviewer manually (a live `kill -9 $$` script), not by any
  `#[test]` in the diff. The resulting BLOCK message ("exited 1") could read to an operator as an
  explicit `exit 1` rather than a signal death with a synthesized placeholder code. Low severity —
  the AC doesn't require a third named reason for this case, and the behavior fails closed.
- **A pre-existing (S73, not S84) collapse remains:** `wait_or_timeout`'s `Err(_) => None` arm (a
  `try_wait()` OS-level error, distinct from both a genuine timeout and a spawn failure) is
  classified as `CannotEvaluate::Timeout` by the caller. Out of this session's scope — not one of
  the two failure modes the ACs target.

## Attestation

- **Review-Inputs-SHA:** `0e172ca700ac46b0c8720cee11364c883da4ade0ef1ddb55349324ba761e5b9f`
  (`sha256(prompt ‖ delivery-diff)`; delivery diff = `src/gate_run.rs`, `src/qa/mod.rs`,
  `src/demoer/mod.rs` + `scripts/verify-session-84.sh` + `scripts/demo-session-84.sh`, per
  `scripts/verify-closeout.sh --inputs-sha 84`). See `sessions/session-84-review.md` for the
  independent cold verdict (ACCEPT).

## Coder-gate execution (plan step → landing commit)

- step 1 (`CannotEvaluate` + retyped runners + test seam) → `d0cf43f`
- step 2 (`qa/mod.rs` propagation) → `d0cf43f`
- step 3 (`demoer/mod.rs` propagation) → `d0cf43f`
- step 4 (test updates + new spawn-failure coverage) → `d0cf43f`

All 4 plan steps landed together in one commit — a single coherent type-threading edit across 3
tightly-coupled files, disclosed plainly in the commit message rather than split into 4 artificial
commits. `scripts/verify-session-84.sh` + `scripts/demo-session-84.sh` → `b01c34e`.

## 3 ranked S86 candidates (post-S85 ground truth)

- **🥇 A — S76 retroactive sha fix** (short, standing since S81, now **8 sessions overdue**): fill
  the 4 `<sha>` placeholders in `prompts/76-task-dogfood-ride-along.md` with real S76 shas; verify
  `--check-exec-shas 76` passes. Key risk: none material — a clean, bounded fix that keeps aging
  every session it isn't picked.
- **🥈 B — harden the attestation check itself** (S82's disclosed finding, still the standing weak
  point behind 2 stations): `session_attested_accept`/`reviewer_status` (`src/stations/mod.rs`)
  both trust a bare substring match on `"review-inputs-sha"` rather than recomputing the hash
  `verify-closeout.sh`'s `canonical_inputs_sha` already computes. Fix = have the station counter
  call the same canonical-hash logic (or shell out to it). Key risk: the first real design tension
  in this arc — porting bash hashing logic into Rust, or having Rust shell out to bash, needs a
  clean call; likely the largest of the three candidates.
- **🥉 C — the readable-roadmap one-pager** (backlog since ~S69, founder-flagged notebook-bloat
  pain reading `ROADMAP.md`/`STATE.md` raw): a DERIVED, never-hand-maintained summary view over
  the live `.ai/` spine (the S19/S22 no-hand-copy pattern). Key risk: scope discipline — easy to
  over-build into a second store; must stay strictly derived, never authored.

**S85 = the next mandatory NO-CODE ground truth** (`85 % 5 == 0`), already fixed regardless of
which S86 candidate is picked.
