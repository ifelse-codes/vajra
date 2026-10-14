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
design-significant: yes
- Switched from `no` after the founder's yes to F127 (2026-10-14: "no pr creation till it is not green, till all
  review is pass from agents"). Narrow design-advisor dispatch: `.ai/handoffs/session-196-design-advisor.md`.
- F127: a PR needs a pushed branch, so the push is the one door every PR route passes (gh, the web UI, a GUI client).
  `.githooks/pre-push` refuses an AGENT's push of `refs/heads/session-NN-*` unless the newest
  `.ai/verify/closeout/<stamp>/result` whose `head:` equals the pushed sha says `verdict: GREEN`, `clean: yes`,
  `session: NN`. GREEN with WARN passes (WARN is not a fail; the count is printed). A person gets a note and the push
  goes on (founder's call, 2026-10-14 — the S171 split). Deletes, tags, non-session branches (founder 2026-09-21:
  ungoverned on purpose) and the main/master rule are unchanged — the guard only adds.
- Result format 2 (ADR-0004 S196 addendum): `head:` + `clean:` after `session:`, taken at the start and the end of
  the run (`clean: yes` only if both are clean and HEAD did not move). The binary reads 1 and 2; the hook only 2.
- Session number from the branch name, never `.ai/SESSION` or a guess. No new override (DECISION-011): the founder's
  own push is never stopped; an agent told "stop and tell the founder".
- Records: DECISION-007 S196 addendum (the push belt — primary) and ADR-0004 S196 addendum (result v2, a second
  reader). Rejected: re-running the close inside the push (minutes; time-outs) · guarding `gh pr create` by command
  text (S177/S188) · GitHub CI (rudra has none; local-first) · every branch (reverses 2026-09-21).
- Named, not closed: the agent can write a GREEN result file or type `git push --no-verify` (bar-raising, not
  tamper-proof) · untracked files are not counted in `clean:` · an inline waiver is a GREEN · a non-session branch
  name skips it (N17, S197).

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
1. Read rudra S21's close logs (WAIVED/N/A/WARN first), transcript, git and cost records; write the findings with the
   founder's calls, F121/F123 live results, the receipt and the Opus-vs-Haiku table into the summary before any code.
   covers: 1, 2, 3
2. F127 the push belt: result format 2 in both close scripts, the exit box reads 1 and 2, `.githooks/pre-push`
   refuses an agent's session-branch push without a GREEN for that commit; real-push tests in `tests/push_belt.rs`.
   covers: 4
3. The records: DECISION-007 + ADR-0004 S196 addenda; the Releaser step text and `.githooks/README.md`.
   covers: 4
4. `scripts/verify-session-196.sh` (each F127 row a real push, red at the start commit) and the demo; full
   `cargo test` before push; no commit touches rudra.
   covers: 4, 5

## Delta
- `+` rudra S21 findings (F126…) with the founder's calls
- `+` F121 and F123 live results; the Opus-vs-Haiku comparison
- `~` whatever they show is wrong

## Advice
