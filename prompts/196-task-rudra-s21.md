# Session 196 — INTERACTIVE: rudra session 21 on Opus, synced — F121 and F123 live

> **Status:** DRAFT — written by the S195 agent from the founder's pick (2026-10-12: option A of
> `sessions/session-195-ground-truth.md`, "rudra S21 on Opus, synced"). The founder reads it and runs
> `vajra approve 196` in his own terminal; the gate reads the record, not this line.

## Type
session_type: INTERACTIVE
- **INTERACTIVE** (gets the CODE checks). Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The founder runs rudra S21 himself under `vajra claude` on **Opus**, after syncing rudra, and brings what happened;
  this session lists the findings with him and fixes what he says yes to.

## Goal
S194 shipped two fixes that have only run against a stand-in `claude` (S194's fakest green): **F121** (the exit box
shows the close check — RED with the failed names, or GREEN) and **F123** (`.githooks/pre-merge-commit` stops a merge
commit on main). rudra S21 is their first real run. It is also the Opus half of an A/B with rudra S20 (Haiku 4.5):
same project, same rules — do the instruction-only steps (tech-lead, cold review, `vajra next`) run on Opus, and does
the founder see the close's verdict before he merges? S195's answer to "can the founder be confident yet?" was
"cost: yes · close: not yet" — this run decides the close half.

## Before rudra S21 starts (founder, in order)
1. S195 merged, main synced (`git checkout main && git fetch --prune && git pull --ff-only`), `git branch -d
   session-195-closeout`, `cargo install --path .` (no `src/` change since S194, but the binary must be S194's or
   later for F121).
2. In rudra: `vajra init --sync-fleet` — brings F121's result file (scaffold close check), F123's `pre-merge-commit`,
   F120. Commit what it writes as S21's first commit, on S21's branch.
3. `/model` → Opus for the whole run. `vajra approve 21` in rudra, from his own terminal.
4. rudra's S21 task: licensed futures data if it is ready; if not, any real rudra task the founder picks — the point
   is a real session through close, not the task itself.

## What to watch in rudra S21
Read every close log for `WAIVED`, `N/A` and `WARN` FIRST, never just PASS (S178).
- **F121 live:** on exit, the line under the receipt — `close check: GREEN …` / `RED — N of M failed (…)` / started
  but wrote no result / not run. Does it match the newest `.ai/verify/closeout/<stamp>/result`? Did the founder see it
  BEFORE he merged on GitHub (S195 design-advisor rec 3: the "only at exit" limit)?
- **F123 live:** does any merge onto rudra's local main happen, and is it stopped? (pre-push still stops the push.)
- **Opus vs Haiku (S20):** count Agent calls (tech-lead, fidelity-reviewer, others), whether `vajra next` ran,
  whether the review is a real subagent's or self-written, and what the agent told the founder at the end vs what the
  close said.
- **The receipt:** top line = Claude Code's own `cost-state` figure, nothing else beside it (F117).
- **Known bugs if seen again (F116, F118, F119, F125):** record the sighting on the existing entry — do not fix unless
  the founder says so (the known-bug session is S197).

## Deliverables
1. A findings list from rudra S21 (`F126…`), each with evidence (log line, file, commit) and the founder's call
   (fix / park / not a problem).
2. The F121 and F123 live results recorded against their result file and git state, and the Opus-vs-Haiku comparison
   (Agent calls, review provenance, the end-of-run claim vs the close verdict).
3. Fixes for every finding the founder says yes to, each with a test that fails without it.

## Acceptance
| AC | Check |
|---|---|
| AC1 | Every finding has evidence and a founder call recorded in the summary. |
| AC2 | F121's exit line from the real run is recorded beside the result file it read (verdict, pass/fail counts, failed names); F123 recorded as fired / not exercised. |
| AC3 | The Opus-vs-Haiku table: Agent calls, `vajra next` used, review real or self-written, the agent's last claim vs the close verdict — from rudra S21's own logs and S194's summary. |
| AC4 | Every fix has a real-run check in `scripts/verify-session-196.sh` (no source greps), red at the start commit. |
| AC5 | No Vajra commit touches rudra; rudra's own commits are the founder's. `cargo test` passes in full before push. |

## Design
design-significant: no
- No change is approved before the run. If a finding the founder says yes to changes a shared rule (the receipt box,
  the git belt, the handoff contract, the guards), switch this to `yes`, dispatch the design-advisor narrowly, and
  record an addendum on ADR-0004 / DECISION-007 / DECISION-011 (S194 tech-lead rec 5 pattern).

## Carried in
- **From S195 (founder-approved report):** F125 → S197 first (design: the `-closeout` opening needs a founder
  `vajra approve NN --close` record; amends DECISION-011; N17 the no-`session-NN` branch hole with it) · F116, F118,
  F119, N10 (`# source-claim:` marker) → S197 · F121's next step (a Stop hook showing the newest unseen result) only
  after this run proves the exit line · F123's routes kept named · Haiku answer: (c) a README "tested with" fact in the
  founder's words, then (d) Vajra runs the required reviewer itself (its own design session) · N14 one GT question on
  "what did the agent tell the founder at close" · N15 `--stations` read on rudra at the next GT.
- **Founder rulings:** read the tool's own cost, never grow the price list; one release-coordinator judges all
  `obeyed:` answers; the close does not run `cargo test` separately (run it in full before pushing); no new policing
  of Vajra's own paperwork; release not yet.
- **Kept in backlog:** the rest of N7; F97's opt-out key; `tests/gt_cadence_shared.rs`'s loose assertion; S188's
  named gaps; S192 review rec 6; `/clear` + a fork's own share (named). **Dropped (S195, founder):** N11, verify-131's
  two stale checks. **Parked:** non-Claude tools (F91/F94/F95); release.
- **Next ground truth: S200** (derived, `scripts/lib-ground-truth.sh`).

## Guardrails
- No paid run by the agent without the founder's yes. No transcript or run capture committed (S126).

## Plan
<the S196 agent writes this after the tech-lead>

## Delta
- `+` rudra S21 findings (F126…) with the founder's calls
- `+` F121 and F123 live results; the Opus-vs-Haiku comparison
- `~` whatever they show is wrong

## Advice
