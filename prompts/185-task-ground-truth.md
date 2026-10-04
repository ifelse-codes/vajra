# Session 185 — Ground Truth (no code): the every-5th review, F113 and F110 first

> **Status:** DRAFT — written by the S184 agent from the founder's pick (2026-10-04: "yes next session 185 is
> review"). He approves it with `vajra approve 185` in his own terminal; the gate reads the approval record.

## Type
session_type: GROUND_TRUTH
- **NO-CODE.** Derived as the next review-only session by `scripts/lib-ground-truth.sh` (every 5th; S180 was
  the last). No Vajra source edits · no commits except the report on a housekeeping branch · no PRs besides it.
- A finding is written down with a severity and a proposed fix, not fixed. The founder signs off before code resumes.

## Goal
0. **FIRST ITEMS — the founder said "an issue, we fix it" (2026-10-04); pick the fix here, build it after.**
   - **F113 — a project's own session 132 starts BLOCKING unchecked `obeyed:` claims.** The threshold
     (`OBEYED_JUDGMENT_FROM_SESSION = 132`, `src/obeyed/mod.rs`) counts the project's sessions in Vajra's
     numbering, against the founder's 2026-10-03 "not a blocking gate for projects". DECISION-007's S134
     addendum already names this mistake for the design-advisor threshold and lists the options: an
     adoption marker in the project, the prompt's git birth date, or dropping the threshold for projects.
     Which, and does the design-advisor threshold (same units) need the same fix? No text guessing (S177).
     With the fix, restore the honest disclosure F107 removed (S184 cold review rec 4): the comment at
     `src/obeyed/mod.rs` ~517 still says the exemption is "stated out loud", and verify-132's
     `pre-threshold-warns-and-names-the-exemption` no longer checks that it is named.
   - **F110 — the approvals guard false-blocks text.** A command whose TEXT names the approvals folder next to
     a redirect is blocked — a heredoc counts, and so did the `<…>` in a commit sign-off. Hit three times on
     2026-10-04 (rudra S17 once, S184 twice); every agent worked around it in seconds. Weigh with S182's
     parked pass-2 recs (ROADMAP S182 row): rec 1 `..` segments get past it, rec 2 whole-group append in
     `merge_claude_settings`, rec 5 unlisted write commands (`find -delete`, `git checkout --`, `rsync`,
     `curl -o`). Guard changes only ADD (S173): fix a false block in what the guard reads, never by hiding
     text from it.
1. **Audits** (the live list: `CONSTRAINTS.yaml#ground_truth.required_audits`), one or two lines each,
   🟢/🟡/🔴, `delivery_progress` first: what reached a user since S180, and is Vajra on track?
2. **The rudra loop since S180** (rudra S16, S17): 5 + 3 Vajra fixes landed (S183, S184); rudra reached 8 of 8
   stations for the first time in S17. Is the loop still finding Vajra defects worth its cost, or mostly
   rudra's own? (S184: of F109–F113, three were rudra's.)
3. **Point at the user:** the shortest path from here to a stranger getting value (0.2.0 is still not on crates.io).

Output: `sessions/session-185-ground-truth.md`. New findings listed with a severity for S186.

## Deliverables
> Added at close (2026-10-04) so the Analyst gate can read this ground truth: it restates Goal 0–3 and
> the Output line above, with no new requirement (S185 finding N8 — S180 hand-typed `.ai/SESSION` instead).
1. `sessions/session-185-ground-truth.md` with a chosen design for F113 and F110 (+ S182 recs 1, 2, 5).
2. Every audit in `CONSTRAINTS.yaml#ground_truth.required_audits`, 🟢/🟡/🔴, `delivery_progress` first.
3. A verdict on the rudra loop since S180, weighed against its cost, and the shortest path to a stranger getting value.
4. F114 sized and F115 answered (stale or regression), new findings with a severity for S186.

