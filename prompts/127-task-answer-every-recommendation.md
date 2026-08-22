# Session 127 — CODE: every recommendation must be ANSWERED (obeyed, refused, or deferred)

> **Status:** APPROVED — founder sign-off at the S127 open ("start session 127 all approved",
> 2026-08-22).
>
> **Founder-directed rewrite at the S126 closeout.** The first draft of this prompt gated on *a
> handoff exists*. The founder cut straight past it: **"the obeying is what all Vajra is — the
> agent obeys the prompt, and obeys in a deterministic way."** A gate that only proves a role was
> *asked* leaves the actual failure — advice read and silently dropped — exactly as invisible as
> before. This prompt gates on the ANSWER instead.
>
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**,
> not a status report. Do NOT soften them. **No release** until reality meets them.

## Type

**CODE. Max 2 assumptions · 2 retries · 1 story · ~2h · new chat.** One story: *advice you asked
for must be answered in writing.* Commits need the un-forgeable marker —
`VAJRA_ALLOW_COMMIT=127 git commit …`.

## Why this session

S126 completed the fleet roster: nine roles, one per station. S125 established, and S126's summary
repeats unsoftened, that **no gate consumes a handoff** — nine roles that nothing depends on are
nine decorations.

**S126 also produced the evidence for what actually goes wrong, twice, in its own record.** Both
were advice that was read and then silently dropped:

- the `demo-producer` said to show the `verify-session-121.sh` unpin in the before/after,
  "otherwise the before/after only shows the after". The shipped demo showed only the roster. The
  omission surfaced by luck, in a later cold pass that happened to read both the brief and the diff.
- the `design-advisor` found that this very session reverses a locked deferral in `DECISION-007`
  and needs an addendum lifting it. That finding **never reached the first draft of this prompt** —
  the brief was read at dispatch time and the prompt was written later, from memory.

Neither was defiance. Neither left a trace. **The defect is not disobedience — it is INVISIBLE
disobedience**, and no gate anywhere can see it.

### What a machine can and cannot decide (read this before designing anything)

"Did the agent follow this paragraph of advice?" is a judgement. No parser decides it, and any gate
claiming to is a fake green. What Vajra has always done instead is convert a judgement into a
**recorded marker a machine can check** — `covers: N`, `step N — done: <sha>`,
`design-significant: yes` + a spine record that EXISTS, `demo:before_after` in the LIVE output.

The missing marker is a **disposition**: for each recommendation, what did the session DO with it?
That is checkable, and it is deterministic:

```
advice given (numbered by the advisor)  →  a disposition recorded per item  →  gate checks all answered
```

**It does not force obedience, and must never be sold as if it did.** It forces an ANSWER. A
refusal with a written reason is honest disobedience and passes — that is correct and intended.
What becomes impossible is the silent version, which is the one that actually cost S126 twice.

## Goal

Make every numbered recommendation in a session's governed handoffs carry a recorded disposition —
`obeyed:` with a commit that exists, `refused:` with a real reason, or `deferred:` with a real
destination — and BLOCK the close of a session that leaves any of them unanswered.

## Deliverables

- Advisory role prompts emit each recommendation with an explicit `rec N —` marker (the S116
  contract shape: the role proposes in the exact form a gate already parses; it never authors the
  answer).
- A gate that reads the session's governed handoffs, counts the recorded recommendations, reads the
  `## Advice` section of the session's own prompt, and classifies each item —
  answered / unanswered / claimed-but-not-real.
- `vajra next --advice NN` (surface, read-only) and `--check-advice NN` (BLOCK), wired into the
  existing close path. **No 8th top-level command.**
- A `DECISION-007` S127 addendum that **lifts the S116 deferral** (see `## Design`) and records the
  disposition contract.
- `scripts/verify-session-127.sh` + `scripts/demo-session-127.sh`, both exit 0, with the
  check-class tally.
