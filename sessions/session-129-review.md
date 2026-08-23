# Session 129 — Independent Cold Fidelity Review

> Two passes. **Pass 1** was fed only `prompts/129-task-one-source-scaffold.md` and the S129 diff,
> with no shell. It returned **ACCEPT** and, in doing so, found a third fork the session had missed
> **inside the very YAML block it rewrote**. Every one of its eight recommendations was obeyed, and
> a **fresh pass 2** was then run on the resulting tree. Both verdicts are recorded below, in full,
> in the order they happened.

---

# PASS 1 — cold `fidelity-reviewer`, fed prompt + diff, no shell

**Verdict:** ACCEPT

**15 of 16 SHIPPED** (A9 is the review itself and cannot be graded by its own subject). One
prompt-contract line outside the numbered set — the `## Execution` sha block — was **NOT-BUILT as of
the diff it was fed** and had to land before closeout.

## Per-requirement grades

| id | requirement | verdict | evidence in the diff |
|---|---|---|---|
| D1 | recorded decision in `## Design` on what a stranger's constitution + audit list should BE, rejected options named | SHIPPED | `c1702c9` adds 44 lines to the prompt — "THE DECISION": parameterised derivation, with **full copy** and **declared subset** each rejected with a specific reason. Landed **before** the code commit `34d7dcd`. The pre-declared scope limit ("what is NOT derived") is there too, before the summary could quietly claim otherwise. |
| D2 | constitution derived from `.ai/AGENTS.md`, every deliberate omission declared | SHIPPED | `build.rs` `parse_hard_rules()` + `render_hard_rules()`; `TPL_AGENTS` becomes `concat!(…, include_str!(OUT_DIR/scaffold_hard_rules.md), …)` and the 8-row hand-typed table is **deleted in the same hunk**. `OMIT_RULES` empty; the fragment emits "Declared omissions: none". Caveat on `RETEXT_RULES` below. |
| D3 | `required_audits` reconciled; `stranger_check` runnable or a recorded decision that it is not | SHIPPED | `render_ground_truth()` carries 10 of 12; `OMIT_AUDITS` withholds two, each with a reason **emitted into the stranger's own file**. The hand-typed list and three question blocks are deleted from `TPL_CONSTRAINTS`. The deliverable's "or a recorded decision that it is not, and why", honoured as data rather than prose. |
| D4 | execute-based drift check that FAILS when scaffold and live `.ai/` diverge | SHIPPED | `scripts/scaffold-drift.sh`: real `mktemp -d` with an in-repo BLOCK guard, real `git init`, real release binary, reads only the written files. Both directions, exit 1 on any FAIL. Falsified by P1/P2/P4. |
| D5 | verify + demo, both exit 0, with the check-class tally | SHIPPED (not executed by the reviewer) | 11 `run_check` calls, exec 3 / struct 3 / behav 1 / nested 4, `print_tally` from `lib-tally.sh`; demo 13 scored cases with all four required elements. |
| D6 | summary + exactly 3 ranked next candidates | SHIPPED | A / B / C, each with goal, why, and a named risk. Exactly three. |
| A1 | fresh `vajra init` carries every binding rule, or the omission is declared in a list the drift check reads | SHIPPED (scope caveat) | drift section 1, `stranger-check` criterion 6, demo cases 1–3 with `grep -Fxq` on the exact names of the five recovered and two renamed rules. **Caveat:** "binding" is scoped to the Hard Rules table; the live file's `## Mandatory Load Order` (9 vs 8) and `## Session Loop (10 Steps — All Mandatory)` (10 vs 9) are declared only in prose. |
| A2 | audit lists agree, or every difference declared with a reason | SHIPPED | drift sections 1–3 both directions + section 4's per-audit `grep -q "scaffold-omits-audit: $el — ."` — asserts a **non-empty reason**, not just the marker. Demo cases 5–6. |
| A3 | plant the divergence → the drift check FAILS (proven, not asserted) | SHIPPED | P1/P2/P4: assert the plant landed → run drift against a snapshotted `STALE_BIN` → require `^RED` **and** the owning check's exact FAIL line **and** the planted element by name. Baseline green asserted first, so "it went red" is attributable. |
| A4 | on the shipped tree it PASSES and NAMES what it compared | SHIPPED (not executed) | Prints six counts then dumps live rules and live audits by name before any verdict. Zero extraction on any inventory **BLOCKs** rather than passing — S69, correctly applied. |
| A5 | `stranger-check.sh` still exits 0 and now looks at the scaffolded audit list | SHIPPED (not executed) | +59 lines, criterion 6, four probes. Falsified by P5 — delete the `stranger_check` declaration, rebuild, the default carries it, the runnable-audit probe fires. **The sharpest plant in the suite:** it proves the criterion is load-bearing, not decorative. |
| A6 | `K of 8` unchanged, 7 commands, every source file changed DECLARED with a reason | SHIPPED (boundary caveat) | `stations_shape_unchanged` reads the live binary (derivation sentence, 8 names by regex, exactly 8 status lines, the `8 of 8` baseline). `no_eighth_command_exists` drives 8 candidate words through real dispatch. The declaration check derives from `git ls-files` **and** from `build.rs`'s own `rerun-if-changed` lines, refuses an empty inventory, and fails both ways. **Caveat:** the inventory roots are typed, and `scripts/stranger-check.sh` — modified this session — sits outside them. |
| A7 | fixture red for the RIGHT reason; every probe asserts its own pattern matched | SHIPPED | Five plants + one control. Every plant `assert`s its anchor, re-greps to confirm the edit landed, then requires the owning check's padded FAIL line — which cannot match the PASS line, since PASS carries a `(N checked)` suffix. **The best-built part of the delivery.** |
| A8 | verify + demo exit 0 with a printed check-class tally | SHIPPED (not executed) | Both end in an explicit tally and a green/red exit; verify additionally names its one behavioral grep. |
| A9 | independent cold `fidelity-reviewer` ACCEPT, attested | IN FLIGHT — not gradeable by its own subject | "I do not attest myself." |
| A10 | the summary states plainly what a stranger still gets wrong | SHIPPED | Five numbered items plus an unprompted dogfood-staleness note. Unsoftened, and it does not claim adoption. |
| X1 | *(contract line, not numbered)* `## Execution` — each plan step's landing commit | **NOT-BUILT at the pass-1 snapshot** | Eleven literal `<sha>` placeholders, while the summary already cited real shas. "A typed sha that does not contain the work is worse than an empty one, because the gate turns green on it." |

