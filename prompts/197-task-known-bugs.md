# Session 197 — CODE: the known-bug session — F125 first, then F116, F118, F119, N10

> **Status:** DRAFT — written by the S196 agent from the founder's pick (2026-10-14: option 1 of
> `sessions/session-196-summary.md`, "S197 — the known-bug session"). The founder reads it and runs
> `vajra approve 197` in his own terminal; the gate reads the record, not this line.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story (the known-bug list) · new chat. If F125's design grows,
  split F118 out to a later session rather than run long (S195 risk note).

## Goal
Fix the bugs parked on ROADMAP's "🐞 KNOWN BUGS — TO FIX" list that the S195 ground truth sent here — each one a
thing a user meets — with F125 first, because it lets an agent switch off the review-only guard by naming its branch.

## Founder call in-session (2026-10-14)
- **F125's premise was wrong.** Found at the start of S197: user projects never HAD the review-only no-code guard.
  It lives only in Vajra's own `scripts/hook-pre-bash.sh` / `hook-pre-write.sh`; `vajra init` / `--sync-fleet`
  ship neither (rudra's `.claude/settings.json` + `.ai/hooks/` have no ground-truth block at all). So rudra S20's
  `-closeout` branch switched nothing off — the rule was text only. The founder chose: **ship the guard to every
  project**, with `vajra approve NN --close` as the only way to open it (Vajra too), and **move F118 out** to make room.

## Deliverables
1. **F125 + N17 — the review-only guard cannot be switched off by a branch name the agent picks.** Today
   `hook-pre-bash.sh`'s `*-closeout) GT=0` turns the ground-truth guard off on any `-closeout` branch (rudra S20 made
   one before any work), and a branch with no `session-NN` in its name leaves `GT` at 0 too (N17). Design first
   (`design-significant: yes`, a DECISION-011 addendum): S195's pick is that the `-closeout` opening needs a founder
   `vajra approve NN --close` record; the design-advisor also weighs "the session's ground-truth report already
   committed" (the ROADMAP fix idea). N17 is fixed with it or named with a reason.
2. **F116 — the approval record is left out of git at close.** `vajra next --steps` / boot say "approved ✓ — not in
   git yet; commit it with the session" (a reminder, not a block). Seen in rudra S19, S21 and Vajra's own S192.
3. **F118 — MOVED OUT by the founder (2026-10-14, above): stays on ROADMAP's known-bug list for a later session.**
   Was: **`vajra next --advance` leaves the old session's text under the new number.** The advance moves the old
   `## Current Session` entry down to `## Prior Session` instead of number-swapping it in place (Vajra's own
   SESSION-BOOT layout; a project with another shape is left alone and told).
4. **F119 — the step list shows ✗ for design when the prompt says none is needed.** `--steps` agrees with
   `--check-design` for `design-significant: no`; the how-to no longer tells the agent to cite a record it does not need.
5. **N10 — `scaffold-drift.sh` check 6's false alarm.** A line may opt out with `# source-claim: <why>` on the line
   itself (S195 design-advisor rec 5); check 6 stays, and the three current false alarms carry the marker.

## Acceptance
| AC | Check |
|---|---|
| AC1 | F125: in a temp `vajra init` project (and after `--sync-fleet` on an older one), a ground-truth session's code edit / commit / push / PR is blocked — on a `-closeout` branch too — until the founder's `vajra approve NN --close` record exists; with it, it opens. A branch with no `session-NN` (N17) is blocked or its gap named in the addendum. Real runs. |
| AC2 | F116: `vajra next --steps` names an approval record that exists but is not in git, and stops naming it once committed. |
| AC3 | F118 moved out (founder, 2026-10-14): ROADMAP's known-bug list still names it, with the founder's call and no session number claimed fixed. |
| AC4 | F119: `--steps NN` shows ✓ for design on a `design-significant: no` prompt that `--check-design NN` calls READY. |
| AC5 | N10: `bash scripts/scaffold-drift.sh` exits 0 on Vajra; a hollow source grep without the marker still fails check 6. |
| AC6 | Every fix has a real-run check in `scripts/verify-session-197.sh` (no source greps), red at the start commit. Full `cargo test` passes before push; the push itself goes through the S196 push belt (close GREEN on the pushed commit). |

