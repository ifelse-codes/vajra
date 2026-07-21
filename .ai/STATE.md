# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S89 complete, S90 not yet started).
S89 = **CODE (docs-only)** — full ROADMAP consolidation (710→219 lines, 69% reduction) + fixed
stale "Where We Are" table (27 sessions stale since S60). Founder expanded scope at session start
from "fix the table" to a full cleanup. Independent cold review: **ACCEPT** (4 SHIPPED, 1
PARTIAL/disclosed — AC5 content-accuracy not script-verified). Report: `sessions/session-89-review.md`.

## Active PRs
- Merged: S88 [#87](https://github.com/ifelse-codes/vajra/pull/87) · S87
  [#86](https://github.com/ifelse-codes/vajra/pull/86) · S86
  [#85](https://github.com/ifelse-codes/vajra/pull/85) · S85 (docs-only GT closeout,
  `session-85-closeout`) · S84 [#83](https://github.com/ifelse-codes/vajra/pull/83).
- **S89 PR:** TBD (`session-89-fix-roadmap-stale-table`) — 2 commits (ROADMAP + prompt; verify +
  demo scripts).

## Direction (governance is the product — 8 governed stations + durable station counter)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S89 consolidated the ROADMAP** — 710 lines of dense per-session prose replaced with compact
  tables. The "Where We Are" table now correctly reflects: 2026-07-21, 8-station pipeline + S86–S88
  attestation-hardening arc, last=S88, active="None — between sessions". Rule 5 added: per-session
  detail belongs in `sessions/session-NN-summary.md`, not in ROADMAP.md.
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood: S76
  baseline, now **12 sessions (S77–S89) / 19+ calendar days** stale (2026-07-03 → 2026-07-21) — 🔴,
  founder-un-parkable, not re-picked through S89. ③ compression: never claimed until measured (0
  folds). ④ payload counter = BUILT (S74) + GT-verified (S75/S80/S85) + hardened (S82).
- **House patterns (carried):** a raw K-of-8 reading cannot distinguish "counter got more accurate"
  from "pipeline stalled" — read the shape, not just the digit (S85). A "recompute and compare" fix
  must be tested against real historical data the old bug actually failed on (S86). A fix to a
  historical record can retroactively break a different governance mechanism that depends on that
  record's bytes staying stable — check downstream dependents (S87). A session's own proof fixture
  can be hollow for a reason unrelated to the fix under test — verify a test fails without the fix
  by actually reverting and re-running (S88). **NEW (S89): a 710→219 line consolidation's content
  accuracy is not script-verifiable — the green is structural, not semantic.**

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
- **`cargo test --lib` 271** (unchanged — docs-only session).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.

## What Is Broken / Weak
- **🔴 Dogfood: stale since S76 — now 12 sessions (S77–S89) / 19+ calendar days.** Escalated 🟡→🔴
  at S85, still not re-picked through S89. Refresh = founder-un-parkable MEASURE session. S90 GT
  is next — this is near-certain to be its top finding.
- **🟡 ROADMAP consolidation content fidelity not script-verified** — S89 cold review AC5 PARTIAL.
  The session-log table entries sourced from reading the old ROADMAP; not row-by-row cross-checked
  against `sessions/session-NN-summary.md`. Low severity, reference content.
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
- **S89 DONE (CODE docs-only).** Founder picked **S90 = mandatory NO-CODE ground truth**
  (`90 % 5 == 0`). Lead lens: dogfood 🔴 (12+ sessions stale). `prompts/90-task-ground-truth.md`
  written and approved. **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **Session 77–89: ~$0 each** (S78 ~$0.055; the rest docs-only, bash/Rust-only source fixes, or
  local-subagent cold reviews).
- Cumulative: **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
