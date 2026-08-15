# Session 118 — Dogfood ground truth (paid `vajra claude` run on chitra)

**Type:** DOGFOOD (paid). Deliverable = evidence, not Vajra `src/` changes.
**Run:** one headless stage, `vajra claude -p --model sonnet`, guards ON, CC permissions off.

## Verdict rows

| Axis | Reading | Verdict |
|---|---|---|
| **cost** | `total_cost_usd` = **$4.0911771** (authoritative, S78 tee path), cumulative $4.0912 against a $5 cap | 🟢 under cap, authoritative |
| **budget mechanism** | gate present and recorded (`budget-gate.txt`), but **never triggered** — the refusal path is unproven | 🟡 real code, untested branch |
| **stations** | pre-run 3 of 8 → post-run 2 of 8 (Releaser flipped ABSENT once the session branch existed) | 🟡 counter behaved as designed; expected mid-session shape |
| **obedience** | **1 gate proven against the permission-free agent** (chitra L3 session guard, 3 file-backed `permission_denials`); 3 further blocks hit the operator, uncaptured; the rest HELD (no violation attempted). `main` untouched, nothing pushed | 🟢 enforced-not-voluntary, on one file-backed gate — not the six the first draft claimed |
| **dogfood_staleness** | was S103 / 14 sessions / 16 days 🔴; this run closes it (re-read post-closeout) | 🟢 retired |
| **chitra-S11 outcome** | shell + editor + preview + toolbar real; **19 of 20 chart pages errored** as delivered; repaired by the operator to 20 of 20 | 🔴 as delivered · 🟢 after repair |
| **fidelity enforcement** | nothing in the governed run noticed the breakage; verify was 14/14 green on a broken page | 🔴 the finding of this session |

## The finding, plainly

Vajra's gates enforce **how** work is done and enforce it genuinely — even against an
agent whose host permission checks were switched off. Nothing in the system asks
**whether the delivered thing works.**

chitra S11 shipped a page where 19 of 20 charts showed an error instead of a chart. On
that page:

- `scripts/verify-session-11.sh` reported **14 of 14 ALL GREEN** (all 11 catalog checks
  were `grep` for source strings such as `new Function` and `catalog-page`),
- the session summary claimed **8 of 8 SHIPPED** and "Nothing from the acceptance
  criteria was omitted",
- and the run's own "independent cold fidelity review" **passed** it.

This is the **S54 finding reproduced exactly**, one full pipeline generation later, on a
paid run — and it is the strongest argument yet for [[vajra-fidelity-over-discipline]]:
discipline gates cannot detect a hollow delivery, because a hollow delivery breaks no rule.

The one detail the governed run got right and that matters: the evaluator was **genuinely
live**. Editing the buffer really did execute chitra in the browser. The agent built the
hard part and shipped it broken, then graded it green.

## Meta-check — did this session's own mechanism miss a kind of drift?

**Yes, and it is the same class.** S118's acceptance criteria could all have been met by
committing artifacts and writing a report; only criterion 7 ("verified with **my own**
eyes… a real browser screenshot") forced the discovery. Had that clause been written the
way chitra's own criteria were written, this session would have closed green over a
broken payload too. The lesson is not "the agent was careless" — it is that **a criterion
that can be satisfied by describing the work is worth less than one that requires
operating it.**

Second, smaller miss: the budget gate is code that never ran. Worse than untested — its
one recorded evaluation was `spent_before=0` against a $5 cap, a comparison that cannot
fail for any positive cap. Named, not hidden.

Third, caught by cold review pass 2 and not by me: **I inflated the obedience headline to
"six gates fired"** when one gate is file-backed against the agent and three of the six
fired against me, uncaptured, during closeout. In a session whose whole finding is that
unverified claims sail through green gates, that is the finding landing on its author.
Corrected in `obedience-log.md` and in the row above.

## What this changes

1. **`vajra check` / the QA station cannot keep accepting a verify script at face value.**
   A verify suite made entirely of greps should be *detectable* — every check being a
   `grep`/`test -f` over source is a measurable property of the script.
2. **The fidelity reviewer must be fed the running artifact, not only the diff.** For a UI
   deliverable, "prompt + diff" is not enough context to catch a page that does not render.
3. The repair pattern that worked here — **execute every example, then prove the check
   fails when the bug is reintroduced** — is the house standard for closing a hollow green.
