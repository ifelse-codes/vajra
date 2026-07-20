# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S79 complete, S80 not yet started).
S79 = **CODE, re-price the stale static opus rate** (founder pick A). Within ADR-0004, a
compiled-in pricing-value change, no new command: `src/meter/mod.rs` gets specific-before-generic
`MODEL_PRICING` entries for `claude-opus-4-8`/`-4-7`/`-4-6` at the confirmed current rate $5/$25 per
MTok (sourced live from the `claude-api` skill, cached 2026-06-24) ahead of the generic
`claude-opus-4` fallback, which now explicitly means legacy/unconfirmed opus (4.0/4.1/4.5) at the
historical $15/$75 — a recorded granularity decision. `src/cli/estimate.rs`'s `DEFAULT_MODEL` bumped
from the bare `"claude-opus-4"` to `"claude-opus-4-8"` — the actual interactive-path fix, since
`vajra estimate` is the only cost figure an interactive user sees. `UNKNOWN_MODEL_PRICING`'s
numeric value is unchanged ($15/$75) but its rationale corrected (opus is no longer the priciest
tier; Claude Fable 5 is) and reconfirmed `>=` every real rate by a new test. `cargo test --lib`
**258** (+2) · verify 11/11 · demo 4 markers · clippy+fmt clean · cold review ACCEPT (attested
`c6111ba5…`) · live-verified (`vajra estimate` shows `$5/MTok`, not `$15/MTok`). **Spend ~$0**
(compiled-in rate correction, no paid run needed). Closeout on `session-79-stale-opus-reprice`.

## Active PRs
- S79: `session-79-stale-opus-reprice` → `main` (meter re-pricing + estimate fix + ADR updates +
  verify/demo + closeout). Founder call to open/merge.
