# Session 133 — CODE: the design-advisor becomes mandatory, and a skip must carry a reason

> **Status:** APPROVED — founder, in chat at the S132 closeout. This REPLACES the previously-written
> S133 (compression keep/kill), which is demoted to a pre-release checklist line: cutting unused
> code delivers nothing to a user and can be done in the hour before release.
>
> **The founder's own framing, in their words:** make the design-advisor and the
> implementation-advisor mandatory — both currently at effectively zero real use — "and if we want
> to skip we have to skip with a valid reason." This session does the FIRST of the two; S134 does
> the second on the same mechanism.
>
> Founder directive in force (S118): README.md / VISION.md claims are the target spec, not a status
> report. Do NOT soften them.

## Type

CODE. Max 2 assumptions, 2 retries, 1 story, ~2h, new chat. One story: the design-advisor's
governed handoff becomes required BEFORE code, with a recorded reason as the only way past it.
Commits need the un-forgeable marker on the command line at commit time.

## Why this session

Nine roles exist. **18 governed handoffs across 132 sessions**, and most of those were the session
that CREATED the role — used once, never called again. Measured live at the S132 closeout:

```
fidelity-reviewer 5 · implementation-advisor 3 · researcher 2 · qa-specialist 2
demo-producer 2 · requirements-analyst 1 · release-coordinator 1 · plan-advisor 1 · design-advisor 1
```

Only ONE role is mandatory (`fidelity-reviewer`, S131) and it runs at the END — it grades finished
work. The advisors that could change what gets BUILT are all optional, and optional loses to time
pressure every session.

**The evidence for picking design-advisor specifically, not a role at random.** The two most
expensive discoveries of the last two sessions were both DESIGN holes, both found by a cold reader
AFTER the code was written:

- **S131:** the provenance chain proves a dispatch happened, not that its returned content is what
  got filed (`.ai/ROADMAP.md` F2) — found at close, still open.
- **S132:** the whole gate was hung on the mandatory role's own handoff, and that role
  **structurally cannot grade its own advice**. Found by the second cold pass, at close. It cost a
  third dispatch and an extra hour to unwind (`.ai/ROADMAP.md` F2a).

Two for two. A design question costs minutes to ask before a line is written, and this repo keeps
paying for it at the end instead.

**What this is NOT.** The `fidelity-reviewer` is a cop — it grades finished work. An advisor
consulted before the work is a SECOND BRAIN handed to the builder. It informs; it does not grade.
This session builds the co-pilot half of `DECISION-007`, not more supervision (the founder's
"co-pilot, not cop" direction).

## Goal

A session cannot reach its first code commit without either (a) a real `design-advisor` governed
handoff, or (b) a RECORDED, substantive reason why this session does not need one. A silent skip is
no longer possible; a reasoned skip always is.

## Deliverables

- **The gate:** the `design-advisor` handoff is required before code, existence-gated and
  provenance-verified through the SAME chain S131 built and S132 reused (`src/dispatch/mod.rs`) —
  a hand-typed handoff must not satisfy it. Decide and RECORD in `## Design` whether this rides
  `--check-design` (the Architect station, which already asks the design question) or takes its own
  command like S131's did, and say why — the same explicit choice S131 and S132 each had to make.