- `sessions/session-127-summary.md` + exactly 3 ranked next candidates.

## The contract, concretely

The advisor numbers its recommendations in its brief:

```
rec 1 — cite DECISION-007 and record an addendum that lifts the S116 deferral
rec 2 — show the verify-121 unpin in the before/after, or the demo shows only the after
```

The session answers every one, in a `## Advice` section inside its own prompt — the same place the
`## Execution` trace lives, for the same reason (`.ai/` and `prompts/` ARE the memory; no new
store, no new artifact type):

```
## Advice (every recommendation, answered)
- design-advisor rec 1 — obeyed: `a1b2c3d`
- design-advisor rec 2 — refused: out of scope; this session ships one story and rec 2 is a second
- demo-producer  rec 1 — deferred: filed to prompts/128-task-<slug>.md
```

Each disposition is **existence-gated**, mirroring the house pattern exactly:

| disposition | what the gate requires | precedent |
|---|---|---|
| `obeyed: <sha>` | `git cat-file -e <sha>^{commit}` resolves — a made-up sha is scored unanswered | S68 Coder |
| `refused: <reason>` | a real reason, not empty and not a `<placeholder>` | S61 Delta substantiveness |
| `deferred: <path>` | the named destination file EXISTS | S67 Architect spine-existence |

## Acceptance (testable, EARS-style)

1. **WHEN** a governed handoff for session NN records numbered recommendations **AND** the prompt's
   `## Advice` section has no line for one of them **THEN** `vajra next --check-advice NN` BLOCKS
   (exit 1) naming the role, the recommendation number, and the handoff path — proven by running
   the real binary, not by reading source.
2. **WHEN** every recorded recommendation carries a disposition **THEN** the same command passes and
   prints one line per recommendation showing which disposition it took.
3. **WHEN** a recommendation is answered `obeyed: <sha>` and that sha does not resolve to a commit
   **THEN** it is scored unanswered and BLOCKS — the S68 existence rule, applied to advice.
4. **WHEN** a recommendation is answered `refused:` with an empty or still-placeholder reason
   **THEN** it BLOCKS. A refusal is allowed; an unexplained refusal is not.
5. **WHEN** a recommendation is answered `deferred:` naming a file that does not exist **THEN** it
   BLOCKS.
6. **WHEN** a handoff exists but records no numbered recommendations **THEN** the gate WARNs at most
   and **names the dodge in plain words** — deleting the numbers dodges the gate (the known
   self-granted-jurisdiction class, S68/S71). The summary must repeat that limit, not bury it.
7. Every advisory role's system prompt instructs it to number its recommendations in the exact
   marker shape the gate parses, and states that the role **proposes; it never writes the `##
   Advice` section**. Asserted per role, so a tenth role cannot silently skip the contract.
8. **Traced, not asserted:** `K of 8` is unchanged in derivation and shape, the command count stays
   7, and no other gate's evidence contract moves.
9. A falsifiability fixture turns the suite RED **for the right reason** (S122): deleting the
   disposition-checking code — not renaming a message string — must make it fail.
10. `verify-session-127.sh` and `demo-session-127.sh` both exit 0 with a printed check-class tally,
    every check execute-based or honestly labelled.
11. Independent cold `fidelity-reviewer` verdict **ACCEPT**, attested.
12. **The summary states the floor plainly, never softened:** this proves every recommendation was
    ANSWERED. It does not prove the answer was good — that an `obeyed:` commit really implements the
    advice, or that a `refused:` reason is sound, stays a judgement only an independent reader can
    make. **Required ≠ obeyed; answered ≠ obeyed well.**

## Plan (ordered — cite the acceptance criteria each step covers)

1. **Fix the marker shape first, on paper.** Decide the exact `rec N —` form and the three
   disposition words, and write down the rejected alternatives. Everything downstream parses this.
   `covers: 7`
