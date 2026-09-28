# Session 179 — `--help` that runs nothing, and a project review that asks about the project

**Type:** CODE, interactive. First Vajra's own F89 (found after S178 merged), then the founder's rudra
sessions 14 and 15, both run under **OpenCode** in one chat. **Branch:** `session-179-keep-testing`.
**Brief:** `prompts/179-task-keep-testing.md`. **Verify:** `scripts/verify-session-179.sh` — 37 pass,
0 fail, 0 skipped (old `224b349` vs new, every run in a fresh temp git repo). **Demo:**
`scripts/demo-session-179.sh` — 6 live checks, complete.

## What happened

- **F89:** `vajra init --help` ran a real setup (11 files in an empty repo; in Vajra's own repo it
  merged a second set of guard hooks). No subcommand printed its own help. rudra's agent hit it live:
  it ran `vajra next --help` twice and got the full session report. **Fixed:** `--help`/`-h` after
  `init`, `check`, `next`, `estimate`, `hook`, `meter` prints that command's help, exits 0, runs
  nothing. `claude` stays a pass-through (its flags are Claude Code's).
- **F90** (found while probing F89): `init` ignored any word it did not know, so `vajra init --dry-run`
  (a preview flag that needs `--sync-fleet`) did a full setup. **Fixed:** `init` refuses, says "nothing
  was written", and names `vajra init --sync-fleet --dry-run`.
- **S178's record corrected:** its summary blamed "something other than this session's commands" for
  the stray files; S178's own `init --help` wrote them. Summary line struck and corrected; a comment
  on PR #215 (founder yes).
- **rudra S14 + S15 (OpenCode, one chat, ~24 h wall, $1.93, 566 shell commands):** close runs fell from
  ~30 (S13) to ~5 per session — the agent took the helper-check wall to the founder as a question
  instead of re-running (S178's F86 note worked). Helper records say "unverifiable" honestly. Six new
  findings (below).
- **F93 (founder yes):** rudra S15, the first big review a scaffolded project ran, audited Vajra's
  paperwork and never asked whether rudra was on track — the founder caught it and ordered a re-run.
  Cause: `vajra init` handed the project Vajra's own checklist (3 of its 10 audits were Vajra's
  questions about Vajra; none asked what the project delivered). **Fixed:** a new `delivery_progress`
  audit; vision → roadmap → delivery lead the list and the questions; `dogfood_check` and
  `dogfood_staleness` withheld from projects with declared reasons (`build.rs` `OMIT_AUDITS`, S129's
  mechanism unchanged). rudra's copy updated by hand (uncommitted there, like S178's sync).

## Everything found

| # | What | Outcome |
|---|---|---|
| F89 | `vajra <cmd> --help` ran the command; `init --help` wrote a scaffold | HIGH — **fixed** |
| F90 | `init` ignored unknown words; `init --dry-run` did a full setup | HIGH — **fixed** |
| F91 | Under OpenCode the git guards can't tell the agent from the founder: 37 unchecked commits, a push straight to rudra's main (`5ab6e83`) | HIGH — parked until after S180 |
| F92 | S15's four waived closes labelled "Founder waiver" (he waived only S14); the waiver passes ~20 checks at once | HIGH — S180 Goal 0 |
| F93 | A project's big review asked about the tool, not the project | HIGH — **fixed in the template**; unproven until a project's next big review |
| F94 | S14 + S15 in one chat; the one-chat guard is Claude-only | MED — parked until after S180 |
| F95 | OpenCode helpers matched to unrelated old Claude Code records | MED — parked until after S180 |
| F96 | The founder asked twice for plain English | LOW — recorded |
| F97 | Existing projects don't get the new review questions: `--sync-fleet` never touches `CONSTRAINTS.yaml` | MED — recorded |
| F98 | Vajra scores a no-code big review like a coding session (station counter; the step→commit map demanded) | MED — S180 `session_type` |
| F99 | The kept stations question still says "in this repo (SHIP needs a synced origin…)" — Vajra's wording | LOW — recorded |
| F100 | `scripts/demo-session-129.sh` case 4 cannot fail (`false; break` exits 0); case 5 now fails by design | LOW — recorded |

Sources for each row: `prompts/179-task-keep-testing.md` `## Findings`.

## Fidelity — every deliverable

