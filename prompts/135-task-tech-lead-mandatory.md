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

**CODE — by explicit founder override of the Ground Truth rule, decided in chat at the S134
closeout.** `135 % 5 == 0`, so the constitution makes this a mandatory NO-CODE Ground Truth session
and the hooks enforce it. The founder converted it to a CODE session, and **decided that this
cycle's Ground Truth is SKIPPED entirely rather than deferred — the next GT is S140.**

**This is the first skipped Ground Truth in the project's history.** It is recorded here as a
DECISION, not left to look like drift, so no future audit has to guess. The founder's reason:
**S134 already did most of a review session's work** — it audited the fleet, counted every dispatch
in the repo's history, found two structural holes, and corrected a 45× cost error, which is more
direction-checking than a typical GT produces.

**The concern was raised and overruled, and both halves belong on the record:** GT is the only
instrument that asks *are we building the right thing* rather than *did we follow our own rules*,
and S140 is five sessions away. If S135–S139 drift, nothing is scheduled to catch it.

**To run this session you MUST launch with the founder waiver:**

    VAJRA_GT_WAIVER=135 vajra claude

Without it the pre-write hook refuses every edit under `src/` and the pre-bash hook refuses every
commit. The waiver is founder-held — set in the LAUNCH environment, which the agent cannot set for
itself mid-session — and is scoped to this one session number, so a blanket `=1` or a stale number
does nothing. It shipped in S134's closeout **deliberately**, rather than as S135's own first act:
a Ground Truth session that disables its own Ground Truth enforcement is precisely the self-granted
jurisdiction this repo keeps writing findings about.

Max 2 assumptions, 2 retries, 1 story, ~2h, new chat. One story: **a role that no session can
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

## The phases, and the BUDGET REALITY that reshaped them — founder decisions, S134 closeout

**The constraint, stated first because it drives everything below: the founder is on a `$20`/month
Claude Code plan.** S134 used **three** dispatches costing **19,192,697 raw tokens** and **hit the
monthly limit mid-session** — that is what killed its judge's re-grade. Nine dispatches of that size
is roughly 58M and would wall a session partway through.

**PHASE 1 — THIS SESSION. Build the mechanism; do NOT run all nine.** Founder's call, taken over the
alternatives (tight budgets with all nine in one session; three roles per session, rotating). S135
ships the `tech-lead`, the binding gate and the cost reporting, and proves them with **2–3 real
dispatches**, not nine.

**PHASE 1b — THE ALL-NINE OBSERVATION, DEFERRED until the budget allows it.** This is where the
learning actually happens and it is NOT happening this session.

**PHASE 2 — the off switch**, only after 1b. Once each role's real behaviour is on record — does it
find real things, does it grade honestly, does its advice change the work — the `tech-lead` earns
the power to mark a role not-needed. **Six of the nine have been dispatched twice or fewer in 134
sessions; you cannot tune what you have never observed.** A session that adds the off switch before
1b's evidence exists is violating this record, not extending it. Say so in the code comment guarding
it.

### The risk this ordering creates, raised and OVERRULED — record it, then guard against it

Deferring the observation means **S135 ships a mechanism nobody runs**, which is this repo's own
most-repeated failure: *"a role no gate consumes is decoration"* (S125), *"a registered gate nobody
executes is not a gate"* (S129). The founder chose this path with that stated. **So S135 must not
close having merely built the thing** — the gate has to bind on this very session, and the summary
must say how many roles actually ran and what each did.

### The two verdicts, and why they are on DIFFERENT axes

A `tech-lead` that marks all nine `required` while the account can afford three would **block every
session.** So phase 1 admits exactly two values, and the distinction is load-bearing:

- **`required`** — this task needs this role.
- **`deferred-budget`** — **a money fact, not a judgement about usefulness.** It must carry the
  budget arithmetic that justifies it.

This preserves precisely what the founder withheld: the lead may **not** say *"this role isn't worth
it"* (an unobserved judgement — that is phase 2). It may say *"we cannot afford it this session"*,
because that is a checkable fact about a `$20` plan.

**Anything else — a bare skip, a `not-needed`, an empty reason — is REFUSED by the gate**, and the
refusal message names phase 1b as the condition for earning more.

### The lever that makes all-nine affordable later, and should be built into the budgets NOW

Of S134's 19.2M raw tokens, **17.5M were cache reads** — the cost of each subagent re-reading a large
context. Those dispatches were deliberately huge (*read the whole repo, grade 34 items*). **A role
given a narrow brief and three named files costs a fraction of that.** So the `tech-lead`'s budget is
not bookkeeping bolted on; it is the mechanism that makes phase 1b possible. Budgets set here should
be tight on purpose, and the summary should report actual-against-allowance so phase 1b can be
planned with real numbers rather than hope.

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