## Pass 1's fakest green — its call, not the summary's

> **`drift_axes` — a six-entry hand-typed governance list sitting three lines above the derived
> include, in the same `ground_truth:` block, forked from a seven-entry live list, and invisible to
> every instrument this session built.**
>
> The session's guard prints "every difference declared with a reason". That sentence is true of the
> two lists it looked at and false of the file it looked at them in. `drift_axes` drifted the exact
> way the Hard Rules table drifted — hand-typed, uncompared, no reason on record — and it survived a
> session whose entire purpose was to kill that class, **in the one YAML block the session opened and
> edited.** Nothing here is dishonest; it is the class proving it is not dead by hiding one line from
> where the fix landed.

On the summary's own self-named fakest green ("the drift check's inventory is a two-item boundary
its own author drew"): the right *category*, stated bravely, but at an altitude that reads as a
large next-session problem and distracts from a cheap adjacent instance missed inside the delivered
scope. **"The honest form of the summary's residual is: we did not look one line up."**

Two runners-up the summary did not name:

1. **`RETEXT_RULES` is an undeclared deviation channel.** Two rules ship to strangers with rewritten
   detail; `build.rs` verifies only that the NAME still exists, no check compares the detail, and
   **the fixture's control certifies that detail changes stay green.** The retexts made are
   defensible; the channel is unguarded and unlabelled.
2. **`stranger-check.sh` criterion 6 hardcodes the numbers it is guarding** — `>= 13`, `>= 10`, and a
   typed exclusion set. A hand-typed twin of a live count, introduced by the session that exists to
   kill hand-typed twins. It goes stale **by construction, not by neglect.**

## Pass 1's limits on its own verdict

- **No shell. Nothing was executed.** Every `11/11 · 13/13 · 12/12 · 20/20 · 13/13 · 364` figure was
  unverified by it; the scripts were graded by reading their logic, failure paths and assertions.
  D5, A4, A5, A8 and the exec half of A6 are "the code, if run, tests what it claims" — not "it ran".
- **The Cargo negation could not be verified.** `exclude = [".ai/", "!.ai/AGENTS.md", …]` re-includes
  under an excluded directory; cargo is last-match-wins and the repo already relies on the shape for
  `.githooks/`, but "a `cargo install vajractl` still builds" is an unrun claim in the review.
