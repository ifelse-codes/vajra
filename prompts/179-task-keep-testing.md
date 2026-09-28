# Session 179 — rudra sessions 14 + 15 under OpenCode: find what went wrong, fix F89

> **Status:** APPROVED — the founder, 2026-09-28, in the S178 chat: "ok use opencode for rudra 14 and
> 15 already done … we need to check it and find issue and trouble". Written by the S178 agent at the
> founder's request (disclosed: F77 — an agent wrote this line; the founder's words above are the
> approval). Written on `main` as an untracked file; commit it on the S179 branch.

## Type
- **CODE**, interactive. The founder already ran rudra sessions 14 and 15 under **OpenCode** (not
  `vajra claude`). This session reads what happened, lists the findings with the founder, and fixes
  what he says yes to.
- **Not a ground-truth session.** `.ai/CONSTRAINTS.yaml#ground_truth_next_session: 180`.

## Where rudra is (checked 2026-09-28)
- **rudra S14** (`prompts/14-task-ordering-witness.md` there): PR #17 **OPEN, not merged**
  ("Session 14: the promise is provably first, and the key is ours (ORDERING_GREEN)").
- **rudra S15** — rudra's own ground truth (`ground_truth_next_session: 15`, NO-CODE):
  `sessions/session-15-ground-truth.md`, review with "both REJECTs recorded, the canonical ACCEPT
  added". On local branch `session-15-ground-truth-closeout`; **not merged, no PR yet.**
- rudra S16 prompt exists (`prompts/16-task-measure-an-edge.md`).
- OpenCode transcripts: `~/.local/share/opencode/opencode.db` (SQLite); export one with
  `opencode session export <ses_id>`. Vajra cannot read these (F80).

## Step 0 — before looking at rudra (founder's order)
1. **F89 (found after S178 merged):** `vajra init --help` does NOT print help — it runs a full
   `vajra init` (proved in an empty git repo: `.ai/`, `.githooks/`, `.gitignore`, `AGENTS.md`,
   `CLAUDE.md`, `darshan/`, `prompts/`, `reviewer/`, `scripts/`, `.cursorrules`). In Vajra's own repo
   it merged a duplicate set of guard hooks into `.claude/settings.json` (every guard would run
   twice); the founder reverted it 2026-09-28. A stranger's first command is `--help`. Fix it, and
   check every `vajra <command> --help` for the same.
2. **Correct S178's record:** `sessions/session-178-summary.md` ("What this does NOT claim") and PR #215
   say `.claude/settings.json`/`.gitignore`/`.ai/hooks/` were changed "by something other than this
   session's commands". Wrong — the S178 agent's own `./target/release/vajra init --help` wrote them.

## What to look for in rudra S14 + S15
Read every close log for `WAIVED` and `N/A` FIRST, never just PASS; a hand-written `verified:` stamp
is not evidence (S178's lessons).
- **Did S178's fixes help under OpenCode?** S13 took ~30 close runs, blocked on the same 3 checks. How
  many close runs did S14 and S15 take? Did the agent read the new non-Claude note (F86) and go to
  the founder's decision instead of re-running `vajra next --role`? Was the override used, and with
  a reason (F78)?
- **F83 in rudra:** was the synced `.claude/agents/tech-lead.md` committed with S14's first commit (F60
  pattern)? Are the crew lines written outside code blocks?
- **S15 = a NO-CODE ground truth:** did Vajra's close treat it as NO-CODE? Why does its record carry an
  `## Execution` step-to-commit map (rudra `1328245`, `d582240`) — did a Vajra check demand one from a
  review-only session? Why two REJECTs?
- **Hand-typed provenance again (F79/F84)?** Look at every `.ai/handoffs/session-1[45]-*.md` `agent:` line.
- **Time + cost** per session (no Vajra receipt under OpenCode).
- **Merge state:** S14's PR is open; S15 has no PR. Anything in Vajra that made merging confusing?

## Carried in
1. **S180 Goal 0** (`prompts/180-task-ground-truth.md`): the founder's controls are agent-typeable
   (F77–F80, F84, F85) + strict `session_type` + experts-vs-checklist. Not built here.
2. **S178 review leftovers (deferred, `sessions/session-178-summary.md`):** rec 1 — `src/cli/next.rs:1650,1678`
   "There is no environment variable for this one" (same false-sentence family as F87); rec 3 — verify
   AC6 (a) is hollow; rec 4 — the close script's FAIL lines should point at the non-Claude note; rec 5 —
   SKIP guard for Vajra S176/S177 comparisons; rec 7 — "Ways through include …", `=<N>` not `=<NN>`.
