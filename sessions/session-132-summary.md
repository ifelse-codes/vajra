# Session 132 — CODE: verify the recorded `obeyed:` disposition is actually true

**Goal:** an `obeyed: <sha>` disposition that does not implement its recommendation can no longer
pass silently.

**Verdict: goal achieved**, with the ceiling stated plainly below rather than buried.

## What shipped

| Piece | Where | What it does |
|---|---|---|
| The `obeyed-check` marker | `src/obeyed/mod.rs` | `obeyed-check [session NN] <role> rec <N> — implemented\|mismatch: <sha> — <note>`, recorded in a governed handoff body, parsed with the same boundary rule as the S127 disposition (`advice::split_role_rec`, factored out this session) |
| Four admissibility rules | `obeyed::admit` | the advisor may not grade its own advice (DECISION-002 one level down) · the judgment must name the sha the disposition records · the note must be substantive · the judging handoff's provenance must independently re-verify (S131's chain, reused whole) |
| The gate | `vajra next --check-obeyed NN`, wired into `--advance` | a `mismatch` or an inadmissible judgment BLOCKS at any session; a MISSING judgment blocks from session 132 on and WARNs before it, the exemption named in the output |
| The migration threshold | `obeyed::OBEYED_JUDGMENT_FROM_SESSION = 132` | the threshold governs SILENCE only — never a judgment that exists, which is what makes a historical session re-gradable |
| Closeout binding | `scripts/verify-closeout.sh::check_obeyed_judgments` | the gate runs at closeout too, not only if `--advance` is invoked (the S129 "registered ≠ run" hole) |
| The judgment contract, propagated | `fleet::OBEYED_JUDGMENT_RULE` → all nine `.claude/agents/*.md` | every role is now TOLD the grammar and the no-self-grading boundary; before this, the marker's only producers were a hand-written dispatch prompt and the builder itself |

## Evidence, live this session

- **`scripts/verify-session-132.sh` — 13/13 GREEN** (12 execute-based, 1 behavioral grep, labelled).
  Every gate check drives the REAL release binary against throwaway repos.
- **`scripts/demo-session-132.sh` — 8/8 GREEN**, all four required elements.
- **The S127 specimen, on the real historical record:** `vajra next --check-obeyed 127` exits 1 and
  reports `implementation-advisor rec 9 — obeyed: 8cd3bea — MISMATCH`, carrying the independent
  judge's own words about the `_uses` stub. Not a fixture: the disposition, the recommendation, the
  commit and the judgment are all landed artifacts.
- **402 lib tests**, `cargo clippy` clean.
- Falsifiability fixture: RED on each of four bypasses (self-certification · sha bind · provenance ·
  sticky mismatch), each probe asserting its own substitution landed and its red being a TEST
  FAILURE, not a compile error — and GREEN when every gate message string is renamed.

