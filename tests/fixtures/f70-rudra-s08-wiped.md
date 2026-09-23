<!-- S176 F70 fixture: rudra prompts/08-task-leakage-guard.md at 2476f24 with ## Deliverables through
     ## Assumptions removed — the shape rudra S08's agent produced by its own edit, mid-session. -->
# Session 08 — M3 Phase-6 depth: the as-of-T machine leakage guard (LEAKAGE_GREEN)

> **Status:** ACTIVE — intake authored at S07 closeout from the founder's pick (S07 summary candidate 2:
> Phase-6 depth — the as-of-T leakage guard). Branch `session-08-<slug>` off `main`. Third M3 CODE slice —
> returns to Phase-6 to close the gap S06 left `attested-not-built` before Phase-8 builds on top of it.
> **Design / Plan / Advice are authored in-session by the required advisors** (tech-lead dispatches first).
> This intake fixes Goal · Deliverables · Acceptance · Guardrails · Delta · Assumptions. **No new milestone
> ADR needed** — ADR-011:31 already names "the as-of-T machine leakage guard" as remaining Phase-6 depth.

## Type
- **CODE.** Max 2 assumptions · 2 retries · ~2h · **1 story** · new chat · approval token before any commit
  (`VAJRA_ALLOW_COMMIT=08`). The one story: **the `research` crate enforces point-in-time discipline by
  machine** — a feature computed as-of T can only read events with market-event time ≤ T, and a feature that
  peeks at a future event is REFUSED — proven by one falsifiable proof, `LEAKAGE_GREEN`. Only the as-of-T
  future-read check is in scope; the rest of the RESEARCH.md:63 checklist is OUT (later cuts).

## Goal
S06 built a feature that carries an `as_of_nanos` cutoff (`crates/research/src/experiment.rs:22-25`) and
filters by it, but the no-future-leak rule (RESEARCH Invariant 1, `docs/RESEARCH.md:125`; point-in-time
discipline `:52`) is only **attested**: `research::LEAKAGE_ASOF_T = "attested-not-built"`
(`crates/research/src/repro.rs:18`). Nothing stops a feature from reading a future event, and S07's SIM
verdict inherits that trust. Session 08 turns the attestation into a machine guard:
- **A point-in-time read boundary** — features read events only through an as-of-T boundary that the guard
  can check (the design-advisor chooses the mechanism: a structural as-of view, an audited read trail, or
  both). "Market-event time" and the handling of events without an exchange timestamp are decided in
  `## Design` and recorded, never left implicit.
- **A leakage guard** — before a feature result is accepted into an experiment run, the guard checks that
  every event it read is ≤ T; a violation is REFUSED with a typed error naming the offending event, never a
  warning (`RESEARCH.md:52`: "fails validation automatically where checkable").
- **`LEAKAGE_GREEN` — one proof, falsifiable.** *Positive arm:* the shipped S06 feature passes the guard
  over the pinned dataset, and REPRODUCE_GREEN's anchor `4409d40c6865f5e6` is unchanged (the shipped feature
  was already point-in-time). *Falsifiability arm:* an injected future-peek feature (reads at least one event
  with time > T) is REFUSED; removing or stubbing the guard must turn `LEAKAGE_GREEN` RED. A future-peek that
  still produces an accepted run is the fakest-green defect.

The guard lives in `research` (Research signs methodological validity — `RESEARCH.md:87`). `sim` and the
S07 verdict consume research as-shipped and must stay green. Single process, pinned seeds, dev-grade
synthetic data.

## Design
`design-significant: yes` — **slice-level, NOT milestone-defining.** New public `research` surface
(`AsOfView` / `ReadRecord` / `AsOfFeature` / `check_reads` / `Experiment::run_guarded` + two `ResearchError`
variants) replacing an attested invariant with a machine one. Design record:
`docs/ADR/ADR-011-milestone-m3-scope.md:31` (this depth is named) and `:81` (the exclusion this session
discharges) — no new ADR, no deviation from ADR-011; one crate, no new dependency edge, `common-events`
as-shipped. **Declared partial coverage** of LOCKED `docs/RESEARCH.md:52` (no latency/staleness bounds) and
`:63` (1 of 6 checklist items built). `AsOfFeature` is a v0 dev-grade interface; the later feature-registry
cut (ADR-011:31) should ADR it before Phase-8 relies on it. Authored in-session from the design-advisor
handoff; every cited line verified against live source.