| # | Item | Grade (independent, `sessions/session-179-review.md`) | Evidence |
|---|---|---|---|
| D1 / AC1 | every `vajra <cmd> --help`/`-h` prints help, writes nothing | SHIPPED | `src/main.rs` `subcommand_usage`; verify AC1, 16 checks; `tests/cli_front_door.rs` |
| D1b / AC1b | `init` refuses unknown words, writes nothing | SHIPPED | `src/cli/init.rs` `check_init_args`; verify AC1b, 8 checks |
| D2 / AC2 | a project's review leads with the project | SHIPPED (D2) · PARTIAL→fixed (AC2: rudra's `vajra check` unproven → proven in dd73c80) | `.ai/CONSTRAINTS.yaml`, `build.rs`, `src/cli/init.rs`; verify AC2, 10 checks; scaffold-drift exit 0 |
| Plan 3 | S178's record corrected | PARTIAL→fixed (PR #215 comment recorded, dd73c80) | `sessions/session-178-summary.md:80`; PR #215 comment |
| Plan 4 | rudra S14/S15 read, findings listed with the founder | PARTIAL→fixed (brief's questions answered; F98–F100 added, dd73c80) | `## Answers`, findings F91–F100 |

## Review

One cold pass (`fidelity-reviewer`, read-only): **ACCEPT — 10 of 16 SHIPPED, 6 PARTIAL, 0 NOT-BUILT.**
"The code part of the contract is done in full … the session falls short on its records, not its code."

- Recs 1, 2, 3, 4, 7, 8 (records) — done in dd73c80: rudra's `vajra check` proven unchanged on two
  throwaway copies; F93 scoped to "fixed in the template, unproven until a project's next ground
  truth"; the brief's S15 questions answered; F98–F100 added; the S129 reversal named.
- Recs 5, 6 (code) — **deferred to S181** (founder option B): the top-level `vajra --help` line
  "<command> --help … run nothing" has no exception for `claude`; one test cannot fail as written.
  Code after an ACCEPT needs a fresh review (F81); the founder chose to close on one review.
- The partials the review found in guardrails: a new help line that is a small false absolute (rec 5,
  deferred), and the S129 ruling reversed without saying so (named now).

## What this does NOT claim

- **Existing projects are not upgraded (F97).** Only new projects and rudra (by hand) get the new
  review questions. A stranger gets F89/F90/F93 only after the next crates.io release; the founder's
  installed `vajra` needs a rebuild.
- **Unknown flags on other commands are still swallowed.** `vajra next --advnce` prints the handoff
  packet instead of refusing (read-only, so nothing is written). Only `init` refuses now.
- **The new delivery questions are text.** Nothing checks that a big review answers them — by design:
  no new check on paperwork (founder, 2026-09-15).
- **Nothing about other coding tools was fixed** (F91, F94, F95 — founder: after S180).
- A stale build cache once served the old scaffold during the build; a clean rebuild fixed it. The
  verify script builds OLD in its own target dir.

## The fakest green here

**F93 marked fixed** (the reviewer's pick). Every Acceptance 2 check reads file text — the list's
first three names, where the question blocks sit, one delivery question present. They would all pass
if no project's big review ever asked what the project delivered. And rudra S15's first attempt
answered 0 of its 10 audits while `vision_alignment` was already first, so order was not the whole
cause. The row now says "fixed in the template, unproven until a project's next ground truth".

Runner-up: `init_sync_fleet_dry_run_still_works` compares `git status` in a repo whose scaffold is
uncommitted, so writes inside `?? .ai/` would not show (rec 6, deferred to S181).

## Ship steps (release-coordinator recs 1–9)

- rec 1 — reviewer handoff + review file recorded, summary filled, staged by path (`.claude/launch.json`, `first-mate.html`, `sessions/session-137-scatter-render.html`, `vajra-cto-audit-2026-07-22.html` stay out).
- rec 2 — founder ruling (option A): check-script checks the review asked for are evidence, not code; nothing under `src/` changed after the ACCEPT. The stamp is computed after the last prompt commit, never typed.
- rec 3 — answered in `## Advice`; steps 7–9 come after the merge.
- rec 4 — `cargo install --path .` from the branch head, then the full `scripts/verify-closeout.sh` on the branch, exit 0, logs read for WAIVED/N/A — BEFORE the PR (S83). If interrupted: `git -C ~/playground/rudra worktree prune`.
- rec 5 — push + PR; the body names recs 5/6 → S181, rudra's uncommitted edit, F93 unproven until a project's next ground truth.
- rec 6 — the founder merges by hand, while green, with a merge commit (not squash).
- rec 7 — after the merge: `git checkout main && git fetch origin && git pull --ff-only`.
- rec 8 — `git branch -d session-179-keep-testing`, `git push origin --delete session-179-keep-testing` (F71), `git fetch --prune`.
- rec 9 — rudra's next agent commits the hand-edited `.ai/CONSTRAINTS.yaml` first. Founder's call, raised not scheduled: a crates.io release so strangers get F89/F90/F93.

## Cost

Interactive. The founder's rudra S14/S15 run: OpenCode reports $1.93 (mostly a free model;
`glm-5.3` hit its usage limit and was swapped mid-run). No Vajra receipt (not launched via `vajra`).
Fleet dispatches here: tech-lead, fidelity-reviewer (one pass; a follow-up asking it to judge was cut off by a safety check, no output), release-coordinator (judge of the obeyed lines + ship steps, beyond the tech-lead's crew — disclosed).

## 3 ranked next candidates

1. **(Recommended) Session 180 — the ground truth (no code), Goal 0 first.** Already booked. The
   founder's controls the agent can type (F77–F80, F84, F85, now F92), and the first big review with
   `delivery_progress` leading. Risk: a design session with no code; the answer may be "stop and
   rethink".
2. **After S180 — brainstorm Vajra on coding tools other than Claude Code (F91, F94, F95).** Two
   sessions ran under OpenCode with the guards blind. Risk: a large design; it may end as "Vajra is a
   rulebook + end check off Claude Code, and says so".
3. **Finish the 0.2.0 release.** crates.io still serves 0.1.0, so a stranger gets none of S167–S179,
   including today's `--help` fix. Risk: founder-only steps; S180 may change what 0.2.0 should claim.
