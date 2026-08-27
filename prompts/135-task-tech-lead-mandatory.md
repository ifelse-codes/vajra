# Session 135 — the `tech-lead`: the role that decides which roles run, and what each may spend

> **Status:** APPROVED — founder, in chat at the S134 closeout. This **REPLACES** the previously
> locked S135 (`implementation-advisor` mandatory). It is not a delay of that work: under this
> design `implementation-advisor` becomes mandatory *automatically*, because the `tech-lead` can
> call for it like any other role.
>
> **The founder's own framing, and the rebuke that produced it:** *"'agentic SDLC harness' is true
> inside the repo that builds it, and not true anywhere else — we are building it for the user, not
> for us."* That is the sentence this session answers.
>
> Founder directive in force (S118): README.md / VISION.md claims are the target spec, not a status
> report. Do NOT soften them.

## Type

CODE. Max 2 assumptions, 2 retries, 1 story, ~2h, new chat. One story: **a role that no session can
start without, which decides which of the crew this task needs and what each of them may spend.**

## Why this session — the evidence that forced it

S134 counted every dispatch in the repo's whole history:

| Role | Has a gate? | Dispatches in 134 sessions |
|---|---|---|
| `fidelity-reviewer` | **yes** | 7 |
| `implementation-advisor` | **yes** | 5 |
| `design-advisor` | **yes** | 3 |
| `researcher` | no | 2 |
| `qa-specialist` | no | 2 |
| `demo-producer` | no | 2 |
| `requirements-analyst` | no | 1 |
| `release-coordinator` | no | 1 |
| `plan-advisor` | no | 1 |

**Three gated roles: 15 uses. Six ungated roles: 9 uses, ever.** The law is not subtle — *a role is
used exactly as often as a gate forces it, and otherwise essentially never.*

And in chitra, the one real outside project: **0 dispatches, 4 of 9 role files on disk, 0 of 8
stations.** The harness is real here and decorative there.

## Goal

Ship `tech-lead` — the tenth role, the first that is not a specialist — as the **first and
mandatory** dispatch of every session. It records, per role, whether this task needs it and why,
plus a token budget for each. **Its verdict BINDS:** a role it marks required must produce a real
governed handoff or the session cannot close.

## The two-phase decision, recorded so a later session cannot quietly skip phase 1

**PHASE 1 — THIS SESSION. The `tech-lead` has NO off switch.** Its only admissible answer for every
role is `required`. The ability to mark a role `not-needed` is **deliberately NOT built**, and this
brief is the record of why: six of the nine roles have been dispatched twice or fewer in 134
sessions, so **nobody knows how they behave.** You cannot tune what you have never observed, and a
lead granted discretion on day one would simply relocate the self-granted skip one level up.

**PHASE 2 — A LATER SESSION, after a few sessions of running all nine.** Once each role's real
behaviour is on record — does it find real things, does it grade honestly, does its advice change
the work — the `tech-lead` earns the power to switch roles off.

**A session that adds the off switch before that evidence exists is violating this record, not
extending it.** Say so in the code comment that guards it.

## The budget — and the honest limit, verified live at S134's close

S134 measured what three dispatches actually cost, from the transcripts Claude Code writes to disk:

| Dispatch | raw total tokens |
|---|---|
| `design-advisor` | 4,928,036 |
| `fidelity-reviewer` | 6,152,671 |
| `implementation-advisor` | 8,111,990 |
| | **19,192,697** |

17.5M of that is cache reads. **This is why S134 hit the account's monthly spend limit**, which
killed its judge's re-grade mid-flight. Nine dispatches per session is plausibly **50–60M raw**.

**So the budget is not a nice-to-have — it is what makes phase 1 affordable at all.**

**Verified buildable:** `~/.claude/projects/*/*/subagents/agent-<id>.jsonl` carries per-turn `usage`,
and `src/meter/mod.rs` already folds that directory (`subagent_dir`). Reading a per-dispatch raw
total is real work on real bytes, not a new store.

