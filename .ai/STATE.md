# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S83 complete, S84 not yet started).
S83 = **CODE** — `src/cli/launch.rs` gains `has_permission_flag`/`should_warn_readonly_headless`:
`vajra claude -p ...` with no `--dangerously-skip-permissions`/`--permission-mode` on argv now
prints an advisory stderr warning BEFORE `claude` is spawned, naming the read-only wall (headless
Claude Code has no approval channel) and the fix. Closes the S76-dogfood-observed gap carried
across 5 sessions (S73/S76/S77/S78/S81). Advisory only — never blocks, never mutates `args`.
11/11 verify (E2E via a stub `claude` binary, $0/no credentials needed) · 263 lib tests (+2) ·
ACCEPT cold review (6/6 SHIPPED).

## Active PRs
- Merged: S82 [#80](https://github.com/ifelse-codes/vajra/pull/80) · S81
  [#79](https://github.com/ifelse-codes/vajra/pull/79) · S79
  [#77](https://github.com/ifelse-codes/vajra/pull/77) · S78
  [#76](https://github.com/ifelse-codes/vajra/pull/76) · S77
  [#75](https://github.com/ifelse-codes/vajra/pull/75).
- **S83 PR:** merged → [#81](https://github.com/ifelse-codes/vajra/pull/81)
  (`session-83-readonly-headless-warning`). Local + remote branch pruned; `main` synced.

## Direction (governance is the product — 8 governed stations + a durable station counter)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S83 closed the oldest standing UX debt in the receipt/launch arc:** a headless run with no
  permission decision on argv used to fail silently (every Write/Edit/Bash denied, no explanation)
  — first observed as a real paid-call loss in S76's dogfood ride-along, carried across 5
  sessions without a fix. `run()` now warns before spawn; the fix is advisory, not a new gate (no
  CONSTRAINTS.yaml key, no exit-code change, no `args` mutation).
- **New finding disclosed by S83's own cold review (not yet fixed):** `scripts/verify-session-83.sh`'s
  `ac5-advisory-exit-code-untouched` check is a near-tautology — the stub `claude` binary used for
  the $0 E2E proof always exits 0, so the check can't distinguish "warning fired correctly" from
  "warning logic broke in some way that still happens to exit 0." The AC5 property itself holds
  (verified by code-reading: the warning branch has no control-flow path), but the verify check
  is decorative. Also: the AC4 "interactive + permission-flag-present" combination is untested by
  any test/demo/verify case, only manually confirmed by the cold reviewer.
- **S82's disclosed finding is unchanged, still carried:** `session_attested_accept`/
  `reviewer_status`'s "attested" check is a bare substring match on `"review-inputs-sha"`, not a
  recomputed hash — load-bearing for 2 stations (Reviewer + Releaser). Carried as an S84+
  candidate (picked as candidate C at S83 close, not selected — S84 = the typed
  `CannotEvaluate` half instead).
- **S80 GT findings, updated:** (1) `verify-closeout.sh` checks Execution shas (S81 DONE).
  (2) Releaser structural decay on `--stations` — S82 DONE. (3) Dogfood: still stale since S76
  (intentional; receipt/counter/UX-focused $0 sessions since); 8-station dogfood refresh = MEASURE
  session, founder-un-parkable, still not re-picked.
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood:
  S76 baseline, aging. ③ compression: never claimed until measured (0 folds). ④ payload counter
  = BUILT (S74) + GT-verified (S75, S80) + hardened for Releaser durability (S82).
- **House patterns (carried):** … when a "derived, never-asserted" counter dimension goes
  structurally-always-ABSENT because its PRIMARY evidence source decays over time, fix it with a
  SECONDARY evidence fallback from another already-trusted store (S82). **NEW (S83):** an
  advisory UX warning should live entirely outside the governance-gate machinery — no
  CONSTRAINTS.yaml key, no waiver, no exit-code change — a pre-flight nudge on a *launch* is not a
  gate on a *close*; conflating the two would be scope creep (flagged explicitly in the S83
  prompt's own Guardrails and honored).

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt is AUTHORITATIVE when a `total_cost_usd` exists (S66/S78), HONEST when
  it genuinely doesn't (S77), correctly priced on the interactive estimate (S79), the closeout
  gate blocks unfilled execution shas (S81), the station counter's Releaser dimension is durable
  across branch pruning (S82), and **`vajra claude -p` now warns before a headless run hits the
  silent read-only wall (S83)**.
- **`vajra claude`** — headless-permission-flag pre-flight warning (S83) added beside the existing
  S78 tee/cost-capture logic and S34 auth pre-check; all three checks run in sequence in `run()`
  without interfering with each other.
- **`cargo test --lib` 263** (+2 over S82's 261 — the 2 new launch-warning tests).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.

## What Is Broken / Weak
- **🟡 S76 `## Execution` has `<sha>` placeholders** — S81 true positive, not yet fixed. Carried
  as an S84+ candidate (ranked B at S83 close).
- **🟡 `session_attested_accept`/`reviewer_status`'s attestation check is a substring match, not a
  hash recompute** — load-bearing for 2 stations (S82 finding). Carried as an S84+ candidate
  (ranked C at S83 close).
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — kept at historical
  $15/$75 as a conservative estimate (disclosed S79, re-confirmed S80).
- **🟡 The S73 fakest green — S84 IS FIXING THIS:** QA's streamed path (and Demo-er's captured
  path) collapse timeout + spawn-failure into one untyped `None`
  (`CannotEvaluate::{Timeout, SpawnFailure}` — split off S82's candidate B, S83 shipped the other
  half, S84 = this half, `prompts/84-task-typed-cannot-evaluate.md`, APPROVED).
- **🟡 S83's own verify-script check `ac5-advisory-exit-code-untouched` is a near-tautology**
  against the $0 stub `claude` binary (new finding, disclosed by S83's cold review; not fixed).
- **🟡 Dogfood: stale since S76** — intentionally so ($0 receipt/counter/UX-focused sessions
  since). Refresh = founder-un-parkable MEASURE session, not yet re-picked.
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured (S70).
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70.
- 🟡 `vajra init` template omits `pipeline_advance_check` (precedent) · ledger tamper-EVIDENT not
  PROOF + opt-in · guard nested-repo blindspot · install path · readable-roadmap one-pager (backlog).

## What Is In Progress
- **S83 DONE.** **Next = S84 — typed `CannotEvaluate::{Timeout, SpawnFailure}`** (APPROVED,
  `prompts/84-task-typed-cannot-evaluate.md`). New chat. **S85 = the next mandatory NO-CODE GT.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **Session 77–82: ~$0 each** (S78 ~$0.055; the rest bash-only or local-subagent cold reviews, not
  billed against the Claude Code session budget). **Session 83: ~$0** (bash-only source fix + a
  local `general-purpose` subagent cold review, not a paid API call).
- Cumulative: **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
