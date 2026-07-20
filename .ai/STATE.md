# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S82 complete, S83 not yet started).
S82 = **CODE** — `releaser_status` (`src/stations/mod.rs`) now falls back to the attested
cold-review ledger when a session's branch is `BranchShip::NoBranch` (merged then pruned — the
S37 REQUIRED close step, indistinguishable in git alone from "never existed"). New
`session_attested_accept` helper reuses the existing `review_verdict_accept` read path (no new
store). `Unmerged`/`Merged` paths are unchanged — confirmed algebraically identical by the cold
reviewer. Live: `vajra next --stations 81` now shows `[PASSED] Releaser SHIP` naming the ledger.
11/11 verify · 261 lib tests (+3) · ACCEPT cold review.

## Active PRs
- Merged: S81 [#79](https://github.com/ifelse-codes/vajra/pull/79) · S80-closeout · S79
  [#77](https://github.com/ifelse-codes/vajra/pull/77) · S78
  [#76](https://github.com/ifelse-codes/vajra/pull/76) · S77
  [#75](https://github.com/ifelse-codes/vajra/pull/75).
- **S82 PR:** open → [#80](https://github.com/ifelse-codes/vajra/pull/80)
  (`session-82-releaser-durability`, to be merged).
- **⚠ The Releaser gate is LIVE:** before closing S83 — merge PR #80, checkout `main`, pull,
  prune `session-82-*`. Skip it and the S83 `--advance` refuses the close.

## Direction (governance is the product — 8 governed stations + a durable station counter)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S82 fixed the station counter's own Releaser false-read:** `vajra next --stations NN` used to
  show every properly-shipped session as `[ABSENT] Releaser SHIP` once its branch was pruned
  (S75 + S80 GT, 2 consecutive confirmations). The counter now reads the attested ledger as
  fallback evidence when no branch ref survives — durable across the normal prune-after-merge
  cycle, not just a point-in-time git snapshot.
- **New governance finding (S82, disclosed by the cold review, not yet fixed):**
  `session_attested_accept`'s "attested" check is a bare substring match on the text
  `"review-inputs-sha"`, not a recomputed cryptographic hash (that recompute only happens in
  `verify-closeout.sh`'s separate close-time attestation gate). S82 makes this pre-existing weak
  check load-bearing for a SECOND station (Releaser, on top of Reviewer) — doubling the blast
  radius of a forged/stale attestation string inflating the payload counter. Carried as an S83+
  candidate (picked as candidate C, not selected for S83 — S83 = the read-only-headless UX story).
- **S80 GT findings, updated:** (1) `verify-closeout.sh` checks Execution shas (S81 DONE).
  (2) Releaser structural decay on `--stations` (S75/S80 finding) — **S82 DONE.** (3) Dogfood:
  still stale since S76 (intentional; receipt/counter-focused $0 sessions since); 8-station
  dogfood refresh = MEASURE session, founder-un-parkable, still not re-picked.
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood:
  S76 baseline, aging. ③ compression: never claimed until measured (0 folds). ④ payload counter
  = BUILT (S74) + GT-verified (S75, S80) + hardened for Releaser durability (S82).
- **House patterns (carried):** … **NEW (S82):** when a "derived, never-asserted" counter
  dimension goes structurally-always-ABSENT because its PRIMARY evidence source decays over time
  (here: pruned git refs, the required end-state), fix it with a SECONDARY evidence fallback from
  another already-trusted store — never loosen the primary check, only add a fallback for the case
  the primary source cannot see.

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt is AUTHORITATIVE when a `total_cost_usd` exists — from the transcript
  (S66) OR recovered from a headless run's result stream (S78) — HONEST when it genuinely doesn't
  (interactive: "no authoritative cost available" + a clearly-secondary token estimate, S77), that
  token estimate is CORRECTLY PRICED on current opus (S79), the closeout gate blocks unfilled
  execution shas (S81), and the station counter's Releaser dimension is now durable across branch
  pruning via the attested ledger (S82).
- **`vajra next --stations NN` (S74, hardened S82):** per-station PASSED/ABSENT + derived K-of-8.
  `releaser_status` now has a 3-way match on `BranchShip` (Unmerged/Merged/NoBranch), with
  `NoBranch` falling back to `session_attested_accept`.
- **`cargo test --lib` 261** (+3 over S81's 258 — the 3 new Releaser ledger-fallback tests).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.

## What Is Broken / Weak
- **🟡 S76 `## Execution` has `<sha>` placeholders** — S81 true positive, not yet fixed. Carried
  as an S83+ candidate A.
- **🟡 `session_attested_accept`/`reviewer_status`'s attestation check is a substring match, not a
  hash recompute** — now load-bearing for 2 stations (S82 finding). Carried as candidate C.
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — kept at historical
  $15/$75 as a conservative estimate (disclosed S79, re-confirmed S80).
- **🟡 Read-only-headless UX (S76):** `vajra claude -p` with no permission flag is silently
  read-only. **S83 is fixing this** (`prompts/83-task-readonly-headless-warning.md`, APPROVED).
- **🟡 The S73 fakest green persists:** QA's streamed path collapses timeout + spawn-failure into
  one untyped `None` (`CannotEvaluate::{Timeout, SpawnFailure}` — split off S82's candidate B,
  carried to S84).
- **🟡 Dogfood: stale since S76** — intentionally so (receipt/counter-focused $0 sessions since).
  Refresh = founder-un-parkable MEASURE session, not yet re-picked.
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured (S70).
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70.
- 🟡 `vajra init` template omits `pipeline_advance_check` (precedent) · ledger tamper-EVIDENT not
  PROOF + opt-in · guard nested-repo blindspot · install path · readable-roadmap one-pager (backlog).

## What Is In Progress
- **S82 DONE.** **Next = S83 — warn before a headless run hits the read-only wall** (APPROVED,
  `prompts/83-task-readonly-headless-warning.md`). New chat.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **Session 77: ~$0** · **Session 78: ~$0.055** · **Session 79: ~$0** · **Session 80: ~$0** ·
  **Session 81: ~$0** (bash-only) · **Session 82: ~$0** (no paid API call; cold review used the
  local `general-purpose` subagent, not billed against the Claude Code session budget).
- Cumulative: **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
