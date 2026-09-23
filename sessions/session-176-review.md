# Fidelity review — session 176 (`session-176-keep-testing`)

**Verdict:** ACCEPT

**Review-Inputs-SHA:** <pending>

10 SHIPPED · 1 PARTIAL (Guardrails) · 0 NOT-BUILT. One cold pass (`fidelity-reviewer`), read-only. Its
recs 1–5 were applied AFTER this pass (d4c1e29 and the closeout commits) and were not re-reviewed —
the attested inputs hash above covers the final diff, including those fixes.


Method: cold, read-only; contract = `prompts/176-task-keep-testing.md`; work = code at HEAD (`src/planner/mod.rs`, `src/stations/mod.rs`, `src/nextstep/mod.rs`, `src/cli/next.rs`), `scripts/verify-session-176.sh`, `scripts/demo-session-176.sh`, the fixture, rudra's prompts, the QA handoff. Could not run `git diff`/`git show`; commit attribution from `.git/logs/HEAD` subjects + the QA handoff (which describes the code at 4b1df85).

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| G1 | Planner not READY when the plan cites `covers: N` the prompt lacks | SHIPPED | cited-but-absent check before anything else (`planner/mod.rs:321-330`); verify AC1/AC2/AC3 run the real binary |
| D1 | new blocking state, plain message naming numbers + cause; kept no-criteria rule | SHIPPED | `Dangling(Vec<u32>)` :59; `plan_gate` reasons :403-427, 3 cause-specific messages; kept rule tested :660-661, :613-620 |
| D2 | every consumer handles the new state | SHIPPED | stations :254-258 → ABSENT; `--steps` via `passed("Planner")` (nextstep :97); check-plan / plan / the session-advance path all use `plan_gate().blocked()` (next.rs :530,541,1875); exhaustive matches, no wildcard |
| D3 | unit tests; old-vs-new sweep both repos; verify + demo | SHIPPED | 9 new planner tests; sweep verify :54-79 vs pinned cd4302b; demo live old vs new :53-71 |
| AC1 | section gone → NOT READY, names numbers, non-zero exit | SHIPPED | verify :28-33; `run_check_plan` exits 1 (next.rs :541-543) |
| AC2 | list cut short → NOT READY | SHIPPED | verify :36-40; unit :637-641 |
| AC3 | rudra S08 wipe: old READY, new NOT READY | SHIPPED | verify :43-48; fixture diffed by eye vs rudra's prompt — exactly lines 40–105 gone; QA confirmed vs rudra's literal bc58af3 |
| AC4 | no regression; flips listed with why | SHIPPED | verify expects exactly 155/157/166 + rudra 0; each flip checked by hand, all real. Caveat: verdict-line-only; S180 excluded (no plan) |
| AC5 | stations + `--steps` read Dangling as not passed | SHIPPED | verify :82-92 (ABSENT line; `--steps` OLD ✓ → NEW ✗) |
| GR | Guardrails | PARTIAL | holds: no close re-run added; 12 table prompts fixed by teaching the parser, not hidden; 3 closed sessions recorded as history. Missing: QA §4 remaining shapes (`1)`, `**1.**`, `\| 1 \| x \|`, `- AC1: x`) and the silent `covers:` u32-overflow drop have no findings row; 4 deferred QA recs point at a summary that does not exist yet |
| DS | Design | SHIPPED | dangling-first :326-330, test :644; known limit in `## Design` + demo honest notes. Gap: DECISION-007 not amended though Design says it EXTENDS it |

Probes: (a) "no regression" honest at the verdict level, but QA's full-output sweep predates 100095a. (b) only the Planner calls `acceptance_criteria`; but 100095a's sub-heading rule lets a level-1 title naming "acceptance" open the block and nest every `##` after it — `prompts/56-task-fidelity-gate.md:1` is a live shape (its `--plan 56` checklist widens; verdict unchanged, no plan); it RE-OPENS F70 for that title shape (title + numbered `## Goal` + plan citing them + no `## Acceptance` → READY; at 88901e0 it was Dangling). (c) Guardrails mostly hold (see GR). (d) one `obeyed:` mismatch (tech-lead rec 5).

**Fakest green:** AC4's verdict-line-only sweep is the "no regression" evidence for 100095a's parser change and cannot fail for what that change alters (the S56 widening and the re-opened hole leave every verdict unchanged). The verify's QA-rec-1 check tests only the false-block direction. Runner-up: tech-lead rec 2 "obeyed" rests on `PlanState::blocks()` + a direct unit assert — `blocks()` has no production caller (the real gate is `PlanVerdict::blocked()`, QA M1); other tests cover the real path. Also stale hand-typed demo scorecard (22/22, 173).

rec 1 — Stop a level-1 title from opening the acceptance block (or apply the sub-heading rule only to blocks opened at level 2 or deeper), and add a unit test: title containing "acceptance" + numbered `## Goal` + plan citing those numbers + no `## Acceptance` → Dangling; add the same as a live verify case covering the widening direction.
rec 2 — Change tech-lead rec 5's disposition to cite 4b1df85 (the commit writing the F70-residual findings row), not 70d76a3.
rec 3 — Add a findings row with severity for the unfixed QA §4 items (`1)`, `**1.**`, `| 1 | x |`, `- AC1: x` shapes; the silent `covers:` overflow drop), and make sure `sessions/session-176-summary.md` exists before the four `deferred:` lines point at it.
rec 4 — Refresh the demo's hand-typed scorecard (22/22 tests, 173 prompts) or print the numbers from the verify run.
rec 5 — Add a short S176 note to `docs/decisions/DECISION-007-agent-fleet.md` under the S116 `covers: N` addendum.

## Obeyed-checks
obeyed-check qa-specialist rec 1 — implemented: 100095a — `acceptance_criteria` keeps deeper sub-headings and skips fenced code (planner :96-109); the Dangling reason names the cause it sees (:403-427); tests :679, :709; live verify :99-102
obeyed-check qa-specialist rec 2 — implemented: 100095a — `ac_table_row` upper-cases, trims `*`, strips ` -_` (:189-198); test :701 covers ac2, Ac2, **AC2**, AC 2, AC-2, AC02
obeyed-check qa-specialist rec 5 — implemented: 100095a — rudra-absent adds to SKIP and shows in the total (verify :79, :104)
obeyed-check tech-lead rec 2 — implemented: 88901e0 — Dangling is in `PlanState::blocks()` with a direct assert (:67-71, :630-633); no production caller of `blocks()`
obeyed-check tech-lead rec 3 — implemented: 88901e0 — Dangling before Uncovered (:326-330), test :644
obeyed-check design-advisor rec 3 — implemented: 88901e0 — same code and test as tech-lead rec 3
obeyed-check design-advisor rec 1 — implemented: 7a70d35 — `design-significant: yes` in `## Design`
obeyed-check design-advisor rec 2 — implemented: 7a70d35 — `## Design` cites DECISION-007's S116 `covers: N` addendum (exists at :309) and notes S64 has no record
obeyed-check design-advisor rec 5 — implemented: 7a70d35 — the known limit written in `## Design`
obeyed-check tech-lead rec 5 — mismatch: 70d76a3 — that commit adds the demo honest note; the findings row with severity was written in 4b1df85
Not judged (no commit-level evidence): tech-lead rec 1 (2495780 commits handoffs only), tech-lead rec 4 (cannot tell whether table parsing landed in 88901e0 or b31d7bd), design-advisor rec 4 (the cited test now checks only the "deleted" cause; the other causes landed in 100095a).
