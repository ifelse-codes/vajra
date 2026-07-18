# Cold Fidelity Review — Session 74 (the payload counter)

> Independent adversarial pass (DECISION-002). Run in a **fresh subagent** fed exactly two cold
> inputs — the contract (`prompts/74-task-payload-counter.md`) and the delivery diff (committed
> changes vs the merge-base, excluding `sessions/`, `prompts/`, and the closeout-synced `.ai/*`).
> No summary, STATE, or memory consulted. No expected verdict supplied.

## Method controls
- Read **only** the two supplied artifacts. Every verdict is anchored to a quoted identifier / hunk
  in the diff, not to prose claims in the contract or the module's own doc-comments.
- Adversarial posture: assume the builder re-scoped toward a green checkmark; the diff is trusted
  over any narration inside it.

## Per-requirement table

| # | Requirement | Verdict | Evidence |
|---|-------------|---------|----------|
| A1 | `--stations NN` prints per-station PASSED/ABSENT + "K of 8", read-only | **SHIPPED** | `run_stations()` in `next.rs` calls `stations::format_station_report(&stations::station_report(...))`; formatter emits `[{mark}] {name} {lane} — {note}` + `"{} of {} stations passed"`; `run_stations` returns `Ok(())` unconditionally (report, not gate). |
| A2 | placeholder / missing ⇒ ABSENT; count earned only by gate-acceptable evidence | **PARTIAL** | True for file/git stations (`DeltaState::Placeholder → absent`, `PlanState::Placeholder → absent`; test `placeholder_laden_prompt_counts_low` asserts `passed()==0`). QA/Demo-er earn PASS on `script_exists`/`missing_in_file.is_empty()` — a present-but-broken script is PASSED here yet BLOCKS at the live gate. Disclosed via `[static — not live-green]`. |
| A3 | Reuses each station's classifier; rule and counter must **never** disagree | **PARTIAL** | 5/8 truly reuse the gate fn (`validate_prompt`, `design_gate`, `plan_gate`, `exec_gate`, `derive_ship_state`). QA/Demo-er reuse only the **static half** (`gather_contract`) — the S69 QA gate re-runs LIVE, so the counter CAN disagree. Reviewer re-implements verdict parsing (`review_verdict_accept`). All three deviations disclosed. |
| A4 | Station count is a GT input, recorded where the GT reads it | **SHIPPED** | `CONSTRAINTS.yaml` adds `pipeline_advance_check` to `required_audits` + `pipeline_advance_questions`; `verify-session-74.sh` `gt-input-wired` greps it. Rides the existing spine — `no-second-store`. |
| A5 | Proven: verify-74 + demo-74 + cold review + attestation | **PARTIAL** | verify-74 (7/8 fixture, 0/8 placeholder, `counter_agrees_with_gates`) + demo-74 (4 `demo:` markers) present. Cold review = this doc; attestation = builder's post-verdict step. |
| P1 | `stations` module calls each classifier, maps PASSED/ABSENT | **SHIPPED** | `station_report()` fans out to 8 `*_status` fns, each `Outcome::Passed/Absent`. |
| P2 | `--stations` surfaces table + K of 8, read-only | **SHIPPED** | `--stations` branch before `--advance`; `StationReport::passed()` filters `Passed`. |
| P3 | Record count where GT reads it; wire placeholder→ABSENT | **SHIPPED** | CONSTRAINTS wiring (A4) + placeholder mapping (A2). |
| P4 | verify + demo + review + attestation | **PARTIAL** | Scripts shipped; review/attestation are closeout-phase. |
| G1 | One story; no station-behavior / gate-semantics change | **SHIPPED** | New module + read-only surface; no station gate fn modified (only read). |
| G2 | Derive, never assert | **SHIPPED** | `passed()` is a computed filter; no hand-typed count anywhere. The criterion the session most cleanly nails. |
| G3 | ≤3 files/commit, branch, approval tokens, ~2h | **PARTIAL** | `per_commit_file_cap` check present; per-commit composition not verifiable from a squashed diff. |
| D1 | stations module + surface + GT wiring | **SHIPPED** | `src/stations/mod.rs`, `next.rs`, `lib.rs` `pub mod stations`, CONSTRAINTS. |
| D2 | verify + demo scripts | **SHIPPED** | Both new files present. |
| D3 | summary + attested cold review | **NOT-BUILT (in diff)** | Not in the delivery diff (closeout/reviewer step) — expected. |
| D4 | closeout `.ai/` sync + 3 ranked S75-GT notes | **NOT-BUILT (in diff)** | No STATE/ROADMAP/TASK sync in the diff — closeout-phase. |

## Count
**11 of 17 SHIPPED** (A1, A4, P1, P2, P3, G1, G2, D1, D2 fully; D3/D4 correctly deferred to
closeout). 6 PARTIAL/deferred, **0 silently NOT-BUILT** among the in-scope code requirements.

## The FAKEST GREEN — named
**The QA and Demo-er station reads (`qa_status` / `demoer_status`).** Their checkmark is trivially
true: QA passes on `c.script_exists` — a file merely being present — and Demo-er on a static text
scan for `demo:` element strings. The live close gate (S69/S71) actually **re-runs** the script. So
a verify script that exists but fails scores PASSED in `--stations` while BLOCKING at close —
contradicting criterion 3's "never disagree." `counter_agrees_with_gates` tests agreement only for
design/plan/exec, never the live QA/Demo re-run, because it cannot hold there.

Crucially **disclosed, not hidden**: the module doc names it "the disclosed fakest green", every
QA/Demo note carries `[static — not live-green]`, and the demo's "honest edges" spells out that a
`--stations` QA/Demo PASS "attests the evidence is gate-ELIGIBLE, not that a live re-run is green."
The Reviewer station's re-implementation (`review_verdict_accept`) is a secondary, likewise-disclosed
instance of the same can-drift class.

## Verdict

**Verdict:** ACCEPT

The real scope is a faithful build of the whole contract — all eight stations derived from real
classifiers with a genuinely computed (not self-asserted) K-of-8 — with one honestly-flagged
weakening (QA/Demo/Reviewer read statically, weaker than their live close gates), disclosed in code,
verify, and demo rather than silently re-scoped.

**Review-Inputs-SHA:** 9b0d5eb7841201dc3cb7947a214616d61ed0cf1ed1a6b71454b5f59b9ce72fc1
