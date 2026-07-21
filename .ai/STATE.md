# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S90 complete, S91 not yet started).
S90 = **NO-CODE Ground Truth** (`90 % 5 == 0`). 9 required audits run. Key findings:
(1) STATE.md date error: "19+ days since S76 (2026-07-03)" cited S36's date — S76 was 2026-07-18;
actual staleness = 13 sessions / 2–3 calendar days. (2) S89 station check = 5/8: Demo-er missing
`demo:<element>` markers + Reviewer hash mismatch (docs-only diff unverifiable by
`canonical_inputs_sha`). (3) Easy-green detour, 3rd consecutive GT finding this shape. Full
report: `sessions/session-90-ground-truth.md`.

## Active PRs
- Merged: S89 [#88](https://github.com/ifelse-codes/vajra/pull/88) · S88
  [#87](https://github.com/ifelse-codes/vajra/pull/87) · S87
  [#86](https://github.com/ifelse-codes/vajra/pull/86) · S86
  [#85](https://github.com/ifelse-codes/vajra/pull/85) · S85 (docs-only GT closeout,
  `session-85-closeout`).
- **S90 PR:** TBD (`session-90-closeout`) — docs-only GT closeout.

## Direction (governance is the product — 8 governed stations + durable station counter)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S90 GT verdicts:** vision/roadmap/constraints/constitution 🟡🟢 · state_drift 🔴 (date error
  fixed in this STATE.md) · dogfood 🔴 (13 sessions / 2–3 days since S76 = 2026-07-18) ·
  pipeline 🟡 (S89 = 5/8; S86–S88 = 7/8).
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood:
  S76 baseline (2026-07-18), now **13 sessions (S77–S89) / 2–3 calendar days** stale — 🔴,
  founder-un-parkable, not re-picked through S90. ③ compression: never claimed until measured
  (0 folds). ④ payload counter = BUILT (S74) + GT-verified (S75/S80/S85/S90) + hardened (S82).
- **House patterns (carried):** a 710→219 line consolidation's content accuracy is not
  script-verifiable — the green is structural, not semantic (S89). Dogfood staleness must be
  computed from git/receipts, not read from STATE.md — the "19+ days" date error survived 3 GTs
  (S90 meta-check finding). Easy-green detour: 3rd consecutive GT flagging the same shape (S80,
  S85, S90).

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
  is review-time-stable (S88, which also repaired S73 and S79 as a bonus). ROADMAP.md is now
  compact and current (S89).
- **`cargo test --lib` 271** (unchanged — NO-CODE GT session).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.

## What Is Broken / Weak
- **🔴 Dogfood: 13 sessions (S77–S89) / 2–3 calendar days stale since S76 (2026-07-18).** The
  previous "19+ calendar days since S76 (2026-07-03)" was a date error — S36's date (2026-07-03)
  was cited instead of S76's actual date. Staleness by session count (13) was correct. Still
  founder-un-parkable; not picked through S90.
- **🔴 S89 Reviewer station ABSENT** — `--stations 89` shows Reviewer ABSENT (hash mismatch):
  docs-only sessions produce a `Review-Inputs-SHA` that `canonical_inputs_sha` cannot reconstruct.
  Breaks the ledger chain at S89. S91 fixes this (B).
- **🟡 S89 Demo-er station ABSENT** — `demo-session-89.sh` exists but does not emit
  `demo:<element>` markers. The script exits 0 but the element scan fails. Docs-only sessions
  didn't retroactively get the S71 marker contract applied.
- **🟡 No live dogfood-staleness query** — STATE.md's date was wrong for 3+ GTs because staleness
  was read from docs, not computed. S91 adds `--dogfood-age` (C).
- **🟡 ROADMAP consolidation content fidelity not script-verified** — S89 cold review AC5 PARTIAL.
  Low severity, reference content.
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — kept at historical
  $15/$75 as a conservative estimate (disclosed S79).
- **🟡 The signal-death edge case (`gate_run::code_or_conservative`) has no dedicated automated
  test** — S84 cold review finding, low severity.
- **🟡 A pre-existing (S73) `wait_or_timeout` `Err(_) => None` still classified as
  `CannotEvaluate::Timeout`** — unchanged.
- **🟡 S83's verify-script check `ac5-advisory-exit-code-untouched` is a near-tautology** against
  the $0 stub `claude` binary (disclosed S83).
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured.
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70.
- **🟡 (S86, unchanged) `read_prompt` picks the FIRST prompt file on multiple matches** — bash fails
  closed on 0 or >1 matches; rare divergence.
- **🟡 (S86, unchanged) No dedicated test for the "still on the open, not-yet-merged branch" live
  candidate path of `attested_hash_outcome`.**
- **🟡 (S86, unchanged) `candidate_diffs` rescans every merge commit on every single-session query**
  — cheap today (~2s), scalability note.
- **🟡 (S88, low severity) `full_historical_scan`'s pass bar is a floor (`verified >= 16`), not a
  strict zero-regression assertion.**
- **🟡 (S86, unchanged) bash's `canonical_inputs_sha`/`--attest-only <N>` is single-candidate only**
  — can't re-verify arbitrary historical sessions; Rust side (`--stations`) is the correct path.
- 🟡 `vajra init` template omits `pipeline_advance_check` (precedent) · ledger tamper-EVIDENT not
  PROOF + opt-in · guard nested-repo blindspot · install path.

## What Is In Progress
- **S90 DONE (NO-CODE GT).** Founder picked **S91 = B+C** (fix S89 Reviewer hash mismatch +
  add live dogfood-staleness query). `prompts/91-task-fix-attestation-and-dogfood-staleness.md`
  written and approved. **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **Session 77–90: ~$0 each** (S78 ~$0.055; the rest docs-only, bash/Rust-only source fixes, or
  local-subagent cold reviews).
- Cumulative: **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
