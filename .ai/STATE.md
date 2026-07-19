# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S78 complete, S79 not yet started).
S78 = **CODE, recover the true $** (founder pick A). Within ADR-0004, no new command: the launcher
now captures the coding tool's OWN end-of-session cost on headless runs. `src/cli/launch.rs`
`is_headless(args)` gates a byte-level tee (headless pipes stdout, streams every byte through
untouched + keeps a copy; interactive keeps an inherited TTY, unchanged); `src/meter/mod.rs`
`extract_result_cost` reads `total_cost_usd` from the terminal `type:"result"` line;
`SessionCost::apply_captured_cost` promotes it to S66's `authoritative_dollars` (fill-only). A
headless run's receipt headline is now a real `$… total` (live smoke: `$0.0277`) where S77 could
only say "no authoritative cost available"; interactive stays honestly null. `cargo test --lib`
**256** (+7) · verify 15/15 · demo 4 markers · clippy+fmt clean · cold review ACCEPT (attested
`daabaa7a…`) · live end-to-end verified. **Spend ~$0.055** (two cheap haiku smoke runs). Closeout on
`session-78-recover-true-cost`.

## Active PRs
- S78: `session-78-recover-true-cost` → `main` (launcher capture path + meter functions + real
  fixture + live evidence + verify/demo + closeout). Founder call to open/merge.
- Merged: S77 [#75](https://github.com/ifelse-codes/vajra/pull/75) · S76
  [#74](https://github.com/ifelse-codes/vajra/pull/74) · S75
  [#73](https://github.com/ifelse-codes/vajra/pull/73) · S74
  [#72](https://github.com/ifelse-codes/vajra/pull/72).
- **⚠ The Releaser gate is LIVE:** before closing S79 — merge the S78 PR, checkout `main`, pull,
  `git branch -d session-78-recover-true-cost`. Skip it and the S79 `--advance` refuses the close.
  (S77's PR #75 was already merged + its branch pruned at S78 start, so S78's own Releaser gate was
  pre-satisfied.)

## Direction (governance is the product — 8 governed stations + a receipt that RECOVERS the true $ on headless / stays honestly null on interactive)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **The receipt arc is closed for headless:** S76 measured the pipeline as lived experience and
  found the receipt the weak station (fable-5 unpriced → opus-bound estimate; no `total_cost_usd`).
  **S77 fixed the LIE** (fable-5 priced; a run with no authoritative figure says so plainly).
  **S78 recovered the TRUTH** — the launcher tees the headless `-p` result stream and reads the
  tool's OWN `total_cost_usd` into the S66 authoritative path. What remains: interactive runs still
  rely on the token *estimate*, and that estimate's static opus rate is stale (S79 candidate A).
- **S70 founder decisions (binding until revisited):** ① crew first ✓. ② dogfood: DONE at S76. ③
  compression: never claimed until measured (S76: 0 folds). ④ payload counter = BUILT (S74) +
  GT-verified (S75).
- **House patterns (carried):** existence-gate recorded markers (S67/S68) · re-run executable markers
  live (S69) · element-scan live output (S71) · re-derive git-state from refs (S72; limit S75) ·
  bound+kill a live gate run (S73) · a derived metric reuses each gate's classifier (S74) · re-read a
  debt's origin before calling it retired (S75) · a dogfood pins a CURRENT binary + headless needs a
  permission flag (S76) · an honest null beats a confident fake (S77) · **NEW (S78): capture the
  tool's OWN end-of-session number by tee-inspecting its result stream byte-for-byte — never
  reconstruct it, never grow Vajra's price list; pipe only stdout (stdin/stderr inherited) so the tee
  can't deadlock.**

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained
  ledger). Receipt is AUTHORITATIVE when a `total_cost_usd` exists — from the transcript (S66) OR
  now **recovered from a headless run's result stream (S78)** — and HONEST when it genuinely doesn't
  (interactive: "no authoritative cost available" + a clearly-secondary token estimate, S77).
- **Receipt/meter (ADR-0004), S78:** `src/cli/launch.rs` tees headless `-p` stdout byte-for-byte
  (`is_headless` + `tee_and_capture`) and feeds the result line's cost via
  `meter::extract_result_cost` + `SessionCost::apply_captured_cost`. `meter::MODEL_PRICING` prices
  `claude-fable-5` at real rates (S77); an unpriced model still flags the opus-upper-bound fallback.
- **The payload counter (S74), GT-verified (S75):** `vajra next --stations NN` — derived K-of-8,
  read-only (Releaser dimension decays once refs pruned — S79 candidate B).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th. `cargo
  test --lib` **256 passed** (+7 S78). Enforcement moat + Darshan + Varta hold live (the co-pilot
  loader fired + blocked a commit during THIS closeout — dogfood-in-dogfood).
- **S78 evidence:** `sessions/session-78-artifacts/fixtures/s78-headless-result-stream.txt` (real
  captured stream) · `live-receipt.stderr.txt` (`$0.0277 total`) · `live-result-line.txt` (untouched
  passthrough) · `verify-session-78.sh` 15/15 · `demo-session-78.sh` 4 markers · review ACCEPT
  attested `daabaa7a…`.

## What Is Broken / Weak
- **🟡 The static `claude-opus-4` rate is stale** — $15/$75 (opus-4.0/4.1 era) while opus-4-8 is
  $5/$25, so the token *estimate* overstates opus runs ~3×. S78 recovered the AUTHORITATIVE figure
  for headless, but interactive runs still show the estimate. **→ S79 candidate A.**
- **🟡 `--stations` Releaser dimension decays** once branch refs are pruned (S75; S79 candidate B) —
  the GT's own mandatory instrument, relevant right before S80.
- **🟡 Read-only-headless UX (S76):** `vajra claude -p` with no permission flag is a silently
  read-only agent — nothing surfaces it up front. (S79 candidate C, bundled with the typed null.)
- **🟡 The S73 fakest green persists:** QA's streamed path collapses timeout + spawn-failure into one
  untyped `None` (`CannotEvaluate::{Timeout, SpawnFailure}` = S79 candidate C).
- **🟡 Headless capture buffers the whole stdout in RAM** for the scan (bounded by output size; the
  tee streams through regardless — a memory note, not a correctness one).
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured (S70).
- **🟡 The self-granted-jurisdiction / can-drift class stays EIGHT+ gates wide** (all disclosed).
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70;
  now includes reading Codex/Grok's own end-of-session cost (the S78 pattern, other tools).
- 🟡 `vajra init` template omits `pipeline_advance_check` (precedent) · ledger tamper-EVIDENT not
  PROOF + opt-in · guard nested-repo blindspot · install path · readable-roadmap one-pager (backlog).

## What Is In Progress
- **S78 DONE (CODE, ACCEPT), closeout committed.** **Next = S79 — CODE, founder pick pending** from 3
  ranked candidates (A stale-opus re-pricing [rec] · B `--stations` durability · C read-only-headless
  UX + typed nulls). New chat for S79. **S80 = the next NO-CODE GT.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN in dollars** (fable-5 unpriced;
  opus-estimate ≤ ~$26.6, true cost lower). **Session 77: ~$0** (reused S76 fixtures). **Session 78:
  ~$0.055** (two cheap haiku `-p` smoke runs to capture + live-verify one real result line; the live
  run's authoritative receipt read `$0.0277`).
- Cumulative: **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
