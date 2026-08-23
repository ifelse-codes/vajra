# Session 129 — CODE: one source for what a stranger gets

> **Status:** APPROVED — founder, 2026-08-22, at the S128 closeout. Asked to choose between A, B
> and C in plain English, they picked **A**.
>
> **The pick, and what it means:** A was recommended because it is the same blind spot as all four
> S128 defects, one level deeper — nobody ever looked at what `vajra init` actually hands a
> stranger. B (the small first-contact residuals) and C (a paid ride-along) stay on the shelf; C in
> particular is partly covered by S130's ground truth, which now runs `stranger_check`.
>
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**,
> not a status report. Do NOT soften them. **No release** until reality meets them.

## Type

**CODE. Max 2 assumptions · 2 retries · 1 story · ~2h · new chat.** One story: *what `vajra init`
hands a stranger is derived from what this repo runs on, and cannot silently drift from it.*
Commits need the un-forgeable marker — `VAJRA_ALLOW_COMMIT=129` on the commit.

## Why this session

S128 fixed the front door and, in doing so, measured the room behind it. **The scaffold is a
hand-maintained fork in at least two files, and nobody was watching either:**

| What a stranger receives | What this repo runs on |
|---|---|
| `AGENTS.md` — **66 lines** (`TPL_AGENTS` in `src/cli/init.rs`) | `.ai/AGENTS.md` — **183 lines** |
| `required_audits` — **7 entries** (`src/cli/init.rs`) | `.ai/CONSTRAINTS.yaml` — **11 entries** |

The second one is new, found by S128's cold reviewer: `stranger_check`, `dogfood_check`,
`pipeline_advance_check` and `dogfood_staleness` are all missing from the scaffold. In the
reviewer's words: ***"A stranger's ground truth will never run the audit invented to protect
strangers."***

**S128 REFUSED to fix it** — deliberately, with a reason recorded in its `## Advice`: registering an
audit whose evidence script the scaffold does not ship would make every stranger's ground truth
fail a check it cannot run. **Fixing it properly means deciding what a stranger's list should BE,
and that is this session.**

**The counter-example that proves it is cheap:** `scripts/verify-closeout.sh` is `include_str!`'d
into the scaffold (`src/cli/init.rs`). It is byte-identical in both places, so S128's bash-3.2 fix
reached every future scaffold for free. One file already does this right.

**The trap, named before it is walked into:** the two files are **not supposed to be identical**.
This repo's constitution names ADRs, session numbers, hooks and a fleet a stranger's project has
none of. *"Derive from one source"* may mean writing a real derivation, not an `include_str!`.
**Decide that in `## Design` before writing code.**

## Goal

Make the scaffold a DERIVED artifact of this repo's governance rather than a hand-typed copy of it,
for both the constitution and the required-audit list — and add a check that goes RED when the two
drift, so this class cannot come back the way it came.

## Deliverables

- A recorded decision, in `## Design`, on **what a stranger's constitution and audit list should
  BE** — full copy, parameterised derivation, or a declared subset — with the rejected options
  named. This is the load-bearing deliverable; the code follows it.
- `vajra init`'s constitution derived from `.ai/AGENTS.md` by whatever mechanism `## Design`
  chooses, with every deliberate omission **declared**, not accidental.
- `vajra init`'s `required_audits` reconciled with this repo's, including whatever
  `stranger_check` needs in order to be runnable in a scaffolded project (or a recorded decision
  that it is not, and why).
- **A drift check that FAILS when the scaffold and the live `.ai/` diverge** — the thing that was
  missing for 125 sessions. Execute-based.
- `scripts/verify-session-129.sh` + `scripts/demo-session-129.sh`, both exit 0, with the
  check-class tally.
- `sessions/session-129-summary.md` + exactly 3 ranked next candidates.

## Acceptance (testable, EARS-style)

1. **WHEN** a fresh `vajra init` repo is created **THEN** its constitution contains every rule this
   repo's `.ai/AGENTS.md` marks as binding, or the omission is DECLARED in a list the drift check
   reads — asserted in a real empty directory, on the real binary.
