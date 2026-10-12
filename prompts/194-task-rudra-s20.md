# Session 194 — INTERACTIVE: rudra session 20 (its ground truth) under Vajra

> **Status:** DRAFT — written by the S194 agent from the founder's pick (chat 2026-10-12: option 1 of
> `sessions/session-193-summary.md`, "rudra S20"). The approval record `.ai/approvals/session-194.json` was written
> by his `vajra approve 194` at 08:39 the same day, BEFORE this file existed; he reads this prompt and re-runs
> `vajra approve 194` if he wants the record to follow it. The gate reads the record, not this line.

## Type
session_type: INTERACTIVE
- **INTERACTIVE** (gets the CODE checks). Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The founder runs rudra S20 himself under `vajra claude` and brings what happened; this session lists the findings
  with him and fixes what he says yes to.

## Goal
rudra S20 is a ground-truth (review-only, NO-CODE) session — a path a real project has walked under Vajra only once
(rudra S15). It is also the first real run since S193's F117 fix, so it is the live proof S193's review asked for
(rec 4): with Claude Code's own figure, the receipt shows only that figure. Find what real work shows that fixtures
cannot; fix what the founder says yes to, each with a check that fails without it.

## Before rudra S20 starts (founder, in order)
1. Already done: S193 merged (#231), main synced, `vajra` installed from it (binary 2026-10-10 00:20, after the
   00:10 merge).
2. In rudra: `vajra init --sync-fleet`; commit what it writes as S20's first commit, on S20's branch.
3. `vajra approve 20` in rudra, from his own terminal. rudra's prompt: `prompts/20-task-ground-truth.md`
   (`session_type: GROUND_TRUTH`).

## What to watch in rudra S20
Read every close log for `WAIVED`, `N/A` and `WARN` FIRST, never just PASS (S178).
- **The receipt (S193 rec 4, the live proof):** the top line equals Claude Code's own `cost-state` total; NO
  `[estimate` line, NO split line, NO "not in pricing table" warning beside it. A resume shows only its own share; a
  `/clear` skips (named, founder 2026-10-09).
- **The ground-truth path:** does Vajra treat S20 as NO-CODE (the guard, the close checks a GT session gets), and does
  the derived cadence (`ground_truth_every_n_sessions: 5`) agree that S20 is a GT session?
- **The three parked bugs (F116, F118, F119):** if seen again, record it on the existing entry — do not fix unless
  the founder says so.
- **Approvals, the session guard, waivers, stamps:** as in S184's list.
- **Time + cost** for the session, from the trusted figure.

## Deliverables
1. A findings list from rudra S20 (`F120…`), each with evidence (log line, file, commit) and the founder's call
   (fix / park / not a problem).
2. Fixes for every finding the founder says yes to, each with a test that fails without it.

## Acceptance
| AC | Check |
|---|---|
| AC1 | Every finding has evidence and a founder call recorded in the summary. |
| AC2 | Every fix has a real-run check in `scripts/verify-session-194.sh` (no source greps), red at the start commit. |
| AC3 | The rudra S20 receipt is recorded against Claude Code's own total, and whether it shows the estimate lines. |
| AC4 | No Vajra commit touches rudra; rudra's own commits are the founder's. `cargo test` passes in full. |

## Design
design-significant: no

No fix is approved yet, so there is no design to record. If a finding the founder approves changes a shared rule
(the receipt, the guard, the close, the scaffold), this flips to `yes` and cites the ADR it touches, as S193 did.

## Carried in
- **From S193:** fidelity-reviewer rec 4 (live proof of F117 on the next real run) — this session. F116, F118, F119
  parked as known bugs (ROADMAP backlog, S195 checklist).
- **Founder calls (2026-10-09):** `/clear` gets no receipt and a fork's own share is not shown — named, not closed
  (ADR-0004 S192 addendum).
- **Founder rulings:** read the tool's own cost, never grow the price list; one release-coordinator judges all
  `obeyed:` answers; the close does not run `cargo test` separately (run it in full before pushing); no new policing
  of Vajra's own paperwork.
- **Kept in backlog:** the rest of N7; F97's opt-out key; `tests/gt_cadence_shared.rs`'s loose assertion; S188's
  named gaps; N10; N11; S192 review rec 6. **Parked:** non-Claude tools (F91/F94/F95); release.
- **Next ground truth: S195** (derived, `scripts/lib-ground-truth.sh`).

## Guardrails
- No paid run by the agent without the founder's yes. No transcript or run capture committed (S126).

## Plan
1. The founder syncs and runs rudra S20; read its close logs and receipt with him. — covers: 1, 3
2. Fix each finding he says yes to, with a check red at the start commit. — covers: 2
3. `scripts/verify-session-194.sh`, the demo, the full `cargo test`. — covers: 2, 4
4. Summary with 3 next options; closeout sync; next prompt; one cold review; the `--inputs-sha 194` stamp last.
   — covers: 1, 2, 3, 4

## Delta
- `+` rudra S20 findings (F120…) with the founder's calls
- `+` the live receipt check for F117
- `~` whatever they show is wrong

## Execution

## Advice
Roles dispatched: `tech-lead` (mandatory, first). Required at close: `fidelity-reviewer` (the one cold review),
`release-coordinator` (the one judge of every `obeyed:` answer). `design-advisor` only if an approved finding changes
a shared rule (tech-lead rec 5).

researcher: skipped — the tech-lead deferred it on budget: the evidence is rudra S20's own close logs, receipt and transcript on this machine, read with the founder, and S192/S193 already proved the receipt live (~0.4M saved, crew ~1.6M → ~2.0M otherwise).
requirements-analyst: skipped — the tech-lead deferred it on budget: the founder picked this session and AC1–AC4 copy S193's accepted shape (~0.3M would restate a prompt he chose).
plan-advisor: skipped — the tech-lead deferred it on budget: the Plan covers AC1–AC4 with `covers: N`; the real order depends on findings that do not exist yet (~0.3M).
implementation-advisor: skipped — the tech-lead deferred it on budget: no code is approved yet; its recs 4 and 6 name the traps (red for the right reason, the full cargo test before push) (~0.6M).
qa-specialist: skipped — the tech-lead deferred it on budget: AC2 makes every fix's check real-run and red at the start commit, and the fidelity-reviewer re-runs verify-194 at both ends (~0.6M).
demo-producer: skipped — the tech-lead deferred it on budget: the founder watches his own rudra run and its receipt; the summary records both (~0.3M).

**tech-lead** (`.ai/handoffs/session-194-tech-lead.md`):