**The budget is an INSTRUCTION, not a fence — founder's call, in chat, and it is the right one.**
A dispatch takes no budget parameter, so Vajra cannot hard-stop a subagent mid-run. That is not a
limitation to apologise for; it is the design. **The `tech-lead` tells each role what it may spend,
and the role is trusted to work within it.** A model given a budget will try to respect it. Building
a fence first assumes it is a cheater, and that is the opposite of `DECISION-001`'s co-pilot posture.

So the shape is: **allocate → the role works to its budget → measure afterwards to LEARN.** An
overrun is a **finding, not an offence** — it usually means the budget was wrong, not that the role
misbehaved, and phase 2 needs exactly that data to set sane numbers. Never describe it as a cap, and
never make it block. Measurement here serves the founder's understanding, not enforcement.

*(S134's own 45× error is the argument for measuring at all: nobody was cheating, and the number
was still wrong by an order of magnitude.)* The same machine-local disclosure as `--dogfood-age`
(S91) applies: a fresh CI runner has no `~/.claude/projects` history.

## chitra must be upgraded, or this is a Vajra-only feature again

chitra has **4 of 9** role files. The `tech-lead` there could only ever call on four, and phase 1's
"all nine" is literally impossible. **Re-install / upgrade Vajra's scaffold in chitra as part of
this session** so all ten role files exist there. That is the founder's explicit instruction and it
is the difference between building this for a user and building it for us.

**Guardrail:** chitra may still be mid-session with uncommitted work. Use S134's four-way
fingerprint (`git rev-parse HEAD` · `git ls-files -s | shasum -a 256` · `git stash list` ·
`git status --porcelain -uall`) before and after, declare the permitted delta in advance, and stop
and ask if anything else moved.

## Deliverables

- **`.claude/agents/tech-lead.md`** — the tenth role. It PROPOSES a crew and a budget; it never
  writes code, never dispatches, and never authors another role's handoff.
- **A `tech-lead` handoff recording, for every one of the nine specialist roles:** the role name,
  `required` (the only admissible value in phase 1), a substantive reason, and a token budget.
- **`vajra next --check-crew NN`** — rides `vajra next`, **no 8th top-level command**. Blocks the
  close unless (a) a real provenance-verified `tech-lead` handoff exists, and (b) every role it
  marked `required` has its own real governed handoff.
- **Built as a CALL SITE on `src/mandate`**, which S133 made generic over a `fleet::Role`. This is
  still the falsification test S133 never got: **if this session finds itself editing `mandate_gate`,
  `parse_skip_marker` or `classify_marker_value`, the genericity was decoration — report that as the
  headline finding, in a number: lines added to the shared ladder vs lines added as call site.**
- **`vajra next --crew-cost NN`** — reads the on-disk subagent transcripts and prints each
  dispatch's raw token total beside the budget the `tech-lead` recorded. It **reports**; it does not
  block and does not scold. An overrun is surfaced as information for setting better budgets.
- **The chitra scaffold upgrade**, with all ten role files present and the before/after fingerprint.
- `scripts/verify-session-135.sh` + `scripts/demo-session-135.sh` + a falsifiability fixture, all
  exit 0 with a printed check-class tally. `sessions/session-135-summary.md` + 3 ranked candidates.

## Acceptance (testable, EARS-style)

1. A `tech-lead` handoff is required before the close, and the gate names it as the FIRST role.
2. The handoff records all **nine** specialist roles, each with `required`, a substantive reason
   (gated by `advice::substantive_reason`, the S133 function, verbatim — no new parser), and a
   numeric token budget.
3. **Phase 1 has no off switch:** any value other than `required` is REFUSED by the gate, and the
   refusal message names this brief's phase-2 condition. A test binds to that behaviour by VALUE.
4. `vajra next --check-crew NN` blocks the close when the `tech-lead` handoff is missing, forged, or
   when any role it marked `required` has no real governed handoff. The 7-command floor is unchanged.
