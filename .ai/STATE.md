# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S91 complete, S92 not yet started).
S91 = **CODE (B+C)** — fix S89 Reviewer hash mismatch + add `--dogfood-age` live staleness query.
Results: S89 Reviewer PASSED (intermediate-commit attestation fixed); `--dogfood-age` live (git-derived,
never from STATE.md). 283 lib tests. Cold review: see `sessions/session-91-review.md`.

## Active PRs
- Merged: S90 (NO-CODE GT closeout) · S89 [#88](https://github.com/ifelse-codes/vajra/pull/88) ·
  S88 [#87](https://github.com/ifelse-codes/vajra/pull/87) · S87
  [#86](https://github.com/ifelse-codes/vajra/pull/86) · S86
  [#85](https://github.com/ifelse-codes/vajra/pull/85).
- **S91 PR:** TBD (`session-91-fix-attestation-and-dogfood-staleness`).

## Direction (governance is the product — 8 governed stations + durable station counter)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S91 outcome:** S89 Reviewer hash mismatch fixed (B) — `--stations 89` now 6/8. Live
  `--dogfood-age` query added (C) — staleness now git-derived, never read from STATE.md.
  dogfood is 🔴 (14 sessions since S76 / 3 calendar days) but now measurably so.
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood:
  S76 baseline (2026-07-18), now **14 sessions (S77–S90) / 3 calendar days** stale — 🔴,
  founder-un-parkable. ③ compression: never claimed until measured (0 folds). ④ payload counter =
  BUILT (S74) + GT-verified (S75/S80/S85/S90) + hardened (S82).
- **House patterns (carried):** dogfood staleness now derived from git via `--dogfood-age` (S91 C);
  never read STATE.md's date. Easy-green detour: 3rd consecutive GT found same shape (S90 finding).
  Fakest green classes: jurisdiction-self-granted (S69) · hollow-green (S69) · intermediate-commit
  attestation gap (fixed S91B, disclosed residual: `--inputs-sha` post-merge-tip case still ABSENT).

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt is AUTHORITATIVE when `total_cost_usd` exists (S66/S78), HONEST when it
  genuinely doesn't (S77), correctly priced on the interactive estimate (S79), the closeout gate
  blocks unfilled execution shas (S81), the station counter's Releaser dimension is durable across
  branch pruning (S82), `vajra claude -p` warns before a headless run hits the silent read-only wall
  (S83), the QA/Demo-er gates' cannot-evaluate BLOCK names WHICH of two reasons occurred (S84), the
  Reviewer/Releaser attestation check cryptographically verifies the claimed hash instead of
  trusting a bare label (S86), S76's Execution trace is fully recorded (S87), the attestation hash
  is review-time-stable (S88, which also repaired S73 and S79 as a bonus), ROADMAP.md is compact
  and current (S89), **S89 Reviewer PASSED** (intermediate-commit attestation fixed, S91B),
  **`vajra next --dogfood-age`** derives staleness live from git (S91C).
- **`cargo test --lib` 283** (+12 from S91: +1 station B, +11 dogfood C).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.
- **CONSTRAINTS.yaml `required_audits`** — 10 audits (added `dogfood_staleness` in S91).

## What Is Broken / Weak
- **🔴 Dogfood: 14 sessions (S77–S90) / 3 calendar days stale since S76 (2026-07-18).** Now
  measurable via `vajra next --dogfood-age` (git-derived). Still founder-un-parkable; not picked
  through S91 (S91 fixed the measurability gap, not the staleness itself).
- **🟡 S89 Demo-er station ABSENT** — `demo-session-89.sh` exists but does not emit
  `demo:<element>` markers. Docs-only sessions didn't retroactively get the S71 marker contract.
  Low severity (historical); future CODE sessions always get the marker contract.
- **🟡 `--inputs-sha` post-merge-tip edge case still ABSENT** — if a session computed its hash
  AFTER merging to main (tip = the merge commit's p2 = final), no intermediate candidate exists.
  Different root cause from S89's gap; disclosed in session-91-summary.md.
- **🟡 `--dogfood-age` artifact naming is convention-based** — detects by `receipt.stderr.txt`
  or `vajra-receipt.txt` presence; future artifact naming changes would miss paid runs. Disclosed.
- **🟡 ROADMAP consolidation content fidelity not script-verified** — S89 cold review AC5 PARTIAL.
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — kept at historical
  $15/$75 as a conservative estimate (disclosed S79).
- **🟡 The signal-death edge case (`gate_run::code_or_conservative`) has no dedicated automated
  test** — S84 cold review finding, low severity.
- **🟡 A pre-existing (S73) `wait_or_timeout` `Err(_) => None` still classified as
  `CannotEvaluate::Timeout`** — unchanged.
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured.
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70.
- **🟡 `full_historical_scan`'s pass bar is a floor (`verified >= 16`), not a strict zero-regression
  assertion** (S88, low severity).
- **🟡 `candidate_diffs` rescans every merge commit on every single-session query** — cheap today
  (~2s), O(n) scalability note (S86, unchanged).
- 🟡 `vajra init` template omits `pipeline_advance_check` precedent · ledger tamper-EVIDENT not
  PROOF + opt-in · guard nested-repo blindspot · install path.

## What Is In Progress
- **S91 DONE (CODE B+C).** Founder options for S92: TBD. **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **Session 77–91: ~$0 each** (S78 ~$0.055; S91 uses only local Rust cargo/test; rest docs-only,
  bash/Rust-only source fixes, or local-subagent cold reviews).
- Cumulative: **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