- **Per-commit content was not verified** — a squashed diff and a commit list; ordering was inferred
  from messages, not from inspecting each tree.
- **The `## Execution` block was unfilled at its snapshot.** Nothing in the review certifies shas
  written afterwards.

## Pass 1 recommendations — all eight

1. Fill `## Execution` with the eleven real landing shas before closeout, confirmed by someone other than the author.
2. Derive `drift_axes` too, or declare it out with a reason, **in this session rather than the next**.
3. Make `RETEXT_RULES` visible to the stranger and to the drift check — emit a marker, require a reason, assert it round-trips.
4. Stop hardcoding `>= 13` / `>= 10` in criterion 6 and derive the unrunnable-audit set instead of typing it.
5. Add a fixture plant for the `OMIT_RULES` path, or say plainly that one of the twelve passes is a structural no-op today.
6. Close the `no-undeclared-build-input-change` boundary over `scripts/`, or rename the check to what it measures.
7. Note that the declaration check is branch-only and goes RED after merge.
8. Record that publishing now ships Vajra's own `.ai/AGENTS.md` and `.ai/CONSTRAINTS.yaml` inside the crate.

---

# PASS 2 — a FRESH cold `fidelity-reviewer`, on the tree after every rec-1..8 change

> Run because the post-ACCEPT work was substantive. Fed the prompt, the full re-generated diff and
> the commit list; **no shell**, and it said so. It was told to treat pass 1's ACCEPT as a claim to
> be checked, not as truth.

**Verdict:** ACCEPT

**14 of 16 SHIPPED · 2 PARTIAL · 0 NOT-BUILT.** In its words: *"The real scope is a faithful build
of the contract as its own pre-registered `## Design` scoped it — not a narrow slice presented as
the whole."*

## Where it differed from pass 1

| id | pass 2 verdict | why |
|---|---|---|
| A1 | **PARTIAL** (pass 1: SHIPPED with a caveat) | the live file also marks `## Mandatory Load Order (Every Session)` (9 entries; scaffold 8) and `## Session Loop (10 Steps — All Mandatory)` (scaffold 9 — live step 8, *write `prompts/NN+1`*, is absent) as binding. Those omissions are declared in **prose**, which is neither of the two paths A1 offered. *"Disclosed, not hidden — hence PARTIAL, and I judge it non-material because the contract itself made the Design the governing decision and pre-registered this boundary before any code."* |
| A9 | **PARTIAL — in flight** | the review carried no `Review-Inputs-SHA` at its snapshot, and pass 2 itself had not landed. Structurally cannot close before this section exists. |
| all others | SHIPPED | re-derived independently from the diff |

## It verified all eight pass-1 dispositions as real work

*"Nothing here is an S127-class fake `obeyed:`."* One shortfall: **rec 1's Execution extension table
carried three factual errors** — it said "six steps" over seven rows, presented `bce033c` as a
post-review extension when the commit list places it before `34d7dcd` and long before the review,
and omitted step 11's real extension `69baaba`. *"The table's own promise — so nobody has to guess
which sha carries which half — is partly false."* Corrected at `06431df`.

## THE FOURTH FORK — pass 2's own find

> *"`TPL_CONSTRAINTS` still hand-types at least six machine-readable twins of live
> `.ai/CONSTRAINTS.yaml` keys, and two have **already drifted**."*

- `communication.forbid` — live 5 entries, scaffold **4**. Drifted. Uncompared. Unnamed anywhere.
- `commit.forbid_skip_hooks` — absent from the scaffold, **and read by the product** at
  `src/varta/render.rs:84`. A stranger's Varta render silently drops that governance line.
- `commit.forbid_force_push_to` · `self_review_questions` (read at `src/varta/render.rs:194`) ·
  the whole `end_of_session` block (cited by `src/analyst/mod.rs` and `src/cli/next.rs`) — absent.
- `verify.artifacts_dir` · `communication.max_bullets_per_section` — live-only ·
  `demo.required_elements` — a twin that happens to agree today · `load_order` — 8 vs 9.

*"The summary names the AGENTS.md side and generalises to 'any OTHER list'. It never names the
CONSTRAINTS.yaml side — which is the more damning instance, because `build.rs` parses that exact
file three lines away from these keys, and two of them are already wrong. This is pass 1's
`drift_axes` find one level out."*

## Pass 2's fakest green