5. **The genericity claim is tested and reported as a NUMBER** — lines added to `src/mandate`'s
   shared ladder versus lines added as call-site/table. If the ladder had to change, that is the
   session's headline finding, not a footnote.
6. **`vajra next --crew-cost NN` reads REAL bytes** — per-dispatch raw totals derived from
   `~/.claude/projects/*/*/subagents/agent-<id>.jsonl`, reconciling against S134's recorded figures
   (4,928,036 / 6,152,671 / 8,111,990) as a fixture. A missing transcript FAILS rather than skips
   (S69) — the READING must be honest even though the budget does not enforce.
7. **The budget is carried INTO each role's brief**, so the role knows its allowance and can work to
   it. `--crew-cost` reports actual against allowance and **never blocks**; the code, the help text
   and the summary all describe it as an instruction the role is trusted to honour, not a cap.
8. **chitra carries all ten role files** after this session, installed by the real scaffold path
   rather than hand-copied, and chitra's in-flight state is undisturbed — proved by the four-way
   fingerprint before and after, with the permitted delta declared in advance.
9. No `VAJRA_SKIP_*` escape for the crew gate, matching S133. Twelve-plus environment variables
   driven live, singly and together; it blocks every time.
10. `verify-session-135.sh` and `demo-session-135.sh` exit 0 with a printed check-class tally, and a
    falsifiability fixture goes RED on each planted bypass — every substitution asserting it landed,
    **and the positive control asserting a CLEAN EXIT 0** (S134: a sandbox missing one file made the
    exit-code half of every assertion meaningless).
11. Independent cold `fidelity-reviewer` verdict ACCEPT, attested. The judge of any `obeyed:`
    disposition may not be the role that made the recommendation.
12. The summary answers two questions directly: **what did each of the nine roles actually do when
    forced to run** — the observation phase 2 depends on — and **what did the whole session cost in
    raw subagent tokens**, reported as a raw figure, never a new-tokens-only figure (S134 got this
    wrong by ~45× and caught it only by hand).

## Plan (ordered — cite the acceptance criteria each step covers)

1. Dispatch `design-advisor` FIRST and land its handoff — the S133 mandate, met by real use.
   covers: 11
2. Record the design, the phase-1/phase-2 split and the budget's honest limit in `## Design`.
   covers: 7
3. Write `.claude/agents/tech-lead.md` and the handoff grammar it must emit. covers: 1, 2
4. Add the call site on `src/mandate`; count the shared-ladder lines touched. covers: 4, 5
5. Enforce phase 1's no-off-switch rule with a value-bound test. covers: 3
6. Build `--crew-cost` against the real transcripts and reconcile with S134's figures. covers: 6
7. Drive twelve-plus environment variables live against the crew gate. covers: 9
8. Upgrade chitra's scaffold to all ten roles, fingerprinted before and after. covers: 8
9. `verify-session-135.sh` + `demo-session-135.sh` + the fixture with a clean-exit control.
   covers: 10
10. Cold `fidelity-reviewer` pass, then a separate judging dispatch by a third role. covers: 11
11. Record what each forced role actually did, and the session's RAW token cost. covers: 12

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
- step 10 — done: <sha>
- step 11 — done: <sha>

## Advice (every recommendation from this session's advisors, answered)

(Filled during S135. `vajra next --check-advice 135` BLOCKS the close until every recorded
recommendation is answered, and `vajra next --check-obeyed 135` BLOCKS until every `obeyed:` claim
carries an independent judgment from a role that is not the one that gave the advice.)

## Design

