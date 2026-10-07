# Session 190 — Ground Truth (no code): the every-5th review of S186–S189

> **Status:** DRAFT — written by the S189 agent from the founder's pick (2026-10-07: "Review-only S190").
> He approves it with `vajra approve 190` in his own terminal; the gate reads the approval record.

## Type
session_type: GROUND_TRUTH
- **NO-CODE.** Derived as the next review-only session by `scripts/lib-ground-truth.sh` (every 5th; S185 was
  the last). No Vajra source edits · no commits except the report on a `-closeout` branch · no PRs besides it.
- A finding is written down with a severity and a proposed fix, not fixed. The founder signs off before code resumes.

## Goal
1. **Audits** (the live list: `CONSTRAINTS.yaml#ground_truth.required_audits`), one or two lines each,
   🟢/🟡/🔴, `delivery_progress` first: what reached a user since S185 (S186 the S185 fixes, S187 the guard
   message, S188 the approvals before/after check, S189 the receipt reading Claude Code's own cost), and is
   Vajra on track?
2. **The S190 checklist** — every backlog carry named "S190" since S185, each with a pick: fix (which session),
   keep in backlog (why), or drop (the founder's call):
   - N2 (the GT Write guard blocks writes outside the project — a known issue, founder 2026-10-05)
   - the rest of N7 (verify-176/178/179, demo-176/178/179/184/186 still make their own checkouts)
   - F97's opt-out key for an audit removed on purpose
   - `vajra next --advance` number-swaps SESSION-BOOT (hit again in S188 and S189)
   - the session guard reads a session number in edit text as starting that session
   - verify-133 not safe to run twice at once
   - `tests/gt_cadence_shared.rs` reads the real repo's summary (went red on S189's summary wording)
   - S188's named gaps (a change undone in one command, writes between pairs, another project's folder) and the
     older guard verify checks S188 superseded (verify-182/186/187)
   - S189's carries: the paid live receipt check (`/clear`, `--continue`, a fork — the fork `startTime`
     assumption is the one way left for a wrong number with a "this run" label); a SessionStart-hook session-id
     match; `find_session_jsonl`'s folder name (only `/` replaced) and `CLAUDE_CONFIG_DIR`
   - F110 (b) as its own session (DECISION-011 S186 addendum, P1–P7) and F110 option A (sandbox `denyWrite`)
3. **Point at the user:** the shortest path from here to a stranger getting value (0.2.0 is still not on
   crates.io; the founder ruled release is not a problem yet at S180 — say whether that still holds).

Output: `sessions/session-190-ground-truth.md`. New findings listed with a severity for S191.

## Deliverables
1. `sessions/session-190-ground-truth.md` with every audit in `CONSTRAINTS.yaml#ground_truth.required_audits`,
   🟢/🟡/🔴 with live evidence, `delivery_progress` first.
2. A pick for every S190 checklist item above (fix → named session, keep → why, drop → founder's call).
3. The shortest path to a stranger getting value, and new findings with a severity for S191.

## Acceptance
1. The report has one row per required audit with a 🟢/🟡/🔴 and live evidence (commands run, output pasted).
2. Every S190 checklist item has a pick and a one-line reason.
3. The founder signs the report off before code resumes.

## Carried in
- From S189: F67 is fixed on recorded lines only (STATE 🟡) — it leaves the broken list after one real
  interactive receipt shows Claude Code's own figure. The founder chose not to run the live check in S189.
- **Parked by the founder:** non-Claude tools (F91, F94, F95), release/publish.
- Founder decisions to respect: no per-claim `obeyed:` judge (2026-10-03); Vajra's close does not run
  `cargo test` (2026-10-04); no new policing of Vajra's own paperwork (2026-09-15).

## Design
design-significant: no
- A review-only session picks designs; it builds none. Any design it picks names its record (ADR-0004 S189
  addendum, DECISION-011, DECISION-007) in the report.

## Plan
<the S190 agent writes this after the tech-lead>

## Delta
- `+` `sessions/session-190-ground-truth.md`
- `~` the S190 checklist items: each picked (fix / keep / drop)