3. **Parked by the founder:** F67 (receipt ~5×), F71 (leftover branch). Recorded: F81, F82, F88.
4. Vajra's own `origin/session-165-closeout` — its one remaining unmerged remote branch: the
   founder to look at it.

## Findings (filled in with the founder)
| # | Where | What happened | Severity |
|---|---|---|---|
| F89 | Vajra CLI | `vajra init --help` runs a real init (11 files in an empty repo). No subcommand prints its own help: `check`/`next`/`estimate` run, `meter` opens a file named `--help`, `hook` prints `{}` | HIGH (user-facing) |
| F90 | Vajra CLI | `vajra init` ignores any word it does not know — `vajra init --dry-run` (without `--sync-fleet`) runs a full real init. Found while probing F89; founder yes 2026-09-28 | HIGH (user-facing) |
| F91 | rudra S14/S15 (OpenCode) | Vajra's git guards cannot tell OpenCode's agent from the founder (`.githooks/pre-commit:33-35` reads only CLAUDECODE/CLAUDE_CODE_ENTRYPOINT/CURSOR_TRACE_ID/VAJRA_AGENT — the agent's env probe printed `none-set`). 37 agent commits, no approval check; after both merges the agent pushed `5ab6e83` straight to rudra's main (the pre-push note said "Pushing anyway"). Merges #17/#18 were typed by the agent on the founder's chat word | HIGH — PARKED (non-Claude tools, after S180) |
| F92 | rudra S15 | S15's 4 waived close runs are labelled "Founder waiver 2026-09-28"; the founder waived only S14 (OpenCode question box, 10:00) and his waiver ruling (rudra GT-3) was still open. `VAJRA_CLOSEOUT_WAIVER=N` passes ~20 checks at once (rudra `scripts/verify-closeout.sh`, 20+ `WAIVED` sites), incl. `review-inputs-attested` — the agent itself said the waiver made the review stamp a no-op (18:17) | HIGH — S180 Goal 0 |
| F93 | rudra S15 | The first ground truth a scaffolded project ran audited the tooling, never whether rudra is on track — the founder had to ask (16:11) and order a re-run. Cause, as far as the template goes: `vajra init` handed a project Vajra's own audit list — 2 of its 10 audits were purely Vajra's self-usage questions (`dogfood_check`, `dogfood_staleness`), none asked what the project delivered. Not the whole cause: the first attempt answered 0 of the 10 audits while `vision_alignment` was already first (`session-15-ground-truth.md:5-7`) | HIGH — **fixed in the template** (new `delivery_progress`, project questions first, two self-usage audits withheld); **unproven until a project's next ground truth** |
| F94 | rudra S14/S15 | S14 and S15 ran in one chat; `one_session_per_chat` is guarded only under Claude Code (rudra GT-6) | MED — PARKED (non-Claude) |
| F95 | rudra S14 | Vajra labels OpenCode helpers `claude-code-subagent (unverifiable: subagent transcript recorded gitBranch "session-03-…")` — it matched unrelated old Claude Code records (rudra S01/S03) | MED — PARKED (non-Claude) |
| F96 | rudra S14 | The founder asked twice for plain English ("too much analogy") | LOW — recorded |
| F97 | Vajra | `vajra init --sync-fleet` never touches a project's `CONSTRAINTS.yaml` (by design, `sync_fleet_touches_only_roles_hooks_and_the_constitution`), so F93 reaches new projects and rudra (hand-applied) but no other existing project | MED — recorded |
| F98 | rudra S15 | Vajra measures a NO-CODE ground truth like a CODE session: the station counter scored S15 ABSENT on Planner ("plan misses criteria 1…10") and Coder ("no `## Execution` trace") (`session-15-ground-truth.md:198-209`), and the close gate's execution check made the agent add a step→commit map to a review-only session (rudra `1328245`: "The closeout gate requires a ## Execution section when a plan has real numbered steps"). The close's other checks did treat it as NO-CODE (`tech-lead file not required`, `no session scripts expected`) | MED — S180 (the strict `session_type` item) |
| F99 | Vajra scaffold | `pipeline_advance_check` stays in a project's list (its evidence, `vajra next --stations NN`, reads the project's own prompts), but its question still says "in this repo (SHIP needs a synced origin; Reviewer needs an attested ACCEPT)" — Vajra's own wording (rudra `CONSTRAINTS.yaml`, `pipeline_advance_questions`) | LOW — recorded |
| F100 | Vajra `scripts/demo-session-129.sh` | Case 4 cannot fail: its failure path is `false; break`, and `break` exits 0, so `score $?` scores OK (it still says OK today with `dogfood_check` withheld). Case 5 now fails by design — it asserts exactly 2 withheld audits; S179 withholds 4 (the S129 ruling reversed, `## Design`) | LOW — recorded (a past session's demo; not re-run at any close) |

## Goal
1. F89 + F90 fixed; S178's wrong record corrected.
2. F93: a project's ground truth asks about the project first (founder yes). Other non-Claude findings parked until after S180 (founder, 2026-09-28).

## Deliverables
1. `vajra init --help` (and every `vajra <cmd> --help`/`-h`) prints that command's help and writes nothing.
   `vajra claude --help` stays a pass-through (its arguments belong to Claude Code).
1b. `vajra init` refuses a word it does not know and writes nothing; `--dry-run`/`--overwrite-drifted`
   without `--sync-fleet` are refused with a message naming the right command.
2. `vajra init` hands a project a ground truth whose first audits are vision, roadmap and a new `delivery_progress`; Vajra's two self-usage audits are withheld with declared reasons; rudra's copy updated.

## Acceptance
1. In an empty git repo, `vajra init --help` exits 0, prints usage, and `git status` shows nothing new;
   the same for every subcommand's `--help` and `-h`. Old vs new on that list.
1b. In an empty git repo, `vajra init --dry-run` and `vajra init --bogus` exit non-zero, name the word,
   and `git status` shows nothing new; `vajra init` and `vajra init --sync-fleet [--dry-run|--overwrite-drifted]`
   behave as before.
2. A fresh `vajra init`'s `required_audits` starts `vision_alignment, roadmap_alignment, delivery_progress,`, has no `dogfood_check`/`dogfood_staleness` (each declared with a reason), and its project questions precede the workflow ones; `scripts/scaffold-drift.sh` exits 0; rudra's `vajra check` is unchanged.

## Design
- design-significant: no — F89/F90 are argument handling at the front door; F93 is a change to derived text through the existing S129 mechanism (`build.rs` `OMIT_AUDITS`, declared omissions), no new mechanism, no new check.
- **This reverses a recorded S129 ruling** (review rec 4): S129 judged `dogfood_check` and `dogfood_staleness` portable ("every stranger has that binary", `sessions/session-129-fork-measurement.md:47,49`). S179 withholds them: the binary exists in a project, but the question is about Vajra's use, not the project's delivery. `scripts/demo-session-129.sh` case 5 now fails against the new binary (F100). The derivation mechanism itself is unchanged.
- design-advisor: skipped — the tech-lead deferred it for budget (`.ai/handoffs/session-179-tech-lead.md`, one dispatch affordable after the F82 cap), and F89/F90 are argument handling; F93 runs through the S129 `OMIT_AUDITS` mechanism unchanged but reverses S129's portability ruling for two audits (above) — a design choice, made on the founder's yes, disclosed here rather than sent to the design-advisor.

## Plan
1. F89: `src/main.rs` answers `--help`/`-h` after any Vajra subcommand (not `claude`) with that command's usage, exit 0, before running it; binary tests in `tests/cli_front_door.rs` (covers: 1)
2. F90: `src/cli/init.rs` refuses unknown words before anything is written; binary tests (covers: 1b)
3. Correct S178's record in `sessions/session-178-summary.md` (the S178 agent's own `init --help` wrote the files)
4. Rudra S14 + S15: read, list findings with the founder; fix F93 (his yes) — `.ai/CONSTRAINTS.yaml`, `build.rs`, `src/cli/init.rs`, then rudra's copy by hand (covers: 2)


