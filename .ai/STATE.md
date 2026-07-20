# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S84 complete, S85 not yet started).
S84 = **CODE** — `src/gate_run.rs` gains `CannotEvaluate { Timeout, SpawnFailure }`;
`run_streamed`/`run_captured` retyped from `Option<i32>`/`(Option<i32>, String)` to
`Result<i32, CannotEvaluate>`/`(Result<i32, CannotEvaluate>, String)`. `src/qa/mod.rs`'s
`QaState` and `src/demoer/mod.rs`'s `DemoState` drop `LiveRed(Option<i32>)` for a
`CannotEvaluate(CannotEvaluate)` variant + a bare `LiveRed(i32)`. Both gates' BLOCK message now
names TIMEOUT vs SPAWN FAILURE distinctly — closes the S73 fakest-green finding carried across 7
sessions (S76-S83). New injectable-program-name test seam avoids global `PATH` mutation.
267 lib tests (+4) · 16/16 verify (unit + live E2E via the real binary against a synthetic temp
repo) · ACCEPT cold review (6/6 SHIPPED).

## Active PRs
- Merged: S83 [#83](https://github.com/ifelse-codes/vajra/pull/83) · S82
  [#80](https://github.com/ifelse-codes/vajra/pull/80) · S81
  [#79](https://github.com/ifelse-codes/vajra/pull/79) · S79
  [#77](https://github.com/ifelse-codes/vajra/pull/77) · S78
  [#76](https://github.com/ifelse-codes/vajra/pull/76).
- **S84 PR:** [#83](https://github.com/ifelse-codes/vajra/pull/83)
  (`session-84-typed-cannot-evaluate`) — merged pre-closeout per the S83 premerge-verify lesson;
  local + remote branch pruned; `main` synced.

## Direction (governance is the product — 8 governed stations + a durable station counter)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S84 closed the S73 fakest-green finding, the last standing item from the QA/Demo-er live-gate
  arc:** the two gates' cannot-evaluate BLOCK used to say the identical generic "no exit code"
  whether the script hung past its bound or the process never spawned at all — an operator
  debugging a blocked close could not tell which. The typed `CannotEvaluate` value now names it;
  the signal-death edge (a process that exits without a code but is not our own timeout kill) is
  resolved conservatively via a real, still-blocking placeholder code rather than a second
  ambiguous `None`.
- **New house pattern (S84): a deterministic spawn-failure test needs an injectable program name,
  not a global `PATH` mutation** — `cargo test --lib` runs tests on parallel threads alongside
  others that spawn real subprocesses, so `set_var("PATH", …)` is a flakiness landmine (the same
  class of hazard S73's `static ENV_LOCK` fixed for a different global). Also new: a live spawn
  failure can be forced against the REAL compiled binary for a verify script by overriding `PATH`
  to a nonexistent directory for one invocation — no stub binary needed.
- **Closeout-verify-premerge lesson APPLIED, not just recorded:** S83 discovered
  `canonical_inputs_sha`'s `git merge-base main HEAD` collapses once a session's branch is merged
  into main (the diff window vanishes). S84 ran the full `verify-closeout.sh` — with `.ai/SESSION`
  bumped to 84 — on the session branch BEFORE merging the PR, confirming `review-inputs-attested`
  passes while the merge-base still isolates the branch's own diff.
- **S82's disclosed finding is unchanged, still carried, now RE-DISCLOSED a 3rd time (S84):**
  `session_attested_accept`/`reviewer_status`'s "attested" check is a bare substring match on
  `"review-inputs-sha"`, not a recomputed hash — load-bearing for 2 stations (Reviewer + Releaser).
  Standing since S82, carried through S83, disclosed again at S84 without being picked. Ranked 🥈 B
  for S86.
- **S80 GT findings, updated:** (1) `verify-closeout.sh` checks Execution shas (S81 DONE).
  (2) Releaser structural decay on `--stations` — S82 DONE. (3) Dogfood: still stale since S76
  (intentional; receipt/counter/UX/typing-focused $0 sessions since S77) — now **8 sessions**
  (S77–S84) since the last paid run, aging further; S85's GT must state the exact age, not guess.
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood:
  S76 baseline, aging (8 sessions stale as of S84). ③ compression: never claimed until measured (0
  folds). ④ payload counter = BUILT (S74) + GT-verified (S75, S80) + hardened for Releaser
  durability (S82).
- **House patterns (carried):** … when a "derived, never-asserted" counter dimension goes
  structurally-always-ABSENT because its PRIMARY evidence source decays over time, fix it with a
  SECONDARY evidence fallback from another already-trusted store (S82). An advisory UX warning
  lives entirely outside the governance-gate machinery — no CONSTRAINTS.yaml key, no waiver, no
  exit-code change (S83). **NEW (S84): when a state enum's variant conflates "no code" with "code
  present" inside ONE `Option`-wrapped case, split it into a distinct typed variant so the
  wrapping-type stays honest at every layer it's threaded through** (`gate_run::CannotEvaluate` →
  `QaState`/`DemoState::CannotEvaluate(..)` — the same "don't leave a second `Option`-shaped
  ambiguity" rule applied consistently top to bottom, not just at the lowest layer).

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt is AUTHORITATIVE when a `total_cost_usd` exists (S66/S78), HONEST when
  it genuinely doesn't (S77), correctly priced on the interactive estimate (S79), the closeout
  gate blocks unfilled execution shas (S81), the station counter's Releaser dimension is durable
  across branch pruning (S82), `vajra claude -p` warns before a headless run hits the silent
  read-only wall (S83), and **the QA/Demo-er gates' cannot-evaluate BLOCK names WHICH of two
  reasons occurred — Timeout or SpawnFailure — instead of one generic "no exit code" (S84)**.
- **`vajra claude`** — headless-permission-flag pre-flight warning (S83) added beside the existing
  S78 tee/cost-capture logic and S34 auth pre-check; all three checks run in sequence in `run()`
  without interfering with each other.
- **`cargo test --lib` 267** (+4 over S83's 263 — 2 spawn-failure-distinctness tests in
  `gate_run.rs`, 1 each in `qa/mod.rs`/`demoer/mod.rs`).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.

## What Is Broken / Weak
- **🟡 S76 `## Execution` has `<sha>` placeholders** — S81 true positive, not yet fixed. Standing
  since S81, now **8 sessions overdue**. Ranked 🥇 A for S86.
- **🟡 `session_attested_accept`/`reviewer_status`'s attestation check is a substring match, not a
  hash recompute** — load-bearing for 2 stations (S82 finding), re-disclosed at S84, standing 3
  sessions without being picked. Ranked 🥈 B for S86.
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — kept at historical
  $15/$75 as a conservative estimate (disclosed S79, re-confirmed S80).
- **🟡 The signal-death edge case (`gate_run::code_or_conservative`) has no dedicated automated
  test** — S84's own cold review finding; behavior fails closed and was live-verified by the
  reviewer, but no `#[test]` in the suite exercises it. Low severity, not fixed this session.
- **🟡 A pre-existing (S73) `wait_or_timeout` `Err(_) => None` (a `try_wait()` OS-level error) is
  still classified as `CannotEvaluate::Timeout`** — distinct from a genuine timeout, out of S84's
  scope (not one of the two failure modes its ACs targeted).
- **🟡 S83's own verify-script check `ac5-advisory-exit-code-untouched` is a near-tautology**
  against the $0 stub `claude` binary (disclosed S83, not fixed).
- **🟡 Dogfood: stale since S76 — now 8 sessions (S77–S84)** — intentionally so ($0 receipt/
  counter/UX/typing-focused sessions since). Refresh = founder-un-parkable MEASURE session, not
  yet re-picked. S85's GT must state the exact calendar+session age, not guess a verdict.
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured (S70).
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70.
- 🟡 `vajra init` template omits `pipeline_advance_check` (precedent) · ledger tamper-EVIDENT not
  PROOF + opt-in · guard nested-repo blindspot · install path · readable-roadmap one-pager
  (backlog, ranked 🥉 C for S86).

## What Is In Progress
- **S84 DONE.** **Next = S85 — mandatory NO-CODE ground truth** (`85 % 5 == 0`,
  `prompts/85-task-ground-truth.md`). Lead lens A: did S81→S84's 4 hardening/UX sessions advance
  the pipeline, or repeat the S80-flagged easy-green-detour pattern? New chat.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **Session 77–83: ~$0 each** (S78 ~$0.055; the rest bash-only or local-subagent cold reviews, not
  billed against the Claude Code session budget). **Session 84: ~$0** (bash-only source fix + a
  local `general-purpose` subagent cold review, not a paid API call).
- Cumulative: **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
