# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S76 complete, S77 not yet started).
S76 = the founder-led **paid dogfood ride-along** (MEASURE). Two headless `vajra claude` runs on chitra's
real S07 CI task: run 1 read-only wall, run 2 (`--dangerously-skip-permissions`) delivered a green CI
workflow. Governance held; cost readout was a null-with-cause. Report + verify(14/14) + demo + attested
cold review (ACCEPT). No `src/` change. Closeout on `session-76-dogfood-ride-along`.

## Active PRs
- S76: `session-76-dogfood-ride-along` → `main` (dogfood report + artifacts + verify/demo + closeout).
  Founder call to open/merge.
- Merged: S75 [#73](https://github.com/ifelse-codes/vajra/pull/73) · S74
  [#72](https://github.com/ifelse-codes/vajra/pull/72) · S73
  [#71](https://github.com/ifelse-codes/vajra/pull/71) · S72
  [#70](https://github.com/ifelse-codes/vajra/pull/70).
- **⚠ The Releaser gate is LIVE:** after merging the S76 PR — checkout `main`, pull,
  `git branch -d session-76-dogfood-ride-along`. Skip it and the S77 `--advance` refuses the close.

## Direction (governance is the product — 8 governed stations, now MEASURED AS EXPERIENCE)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S76 measured the pipeline as LIVED EXPERIENCE (first paid run since S63, 12 sessions).** The headline:
  **governance is real and voluntary** — run 2 bypassed every permission hook (`--dangerously-skip-
  permissions`) yet the governed instance branched instead of working on main, **refused to auto-commit
  "per CONSTRAINTS"** (chitra doesn't even wire the no-commit hook), and held the 2-assumption cap.
  Fidelity was real: an independent re-run of the delivered `verify-session-07.sh` = 13/13 GREEN.
- **The weak station is the RECEIPT on real runs (S76 finding, 🔴):** both runs ran on `claude-fable-5`
  (unpriced → opus-upper-bound estimate) with **no `total_cost_usd`** in the JSONL (0 `type:result`, a
  regression vs S63) → **no truthful dollar figure was obtainable.** S66's authoritative-vs-estimate
  labeling worked as a *fallback*; its happy path never fired. This is exactly what **S77 (pick A)** fixes.
- **S70 founder decisions (binding until revisited):** ① crew first ✓. ② dogfood: **DONE at S76** (founder
  drove, agent measured). ③ compression: **never claimed until measured** — S76 re-measured **0 folds**
  (unchanged). ④ payload counter = BUILT (S74) + GT-verified (S75).
- **House patterns (carried):** existence-gate recorded markers (S67/S68) · re-run executable markers live
  (S69) · element-scan live output (S71) · re-derive git-state from refs (S72; limit S75) · bound+kill a
  live gate run (S73) · a derived metric reuses each gate's classifier (S74) · re-read a debt's origin
  before calling it retired (S75). **NEW (S76): a dogfood must pin a CURRENT binary** (the installed
  `~/.cargo/bin/vajra` was 16 days / 5 stations stale) **and headless needs a permission flag to do work.**

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained
  ledger). Receipt AUTHORITATIVE for headless runs *that carry `total_cost_usd`* (S66) — but S76 found
  real headless runs here carry none (see 🔴 below).
- **The payload counter (S74), GT-verified (S75):** `vajra next --stations NN` — derived K-of-8, read-only.
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th. `cargo test
  --lib` **248 passed** (unchanged — MEASURE session, no `src/` change). Enforcement moat + Darshan + Varta
  hold live (the co-pilot loader fired + blocked a real commit during THIS closeout — dogfood-in-dogfood).
- **S76 dogfood evidence:** `sessions/session-76-dogfood.md` + `sessions/session-76-artifacts/` (curated:
  harness, task, checklist, 2 receipts; raw 285KB transcripts kept local, gitignored). `verify-session-
  76.sh` 14/14 · `demo-session-76.sh` 4 markers · cold review ACCEPT attested `4b87434c…`.

## What Is Broken / Weak
- **🔴 The receipt cannot tell $ truth on real runs (S76, → S77 pick A):** (1) `claude-fable-5` is unpriced
  → estimate uses the opus upper bound (overstates $14.39/$12.18); (2) headless CC (2.1.183, possibly
  nested) emits no `total_cost_usd` → no authoritative fallback. Together = no truthful dollar figure.
- **🟡 Read-only-headless UX (S76):** `vajra claude -p` with no permission flag is a silently read-only
  agent — a real user doing headless work hits the wall; nothing surfaces it up front. (S77 candidate B.)
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured (S70). S76
  re-measured 0 on the 8-station pipeline.
- **🟡 The self-granted-jurisdiction / can-drift class stays EIGHT+ gates wide** (all disclosed).
- **🟡 The S73 fakest green persists:** QA's streamed path collapses timeout + spawn-failure into one
  untyped `None` (`CannotEvaluate::{Timeout, SpawnFailure}` = S77 candidate B).
- **🟡 `--stations` Releaser dimension decays** once branch refs are pruned (S75; candidate C).
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70.
- 🟡 `vajra init` template omits `pipeline_advance_check` (precedent) · Releaser/Demo-er/QA minors ·
  unknown-model estimate = opus upper bound (fable-5) · ledger tamper-EVIDENT not PROOF + opt-in ·
  guard nested-repo blindspot · install path · readable-roadmap one-pager (backlog, low-priority).

## What Is In Progress
- **S76 DONE (paid MEASURE, ACCEPT), closeout committed.** **Next = S77 — CODE, receipt truth** (founder
  pick A; `prompts/77-task-receipt-truth.md`, APPROVED). New chat for S77. **S80 = the next NO-CODE GT.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN in dollars** — model was fable-5 (unpriced);
  the opus-upper-bound estimate summed ~$26.6 across the two runs, true cost lower (the S77 debt).
- Cumulative: **~$73.6 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
