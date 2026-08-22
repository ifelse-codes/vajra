# Session 128 — CODE: first contact works

**Verdict lives in `sessions/session-128-review.md`** (independent cold `fidelity-reviewer`,
one pass, **ACCEPT** — 14 SHIPPED · 2 PARTIAL · 2 NOT-BUILT · 1 N/A). It is not restated here as a
bare line, deliberately: the review file is the attested record, and two verdict lines in two files
is how a summary starts drifting from its own review.

## Goal

Make the first ten minutes with Vajra work. Four defects, all re-confirmed live in an empty
directory before a line was changed (`sessions/session-128-repro.md`, step 1) — plus the audit that
stops the class recurring.

## What shipped

| # | The thing | Evidence |
|---|---|---|
| 1 | **`vajra --version` / `-V`** — prints `env!("CARGO_PKG_VERSION")`, exit 0. A FLAG, not an 8th command | `src/main.rs`; the test parses `Cargo.toml` at runtime rather than comparing against the constant the binary prints, so "read from the crate" is falsifiable |
| 2 | **The front door fails CLOSED** — an unknown word exits **2** and is named. `vajra chek && deploy` no longer runs deploy | `src/main.rs`; asserted through a live `sh -c` chain, with a positive anchor so it cannot pass when `sh` never ran the binary |
| 3 | **`verify-closeout.sh` survives bash 3.2** on a fresh repo — RED is a verdict, a crash is not | 14 guarded array expansions; run live on 3.2.57 |
| 4 | **`vajra check` is honest on arrival** — 9/11 → 10/11; the `vajra.varta` demand retired, the drift guard's teeth kept | `src/cli/check.rs`, 4 unit tests over all four states; demo cases 9–10 drive the two retained FAILs live |
| 5 | **`stranger_check`** — a real empty dir, a real `git init`, the real binary, 16 checks | `scripts/stranger-check.sh`, registered in `CONSTRAINTS.yaml#ground_truth.required_audits` |
| 6 | **Falsifiability** — each defect planted back, each turning the suite RED *through the check that owns it*, plus a rename control that stays GREEN | `scripts/fixture-session-128.sh`, 12/12 |

**Numbers:** verify **9/9** (3 exec · 2 struct · 1 behav · 3 nested) · demo **13/13** (12 exec ·
1 struct) · stranger-check **16/16** · fixture **12/12** · **364** tests · `K of 8` unmoved in
derivation and shape · **7 commands**, no 8th.

## What a stranger STILL gets wrong after this session

Stated plainly, because criterion 12 asked for it and because a working front door is the easiest
thing in the world to oversell.

1. **The scaffolded constitution is still a hand-maintained fork.** `vajra init` gives a stranger
   **66 lines**; this repo runs on **183**. They get a weaker rulebook than the one that produced
   every result above, and they get it silently. S128 deliberately did not touch this — it is a
   whole story of its own, and it is candidate A below.
2. **The scaffolded audit list is the same fork.** `src/cli/init.rs` ships `required_audits` with
   **seven** entries; this repo has **eleven**. `stranger_check`, `dogfood_check`,
   `pipeline_advance_check` and `dogfood_staleness` are all missing from it. In the cold reviewer's
   words: *"A stranger's ground truth will never run the audit invented to protect strangers."*
   **This session REFUSED to fix it** (rec 4) — see the dispositions.
3. **A stranger's very first `vajra check` still exits 1**, because `branch: not main` fails on a
   fresh `git init`. The failure is true and actionable, and the contract sanctions it — but
   `vajra check && …` still stops on a brand-new repo, which is the same shape as the bug this
   session just fixed one door over. Raised by the reviewer (rec 8); **not decided here**, because
   deciding it means deciding whether `vajra check`'s exit code is a health signal or a gate.
4. **`vajra init` still blocks on stdin without EOF.** Every script in this session works around it
   with `</dev/null`. A stranger piping or scripting it hangs, exactly as this session's own verify
   suite hung for nine minutes when a stray backtick ran it.
5. **Nobody is using any of this.** 0 stars · 0 forks · 0 issues · 0 external contributors ·
   19 downloads, unchanged. A front door that works is a precondition for adoption. It is not
   adoption, and nothing in this session is evidence of it.

## The fakest green

**The cold reviewer's call, kept:** `no-gate-evidence-contract-moved` — a `struct` check whose
whole assertion was that a **hand-typed** list of eleven directory names did not appear in
`git diff --name-only`. It passes if the session shipped nothing, and the typed list omitted
`src/cli/check.rs` — the one file whose evidence contract actually moved. *"The author picked the
boundary and then measured inside it."*

