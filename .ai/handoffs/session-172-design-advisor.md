---
role: design-advisor
session: 172
agent: claude-code-subagent (verified: toolu_01HWEvuBfiiPHgrxUecb1aDK)
source-sha: a4bb2361889186172377f899d485a5bf44f7943b6c283fbff6019f2a740d9d66
captured: 2026-09-20T17:45:34Z
cost_usd: null
---

# Design-advisor handoff — session 172

I read the real records before proposing. Findings brief below.

## What exists in this repo's spine (checked, not assumed)

`/Users/suman/playground/vajra/docs/adr/` — 0001 compression-delivery, 0002 engine-trait, 0003 settings-injector, 0004 meter-receipt, 0005 pre-run-cost-estimate.
`/Users/suman/playground/vajra/docs/decisions/` — DECISION-001 … DECISION-010.

Three of them are load-bearing for this session, and two of them **lock the exact line S172 moves**:

- `/Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md` line 687 (S127 addendum): the Advice gate is *"Wired into `--advance` on the CLOSING session"*.
- Same file, lines 765–766 (S131 addendum): the fidelity gate is *"wired into `vajra next --advance` exactly like the Coder/Advice/QA/Demo gates (binds on the session being CLOSED)"*.
- `/Users/suman/playground/vajra/docs/decisions/DECISION-010-unfakeable-demo.md` line 60: *"The gate binds only on the session being closed; old demos are never re-graded at close."*

That last line is the **intent** S172 finally makes true — DECISION-010 already said merged work must not be re-graded; the advance wiring quietly broke it, because advance runs after the merge. So F39 is simultaneously a deviation from DECISION-007's wiring clauses and a repair of DECISION-010's stated rule. Say both, in that order.

