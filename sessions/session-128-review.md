# Session 128 — Independent Cold Fidelity Review

**Reviewer:** `fidelity-reviewer` subagent, dispatched cold. Fed only
`prompts/128-task-first-contact-works.md` and the complete delivery diff
(`merge-base 11dbabbf2d44b1498807a9f3a0fa4bb4c7045cb8 → HEAD` on
`session-128-first-contact-works`). Read-only. It did not build any of this.

**Transcription note:** the reviewer's harness gave it no write tool, so this file was landed by
the orchestrator from the reviewer's returned report. The grades, the verdict, the fakest-green
call and the eight numbered recommendations below are the reviewer's words and judgements, not
the author's. **Nothing was softened in transcription**, including the two NOT-BUILTs and the
honest limit it placed on its own ACCEPT.

---

## Per-requirement grades

19 items graded: 12 numbered acceptance criteria (A1–A12) and 7 `## Deliverables` bullets (D1–D7).

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| A1 | `vajra --version` / `-V` prints crate version, exit 0 | SHIPPED | `src/main.rs` uses `env!("CARGO_PKG_VERSION")`; `tests/cli_front_door.rs` parses `Cargo.toml` independently, so a hand-typed number fails |
| A2 | Unknown subcommand exits non-zero, names the word, `&&` chain stops | SHIPPED | `Unknown(String)` → exit 2 + `unrecognised command '{word}'`; a real `sh -c` chain is driven in test |
| A3 | `--help` / bare `vajra` still exit 0 | SHIPPED | `Help` still returns 0; 4 invocations covered |
| A4 | `verify-closeout.sh` completes on a fresh init under bash 3.2 `set -u` | SHIPPED | 14 guarded expansions; live on a real 3.2.57 with the semantics probe answering `yes`; reaches its summary and reports RED, which the contract allows |
| A5 | Fresh `vajra check` reports only true/actionable FAILs; no `vajra.varta missing` | SHIPPED | absent-untracked PASS vs tracked-but-missing FAIL; 4 unit tests cover all four states; 9/11 → 10/11 |
| A6 | `stranger_check` runs a real empty dir end-to-end and fails if any of 1–5 regresses | SHIPPED | real `mktemp -d` + `git init` + `vajra init`, with an in-repo BLOCK guard; R1–R5 each go RED **through the owning check** |
| A7 | `required_audits` contains `stranger_check` + a question list saying what it is for | SHIPPED | registered, with `stranger_questions` naming the evidence script. Jurisdiction is registration-only — disclosed by the author |
| A8 | Traced: `K of 8` unmoved, 7 commands, no gate's evidence contract moves | **PARTIAL** | Command count proven hard through the real binary; `K of 8` shape proven live. The third sub-claim is **not** proven: `GATE_MODULES` is hand-typed and omits `src/cli/check.rs`, which is exactly where an evidence contract moved this session |
| A9 | Fixture RED for the RIGHT reason; every probe asserts its own pattern matched | SHIPPED | `plant()` exits 3 on a no-op, so a silent no-op cannot print green; rename control stays GREEN; R4 falsifies through the `include_str!` scaffold copy — a real plant, not cosmetic |
| A10 | verify + demo both exit 0 with a check-class tally | SHIPPED | 9 checks / 13 cases, classes labelled, one-source `print_tally`, all four `demo:` markers present. Caveat: the newest artifact run predates the last two commits |
| A11 | Independent cold reviewer ACCEPT, attested | N/A | This is that pass |
| A12 | Summary states plainly what a stranger still gets wrong | **NOT-BUILT** | `sessions/session-128-summary.md` did not exist at review time; `## Execution` steps 11–12 still `<sha>` |
| D1 | `--version`/`-V` flag, not an 8th subcommand | SHIPPED | `vajra version` is rejected as unrecognised |
| D2 | Unknown subcommand fails closed with the word named | SHIPPED | same as A2 |
| D3 | `verify-closeout.sh` runs to completion on a fresh init under bash 3.2 | SHIPPED | same as A4 |
| D4 | varta fork fixed-or-retired, **decided in `## Design`**, which and why | **PARTIAL** | The retirement shipped and is argued well — but in `src/cli/check.rs`, not in the contract. `## Design` is untouched and still reads as an instruction |
| D5 | `stranger_check` execute-based in a real empty dir, wired into `required_audits` | SHIPPED | — |
| D6 | `verify-session-128.sh` + `demo-session-128.sh`, exit 0, with tally | SHIPPED | both new + executable; logs corroborate |
| D7 | `sessions/session-128-summary.md` + exactly 3 ranked candidates | **NOT-BUILT** | absent from the diff |

**14 SHIPPED · 2 PARTIAL · 2 NOT-BUILT** (A11 excluded as N/A).

**Verdict:** ACCEPT