## chitra is NOT upgraded this session — founder decision, S134 closeout

chitra has **4 of 9** role files, so the `tech-lead` there could only ever call on four. That is a
real gap and it is **deferred to just before the next dogfooding session**, by the founder's explicit
call. It is not dropped, and it is not this session's work.

**Say so plainly in the summary rather than letting it look finished:** until chitra carries the
full roster, the `tech-lead` remains a Vajra-only feature — which is the exact thing the founder
called out (*"we are building it for the user, not for us"*). S135 narrows that gap in the product;
it does not close it in the one project that would prove it.

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
- `scripts/verify-session-135.sh` + `scripts/demo-session-135.sh` + a falsifiability fixture, all
  exit 0 with a printed check-class tally. `sessions/session-135-summary.md` + 3 ranked candidates.

## Acceptance (testable, EARS-style)

1. A `tech-lead` handoff is required before the close, and the gate names it as the FIRST role.
2. The handoff records all **nine** specialist roles, each with a verdict of `required` or
   `deferred-budget`, a substantive reason (gated by `advice::substantive_reason`, the S133
   function, verbatim — no new parser), and a numeric token budget. A `deferred-budget` verdict must
   carry the budget arithmetic that justifies it.
3. **Phase 1 has no off switch:** any value other than those two — `not-needed`, a bare skip, an
   empty reason — is REFUSED by the gate, and the refusal message names phase 1b as the condition
   for earning more. A test binds to that behaviour by VALUE, not by message text (S133).
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
8. **The gate BINDS ON THIS SESSION, not merely on future ones** — S135 dispatches 2–3 real roles
   through its own `tech-lead` decision and cannot close without their handoffs. This is the guard
   against shipping decoration (S125/S129), and it is the acceptance criterion the founder's
   "build now, observe later" choice makes load-bearing.
9. No `VAJRA_SKIP_*` escape for the crew gate, matching S133. Twelve-plus environment variables
   driven live, singly and together; it blocks every time.
10. `verify-session-135.sh` and `demo-session-135.sh` exit 0 with a printed check-class tally, and a
    falsifiability fixture goes RED on each planted bypass — every substitution asserting it landed,
    **and the positive control asserting a CLEAN EXIT 0** (S134: a sandbox missing one file made the
    exit-code half of every assertion meaningless).
11. Independent cold `fidelity-reviewer` verdict ACCEPT, attested. The judge of any `obeyed:`
    disposition may not be the role that made the recommendation.
12. The summary answers three questions directly: **how many roles actually ran and what each one
    did** (the guard against shipping decoration); **what the session cost in RAW subagent tokens**,
    never a new-tokens-only figure (S134 got this wrong by ~45× and caught it only by hand); and
    **what phase 1b would cost**, estimated from this session's actual-against-allowance numbers, so
    the founder can decide when a `$20` plan can afford the all-nine observation.

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
8. Dispatch 2–3 real roles through this session's own `tech-lead` decision, so the gate binds here.
   covers: 8
9. `verify-session-135.sh` + `demo-session-135.sh` + the fixture with a clean-exit control.
   covers: 10
10. Cold `fidelity-reviewer` pass, then a separate judging dispatch by a third role. covers: 11
11. Record what each forced role actually did, and the session's RAW token cost. covers: 12

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: dda4117
- step 2 — done: 99709c6
- step 3 — done: 1ee85f1
- step 4 — done: d72c0dd
- step 5 — done: d72c0dd
- step 6 — done: 1c5255a
- step 7 — done: c03aa6a
- step 8 — done: PENDING_STEP8
- step 9 — done: c03aa6a
- step 10 — done: PENDING_STEP10
- step 11 — done: PENDING_STEP11

## Advice (every recommendation from this session's advisors, answered)

(`vajra next --check-advice 135` BLOCKS the close until every recorded recommendation is answered,
and `vajra next --check-obeyed 135` BLOCKS until every `obeyed:` claim carries an independent
judgment from a role that is not the one that gave the advice.)

**design-advisor — 6 recommendations, dispatched FIRST (the S133 mandate, met by real use).**

- design-advisor rec 1 — obeyed: 99709c6
- design-advisor rec 2 — obeyed: 99709c6
- design-advisor rec 3 — obeyed: 99709c6
- design-advisor rec 4 — obeyed: 99709c6
- design-advisor rec 5 — obeyed: d72c0dd
- design-advisor rec 6 — obeyed: d72c0dd