2. **WHEN** a fresh `vajra init` repo is created **THEN** its `required_audits` and this repo's
   agree, or every difference is declared with a reason.
3. **WHEN** a rule is added to `.ai/AGENTS.md` (or an audit to `.ai/CONSTRAINTS.yaml`) and not to
   the scaffold **THEN** the drift check FAILS — proven by planting the divergence, not asserted.
4. **WHEN** the drift check runs on the shipped tree **THEN** it PASSES, and it names what it
   compared rather than reporting a bare OK.
5. **WHEN** `scripts/stranger-check.sh` runs **THEN** it still exits 0 — S128's four fixes do not
   regress, and the scaffolded ground-truth audit list is now one of the things it looks at.
6. **Traced, not asserted:** `K of 8` unchanged in derivation and shape, the command count stays
   **7**, and every source file changed is DECLARED in the verify suite with a reason (the S128
   pattern that replaced its fakest green).
7. A falsifiability fixture turns the suite RED **for the right reason** (S122) — reverting a fix,
   not renaming a message — **and every probe asserts its own pattern matched** (S127/S128).
8. `verify-session-129.sh` and `demo-session-129.sh` both exit 0 with a printed check-class tally.
9. Independent cold `fidelity-reviewer` verdict **ACCEPT**, attested.
10. **The summary states plainly what a stranger still gets wrong after this session.**

## Plan (ordered — cite the acceptance criteria each step covers)

1. **Measure the fork before touching it** — diff the scaffolded constitution against `.ai/AGENTS.md`
   rule by rule, and the two audit lists entry by entry. Record it. `covers: 1, 2`
2. **Decide, in `## Design`, what a stranger's governance should BE**, and reject the alternatives
   out loud. `covers: 1, 2`
3. **Derive the constitution** by the chosen mechanism, with declared omissions. `covers: 1`
4. **Reconcile the audit lists**, `stranger_check` included or declared out with a reason.
   `covers: 2`
5. **The drift check** — execute-based, naming what it compared. `covers: 3, 4`
6. **Re-run `stranger-check.sh`; extend it to look at the scaffolded audit list.** `covers: 5`
7. **Prove nothing else moved**, declaring every source change with a reason. `covers: 6`
8. **The falsifiability fixture** — plant the divergence, watch it go red. `covers: 7`
9. **`scripts/verify-session-129.sh` + `scripts/demo-session-129.sh`.** `covers: 8`
10. **Independent cold `fidelity-reviewer` pass.** `covers: 9`
11. **Say in the summary what is still broken for a stranger.** `covers: 10`

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

> **Fill these with real landing shas before closeout,** and **do not record a sha that does not
> contain the work.** S119, S122, S124 and S127 each got this wrong; only a cold reader ever caught
> it.

## Advice (every recommendation from this session's advisors, answered)

> One line per recorded recommendation: `- <role> rec N — obeyed: <sha>` / `refused: <reason>` /
> `deferred: <path>`. `vajra next --check-advice 129` BLOCKS the close until every one is answered.
> **A disposition certifies a typed word and a resolving sha, and nothing else (S127).** If you did
> not do it, write `refused:` and say why — that is a pass by design and the only honest option.

- *(none yet — fill as advisors are dispatched)*

## Design

- design-significant: **yes** — this changes what every future Vajra project is governed BY.
- **Spine record to cite:** `docs/decisions/DECISION-001-governance-as-product.md` — governance a
  user never receives is not the product. **(The Architect gate checks that a cited record EXISTS,
  not that the design obeys it — a citation is not permission.)**
- **The fork to argue, not assume:** *what should a stranger's constitution and audit list BE?*
  Full copy, parameterised derivation, or a declared subset. Name the rejected options.

### THE DECISION (recorded before any code — S129 step 2)

**A stranger's governance is a PARAMETERISED DERIVATION of this repo's, with every deviation
declared at the source and a stale declaration failing the BUILD.**

Mechanism, precisely:

