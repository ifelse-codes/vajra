# Session 127 — independent cold fidelity review

**Reviewer:** the `fidelity-reviewer` fleet role, dispatched by name as a native Claude Code
subagent from this session. It did not build this work and was fed exactly two things: the session
prompt `prompts/127-task-answer-every-recommendation.md` and the branch diff (`main...HEAD`), with
the instruction that the prompt's `## Advice` and `## Execution` sections are part of the DELIVERY,
not part of the ask.

**The brief below is the reviewer's own, landed as returned.** The builder did not edit its grades,
its fakest-green call, or its findings.

**The reviewer's findings are also a governed handoff** — `.ai/handoffs/session-127-fidelity-reviewer.md`
— and its eight numbered recommendations are answered in the prompt's `## Advice`, under the same
gate this session ships. That is not decoration: pass 1's fakest green was a dropped
recommendation, and the fix for it had to be visible to the same mechanism.

---

## Pass 1 — **REJECT** (8 SHIPPED · 2 PARTIAL · 2 NOT-BUILT)

**Method control, in the reviewer's own words:** *"Honest tooling limit: I have Read/Grep/Glob only
— no Bash. I could not run `git diff main...HEAD`, `git cat-file`, `cargo test`,
`verify-session-127.sh` or `demo-session-127.sh`. I reconstructed the delivery from the working tree
and verified every claimed sha against `.git/logs/HEAD`."*

| # | Requirement | Verdict |
|---|---|---|
| 1 | Unanswered rec BLOCKS, naming role + number + handoff path, via the real binary | SHIPPED |
| 2 | All answered → passes and prints one line per rec with its disposition | SHIPPED |
| 3 | `obeyed: <sha>` that does not resolve → unanswered + BLOCKS | SHIPPED |
| 4 | Empty / placeholder `refused:` → BLOCKS | SHIPPED |
| 5 | `deferred:` to a non-existent file → BLOCKS | SHIPPED |
| 6 | Zero numbered recs → WARN, dodge named; **summary repeats the limit** | PARTIAL — summary absent |
| 7 | Every role taught the marker shape, asserted per role | SHIPPED |
| 8 | `K of 8` derivation/shape unchanged, 7 commands, no other contract moved | SHIPPED |
| 9 | Falsifiability fixture goes RED for the right reason | SHIPPED |
| 10 | Both scripts exit 0 with a check-class tally, honestly labelled | PARTIAL — one inert sub-assertion |
| 11 | Independent cold verdict ACCEPT, attested | NOT-BUILT — *"This pass is that review, and it is a REJECT"* |
| 12 | Summary states the floor plainly | NOT-BUILT — summary absent |

### The fakest green (pass 1), verbatim in substance

> **`implementation-advisor rec 9 — obeyed: 8cd3bea` — and the stub it promised to delete is still
> in the shipped file.** … The gate scores it ANSWERED because `8cd3bea` resolves. **This is the
> session's own thesis failing on its own diff.** … 41 of the 43 answers are `obeyed:`, and 22 of
> them point at the single commit `15581a0`. **The disposition word carries all the meaning and
> none of the checking.**

The reviewer was correct. The builder's step-1 removal of that stub was a string replacement with
no assertion behind it; it silently no-opped, the file compiled, and the ledger recorded `obeyed:`.

**Runner-up:** the `--advance` binding was exercised by no test and no verify check, while the demo
printed that it was *"asserted by test and by the verify suite"* — a false sentence, repeated in the
prompt's own disclosure. **Third:** `grep -qi '^\s*\[.*\] *advice'` uses `\s`, a GNU extension BSD
grep ignores, so a scored `OK` line printed unconditionally.

### What held up under adversarial reading

- **Criterion 9** — *"the best-built thing here… Delete `recommendations_in`'s loop and State A's
  `items.len()==1` fails; delete the `check(d)` classification and State C's `blocked()` fails;
  rename any message and nothing moves, because no message is asserted on."* The reviewer further
  noted that a silently no-opping perl substitution in the verify twin leaves the check reporting
  **FAIL** — drift fails safe in the right direction.
- **Criterion 12** — *"I looked for one and could not find it."* No obedience overclaim anywhere.
- **Criterion 8** — nothing else moved: `STATION_COUNT` still 8 and asserted in order, the
  invariance check at a real `8 of 8` baseline, seven commands, `handoff_body` refactored with
  byte-identical filtering, `raw_body` purely additive.
- **The guardrail** — all 43 recommendations answered; both refusals real and matching the code;
  every claimed sha present in the reflog.

### Scope call (pass 1)

> *"This is a faithful build of the whole contract, not one narrow slice presented as the whole. …
> It is short in exactly two places — the close-path binding has no executable evidence and is
> described as though it does, and the closeout artifacts are not written. And its own advice
> ledger, the artifact that is supposed to make silent drops impossible, contains at least one
> silent drop wearing an `obeyed:` label."*

---

## What changed between pass 1 and pass 2

Every one of the reviewer's eight recommendations was answered in `## Advice` under this session's
own gate. The five blocking ones were obeyed in code:

| rec | fix | commit |
|---|---|---|
| 1 | the dead `_uses` stub deleted | `8da2093` |
| 2 | the false *"asserted by test"* sentence corrected in the demo and the disclosure | `8da2093` |
| 3 | **new execute-based check `advance-really-binds-on-unanswered-advice`** — drives the real `vajra next --advance` with every *other* stage neutralised by its own documented override, so the refusal can only be the Advice gate's; then advances under `VAJRA_SKIP_ADVICE_GATE=1` | `8da2093` |
| 4 | the dodge sentence hoisted to one const, `advice::DODGE` | `8da2093` |
| 5 | the `\s` pattern replaced with a POSIX-portable one | `8da2093` |
| 8 | the sharper floor recorded in the addendum, with its live specimen | `9740be6` |
| 6, 7 | this file, the summary, and the `## Execution` shas | below |

Verify moved from 9 checks to **10**, all green. The demo stayed at **13**, all green.

**The thing worth keeping from pass 1 is not the fix list — it is the specimen.** A wrong `obeyed:`
resolved a real sha and scored ANSWERED inside the very ledger built to make silent drops
impossible. The only thing that caught it was a reader. That is now recorded in `DECISION-007`'s
"does NOT claim" list, not as an abstraction but with the case attached.

---

## Pass 2 — verdict recorded below

*(Pass 2 was run on a fresh cold context, fed only the prompt and the diff, after every fix above
had landed.)*