*(rec 1–4 landed in the `## Design` commit `99709c6`: marker kept `yes`, DECISION-007 S135 addendum
written, Q1 handoff-only and Q2 distinct `deferred-budget` outcome recorded. rec 5 (`from_session: 0`,
no threshold) and rec 6 (the crew gate built as a CALL SITE, 0 shared-ladder lines) landed in the
crew module commit `d72c0dd`. An independent role — NOT the design-advisor — judges these via
`--check-obeyed` at close.)*

**tech-lead — 3 recommendations (the crew decision itself; the FIRST-and-mandatory dispatch,
achieved live this session after a mid-session registry refresh — Decision 4).**

- tech-lead rec 1 — deferred: sessions/session-135-summary.md
- tech-lead rec 2 — deferred: sessions/session-135-summary.md
- tech-lead rec 3 — deferred: sessions/session-135-summary.md

*(All three are process recommendations, addressed in the summary's dispatch accounting: rec 1 —
exactly three specialist dispatches ran (design-advisor · fidelity-reviewer · implementation-advisor)
plus the tech-lead itself; rec 2 — every brief was named-files-only, so the raw totals stayed in the
hundreds of thousands, not millions; rec 3 — all six deferred-budget lines are answered as
`deferred:` with their arithmetic, not `refused:`.)*

**fidelity-reviewer — 2 recommendations (pass 2, ACCEPT; pass 1's REJECT findings were all fixed
in-session — see the summary).**

- fidelity-reviewer rec 1 — deferred: sessions/session-135-review.md
- fidelity-reviewer rec 2 — deferred: sessions/session-135-summary.md

*(rec 1 — record criterion 7 as PARTIAL: DONE, the review of record grades it PARTIAL and the summary
discloses it as the session's honest limit. rec 2 — build the budget-into-brief injection: DEFERRED
to a follow-up, which the reviewer itself scoped as a follow-up; it is candidate work in the summary.)*

**implementation-advisor** produced `obeyed-check` judgments (not `rec` lines): 6/6 of the
design-advisor's dispositions `implemented:`, 0 mismatch. `vajra next --check-obeyed 135` reads them.

## Design

- design-significant: yes — a tenth role, a new gate, a new binding relationship between roles
  (one role's output makes another role mandatory), and the first cost control in the product.
  New interface and new module, not a fix.
- Spine records cited (both verified to exist): `DECISION-007` with its **S133 addendum** (L862,
  the ladder and the reasoned skip this builds on) and its **S134 addendum** (L947, the brownfield
  hole). A NEW **S135 addendum** is written into `DECISION-007` this session — the design-advisor
  (rec 2) flagged that S135 does not merely extend the record, it RESOLVES the open threshold
  question the S134 addendum explicitly deferred (L986–997), and a decision that closes a locked
  record's open clause must be written back into the spine, not left living only in a prompt.

**The three design questions — DECIDED (design-advisor dispatched first; handoff
`.ai/handoffs/session-135-design-advisor.md`, provenance re-verified):**

- **Decision 1 (Q1) — HANDOFF-ONLY.** The `tech-lead`'s crew decision lives ONLY in its
  provenance-verified handoff, never mirrored into a builder-owned prompt section. *Loser: a
  `## Crew` block in the prompt* — rejected because it re-opens the "jurisdiction is self-granted"
  dodge S133 disclosed (the builder can type its own record) and creates a second source that
  drifts. Disclosed cost: a reader of the prompt alone cannot see the crew decision;
  `vajra next --check-crew NN` surfaces it on demand, which is the acceptable price of un-forgeability.
- **Decision 2 (Q2) — a spend-limit death is a DISTINCT recorded outcome, not a bare block.** When a
  `required` role's dispatch dies mid-flight (as S134's judge did), the session may NOT manufacture a
  handoff and may NOT upgrade the item to a pass. It re-runs the `tech-lead` decision to move that
  role to `deferred-budget` **carrying the arithmetic that killed it**. The close then passes on a
  recorded money fact, not on confidence. *Loser A: a plain block with no recorded outcome* —
  unhelpful when genuinely out of budget and it tempts a self-certified pass. *Loser B: auto-downgrade
  `required`→`deferred-budget` inside the gate on any missing handoff* — rejected hard: that is a
  silent escape from every required role and guts the gate. The downgrade is an explicit,
  arithmetic-carrying re-decision, never automatic.
