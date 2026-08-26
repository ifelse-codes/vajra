# Session 133 — CODE: the design-advisor becomes mandatory, and a skip must carry a reason

**Goal:** a session cannot reach its close without either a real `design-advisor` governed handoff
or a RECORDED, substantive reason why it did not need one. A silent skip is no longer possible; a
reasoned skip always is.

**Goal achieved.** `vajra next --check-design-handoff NN` blocks at `--advance` AND at
`scripts/verify-closeout.sh`. There is no `VAJRA_SKIP_DESIGN_ADVISOR_GATE` and there never will be
one: the escape hatch is a sentence in the session's own prompt, which is exactly the property an
environment variable cannot have.

**Dogfooded on itself.** S133's own design question — ride `--check-design` or take its own
command, and where the skip reason lives — went to a real `design-advisor` dispatch BEFORE a line
of code was written (`.ai/handoffs/session-133-design-advisor.md`, provenance
`verified: toolu_01FgiKkQM1U1AD6eRXth3fFv`). Fourteen of its fifteen recommendations were obeyed;
one was deferred with the reason written down. **S133 satisfied its own gate by dispatching, not by
skipping** — if it had needed a reasoned skip, the mechanism would have been wrong.

---

## What shipped

| Piece | Where |
|---|---|
| The Mandate gate — a six-rung precedence ladder, generic over a `fleet::Role` | `src/mandate/mod.rs` |
| `vajra next --check-design-handoff NN` + the `--advance` wiring + a cross-reference from `--check-design` | `src/cli/next.rs` |
| The reasoned-skip grammar `<role-name>: skipped — <reason>` | `src/mandate/mod.rs` (`parse_skip_marker`) |
| The scaffold carries the marker, so a fresh repo binds at session 1 | `src/analyst/mod.rs` (`PROMPT_TEMPLATE`) |
| The gate binds at the closeout gate too, not only at `--advance` | `scripts/verify-closeout.sh` (`check_design_advisor_mandate`) |
| The decision of record, and the S131 condition it relaxes | `docs/decisions/DECISION-007-agent-fleet.md` (S133 addendum) |
| 15-check verify suite · 9-case demo | `scripts/verify-session-133.sh` · `scripts/demo-session-133.sh` |

### The ladder, decided rather than fallen out of the code

| # | Situation | Outcome |
|---|---|---|
| 1 | handoff exists but is malformed, or its provenance does not re-verify | **BLOCK at any session, even with a recorded reason** |
| 2 | handoff exists and its provenance independently re-verifies | PASS (WARN if a skip reason is also recorded) |
| 3 | no handoff + a substantive recorded reason | **PASS, and PRINT the reason** |
| 4 | no handoff + a marker that records no usable reason | **BLOCK at any session** |
| 5 | no handoff + no marker + session ≥ 133 | **BLOCK**, naming both ways out |
| 6 | no handoff + no marker + session < 133 | WARN, naming the exemption |

Rung 1 beating rung 3 is the one real conflict in this session's contract (acceptance 2 vs
acceptance 4), and it is resolved on purpose: **a forged claim is not cured by a sentence.**

### Three design calls worth re-reading later

- **Its own sub-flag, not a ride on `--check-design`.** Folding them would have made
  `design-significant: no` silently exempt a mandatory role, because `architect::parse_design`
  never blocks on that value. The one-place-to-look property is recovered by a cross-reference line.
- **`design-significant: no` does NOT excuse the handoff.** An author's own "this is not
  design-significant" is exactly the judgement a second brain exists to check.
- **Threshold 133 governs SILENCE ONLY.** A marker or handoff that EXISTS binds at any session
  number. And because a session-number threshold would exempt sessions 1–132 of a brand-new repo,
  the scaffolded prompt carries the marker as a placeholder — which lands on rung 4 and blocks.

---

## Evidence, live this session

| What | Result |
|---|---|
| `scripts/verify-session-133.sh` | **15/15 GREEN** (14 execute-based · 1 behavioral grep, disclosed) |
| `scripts/demo-session-133.sh` | **9/9 GREEN** |
| `cargo test --lib` | **428 passed**, 0 failed (26 new in `mandate`) |
| `cargo clippy --all-targets -D warnings` · `cargo fmt --check` | clean |
| Falsifiability fixture | **7 bypasses RED** (each asserting its substitution landed and its red is a test failure, not a compile error), **11 messages renamed → still GREEN** |
| `K of 8` | **8 of 8 at session 132**, pinned to that baseline — unchanged |
| 7-command floor | unchanged; both new flags ride `vajra next` |
| S131 Fidelity gate · S132 Obeyed gate | traced live, unchanged (`--check-obeyed 127` still exit 1 MISMATCH) |
| Cold `fidelity-reviewer` verdict | **ACCEPT** — see `sessions/session-133-review.md` |