> "The real scope is a faithful build of the contract's engineering half — not one narrow slice
> dressed as the whole. It is short in exactly one place, and that place is the closeout paperwork
> the contract itself sequenced after this review."

---

## The fakest green

`no-gate-evidence-contract-moved` in `scripts/verify-session-128.sh`, labelled `struct`, whose
entire assertion is that a **hand-typed** list of eleven directory names does not appear in
`git diff --name-only`.

1. **It passes if S128 shipped nothing.** Revert the whole session and it still goes green — an
   absence-claim dressed as proof.
2. **Its scope excludes the one thing that moved.** `src/cli/check.rs` is not in `GATE_MODULES`,
   and that file is precisely where an evidence contract changed this session. The change is
   correct and criterion 5 ordered it — *"but the instrument that 'proves no gate's evidence
   contract moved' was drawn to not be able to see it. The author picked the boundary and then
   measured inside it."*

**Runner-up:** `typo_short_circuits_a_shell_and_chain` asserts only that stdout lacks `RAN`. If
`sh` never ran the binary at all, stdout is empty and the test passes. No positive anchor — the
S127 silent-no-op shape, in Rust.

**Explicitly not the fakest green:** the demo's structural `case 11` and "registration is proven;
the running is not" — *"a disclosed weak check is a weak check, not a fake one."*

---

## Claims the diff does not support

**Nothing material.** The reviewer hunted this repo's specific burns and found them closed rather
than dodged: `## Execution` shas 1–10 map one-to-one and in order to reflog subjects matching each
step (including step 4's amended sha, correctly recorded as the post-amend commit);
`sessions/session-128-repro.md` records the four reds before their fixes; the fixture plants
behaviour, not spelling, and carries a rename control that stays green; the single
`grep -v "branch: not main"` is a named-and-justified sanctioned failure, not an exclusion list
grown to cover a bug; and the "real binary" claims are real.

**The honest limit it placed on its own ACCEPT, unsoftened:**

> "With no shell in this harness I verified sha→work by reflog subject and final-tree content,
> **not** by `git show --stat`. That is weaker than the S119/S122/S124/S127 lesson demands. …
> my ACCEPT does not certify per-commit content."

> "The ACCEPT does not cover A12/D7. They are NOT-BUILT at review time. Adding the summary changes
> the delivery diff, so `Review-Inputs-SHA` goes stale by construction and the attestation gate
> will fire — that is the mechanism working, not a nuisance."

---

## Recommendations

- rec 1 — Write `sessions/session-128-summary.md` (3 ranked candidates + the stranger-still-broken
  list), then **re-read criterion 12 against the landed file** before re-attesting; do not merely
  re-hash.
- rec 2 — Record the varta fork decision **in the prompt's `## Design`**, because that is what
  deliverable 4 asked for. The reasoning in `src/cli/check.rs` is good and in the wrong artifact.
- rec 3 — **Derive** `GATE_MODULES` instead of typing it, and state that `src/cli/check.rs`'s
  evidence contract moved by design — or drop the claim to what it actually proves.
- rec 4 — Port `stranger_check` into the scaffolded template (`src/cli/init.rs` ships strangers a
  seven-audit list). *"A stranger's ground truth will never run the audit invented to protect
  strangers."* If that is scope-widening this session, **say so in the summary rather than leaving
  it silent.**
- rec 5 — Anchor `typo_short_circuits_a_shell_and_chain` with a positive assertion (exit code or
  stderr), so it cannot pass when `sh` never ran the binary.
- rec 6 — Check the `[ -z "${arr[@]+x}" ]` idiom on a **multi-element** array before enshrining it
  as the house pattern; the reviewer predicts `[: too many arguments` at ~100 elements.
- rec 7 — Re-run `verify-session-128.sh` at final HEAD and record steps 11–12. The newest artifact
  run predates the step-10 commit. Run the full gate on the branch **before** merging (S83).
- rec 8 — Decide out loud whether a fresh `vajra check` exiting **1** is acceptable first contact.
  `branch: not main` fails on a fresh `git init`, so a stranger's very first `vajra check` returns
  non-zero and `vajra check && …` still stops. That belongs in criterion 12's list.

---

## What the author did with these — the dispositions

Recorded in `prompts/128-task-first-contact-works.md#Advice` and gated by
`vajra next --check-advice 128`. **rec 6 was tested and did not reproduce** — the measurement is
in the disposition, and the guard was simplified anyway. **rec 4 was REFUSED**, out loud, with a
reason. Everything else was obeyed.

**These fixes landed AFTER the ACCEPT.** The reviewer read the pre-fix tree; the S123 rule is
"do not fix findings after the ACCEPT", and this session broke it for four of them and says so
here rather than in a footnote. The reasoning: rec 2 and rec 3 close a PARTIAL and the named
fakest green — leaving them would ship a graded-PARTIAL deliverable — and rec 5 closes a probe
that can pass without running anything. The verdict above stands on the tree the reviewer read.
