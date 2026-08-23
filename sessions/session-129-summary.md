# Session 129 — CODE: one source for what a stranger gets

**Branch:** `session-129-one-source-scaffold` · **Prompt:** `prompts/129-task-one-source-scaffold.md`
· **Founder pick:** A, taken at the S128 closeout.

---

## Goal achieved?

**Yes, for the two lists it was scoped to — and that scope is also this session's fakest green.**

The constitution `vajra init` hands a stranger was a hand-typed fork of the one this repo runs on
for 128 sessions. Nothing compared them, so nothing noticed. Measured before anything was touched
(`sessions/session-129-fork-measurement.md`, step 1, in a real empty directory on the real binary):

| | before | after |
|---|---|---|
| binding rules a stranger receives | **8 of 13**, two of them under a different NAME | **13 of 13**, names byte-exact |
| ground-truth audits required of them | **7 of 11** | **10 of 12** |
| ground-truth drift axes | **6 of 7** — *nobody knew; found mid-session by the cold reviewer* | **7 of 7** |
| reason on record for anything missing | **none** | one per withheld audit, **in their own file** |
| what keeps the two in step | somebody remembers | **derived at build time** |
| what happens when they diverge | nothing, for 128 sessions | `scaffold-drift.sh` goes **RED** |

The two renames — `Max 2 retries` for `Max 2 error retries`, `Max 3 files per commit` for
`Max 3 files per atomic commit` — are why an equality check had never been possible. They are gone
because the names are no longer typed on either side.

## The decision, which was the load-bearing deliverable

Recorded in the prompt's `## Design` **before any code** (`c1702c9`): **parameterised derivation**,
with both alternatives rejected out loud.

- **Rejected — full copy.** `verify-closeout.sh` is `include_str!`'d byte-identical into the
  scaffold, and that works *because it is project-agnostic*. A constitution is not. A copy would
  tell a stranger their repo is "Vajra — one CLI that guides any AI coding agent", that its owner
  is Suman, that ADR-0001…0005 bind them, and that a nine-role fleet and a `prompts/NN-task` load
  entry govern them. Accurate about this repo, false about theirs.
- **Rejected — declared subset** (keep the hand-typed template, add a check on top). Cheaper, and
  the check half survives. What it cannot fix is the DEFAULT: a new rule would stay silently absent
  from every scaffold until someone ran the check and hand-typed it again. Same hand-typing, with a
  tripwire.

## What shipped

- **`build.rs`** reads `.ai/AGENTS.md#Hard Rules` and `.ai/CONSTRAINTS.yaml#ground_truth` at compile
  time and emits fragments that `src/cli/init.rs` `include_str!`s into `TPL_AGENTS` and
  `TPL_CONSTRAINTS`. Three properties, in order of importance:
  1. **The default is CARRIED.** A rule added to this repo's constitution reaches every future
     scaffold with no action taken. The failure mode that produced the fork is structurally gone,
     not merely detected.
  2. **Deviation must be declared, and the declaration ships to the stranger.** `OMIT_RULES` /
     `OMIT_AUDITS` / `RETEXT_RULES` each carry a reason; the reasons are emitted as
     `scaffold-omits-audit: <name> — <why>` into the stranger's own `CONSTRAINTS.yaml`.
  3. **A stale declaration PANICS the build.** Declaring an omission for something no longer live
     stops `cargo build` by name. S128's fakest green was a hand-typed list that measured the
     boundary its own author drew; a declaration that cannot go stale is the fix for that class.
- **The audit reconciliation.** `dogfood_check`, `pipeline_advance_check` and `dogfood_staleness`
  are carried, because each one's evidence is a command the stranger's own binary already has
  (`vajra claude`, `vajra next --stations`, `vajra next --dogfood-age`). `stranger_check` is
  **declared OUT** with S128's own reason — its evidence script is Vajra's first-contact harness,
  which the scaffold does not ship, and a stranger's analogue is first contact with *their* product.
  S128 refused this in prose inside a prompt, where nothing reads it; it is now enforced data.
- **`scaffold_drift_check`** is registered as this repo's **12th** required ground-truth audit, with
  a question list that names its evidence script and asks the widening question. It is itself
  declared out of the scaffold — a scaffolded project has no scaffold of its own to compare.
