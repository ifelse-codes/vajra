# Session 177 — rudra session 09 with S176's fix in

> **Status:** APPROVED — founder picked candidate A (keep testing on rudra) at the S176 close,
> 2026-09-23, same rudra test as S172–S176.

## Type
- **CODE**, interactive. He runs rudra's session 09 (`prompts/09-task-fill-realism.md` there) for real
  under `vajra claude`; findings are COLLECTED during the run and fixed together after it closes.
  If the run finds nothing to fix, keep this session open for rudra session 10 (S176's pattern).
- **Not a ground-truth session.** `.ai/CONSTRAINTS.yaml#ground_truth_next_session: 180`.

## Before he starts
1. `cargo install --path /Users/suman/playground/vajra` — S176's fix (F70, the Planner's Dangling
   state) lives in the binary (`src/planner/mod.rs`). Without a rebuild, rudra's `--check-plan`
   still passes a brief whose Acceptance was deleted. No `vajra init --sync-fleet` is needed — S176
   changed no scaffolded file.
2. Launch: `VAJRA_ALLOW_COMMIT=09 vajra claude` (add `VAJRA_ALLOW_PUBLISH=1` only if he wants the
   agent to push and open the PR; merge stays his either way).

## What this run should exercise
- **F70 live:** if the agent's plan cites an item the brief lacks, does `--check-plan` / `--steps`
  now say so, and does the message send it to the right fix?
- **F73 watch:** does rudra's S09 brief use an acceptance shape the Planner can't read (`1)`,
  `**1.**`, numeric tables)? If so, the block names it — does it cost a retry?
- **F58, F61/F63, the `cwd`/worktree push** — still never exercised live.
- **F31** a ninth time — tech-lead dispatched first. **F66** — every required handoff git-tracked?

