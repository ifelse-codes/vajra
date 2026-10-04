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

## Carried in
- **F113, F110** (above) · S182 pass-2 recs 1, 2, 5.
- **Parked by the founder:** F67 (receipt ~5×; rudra S17 read ~$110.63), non-Claude tools (F91, F94, F95),
  release/publish. F109 (rudra's download before a terms check) is NOT Vajra's — founder, 2026-10-04.
- `scripts/verify-session-132.sh` `advance-really-binds-on-an-unjudged-obeyed` is red at e1c348e and after
  (S184 fakest green) — a stale check or a real regression? Say which.
- Founder decisions to respect: no per-claim `obeyed:` judge (2026-10-03); Vajra's close does not run
  `cargo test` (2026-10-04); no new policing of Vajra's own paperwork (2026-09-15).

## Guardrails
- No Vajra code. A finding is written down, not fixed.
- The founder signs off the report before code resumes.

## Delta
- `+` `sessions/session-185-ground-truth.md`
- `+` a chosen fix for F113 and F110 (design only)
- `-` nothing removed