- Merged: S78 [#76](https://github.com/ifelse-codes/vajra/pull/76) · S77
  [#75](https://github.com/ifelse-codes/vajra/pull/75) · S76
  [#74](https://github.com/ifelse-codes/vajra/pull/74) · S75
  [#73](https://github.com/ifelse-codes/vajra/pull/73).
- **⚠ The Releaser gate is LIVE:** before closing S80 — merge the S79 PR, checkout `main`, pull,
  `git branch -d session-79-stale-opus-reprice`. Skip it and the S80 `--advance` refuses the close.

## Direction (governance is the product — 8 governed stations + a receipt that is authoritative on headless, honest on interactive, and now correctly priced on the interactive estimate)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **The receipt arc S76→S79 is now fully closed (pending S80's independent confirmation):** S76
  measured the pipeline as lived experience and found the receipt the weak station (fable-5 unpriced
  → opus-bound estimate; no `total_cost_usd`). **S77 fixed the LIE** (fable-5 priced; a run with no
  authoritative figure says so plainly). **S78 recovered the TRUTH** — the launcher tees the
  headless `-p` result stream and reads the tool's OWN `total_cost_usd`. **S79 finished the estimate
  path** — current opus prices at $5/$25, not the stale $15/$75, so the interactive-only cost figure
  is now correct too. **S80 (the next mandatory GT) should independently verify this "fully closed"
  claim rather than carry it forward unaudited**, and re-check whether 4 consecutive receipt-focused
  sessions was the shortest path to the north-star.
- **S70 founder decisions (binding until revisited):** ① crew first ✓. ② dogfood: DONE at S76 — but
  **aging**: S77/S78/S79 were all $0 sessions, so by S80 it is 4 sessions / several days since the
  last paid `vajra claude` run. ③ compression: never claimed until measured (S76: 0 folds). ④
  payload counter = BUILT (S74) + GT-verified (S75) — **not read since S75**, per S79's own summary.
- **House patterns (carried):** existence-gate recorded markers (S67/S68) · re-run executable markers
  live (S69) · element-scan live output (S71) · re-derive git-state from refs (S72; limit S75) ·
  bound+kill a live gate run (S73) · a derived metric reuses each gate's classifier (S74) · re-read a
  debt's origin before calling it retired (S75) · a dogfood pins a CURRENT binary + headless needs a
  permission flag (S76) · an honest null beats a confident fake (S77) · capture the tool's OWN
  end-of-session number by tee-inspecting its result stream, never reconstruct it (S78) · **NEW
  (S79): when a generic model-id prefix stops being uniform-rate (a version split happens), audit
  every OTHER caller of that pricing function for a bare/ambiguous default string that will now
  silently fall through to the wrong bucket** — `vajra estimate`'s `DEFAULT_MODEL` was exactly such
  a caller, not caught by the meter's own tests.

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained
  ledger). Receipt is AUTHORITATIVE when a `total_cost_usd` exists — from the transcript (S66) OR
  recovered from a headless run's result stream (S78) — HONEST when it genuinely doesn't (interactive:
  "no authoritative cost available" + a clearly-secondary token estimate, S77), and that token
  estimate is now CORRECTLY PRICED on current opus (S79).
- **Receipt/meter (ADR-0004), S79:** `src/meter/mod.rs` `MODEL_PRICING` — specific-before-generic
  entries for current opus (4-8/4-7/4-6 at $5/$25) ahead of the generic legacy-opus fallback
  (4.0/4.1/4.5 at $15/$75); `UNKNOWN_MODEL_PRICING` = $15/$75, reconfirmed as 1.5x Fable 5 (the
  actual priciest tier), `>=` every real rate. `src/cli/estimate.rs` `DEFAULT_MODEL` =
  `"claude-opus-4-8"`.
- **The payload counter (S74), GT-verified (S75):** `vajra next --stations NN` — derived K-of-8,
  read-only (Releaser dimension decays once refs pruned — S81 candidate A). **Not re-read since
  S75** — S80 should read it across S75→S79.
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th. `cargo
  test --lib` **258 passed** (+2 S79).
- **S79 evidence:** `sessions/session-79-summary.md` + `-review.md` (ACCEPT, attested
  `c6111ba5…`) · `verify-session-79.sh` 11/11 · `demo-session-79.sh` 4 markers · live `vajra
  estimate` before→after.

## What Is Broken / Weak
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** in the cached pricing
  table — kept at the historical $15/$75 as a conservative, non-decreasing estimate, disclosed as
  such (S79). Not a bug; a documented limit.
- **🟡 `--stations` Releaser dimension decays** once branch refs are pruned (S75; S81 candidate A) —
  the GT's own mandatory instrument, and it hasn't been read since S75.
- **🟡 Read-only-headless UX (S76):** `vajra claude -p` with no permission flag is a silently
  read-only agent — nothing surfaces it up front. (S81 candidate B.)
- **🟡 The S73 fakest green persists:** QA's streamed path collapses timeout + spawn-failure into one
  untyped `None` (`CannotEvaluate::{Timeout, SpawnFailure}` = S81 candidate B, bundled).
- **🟡 Dogfood is aging again:** last paid `vajra claude` run was S76; S77/S78/S79 all ~$0. By S80
  this is 4 sessions / several days — the same drift pattern S60 and S75 both caught, recurring.
- **🟡 Four consecutive sessions (S76-S79) worked the SAME station (the receipt)** — `--stations`
  unread since S75 means no evidence yet on whether the other 7 stations advanced or stalled.
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured (S70).
- **🟡 The self-granted-jurisdiction / can-drift class stays EIGHT+ gates wide** (all disclosed).
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70.
- 🟡 `vajra init` template omits `pipeline_advance_check` (precedent) · ledger tamper-EVIDENT not
  PROOF + opt-in · guard nested-repo blindspot · install path · readable-roadmap one-pager
  (backlog, S81 candidate C).

## What Is In Progress
- **S79 DONE (CODE, ACCEPT), closeout committed.** **Next = S80 — the mandatory NO-CODE ground
  truth** (`prompts/80-task-ground-truth.md`, APPROVED). New chat for S80. **S81 resumes CODE** from
  S80's ranked candidates (standing: A `--stations` durability · B read-only-headless UX + typed
  `CannotEvaluate` · C readable-roadmap one-pager).

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN in dollars** (fable-5 unpriced;
  opus-estimate ≤ ~$26.6, true cost lower). **Session 77: ~$0** (reused S76 fixtures). **Session 78:
  ~$0.055** (two cheap haiku `-p` smoke runs). **Session 79: ~$0** (compiled-in rate correction, no
  paid run).
- Cumulative: **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
