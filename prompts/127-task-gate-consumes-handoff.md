# Session 127 — CODE: make a gate CONSUME a handoff (the fleet's *working* half)

> **Status:** DRAFT — the Analyst gate (`vajra next --advance`) BLOCKS starting this session while
> DRAFT. Flip to `APPROVED` once the founder signs off.
>
> **Recommended at the S126 closeout (candidate A of three).** B (bind the dispatch evidence to
> the runtime) and C (the S126 findings sweep) both harden a fleet that nothing depends on yet;
> only A changes that. If the founder picks B or C instead, this prompt is superseded, not edited.
>
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**,
> not a status report. Do NOT soften them. **No release** until reality meets them.

## Type

**CODE. Max 2 assumptions · 2 retries · 1 story · ~2h · new chat.** One story: *one gate consumes
one role's handoff as evidence.* Commits need the un-forgeable marker — `VAJRA_ALLOW_COMMIT=127
git commit …`.

## Why this session

S126 completed the roster: **nine roles, one per station.** S125 established, and S126's own
summary repeats unsoftened, that **no gate anywhere consumes a handoff** — so skipping every role
has no consequence, and nine roles that nothing depends on is nine decorations.

The founder's gate to unpark the S125 reboot backlog is *"the SDLC agent fleet is done AND
working."* S126 closed **done**. This session is the first real attempt at **working**: it is
S116's own unpicked candidate C and S125's finding F2, and it is the smallest change that makes a
role load-bearing rather than optional.

**Scope discipline, learned from S58–S60:** do NOT wire all eight stations. Wire **one**, prove it
blocks, and let the next session generalise if the shape holds.

## Goal

Pick exactly one station and make its `--check-*` path read the matching role's governed handoff
as **evidence**, so that the gate's verdict differs depending on whether the role was actually
dispatched — and prove the difference by running it both ways.

## Deliverables

- One station's gate reading `fleet::read_handoff` for its role, with a recorded, documented rule
  for what a MISSING handoff does (WARN vs BLOCK — argue it, do not assume it).
- The honest floor stated in the module header, in the house style: what the gate can and cannot
  tell about a handoff it consumes.
- `scripts/verify-session-127.sh` + `scripts/demo-session-127.sh`, both exit 0, with the
  check-class tally.
- `sessions/session-127-summary.md` + exactly 3 ranked next candidates.
- A `DECISION-007` S127 addendum recording which station was wired first and why.

## Acceptance (testable, EARS-style)

1. **WHEN** the chosen station's check runs with the role's handoff absent **THEN** it emits the
   recorded outcome (WARN or BLOCK) naming the role and the path it looked for — proven by running
   the real binary, not by reading source.
2. **WHEN** a valid governed handoff for that role and session is present **THEN** the same command
   reports it as consumed, quoting real content from it — a path alone is not consumption (S112).
3. **WHEN** the handoff is present but malformed **THEN** the gate treats it as NOT consumed and
   says why, never silently as absent.
4. The choice of WARN vs BLOCK for a missing handoff is **argued in writing** in the addendum, with
   the rejected alternative named; a gate that blocks must state how a legitimate no-fleet session
   proceeds.
5. A falsifiability fixture shows the new check going RED for the right reason (S122) — deleting
   the consumption code, not merely renaming a string, must turn it red.
6. `vajra next --stations NN` still reports `K of 8` derived from station gates alone, unchanged in
   shape by this work.
7. `verify-session-127.sh` and `demo-session-127.sh` both exit 0 with a printed class tally.
8. Independent cold `fidelity-reviewer` verdict **ACCEPT**, attested.
9. The summary states plainly how much of the fleet is still optional after this session — one
   station wired is one station, not a working fleet.

## Plan (ordered — cite the acceptance criteria each step covers)

1. **Choose the station and record why.** The Reviewer/`fidelity-reviewer` pair is the obvious
   candidate (its verdict is already gated and attested); the QA pair is the other. Name the
   rejected one. `covers: 4`
2. **Decide WARN vs BLOCK for a missing handoff, and write the argument before the code.**
   `covers: 4`
3. **Wire the chosen gate to `fleet::read_handoff`,** consuming content inline, not a path.
   `covers: 1, 2`
4. **Handle the malformed case explicitly** — `HandoffRead::Malformed` must not read as absent.
   `covers: 3`
5. **Prove `K of 8` is unchanged in shape** by the new consumption. `covers: 6`
6. **Write the falsifiability fixture: delete the consumption, watch it go red.** `covers: 5`
7. **`verify-session-127.sh` + `demo-session-127.sh`,** every check execute-based or honestly
   labelled. `covers: 7`
8. **Independent cold `fidelity-reviewer` pass** fed only the prompt + the diff. `covers: 8`
9. **State in the summary how much of the fleet remains optional.** `covers: 9`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: `<sha>`
- step 2 — done: `<sha>`
- step 3 — done: `<sha>`
- step 4 — done: `<sha>`
- step 5 — done: `<sha>`
- step 6 — done: `<sha>`
- step 7 — done: `<sha>`
- step 8 — done: `<sha>`
- step 9 — done: `<sha>`

## Design

- design-significant: **yes** — this is the first time a gate's verdict depends on fleet output.
  The real fork is **WARN vs BLOCK on a missing handoff**: BLOCK makes the role load-bearing (the
  whole point) but makes every legitimate no-fleet session need an escape hatch, which is how
  `VAJRA_SKIP_*_GATE` env vars multiply; WARN keeps the fleet optional, which is the exact
  criticism S125 made.
- **Spine record cited:** `docs/decisions/DECISION-007-agent-fleet.md` (exists). This session
  appends an S127 addendum; it does not create a new decision record.
- **Recommended resolution, to be argued not assumed:** BLOCK, with the escape hatch being the
  *existing* recorded-marker pattern rather than a new env var — a session that legitimately did
  no fleet work records that fact, the same way `design-significant: no` records a non-significant
  design.

## Non-goals (not built this session)

- **Not all eight stations.** One station, proven, is the whole scope.
- No new role, no 8th top-level command, no new artifact type or store.
- **No S125 reboot-backlog items** beyond F2's core idea — they stay parked until the founder
  unparks them.
- Not fixing the other five S126 review findings (they are candidate C, filed in
  `sessions/session-126-review.md`).
- No release, no crates.io action (founder directive).

## Delta (vs ROADMAP — OpenSpec markers)

- **ADDED:** one station gate that consumes a role's governed handoff as evidence; a
  `DECISION-007` S127 addendum.
- **MODIFIED:** the fleet's status line — from "nine roles nothing depends on" to "nine roles, one
  of which one gate depends on"; the S125/S126 residual shrinks by exactly one station.
- **UNCHANGED:** the 8 stations, the 9 roles, the 7 commands, `K of 8`'s derivation, and every
  other gate's evidence contract.

## Guardrails

- **`VAJRA_ALLOW_COMMIT=127`** on every commit. Max 3 files per atomic commit. Never `--no-verify`.
- **A gate that cannot evaluate FAILS** (S69) — an unreadable handoff blocks, never passes.
- **A path is not consumption** (S112): the gate must show content it read.
- **A fixture must fail for the RIGHT reason** (S122): delete the feature, not a string.
- **Do not fix S126's findings here.** They are a separate candidate.
- **Attest LAST (S69):** recompute `Review-Inputs-SHA` strictly after the Execution shas land;
  two consecutive closeout runs with `--inputs-sha 127` must agree before embedding.
- **One station wired is not a working fleet.** If the session finds itself claiming the fleet now
  works, stop — criterion 9 forbids exactly that.