- design-significant: yes — a tenth role, a new gate, a new binding relationship between roles
  (one role's output makes another role mandatory), and the first cost control in the product.
  New interface and new module, not a fix.
- Spine records to cite (verify both exist first): `DECISION-007` with its **S133 addendum** (the
  ladder and the reasoned skip this builds on) and its **S134 addendum** (the brownfield hole).
- **Open design question 1:** does the `tech-lead`'s decision live in its handoff only, or is it
  also mirrored into the session prompt? The handoff is provenance-verified and un-typed by the
  builder, which is the whole point — mirroring it into a builder-owned file would re-open the
  self-granted dodge S133 disclosed. Decide, and record the loser's reason.
- **Open design question 2:** what happens when a required role's dispatch FAILS — as S134's
  re-grade did, on a spend limit? A blocked close is correct but unhelpful if the account is out of
  budget. Decide whether that is a distinct recorded outcome or simply a block, and say why.
- **Open design question 3:** the brownfield threshold from S134's addendum. `tech-lead` is brand
  new, so it has no legacy sessions to exempt — does it get a threshold at all? Arguably not, and
  arguably that is the fix to the whole threshold problem: **a role introduced with no threshold
  has no brownfield hole.** Decide and record.

## Non-goals (not built this session)

- **NOT the off switch.** Phase 2 only, after the observation sessions. Building it here defeats the
  entire point and contradicts a recorded founder decision.
- **Not a hard mid-run token cap, and not a punishment for overrun.** The cap does not exist in the
  dispatch interface, and building distrust in its place is a founder-refused direction: the role is
  told its budget and trusted to respect it. An overrun is data for phase 2, never an offence.
- **Not F2f** (the rubber-stamp detector) — though note this session makes it more valuable, since
  a `tech-lead` that requires nine roles and never reads their output is exactly a rubber stamp.
- **Not D2** (the fresh-scaffold first-contact paid dogfood) — still outstanding from S134's Q2.
- **Not fixing chitra's charts.** S134 handed chitra ranked proposals; acting on them is chitra's
  own work. This session only upgrades chitra's Vajra scaffold.
- Not compression, not F2/F2a/F2b/F2c, not the fourth fork.

## Delta (vs ROADMAP — OpenSpec markers)

- ADDED: a tenth role (`tech-lead`); a gate where one role's output makes other roles mandatory;
  the first per-role token budget; a chitra scaffold upgrade to the full roster.
- MODIFIED: what "mandatory role" means — from *this specific role is always required* to *no role
  is silently skipped, and an independent role decides*. F2e's answer follows from it.
- UNCHANGED: the 8 stations, the 7 commands, `K of 8`'s derivation, S131's Fidelity gate, S132's
  Obeyed gate, S133's ladder shape.

## Guardrails

- Un-forgeable commit marker on every commit, session number 135. Max 3 files per atomic commit.
- **chitra has its own constitution and its own hooks** — read `chitra/.ai/` and obey chitra's rules
  inside chitra. Do not import Vajra's. Do not disturb its in-flight work.
- **Report the RAW subagent token total, never a new-tokens-only figure.** S134 published a number
  that was wrong by ~45× and no instrument caught it.
- **Trust the crew (`DECISION-001`, founder restated at this closeout).** Measure to understand, not
  to catch. If a design choice here only makes sense against an adversarial subagent, it is the
  wrong choice — the adversary this product guards against is drift and self-certification, never
  the crew doing the work.
- **Count the shared-ladder lines honestly.** The temptation is to call a change to `mandate_gate` a
  small refactor. It is not — it is the falsification.
- A check that cannot evaluate FAILS (S69). A probe must assert its own pattern matched (S127),
  including positive controls (S132), and a fixture's positive control must assert a clean exit 0
  (S134).
- **Three consecutive judges have had no shell (S133, S134 ×2).** If this session's judge also has
  none, say so in the review rather than letting a reader assume otherwise.
- **A dispatch can die mid-flight on an account spend limit (S134, live).** If it happens, record
  the incomplete result as incomplete — never upgrade an unjudged item to a pass because the builder
  is confident.
- When a brief quotes fence syntax, never let a line START with the fence characters (S133).
- Attest LAST (S69/S131): recompute `--inputs-sha 135` after every edit to this prompt; two
  consecutive runs must agree. Run the full `verify-closeout.sh` on the branch BEFORE merging (S83).