1. **Read boundary = structural as-of view + audited read trail, ONE decision point.** New
   `crates/research/src/leakage.rs`: `AsOfView` (private fields, `pub(crate) new`). Features get
   `&mut AsOfView`, never `&PinnedDataset`. `admissible()` = the structural read (exchange time `Some(t)`,
   `t <= T`, dataset order — the same predicate as S06's `experiment.rs:43-45`); `at(idx)` = addressed read
   over the FULL range, unfiltered (the channel a real feature leaks through). Both log every event handed
   out to a `ReadRecord` trail. The view never refuses; `check_reads(trail, T)` is the single decision
   point, refusing the first offending read in trail order. A peek really performs its future read at
   runtime and is refused at acceptance → stubbing the guard turns `LEAKAGE_GREEN` RED. *Rejected:*
   structural-only (refusal unreachable → falsifiability = "does not compile"); refusing inside the view (two
   decision points; a `None` is a warning in disguise); a trail over the raw dataset (the shipped scan would
   be refused).
2. **Injection seam — additive.** `trait AsOfFeature { version, as_of_nanos, compute_as_of(&mut AsOfView) ->
   Vec<i64> }`; the unchanged `Feature` implements it with the S06 arithmetic; the entry point stamps
   `FeatureVector { version, as_of_nanos }` itself. `Experiment::run_guarded` → view → compute →
   `check_reads` → only on `Ok` build lineage + `metric_hash`. Core `pub(crate) run_with_guard(.., guard)` so
   the in-crate load-bearing test can stub it; external callers cannot bypass. `Experiment::run` keeps its
   infallible signature and routes through the guard fail-closed, so SIM's replay is guarded and `sim`
   compiles with zero edits. The peek feature is test-only. *Rejected:* `run -> Result` or a new `Feature`
   field (breaks `sim` — STOP).
3. **Market-event time** = `exchange_timestamp.nanos()` (`Clock::Exchange`), inclusive `<= T`. Events with
   no exchange timestamp are never admissible; an addressed read of one is refused as un-datable. No
   `receive_timestamp` fallback (a latency bound — out of scope). Anchor-neutral: the shipped feature never
   reads them and the pinned generator always sets `Some` (`dataset.rs:62`).
4. **Typed refusal** — `ResearchError::FutureRead { event_id, market_time_nanos, as_of_nanos }` /
   `UndatableRead { event_id, as_of_nanos }`, returned before lineage/metric exist: no `ExperimentRun`, no
   metric hash. `sim` never matches on `ResearchError` → additive.
5. **Anchors.** `4409d40c6865f5e6` holds (identical predicate/order/arithmetic → identical `FeatureVector`;
   `environment_record()` untouched; no guard marker in lineage/metric). `0ef48bb6ced7cc01` holds (the
   verdict hashes no leakage field). `LEAKAGE_ASOF_T` → `"built-in-process"`; `reproduce_green.rs:82`
   updated, not deleted. `LEAKAGE_GREEN.json` records `attested-not-built` by name:
   `no_future_reference_joins` (reference-version as-of joins; event reads ARE guarded),
   `per_fold_normalization`, `out_of_fold_target_encoding`, `no_session_close_for_intraday`,
   `point_in_time_universe`, `staleness_bounds`. **Known supersession:** `scripts/verify-session-06.sh:75` /
   `scripts/demo-session-06.sh:80` assert the old value — historical S06 artifacts, not edited; recorded.
6. **Non-vacuous finite T.** `synthetic(42,1,64)`, `T = 1_000_031_000` → 32 events ≤ T (`RSCH-42-32` ON T),
   32 after. Shipped accepted (`events_seen == 32`); boundary `at(31)` accepted; peek `at(32)` refused
   naming `RSCH-42-33`; control (same peek at T raised to 1_000_032_000) accepted; un-datable refused. T =
   `i64::MAX` kept as the anchor arm.

Honest limit: reads that bypass the view (a feature holding its own copy of the dataset) are not audited —
in-process, dev-grade (Assumption 2).

## Plan
Authored in-session from the plan-advisor handoff. Ordered atomic steps, each ≤3 files, each compiling
green on its own, each `covers: N`. No ADR step, no Cargo step (no new edge). `sim` gets zero edits. Base
sha `385bc7d` (pre-session) pins the anchor / sim-unchanged / before checks.

1. **Guard core + guarded run + load-bearing in-crate tests.** Files: `crates/research/src/leakage.rs`
   (new), `crates/research/src/lib.rs`, `crates/research/src/experiment.rs` (3). Tests:
   `check_reads_refuses_first_future_read_by_name`, `undatable_addressed_read_refused`,
   `read_exactly_at_t_is_admissible`, `load_bearing_stub_guard_accepts_peek`,
   `guarded_run_equals_shipped_run_at_anchor`. Anchor re-check: both proofs regenerate byte-identical;
   `git diff --exit-code 385bc7d -- crates/sim`. `covers: 2, 3, 5, 6`
2. **Flip `LEAKAGE_ASOF_T` → `"built-in-process"`.** Files: `crates/research/src/repro.rs`,
   `crates/research/tests/reproduce_green.rs`, `proofs/REPRODUCE_GREEN.json` (3). Only `leakage_asof_t`
   changes in the proof; VERDICT diff-clean. `covers: 1, 4, 5`
3. **LEAKAGE_GREEN proof test.** Files: `crates/research/tests/leakage_green.rs`,
   `proofs/LEAKAGE_GREEN.json` (2). Arms: anchor (T=MAX) · finite-T shipped · boundary · peek refused by
   name (`peek_produced_run: false`) · control · un-datable. `falsifiable` = peek refused AND control
   accepted AND boundary accepted; `falsifiable_catcher` names the step-1 stub test; six
   `attested_not_built` names. `covers: 1, 2, 3, 4`
4. **`scripts/verify-session-08.sh` (fail-closed).** Files: `scripts/verify-session-08.sh` (1). Workspace
   tests + `-D warnings` build + clippy; `one_test` on leakage_green, each catcher, reproduce/verdict, both
   ledgers; LEAKAGE facts; all 12 prior proofs re-asserted + freshness over 13; sim unchanged vs 385bc7d.
   `covers: 1, 2, 3, 4, 5, 6, 7`
5. **`scripts/demo-session-08.sh` (cumulative 7-section deck).** Files: `scripts/demo-session-08.sh` (1).
   Before pinned to 385bc7d; live cases; HONEST NOTES. `covers: 1, 2, 4`

| AC | Step(s) |
|----|---------|
| 1 Shipped accepted, anchor intact | 2, 3, 4, 5 |
| 2 Future peek refused by name, no run | 1, 3, 4, 5 |
| 3 Stubbed guard → RED | 1, 3, 4 (+ QA live mutations) |
| 4 LEAKAGE_ASOF_T built; 6 items attested by name | 2, 3, 4, 5 |
| 5 VERDICT unchanged; both air gaps green | 1, 2, 4 |
| 6 Workspace green, 0 warnings | 1, 4 |
| 7 verify exit 0 + 12 prior proofs | 4 |

**Riskiest step: 1** — the only step that can move both anchors, and where the fakest green hides (a guard
never reached from `run`, or a run built before the check).

## Execution (step → landing commit)
- step 1 — done: 3b63157
- step 2 — done: 4a7be24
- step 3 — done: 9076527
- step 4 — done: 0d7c29a
- step 5 — done: b931ed2

Review fixes (not numbered steps): b6772eb (impl-advisor: drop unaudited `AsOfView::len/is_empty`, read T/version
once, stale lib doc) · 038d96a (strictly-after-T count; anchored JSON values; clean-tree check) · 8014a94 (demo
same-input before + live mutation; intake restored after the bc58af3 splice) · 99706d5 (QA: `run` generic over
`AsOfFeature` — additive, `sim` unchanged — + `run_routes_through_guard_and_refuses_peek`, killing surviving
mutant (i)) · 3c35946 (verify/demo run it; GIT tally). Design delta: `run` is `run<F: AsOfFeature + ?Sized>`
rather than `&Feature`-only — same call shape for `sim`, needed to make its routing test-proven.

Verify: `scripts/verify-session-08.sh` → exit 0, 93/93 (19 EXEC · 2 GIT · 72 ECHO). Demo: 24/24 live checks.
QA: 11 live mutations — 7 RED, 2 expected-green, 1 equivalent, 1 survivor fixed.

## Advice
> Every advisor recommendation gets an explicit disposition (obeyed: <sha> / refused: <reason> / deferred:
> <path>). One disposition per handoff; per-sub-rec detail is in `sessions/session-08-summary.md`.

- tech-lead rec 1 — obeyed: 36060a2
- design-advisor rec 1 — obeyed: 3b63157
- plan-advisor rec 1 — obeyed: b931ed2
- implementation-advisor rec 1 — obeyed: b6772eb
- demo-producer rec 1 — obeyed: 8014a94
- qa-specialist rec 1 — obeyed: 99706d5
- fidelity-reviewer rec 1 — deferred: sessions/session-08-summary.md
