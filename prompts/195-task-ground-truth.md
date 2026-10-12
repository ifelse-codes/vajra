# Session 195 — Ground Truth (no code): the every-5th review of S191–S194

> **Status:** DRAFT — written by the S194 agent. S195 is review-only by the every-5th rule
> (`scripts/lib-ground-truth.sh`; S190 was the last), not a pick. The founder approves it with
> `vajra approve 195` in his own terminal; the gate reads the approval record.

## Type
session_type: GROUND_TRUTH
- **NO-CODE.** No Vajra source edits · no commits except the report on a `-closeout` branch · no PRs besides it.
- A finding is written down with a severity and a proposed fix, not fixed. The founder signs off before code resumes.

## Goal
1. **Audits** (the live list: `CONSTRAINTS.yaml#ground_truth.required_audits`), one or two lines each,
   🟢/🟡/🔴, `delivery_progress` first: what reached a user since S190 (S191 four small fixes, S192 the receipt
   proven live, S193 F117 the receipt shows only Claude Code's figure, S194 F121 the exit box shows the close check
   + F123 the merge guard + F120 the transcript refusal), and is Vajra on track?
2. **The Haiku question.** rudra S20 ran on Haiku 4.5 (founder's deliberate test): every Vajra step that is only an
   instruction was skipped (no tech-lead, no reviewer, a self-written "independent" ACCEPT), and only what Vajra
   blocks held. S16–S19 on Opus followed the steps. What does that say about Vajra's promise for a user on a cheap
   model — and is the answer more gates, fewer steps, or saying which models Vajra supports?
3. **The S195 checklist** — each with a pick: fix (which session), keep in backlog (why), or drop (founder's call):
   - the known bugs (ROADMAP backlog "🐞 KNOWN BUGS — TO FIX"): F116 (the approval record left out of git), F118
     (`--advance` keeps the old session's text; hit again S194), F119 (✗ design with `design-significant: no`; seen
     again S194), **F125** (the review-only guard turns off on any `-closeout` branch the agent names)
   - F123's remaining routes (fast-forward, `reset --hard`, `branch -f`, `update-ref`, `git merge --no-verify`)
   - F121's named limits (shows, does not stop; only at exit; the agent can write the result file)
   - Vajra's own `.ai/verify/closeout/latest` is a real folder, not a link
   - kept from S190: the rest of N7; F97's opt-out key; `tests/gt_cadence_shared.rs`'s loose assertion; S188's
     named gaps; N10; N11; S192 review rec 6; verify-131's two stale checks
   - the `/clear` receipt gap and a fork's own share (founder 2026-10-09: named, not closed)
4. **Point at the user:** the founder's order (2026-10-09): rudra sessions until he is confident, then cut the cost
   (boot diet F4, KNOWLEDGE trim). Does S191–S194's evidence say he can be confident yet?

Output: `sessions/session-195-ground-truth.md`. New findings listed with a severity for S196.

## Deliverables
1. `sessions/session-195-ground-truth.md` with every audit in `CONSTRAINTS.yaml#ground_truth.required_audits`,
   🟢/🟡/🔴 with live evidence, `delivery_progress` first.
2. An answer to the Haiku question with evidence.
3. A pick for every S195 checklist item (fix → named session, keep → why, drop → founder's call).
4. The next step toward a stranger getting value, and new findings with a severity for S196.

## Acceptance
1. The report has one row per required audit with a 🟢/🟡/🔴 and live evidence (commands run, output pasted).
2. The Haiku question is answered from rudra S20's own evidence (S194 summary), not from memory.
3. Every S195 checklist item has a pick and a one-line reason.
4. The founder signs the report off before code resumes.

## Carried in
- **From S194:** F121, F123, F120 fixed; rudra gets them only after `vajra init --sync-fleet` there. F125 parked.
  F122 (no helpers ran) is visible now through F121's `failed:` names, not prevented.
- **Parked by the founder:** non-Claude tools (F91, F94, F95), release/publish.
- Founder decisions to respect: no per-claim `obeyed:` judge (2026-10-03); Vajra's close does not run
  `cargo test` (2026-10-04); no new policing of Vajra's own paperwork (2026-09-15); read the tool's own cost, never
  grow the price list.

## Design
design-significant: no
- A review-only session picks designs; it builds none. Any design it picks names its record (ADR-0004,
  DECISION-007, DECISION-011) in the report.

## Plan
<the S195 agent writes this after the tech-lead>

## Advice

## Delta
- `+` `sessions/session-195-ground-truth.md`, `sessions/session-195-review.md`, `sessions/session-195-summary.md`
- `~` the S195 checklist items: each picked (fix / keep / drop)
- `+` `prompts/196-task-<slug>.md`
