# Session 128 — CODE: a SECOND gate consumes its role's handoff

> **Status:** DRAFT — the Analyst gate (`vajra next --advance`) BLOCKS starting this session while
> DRAFT. Flip to `APPROVED` once the founder signs off.
>
> **⚠️ THIS IS THE AGENT'S RECOMMENDED PICK, NOT THE FOUNDER'S DECISION.** The S127 closeout
> presented three ranked candidates (`sessions/session-127-summary.md`). This file is candidate
> **A**, written so the session has a real contract to start from. **If the founder picks B (close
> the `obeyed:` hole) or C (unpark the S125 reboot backlog), replace this file.** The DRAFT status
> is deliberately the place that decision gets recorded.
>
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**,
> not a status report. Do NOT soften them. **No release** until reality meets them.

## Type

**CODE. Max 2 assumptions · 2 retries · 1 story · ~2h · new chat.** One story: *a second station's
gate binds on its role's governed handoff.* Commits need the un-forgeable marker —
`VAJRA_ALLOW_COMMIT=128 git commit …`.

## Why this session

S126 completed the roster: nine roles, one per station, and **nothing depended on any of them.**
S127 changed that for exactly one gate — advice a session asks for must now carry a recorded,
existence-gated disposition or the close BLOCKS. **The honest headline today is "one of eight."**

That is one notch up from nine decorations, not ten. The founder's gate to unpark the S125 reboot
backlog was *the SDLC agent fleet is done AND working*; whether one consuming gate satisfies
*working* is their call, and this session is what makes the answer plainly yes rather than
arguable.

**The risk to design against, named up front:** S125's finding was *a role that no gate consumes is
decoration*. The failure mode for S128 is its exact sequel — **a second consumer that nothing
reaches for is a second decoration.** Pick the station whose role is actually dispatched in
practice, and make the binding one a session would hit without being told to.

## Goal

Make one more station's `--check-*` path bind on its role's governed handoff as real evidence, so
that skipping that role has a consequence — using the S127 read side and the existence-gated
recorded-marker pattern, adding no new store, no new artifact type, and **no 8th command**.

## Deliverables

- One station gate (QA or Demo-er — decide in `## Design` and record why) that consumes its role's
  handoff as a binding input, failing closed on `Malformed` and staying silent on `Absent`.
- The role's system prompt states the exact marker the gate parses, rendered from the one canonical
  source so a tenth role inherits it (the S127 `RECOMMENDATION_NUMBERING_RULE` pattern).
- A `DECISION-007` S128 addendum: what the second consumption binds on, the fork it settled, the
  rejected alternatives, and the residual.
- `scripts/verify-session-128.sh` + `scripts/demo-session-128.sh`, both exit 0, with the
  check-class tally.
- `sessions/session-128-summary.md` + exactly 3 ranked next candidates.

## Acceptance (testable, EARS-style)

1. **WHEN** the chosen station's role has recorded a contract-valid handoff for session NN **AND**
   the evidence that handoff requires is absent from the session's record **THEN** the station's
   `--check-*` BLOCKS (exit 1), naming the role and the handoff path — proven by running the real
   binary, not by reading source.
2. **WHEN** that evidence is present **THEN** the same command passes and INLINES what it consumed
   (a path alone is not consumption — S112).
3. **WHEN** the handoff exists but fails its contract **THEN** the gate BLOCKS and says why —
   `Malformed` is never swallowed as `Absent` (S69).
4. **WHEN** no handoff exists for that role **THEN** the gate behaves exactly as it did before this
   session — legacy-compatible and silent, proven against a session that predates the contract.
5. **Driven, not read:** an execute-based check drives `vajra next --advance` with every *other*
   stage neutralised by its own documented override, so the refusal can only be this gate's — the
   S127 `advance-really-binds-on-unanswered-advice` shape.
6. **Traced, not asserted:** `K of 8` unchanged in derivation and shape, the command count stays 7,
   and no other gate's evidence contract moves.
7. A falsifiability fixture turns the suite RED **for the right reason** (S122) — deleting the
   consumption, not renaming a message string — **and every probe asserts its own pattern matched**
   (S127: two probes silently no-opped after `cargo fmt` reflowed the lines and printed GREEN).
8. `verify-session-128.sh` and `demo-session-128.sh` both exit 0 with a printed check-class tally,
   every check execute-based or honestly labelled.
9. Independent cold `fidelity-reviewer` verdict **ACCEPT**, attested.
10. **The summary states the count plainly:** how many of the eight station gates now consume a
    handoff, and how many do not. **"Two of eight" is the honest headline if two is the number.**

## Plan (ordered — cite the acceptance criteria each step covers)

1. **Pick the station on evidence, not taste.** Which role is actually dispatched in practice, and
   what would a session lose by skipping it? Record the answer and the rejected station.
   `covers: 6`