- **`scripts/scaffold-drift.sh`** — the guard missing for 128 sessions. Real `mktemp -d`, real
  `git init`, the real release binary; it reads only the files a real `vajra init` writes, never the
  template constants or the generated fragments. Both directions, three questions (carried-or-
  declared · nothing invented · no stale declaration), plus provenance markers and a check that
  `cargo package --list` still carries the two derivation sources — without which
  `cargo install vajractl` would fail to build for every stranger. **It NAMES what it compared**;
  extracting zero elements BLOCKS rather than passing.
- **`Cargo.toml`** un-excludes `.ai/AGENTS.md` and `.ai/CONSTRAINTS.yaml` from the published crate,
  because they are compile inputs now.
- **`stranger-check.sh` criterion 6** — the governance a stranger is handed, asserted from inside
  the scaffold alone. **Rewritten after the cold review (rec 4) with no magic numbers in it:** the
  file is checked against its OWN derivation notes (the claimed rule count must equal the actual
  rows; carried + withheld must equal the total) and against its OWN contents (no audit may name an
  evidence script the scaffold does not ship — derived, so it holds for future audits with no
  exclusion list to maintain). **16/16 → 21/21.**

## Evidence

| what | result |
|---|---|
| `scripts/verify-session-129.sh` | **12/12 ALL GREEN** — exec 4 · struct 3 · behav 1 · nested 4 |
| `scripts/demo-session-129.sh` | **15/15 GREEN** — exec 14 · struct 1 |
| `scripts/scaffold-drift.sh` | **17/17 GREEN** — three inventories, both directions |
| `scripts/stranger-check.sh` | **21/21 GREEN** (was 16/16) |
| `scripts/fixture-session-129.sh` | **18/18 GREEN** — 7 plants + 1 control |
| `cargo test --release` | **365 passed, 0 failed** |
| `vajra next --stations 128` | **8 of 8**, same derivation, same eight names |
| `vajra next --check-plan 129` | **READY** — after fixing the gate that refused it (below) |
| top-level commands | **7** — `scaffold` and `drift` both rejected as unrecognised |

**Falsifiability, in detail.** Seven plants, each required to land *through the check that owns it*:
P1 a binding rule added live and never shipped → RED through the RULES check, naming the rule ·
P2 an audit added live and never shipped → RED through the AUDITS check, naming the audit ·
P3 a declaration gone stale → the **BUILD** fails, naming it · P4 a derivation source dropped from
the crate → RED through the PACKAGE check · P5 the `stranger_check` omission declaration deleted →
`stranger-check` RED through the runnable-evidence check, naming the missing script, because the
default is carried · **P6 a rule genuinely withheld → GREEN, with the round trip proven** (the rule
leaves the scaffold, its reason arrives in the stranger's file, and the declaration count moves off
zero) · P7 a rewrite claimed for wording that did not change → RED as a stale claim. **The control
is the point:** rewording a rule's DETAIL while leaving its NAME alone stays **GREEN** — the contract
is the rule's identity, not the file's bytes.

---

## What the cold review changed — every recommendation obeyed

Pass 1 returned **ACCEPT** and eight recommendations. **All eight were obeyed; none refused.** The
work is named here as post-ACCEPT rather than blended into the sections above, and a **fresh pass 2**
was run on the result.

| rec | what it caught | what landed |
|---|---|---|
| 2 | **`drift_axes` — a THIRD hand-typed fork**, 6 against 7, three lines above the derived include, in the block this session rewrote | derived, with its own `OMIT_AXES` declaration list and the same build-time stale panic (`0fa9dd5`) |
| 3 | `RETEXT_RULES` was an **undeclared deviation channel** — two rules shipped with rewritten wording while the file read "Declared omissions: none" | a reason field, a `scaffold-retexts-rule:` marker in the stranger's file, and a drift check that compares DETAIL text: an undeclared rewrite FAILS, a rewrite claimed for unchanged wording FAILS (`0fa9dd5`) |
| 4 | criterion 6 **hardcoded `>= 13` and `>= 10`** and a typed exclusion list — a hand-typed twin of a live count, in the session that exists to kill those | every assertion is now RELATIVE: the file against its own derivation notes, and **no audit may name an evidence script the scaffold does not ship** — derived, so it holds for future audits with no list to maintain (`b771887`) |
| 5 | `OMIT_RULES` was empty, so the drift check's **rule-omission branch was a pass over an empty list** | P6 plants a real omission and proves the round trip; the declaration count moves off zero (`b771887`) |
| 6 | `scripts/stranger-check.sh` changed this session and sat **outside the declaration boundary** | `scripts` joins the derived inventory roots; **ten** shipped files declared with reasons (`41d4fa9`, then `src/planner/mod.rs` at `295ae96`) |
| 7 | the declaration check is **branch-only by construction** and goes RED after merge | said in the script (`41d4fa9`) |
| 8 | publishing now **ships this repo's `.ai/AGENTS.md` and `.ai/CONSTRAINTS.yaml` inside the crate** | recorded in `KNOWLEDGE.md`, with the consequence that a stray brace or an emptied list breaks a stranger's build (`41d4fa9`) |
| 1 | `## Execution` was unfilled | eleven landing shas, plus a table naming which commit carries each step's post-review extension (`56672a4`) |

