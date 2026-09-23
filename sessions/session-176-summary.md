# Session 176 — two rudra runs, and a plan check that passed a brief with its acceptance deleted

**Type:** CODE, interactive. Covers the founder's rudra sessions 07 AND 08 (his pick A: S07 had
nothing to fix, so the session stayed open for S08 instead of closing on paperwork alone).
**Branch:** `session-176-keep-testing`. **Brief:** `prompts/176-task-keep-testing.md`.
**Verify:** `scripts/verify-session-176.sh` — 12 pass, 0 fail, 0 skipped. **Demo:**
`scripts/demo-session-176.sh` — 7 live checks, complete.

## What happened

- **rudra S07 (clean):** same size as S04–S06 (~2,200 lines, 20 commits) in 27 active minutes vs
  54–87. The speed came from the model (Opus 4.8 → Opus 5.5), not from Vajra; ~22 of 28 minutes were
  Vajra's process steps. The founder told the agent "merge it yourself" with `VAJRA_ALLOW_PUBLISH=1`
  set; S175's merge block held and the agent handed the merge back without routing around it.
- **rudra S08 (one real find):** the agent's own python edit of its prompt deleted Deliverables,
  Acceptance, Guardrails, Delta and Assumptions from the approved brief. It noticed itself 7 minutes
  later, restored from git, disclosed it. Re-created: `vajra next --check-plan 08` said **READY** —
  zero criteria left nothing "missing". That is F70.
- **The fix:** a plan that cites acceptance items (`covers: N`) the prompt does not have is now
  `PlanState::Dangling` → NOT READY, naming the numbers and the cause it sees.
- **What the fix found (F72):** the old-vs-new sweep flipped 12 of our own prompts — 11 (S156–S168)
  wrote Acceptance as `| ACn |` tables the Planner had never parsed, so it had passed their plans
  without checking one citation. The parser reads those rows now; 3 flips remain, each real.

## Everything found

| # | What | Outcome |
|---|---|---|
| F65 | merge blocked even when told "merge it yourself" | confirmed fixed, live |
| F60, F31, F66, close | Vajra files committed first · tech-lead first (7th, 8th) · handoffs all tracked · close 21/21 before each PR | confirmed / no recurrence |
| F67 | receipt prices Opus 5.5 at the unknown-model ceiling (~5× over) | PARKED by founder — wants the permanent fix (read the tool's own cost), not new price rows |
| F68 | "was S07 fast because of Vajra?" | answered (the model); feature idea DROPPED by founder |
| F69 | post-merge list says "do it without being asked" for S08 | not an issue (founder) |
| F70 | plan check READY on a brief with its Acceptance deleted | **FIXED** |
| F70-residual | nothing at close re-runs the Planner; deleting the `covers:` markers or `## Plan` still passes | disclosed, needs founder's yes |
| F71 | GitHub-button merge leaves the remote branch; release check looks at locals only | PARKED by founder |
| F72 | 11 table-style briefs never coverage-checked | FIXED with F70 |
| F73 | `1)`, `**1.**`, numeric tables, `- AC1:` not read as criteria (now a named block, not a silent pass); `covers:` overflow dropped | LOW, disclosed |

## Fidelity — every deliverable

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| G1 | Planner not READY on cited-but-absent items | SHIPPED | `src/planner/mod.rs` `plan_coverage_against`; verify AC1–AC3 |
| D1 | blocking state + plain message + kept rule | SHIPPED | `PlanState::Dangling`; 3 cause-specific messages; `no_criteria_means_substantive_plan_is_covered` still passes |
| D2 | every consumer handles it | SHIPPED | `src/stations/mod.rs` Planner arm; `--steps` via the station |
| D3 | tests, sweep, verify, demo | SHIPPED | 26 planner tests; sweep vs pinned `cd4302b`; verify 12/12; demo 7/7 |
| AC1 | section gone → NOT READY, names numbers, exit ≠ 0 | SHIPPED | verify AC1 |
| AC2 | list cut → NOT READY | SHIPPED | verify AC2 |
| AC3 | rudra S08 wipe: old READY → new NOT READY | SHIPPED | verify AC3 (fixture); QA also on rudra's literal `bc58af3` |
| AC4 | no regression; flips listed | SHIPPED | 173 session numbers + 10 rudra: flips exactly 155, 157, 166 — each real |
| AC5 | stations + `--steps` not passed | SHIPPED | verify AC5 (old ✓ → new ✗) |

**9 of 9 numbered requirements SHIPPED** (independent cold review ACCEPT, `sessions/session-176-review.md`).

## What this does NOT claim

- Nothing at close re-runs the Planner — a mid-session wipe is caught only when someone runs
  `--check-plan`, `--steps` or `--stations`. Building that is a new gate (F70-residual).
- The 3 flipped sessions (155, 157, 166) are closed history; they are not reopened.
- The review's recs 1–5 were applied after its ACCEPT pass and were not re-reviewed; the attested
  inputs hash covers the final diff.

## The fakest green here

An edit that deletes the `covers:` markers along with the list — or the whole `## Plan` — still
passes: the check only applies where the author keeps its markers (the S68 "jurisdiction is
self-granted" class). Runner-up: `PlanState::blocks()` has no production caller (QA M1); the real
gate is `PlanVerdict::blocked()`, which other tests do cover.

## Deferred

- qa-specialist rec 3 — the `--steps` Planner hint still says "mark each step `covers: N`" for a
  Dangling plan; the `--check-plan` message it points to names the right fix. Small; next time the
  steps text is touched.
- qa-specialist rec 4 — `PlanState::blocks()` has no production caller. Harmless; delete or route
  the gate through it when the Planner is next touched.
- qa-specialist rec 6 — a fixture-level session-advance run on a dangling plan. By source it uses
  the same `plan_gate().blocked()`; not run because this chat owns S176.
- qa-specialist rec 7 — compare exit code and reason in the sweep and check 00/01's shadowed files.
  Tightens Vajra's own paperwork; the founder asked to keep that minimal.

## Review

Cold review (fidelity-reviewer, fed only the prompt and the diff): **ACCEPT, 10 SHIPPED · 1 PARTIAL
(Guardrails — since closed by rec 3) · 0 NOT-BUILT**. It found a real regression in 100095a (a
`# … acceptance` title swallowed the document, re-opening F70 for that shape) — fixed in d4c1e29.

## Cost

Interactive; no metered paid run in this repo (the founder's rudra runs supplied the findings — their
receipts read ~$48.68 and ~$62.71, both overstated ~5× by F67). Fleet dispatches: tech-lead,
design-advisor, qa-specialist, fidelity-reviewer, plus release-coordinator as the independent
judge of `obeyed:` answers.

## 3 ranked next candidates

1. **(Recommended) Session 177 — rudra session 09, same pattern.** S175–S179 stay rudra test
   sessions; S180 is the next ground truth. Two runs back to back found one real bug (F70) and
   confirmed every earlier fix. Risk: a clean run gives nothing to fix — then fold it into the next
   run, as S176 did.
2. **Session 177 — F67 for good: the receipt reads Claude Code's own cost.** Interactive runs have
   no result stream today, so Vajra estimates from a hand-kept price list that goes stale with every
   new model (Opus 5.5 was ~5× over). Find the tool's own figure for interactive runs (e.g. the
   status-line `cost.total_cost_usd`). Risk: the tool may not expose it after exit.
3. **Session 177 — finish the 0.2.0 release.** crates.io still serves 0.1.0, so a stranger's
   `cargo install` gets none of S167–S176. Risk: the publish and the brew smoke are founder-only steps.