## Fidelity — every numbered requirement

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | `obeyed:` requires a recorded independent judgment | SHIPPED | `obeyed::obeyed_gate`; verify check 1 (blocks at the threshold) |
| 2 | A `mismatch` BLOCKS, naming role, number, disagreement | SHIPPED | verify check 2 asserts all three on live output |
| 3 | The S127 specimen reports MISMATCH on the real record | SHIPPED | verify check 6 + demo case 5; exit 1, live, no fixture |
| 4 | The judge is independent — never the builder, never the advisor | PARTIAL | advisor half is structural (`admit` rule 1) + provenance re-verification proves a real dispatch; the `--from` findings file is still builder-writable (S131 rec 4's residual, ROADMAP F2) |
| 5 | Falsifiability fixture drives TRUE / FALSE / ABSENT, each probe asserting its pattern | SHIPPED | verify checks 1/2/3/5 + four hardened bypass probes |
| 6 | K of 8, 7 commands, S131's Fidelity gate, other gates unchanged | SHIPPED | verify checks 9, 10, 10b, 12 — the Fidelity-gate trace added after the cold review's rec 4 |
| 7 | Both scripts exit 0 with a printed check-class tally | SHIPPED | 13/13 and 8/8, tallies printed, the one grep labelled `behav` |
| 8 | Independent cold `fidelity-reviewer` ACCEPT, attested | SHIPPED | two real dispatches; `sessions/session-132-review.md`, `Review-Inputs-SHA` embedded |
| 9 | The summary states plainly what is NOT fixed | SHIPPED | this section and the next |

## What is NOT fixed — plainly

1. **A lazy judge passes.** The gate proves an independent, provenance-verified role recorded a
   verdict against the exact commit named. It never proves the verdict is *correct*. Someone who
   writes `implemented:` without reading the diff satisfies every check here — the same form floor
   S127 disclosed for a refusal reason. Do not say "obedience is now provable"; say "an `obeyed:`
   nobody looked at can no longer close a session."
2. **`refused:` is now the cheapest exit.** A session that answers everything with a reasoned
   refusal is never judged at all, and nothing checks that a refusal is honest. That is the
   self-granted-jurisdiction class (S68/S71), and it is the obvious way to game this gate.
3. **"Independent" means a different DISPATCH, not provably a different mind.** The findings file
   passed to `vajra next --role … --from` is builder-writable; provenance proves a real subagent
   ran for this role and this session, not that the text came from it. That is S131's own rec 4
   residual (`.ai/ROADMAP.md` F2) sitting directly under this gate's load-bearing claim.
4. **The regress does not terminate by mechanism.** The judge's handoff carries its own numbered
   recommendations; obeying one produces a new `obeyed:` that needs its own judgment. This session
   terminated it by hand — a second cold pass graded the first pass's dispositions, and the second
   pass's own recommendations were answered without creating new `obeyed:` claims.
5. **`refused:` and `deferred:` soundness is out of scope**, as the prompt's Non-goals require.
6. **Unsigned provenance, inherited whole.** Dispatch evidence remains hand-fabricable by anyone
   with shell access to this machine (S131's disclosed limit). This session raises no part of it.
7. **A judgment marker no one writes is still invisible.** The grammar is now in every role's
   definition, but a role that simply never writes an `obeyed-check` line leaves the session
   blocked, not judged — the block is real, the judgment is not automatic.

## The fakest green

The cold review named it and this session fixed it, which is worth recording because it was
subtle: the first draft of verify check 6 grepped the binary's output for the literal words
`MISMATCH` and `_uses`. That check could only go green if the "independent" judge wrote exactly
what the builder expected — **a test of the reviewer's cooperation, not of the mechanism.** It now
derives the expected verdict from the landed judgment and asserts the join and the exit code, so it
is green under either honest verdict and red only when the join or the blocking breaks.

The remaining fakest green, unfixed: **`obeyed-check … implemented:` is a typed word.** Everything
this session built raises the bar on WHO may type it and WHICH commit it must name. Nothing checks
that the typist read the diff.

## Next — three candidates

**A. S133 — compression: keep or kill (the locked default).**
Goal: decide, with a measurement rather than a memory, whether the compression hook earns its place
in the product or is cut.
Why pick this: it is the founder-locked next session, and compression has been carried as
"never-claim-until-real" since S70 without a verdict; carrying an undecided feature costs every
future pitch.
Key risk: the measurement needs a real paid run to mean anything, which overlaps S134's dogfood.

**B. Close the content-binding residual (`.ai/ROADMAP.md` F2).**
Goal: bind a dispatch's own returned content to the `--from` findings file it stamps, so
"independent" stops meaning "a dispatch happened".
Why pick this: it is the load-bearing weakness under BOTH S131's and S132's headline claims, named
twice now by two different cold reviews.
Key risk: it is a real design problem (hashing a subagent's last transcript message), not a quick
fix — a full session, and it deepens governance machinery instead of advancing the payload.

**C. Make `refused:` answerable to the same standard.**
Goal: extend the judgment mechanism to `refused:` reasons, closing the cheapest exit this session
just created.
Why pick this: S132 hardened `obeyed:` and pushed the pressure straight onto `refused:`; the gap is
predictable and this repo's own history says the next layer is where the failure moves.
Key risk: judging whether a refusal is *sound* is a heavier judgement than "does this commit do
what was asked", and a form floor there may be worth very little.
