# Session 76 — Summary: the dogfood ride-along (paid MEASURE)

## Goal & outcome
Run one real task through `vajra claude` end-to-end, governed instance in chitra, agent riding along;
derive authoritative cost, receipt fidelity, folds, gates, obedience; write the honest report; refresh
`dogfood_check`. **Outcome: measured — richly on governance, null-with-cause on cost.** Two paid headless
runs on chitra's real next task (S07 CI): run 1 hit a read-only wall; run 2 (full autonomy) delivered a
green CI workflow. `dogfood_check` refreshed for the first time since S63 (12 sessions).

## Evidence
- `sessions/session-76-dogfood.md` + `sessions/session-76-artifacts/` (run1/ + run2/ raw: receipts,
  JSONLs, cost, identity, capture harness).
- `scripts/verify-session-76.sh` → **ALL GREEN (16/16)** incl. cost-consistency (report figure == receipt
  artifact) and null-is-real (0 `type:result` in both JSONLs).
- `scripts/demo-session-76.sh` → 4 `demo:` markers, before→after.
- Independent fidelity re-run of the governed instance's `verify-session-07.sh` → **13/13 GREEN**.

## Fidelity map — every prompt criterion → what shipped (DECISION-002)

| # | Criterion | Verdict | Evidence / gap |
|---|---|---|---|
| 1 | Founder-led + PAID; `total_cost_usd` captured verbatim | **PARTIAL** | PAID ✓ (2 runs); prompt founder-authored ✓; **but agent-INVOKED** at founder's instruction (letter bent, disclosed); **`total_cost_usd` never existed to capture** (headless emitted none) — captured the null instead |
| 2 | Gates-fired table (FIRED/DORMANT + helped/neutral/hindered, each from an artifact) | **SHIPPED** | `session-76-dogfood.md` gates table, 6 rows, each cited |
| 3 | Receipt headline vs `total_cost_usd`; folds measured | **PARTIAL** | folds measured (0) ✓; **receipt-vs-authoritative comparison impossible** (no `total_cost_usd`); S66 *fallback* labeling verified, *happy path* not |
| 4 | `session-76-dogfood.md` + artifacts with raw evidence + honest verdict (hindered/nulls/bugs) | **SHIPPED** | report names 3 bugs, 3 nulls, the caveat, the positives |
| 5 | verify proves existence + internal consistency; demo before→after + markers; no `src/` | **SHIPPED** | verify 16/16, demo 4/4 markers, `no-src-change` PASS |

**Deliverables:** dogfood report ✓ · artifacts ✓ · verify+demo ✓ · summary ✓ · independent cold review
(`session-76-review.md`, attested) → produced this closeout · 3 ranked S77 candidates → below.

## What I did NOT build / fakest green
- **Fakest green:** "dogfood measured ✓" hides that the **single core cost metric was UNOBTAINABLE** — no
  authoritative dollar figure exists for either run (headless emitted no `total_cost_usd`; fable-5 unpriced).
  The run is strong on *governance* and empty on *cost truth* — the exact axis criteria 1/3 centered on.
- **Criterion 1's "founder-led" is bent** — the founder authored+directed but the agent invoked the run.
- **One task, one repo** — a point reading, not a distribution; not generalizable to "vajra is satisfying."

## Next — 3 ranked S77 candidates
- **A — Receipt truth on real runs (fable-5 price + headless authoritative cost). [rec]**
  *Goal:* a real dogfood produces a truthful dollar figure — add fable-5 to `meter::MODEL_PRICING` and
  diagnose/repair the missing headless `total_cost_usd` (regression vs S63). *Why:* this run proved the
  receipt cannot tell the truth on the runs users actually make. *Risk:* fable-5 real rates may be
  unpublished → the fix is "flag clearly," not "price exactly."
- **B — Typed cannot-evaluate + read-only-headless UX.**
  *Goal:* surface "your headless agent is read-only" up front (the run-1 wall) and type the QA
  timeout/spawn-failure null (`CannotEvaluate::{Timeout,SpawnFailure}`). *Why:* standing S73/S76 debt.
  *Risk:* UX-only polish that doesn't move the pipeline.
- **C — Ship-evidence durability for `--stations` (S75 GT finding).**
  *Goal:* a durable merge-time SHIP marker so the payload counter doesn't decay when branch refs are
  pruned. *Why:* makes the S74 counter a durable ledger, not a point-in-time snapshot. *Risk:* lower
  urgency than the cost-truth gap this run exposed.

## Follow-up (chitra, founder's call)
chitra has a green, **uncommitted** `session-07-ci-workflows` branch (3 files, verify 13/13) — real
forward progress from the dogfood. Commit it in chitra to complete the natural progression, or discard.
Pre-run WIP + junk are preserved in the vajra scratchpad.
