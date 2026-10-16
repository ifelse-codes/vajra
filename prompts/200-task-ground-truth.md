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
   - N22 (`scripts/verify-session-178.sh` / `demo-session-178.sh` red on main — old-vs-new wording, found S199)
   - N23 (`scripts/verify-session-179.sh`'s rudra row — rudra's ground-truth section lags the scaffold until rudra
     runs `vajra init --sync-fleet`; S199's N14 question made it differ)
   - **S199 review rec 5 — check at this session's first `vajra next --steps`:** does the new sign-off step (✗ until
     `vajra approve 200 --close`) become "YOUR NEXT STEP" before the report exists, hiding the later steps' how?
     If it does, file it (a known bug for S201); this session writes no code.
   - **S199 release-coordinator rec 1 — at this session's start:** confirm `.ai/verify/closeout/latest` points at
     S199's close-run folder (not `20261015T100751Z`) and record that stamp next to S199's push record (PR head =
     the GREEN result) in `sessions/session-199-summary.md` — the link line hides its errors
     (`verify-closeout.sh:1416`), so this is the eyes-on proof of S199's AC7.
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
design-advisor: skipped — no open design fork on this checklist (every design item is named-not-closed by founder rule; `design-significant: no`); tech-lead rec 3, its allowance carried to S201.

## Plan
(Written after the founder's `vajra approve 200 --close` — the review-only guard blocked this file until then, N26.)
1. Run every required audit live and paste the output into `sessions/session-200-ground-truth.md`, `delivery_progress` first; the start-of-session checks (`vajra next --steps` with S199's binary, `latest`) before any file is written. covers: 1
2. Answer the close-truth question for S196–S199 (and rudra S21) from each newest `.ai/verify/closeout/<stamp>/result`, its PR head, the summary's own words and the agent's last words at close. covers: 2
3. Give every S200 checklist item a pick (fix → session, keep → why, drop → founder's call), "drop" set out as a real choice for N22/N23 (tech-lead rec 4). covers: 3
4. Put the report to the founder; record his sign-off and pick; code resumes only after his `vajra approve 200 --close`. covers: 4

## Execution
- step 1 — done: ee9343a
- step 2 — done: ee9343a
- step 3 — done: ee9343a
- step 4 — done: f21c831

## Delta
- `+` `sessions/session-200-ground-truth.md`, `sessions/session-200-review.md`, `sessions/session-200-summary.md`
- `~` the S200 checklist items: each picked (fix / keep / drop)
- `+` `prompts/201-task-<slug>.md`

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `fidelity-reviewer` (gate-mandated past S131, one cold pass on the
report), `release-coordinator` (required; the one judge of every `obeyed:` answer).

researcher: skipped — the tech-lead deferred it on budget: the close-truth question is four result files and four summaries the main session reads directly (~200k kept for the next rudra comparison).
requirements-analyst: skipped — the tech-lead deferred it on budget: the prompt already lists the audits, the checklist and 4 acceptance lines (~100k).
design-advisor: skipped — the tech-lead deferred it on budget: no open design fork, `design-significant: no`; the recorded skip line is under `## Design` (~100k carried to S201).
plan-advisor: skipped — the tech-lead deferred it on budget: the plan is "fill one report" (~80k).
implementation-advisor: skipped — the tech-lead deferred it on budget: no source edits are allowed in a review-only session (~100k).
qa-specialist: skipped — the tech-lead deferred it on budget: no verify-200 script; the evidence is live command output pasted into the report (~80k).
demo-producer: skipped — the tech-lead deferred it on budget: a review-only session produces no demo (~60k).

**tech-lead** (`.ai/handoffs/session-200-tech-lead.md`):
- tech-lead rec 1 — obeyed: ee9343a (the report's "Start-of-session checks": `vajra next --steps` from the installed and from S199's binary, and `latest -> 20261016T130949Z`, both run before the report file was written; raw output pasted; N24 + N25 filed from them)
- tech-lead rec 2 — obeyed: ee9343a (Goal 2: one row per session naming each result file, its head and verdict, the PR head from `git rev-parse <merge>^2`, the summary's and the chat's own words; the WAIVED/N/A grep over the four final close folders reported — 0 real waivers, rudra S21's 1 N/A named)
- tech-lead rec 3 — obeyed: d9ff0dd (no design-advisor dispatch; the one-line `design-advisor: skipped — <reason>` under `## Design` is written in this prompt at the commit that records it)
- tech-lead rec 4 — obeyed: ee9343a (checklist row 1 sets out N22 "retire" as a proposed drop with the paperwork-loop reason, row 2 offers N23 keep or drop; the founder chose retire / keep — "Founder rulings")
- tech-lead rec 5 — obeyed: d9ff0dd (order: report draft → one fidelity-reviewer pass on it → its recs applied (ee9343a) → this Advice → one release-coordinator judge pass)
- tech-lead rec 6 — obeyed: d9ff0dd (the tech-lead and fidelity-reviewer handoffs recorded by `vajra next --role --from` a scratch file holding the hand-back text, each with a `verified: toolu_…; text-sha` header; the report was committed only after `vajra approve 200 --close`, ee9343a after f21c831's close record)

**fidelity-reviewer** (`.ai/handoffs/session-200-fidelity-reviewer.md`) — one cold pass, ACCEPT 5 SHIPPED / 3 PARTIAL:
- fidelity-reviewer rec 1 — obeyed: ee9343a (the glance row now reads "about the close check itself" and names rudra S21's false "Nothing is left half-done" — F126, fixed S199; Goal 2's rudra row carries ✗ on that claim)
- fidelity-reviewer rec 2 — obeyed: ee9343a (checklist row 4 reads "Checked; the S199 push line is not written yet (after sign-off, N26)")
- fidelity-reviewer rec 3 — obeyed: ee9343a (checklist row 2 points at Goal 4's next step, option A, the rudra sync)
- fidelity-reviewer rec 4 — obeyed: ee9343a (Goal 2 says each summary has no words about its own close at its PR head and quotes where the next session recorded it — S198 `:38`, S199 `:52`)
- fidelity-reviewer rec 5 — obeyed: ee9343a (constitution_review cites `.ai/AGENTS.md:66`, `prompts/200-task-ground-truth.md:69-70` and the step list's plan step as the places that assume the plan is written mid-review)