## Answers — the brief's rudra questions (review rec 3)
- **S178's fixes under OpenCode:** ~5 close runs per session (S13: ~30); the agent put the helper-check wall to the founder as a question (S14, 10:00) instead of re-running `vajra next --role`. The override was used with a reason every time (F78's missing reason did not recur) — but S15's reason claims a founder waiver he did not give (F92).
- **F83 in rudra:** the synced `.claude/agents/tech-lead.md` landed as its own commit before the session work (rudra `S14` C4, "founder edit"); `.ai/handoffs/session-14-tech-lead.md` has 9 plain `crew` lines, no code fence.
- **S15 as NO-CODE:** the close treated it as NO-CODE (logs: "tech-lead file not required here", "no session scripts expected"); the station counter and the execution check did not (F98) — that is why S15 carries an `## Execution` map (rudra `1328245`, `d582240`).
- **Two REJECTs:** pass 1 graded the first delivery (the evidence-vocabulary audit, 9/8/3 of 20) — the one that audited tooling; pass 2 graded the direction re-run (15/17/2 of 34); both remediated, then a canonical ACCEPT added (`rudra/sessions/session-15-review.md:3-9`).
- **Hand-typed provenance (F79/F84):** no — every S14 handoff says "unverifiable" (Vajra matched unrelated Claude Code records, F95); the agent re-added an OpenCode provenance block it wrote itself, labelled as such (rudra S14 08:53).
- **Time + cost:** S14 19:26 (9/27) → PR 10:10 (9/28), with a 1.5 h usage-limit stall and ~8.5 h overnight idle; S15 13:36 → merged 18:48 (incl. the re-run). One OpenCode session for both: $1.93, 566 shell commands, 7.0M input + 207M cache-read tokens. No split per session is recorded.
- **Merge:** the agent merged #17 and #18 itself on the founder's chat word ("commit push crate pr and merge"), then pushed `5ab6e83` straight to main (F91). Nothing in Vajra made merging confusing; nothing in Vajra saw it either.
- **PR #215 (review rec 7):** corrected by a comment (founder yes), not by editing the description: https://github.com/ifelse-codes/vajra/pull/215#issuecomment-5871546356
- **rudra's hand edit (review rec 8):** uncommitted in rudra's `.ai/CONSTRAINTS.yaml`; the verify script proves it touches only the `ground_truth:` block and leaves rudra's `vajra check` unchanged. rudra's next agent commits it first.