## And one thing nobody recommended, because running the gate found it

**`vajra next --check-plan 129` REFUSED this session's own APPROVED prompt**, demanding a
`covers: 11` for an acceptance criterion that does not exist. The cause is exact: the house heading
is `## Plan (ordered — cite the acceptance criteria each step covers)`, it contains the word
*acceptance*, and the acceptance parser matched on `contains` — so the plan's own eleven steps were
read as eleven acceptance criteria.

**This has been true of every prompt since that heading was adopted.** It did not surface earlier
because S128's plan had no more steps than it had criteria, so the phantom numbers happened to be
covered anyway. S129's eleven-against-ten is the first time the arithmetic exposed it. The Planner
station in `K of 8` reads this same gate, so **a station has been reporting PASSED off a parser that
mis-read the prompt** — the "registered, not run" class, one level in.

Fixed at the source (`is_plan_heading` wins over `is_acceptance_heading`) rather than by rewording
the prompt, with a falsifiable test: revert the guard and it fails, naming `[1, 2, 1, 2]`.
`src/planner/mod.rs` is declared in the verify suite as an UNPLANNED change with that reason, and a
new execute-based check asserts the gate is READY on this session's own prompt and that a `[11]`
line never comes back.

---

## Fidelity map — every numbered requirement

### Deliverables

| # | requirement | verdict | evidence |
|---|---|---|---|
| D1 | recorded decision in `## Design`, rejected options named | **SHIPPED** | `c1702c9`, prompt `## Design` → "THE DECISION" |
| D2 | constitution derived, every deliberate omission declared | **SHIPPED** | `34d7dcd` · `build.rs` · **zero** rule omissions declared, because none were needed — all 13 are portable |
| D3 | `required_audits` reconciled, `stranger_check` included or a recorded decision that it is not | **SHIPPED** | `34d7dcd` `OMIT_AUDITS` + the reason shipped into the stranger's file |
| D4 | execute-based drift check that FAILS on divergence | **SHIPPED** | `0d0dc8a` (+`0fa9dd5`, `c692db5`) · **17/17** · fixture P1/P2/P4/P7 |
| D5 | verify + demo, both exit 0, with the check-class tally | **SHIPPED** | `64a00c7` (+`41d4fa9`, `295ae96`) · **12/12** and **15/15** |
| D6 | summary + exactly 3 ranked next candidates | **SHIPPED** | this file |

### Acceptance

| # | criterion | verdict | evidence |
|---|---|---|---|
| 1 | every binding rule reaches a stranger, or the omission is declared — real empty dir, real binary | **SHIPPED** | drift check 1 · demo cases 1–3 · stranger-check criterion 6 |
| 2 | audit lists agree, or every difference declared with a reason | **SHIPPED** | drift checks 1–3 · demo cases 4–6 |
| 3 | plant a divergence → the drift check FAILS | **SHIPPED** | fixture P1 + P2, each red through its owning check, each naming the planted element |
| 4 | on the shipped tree it PASSES and NAMES what it compared | **SHIPPED** | **17/17** · prints all three inventories by name, and its GREEN line now states its own JURISDICTION · demo case 9 |
| 5 | `stranger-check.sh` still exits 0, and now reads the scaffolded audit list | **SHIPPED** | **21/21**, criterion 6a–6e, falsified by fixture P5 |
| 6 | `K of 8` unmoved · 7 commands · every source change DECLARED with a reason | **SHIPPED** | verify checks 1, 2, 4 — the declaration check **widened to build inputs**, since the derivation moved outside `src/` |
| 7 | fixture red for the RIGHT reason; every probe asserts its own pattern matched | **SHIPPED** | **18/18** — 7 plants + 1 control; every plant asserts its edit landed before its result is trusted |
| 8 | verify + demo exit 0 with a printed tally | **SHIPPED** | **12/12**, **15/15** |
| 9 | independent cold `fidelity-reviewer` ACCEPT, attested | **see `sessions/session-129-review.md`** |
| 10 | the summary states plainly what a stranger still gets wrong | **SHIPPED** | the section below |