**Closed after the ACCEPT** (rec 3): replaced by a declaration check whose module inventory is
derived from the tree, where every source change must be declared with a reason and a **stale**
declaration also FAILS. `src/cli/check.rs`'s moved contract is now stated rather than hidden.

**Second fakest, still standing and NOT fixed:** `stranger_check` is *registered*, not *run*. The
demo scores its registration with a structural grep. Nothing forces a future ground-truth session
to execute it — the self-granted-jurisdiction class named at S68 and S71, one more time.

## The reviewer's 8 recommendations, answered

Landed as a governed handoff (`.ai/handoffs/session-128-fidelity-reviewer.md`) so the S127 advice
gate **consumes** them and blocks the close until each carries a disposition. Dispositions live in
`prompts/128-task-first-contact-works.md#Advice`.

**7 obeyed · 1 refused (rec 4, with a reason) · 0 deferred.**

**Four of them were closed AFTER the ACCEPT**, breaking the S123 rule out loud rather than quietly:
recs 2 and 3 closed a graded PARTIAL and the named fakest green, and rec 5 closed a probe that
could pass without running anything. The reviewer read the pre-fix tree; its verdict stands on that
tree, and the post-ACCEPT commits are named in the dispositions so anyone can separate them.

**rec 6 was tested and did NOT reproduce.** The reviewer predicted `[: too many arguments` from the
`${arr[@]+x}` guard on a ~100-element array. Measured at 102 elements on bash 3.2.57: the alternate
word expands once, not per element, and there is no error. The idiom was simplified to the count
form anyway, and both measurements are recorded in the script — guessing about bash 3.2 is how the
original crash shipped.

## Three things this session did not know when it started

- **The scaffolded `verify-closeout.sh` is byte-identical to this repo's** (`include_str!`). One
  source. That is why the bash-3.2 fix reaches every future scaffold, and why the fixture's R4
  plant falsifies through the scaffolded copy rather than a private one.
- **On bash 3.2, `${#arr[@]}` is fine and `"${arr[@]}"` is what aborts.** The emptiness tests never
  needed guarding; only the expansions did. The first fix guarded both on a guess.
- **An unescaped backtick inside a double-quoted `echo` is a command substitution.** A disclosure
  line reading ``echo "  * `vajra init` still blocks..."`` actually **ran `vajra init` in this
  repo** and hung the verify suite for nine minutes on its stdin prompt. A disclosure line that
  executes is its own joke, and it is now a single-quoted line with a comment saying why.

## Next — exactly 3 candidates, ranked

### A — **One source for what a stranger gets** (recommended)
**Goal:** kill the scaffold fork. `vajra init` should hand a stranger the same constitution and the
same required-audit list this repo runs on, derived from one source, with a check that fails when
the two drift.
**Why pick this:** it is the largest remaining first-contact defect, it is the same class as all
four fixed this session (nobody ever looked at what `init` actually produces), and both halves —
66-vs-183 lines and 7-vs-11 audits — are already named, measured and refused-with-a-reason in this
summary. The reviewer raised the audit half unprompted.
**Key risk:** the two files are not supposed to be identical. This repo's constitution names ADRs,
sessions and hooks a stranger's project has none of. "Derive from one source" may mean writing a
real derivation rather than an `include_str!`, and that is a bigger story than it looks.

### B — **Decide the first-contact exit codes, and unblock `vajra init`**
**Goal:** settle whether a fresh `vajra check` exiting 1 is right (rec 8), and make `vajra init`
work without a TTY.
**Why pick this:** both are stranger-visible, both are small, and both are exactly the class this
session was built to catch — `vajra check && …` stopping on a brand-new repo is the same shape as
the typo bug just fixed. The `stranger_check` already exists to hold whatever is decided.
**Key risk:** it is small enough to be a footnote. Two fixes and a decision is not a session unless
the exit-code question is genuinely answered rather than patched.

### C — **A paid dogfood ride-along through the new front door**
**Goal:** run a real session end-to-end from a freshly scaffolded repo, on the real product, paid,
and measure where a stranger actually stalls.
**Why pick this:** everything above is still this repo testing itself, one directory further out.
The last paid run measured the pipeline, not first contact. A ride-along would tell us whether the
first ten minutes now work in a way a person would recognise, not just in a way a script asserts.
**Key risk:** it spends money to produce findings rather than fixes, and S130 is the mandatory
ground truth — which will run `stranger_check` anyway. It may be better as the GT's input than as
its own session.
