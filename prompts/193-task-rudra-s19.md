# Session 193 — INTERACTIVE: rudra session 19 under the trusted receipt

> **Status:** DRAFT — written by the S192 agent from the founder's pick (2026-10-09: "rudra's next session"; the
> `/clear` receipt gap "leave it named"). He approves it with `vajra approve 193` in his own terminal; the gate reads
> the approval record, not this line.

## Type
session_type: INTERACTIVE
- **INTERACTIVE** (gets the CODE checks). Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The founder runs rudra S19 himself under `vajra claude` and brings what happened; this session lists the findings
  with him and fixes what he says yes to.

## Goal
rudra S19 is the first real project session with a receipt the founder can trust (S192: every live figure matched
Claude Code's own to the cent) and with S192's folder fix. Find what real work shows that fixtures cannot; fix what
the founder says yes to, each with a check that fails without it.

## Before rudra S19 starts (founder, in order)
1. Merge S192's PR. Then in `~/playground/vajra`: `git checkout main && git pull --ff-only`, `cargo install --path .`.
2. In rudra: `vajra init --sync-fleet`; commit what it writes as S19's first commit, on S19's branch.
3. `vajra approve 19` in rudra, from his own terminal. rudra's prompt: `prompts/19-task-test4-new-hypothesis.md`.

## What to watch in rudra S19
Read every close log for `WAIVED`, `N/A` and `WARN` FIRST, never just PASS (S178).
- **The receipt:** the top line vs Claude Code's own `cost-state` total in the run's log (the S192 check); a resume
  shows only its own share; a `/clear` skips (named, founder 2026-10-09).
- **Approvals, the session guard, waivers, stamps:** as in S184's list.
- **Time + cost** per session, now from the trusted figure.

## Deliverables
1. A findings list from rudra S19 (`F116…`), each with evidence (log line, file, commit) and the founder's call
   (fix / park / not a problem).
2. Fixes for every finding the founder says yes to, each with a test that fails without it.

## Acceptance
| AC | Check |
|---|---|
| AC1 | Every finding has evidence and a founder call recorded in the summary. |
| AC2 | Every fix has a real-run check in `scripts/verify-session-193.sh` (no source greps), red at the start commit. |
| AC3 | The rudra S19 receipt's top line is recorded against Claude Code's own total. |
| AC4 | No Vajra commit touches rudra; rudra's own commits are the founder's. `cargo test` passes in full. |

## Design
design-significant: no
- No design until a finding needs one; a finding that does gets the design-advisor and a cited record first.

## Carried in
- **Founder calls (2026-10-09):** `/clear` gets no receipt and a fork's own share is not shown — named, not closed
  (ADR-0004 S192 addendum); the fix, if ever, is the SessionStart session-id match (S189 researcher rec 2).
- **From S192:** `scripts/verify-session-131.sh` has 2 stale checks (pre-S181 grep text; the S135 crew gate) — left
  as history (Vajra's own paperwork).
- **From S192's review (rec 6, deferred):** re-runnable oracles for the folder rule — a local check of each
  transcript's `cwd` against its folder name, and Claude Code's long-name hash under node. Backlog unless a
  rudra finding needs it.
- **Founder rulings:** read the tool's own cost, never grow the price list; one release-coordinator judges all
  `obeyed:` answers; the close does not run `cargo test` separately; no new policing of Vajra's own paperwork.
- **Kept in backlog:** the rest of N7; F97's opt-out key; `tests/gt_cadence_shared.rs`'s loose assertion; S188's
  named gaps; N10; N11. **Parked:** non-Claude tools (F91/F94/F95); release.
- **Next ground truth: S195** (derived, `scripts/lib-ground-truth.sh`).

## Guardrails
- No paid run by the agent without the founder's yes. No transcript or run capture committed (S126).

## Plan
1. The founder installs, syncs and runs rudra S19; read its close logs and receipt with him. — covers: 1, 3
2. Fix each finding he says yes to, with a check red at the start commit. — covers: 2
3. `scripts/verify-session-193.sh`, the demo, the full `cargo test`. — covers: 2, 4
4. Summary with 3 next options; closeout sync; next prompt; one cold review; the `--inputs-sha 193` stamp last.
   — covers: 1, 2, 3, 4

## Delta
- `+` rudra S19 findings (F116…) with the founder's calls
- `~` whatever they show is wrong

## Advice
Roles dispatched: `tech-lead` (mandatory, first). Required at close: `fidelity-reviewer` (the one cold review),
`release-coordinator` (the one judge of every `obeyed:` answer).

design-advisor: skipped — the tech-lead deferred it on budget: design-significant: no and no finding exists yet to design (~0.5M, ~1.6M → ~2.1M); its rec 4 dispatches it narrowly if an approved finding changes a guard, the receipt or `vajra init` for every project.
researcher: skipped — the tech-lead deferred it on budget: the evidence is rudra S19's own close logs, receipt and transcript on this machine, and S192 already proved the receipt live (~0.4M saved).
requirements-analyst: skipped — the tech-lead deferred it on budget: the founder co-wrote the deliverables and AC1–AC4 and brings the findings himself (~0.3M would buy a restatement).
plan-advisor: skipped — the tech-lead deferred it on budget: the Plan covers AC1–AC4 with `covers: N`; the real order depends on findings that do not exist yet (~0.3M).
implementation-advisor: skipped — the tech-lead deferred it on budget: no code is approved yet; its recs 3 and 5 name the traps (red for the right reason, the full cargo test before push) (~0.6M).
qa-specialist: skipped — the tech-lead deferred it on budget: AC2 makes every fix's check real-run and red at the start commit, and the fidelity-reviewer re-runs verify-193 at both ends (~0.6M).
demo-producer: skipped — the tech-lead deferred it on budget: the founder watches his own rudra run and its receipt; the summary records both (~0.3M).