- **The reasoned skip — the founder's own requirement, and the heart of this session.** Skipping
  must be possible and must cost a sentence. Design constraints, all binding:
  - The reason is RECORDED IN THE REPO (the session's own prompt — `prompts/` IS the memory), never
    an environment variable a launch script can set invisibly. `VAJRA_SKIP_*_GATE=1` is the existing
    pattern and is exactly what this session must NOT extend: an env var leaves no trace a reader
    can find later.
  - It is substantiveness-gated the way a `refused:` reason already is
    (`advice::substantive_reason`) — non-empty, not a `<placeholder>`. **State the floor out loud:
    this checks a reason was WRITTEN, never that it is good.** Do not fake judging it.
  - It is VISIBLE, not silent: a skipped session must say so in the gate's own output, so a reader
    sees "design review skipped — <reason>" rather than a clean green.
  - Reuse the house pattern (recorded marker + existence gate) — do not invent a new artifact, a new
    store, or a new file type (the S53 rule: map it to Vajra's own mechanism first).
- **Migration posture, recorded not silent** (the S132 precedent): every session S1–S132 predates
  this gate. Decide the threshold explicitly and say why; the threshold must govern SILENCE only,
  never a handoff or a reason that EXISTS.
- **A falsifiability fixture:** (a) a real design-advisor handoff -> PASSES; (b) no handoff and no
  reason -> BLOCKS; (c) no handoff plus a recorded substantive reason -> PASSES **and says so in the
  output**; (d) a placeholder reason -> BLOCKS; (e) a hand-typed handoff with unverifiable
  provenance -> BLOCKS. Each probe asserts its own pattern matched (S127) and fails for the right
  reason (S122), positive controls included (S132).
- **Dogfooded on its own session:** this session must itself pass through the gate it builds — a
  real `design-advisor` dispatch on this session's own design question (ride-along vs own command),
  landed as its governed handoff. If S133 needs a reasoned skip, the mechanism is wrong.
- `scripts/verify-session-133.sh` + `scripts/demo-session-133.sh`, both exit 0, printed check-class
  tally.
- `sessions/session-133-summary.md` + exactly 3 ranked next candidates (S134 — the same treatment
  for `implementation-advisor` — is the founder's stated default; still present it as one of three).

## Acceptance (testable, EARS-style)

1. WHEN a session reaches its code work with no `design-advisor` handoff and no recorded reason
   THEN the gate BLOCKS, naming what is missing and both ways to satisfy it.
2. WHEN a session records a substantive reason for skipping THEN the gate PASSES **and prints the
   reason**, so a skipped design review is visible in the output, never a silent green.
3. WHEN the recorded reason is empty or a template placeholder THEN the gate BLOCKS.
4. WHEN a `design-advisor` handoff exists but its provenance does not independently re-verify THEN
   the gate BLOCKS — a hand-typed handoff does not satisfy a mandatory role (S131's rule, reused).
5. The skip reason lives in the REPO and is readable by a human months later; no environment
   variable can silently satisfy or bypass this gate.
6. A falsifiability fixture drives all five directions above, each probe asserting its own pattern
   matched.
7. Traced, not asserted: `K of 8`, the 7 commands, S131's Fidelity gate and S132's Obeyed gate are
   unchanged by this session.
8. `verify-session-133.sh` and `demo-session-133.sh` both exit 0 with a printed check-class tally.
9. This session's OWN design question was put to a real `design-advisor` dispatch, and its handoff
   is landed — the gate satisfied by real use, not by a fixture.
10. Independent cold `fidelity-reviewer` verdict ACCEPT, attested. Remember S132's own lesson: the
    judge of an `obeyed:` disposition may NOT be the role that made the recommendation — dispatch
    `implementation-advisor` as the judge, and land every commit an `obeyed:` will cite BEFORE that
    dispatch.
11. The summary states plainly what is still NOT fixed — in particular whether a reasoned skip
    becomes the default dodge (the honest risk of this whole design), and what would show that
    happening.

## Plan (ordered — cite the acceptance criteria each step covers)

1. Put this session's OWN design question (ride `--check-design` vs its own command; where the
   reason is recorded) to a real `design-advisor` dispatch, and land its handoff FIRST — before any
   code. covers: 9
2. Record the choice and the rejected alternative in `## Design`, citing DECISION-007. covers: 9
3. Build the gate: handoff required, existence-gated, provenance-verified through the S131 chain.
   covers: 1, 4
4. Build the reasoned skip: recorded in the repo, substantiveness-gated, printed in the output.
   covers: 2, 3, 5
5. Decide and record the migration threshold; the threshold governs silence only. covers: 1
6. Falsifiability fixture, all five directions, each probe asserting its own pattern. covers: 6
7. Prove nothing else moved — `K of 8`, 7 commands, S131's and S132's gates. covers: 7
8. `scripts/verify-session-133.sh` + `scripts/demo-session-133.sh`. covers: 8
9. Cold `fidelity-reviewer` pass, then a separate judging dispatch for the dispositions. covers: 10
10. Say in the summary what is still not fixed, including the reasoned-skip risk. covers: 11

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

## Advice (every recommendation from this session's advisors, answered)

(Filled during S133. `vajra next --check-advice 133` BLOCKS the close until every recorded
recommendation is answered, and `vajra next --check-obeyed 133` BLOCKS until every `obeyed:` claim
carries an independent judgment from a role that is not the one that gave the advice.)

## Design

- design-significant: yes — this makes a second fleet role mandatory and introduces a new class of
  escape (a recorded, reasoned skip) that every future gate in this repo will be tempted to copy.
  Getting its shape wrong propagates.
- Spine record to cite: `DECISION-007` (the agent fleet) and its S131 addendum (mandatory roles,
  provenance) — verify both exist before citing them. `DECISION-002` for why an advisor informs and
  never certifies its own work.
- **Open design question for S133 to resolve and record here (and to put to the design-advisor
  itself, per Plan step 1):** does the gate ride `--check-design` (the Architect station already
  asks the design question, so a reader has one place to look) or take its own command (S131's
  reasoning: two gates checking genuinely different things should not share a command)? Decide, and
  record the loser's reason.
- **Second open question:** where exactly does the skip reason live — a line in `## Design`, a
  dedicated marker, or somewhere else? It must be greppable, human-readable months later, and
  impossible to set from the environment.

## Non-goals (not built this session)

- **Not the implementation-advisor** — that is S134, on this session's own mechanism. One role per
  session (max 1 story), so the mechanism gets proven once before it is copied.
- Not the other seven roles. Nothing here says all nine should be mandatory; the founder named two.
- Not compression keep/kill — demoted to a pre-release checklist line at the S132 closeout.
- Not F2 (content-binding), F2a (judge identity: ROLE vs DISPATCH), F2b (the regress), F2c (three
  selection rules) — all named and open, none this session's.
- Not the fresh-scaffold paid dogfood — **still locked and now further deferred; say so plainly in
  the summary rather than letting it fall off. It is the oldest un-run item on the roadmap** (last
  paid dogfood S124).
- Not the fourth fork (`TPL_CONSTRAINTS`). No release, no crates.io action.

## Delta (vs ROADMAP — OpenSpec markers)

- ADDED: the design-advisor as the fleet's SECOND mandatory role; a recorded, reasoned, visible skip
  as a first-class outcome rather than an invisible env var.
- MODIFIED: what a session must have before it reaches code; `.ai/ROADMAP.md` F2 (the "make the
  fleet used" plan gains its second proven role).
- UNCHANGED: the 8 stations, the 7 commands, `K of 8`'s derivation, S131's Fidelity gate, S132's
  Obeyed gate, and the other seven roles' optional status.

## Guardrails

- Un-forgeable commit marker on every commit, session number 133. Max 3 files per atomic commit.
- A check that cannot evaluate FAILS (S69). A fixture must fail for the RIGHT reason (S122), and a
  probe must assert its own pattern matched (S127) — including positive controls (S132).
- **Do not ship an env-var escape.** If the design pulls toward one, that is the signal the reason
  belongs somewhere else in the repo, not the signal to add `VAJRA_SKIP_DESIGN_GATE=1`.
- Do not fake judging the reason's quality. Say the floor out loud: it checks a reason was written.
- Attest LAST (S69/S131): recompute `--inputs-sha 133` after every edit to this prompt; two
  consecutive runs must agree. Run the full `verify-closeout.sh` on the branch BEFORE merging (S83).
