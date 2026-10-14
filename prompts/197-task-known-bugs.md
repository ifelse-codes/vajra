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
- step 4 — done: efd7ad2
- step 5 — done: 140542b
- step 6 — done: 8f32889
- step 7 — done: b3695d4
- step 8 — done: 9c494c7

## Delta
- `~` F125 + N17: the `-closeout` opening needs something the agent cannot type
- `~` F116, F118, F119, N10 fixed
- `+` a DECISION-011 S197 addendum

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `design-advisor` (required — F125 + N17, before any guard code).
Required at close: `fidelity-reviewer` (the one cold review), `release-coordinator` (the one judge of every
`obeyed:` answer).

researcher: skipped — the tech-lead deferred it on budget: every bug's evidence was already in ROADMAP's known-bug list and the S195 ground truth (~0.2M; crew ~1.9M → ~2.1M).
requirements-analyst: skipped — the tech-lead deferred it on budget: the founder picked this list and AC1–AC6 give one real-run check per bug (~0.15M would restate it).
plan-advisor: skipped — the tech-lead deferred it on budget: the order was set by the prompt and the plan is short fixes, each with `covers: N` (~0.15M).
implementation-advisor: skipped — the tech-lead deferred it on budget: the design-advisor named files and test rows down to line numbers; tech-lead recs 4–6 name the traps (~0.4M).
qa-specialist: skipped — the tech-lead deferred it on budget: AC6 makes every verify row a real run, red at eceb6d5, and the fidelity-reviewer reads verify-197 at close (~0.4M).
demo-producer: skipped — the tech-lead deferred it on budget: bug fixes shown in verify output and the summary; the demo is the template's seven sections with live hook runs (~0.2M).

**tech-lead** (`.ai/handoffs/session-197-tech-lead.md`):
- tech-lead rec 1 — obeyed: efd7ad2 (the design-advisor ran before any F125 code; the DECISION-011 S197 addendum committed before the record command 140542b and the guard 09b7c39)
- tech-lead rec 2 — obeyed: 140542b (`vajra approve NN --close` writes a record in `.ai/approvals/`, read with the same void rules as an approval; the S188 before/after check catches a forged one with no new code — verify row 5)
- tech-lead rec 3 — obeyed: 8f32889 (the founder widened it: projects had no copy, so the guard now ships via `vajra init` / `--sync-fleet` and is wired in settings; Vajra's two hooks call the same file, 09b7c39; AC1 proven in temp `vajra init` projects, 9c494c7)
- tech-lead rec 4 — obeyed: 9c494c7 (11 rows, each a real run of the built binary or the scaffolded hook, each red at eceb6d5 for its own reason; AC5 has both halves: exit 0 here, an unmarked and a reason-less grep still fail)
- tech-lead rec 5 — obeyed: 3b50dc9 (`.ai/approvals/session-197.json` committed; `--steps` named it before that commit and not after — the live case)
- tech-lead rec 6 — obeyed: 048805a (full `cargo test` 735 passed / 0 failed at the tip, recorded in the summary; the order stamp → close → push is followed at close, and the summary records whether the belt let the GREEN push through)
- tech-lead rec 7 — obeyed: 2bd229e (F118 moved out in writing — the founder's call when F125 widened; ROADMAP keeps it with a destination, b3695d4)
- tech-lead rec 8 — obeyed: 2bd229e (the design-advisor recorded from its handback text before the build; one fidelity-reviewer and one release-coordinator after this section; `## Delta` above `## Advice`; the skip lines above carry the money reasons)

**design-advisor** (`.ai/handoffs/session-197-design-advisor.md`):
- design-advisor rec 1 — obeyed: 09b7c39 (one `scripts/hook-ground-truth-guard.sh` holding the moved checks, called by Vajra's two hooks after the approvals guard) and 8f32889 (shipped as `.ai/hooks/hook-ground-truth-guard.sh`, a second entry in the PreToolUse `Bash|Edit|Write|MultiEdit|NotebookEdit` group, no Post group)
- design-advisor rec 2 — obeyed: 140542b (`session-NN-close.json`, method `close-command`, same refusals as `vajra approve`, un-lists only its own name; a unit test pins that `vajra approve MM` never un-lists it)
- design-advisor rec 3 — obeyed: 140542b (`vajra next --check-close-record NN`, exit 0/1, one reader of the void) and 09b7c39 (no `vajra`, an error, or an older binary that ignores the flag → closed: the hook needs the exact sign-off line, not exit 0 alone — verify row 4)
- design-advisor rec 4 — refused: its "session-start says so when the record counts" half — the boot hook does not call the binary, and the guard's own block message already says why it is closed and how it opens; the rest is built: the `-closeout` / `-enforcement` exemptions removed from all four hooks (09b7c39, 0c41f5f), AGENTS.md's section text and Hard Rule reworded (8f32889), and the reminder names `vajra approve NN --close` (0c41f5f).
- design-advisor rec 5 — obeyed: 09b7c39 (`VAJRA_GT_WAIVER` no longer read by any guard; named retired in the addendum, efd7ad2)
- design-advisor rec 6 — obeyed: 09b7c39 (no `session-NN` in the branch → HEAD's committed `.ai/SESSION` + 1, else the working-tree file, else the guard is on — verify row 6 edits the working-tree file to 9 and is still guarded as session 5)
- design-advisor rec 7 — obeyed: efd7ad2 (the wrong-number branch named in the addendum's Limit list, not fixed)
- design-advisor rec 8 — obeyed: 09b7c39 (the allowlist moved unchanged; verify row 3: `src/` blocked, the report and `.ai/` written, 9c494c7)
- design-advisor rec 9 — obeyed: 09b7c39 (no close-gate row; L1 warns, L2/L3 block; `VAJRA_GUARD_MATURITY` read; the jq preflight kept; only the close record opens it — not `--allow-all` or `VAJRA_APPROVE`)
- design-advisor rec 10 — deferred: .ai/ROADMAP.md
- design-advisor rec 11 — obeyed: 9c494c7 (every listed case is a verify row in a temp `vajra init` project, red at eceb6d5)
- design-advisor rec 12 — obeyed: 336786d (F119 reuses `architect::design_gate`), 946a967 (F116 follows the S187 step) and 34cebf4 (N10: no record covers check 6 yet — said in the script's own comment)