- `build.rs` reads the live `.ai/AGENTS.md` `## Hard Rules` table and the live
  `.ai/CONSTRAINTS.yaml#ground_truth.required_audits`, and emits generated fragments that
  `src/cli/init.rs` `include_str!`s into `TPL_AGENTS` and `TPL_CONSTRAINTS`.
- **The default for anything new is CARRIED, verbatim.** A rule added to `.ai/AGENTS.md`
  appears in the next scaffold with no action taken — the failure mode that produced this
  fork is structurally gone, not merely detected.
- Deviating needs a declaration in `build.rs`: `OMIT` (element → reason) or `RETEXT`
  (rule → stranger-facing detail). Both are compile-time data, adjacent to the template they
  modify — **no new artifact, no new store, no new command** (the S53 mapping rule).
- **A stale declaration FAILS THE BUILD.** Declaring an omission or an override for something
  that is no longer in the live source panics `build.rs`. S128's fakest green was a
  hand-typed list that measured the boundary its own author drew; a declaration that cannot
  go stale is the fix.
- `scripts/scaffold-drift.sh` is the execute-based second opinion: it compares the LIVE `.ai/`
  against the files a REAL `vajra init` writes in a REAL empty directory, using the REAL
  release binary — never against the template constants that produce them. It names every
  element it compared.

**REJECTED — full copy (`include_str!` of `.ai/AGENTS.md`).** The counter-example that makes
this session cheap, `verify-closeout.sh`, is byte-identical in both places precisely *because
it is project-agnostic*. The constitution is not. A copy would tell a stranger their repo is
"Vajra — one CLI that guides any AI coding agent", that its owner is Suman, that they are bound
by ADR-0001…0005 they never wrote, and that a nine-role fleet and a `prompts/NN-task-<slug>.md`
load-order entry govern them. Accurate to this repo, false about theirs.

**REJECTED — declared subset (keep the hand-typed template, add a check on top).** Cheaper, and
it is the half of this design that survives: the check. What it cannot do is fix the default. A
new rule would stay silently absent from every scaffold until someone ran the check and then
hand-typed it — the same hand-typing, with a tripwire. The founder's word was *derived*.

**What is NOT derived, stated here so the summary cannot quietly claim otherwise:** only the
Hard Rules table and the audit list are. The rest of the scaffold's constitution — its
"What This Repo Is", its load order, its session loop, its speaking-skill sections — remains
hand-written, because those sections are Vajra-specific prose in the live file and a stranger's
project is not Vajra. The derived inventory is *the binding sets*, and the drift check says so
in its own output rather than reporting a bare OK.
- **Scope discipline:** this is the scaffold's CONTENT and its drift guard. It is not the
  boot-context diet (F4), not the dispatch receipt (F2), and not a release.

## Non-goals (not built this session)

- No 8th top-level command.
- Not F2 (the dispatch receipt) and not F4 (the boot-context diet).
- No release, no crates.io action (founder directive; `vajractl` is already burned at 0.1.0).

## Delta (vs ROADMAP — OpenSpec markers)

- **ADDED:** a scaffold-vs-live drift check.
- **MODIFIED:** `src/cli/init.rs`'s constitution and `required_audits`, from hand-typed to derived.
- **UNCHANGED:** the 8 stations, the 9 roles, the 7 commands, `K of 8`'s derivation, every gate's
  evidence contract.

## Guardrails

- **`VAJRA_ALLOW_COMMIT=129`** on every commit. Max 3 files per atomic commit. Never `--no-verify`.
- **Never test the product only in the repo that builds it (S125/S128).** Assert in an EMPTY
  directory against the release binary.
- **A check that cannot evaluate FAILS** (S69). **A fixture must fail for the RIGHT reason** (S122),
  and **a probe must assert its own pattern matched** (S127/S128).
- **Single-quote any `echo` that quotes a command** — an unescaped backtick in a double-quoted echo
  is a command substitution, and S128's ran `vajra init` inside this repo (S128).
- **Attest LAST (S69):** recompute `Review-Inputs-SHA` strictly after the Execution shas land; two
  consecutive closeout runs with `--inputs-sha 129` must agree before embedding. **Run the full
  `verify-closeout.sh` on the branch BEFORE merging the PR (S83).**