## Execution
- step 1 — done: ad71630
- step 2 — done: 66e01da
- step 3 — done: 65217c3
- step 4 — done: f7c4f5a

## What went right under OpenCode (S14/S15)
- Close-check runs: ~5 per session (S13: ~30). The agent put the helper-check wall to the founder as a question instead of re-running `vajra next --role` — S178's F86 note did its job.
- Helper records say "unverifiable" honestly; no hand-typed "verified" stamps (F79/F84 did not recur).
- F83: rudra's synced `.claude/agents/tech-lead.md` landed as its own commit before the session work.
- F89 was met live: the agent ran `vajra next --help` twice and got the full session report.

## Advice
Roles dispatched: `tech-lead` (mandatory, first) and `fidelity-reviewer` (required; it also judges the
tech-lead's `obeyed:` lines — a role may not grade its own advice; the release-coordinator was
`deferred-budget`, so no extra dispatch). `design-advisor` skipped with a recorded reason (`## Design`).

**tech-lead** (`.ai/handoffs/session-179-tech-lead.md`):
- tech-lead rec 1 — obeyed: 20884aa (the reviewer's brief named files only: this prompt, the diff of the six changed files, `scripts/verify-session-179.sh` + its live output, the demo, and rudra's two records; budget given as an instruction)
- tech-lead rec 2 — obeyed: b3630a6 (Deliverable 1 lists the subcommands and names `claude` the exempt pass-through before any code; `scripts/verify-session-179.sh` grades that exact list, old vs new)
- tech-lead rec 3 — obeyed: 20884aa (every probe runs in a fresh `mktemp` git repo; nothing runs `init` in Vajra's own tree)
- tech-lead rec 4 — obeyed: 790758c (`design-significant: no` recorded only after the rudra findings; no rudra fix touched the close path or the handoff format, so the design-advisor was not added)

## Guardrails
- No new gate on Vajra's own paperwork (founder, 2026-09-15). A gate on the HANDOVER to the human needs his explicit yes.
- Findings are listed with the founder first; fix only what he says yes to. Small commits.
- Anything not fixed goes in the findings table with a severity, never dropped.
- A message fix must not be a new false absolute (S178 pass-1 REJECT). Old vs new on a listed set.
- Never change code after the review's ACCEPT and refresh only the stamp (F81).
- Stage by path only. **Merge stays strictly hand-typed.**

## Delta
- `+` F89 fixed; S178's record corrected
- `+` whatever rudra S14/S15 under OpenCode surface
- `~` S178's F86/F87 messages meet a real non-Claude close for the first time
- `-` nothing removed
