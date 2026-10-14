# Session 198 — CODE: the known-bug leftovers — F118 and N18

> **Status:** DRAFT — written by the S197 agent from the founder's pick (2026-10-14: option 2 of
> `sessions/session-197-summary.md`, "the known-bug leftovers: F118 + N18"). The founder reads it and runs
> `vajra approve 198` in his own terminal; the gate reads the record, not this line.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story (the two leftovers) · new chat.

## Goal
Fix the two small bugs left on ROADMAP's "🐞 KNOWN BUGS — TO FIX" list after S197 — each one a thing a user meets:
`vajra next --advance` leaving the old session's text under the new number (F118), and the drift check choosing the
wrong verify scripts when the folder path has dashes (N18).

## Deliverables
1. **F118 — `vajra next --advance` moves the old `## Current Session` entry to `## Prior Session`.** Today
   `update_session_boot` (`src/cli/next.rs`) swaps only the `**Number:**` token, so the old session's whole story sits
   under the new number and drops out of `## Prior Session` (S193, S194 and S197's own advance `aad6381`, each fixed by
   hand). On a SESSION-BOOT shaped like Vajra's (a `## Current Session` with one `- **Number:** NN — …` entry, then
   `## Prior Session` blocks), the advance writes a fresh `- **Number:** NN+1 — IN PROGRESS` entry under
   `## Current Session` and puts the old entry, unchanged, as the first `## Prior Session` block. Any other shape (a
   project's own SESSION-BOOT, e.g. rudra's) keeps today's number swap and is told so on stderr — never rewritten
   by guess.
2. **N18 — `scripts/scaffold-drift.sh` check 6 picks the last 10 verify scripts by session number, not by a field
   of the full path.** Today `sort -t- -k3 -n` splits the WHOLE path on `-`, so a folder with dashes in its path
   (the old-version checkouts `…/vajra-old-checkouts/<pid>-<sha>/`) sorts the wrong field (found S197).

## Acceptance
| AC | Check |
|---|---|
| AC1 | F118: `vajra next --advance` on a temp repo whose SESSION-BOOT has Vajra's shape leaves `## Current Session` naming only the new number, and the old entry is the first `## Prior Session` block, byte-for-byte. |
| AC2 | F118: on a SESSION-BOOT without that shape, the advance still swaps the number (as today) and prints why it did not move the entry. |
| AC3 | N18: check 6 run from a folder whose path has dashes scans the same 10 scripts as from a path without dashes. |
| AC4 | Every fix has a real-run check in `scripts/verify-session-198.sh` (no source greps), red at the start commit. Full `cargo test` passes before push; the push goes through the S196 push belt (close GREEN on the pushed commit). |

## Design
design-significant: no
- F118 follows the S191 `--advance` addendum (DECISION-011 S191) and DECISION-007's step list; N18 is a one-line
  sort fix in a check script. The design-advisor is still mandatory (S133): one narrow dispatch, or a recorded
  reasoned skip.

## Carried in
- **From S197 (founder calls, 2026-10-14):** F125 + N17 fixed — the review-only guard ships to every project and only
  `vajra approve NN --close` opens it (DECISION-011 S197 addendum); F116, F119, N10 fixed. F118 was moved out of
  S197 to make room. rudra needs `vajra init --sync-fleet` and a Claude Code restart to get the guard.
- **Carried from S197 (its release-coordinator rec 1):** record whether S197's GREEN push went through the S196
  push belt — S197's tech-lead rec 6 and fidelity-reviewer rec 7 asked for it, and no S197 commit can show a push
  that happens after its own close. Write it into S197's summary (sessions/) at this session's start, from the
  founder's S197 pull-request page or `git log origin/session-197-known-bugs`. S197's full `cargo test` (735/0) is in its
  summary already (7443202).
- **Kept in backlog (ROADMAP known bugs):** S197 design-advisor rec 10 (a `--steps` line for the close record) ·
  F126 · the rest of N7 · F97's opt-out key · `tests/gt_cadence_shared.rs`'s loose assertion · S188's named gaps ·
  F123/F127's named routes. **Parked:** non-Claude tools (F91/F94/F95); release.
- **Founder rulings:** read the tool's own cost, never grow the price list; one release-coordinator judges all
  `obeyed:` answers; the close does not run `cargo test` (run it in full before pushing); no new policing of Vajra's
  own paperwork; release not yet.
- **Next ground truth: the next multiple of 5** (derived, `scripts/lib-ground-truth.sh`) — the review-only guard now
  blocks its commits until the founder's `vajra approve NN --close`.

## Guardrails
- No paid run by the agent without the founder's yes. No transcript or run capture committed (S126).
- Fixes only what is listed; a new bug found on the way is filed, not fixed.

## Plan
<the S198 agent writes this after the tech-lead>

## Delta
- `~` F118: `--advance` moves the old Current Session entry down instead of leaving it under the new number
- `~` N18: check 6 sorts by session number, not by a field of the full path

## Advice
