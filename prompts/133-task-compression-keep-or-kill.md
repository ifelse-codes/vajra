# Session 133 — CODE: compression, keep or kill

> **Status:** APPROVED — founder, at the S130 closeout. Locked sequence: S131 -> S132 -> **S133** ->
> S134. S131 made the `fidelity-reviewer` handoff mandatory and provable; S132 made its advice
> consequential (`obeyed:` must be judged true). This session decides the fate of the one large
> subsystem the product carries without a verdict.
>
> Founder directive in force (S118): README.md / VISION.md claims are the target spec, not a status
> report. Do NOT soften them. No release until reality meets them. **The exception this session
> exists to handle:** a claim about a feature that is being CUT is not softened, it is removed with
> the feature.

## Type

CODE. Max 2 assumptions, 2 retries, 1 story, ~2h, new chat. One story: reach a recorded verdict on
the compression engine and execute the losing branch's cleanup in the same session.

## Why this session

The compression engine is ~1,005 LOC (`src/engine/`, plus its hook wiring) shipped as the original
v1 wedge (ADR-0001, ADR-0003). It has been MEASURED twice on real paid runs — S63 and S124 — and
both times it folded **nothing** and saved **$0**. `.ai/ROADMAP.md` K1 carries it as the founder's
own keep-or-kill call, and `.ai/STATE.md` has carried "compression: never claim until real" since
S70. Fifteen sessions later it is still carried, still unverdicted, and still implied by the
product's own front door.

Carrying an undecided subsystem is not free: it is in every pitch, every README read, every
stranger's first impression, and every future session's context budget.

## Goal

A recorded, evidence-backed verdict — KEEP or KILL — and the losing branch's cleanup executed in
this session, so the repo stops carrying an open question. Not a plan to decide later.

## Deliverables

- **A measurement, not a memory.** Re-derive the real numbers live rather than citing S63/S124 from
  STATE.md: how many folds the engine has ever performed on real transcripts available on this
  machine, and what the receipt says was saved. If the honest answer is "no data since S124", say
  that in those words and treat it as evidence, not as a reason to defer.
- **The verdict, recorded in a spine record** (a `docs/decisions/DECISION-00N-*.md` addendum or a
  new one — decide which and say why), citing the measurement. `## Design` records the choice.
- **The losing branch, executed:**
  - **KILL:** remove the engine and every claim that implies it — README, VISION, `vajra claude`'s
    surface, the ADRs marked superseded (never deleted), the scaffolded twin in `src/cli/init.rs`
    if it carries any of it. `K of 8`, the 7 commands and every gate's contract stay unchanged.
  - **KEEP:** state in the README and VISION exactly what it does today (0 folds on the measured
    runs) with no implied savings, and record what evidence would change the verdict.
- **A falsifiability fixture** for whichever branch is taken: KILL must prove the product still
  works without the engine (a real `vajra claude` path exercised, not a compile); KEEP must prove
  the honest claim cannot silently drift back into a savings claim.
- `scripts/verify-session-133.sh` + `scripts/demo-session-133.sh`, both exit 0, printed check-class
  tally.
- `sessions/session-133-summary.md` + exactly 3 ranked next candidates (S134 — the fresh-scaffold
  paid dogfood — is the locked default; still present it as one of three).

## Acceptance (testable, EARS-style)

1. WHEN the session opens THEN the fold count and dollar saving are re-derived LIVE from real data
   on this machine (or their absence is stated as a measured fact), never quoted from STATE.md.
2. WHEN the verdict is reached THEN it is recorded in a spine record that EXISTS, citing that
   measurement, and `## Design` names the choice and the rejected alternative.
3. WHEN the verdict is KILL THEN no code path, README line, VISION line or scaffolded template
   still implies compression, and a grep-based check proves it across ALL of them (including the
   `vajra init` twin — S128/S129: assume any list here has a twin that has already drifted).
4. WHEN the verdict is KEEP THEN every surviving claim states what actually happens today, and a
   check FAILS if a savings claim reappears.
5. A falsifiability fixture drives the losing branch's own risk, each probe asserting its own
   pattern matched (S127), failing for the right reason (S122).
