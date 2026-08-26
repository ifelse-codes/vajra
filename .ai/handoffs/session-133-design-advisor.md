---
role: design-advisor
session: 133
agent: claude-code-subagent (verified: toolu_01FgiKkQM1U1AD6eRXth3fFv)
source-sha: 4fe345ca6637f6a05ef007e9d885bf41bb031698655402fdb7616274dd87cede
captured: 2026-08-25T17:12:48Z
cost_usd: null
---

# Design-advisor handoff — session 133

## Findings

# design-advisor brief — session 133 (the design-advisor becomes mandatory)

## What I read

`prompts/133-task-design-advisor-mandatory.md`, `src/fidelity/mod.rs`, `src/architect/mod.rs`,
`src/advice/mod.rs`, `src/obeyed/mod.rs`, `src/cli/next.rs`, `.githooks/pre-commit`,
`scripts/hook-commit-guard.sh`, `scripts/verify-closeout.sh`,
`docs/decisions/DECISION-007-agent-fleet.md`, `docs/decisions/DECISION-002-fidelity-over-discipline.md`,
`src/fleet/mod.rs`, `src/analyst/mod.rs`.

**Spine records verified to EXIST before citing:** `docs/decisions/DECISION-007-agent-fleet.md`
(with its S126 and S131 addenda), `docs/decisions/DECISION-002-fidelity-over-discipline.md`. The
full spine is ADR-0001..0005 plus DECISION-001..007 — **there is no DECISION-008**, so do not cite one.

**Live count that shapes the migration answer:** `.ai/handoffs/` holds 18 handoffs and exactly
**one** `design-advisor` handoff in the repo's whole history (`session-126-design-advisor.md`).

## 1. Command shape — its own sub-flag, and the loser's reason

Three reasons, the third decisive:

1. **Different subject.** `architect::design_gate` is documented and wired as "advancing INTO
   `session`" — it binds on `next`. Every mandatory-handoff gate (`fidelity`, `obeyed`, `advice`,
   `coder`) binds on `current`, the session being CLOSED. One flag cannot mean two different
   session numbers without a reader getting it wrong.
2. **Different failure modes behind one exit code** — S131's exact argument at
   `src/fidelity/mod.rs:18-22`, and it transfers verbatim: a prompt can have a perfect `## Design`
   and no dispatch, or a real dispatch and a placeholder `## Design`. Merging them blurs the two.
3. **The merge would build the loophole in.** `parse_design` returns `NotSignificant` and never
   blocks whenever the marker is `no`/unrecorded (`src/architect/mod.rs:211-222`). Folding the
   handoff requirement into that function means `design-significant: no` silently exempts a
   mandatory role.

**The loser, named honestly:** riding `--check-design` gives a reader ONE place to look for "the
design question", which is a real and good property. Recover it cheaply without the merge: have
`--check-design`'s output print a cross-reference line. Cross-reference, not shared logic.

The 7-top-level-command floor is untouched either way (both are sub-flags on `next`), so it is not
an argument for either side.

## 2. Where the skip reason lives — exact grammar

Exactly what I recommend the S133 author record for a skip:

```
- design-advisor: skipped — <one real sentence saying why this session does not need a design review>
```

Parser contract, reusing what exists rather than inventing:

- Clean the line the way `architect::design_significance` does (strip `-`/`*`, `**`, `>`,
  backticks), then require the cleaned line to **start with** the role key followed by `:`. A
  mid-sentence mention never counts — the same anchoring rule that makes `rec N —` safe.
- Skip fenced blocks via `advice::skip_fenced`. This is not theoretical: S127 shipped a bug where a
  fenced EXAMPLE `## Advice` heading was mistaken for the real section (`src/advice/mod.rs:367-377`).
- Require the literal word `skipped` after the colon, then one separator from `advice::SEPARATORS`,
  then the reason. Requiring the word means a reader greps ONE string:
  `grep -rn "design-advisor: skipped" prompts/`.
- Gate the reason with `advice::substantive_reason` verbatim — non-empty, not `<...>`. Do not add a
  stop-word list or a word-count; S127 shipped both and removed them (`src/advice/mod.rs:473-483`),
  and S122's lesson is that a guard bound to a spelling gets escaped.

**Why the grammar is `<role-key>:` and not a design-specific literal:** the role keys are a closed
set in `fleet::ROLES`, so this one rule generalises for free — S134 records
`implementation-advisor: skipped — <reason>` with zero new grammar.

**Rejected alternatives, named:**

- **A dedicated marker outside `## Design`** — rejected: two markers about the same concern in two
  places is the drift `## Design` exists to prevent.
- **A separate file (`.ai/skips.md`, a new `docs/` record)** — rejected under the S53 rule:
  `prompts/` IS the memory. It also breaks the attestation binding — `Review-Inputs-SHA` hashes the
  prompt, not a sidecar.
- **Recording it in `## Advice`** — rejected: that section answers recommendations that EXIST. A
  skip means no advisor ran.
- **A commit message or git trailer** — rejected: binds to one commit, not the session, and is
  invisible to anyone reading the prompt months later.