Also relevant, cite-able, and real: `/Users/suman/playground/vajra/docs/decisions/DECISION-008-session-type-detection.md` (closeout is where session-conditional checks fire; it names S67's existence-gating as the origin pattern) and DECISION-007 line 565 (S126 addendum), which says the `design-advisor` cites a record under **`docs/adr/` or `docs/decisions/`** — the exact sentence F35 widens.

---

rec 1 — record `design-significant: yes`, and give the reason as "a locked clause moves", not "we changed code"

Four independent triggers, any one of which is enough: a new interface other gates consume (`releaser::shipped_close()`), a new enforcement point in two shell scripts (`check_live_gate`), a changed behaviour contract every downstream project inherits (`src/architect` record discovery), and a deviation from a locked record. The fourth is decisive under the marker's own definition. A `no` here would be the cheapest instance of the self-granted-jurisdiction class DECISION-007's S127 addendum already names.

rec 2 — record this `## Design` body (real text, no placeholders; trim the last two paragraphs if you must, keep the deviation one)

```
design-significant: yes

Enforcement moves from post-merge to pre-merge. `vajra next --advance` re-judged the session it
closes, but advance runs AFTER that session merged — so merged work was re-graded by rules synced
in later (rudra F39). `releaser::shipped_close()` now asks git whether
`sessions/session-NN-summary.md` is on main; if it is, every closing gate REPORTS instead of
blocking and the slow live QA/demo re-runs are skipped. The teeth move earlier, not away:
`check_live_gate` in `scripts/verify-closeout.sh` and `scripts/verify-closeout-scaffold.sh` runs
`vajra next --check-advice/--check-qa/--check-demo` BEFORE the merge. `src/architect` also widens
record discovery to `docs/ADR/` and to `ADR-010-title.md` names: rudra's ten real ADRs were
invisible, so the citation check was silently waived and a made-up id would have passed.

Cites DECISION-007 (S127 addendum: the Advice gate "wired into `--advance` on the CLOSING
session"; S131 addendum: the fidelity gate "binds on the session being CLOSED"; S126 addendum:
the design-advisor cites a record under `docs/adr/` or `docs/decisions/`) and DECISION-010 ("the
gate binds only on the session being closed; old demos are never re-graded at close").
DEVIATION, stated plainly because the Architect gate checks the form of a citation and never
whether the design obeys it: this session MOVES the moment DECISION-007's two wiring clauses
lock, and in doing so makes DECISION-010's rule true for the other gates. An S172 addendum to
DECISION-007 records the move by name; no new DECISION record — new information about a locked
clause is an addendum (the S122 and S134 house pattern).

Rejected: grandfather merged sessions by a session-number threshold (DECISION-007 S133's shape —
its own S134 addendum proved the threshold is unknowable in a brownfield repo, and it would still
punish a session whose rules arrived after it merged); version the rule set and pin each session
to the rules it merged under (a new store and a clock for n=1 evidence); delete the closing
re-runs at advance and add nothing (removes teeth instead of relocating them); leave the design
gate waiving when `docs/adr/` is absent (a silent waiver reads exactly like a pass — that is the
rudra bug); make the ADR path a CONSTRAINTS.yaml setting (a second setting that drifts from the
folder it describes).

Honest risk: advance was the backstop and is not one any more. If `verify-closeout.sh` is not run
on the branch before the merge, nothing enforces the closing gates at all — the pre-merge rule
becomes load-bearing rather than advisory. `shipped_close()` keys on a single file being on main,
so landing a summary early (or any route that puts it there) downgrades four gates to reporting
while the session is still live: self-granted jurisdiction, disclosed and not fenced. Wider ADR
discovery still proves only that a file exists.
```

rec 3 — write ONE `## S172 addendum` to `/Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md`, not a new DECISION-011

This is a correction to where existing gates bind, on n=1 outside evidence (one rudra run). DECISION-007 owns both clauses being moved, and its own S122/S134 addenda establish that new information about a locked clause goes back into the record that locked it. The addendum must (a) quote the S127 and S131 sentences it supersedes, (b) say the new rule in one line — *a session whose summary is on main is never re-graded; closing gates bind pre-merge, at closeout* — and (c) cross-reference DECISION-010 line 60 as the rule this restores. A new top-level record becomes right only if a later session generalises "all enforcement is pre-merge" across every gate and the constitution; that generalisation is not what shipped here.

rec 4 — put the deviation in the `## Design` prose, not just in the addendum

The gate will pass a citation of DECISION-007 while the session moves DECISION-007's line — the S127 addendum documents that exact hole, and the S67 form floor is still the floor. The only thing that stops it reading as obedience is the word DEVIATION in the body. Do not soften it to "extends" or "clarifies".

rec 5 — name the backstop loss as a residual risk with a named owner, in the addendum's own "does NOT claim" section

Before S172 a skipped closeout was still caught at the next advance. Now it is not caught anywhere. The memory `closeout verify must run pre-merge` (S83) is now the whole enforcement story, and it is a text rule — and this repo's own S171 finding is that text rules get skipped while gates do not. Record that plainly rather than letting "enforcement moved earlier" read as "enforcement unchanged".

rec 6 — in the addendum, list the record shapes `src/architect` now accepts, and restate DECISION-007 line 565 so role text and code agree

Line 565 currently says `docs/adr/` (lowercase) only; the shipped code accepts `docs/ADR/` and `ADR-010-title.md` too. Leave it and the canonical `fleet::ROLES` design-advisor text keeps pointing at a folder shape that is one of several. Write the accepted set out — it is the contract every governed project now depends on — and keep the claim honest: discovery finds more real records, it does not make a citation correct.

rec 7 — prove `check_live_gate` goes red, the same way `tests/commit_belt.rs` proves the belt split

`registered ≠ run`: a gate helper added to two shell scripts and never observed failing is the exact shape this repo has been burned by. One falsifiability case — a session fixture whose `--check-advice` fails, asserting `verify-closeout.sh` exits non-zero and names it — is not a new gate on Vajra's own paperwork (it is a test of a gate that already shipped), so it sits inside this session's guardrail. If it is out of budget, record that in the findings table with a severity rather than dropping it.

---

Two things I did **not** find, stated so nobody reads silence as approval: there is no ADR or DECISION record covering the Architect station itself (S67 lives only in prompts and in DECISION-008's reference to it), and there is no record anywhere stating "enforcement happens pre-merge" as a general principle. The first is fine — DECISION-007 S126/S133 carry the design-advisor contract. The second is the gap rec 3 keeps deliberately narrow.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (8848 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