- **Decision 3 (Q3) — NO migration threshold. The crew gate enforces from session one, always
  (`from_session: 0` at the call site).** This is the fix to the S134 brownfield hole, not a repeat
  of it: a brand-new role has zero legacy prompts to exempt, so silence about the `tech-lead` blocks
  in every project at every session, forever — exactly what the S134 addendum said a threshold
  *should* mean but its session-number units do not. *Loser A: reuse threshold 133* — meaningless for
  a role that did not exist at S133 and would silently exempt S1–S134 of any brownfield adopter,
  importing the exact hole. *Loser B: build a real units-fix now (git-birth-date / adoption marker)* —
  over-engineering on n=1; the S134 addendum itself says n=1 does not earn a mechanism. Reasoned in
  writing in the DECISION-007 S135 addendum so no future audit mistakes it for the S134 defect.
- **Decision 4 (the bootstrapping wall — found live, and the mid-session refresh that beat it) —
  S135's HEADLINE OPERATIONAL FINDING.** A brand-new NATIVE-SUBAGENT role is normally NOT dispatchable
  in the session that creates it: Claude Code snapshots `.claude/agents/` at session START, so
  `tech-lead.md` (written this session) was absent from S135's initial dispatch registry — the first
  attempt to dispatch `subagent_type: tech-lead` was refused with "agent type not found". This is the
  SAME wall that made `design-advisor` (created S126) first dispatchable at S133. **The founder, asked
  in chat while the wall was up, chose Option A (ship + let the gate BLOCK S135's own `--advance`
  live).** Then the harness RE-SCANNED `.claude/agents/` mid-session and `tech-lead` became
  dispatchable — so S135 does one BETTER than Option A: it dispatches a real, provenance-verified
  `tech-lead` whose crew decision the gate reads, and the gate then BINDS honestly through the close.
  **The binding is a sequence, not an instant, and the cold review caught the difference (pass 1,
  REJECT).** The tech-lead marks three roles `required` (design-advisor, implementation-advisor,
  fidelity-reviewer); `vajra next --check-crew 135` correctly BLOCKS until all three handoffs are on
  disk, and PASSES only once they are — which is the final act of the close, after the fidelity and
  judge dispatches land. The mid-flight block IS the gate biting its own session; the pass is earned
  at the end, not asserted early. **The wall is still real and recorded:** a mid-session
  refresh is not guaranteed, so the reliable rule remains "a native-subagent role first binds the
  session AFTER it is created" — and verify's sandbox fixtures (a real tech-lead handoff built by the
  binary) prove the PASS path independently of whether any given harness refreshes. *Rejected: a
  founder-gated bootstrap waiver, and silently re-scoping acceptance 8 to S136* — both are unnecessary
  now that a real tech-lead dispatch is possible; a gate satisfied by real work beats both a waved-through
  green and a deferral. S135 still closes via `verify-closeout.sh` (which does not run the crew gate);
  `--advance` is the surface the crew gate binds.
- **The call-site claim (design-advisor rec 6, the falsification test):** the crew gate is built as a
  CALL SITE on `src/mandate`'s generic `mandate_gate` — `from_session: 0` for the tech-lead's own
  presence, then crew-gate-specific code parses the verified handoff and calls the EXISTING per-role
  handoff verification once per `required` role. Prediction on record: **0 lines added to
  `mandate_gate` / `parse_skip_marker` / `classify_marker_value`.** If the ladder had to change, that
  is the session's headline finding (acceptance 5), reported as a number.

## Non-goals (not built this session)

- **NOT the off switch.** Phase 2 only, after the observation sessions. Building it here defeats the
  entire point and contradicts a recorded founder decision.
- **Not a hard mid-run token cap, and not a punishment for overrun.** The cap does not exist in the
  dispatch interface, and building distrust in its place is a founder-refused direction: the role is
  told its budget and trusted to respect it. An overrun is data for phase 2, never an offence.
- **NOT the all-nine observation (phase 1b).** Deferred until the budget allows. This is where the
  learning happens, and deferring it is the acknowledged cost of the founder's "build now" choice.
- **NOT chitra's scaffold upgrade.** Founder's call: it happens just before the next dogfooding
  session, not here. Until then the `tech-lead` is a Vajra-only feature and the summary must say so.
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

- **Launch with `VAJRA_GT_WAIVER=135`** or every code edit and every commit is blocked. See `## Type`.
- **The founder is on a `$20`/month plan and S134 hit the limit with THREE dispatches.** Budget every
  dispatch tightly: a narrow brief and named files, never "read the repo". If a dispatch dies
  mid-flight on a spend limit — as S134's judge did — record the result as INCOMPLETE. Never upgrade
  an unjudged item to a pass because the builder is confident.
- **The GT skip is a one-cycle founder decision, not a new default.** The every-5th cadence resumes
  at **S140**. A session that reads this file must not treat the skip as precedent.
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