## Acceptance
1. The report names one pick for F113 and for F110, each with the rejected options and why.
2. The report has one row per required audit with a 🟢/🟡/🔴 and live evidence.
3. F115 says "stale" or "regression" with the command output that decides it.
4. The founder signs the report off before code resumes.

## Carried in
- **F113, F110** (above) · S182 pass-2 recs 1, 2, 5.
- **Parked by the founder:** F67 (receipt ~5×; rudra S17 read ~$110.63), non-Claude tools (F91, F94, F95),
  release/publish. F109 (rudra's download before a terms check) is NOT Vajra's — founder, 2026-10-04.
- **F114 (founder: fix later):** in a fresh `vajra init` project with no review files, `scripts/verify-closeout.sh
  --ledger` prints nothing and exits 1 (`set -euo pipefail` + an `ls` glob with no match in
  `_ledger_worktree_sessions`). A first-run defect — size it and slot the fix.
- **F115:** `scripts/verify-session-132.sh` `advance-really-binds-on-an-unjudged-obeyed` is red at e1c348e and
  after — the check that the obeyed gate really stops `--advance`. A stale check or a real regression? Say which.
- Founder decisions to respect: no per-claim `obeyed:` judge (2026-10-03); Vajra's close does not run
  `cargo test` (2026-10-04); no new policing of Vajra's own paperwork (2026-09-15).

## Design
design-significant: yes
- Cites `docs/decisions/DECISION-007-*.md` and `docs/decisions/DECISION-011-*.md`. This NO-CODE session picks designs S186 builds: F113 `obeyed_blocks_from:` (DEVIATES from DECISION-007's S132 clause — 132+ blocks only where the key is declared); F110 option (b), the guard reads the real redirect target and fails closed (DECISION-011, guard changes only add). Detail: the report's Goal 0.

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `design-advisor` and `release-coordinator` (required by the tech-lead), `fidelity-reviewer` (the one cold close review, ACCEPT 5 of 8 SHIPPED · 3 PARTIAL — the tech-lead deferred it for budget; the close gate requires it in every session, so it was dispatched with a narrow brief). No code and no commits before close, so no `obeyed:` line: every adopted rec is built in S186 or was done in the report.

**tech-lead** (`.ai/handoffs/session-185-tech-lead.md`):
- tech-lead rec 1 — deferred: prompts/186-task-s185-fixes.md
  why: adopted: F113 = `obeyed_blocks_from:`, the 133 threshold keeps its number with honest words, the disclosure and verify-132 check restored — S186 deliverable 1; the choice is in the report's Goal 0.
- tech-lead rec 2 — deferred: prompts/186-task-s185-fixes.md
  why: adopted as F110 option (b), the founder's pick 2026-10-04 — S186 deliverable 2. Differs on one point: recs 2/5 get fixes, not only a severity (the founder's own controls, not Vajra's paperwork; founder yes) — S186 deliverable 3.
- tech-lead rec 3 — deferred: sessions/session-185-ground-truth.md
  why: done in the report: F115 run with binaries built at e1c348e^ and e1c348e, both red on the Crew gate → stale since S135; F114 reproduced and sized XS → S186 deliverables 4–5.

**design-advisor** (`.ai/handoffs/session-185-design-advisor.md`):
- design-advisor rec 1 — deferred: prompts/186-task-s185-fixes.md
  why: S186 deliverable 1 (the key, absent → WARN forever, never scaffolded).
- design-advisor rec 2 — deferred: prompts/186-task-s185-fixes.md
  why: S186 deliverable 1 (malformed/empty/duplicate → BLOCK naming the line) and AC1.
- design-advisor rec 3 — deferred: prompts/186-task-s185-fixes.md
  why: S186 deliverables 1 and 5 (the WARN wording, the comment at ~517, verify-132's check).
- design-advisor rec 4 — deferred: prompts/186-task-s185-fixes.md
  why: S186 deliverable 1 (133 keeps its number; only `src/mandate/mod.rs:428`'s words change).
- design-advisor rec 5 — refused: the founder chose option (b) over message-only on 2026-10-04 (report, Founder rulings). Its message is kept for whatever (b) still blocks — S186 deliverable 2.
- design-advisor rec 6 — deferred: prompts/186-task-s185-fixes.md
  why: this IS option (b), with every fail-closed rule — S186 deliverable 2 and AC2.
- design-advisor rec 7 — deferred: prompts/186-task-s185-fixes.md
  why: S186 deliverable 3 (`..` in both checks; the line-43 comment deleted) and AC4.
- design-advisor rec 8 — deferred: prompts/186-task-s185-fixes.md
  why: S186 deliverable 3 (`merge_claude_settings` pushes only missing hooks) and AC5.
- design-advisor rec 9 — deferred: prompts/186-task-s185-fixes.md
  why: S186 deliverable 3 (writers list) and AC4.
- design-advisor rec 10 — deferred: prompts/186-task-s185-fixes.md
  why: S186 deliverable 3 (shells/eval/source/xargs on the interpreter list) and AC4.
- design-advisor rec 11 — deferred: prompts/186-task-s185-fixes.md
  why: S186 AC3 (the corpus test against the e1c348e guard).
- design-advisor rec 12 — deferred: prompts/186-task-s185-fixes.md
  why: S186 Design section: S185/S186 addenda to DECISION-007 and DECISION-011, no new record.

**release-coordinator** (`.ai/handoffs/session-185-release-coordinator.md`):
- release-coordinator rec 1 — deferred: sessions/session-185-summary.md
  why: done: the founder approved the report on 2026-10-04 (report, Founder rulings).
- release-coordinator rec 2 — deferred: sessions/session-185-summary.md
  why: done: the founder ran `vajra approve 185`; `vajra next --advance` moved 184 → 185 after N8's two sections were added.
- release-coordinator rec 3 — deferred: sessions/session-185-summary.md
  why: done: the branch was renamed to `session-185-closeout` before any prompt write or commit.
- release-coordinator rec 4 — deferred: sessions/session-185-summary.md
  why: the one founder-run commit script, in its order, leaving out the four local files — at the end of the summary.
- release-coordinator rec 5 — deferred: sessions/session-185-summary.md
  why: `scripts/verify-closeout.sh` on the closeout branch before merge — its final result is pasted in the summary.
- release-coordinator rec 6 — deferred: sessions/session-185-summary.md
  why: the founder opens and merges the PR, then main is synced and the branch deleted — the summary's ship steps.

**fidelity-reviewer** (`.ai/handoffs/session-185-fidelity-reviewer.md`):
- fidelity-reviewer rec 1 — deferred: sessions/session-185-ground-truth.md
  why: done after the review: Goal 2 now prices the loop (~$39 real, ~2 h of founder time, ~$6.50 / ~20 min per Vajra defect); Deliverable 3 says "weighed against its cost".
- fidelity-reviewer rec 2 — deferred: sessions/session-185-ground-truth.md
  why: done: the sign-off is labelled the founder's chat reply transcribed by the agent; the gap is finding N9.
- fidelity-reviewer rec 3 — deferred: sessions/session-185-ground-truth.md
  why: done: dogfood_check 🟡 "from summaries"; dogfood_staleness one colour, 🔴.
- fidelity-reviewer rec 4 — deferred: sessions/session-185-ground-truth.md
  why: done: the F113 table's "vs your 2026-10-03 ruling" row — the ruling was for projects; Vajra keeps its one batch judge.
- fidelity-reviewer rec 5 — deferred: sessions/session-185-ground-truth.md
  why: done: the stale "not in the prompt" line and the verify-132 premise are corrected (report + the next prompt's deliverable 1).

## Guardrails
- No Vajra code. A finding is written down, not fixed.
- The founder signs off the report before code resumes.

## Delta
- `+` `sessions/session-185-ground-truth.md`
- `+` a chosen fix for F113 and F110 (design only)
- `-` nothing removed