---

## Fidelity check — every numbered requirement

| # | Requirement | Verdict |
|---|---|---|
| A1 | Silence BLOCKS, naming what is missing and both ways to satisfy it | SHIPPED |
| A2 | A substantive reason PASSES **and the gate prints it** | SHIPPED |
| A3 | An empty or placeholder reason BLOCKS | SHIPPED |
| A4 | A handoff whose provenance does not re-verify BLOCKS | SHIPPED |
| A5 | The reason lives in the repo; no env var silently satisfies or bypasses | **PARTIAL — see below** |
| A6 | Falsifiability fixture drives all five directions, each probe asserting its own pattern | SHIPPED |
| A7 | Traced: `K of 8`, 7 commands, S131's and S132's gates unchanged | SHIPPED |
| A8 | Both scripts exit 0 with a printed check-class tally | SHIPPED |
| A9 | S133's own design question went to a real dispatch; handoff landed | SHIPPED |
| A10 | Independent cold `fidelity-reviewer` ACCEPT, attested; a separate judging dispatch | SHIPPED |
| A11 | The summary states plainly what is NOT fixed, incl. the default-dodge risk | SHIPPED (this section) |

**A5 is PARTIAL and the cold review is right about it.** No environment variable BYPASSES the
block — twelve names are driven live, one at a time and all together, and the gate refuses every
time; the module contains zero `env::var` calls; the `--advance` block is the only gate there with
no override. But the SATISFY half carries S131's inherited limit:
**`VAJRA_CLAUDE_PROJECTS_DIR` redirects where provenance evidence is read from**, and this
session's own positive control uses it to build a passing dispatch out of three `printf`s. The
claim in `DECISION-007` and the demo was narrowed to say so. It cannot release a session that
recorded nothing, and the suite asserts that boundary.

---

## What is still NOT fixed — plainly

1. **The fakest green: "the design-advisor was consulted" means a contract-valid file exists whose
   dispatch cross-checks — never that its advice reached the design.** A session can write all its
   code, dispatch the advisor at the end, land the handoff, and show every gate green. The cheap
   partial answer (compare the handoff's `captured:` timestamp against the session's first code
   commit and WARN) was proposed by the advisor itself as rec 14 and **deliberately not built** —
   a second story, and "which commit counts as code" is a judgement the binary should not guess.
   Filed as `.ai/ROADMAP.md` **F2f**.

2. **The reasoned skip may become the default dodge.** This is the honest risk of the whole design
   and nothing in the machine prevents it. The counting rule is fixed NOW so a later session cannot
   pick a flattering one — **skips outnumbering dispatches in any rolling 5-session window means
   the skip has become the default:**

   ```bash
   grep -rl "design-advisor: skipped" prompts/ | wc -l   # skips recorded
   ls .ai/handoffs/session-*-design-advisor.md | wc -l   # dispatches landed
   ```

   Two supporting signals: the same reason sentence appearing in 3+ consecutive prompts (a ritual,
   not a decision), and the count of sessions recording `design-significant: yes` alongside a skip
   (the gate WARNs on each, so they are greppable in its output).

3. **The gate binds at CLOSE, not before code.** "Before code" is a WORKFLOW property — Plan step 1,
   the boot packet — not a mechanism. A pre-commit binding was considered and refused: it would
   fire on the very commit that records the skip reason, and it would make every commit in this
   repo depend on a fresh `target/release/vajra` plus local Claude Code history. Acceptance 1's
   wording ("when a session reaches its code work") must not be read as a commit-time block.

4. **The reasoned skip is self-granted.** A session types one line into a file it owns and passes.
   That is the S68/S71 jurisdiction class, and it is the deliberate trade: the dodge is not closed,
   it is made **visible, greppable and countable**.

5. **`maturity: L1` still turns this gate advisory at `--advance`**, uniformly with every other
   gate, and `.ai/CONSTRAINTS.yaml` is agent-writable. Nothing probes it live. `.ai/ROADMAP.md`
   **F2g**.