## Design
design-significant: yes
- F125 changes a guard and the approvals contract (DECISION-011). Dispatch the design-advisor narrowly on F125 + N17
  before coding; record a DECISION-011 S197 addendum. F116/F118/F119/N10 are small and follow existing records
  (DECISION-011 S188 for approvals, DECISION-007 for the step list); the design-advisor says whether any needs more.

## Carried in
- **From S196 (founder calls, 2026-10-14):** F127 shipped — the push belt (`.githooks/pre-push`, DECISION-007 S196
  addendum) stops an agent's push of a session branch without a GREEN close for that commit; this session's own push
  is its first real GREEN push (the S196 review's fakest green: no real GREEN has yet passed it). A branch not named
  `session-NN-…` skips the push belt by the founder's 2026-09-21 rule, kept on 2026-10-14 — **not** part of N17's fix
  unless he says so. F126 parked (ROADMAP known bugs, S200 checklist).
- **Founder question still open (S196 release-coordinator rec 6):** delete the old remote branches
  `session-165-closeout` and `session-187-closeout` on GitHub? Not a step.
- **Founder rulings:** read the tool's own cost, never grow the price list; one release-coordinator judges all
  `obeyed:` answers; the close does not run `cargo test` (run it in full before pushing); no new policing of Vajra's
  own paperwork; release not yet.
- **Kept in backlog:** the rest of N7; F97's opt-out key; `tests/gt_cadence_shared.rs`'s loose assertion; S188's
  named gaps; S192 review rec 6; `/clear` + a fork's own share (named); F121's Stop-hook follow-up; F123/F127's named
  routes. **Parked:** non-Claude tools (F91/F94/F95); release.
- **Next ground truth: S200** (derived, `scripts/lib-ground-truth.sh`).

## Guardrails
- No paid run by the agent without the founder's yes. No transcript or run capture committed (S126).
- Fixes only what is listed; a new bug found on the way is filed, not fixed.

## Plan
1. F119: `--steps` ticks design when the prompt records `design-significant: no` (the `--check-design` reading).
   covers: 4
2. F116: `--steps` names an approval record that is not in the last commit, until it is; this session's own
   record is the live case.
   covers: 2
3. N10: `scaffold-drift.sh` check 6 skips a line carrying `# source-claim: <why>`; the three current lines carry it.
   covers: 5
4. F125 + N17 record: the DECISION-011 S197 addendum (design-advisor's text), committed before the guard code.
   covers: 1
5. F125 the opening: `vajra approve NN --close` writes `session-NN-close.json`; `vajra next --check-close-record NN`
   reads it the way an approval is read (void, lower-case); unit tests.
   covers: 1
6. F125 + N17 the guard: `scripts/hook-ground-truth-guard.sh` (the GT parts of hook-pre-bash/pre-write, no suffix
   exemption, no `VAJRA_GT_WAIVER`, an unnumbered branch uses HEAD's `.ai/SESSION` + 1); Vajra's two hooks call it;
   `vajra init` / `--sync-fleet` ship and wire it; the boot hooks drop the suffix too; AGENTS.md text.
   covers: 1
7. F118 moved out: ROADMAP's known-bug list keeps it, with the founder's call.
   covers: 3
8. `scripts/verify-session-197.sh` — real runs, each red at eceb6d5; full `cargo test` before push; push through
   the S196 belt after a GREEN close.
   covers: 6

## Execution
- step 1 — done: 336786d
- step 2 — done: 946a967
- step 3 — done: 34cebf4

## Delta
- `~` F125 + N17: the `-closeout` opening needs something the agent cannot type
- `~` F116, F118, F119, N10 fixed
- `+` a DECISION-011 S197 addendum

## Advice