- **Hard section-scoping (only valid inside `## Design`)** — rejected: it turns a formatting slip
  into a false BLOCK. Disclosed cost: a prompt that quotes another session's skip line at
  line-start would satisfy the gate.

## 3. `design-significant: no` — it does NOT excuse the handoff

If `no` excused it, the dodge would be: one word, already required by a different gate,
self-asserted by the very author being governed, costing nothing and leaving no new trace. That is
the "jurisdiction is self-granted" class (S68/S71) in its cheapest possible form.

```
- design-significant: no — pure fix
- design-advisor: skipped — pure fix: no new interface, no new module, no deviation from a locked record
```

**The loophole, either way, stated plainly:** with my recommendation the dodge becomes "write
`design-advisor: skipped — pure fix` every session". That is not closed. It is made **visible,
greppable and countable**, which is the entire trade this session is making.

## 4. The precedence ladder — decide it, do not let it fall out

1. handoff exists but is **Malformed**, or its provenance does not re-verify → **BLOCK at any
   session, even with a recorded reason.**
2. handoff exists and re-verifies → **PASS** (if a `skipped` marker is also present, WARN on the
   contradiction).
3. no handoff + substantive marker → **PASS, and PRINT the reason**.
4. no handoff + marker present but empty/placeholder → **BLOCK**.
5. no handoff + no marker + session ≥ threshold → **BLOCK**, naming both ways to satisfy.
6. no handoff + no marker + session < threshold → **WARN**, naming the exemption.

Rung 1 vs rung 3 is a genuine conflict between criterion 2 and criterion 4 in the prompt as written.

## 5. When it binds — close-time, and say so

Why a pre-commit binding is the wrong trade here, concretely:

- The L2 hook fires on **every** commit on a session branch, including the commit that lands the
  prompt edit recording the skip reason. Chicken-and-egg on the session's own first commit.
- Re-verifying provenance needs the compiled binary and a local `~/.claude/projects` history. Wiring
  that into pre-commit makes **every commit in this repo** depend on `target/release/vajra` being
  freshly built. That is bricking the build agent — the exact hazard
  `scripts/hook-commit-guard.sh:24-35` already documents.
- The shell alternative (re-implement the check in bash) is a second parser of the same marker.
- `git commit --no-verify` skips the L2 hook anyway.

**What is lost by close-time binding, said plainly:** the gate cannot stop code being written before
advice is taken. It can only stop the session CLOSING.

## 6. Migration threshold — 133, governing silence only, plus a hole S132 left

The evidence: exactly one `design-advisor` handoff exists across 132 sessions. Retro-blocking would
make 132 sessions un-closeable.

**The hole worth naming while you are there:** a session-NUMBER threshold is meaningful for THIS
repo's history and perverse in a freshly-`vajra init`'d project, where sessions 1..132 would all sit
below the threshold — shipping a "mandatory" gate that does nothing for 132 sessions. S132's constant
has the same defect and nobody has said so. The clean fix: have the scaffold emit the marker line as
a placeholder, so **rung 4 blocks** in a fresh project from session 1. Number-based exemption for
legacy, marker-based enforcement for everything new.

## 7. The rejected-escape check — no env var, and where the pull comes from

The pull toward an env var is real: `--advance` treats every gate uniformly. Symmetry will make an
env var feel like the house style. The answer is that **this gate's entire novelty is that its escape
hatch leaves a trace**. Ship both and the recorded reason becomes the honest person's path while the
traceless one stays open for everyone else.

Two caveats to record rather than leave implicit:

- **`VAJRA_CLOSEOUT_WAIVER=N` will still waive it** once the check is in `verify-closeout.sh`. My
  recommendation: **honour it**, and record the distinction in words — a founder-held,
  session-scoped, un-forgeable-by-the-agent waiver is a different animal from an agent-settable skip
  flag.
- **L1 maturity still advises rather than blocks** in `--advance`, uniformly with every other gate.

## 8. Module shape (a design call the prompt does not ask, and should)

Criterion 7 requires S131's Fidelity gate to be unchanged by this session. **Rejected alternative
(a):** extract now and argue "unchanged" means behaviourally unchanged. Defensible, but it spends an
assumption on re-interpreting an acceptance criterion. **Rejected alternative (b):** copy
`src/fidelity/mod.rs` into `src/design_advisor/mod.rs` — cheapest, and it guarantees a third copy at
S134. My recommendation is the middle: new generic module, fidelity untouched, and file "fold
`fidelity_gate` into `mandate`" as named debt.

## 9. The fakest green, and whether the reasoned skip becomes the default

**The fakest green this design will produce:** *"the design-advisor was consulted" means a
contract-valid file exists whose dispatch cross-checks — never that its advice reached the design.*
Three concrete shapes:

1. **Rubber-stamp ordering.** Write the code, dispatch the advisor at close, land the handoff. Every
   gate green; the advice changed nothing.
2. **The unread handoff.** S127's Advice gate covers part of it — but ONLY if the advisor numbers its
   recommendations. So the combined honest claim is: **S133 makes the DISPATCH mandatory; it does not
   make the ADVICE binding.**