2. **Teach the advisory roles to number their recommendations** — one added rule per role prompt in
   `src/fleet/mod.rs`, plus the per-role assertion so a future role cannot skip it. `covers: 7`
3. **Parse the recommendations out of a governed handoff** (pure, unit-testable, no fs edge).
   `covers: 1`
4. **Parse the `## Advice` dispositions out of the session's prompt**, classifying each as answered
   / unanswered / claimed-but-not-real. `covers: 1, 2`
5. **Existence-gate each disposition:** sha resolves, reason is substantive, deferral target exists.
   `covers: 3, 4, 5`
6. **Wire `--advice NN` and `--check-advice NN`** into the existing close path; handle the
   no-numbered-recs case as a WARN that names the dodge. `covers: 2, 6`
7. **Prove nothing else moved:** `K of 8` derivation and shape unchanged, still 7 commands.
   `covers: 8`
8. **Write the falsifiability fixture** — delete the consumption, watch it go red. `covers: 9`
9. **`scripts/verify-session-127.sh` + `scripts/demo-session-127.sh`**, both exit 0 with the tally.
   `covers: 10`
10. **`DECISION-007` S127 addendum:** the disposition contract, the lifted S116 deferral, the
    rejected alternatives, and the residual. `covers: 6, 12`
11. **Independent cold `fidelity-reviewer` pass** fed only the prompt + the diff. `covers: 11`
12. **State the floor in the summary** — answered is not obeyed-well. `covers: 12`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: d41fefb
- step 2 — done: eaa4ff8
- step 3 — done: 8cd3bea
- step 4 — done: 01d86a0
- step 5 — done: 2043432
- step 6 — done: 61c867a
- step 7 — done: 6bff7ec
- step 8 — done: 1e2d5c6
- step 9 — done: 51e5d14
- step 10 — done: 7af6d7b
- step 11 — done: `<sha>`
- step 12 — done: `<sha>`

> **Fill these with real landing shas before closeout.** S119, S122 and S124 each left `<sha>`
> placeholders and only an independent cold review caught it — never self-noticed.

## Advice (every recommendation from this session's advisors, answered)

> Two advisors were dispatched and returned **43 numbered recommendations** between them. Every one
> is answered below. **A session that ships this gate and leaves its own advice unanswered has
> refuted itself** — so this section is the delivery, not paperwork about it.

**implementation-advisor** (19 recommendations, `.ai/handoffs/session-127-implementation-advisor.md`)

- implementation-advisor rec 1 — obeyed: 8cd3bea
- implementation-advisor rec 2 — obeyed: 633994e
- implementation-advisor rec 3 — obeyed: 9c76ba9
- implementation-advisor rec 4 — obeyed: 633994e
- implementation-advisor rec 5 — obeyed: 633994e
- implementation-advisor rec 6 — refused: the rule is rendered from ONE const into every ROLES entry instead of nine hand-edited system prompts, so a tenth role inherits the contract with no edit; the advisor itself named that structural impossibility the runner-up's real merit, and it is the S114 lesson (one hardcoded word stamped every future role). Recorded as a rejected alternative in the DECISION-007 S127 addendum.
- implementation-advisor rec 7 — obeyed: eaa4ff8
- implementation-advisor rec 8 — obeyed: 633994e
- implementation-advisor rec 9 — obeyed: 8cd3bea
- implementation-advisor rec 10 — refused: joining on the `<role> rec N` label already makes an unknown role key an ORPHAN and warns about it by name; gating on `fleet::resolve_role` would discard a typo'd line before it could be surfaced, which is strictly worse for the failure the rec is aimed at.
- implementation-advisor rec 11 — obeyed: 633994e
- implementation-advisor rec 12 — obeyed: 2043432
- implementation-advisor rec 13 — obeyed: 633994e
- implementation-advisor rec 14 — obeyed: 633994e
- implementation-advisor rec 15 — obeyed: 2043432
- implementation-advisor rec 16 — obeyed: 61c867a
- implementation-advisor rec 17 — obeyed: 1e2d5c6
- implementation-advisor rec 18 — obeyed: e8cdd49
- implementation-advisor rec 19 — obeyed: ec4a8c2