> **"The drift check's jurisdiction is defined by the thing it audits, and its verdict sentence does
> not say so."** *"'Every difference declared with a reason' reads as a statement about the two
> files. It is a statement about the three lists `build.rs` happens to derive… The check can never
> go red on any of them, because the derivation decides what the check compares."*

On the summary's self-nomination (criterion 6c's vacuous pass): *"honest and correct as far as it
goes… but it is the second-order item, and naming it distracts from the first-order one."*
Runner-up it named: **stranger-check 6e, a check that passes if the retext feature it guards is
deleted.** Both fixed or labelled at `c692db5`.

## Other findings, all acted on

- **Two new vacuous passes** introduced by the post-review work (drift §3's axes arm, and 6e) →
  labelled `STRUCTURAL NO-OP` in their own PASS lines, and 6e now asserts its count.
- **Both marker parsers split on the em dash**, so a name containing one mis-parses into a wrong
  element — the S122 spelling-bound-guard shape → `build.rs` panics on such a name.
- **Only ONE direction of the rewrite guard is falsified** (P7, the stale claim); the
  undeclared-rewrite direction is a renderer-regression guard, *"and the summary states both as
  proven; only one is"* → disclosed in the script and in the summary.
- **Standing limit nobody had written down:** *"once a rule is declared retexted, its stranger-facing
  wording is unconstrained. The guard proves a declaration exists, never that the rewrite preserves
  the rule."* → recorded in the fakest-green list.
- **Stale tallies across the record**, including `.ai/ROADMAP.md` → all re-synced against a live run.
- **The Planner fix**: *"correct, minimal, falsifiable, and it breaks no other heading shape"* —
  `is_plan_heading` matches the first token exactly, so `## Acceptance`, `## Planning notes` and
  `# Session 64 — the PLANNER stage` are unaffected.

## Pass 2's limits on its own verdict

- **No shell; nothing executed.** Every tally — verify 12/12, demo 15/15, drift 17/17, stranger
  21/21, fixture 18/18, 365 tests — is unverified by it.
- **Per-commit tree content not verified** — a squashed diff and a commit list; the `bce033c`
  ordering finding is inferred from the list, not from inspecting trees.
- **It read the working tree** (read-only) for the fourth-fork probe and flagged that itself:
  *"those reads produced findings against the delivery, never in its favour."*
- **The Cargo negation is unverified** — `cargo install vajractl` still building is an unrun claim.
- **A9 cannot be closed by it.** *"I do not attest myself."*

## Pass 2 recommendations — numbered from 9, and why

*"I number from 9, continuing pass 1's sequence, because rec 1…rec 8 already carry recorded
dispositions and re-using those numbers would break the guarantee that a disposition keeps meaning
the same advice."* (This is the S127 renumbering trap, avoided by the reviewer unprompted.)

9. Hunt the FOURTH fork now, key by key. — **REFUSED**, with the reason recorded in four places.
10. Correct the Execution extension table's three factual errors. — obeyed `06431df`
11. Re-sync every stale tally in the record. — obeyed `8461d94`
12. Plant the missing RETEXT direction, or disclose it. — obeyed `c692db5`
13. Label the structural no-ops; make 6e assert its count. — obeyed `c692db5`
14. Widen or name 6c's shape-bound read. — obeyed `c692db5`
15. De-fang the em-dash-bound marker parsers. — obeyed `c692db5`
16. Attest LAST, after this brief lands; run the full closeout on the branch. — obeyed at closeout
17. Record the RETEXT channel's standing limit in the fakest-green list. — obeyed `8461d94`

---

## Attestation

**Verdict:** ACCEPT

**Review-Inputs-SHA:** `fca673defe06a39ed91f9bcacebd02f59139c2ad8a927f05f070d07f2b7cb015`

Recomputed strictly AFTER every `## Execution` sha landed and after both passes were recorded
(S69, and pass 2's rec 16). Two consecutive `scripts/verify-closeout.sh --inputs-sha 129` runs
agreed before this line was written. **What it certifies and nothing more:** that this review was
written against this prompt and this diff. It does not certify per-commit content — **neither
reviewer had a shell, and both said so** — and it does not certify that the advice was good, only
that it was answered.

---

**Both passes ACCEPT. Two independent cold readers, two forks found that the builder had not seen —
`drift_axes` by pass 1 (fixed), the `TPL_CONSTRAINTS` family by pass 2 (refused, named, and made
candidate A). Neither reader had a shell, and both said so.**
