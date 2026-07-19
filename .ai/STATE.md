# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S77 complete, S78 not yet started).
S77 = **CODE, receipt truth on real runs** (founder pick A). Within ADR-0004: added `claude-fable-5` to
`meter::MODEL_PRICING` at real sourced rates ($10/$50) and changed the receipt so that when no
authoritative `total_cost_usd` exists the headline says "no authoritative cost available" instead of
dressing an opus-priced token estimate up as a `$… total`. Root cause recorded. Regression test on a real
S76-captured fixture. `cargo test --lib` 249 · verify 11/11 · demo 4/4 · cold review ACCEPT (attested
`a756c9db…`). $0 spent (reused S76 fixtures). Closeout on `session-77-receipt-truth`.

## Active PRs
- S77: `session-77-receipt-truth` → `main` (meter/receipt fix + real fixture + verify/demo + closeout).
  Founder call to open/merge.
- Merged: S76 [#74](https://github.com/ifelse-codes/vajra/pull/74) · S75
  [#73](https://github.com/ifelse-codes/vajra/pull/73) · S74
  [#72](https://github.com/ifelse-codes/vajra/pull/72) · S73
  [#71](https://github.com/ifelse-codes/vajra/pull/71).
- **⚠ The Releaser gate is LIVE:** before closing S78 — merge the S77 PR, checkout `main`, pull,
  `git branch -d session-77-receipt-truth`. Skip it and the S78 `--advance` refuses the close.

## Direction (governance is the product — 8 governed stations + a receipt that now tells $ truth or admits it can't)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S76 measured the pipeline as lived experience and found the receipt was the weak station** on real
  runs (fable-5 unpriced → opus-bound estimate; no `total_cost_usd`). **S77 fixed the LIE:** fable-5 is
  priced at real rates, and a run with no authoritative figure now says so plainly instead of printing a
  misleading total. **What S77 did NOT do — and S78 will — is recover the TRUE figure** (the on-disk
  transcript genuinely carries none; the truth lives on the headless `-p` result stream, which vajra
  doesn't yet capture).
- **S70 founder decisions (binding until revisited):** ① crew first ✓. ② dogfood: DONE at S76. ③
  compression: never claimed until measured (S76: 0 folds). ④ payload counter = BUILT (S74) + GT-verified
  (S75).
- **House patterns (carried):** existence-gate recorded markers (S67/S68) · re-run executable markers live
  (S69) · element-scan live output (S71) · re-derive git-state from refs (S72; limit S75) · bound+kill a
  live gate run (S73) · a derived metric reuses each gate's classifier (S74) · re-read a debt's origin
  before calling it retired (S75) · a dogfood pins a CURRENT binary + headless needs a permission flag
  (S76). **NEW (S77): when the tool's own record can't tell $ truth, the receipt says so — an honest null
  beats a confident fake; and the fix for a wrong number is to READ the tool's own figure, not to grow
  Vajra's price list (founder direction, S78 = do exactly that).**

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained
  ledger). Receipt is AUTHORITATIVE when a `total_cost_usd` exists (S66) and **HONEST when it doesn't**
  (S77): "no authoritative cost available" + a clearly-secondary, real-rate token estimate.
- **Receipt/meter (ADR-0004), S77:** `meter::MODEL_PRICING` now prices `claude-fable-5` ($10/$50, real
  sourced rates); an unpriced model still flags the opus-upper-bound fallback (tested with
  `claude-mythos-5`); no-authoritative headline is honest, never a fake total. `vajra meter <jsonl>`
  demonstrates it live on the real S76 fixture.
- **The payload counter (S74), GT-verified (S75):** `vajra next --stations NN` — derived K-of-8, read-only.
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th. `cargo test
  --lib` **249 passed** (+1: the S77 real-data regression). Enforcement moat + Darshan + Varta hold live
  (the co-pilot loader fired + blocked a real commit during THIS closeout — dogfood-in-dogfood).
- **S77 evidence:** `sessions/session-76-artifacts/fixtures/s76-fable-headless.jsonl` (committed real-data
  slice) · `verify-session-77.sh` 11/11 · `demo-session-77.sh` 4 markers · review ACCEPT attested
  `a756c9db…`.

## What Is Broken / Weak
- **🔴→🟡 The receipt still has no TRUE $ for headless/fable runs** — S77 made it HONEST (says "no
  authoritative cost available") but did not RECOVER the figure. The on-disk transcript carries none; the
  truth is on the `-p` result stream, uncaptured. **→ S78 (founder pick A) captures it.**
- **🟡 NEW debt (S77): the static `claude-opus-4` rate is stale** — $15/$75 (opus-4.0/4.1 era) while
  opus-4-8 is $5/$25, so the meter now *overstates* opus runs ~3×. Out of S77's one-story scope; a
  separate receipt-accuracy pass (standing S79 candidate).
- **🟡 Read-only-headless UX (S76):** `vajra claude -p` with no permission flag is a silently read-only
  agent — nothing surfaces it up front. (Standing S79 candidate B.)
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured (S70).
- **🟡 The self-granted-jurisdiction / can-drift class stays EIGHT+ gates wide** (all disclosed).
- **🟡 The S73 fakest green persists:** QA's streamed path collapses timeout + spawn-failure into one
  untyped `None` (`CannotEvaluate::{Timeout, SpawnFailure}` = standing S79 candidate B).
- **🟡 `--stations` Releaser dimension decays** once branch refs are pruned (S75; candidate C).
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70.
- 🟡 `vajra init` template omits `pipeline_advance_check` (precedent) · ledger tamper-EVIDENT not PROOF +
  opt-in · guard nested-repo blindspot · install path · readable-roadmap one-pager (backlog).

## What Is In Progress
- **S77 DONE (CODE, ACCEPT), closeout committed.** **Next = S78 — CODE, recover the true $** (founder
  pick A; `prompts/78-task-recover-true-cost.md`, APPROVED). New chat for S78. **S80 = the next NO-CODE GT.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN in dollars** (fable-5 unpriced; opus-estimate
  ≤ ~$26.6, true cost lower — the debt S77 addressed for the *estimate*, S78 will *recover*). **Session
  77: ~$0** (no paid runs — reused S76 fixtures; the fable-priced re-estimate of the S76 run1 transcript
  is ~$9.59, a token estimate, not a bill).
- Cumulative: **~$73.6 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