3. **Reason inflation.** `design-advisor: skipped — pure fix`, typed reflexively.

**Does the reasoned skip become the default dodge?** Assume it will drift that way unless someone
counts. The observable signals:

- **Ratio:** `grep -rl "design-advisor: skipped" prompts/` versus
  `ls .ai/handoffs/session-*-design-advisor.md` over any rolling 5-session window. **Skips >
  dispatches in a 5-session window = the skip has become the default.**
- **Text repetition:** the same reason sentence in 3+ consecutive prompts.
- **Contradiction count:** sessions recording `design-significant: yes` alongside a skip.

## 10. S133's own prompt — marker value and Architect-gate readiness

**`design-significant:` value — keep `yes`.** It adds a new module, a new CLI sub-flag, a new marker
grammar, and a new *class* of escape that every future gate in this repo will copy.

**Is the existing `## Design` substantive enough for the Architect gate? Yes, today — I traced it
against the real parser.** `## Design` at line 157 matches `is_design_heading`;
`design-significant: yes` parses as `Significance::Yes`; the section cites `DECISION-007` and
`DECISION-002`, and both exist in the spine. `parse_design` returns `Substantive` and
`--check-design 133` passes. But it passes as a QUESTION, not a DECISION.

**The deviation the Architect gate structurally cannot catch:** the DECISION-007 S131 addendum closes
with *"this addendum does not generalise the pattern to a second role — S131's own prompt names that
explicitly out of scope, to be repeated only after this one is proven in use."* S133 IS that
repetition, on n=2 enforced sessions (S131, S132). Citing DECISION-007 passes `--check-design` while
quietly moving a line that record locked.

## Numbered recommendations

rec 1 — Give the gate its own sub-flag `vajra next --check-design-handoff NN`; do not ride `--check-design`, and have `--check-design` print a cross-reference line instead.

rec 2 — Record the skip as `<role-key>: skipped — <reason>` in the session's own prompt: line-anchored after decoration-stripping, fenced blocks skipped (`advice::skip_fenced`), reason gated by `advice::substantive_reason` verbatim, `## Design` taught as its home but parsed anywhere in the prompt.

rec 3 — `design-significant: no` does NOT excuse the handoff; it is a reason a human may write on the skip line, never an exemption the machine infers.

rec 4 — Record the six-rung precedence ladder explicitly in the module header, including the rung-1-over-rung-3 call: an unverifiable handoff BLOCKS even when a substantive reason is also recorded.

rec 5 — Bind at close (`--advance` on the CLOSING session plus `verify-closeout.sh`); add nothing to `.githooks/pre-commit`, and state in the summary that "before code" is a workflow property, not a mechanism.

rec 6 — Set `DESIGN_ADVISOR_MANDATE_FROM_SESSION = 133` governing SILENCE only, and close the fresh-project hole by scaffolding the marker as a placeholder so rung 4 binds from session 1 in a new repo.

rec 7 — Ship no `VAJRA_SKIP_DESIGN_ADVISOR_GATE`; record that the marker IS the override, that `VAJRA_CLOSEOUT_WAIVER` is still honoured because it is founder-held and un-forgeable by the agent, and that L1 still advises.

rec 8 — Name the module for the mechanism (`src/mandate/mod.rs`), generic over `&fleet::Role` plus a marker key so S134 is a table entry; leave `src/fidelity/mod.rs` untouched this session and file the fold-in as named debt.

rec 9 — `design-significant: yes` plus a recorded skip PASSES but prints a loud WARN naming the contradiction.

rec 10 — Define the visible-skip line and the "a reason was written, never that it is good" floor as single module constants reused by gate, surface and summary (the `DODGE`/`CEILING` precedent).

rec 11 — State the fakest green as "a contract-valid handoff exists, never that its advice reached the design", and commit to the counting rule for the default-dodge signal: skips outnumbering dispatches in any rolling 5-session window.

rec 12 — Keep `design-significant: yes` for S133, and before close replace the two "open design question" bullets in its `## Design` with the recorded decisions and their rejected alternatives — the section currently passes the Architect gate while recording questions.

rec 13 — Record this as a DECISION-007 S133 addendum (not a DECISION-008), and say in `## Design` that it relaxes the S131 addendum's "only after this one is proven in use" condition on n=2 under a direct founder instruction — a deviation the Architect gate cannot catch.

rec 14 — WARN (never block) when the handoff's `captured:` timestamp is later than the session's first code commit; if it does not fit the budget, record it in the summary as the named observable for rubber-stamping.

rec 15 — In `verify-closeout.sh`, require the gate's own header string in the output (an unknown flag exits 0 via `run_dump`) and FAIL rather than pass when `target/release/vajra` is missing.

## One operational note for criterion 9

For this handoff to satisfy the gate S133 is building, it must be filed with
`vajra next --role design-advisor --from <file>` from this branch. `dispatch::reverify` requires the
dispatching session's `gitBranch` to start with `session-133-`.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (15503 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