2. **Decide what the gate BINDS on** — the marker, and why a machine can check it. `covers: 1`
3. **Consume the handoff** through the S127 read side, inlining what it reads. `covers: 2, 3`
4. **Legacy compatibility:** prove a pre-contract session closes exactly as before. `covers: 4`
5. **Wire it into the close path** and drive it live. `covers: 5`
6. **Prove nothing else moved.** `covers: 6`
7. **The falsifiability fixture**, with self-asserting probes. `covers: 7`
8. **`scripts/verify-session-128.sh` + `scripts/demo-session-128.sh`.** `covers: 8`
9. **`DECISION-007` S128 addendum.** `covers: 6, 10`
10. **Independent cold `fidelity-reviewer` pass.** `covers: 9`
11. **State the count in the summary.** `covers: 10`

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
- step 10 — done: `<sha>`
- step 11 — done: `<sha>`

> **Fill these with real landing shas before closeout.** S119, S122 and S124 each left `<sha>`
> placeholders and only an independent cold review caught it — never self-noticed.

## Advice (every recommendation from this session's advisors, answered)

> The S127 contract. One line per recorded recommendation: `- <role> rec N — obeyed: <sha>` /
> `refused: <reason>` / `deferred: <path>`. `vajra next --check-advice 128` BLOCKS the close until
> every one is answered.
>
> **Read S127's residual before trusting this section's count:** four `obeyed:` labels in its
> 51-answer ledger were factually wrong and passed the gate. **A disposition certifies a typed word
> and a resolving sha, and nothing else.** Answer honestly or answer `refused:` — a reasoned
> refusal is a pass by design, and a false `obeyed:` is the one thing this contract cannot see.

- *(none yet — fill as advisors are dispatched)*

## Design

- design-significant: **yes** — a second binding contract between the fleet's write side and a
  station's gate, extending the reversal the `DECISION-007` S127 addendum recorded.
- **Spine record cited:** `docs/decisions/DECISION-007-agent-fleet.md` (exists; its S127 addendum
  lifted the S116 deferral narrowly, for one gate). **This session widens that lift** and must
  record an S128 addendum saying so — a citation is not permission, and the Architect gate checks
  existence, not obedience.
- **The fork to argue, not assume:** QA or Demo-er. Both already re-run their script LIVE at close,
  so both have somewhere real for a handoff to bind. Argue it on which role a session actually
  reaches for, and record the loser.
- **Consumption must inline content, never a path** (S112).
- **`Malformed` must never be swallowed as `Absent`** — fail closed, and say why.

## Non-goals (not built this session)

- **Not all eight stations.** One more, argued and evidenced.
- **Not a judge of quality.** The same floor S127 recorded: a gate checks form and existence.
- No new role, **no 8th top-level command**, no new artifact type or store.
- **No S125 reboot-backlog items** — parked until the founder unparks them.
- No release, no crates.io action (founder directive).

## Delta (vs ROADMAP — OpenSpec markers)

- **ADDED:** a second station gate that consumes a governed handoff; a `DECISION-007` S128 addendum
  widening the S127 lift.
- **MODIFIED:** the fleet's status line — from "one gate of eight consumes a handoff" to two.
- **UNCHANGED:** the 8 stations, the 9 roles, the 7 commands, `K of 8`'s derivation, every other
  gate's evidence contract — and the fact that no gate can tell whether an answer was a good one.

## Filed findings carried in from S127 (fix as a side-order, or as a later candidate)

1. **The scaffold template has no `## Advice` section.** `vajra next --scaffold` still emits the
   pre-S127 shape, so every future prompt starts without the section its own close gate reads.
   Symmetric with the `## Design` (S67) and `## Execution` (S68) placeholders, which the scaffold
   does carry. Not fixed at S127 because the ACCEPT had already landed.
2. **`scripts/hook-session-guard.sh` false-arms on PROSE.** Its quoted-span strip only removes
   shell quotes, so a heredoc body merely *describing* the advance command trips the
   one-session-per-chat block. Hit live during the S127 closeout. S125's "spelling-bound guards
   over-block on words", inside the enforcement layer.
3. **A re-run handoff RENUMBERS** and the orphan warning does not fire when the counts happen to
   match (S127). Superseded answers survive only in the session record.
4. **`verify-session-114.sh` / `-116.sh` remain stale-red** on their own roster pins, and
   `verify-session-121.sh`'s check name still says "four" after being unpinned (carried from S126).

## Guardrails

- **`VAJRA_ALLOW_COMMIT=128`** on every commit. Max 3 files per atomic commit. Never `--no-verify`.
- **A gate that cannot evaluate FAILS** (S69). **A path is not consumption** (S112).
- **A fixture must fail for the RIGHT reason (S122) — and a probe must assert its own pattern
  matched (S127).**
- **Before adding the consumption, ask what breaks without it.** If the answer is "nothing a
  session would hit unprompted", pick the other station.
- **Answer this session's own advisors in `## Advice`** — and do not record `obeyed:` against a
  commit that does not contain the work. S127 did that four times.
- **Attest LAST (S69):** recompute `Review-Inputs-SHA` strictly after the Execution shas land; two
  consecutive closeout runs with `--inputs-sha 128` must agree before embedding.