**demo-producer** (24 recommendations, `.ai/handoffs/session-127-demo-producer.md`)

- demo-producer rec 1 — obeyed: 15581a0
- demo-producer rec 2 — obeyed: 15581a0
- demo-producer rec 3 — obeyed: 15581a0
- demo-producer rec 4 — obeyed: 15581a0
- demo-producer rec 5 — obeyed: 15581a0
- demo-producer rec 6 — obeyed: 15581a0
- demo-producer rec 7 — obeyed: 15581a0
- demo-producer rec 8 — obeyed: 15581a0
- demo-producer rec 9 — obeyed: 15581a0
- demo-producer rec 10 — obeyed: 15581a0
- demo-producer rec 11 — obeyed: 15581a0
- demo-producer rec 12 — obeyed: 15581a0
- demo-producer rec 13 — obeyed: 15581a0
- demo-producer rec 14 — obeyed: 15581a0
- demo-producer rec 15 — obeyed: 15581a0
- demo-producer rec 16 — obeyed: 15581a0
- demo-producer rec 17 — obeyed: 15581a0
- demo-producer rec 18 — obeyed: 7af6d7b
- demo-producer rec 19 — obeyed: 15581a0
- demo-producer rec 20 — obeyed: 15581a0
- demo-producer rec 21 — obeyed: 15581a0
- demo-producer rec 22 — obeyed: 15581a0
- demo-producer rec 23 — obeyed: 15581a0
- demo-producer rec 24 — obeyed: 15581a0

> **Read this before reading the ledger as a score.** The gate proves each of these 43 was
> ANSWERED and that its evidence is real. It does not prove the answer was good. Two partial
> obediences are disclosed here rather than hidden behind an `obeyed:`: **impl rec 2's** blockquote
> sub-clause (count `>` lines in a handoff, skip them in a prompt) was NOT adopted — both sides
> treat `>` lines as prose, keeping one grammar instead of two; **demo rec 12's** live `--advance`
> drive was first taken via the escape the rec itself offers, and the demo then described the
> fallback as "asserted by test" — which was **false**, as the cold review's pass-1 REJECT found.
> It is now genuinely driven, by `verify-session-127.sh`'s
> `advance-really-binds-on-unanswered-advice` check, so demo rec 12 is obeyed in full.

## Design

- design-significant: **yes**, on two triggers.
  - **A new class of gate input.** Every station gate today reads a marker inside the session's own
    prompt. This one also reads a **governed handoff** (`.ai/handoffs/session-NN-<role>.md`, its own
    frontmatter contract) and binds the two together. That is a new binding contract between the
    fleet's write side and a gate.
  - **A deviation from a locked record, found by the `design-advisor` and carried here verbatim
    rather than discovered late:** `DECISION-007`'s S116 addendum names "consuming a handoff into a
    station's own gate" and marks it **"explicitly deferred as a non-goal."** This session reverses
    that. The Architect gate checks that a citation EXISTS, not that the design obeys it — so citing
    `DECISION-007` will pass while the deviation stands. **It must therefore ship a `DECISION-007`
    S127 addendum that explicitly lifts the S116 deferral.** Do not let the `## Design` read as
    "DECISION-007 already allows this."
- **Spine record cited:** `docs/decisions/DECISION-007-agent-fleet.md` (exists; the deferral is in
  its S116 addendum). No new decision record — the addendum chain is how this arc is recorded.
- **The real fork, to be argued in the addendum, not assumed:** what happens when a handoff exists
  but carries **no** numbered recommendations. WARN keeps legacy and pre-S127 handoffs working but
  leaves an obvious dodge (delete the numbers); BLOCK closes the dodge and breaks every handoff
  written before this contract existed. **Recommended: WARN, with the dodge named in the gate's own
  output and in the summary** — the S68/S71 precedent — and revisit once the roles have emitted
  numbered recommendations for a few sessions.
