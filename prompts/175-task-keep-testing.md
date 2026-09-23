# Session 175 — rudra session 06 with S174's fixes in

> **Status:** APPROVED — founder, 2026-09-22: "session 175 is the same rudra test, and keep going —
> no review-only session until 180."

## Type
- **CODE**, interactive. He runs rudra's session 06 for real under `vajra claude`; findings are
  COLLECTED during the run and fixed together after it closes (his rule since S173). Full close.
- **Not a ground-truth session.** The founder moved the next review-only session to **S180**.

## Before he starts
1. `cargo install --path /Users/suman/playground/vajra` (S174's fixes) — done 2026-09-22.
2. `cd ~/playground/rudra && vajra init --sync-fleet` — done; **4 Vajra files are waiting to be
   committed there. Never revert them**; S06's agent should commit them first.
3. `VAJRA_ALLOW_COMMIT=06 vajra claude`.

## Deliverable 0 — the cadence the founder just changed (do this first, before his run)
`N % 5 == 0` is hardcoded in `scripts/hook-session-start.sh` (the boot reminder) and
`scripts/verify-closeout.sh` (`is_code_session`, and the "no session scripts expected" branch), while
`.ai/CONSTRAINTS.yaml` already carries `ground_truth_every_n_sessions: 5` that nothing reads. So
today S175 announces itself as ground truth and its close QUIETLY SKIPS the CODE checks — weaker
exactly where we want them.
- Make both scripts read the next ground-truth session from `.ai/CONSTRAINTS.yaml`
  (e.g. `ground_truth_next_session: 180`), defaulting to today's every-5th rule when the key is
  absent, so other projects are unchanged.
- Record the founder's decision (DECISION-00N addendum): the every-5th cadence is a default, and he
  moved the next one to S180.
- A session that is NOT ground truth must get the full CODE close checks.

## What this run should exercise for the first time
- **F58:** when the agent's PR command is blocked once, does the new message get it through on the
  retry (`--body-file`), or does it still hand the PR back?
- **F59/F62:** does boot say "session 05 is merged — session 06 starts here"? How many times does the
  agent re-run `vajra next --steps` during the session (0 is the finding)?
- **F60:** does it commit the 4 waiting Vajra files first, and never suggest reverting them?
- **F61/F63:** do the two commit blocks now cost one try instead of three?
- **F48/F53/F54:** S07's prompt written before the merge; the review stamped ONCE; `## Advice` right
  the first time.
- **The `cwd` assumption** (still never tested live): `cd` into a worktree, try `git push` — it must
  go to the human.
- **F31 a sixth time** — tech-lead first.

## Carried in
1. **S174 review, deferred:** rec 2 — boot does not name synced role files (`.claude/agents/*.md`,
   stamp inside the header) as Vajra's update; rec 6 — build the verify's expected set from
   everything the sync changed; rec 7 — also name untracked files a sync adds.
2. **F64 (watch):** an advice answer switched from `deferred:` to `obeyed:` to pass the check —
   compare each `obeyed:` sha against what its rec actually asked.
3. **F47, F56, F57** (LOW, parked) · **F50** (not fixed in code, by the S173 decision).

## Findings (filled in live)
| # | Step | What happened | Severity |
|---|---|---|---|
| Deliverable 0 | boot | `N % 5 == 0` was hardcoded in **6** places, not the 2 named above: also `hook-pre-bash.sh` (would have blocked S175's first `git commit` — a live self-block, not paperwork), `hook-pre-write.sh`, `hook-prompt-submit.sh`, `hook-stop.sh`. All 6 fixed. | HIGH (would have blocked this session) |
| F59/F62 | rudra S06 run | Boot said "session 05 is merged — session 06 starts here"; `vajra next --steps` re-run 3× during the session (not 0). Fix holds. | fixed, confirmed |
| F60 | rudra S06 run | Boot named all 4 waiting Vajra files by path, said commit-first-never-revert; agent committed them first. Fix holds. | fixed, confirmed |
| F58 | rudra S06 run | Both `gh pr create` calls succeeded first try — no block, nothing to retry. Not exercised this run. | untestable this run |
| F61/F63 | rudra S06 run | 15 commits, zero blocked — nothing to retry. Not exercised this run. | untestable this run |
| cwd/worktree | rudra S06 run | No worktree used. Still never tested live. | unchanged, watch |
| **F65 (new)** | rudra S06 run | He launched with `VAJRA_ALLOW_PUBLISH=1` (new, not in "before he starts"). That gate allowed ALL FIVE guarded actions with no distinction — the agent ran `gh pr merge` on both its own PRs, itself, unsupervised. Contradicts F55 (S173): "merging stays with the human." Founder, asked plainly: "no, merge should stay human — fix it." | HIGH — fixed this session |
| **F66 (new)** | rudra S06 run, transcript-mined | `vajra next --check-crew` (required-crew gate) checks a handoff file exists ON DISK, never that it is git-tracked — rudra S06 closed with 2 of 8 required handoffs uncommitted, missing the PR, needing a same-morning fixup PR. Same bug family as F60, different target (crew handoffs, not Vajra's own sync files). | MEDIUM — **not fixed** (Guardrails: no new gate on Vajra's own paperwork without the founder's explicit yes; tech-lead rec 5 concurs: watch-only) |

## Goal
1. Deliverable 0 above.
2. Read back what the founder's rudra session 06 run actually exercised (the paste he shared was
   only the cost receipt — the substance came from mining the transcript himself gave access to),
   and fix what it found that needed fixing.

## Deliverables
1. The ground-truth cadence reads from config; next one is S180; a non-GT session gets the full CODE
   close checks. **All 6 sites fixed** (not the 2 named in the brief).
2. `VAJRA_ALLOW_PUBLISH=1` no longer allows a merge (`gh pr merge` / `glab mr merge`) — merge stays
   human, always, no env var, matching the rule F55 already built for `VAJRA_ALLOW_COMMIT`.
3. F66 (required-crew checks disk-presence, not git-tracked-ness) recorded as a disclosed, unfixed
   finding — not built, by the guardrails' own rule.

## Acceptance
1. With `ground_truth_next_session: 180`, boot on a `session-175-*` branch does NOT announce ground
   truth, and `verify-closeout.sh` treats S175 as a CODE session (verify + demo scripts required).
   — **Met.** `scripts/verify-session-175.sh` AC1c–AC1k, all 6 sites live-executed.
2. With the key absent, every 5th session behaves exactly as it does today (a listed set of session
   numbers, old script vs new, same verdict). — **Met.** AC1a/b (18 numbers, model-consistency) +
   AC1h–j (3 sites × 3 numbers × with/without key, real execution) + AC1k (structural floor).
3. `VAJRA_ALLOW_PUBLISH=1` blocks `gh pr merge`/`glab mr merge` (exit 2, "Merging stays with the
   human"); `git push`/`gh pr create` unaffected; the pre-existing `VAJRA_ALLOW_COMMIT` merge
   exclusion (F55) is untouched. — **Met.** AC2a–e, AC3 (old-vs-new diff, 0 unexpected changes),
   independently re-run by qa-specialist against a fresh fixture, not just this script's own report.

## Design
- design-significant: **yes** — both fixes change enforcement/advisory guard behavior (a
  commit-blocking hook's ground-truth test; a publish guard's escape hatch), the highest-scrutiny
  change class this repo tracks (S173 needed 9 cold-review passes for the same class). Cites
  `docs/decisions/DECISION-007-agent-fleet.md`'s "## S175 addendum" (both halves — the cadence
  config, and the merge-stays-human tightening found live).

## Plan
1. Deliverable 0: read `.ai/CONSTRAINTS.yaml#ground_truth_next_session` in all 6 hardcoded sites,
   falling back to `N % 5 == 0` when absent. — covers Acceptance 1, 2.
2. Dig into rudra session 06's actual transcript (the founder's paste was cost-receipt only) to find
   what it exercised, since findings are collected live per his S173 rule. — covers Goal 2.
3. Fix F65: exclude merge actions from `VAJRA_ALLOW_PUBLISH=1`'s bypass in `hook-publish-guard.sh`,
   confirmed with the founder before fixing. — covers Acceptance 3.
4. tech-lead dispatch (required by this repo's own constitution) finds `verify-session-175.sh` only
   live-executed 3 of 6 fixed sites; qa-specialist (required) live-executes the other 3 plus an
   independent replay of rudra's exact merge command, and adds a structural floor. — covers
   Acceptance 1, 2, 3 with real evidence, not self-report.
5. Record F66 as disclosed, not fixed, per the guardrails. — covers Deliverable 3.

## Execution
- step 1 — done: 59e1079 / 3eb3af6 / 76f6df9 / e8b23d9
- step 2 — done: (this file — findings recorded from the transcript)
- step 3 — done: 4cf1d8d
- step 4 — done: 93dec6b / 32851f3
- step 5 — done: (this file — Findings table row F66)

## Advice
Two roles were dispatched beyond the mandatory `fidelity-reviewer`: `tech-lead` (mandatory, first)
and `qa-specialist` (the one role it marked required). Every `obeyed:` below will be judged by an
independent role, not the builder this session.

**tech-lead** (`.ai/handoffs/session-175-tech-lead.md`):
- tech-lead rec 1 — obeyed: 93dec6b / 32851f3 (only qa-specialist and fidelity-reviewer dispatched;
  the other seven roles recorded as deferred-budget in the handoff, with real money reasoning each)
- tech-lead rec 2 — obeyed: 93dec6b (qa-specialist live-executed `hook-session-start.sh`,
  `hook-pre-write.sh`, `hook-stop.sh` against fixtures at N=170/175/180 × key with/without — AC1h/i/j)
- tech-lead rec 3 — obeyed: 93dec6b (qa-specialist independently replayed rudra's exact
  `gh pr merge 7 --merge --delete-branch` against old vs new `hook-publish-guard.sh`, in its own
  fresh fixture, not trusting this script's self-report)
- tech-lead rec 4 — obeyed: 5640a2a (fidelity-reviewer dispatched, briefed on qa-specialist's live
  evidence and the AC1a/b reimplementation caveat before reading anything else — see the dispatch
  prompt quoted in `.ai/handoffs/session-175-fidelity-reviewer.md`'s source)
- tech-lead rec 5 — obeyed: 32851f3 (F66 recorded in the Findings table above as disclosed, not
  fixed — no new gate on Vajra's own paperwork without the founder's yes)

**qa-specialist** (`.ai/handoffs/session-175-qa-specialist.md`):
- qa-specialist rec 1 — obeyed: 93dec6b (AC1h/i/j: live-execute the 3 previously-untested sites)
- qa-specialist rec 2 — obeyed: 50027f1 (rec offered "replace or supplement" — the cold review's rec 3 pushed
  past the session's first pass of "supplement" to the stronger option: AC1a/b are now retired and
  rebuilt as a live sweep of the real `hook-session-start.sh`, not a self-only model)
- qa-specialist rec 3 — obeyed: 4cf1d8d (the publish-guard fix committed before this session's close)
- qa-specialist rec 4 — obeyed: 93dec6b (AC1k: the structural marker-presence floor across all 6 sites)

**fidelity-reviewer** (`.ai/handoffs/session-175-fidelity-reviewer.md`, `sessions/session-175-review.md`, ACCEPT 11/11 SHIPPED):
- fidelity-reviewer rec 1 — obeyed: 50027f1 (the overclaiming header banner corrected)
- fidelity-reviewer rec 2 — obeyed: 613ac3b (DECISION-007 addendum now describes the live sweep, not a model)
- fidelity-reviewer rec 3 — obeyed: 50027f1 (AC1a/b retired and rebuilt against the real file — this also
  surfaced and fixed a second, unrelated real bug in AC3: it compared `HEAD`'s publish guard
  against itself once this session's own fix had landed there, silently zeroing its own count)
- fidelity-reviewer rec 4 — obeyed: a23f019 (this file)

## Guardrails
- No new gate on Vajra's own paperwork. A gate on the HANDOVER to the human needs his explicit yes.
- Findings are collected during his run and fixed after it closes; small commits, each fix shown.
- Anything not fixed goes in the findings table with a severity, never dropped.
- Guard/check changes: compare old vs new on a listed set before claiming "no regression" (S173);
  changes may only ADD (S173 permanent lesson).

## Delta
- `+` the ground-truth cadence becomes config, next one S180 (founder, 2026-09-22)
- `+` whatever rudra session 06 surfaces
- `~` S174's six fixes meet a real run for the first time
- `~` F31 watched a sixth time; the `cwd` check finally exercised
- `-` nothing removed