---

## Pass 2 — a fresh cold review of the result

Because the post-ACCEPT work was substantive, a **second independent cold pass** was run on the
resulting tree rather than shipping pass 1's verdict over changed code. It returned **ACCEPT**
(14 SHIPPED · 2 PARTIAL · 0 NOT-BUILT), verified all eight pass-1 dispositions as real work rather
than typed words, and raised nine more. **Eight obeyed; one refused.**

Obeyed: correct the Execution table's three factual errors (rec 10) · re-sync every stale tally in
the record (rec 11) · say which half of the rewrite guard is actually falsified (rec 12) · label the
structural no-ops in the printed tallies and make criterion 6e fail if the feature it guards is
deleted (rec 13) · name 6c's shape-bound read (rec 14) · panic at build time on a name containing
the em dash the marker parsers split on (rec 15) · attest last (rec 16) · record the rewrite
channel's standing limit (rec 17).

**REFUSED — rec 9, the fourth fork.** Pass 2 found what pass 1's find looks like one level out:
`TPL_CONSTRAINTS` in `src/cli/init.rs` still hand-types a family of twins of live
`.ai/CONSTRAINTS.yaml` keys, **and two have already drifted** — `communication.forbid` ships
4 entries against the live 5, and `commit.forbid_skip_hooks` is missing entirely **while the product
reads it** (`src/varta/render.rs:84`). Also absent: `commit.forbid_force_push_to`,
`self_review_questions` (read at `src/varta/render.rs:194`) and the whole `end_of_session` block
(cited by `src/analyst/mod.rs` and `src/cli/next.rs`).

*Refused because it is a second design decision the size of this session's, not an extension of it:*
those keys are block-shaped, sit under three different YAML parents, and need a KEY-SET inventory
rather than three more list comparisons. And hand-patching the two drifted lines would put fresh
hand-typed content into the session whose whole point was removing it. **A refusal has to be said
twice** (S128): it is the disposition in the prompt's `## Advice`, it is named in
`scaffold-drift.sh`'s own GREEN output where anyone running the check will read it, it is the
fakest green below, and it is the sharpened candidate A for S131.

## The fakest green

**Pass 2's call, and I agree with it over my own:** *the drift check's jurisdiction is defined by the
thing it audits, and its verdict sentence did not say so.*

`scaffold-drift.sh` used to end with "every difference declared with a reason", which reads as a
statement about the two files. It was a statement about **the three lists `build.rs` happens to
derive**. Outside them sit a mandatory 9-entry load order shipped as 8; a "10 Steps — All Mandatory"
session loop shipped as 9 with the NEXT step missing; `communication.forbid` shipped 4-of-5; and
`commit.forbid_skip_hooks`, `self_review_questions` and `end_of_session` shipped not at all, two of
which the binary itself reads. **The check can never go red on any of them, because the derivation
decides what the check compares.** Same shape as pass 1's `drift_axes` find — a hand-typed twin
inside the blast radius of the fix — except this time it is a whole family, in the very file
`build.rs` opens, with two members already wrong.

The one fix made in-session is honesty: the GREEN line now states its own scope and names that
family in its own output, so nobody reads the verdict as wider than it is. The family itself is
**refused, not fixed** — see above.

My earlier self-nomination (criterion 6c passing over an empty set) was real but second-order, and
pass 2 was right that naming it distracted from this. 6c is now labelled a **structural no-op** in
its own PASS line, and fixture P5 is the only thing that makes it fire.

Three standing limits, none of them hidden:

- **Carrying a rule is not enforcing it.** A stranger now READS all 13; what enforces them in their
  repo is the same hook set as before, untouched this session.
- **A declared rewrite's wording is unconstrained forever after** (pass 2, rec 17). The guard proves
  a declaration and a reason exist; it never proves the rewrite preserves the rule. Today's two
  rewrites are faithful — that is a fact about this author, not about the mechanism.
- **`scaffold_drift_check` is REGISTERED, not RUN** — identical to S128's `stranger_check` residual.
  The Planner mis-parse above is exactly what that residual costs: a gate nobody executes had been
  wrong since the heading changed, and a `K of 8` station reported PASSED off it.

## What a stranger STILL gets wrong after this session

