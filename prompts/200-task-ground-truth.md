# Session 200 — Ground Truth (no code): the every-5th review of S196–S199

> **Status:** DRAFT — written by the S199 agent. S200 is review-only by the every-5th rule
> (`scripts/lib-ground-truth.sh`; S195 was the last), not a pick. The founder approves it with
> `vajra approve 200` in his own terminal; the gate reads the approval record. The review-only guard blocks code
> edits, commits, pushes and PRs until the founder reads the report and types `vajra approve 200 --close`.

## Type
session_type: GROUND_TRUTH
- **NO-CODE.** No Vajra source edits · the report is committed only after the founder's `vajra approve 200 --close`.
- A finding is written down with a severity and a proposed fix, not fixed. The founder signs off before code resumes.

## Goal
1. **Audits** (the live list: `CONSTRAINTS.yaml#ground_truth.required_audits`), one or two lines each,
   🟢/🟡/🔴, `delivery_progress` first: what reached a user since S195 (S196 rudra S21 on Opus + F127 the push belt,
   S197 F125 the review-only guard in every project + F116/F119/N10/N17, S198 F118 + N18, S199 every pending known
   bug), and is Vajra on track?
2. **The first use of the close-truth question (S199, N14):** `constraint_violation_review`'s new question — for each
   session S196–S199, read its newest `.ai/verify/closeout/<stamp>/result` and compare with what the summary and the
   agent told the founder. Name every mismatch.
3. **The S200 checklist** — each with a pick: fix (which session), keep in backlog (why), or drop (founder's call):
   - N22 (`scripts/verify-session-178.sh` red on main — old-vs-new wording comparisons, found S199)
   - `scripts/verify-session-179.sh`'s rudra row (rudra's ground-truth section lags the scaffold until rudra runs
     `vajra init --sync-fleet`; S199's N14 question made it differ)
   - F127's and F123's remaining routes (named, not closed; founder 2026-09-15: no more policing)
   - F97's opt-out key (S195: wait for a real request) · S188's named gaps · the `/clear` receipt gap and a fork's
     own share (founder 2026-10-09: named, not closed)
   - anything S199's summary moved out under its split rule
4. **Point at the user:** the founder's order (2026-10-09): rudra sessions until he is confident, then cut the cost
   (boot diet F4, KNOWLEDGE trim). The README "tested with" line (Haiku answer c) is still open — in his words.

Output: `sessions/session-200-ground-truth.md`. New findings listed with a severity for S201.

## Deliverables
1. `sessions/session-200-ground-truth.md` with every audit in `CONSTRAINTS.yaml#ground_truth.required_audits`,
   🟢/🟡/🔴 with live evidence, `delivery_progress` first.
2. The close-truth question answered for S196–S199 from their result files.
3. A pick for every S200 checklist item (fix → named session, keep → why, drop → founder's call).
4. The next step toward a stranger getting value, and new findings with a severity for S201.

## Acceptance
1. The report has one row per required audit with a 🟢/🟡/🔴 and live evidence (commands run, output pasted).
2. The close-truth question names, for each of S196–S199, the result file read and whether the summary matched.
3. Every S200 checklist item has a pick and a one-line reason.
4. The founder signs the report off (`vajra approve 200 --close`) before code resumes.

## Carried in
- **From S199:** F126 (a late founder change goes into git, in files that leave the stamp alone — no new rule), the
  review-only sign-off step, N19, N20, N21, N14, `latest`, `gt_cadence_shared`, the rest of N7 — see
  `sessions/session-199-summary.md`. N22 filed. rudra gets N14's question only after `vajra init --sync-fleet` there.
- **Parked by the founder:** non-Claude tools (F91, F94, F95), release/publish; the "Vajra runs the reviewer" design
  (dropped 2026-10-15).
- Founder decisions to respect: no new policing of Vajra's own paperwork (2026-09-15); Vajra's close does not run
  `cargo test` (2026-10-04); read the tool's own cost, never grow the price list; one release-coordinator judges all
  `obeyed:` answers.

## Design
design-significant: no
- A review-only session picks designs; it builds none. Any design it picks names its record (ADR-0004,
  DECISION-007, DECISION-011) in the report.

## Plan
<the S200 agent writes this after the tech-lead>

## Delta
- `+` `sessions/session-200-ground-truth.md`, `sessions/session-200-review.md`, `sessions/session-200-summary.md`
- `~` the S200 checklist items: each picked (fix / keep / drop)
- `+` `prompts/201-task-<slug>.md`

## Advice