## Carried in
1. **Parked by the founder:** F67 (receipt misprices Opus 5.5 ~5× — the permanent fix is reading the
   tool's own cost, not new price rows) · F71 (remote branch left after a GitHub-button merge).
2. **Disclosed, needs his yes:** F70-residual (nothing at close re-runs the Planner) · F66
   (`--check-crew` disk-presence vs git-tracked).
3. **Deferred from S176:** qa-specialist recs 3 (the `--steps` hint for a Dangling plan), 4
   (`PlanState::blocks()` has no production caller), 6 (a fixture session-advance run on a dangling
   plan), 7 (sweep compares exit + reason) — `sessions/session-176-summary.md`.
4. **Parked LOW:** F47, F56, F57, F73 · **F50** not fixed in code · **F64** watch.
5. **S180 ground truth** carries S175's design-advisor recs — `prompts/180-task-ground-truth.md`.

## Findings (filled in live)
| # | Step | What happened | Severity |
|---|---|---|---|
| F74 | close | rudra's close check (`scripts/verify-closeout.sh`, synced from `scripts/verify-closeout-scaffold.sh`) still hard-codes `N % 5 == 0` as a no-code session. The founder moved rudra's ground truth to S15 at the S09 close (`ground_truth_next_session: 15`); the start hook obeys it, but the close check does not, so rudra S10 (CODE) will pass "verify/demo scripts exist" and "tech-lead recorded" as N/A. Already happened at rudra S05 (a CODE session, logged `N/A: session 5 is a NO-CODE ground-truth`). The agent saw it, could not fix it (Vajra-owned), and wrote it into S10's prompt + its memory. S175 left the scaffold out on purpose ("no reason to move the first ground truth on day one"); it took 3 sessions to be wrong | HIGH |
| F76 | close (found fixing F74) | The same close check decides "is this a CODE session?" by an exact `**CODE**` match. rudra writes `- **CODE.** Max 2…` in every brief (S02–S10), so all of them read as non-CODE: its "tech-lead recorded" check never ran (S09 log: `N/A: session 9 is not a CODE session`). Same bug family as F74 — a CODE session's close quietly skips CODE checks | HIGH |
| F71 (again) | merge | Remote session branch left after the GitHub-button merge; the agent called it "harmless, the checks don't require removing it"; the founder deleted it by hand in the GitHub UI. Second time (rudra S08, S09) | MEDIUM (parked) |
| F67 (again) | exit receipt | `~$118.69 estimated` for 287 replies, opus-5-5 priced at the unknown-model ceiling (~5× over → roughly $24). Third run in a row | HIGH (parked — permanent fix wanted) |
| F75 | design | The design-advisor proposed "record a 4-file Plan exception"; no agent can pass the ≤3-file pre-commit hook, so the plan-advisor overruled it. The ≤3 rule then forced a split where `proofs/VERDICT_GREEN.json` sat stale for one commit (founder asked, approved) | LOW |
| ✓ | whole run | F31 clean 9th time (tech-lead first, 05:45) · F66: all 7 handoffs git-tracked · F58: agent pushed + opened PR #11 itself under `VAJRA_ALLOW_PUBLISH=1`, merge stayed his · close check ran ON the branch before the PR (21/21) · F70 had nothing to catch (brief intact, `--check-plan` READY) · F73 not hit (Acceptance uses `1.`) · worktree/`cwd` still never exercised | — |
| ⏱ | whole run | 3h20m in chat: ~1h50m waiting on his answers (plan questions 54 min, S10 pick 40 min); code steps 1–13 took 25 min; Vajra's advisors + reviews + the 6-min close check ≈ 50 min | info |

## Goal
1. A CODE session in a Vajra project gets its full close checks, even after the founder moves the
   next ground truth, and even when its brief writes `**CODE.**` (F74 + F76; founder: "yes fix it").

## Deliverables
1. `scripts/verify-closeout-scaffold.sh` reads `ground_truth_next_session` (the S175 helper) at both
   sites, and accepts `**CODE.**` as CODE.
2. `tests/scaffold_gt_cadence.rs` runs the real scaffold functions on fixture projects.
3. rudra gets the fixed gate before its S10 (rebuild + `vajra init --sync-fleet`).

## Acceptance
1. With `ground_truth_next_session: 15`, session 10 (no scripts) is a CODE session and its
   "verify + demo scripts" check BLOCKS; session 15 passes it as N/A.
2. Without the key, every session number answers exactly as before (old vs new, a listed spread).
3. `**CODE.**`, `**CODE**`, `**CODE**,` read as CODE; `**NO-CODE.**`, `**DOCUMENT.**` do not. Old vs new
   over every prompt in both repos: nothing moves from CODE to non-CODE.
4. rudra's own `scripts/verify-closeout.sh`, after the sync, says S10 is a CODE session.

## Design
- design-significant: yes
- Record: `docs/decisions/DECISION-007-agent-fleet.md` — S177 addendum (reverses the S175
  addendum's "NOT claimed" item 1, on rudra evidence).
- design-advisor: skipped — the change copies S175's existing, reviewed `is_ground_truth_session`
  helper verbatim into the scaffold, plus a one-line widening of an exact-match grep; no new design
  choice exists to advise on (tech-lead rec 2).

## Plan
1. Port `is_ground_truth_session` into the scaffold at both sites; accept `**CODE.**`. covers: 1, 3
2. `tests/scaffold_gt_cadence.rs` — S10/S15 with the key, the old rule without it, the Type spellings. covers: 1, 2, 3
3. `scripts/verify-session-177.sh` + `scripts/demo-session-177.sh` — old (main) vs new sweeps over a
   session-number spread and every prompt in both repos, run live. covers: 1, 2, 3, 4
4. Rebuild, `vajra init --sync-fleet` in rudra, and show rudra's own gate calling S10 CODE. covers: 4

## Execution
- step 1 — done: 2053bb7
- step 2 — done: a803ec3
- step 3 — done: f9b3387
- step 4 — done: f9b3387 (rebuild + `cargo install` + `vajra init --sync-fleet` in rudra are not commits here; verify AC4 in this commit proves rudra's synced gate)

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `fidelity-reviewer` (required). `design-advisor`
skipped with a recorded reason (`## Design`), as tech-lead rec 2 advised. Every `obeyed:` is judged
by the fidelity-reviewer, not the builder.

**tech-lead** (`.ai/handoffs/session-177-tech-lead.md`):
- tech-lead rec 1 — obeyed: 75ec337 (only fidelity-reviewer required; the other eight stayed deferred-budget — no other role was dispatched)
- tech-lead rec 2 — obeyed: 0de77a7 (`design-advisor: skipped — <reason>` in `## Design`, naming DECISION-007's S175 addendum as the record reversed; the S177 addendum itself landed in 2053bb7)
- tech-lead rec 3 — obeyed: f9b3387 (verify AC1 key 15 → S10 CODE + blocks, S15 N/A; AC2 no key → old = new at 16 session numbers; AC4 runs rudra's own synced gate in rudra's tree)
- tech-lead rec 4 — obeyed: 75ec337 (one fidelity-reviewer pass planned; a second only on REJECT)

## Guardrails
- No new gate on Vajra's own paperwork. A gate on the HANDOVER to the human needs his explicit yes.
- Findings are collected during his run and fixed after it closes; small commits, each fix shown.
- Anything not fixed goes in the findings table with a severity, never dropped.
- Guard/check changes: compare old vs new on a listed set before claiming "no regression" (S173);
  changes may only ADD. When a check finds nothing to check, ask whether it could read what was
  there (S176).
- A founder "why" question is answered with evidence, not turned into a feature (S176).
- **Merge stays strictly hand-typed.**

## Delta
- `+` whatever rudra session 09 surfaces
- `~` S176's F70 fix meets a real run for the first time
- `~` F31 watched a ninth time
- `-` nothing removed