1. **The rest of their governance is still a fork, and two pieces of it are WRONG, not just
   missing.** Only three lists are derived — binding rules, `required_audits`, `drift_axes`. Still
   hand-typed against live twins: `communication.forbid` (**they get 4 of our 5**),
   `commit.forbid_skip_hooks` (**absent, and the product reads it** at `src/varta/render.rs:84`),
   `commit.forbid_force_push_to` (absent), `self_review_questions` (absent, read at
   `src/varta/render.rs:194`), the whole `end_of_session` block (absent),
   `demo.required_elements`, `verify.artifacts_dir`. Their constitution is 76 lines against this
   repo's 183: load order 8 entries against 9, session loop 9 steps against 10 — and the live file
   labels both of those sections *Mandatory*. **Named by pass 2, refused in-session with a reason,
   and the top candidate for S131.**
2. **`vajra init` still blocks on stdin without EOF.** Every script in this repo works around it
   with `</dev/null`. A stranger scripting their setup hits a hang with no message.
3. **Their first `vajra check` still exits 1** — `branch: not main` on a fresh `git init`, which is
   true and actionable but is still a non-zero exit on minute one.
4. **Nobody has asked for any of this.** 0 stars · 0 forks · 0 issues · 19 downloads, unchanged.
   A stranger being governed by the same 13 rules we are is a precondition for adoption, never
   evidence of it.
5. **The published crate predates all of it.** `vajractl 0.1.0` on crates.io is from S108. The
   packaging assertion here is `cargo package --list`; nothing installed from crates.io was tested,
   and no publish was made (founder-gated).

**Dogfood, unmeasured this session by decision:** `vajra next --dogfood-age` reports the last paid
run at **S124, `$3.2985`**, 2026-08-20 — 4 sessions and 3 calendar days ago, computed against
`.ai/SESSION` = 128. Nothing in S129 ran through `vajra claude` for money.

---

## Next

**S130 is not a choice — `130 % 5 == 0` makes it the mandatory NO-CODE ground truth.** It is the
first GT that must run **both** product-facing audits live: `stranger_check` (S128) and
`scaffold_drift_check` (S129). Both are registered; neither has ever been executed *by a ground
truth*, which is the standing residual in both sessions.

Three ranked candidates for **S131**, after that GT signs off:

**A — the fourth fork, refused this session and named key by key (pass 2, rec 9).** *Goal:* bring
the REST of `TPL_CONSTRAINTS` and the scaffolded constitution under one source — `communication.forbid`
(shipping 4 of 5), `commit.forbid_skip_hooks` and `commit.forbid_force_push_to` (absent; the first
is read by `src/varta/render.rs:84`), `self_review_questions`, the `end_of_session` block,
`demo.required_elements`, `verify.artifacts_dir`, plus the load order (8 vs 9) and session loop
(9 vs 10) the live file labels *Mandatory* — and, above all, **a KEY-SET inventory** so the check
stops being defined by the derivation. *Why:* two of those are already wrong in a stranger's file
today, and the class was found twice by readers in one session — `drift_axes` by pass 1, this family
by pass 2, both inside the blast radius of the fix. *Risk:* it is a real design decision (block-shaped
values, three YAML parents), and done badly it becomes scaffold-polishing while nothing a user wants
moves. *Why:* it is the residual this session
named itself, the mechanism already exists, and S128's lesson was that any list here may have a
twin. *Risk:* the remaining sections are genuinely Vajra-specific prose, so this is a second design
decision, not an extension of the first — and it could turn into scaffold-polishing while nothing
a user wants moves.

**B — F2, the dispatch receipt.** *Goal:* gate the fidelity review on evidence a **different actor**
produced it, replacing the hardcoded `"claude-code-subagent"` provenance string in
`src/cli/next.rs`. *Why:* it is the fleet's only real "and working" proof, and S127's residual
(four `obeyed:` labels factually wrong, gate green) says recorded dispositions certify a typed word
and nothing more. *Risk:* it hardens governance nobody outside this repo uses yet — the exact
critique the founder made of candidate A at the S127 closeout.

**C — a paid dogfood ride-along from a FRESH SCAFFOLD, not from this repo.** *Goal:* run a real
session with `vajra claude` inside a `vajra init` project and measure whether the governance a
stranger now receives is usable. *Why:* every paid dogfood in 129 sessions has run inside the repo
that builds Vajra; S125's rule — never test the product only in the repo that builds it — has been
applied to `init` and never to a real working session. *Risk:* it costs real money, it produces a
measurement rather than a feature, and the last dogfood cost `$3.2985`.