6. **Two copies of the mandatory-role ladder.** `src/mandate/mod.rs` and `src/fidelity/mod.rs`
   check the same three things. S133 left S131's gate untouched because acceptance 7 required it;
   folding `fidelity_gate` into `mandate` is the right end state. `.ai/ROADMAP.md` **F2e**.
   **S134 must not add a third copy** — `implementation-advisor` is a call site.

7. **S131's disclosed limit is inherited whole and not improved:** the on-disk dispatch evidence is
   UNSIGNED and hand-fabricable by anyone with shell access to this machine.

8. **The paid dogfood is deferred again and is now the oldest un-run item on the roadmap.** Live
   query at this closeout: last paid dogfood **S124, $3.2985, 2026-08-20 — 9 sessions and 6
   calendar days stale.** Saying it here rather than letting it fall off.

9. **Eight of nine fleet roles remain optional**, and this session dispatched only two of them
   (`design-advisor`, `fidelity-reviewer`) plus the judge. Nothing here claims all nine should be
   mandatory; the founder named two.

---

## Cost

`$0` metered for the build (interactive session). Unmetered subagent tokens across three real
dispatches: `design-advisor` ~139k, `fidelity-reviewer` ~150k (plus ~135k on a first attempt that
died mid-response to an API error and returned nothing), `implementation-advisor` (the judge) — the
totals are in the session ledger, not in a receipt, because a subagent's cost rolls into the parent
session and this session was not run under `vajra claude`.

---

## Next — 3 ranked candidates

### A. S134 — the same treatment for `implementation-advisor` (the founder's stated default)

- **Goal:** the second build-shaping advisor becomes mandatory on S133's mechanism, as a CALL SITE
  on `mandate` — a second `*_gate` wrapper and a table entry, no third copy of the ladder.
- **Why pick this:** it is the founder's locked sequence, the mechanism is proven once and is
  designed to be reused, and it is the cheapest session on this list. It also closes the honest
  question S133 leaves open — whether the grammar really is generic, or generic only in the
  comments. Fold `fidelity_gate` into `mandate` (F2e) or record why not, and probe the `L1` escape
  (F2g) live.
- **Key risk:** it is nearly free, which is exactly what makes it look like progress. Two mandatory
  advisors do not make the fleet used; they make two roles unskippable. If S134 ships without
  touching F2f, the repo will have two gates that prove a dispatch happened and still nothing that
  observes whether any advice changed the work.

### B. The rubber-stamp detector (ROADMAP F2f) — make the mandate mean something

- **Goal:** WARN (never block) when a mandatory role's handoff was captured AFTER the session's
  first code commit — the advice arrived after the work.
- **Why pick this:** it attacks S133's named fakest green directly, and it is the only item here
  that moves "a dispatch happened" toward "the advice had a chance to matter". Both artifacts
  already carry the data.
- **Key risk:** "which commit counts as code" is a judgement, and a WARN nobody reads is
  decoration. It may also be honestly unanswerable for a session that legitimately re-dispatches
  late.

### C. The fresh-scaffold paid dogfood — the oldest un-run item on the roadmap

- **Goal:** run a real paid session through `vajra claude` in a fresh `vajra init` project, not in
  the repo that builds Vajra, and measure what a stranger actually experiences.
- **Why pick this:** last paid dogfood was S124 — 9 sessions and 6 calendar days ago — and every
  instrument in this repo measures Vajra governing itself. S128's stranger-check exists precisely
  because that blind spot hid four first-contact defects for 125 sessions.
- **Key risk:** it costs real money and produces no new mechanism, and it will very likely surface
  a pile of first-contact defects that turn into their own sessions. It is also the one item that
  can tell us whether any of the last nine sessions are worth anything to a user.

---

## Founder's pick, recorded after the close

**C — the fresh paid dogfood — with A deferred, not dropped.** The founder took the recommendation
over the locked default. The reasoning that carried it: S133 shipped a gate that blocks a brand-new
project's FIRST session, and it has only ever been exercised against fixtures this repo wrote; nine
sessions have passed since the last paid run; and option A would have been the tenth consecutive
session with nothing a user could see.

The founder also chose the payload, in their own words: run it on **chitra**, and *"take all the new
charts implemented in mudra design and review them and see them, and then tell me if it is
impressive or not — or if not, what can be fixed; if yes, why and what we made good."*

So S134 has two audiences and owes both a real answer: the design verdict for the founder, and the
dogfood measurement for Vajra. Brief:
`prompts/134-task-dogfood-chitra-mudra-review.md`. Option **A**'s brief was not discarded — it
survives in full inside that prompt's Non-goals, so restoring it costs nothing.