6. Traced, not asserted: `K of 8`, the 7 commands, S131's Fidelity gate and S132's Obeyed gate are
   unchanged by this session.
7. `verify-session-133.sh` and `demo-session-133.sh` both exit 0 with a printed check-class tally.
8. Independent cold `fidelity-reviewer` verdict ACCEPT, attested. Note (S132's own lesson): the
   judge of an `obeyed:` disposition may NOT be the role that made the recommendation, so a
   `fidelity-reviewer` recommendation needs a DIFFERENT role's dispatch to grade it — dispatch
   `implementation-advisor` as judge, and land every commit an `obeyed:` will cite BEFORE that
   dispatch.
9. The summary states plainly what is still NOT fixed, including whether the verdict is reversible
   and at what cost.

## Plan (ordered — cite the acceptance criteria each step covers)

1. Measure first, decide second: derive the live fold/saving numbers (or their measured absence).
   covers: 1
2. Put the numbers in front of the founder with the two branches' costs, and take the call.
   covers: 2
3. Record the verdict in a spine record + `## Design`. covers: 2
4. Execute the losing branch across code, README, VISION and the scaffolded twin. covers: 3, 4
5. Falsifiability fixture for that branch's own risk. covers: 5
6. Prove nothing else moved — `K of 8`, 7 commands, S131's and S132's gates. covers: 6
7. `scripts/verify-session-133.sh` + `scripts/demo-session-133.sh`. covers: 7
8. Dispatch the cold `fidelity-reviewer` pass, then a separate judging dispatch. covers: 8
9. Say in the summary what is still not fixed. covers: 9

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>
- step 5 — done: <sha>
- step 6 — done: <sha>
- step 7 — done: <sha>
- step 8 — done: <sha>
- step 9 — done: <sha>

## Advice (every recommendation from this session's advisors, answered)

(Filled during S133. `vajra next --check-advice 133` BLOCKS the close until every recorded
recommendation is answered, and `vajra next --check-obeyed 133` BLOCKS until every `obeyed:` claim
carries an independent judgment — S132's gate, now binding on every session.)

## Design

- design-significant: yes — removing or permanently re-scoping a subsystem named in two ADRs is a
  spine-level decision, and the KEEP branch changes what the product claims about itself.
- Spine records to cite: ADR-0001 and ADR-0003 (the compression wedge as originally decided) — verify
  both exist before citing them. A superseded ADR is marked superseded, never deleted.
- Open design question for S133 to resolve and record here: does the verdict live as an addendum to
  ADR-0001/0003, or as a new `docs/decisions/DECISION-00N`? Decide and give the reason.

## Non-goals (not built this session)

- Not S134's fresh-scaffold paid dogfood.
- Not the F2a judge-identity question, F2b (the regress), F2c (three selection rules), or S131's F2
  content-binding residual — all named and open, none this session's.
- Not K2–K4 (the other kill candidates) — parked, not decided.
- Not the fourth fork (`TPL_CONSTRAINTS`).
- No release, no crates.io action.

## Delta (vs ROADMAP — OpenSpec markers)

- ADDED: a recorded verdict on compression, and whichever guard the surviving branch needs.
- MODIFIED: `.ai/ROADMAP.md` K1 (open -> decided); README/VISION claims about compression; possibly
  `src/engine/` and its hook wiring.
- UNCHANGED: the 9 roles, the 8 stations, the 7 commands, `K of 8`'s derivation, S131's Fidelity
  gate and S132's Obeyed gate.

## Guardrails

- Un-forgeable commit marker on every commit, session number 133. Max 3 files per atomic commit.
- A check that cannot evaluate FAILS (S69). A fixture must fail for the RIGHT reason (S122), and a
  probe must assert its own pattern matched (S127) — including positive controls (S132).
- Do not defer the verdict. "Decide later" is the outcome this session exists to end.
- Attest LAST (S69/S131): recompute `--inputs-sha 133` after every edit to this prompt; two
  consecutive runs must agree. Run the full `verify-closeout.sh` on the branch BEFORE merging (S83).
