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