- **Consumption must inline content, never a path** (S112): a gate that prints only a filename has
  not consumed anything.
- **`Malformed` must never be swallowed as `Absent`** — a handoff that exists but fails its
  contract fails closed, and says why.

## Non-goals (not built this session)

- **Not a judge of whether the advice was followed WELL.** The gate checks that each item was
  answered and that the answer's evidence is real. Grading the answer stays the independent
  reviewer's job.
- Not all eight stations, not all nine roles wired into gates — one contract, applied where
  handoffs already land.
- No new role, **no 8th top-level command**, no new artifact type or store.
- **No S125 reboot-backlog items** — parked until the founder unparks them.
- No release, no crates.io action (founder directive).

## Delta (vs ROADMAP — OpenSpec markers)

- **ADDED:** a recorded disposition contract (`obeyed:` / `refused:` / `deferred:`), a gate that
  BLOCKS on an unanswered recommendation, `--advice` / `--check-advice`, a `DECISION-007` S127
  addendum lifting the S116 deferral.
- **MODIFIED:** the fleet's status line — from "nine roles nothing depends on" to "advice you asked
  for cannot be dropped in silence"; every advisory role prompt gains the numbering rule.
- **UNCHANGED:** the 8 stations, the 9 roles, the 7 commands, `K of 8`'s derivation, every other
  gate's evidence contract — and, stated deliberately, the fact that the gate still cannot tell
  whether an answer was a good one.

## Filed findings carried in from S126 (fix as a side-order, or as a later candidate)

1. **The two pass-4 nits on the ignore-rule fixture:** its temp repo is not hermetic (it inherits
   the operator's global `core.excludesFile`; `-c core.excludesFile=/dev/null` closes it), and its
   carve-out block is a retyped copy of the real `.gitignore`'s eleven lines, so real-file drift
   would keep testing the old shape. The comment calling it the "real rule block" should read "real
   rule line".
2. **The unused binding.** Each role's recorded `brief_sha256` in
   `sessions/session-126-dispatch-evidence.md` already equals that role's handoff `source-sha`, and
   nothing compares them — the one in-repo tie between the evidence record and something Vajra
   itself wrote. Natural to fold in here, since this session parses handoffs anyway.
3. **The dispatch evidence is a record, not a proof** (S126 pass-1 fakest green): nothing binds the
   committed record to the runtime originals under `~/.claude/projects/`.
4. **`K of 8` invariance is checked at a degenerate `0 of 8` baseline** (S126 pass 1).
5. **`verify-session-121.sh`'s check name still says "four"** after being unpinned;
   `verify-session-114.sh` / `-116.sh` remain stale-red on their own roster pins.
6. **PR #142 shows CLOSED, not merged**, though its commits are on `main` via `892e5a5` — GitHub's
   record never flipped after the merge API errored. Nothing is lost; the PR list is misleading on
   its own. Worth one line in the repo record.

## Guardrails

- **`VAJRA_ALLOW_COMMIT=127`** on every commit. Max 3 files per atomic commit. Never `--no-verify`.
- **A gate that cannot evaluate FAILS** (S69) — an unreadable handoff blocks, never passes.
- **A path is not consumption** (S112).
- **A fixture must fail for the RIGHT reason** (S122).
- **Never claim this makes the agent obey.** It makes silence impossible. If the session finds
  itself writing that Vajra now enforces obedience, stop — criterion 12 forbids exactly that.
- **This session must answer its own advisors' recommendations in `## Advice`.** Shipping the gate
  while dropping advice in silence would refute the session in its own diff.
- **Attest LAST (S69):** recompute `Review-Inputs-SHA` strictly after the Execution shas land; two
  consecutive closeout runs with `--inputs-sha 127` must agree before embedding.
