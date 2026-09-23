# Session 176 — rudra session 07 with S175's fixes in

> **Status:** APPROVED — founder picked candidate A (test on rudra) at the S176 start, 2026-09-23,
> same rudra test as S172–S175.

## Type
- **CODE**, interactive. He runs rudra's session 07 for real under `vajra claude`; findings are
  COLLECTED during the run and fixed together after it closes (his rule since S173). Full close.
- **Not a ground-truth session.** `.ai/CONSTRAINTS.yaml#ground_truth_next_session: 180` — 176 is a
  plain CODE session (S175's own fix, first real use of it after itself).

## Before he starts — read this carefully, two of S175's fixes are BINARY-EMBEDDED
1. `cargo install --path /Users/suman/playground/vajra` — **not yet done for S175's fixes.**
   `scripts/hook-publish-guard.sh` and `scripts/hook-session-start.sh` are embedded into the `vajra`
   binary at build time (`include_str!` in `src/cli/init.rs`) and only reach rudra through a rebuild
   + resync — unlike `hook-pre-bash.sh`/`hook-pre-write.sh`/`hook-prompt-submit.sh`/`hook-stop.sh`/
   `verify-closeout.sh`, which are NOT scaffolded at all (Vajra-repo-only, per the S175 addendum).
   **Skipping this step means the F65 merge fix is not in rudra** — the exact bug from S175 would
   still be live there.
2. `cd ~/playground/rudra && vajra init --sync-fleet` — carries the rebuilt `hook-publish-guard.sh`
   (merge exclusion) and `hook-session-start.sh` (cadence config read, though rudra has no reason to
   set `ground_truth_next_session` itself) into rudra. Commit whatever it changes FIRST, never revert
   (F60's own rule, holding since S174).
3. Launch: **`VAJRA_ALLOW_COMMIT=07 vajra claude`.** Founder's call last session: merge stays strictly
   hand-typed — do **not** add `VAJRA_ALLOW_PUBLISH=1` unless you want the agent to push/open a PR
   too (it still cannot merge, by design, after S175).

## What this run should exercise for the first time
- **The F65 fix, live:** does `gh pr merge` still get blocked even with `VAJRA_ALLOW_PUBLISH=1` set,
  if he sets it again? (Optional — only if he wants to re-test it; not required for this run.)
- **F58, F61/F63:** two sessions running with no block firing to retry from. If one fires this time,
  does it cost one try, and does the PR block name `--body-file` correctly?
- **The `cwd`/worktree push assumption:** still never tested live, six sessions running. Not forced
  this session either — a real worktree use would settle it if one happens naturally.
- **F66 (watched, not fixed):** does a same-morning fixup PR happen again (a required handoff left
  uncommitted at close), or did S06's founder-observed gap not recur?
- **F31 a seventh time** — tech-lead dispatched first.

## Carried in
1. **S175 design-advisor, 3 recs, carried to S180** (not S176 — they're a ground-truth-scale audit
   question, not a build task): shared-lib extraction trigger for the 6-copy `ground_truth_next_session`
   pattern; the post-S180 dead-cadence trip-wire; `verify-closeout-scaffold.sh`'s drift ownership.
   `prompts/180-task-ground-truth.md`.
2. **F47, F56, F57** (LOW, parked) · **F50** (not fixed in code, S173 decision) · **F64** (watch: an
   advice answer switched from `deferred:`/`refused:` to `obeyed:` to pass the check).
3. **F66** (S175, disclosed, not fixed): `--check-crew` checks disk-presence, never git-tracked-ness.
   Still needs the founder's explicit yes before it becomes a session (Guardrails, unchanged).

## Scope change (founder, 2026-09-23)
- rudra S07 surfaced nothing to fix (F67 parked, F68 dropped, F69 not an issue). **Founder pick A:
  S176 stays OPEN and also covers rudra session 08** — findings from both runs are fixed together
  here, so no session closes on paperwork alone. Launch S08: `VAJRA_ALLOW_COMMIT=08 vajra claude`.

## Findings (filled in live)
| # | Step | What happened | Severity |
|---|---|---|---|
| F65 ✓ | merge | Founder said "merge it yourself" with `VAJRA_ALLOW_PUBLISH=1` set; `gh pr merge 9` BLOCKED by the publish-guard; agent did not route around it, handed back `! gh pr merge …`; founder merged. S175's fix confirmed live, hardest case. | confirmed fixed |
| F60 ✓ | boot | The 2 waiting Vajra hook files committed first on the session branch, not reverted. | confirmed (2nd run) |
| F31 ✓ | start | tech-lead dispatched before any plan edit — 7th clean run. | confirmed |
| F66 — | close | Did not recur: 7/7 handoffs git-tracked, `--check-crew` READY, no fixup PR. | watch, no recurrence |
| close ✓ | close | Full `verify-closeout.sh 07` ran on the branch BEFORE the PR: 21/21. | confirmed |
| F67 | receipt | Receipt said ~$48.68: `claude-opus-5-5` is not in Vajra's compiled-in price list, so it fell to the unknown-model ceiling ($15/$75). At real rates ($4/$20, cache read $0.20) ≈ $9.50 — ~5× overstated. **Founder: PARKED** — adding rows per model is not the root cause fix; fix it in a permanent way (read cost from the tool, not a hand-kept table) in a later session. | MED, parked |
| F68 | — | Founder asked why S07 was fast. Answer: same size as S04–S06 (~2,200 lines, 20 commits), 27 active min vs 54–87 — the model changed (Opus 4.8 → Opus 5.5, effort high), not Vajra. ~22 of 28 min was Vajra's process steps. A "what Vajra did" receipt line was proposed and **dropped by the founder** (misread question). | dropped |
| F69 | handover | After merge, `--steps` showed S08's list with "Do it without being asked"; the agent still told the founder to start S08 in a new chat. **Founder: not an issue** — outcome correct. | none |
| — | untested | F58, F61/F63 (no commit block fired), `cwd`/worktree push (no worktree used) — still not exercised. | carried |
| **rudra S08** | | | |
| F31 ✓ / F66 — / close ✓ | S08 | tech-lead first (8th); 7/7 handoffs git-tracked; full `verify-closeout.sh 08` 21/21 before the PR; 0 blocks fired; founder merged on GitHub. | confirmed |
| F70 | plan | The agent's own python edit of its prompt deleted Deliverables, Acceptance, Guardrails, Delta, Assumptions; it noticed 7 min later, restored from git, disclosed it. Re-created: `--check-plan 08` says **READY** on the wiped prompt (zero criteria → "all covered"); `--validate` says NOT READY; no close check re-runs either. **Founder: FIX.** | MED |
| F71 | ship | After a GitHub-button merge, `origin/session-08-…` stayed, plus 3 stale S04/S05 remote branches; the release check's `pruned` looks at locals only. Agent noticed, founder asked, agent deleted. **Founder: PARKED.** | LOW |
| F67 | receipt | $62.71 shown again (same unpriced opus-5-5). Still parked. | parked |
| F70-residual | close | After the fix, `--check-plan`/`--steps`/`--stations` say NOT READY on a cut brief — but nothing at CLOSE re-runs the Planner (or the Analyst's `--validate`). A mid-session self-wipe is caught only if someone looks. A close re-run is a new gate → needs the founder's explicit yes (tech-lead rec 5). Also: an edit that deletes the `covers:` markers or the whole `## Plan` still passes (S68 class). | MED, disclosed, not built |
| F72 | history | The F70 sweep found 11 prompts (S156–S168) writing Acceptance as `\| ACn \|` tables the Planner never parsed — it passed their plans without checking one citation (12 sessions incl. S155, which has no Acceptance at all but cites `covers: 1`). Fixed in the same change (the parser reads the table rows). 3 closed sessions now read NOT READY, each real: 155 (no list), 157 (AC5 never cited), 166 (AC1 never cited). History, not reopened. | fixed (with F70) |
| F73 | plan | QA §4, not fixed: acceptance items written as `1)`, `**1.**`, a numeric `\| 1 \| x \|` table, or `- AC1: x` are not read as criteria — a plan citing them now BLOCKS (before: passed unchecked). The message names the right cause ("no item under `## Acceptance` is numbered — write them as `N.` lines or `\| ACn \|` rows"). None occur in this repo or rudra. Also `covers: 99999999999` overflows and is silently dropped. | LOW, disclosed |

## Goal
1. Fix F70 (founder pick, 2026-09-23): the Planner check must not say READY when the `## Plan`
   cites acceptance items (`covers: N`) that the prompt no longer has — the shape rudra S08's agent
   produced when its own edit deleted five sections of the approved brief. F71 parked, F67 parked.

## Deliverables
1. `src/planner/mod.rs`: a plan that cites a criterion number absent from `## Acceptance` is a new
   blocking state, with a plain message naming the missing numbers and the likely cause (the
   acceptance list was cut or deleted). The old "no criteria + real plan → Covered" rule is kept
   for plans that cite nothing (adds only — S173).
2. Every consumer of the Planner state handles the new state (`src/stations/mod.rs`).
3. Unit tests for the new state; an old-vs-new sweep over every real prompt in this repo and in
   rudra; `scripts/verify-session-176.sh` + `scripts/demo-session-176.sh`.

## Acceptance
1. A prompt whose `## Acceptance` section is gone but whose `## Plan` still cites `covers: N` →
   `vajra next --check-plan NN` says NOT READY, names the cited numbers, and exits non-zero.
2. A prompt whose acceptance list was cut short (plan cites a number past the last item) → NOT READY
   the same way.
3. The live case: rudra S08's final prompt with Deliverables…Assumptions removed (the agent's own
   wipe, re-created) → NOT READY with the new build; READY with the old build.
4. No regression: old vs new binary over every `prompts/*-task-*.md` in this repo and in rudra —
   every verdict is unchanged except prompts that really cite a missing number; each changed one is
   listed with why.
5. The stations counter and `--steps` Planner line read the new state as not passed.

## Design
- design-significant: yes
- Record: `docs/decisions/DECISION-007-agent-fleet.md` — S116 addendum, "The `covers: N` contract:
  reused, not re-derived". The only spine record stating the Planner's coverage contract (the S64
  Planner itself was never written up). This EXTENDS it; that addendum's "gate not touched" was S116's scope.
- Decision: the Planner checks both directions. Every `covers: N` a step cites must be a criterion the
  prompt has. Citing absent numbers → new blocking `PlanState::Dangling(Vec<u32>)` (sorted, deduped);
  the message names the numbers and the two likely causes (Acceptance cut/deleted, or its items are not
  written as `N.` lines). Dangling wins over `Uncovered` — it names the root cause (the list is wrong);
  a re-run shows any Uncovered numbers once the list is fixed.
- Kept (adds only, S173): no criteria + a plan citing nothing stays `Covered`.
- Rejected: a close-time re-run or `--validate` hook (new gate on own paperwork — founder's yes needed);
  zero-criteria → not covered (flips old prompts); a two-list variant; widening `Uncovered`.
- Known limit: an edit that also deletes the `covers:` markers, or the whole `## Plan` (Absent → WARN),
  still passes — the S68 self-granted-jurisdiction class. This closes F70's shape, not the class.

## Plan
1. `PlanState::Dangling` in `src/planner/mod.rs`: detected before `Uncovered`, added to `blocks()`,
   `plan_gate` message, `format_plan_checklist`; unit tests incl. the rec-4 edge fixtures and the
   dangling-wins case. covers: 1, 2
2. `src/stations/mod.rs` Planner arm reads `Dangling` as not passed. covers: 5
3. Old-vs-new sweep (saved pre-change binary vs rebuilt) over every prompt here and in rudra, plus the
   re-created rudra S08 wipe; flipped verdicts listed in the verify artifacts. covers: 3, 4
4. `scripts/verify-session-176.sh` + `scripts/demo-session-176.sh` run the above live. covers: 1, 2, 3, 4, 5

## Execution
- step 1 — done: 88901e0 / 100095a
- step 2 — done: 88901e0
- step 3 — done: b31d7bd
- step 4 — done: b31d7bd / 70d76a3 / 100095a

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `design-advisor` (mandatory), `qa-specialist`
(required by the tech-lead), `fidelity-reviewer` (mandatory). Every `obeyed:` is judged by an
independent role, not the builder.

**tech-lead** (`.ai/handoffs/session-176-tech-lead.md`):
- tech-lead rec 1 — obeyed: 2495780 (only qa-specialist + fidelity-reviewer required; design-advisor dispatched anyway because the close gate mandates it; the other six deferred-budget)
- tech-lead rec 2 — obeyed: 88901e0 (`Dangling` added to `PlanState::blocks()`; `plan_citing_a_deleted_acceptance_list_is_dangling` asserts `blocks()` directly)
- tech-lead rec 3 — obeyed: 88901e0 (dangling wins; `dangling_wins_over_uncovered` locks it)
- tech-lead rec 4 — obeyed: 88901e0 (edge fixtures a/b/c in `edge_fixtures_non_numbered_list_prose_and_citing_nothing`; the sweep flipped 12 real prompts of shape (a) — fixed by teaching the parser `| ACn |` rows, never by hiding them; 3 real flips remain)
- tech-lead rec 5 — obeyed: 4b1df85 (F70-residual row, with severity, in the Findings table; also 70d76a3, the demo's honest notes; not built)

**design-advisor** (`.ai/handoffs/session-176-design-advisor.md`):
- design-advisor rec 1 — obeyed: 7a70d35 (`design-significant: yes` recorded)
- design-advisor rec 2 — obeyed: 7a70d35 (cites DECISION-007's S116 `covers: N` addendum; says the S64 Planner has no record of its own; no new decision file)
- design-advisor rec 3 — obeyed: 88901e0 (same as tech-lead rec 3 — `Dangling` checked before `Uncovered`, test-locked)
- design-advisor rec 4 — obeyed: 100095a (the message names the cause it sees — section gone, list cut, or items unnumbered; `dangling_message_names_the_actual_cause` asserts all three; first landed in 88901e0 as one two-cause message)
- design-advisor rec 5 — obeyed: 7a70d35 (known limit written into `## Design`)

**qa-specialist** (`.ai/handoffs/session-176-qa-specialist.md`):
- qa-specialist rec 1 — obeyed: 100095a (`###` sub-headings and code fences stay inside Acceptance; the Dangling message names the cause it sees — gone / cut / unnumbered; unit-tested + a live verify check)
- qa-specialist rec 2 — obeyed: 100095a (`ac_table_row` upper-cases the label and accepts `**AC1**`, `AC 1`, `AC-1`; `ac_labels_read_in_any_case_and_common_spellings` kills M7)
- qa-specialist rec 3 — deferred: sessions/session-176-summary.md
- qa-specialist rec 4 — deferred: sessions/session-176-summary.md
- qa-specialist rec 5 — obeyed: 100095a (rudra-absent is a counted SKIP in the verify total)
- qa-specialist rec 6 — deferred: sessions/session-176-summary.md
- qa-specialist rec 7 — deferred: sessions/session-176-summary.md

**fidelity-reviewer** (`.ai/handoffs/session-176-fidelity-reviewer.md`, `sessions/session-176-review.md`, ACCEPT):
- fidelity-reviewer rec 1 — obeyed: d4c1e29 (sub-headings nest only under a `##`-or-deeper Acceptance; a `# Title` naming "acceptance" is not a section for the message either; unit `a_title_naming_acceptance_does_not_swallow_the_document` + a live verify check; `--plan 56` checklist now byte-identical to the old build)
- fidelity-reviewer rec 2 — obeyed: 4b1df85 (tech-lead rec 5's line now cites the commit that wrote the findings row)
- fidelity-reviewer rec 3 — obeyed: aedaf3d (F73 row added to the Findings table with severity; the summary the deferrals point at exists)
- fidelity-reviewer rec 4 — obeyed: d4c1e29 (demo scorecard: 26/26 planner, 594/594 all tests, "173 session numbers")
- fidelity-reviewer rec 5 — obeyed: aedaf3d (DECISION-007-agent-fleet.md: S176 addendum under the S116 `covers: N` contract)

## Guardrails
- No new gate on Vajra's own paperwork. A gate on the HANDOVER to the human needs his explicit yes.
- Findings are collected during his run and fixed after it closes; small commits, each fix shown.
- Anything not fixed goes in the findings table with a severity, never dropped.
- Guard/check changes: compare old vs new on a listed set before claiming "no regression" (S173);
  changes may only ADD (S173 permanent lesson).
- **Merge stays strictly hand-typed** (founder, 2026-09-23, S175): no `VAJRA_ALLOW_MERGE`-style
  switch exists or should be built without his explicit ask.

## Delta
- `+` whatever rudra session 07 surfaces
- `~` S175's two fixes (GT cadence config, merge-exclusion) meet a real run for the first time
- `~` F31 watched a seventh time
- `-` nothing removed
