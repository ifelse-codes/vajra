# Session Boot

## Current Session
- **Number:** 129 — COMPLETE
- **Type:** CODE — one source for what a stranger gets. Founder pick **A** at the S128 closeout,
  chosen in plain English over the first-contact residuals (B) and a paid ride-along (C).
- **Goal:** make what `vajra init` hands a stranger a DERIVED artifact of what this repo runs on,
  and make it impossible for the two to silently drift again.
- **Verdict:** **ACCEPT on TWO independent cold passes.** A second pass was run because the work
  done after pass 1 was substantive — shipping pass 1's verdict over changed code would have been
  dishonest. **Pass 2: 14 SHIPPED · 2 PARTIAL · 0 NOT-BUILT.** 17 recommendations across both
  passes: **16 obeyed, 1 refused with a reason.** Report: `sessions/session-129-summary.md`.
  Both reviews: `sessions/session-129-review.md`. Measurement: `sessions/session-129-fork-measurement.md`.
- **What a stranger gets now:** **13 of 13** binding rules (was 8, two of them renamed so equality
  was never checkable) · **10 of 12** ground-truth audits (was 7) · **7 of 7** drift axes (was 6,
  and nobody knew) — all DERIVED at build time by `build.rs`. **The default is CARRIED**, so a rule
  added here reaches every future scaffold with no action taken; deviating needs a declared reason
  that **ships into the stranger's own file**; a stale declaration **panics the build**.
- **The guard that was missing for 128 sessions:** `scripts/scaffold-drift.sh` — real empty dir,
  real `git init`, the real release binary, three inventories, both directions, and **a GREEN line
  that states its own jurisdiction**. `scaffold_drift_check` is the 12th required GT audit.
- verify **12/12** · demo **15/15** · drift **17/17** · stranger **21/21** (was 16) · fixture
  **18/18** (7 plants + a control) · **365** tests · `K of 8` unmoved · **7 commands**, no 8th.

**🔴 BOTH COLD READERS FOUND A FORK THE BUILDER HAD MISSED, INSIDE THE BLAST RADIUS OF THE FIX.**
Pass 1 found `drift_axes` (6 vs 7, *three lines above the derived include*) — fixed in-session.
Pass 2 found **the FOURTH fork**: `TPL_CONSTRAINTS` hand-types a family of twins of live
`.ai/CONSTRAINTS.yaml` keys, **two already WRONG in a stranger's file** — `communication.forbid`
ships 4 of our 5, and `commit.forbid_skip_hooks` is absent **while `src/varta/render.rs:84` reads
it**. **REFUSED in-session** (it needs a KEY-SET inventory, not a fourth list comparison; and
hand-patching would put fresh hand-typed content into the session that removed it), named in four
places, and it is the **S131 candidate A**.

**🔴 UNPLANNED, AND THE THING TO CARRY FORWARD:** running `vajra next --check-plan` at close showed
it had been **mis-parsing every prompt** since the heading `## Plan (ordered — cite the acceptance
criteria each step covers)` was adopted — the acceptance parser matched on `contains("acceptance")`,
so plan steps were counted as criteria. **The Planner station in `K of 8` reported PASSED off that
parser.** Fixed at the source with a falsifiable test. **A registered gate nobody executes is not a
gate.**

**Fakest green (pass 2's call, adopted over the builder's):** the drift check's jurisdiction is
defined by the thing it audits — its GREEN can never go red outside the three derived lists. The fix
shipped is **honesty, not coverage**.

**Still true for a stranger:** `vajra init` blocks on stdin without EOF · their first `vajra check`
exits 1 · **0 stars · 0 forks · 0 issues · 19 downloads, unchanged.**

## Repo State Snapshot
- `.ai/SESSION` = 129.
- Last paid dogfood: **S124, `$3.2985`** (`vajra next --dogfood-age` is the live query — never
  STATE.md).
- Two product-facing audits registered, **neither ever run BY a ground truth**.

## Next Session
- **Read prompt:** `prompts/130-task-ground-truth.md`
- **Session 130 is the MANDATORY NO-CODE GROUND TRUTH** (`130 % 5 == 0`), auditing S126–S129, and
  **the first GT that must RUN `stranger_check` and `scaffold_drift_check` live.** No `src/` edits,
  no commits on its own branch — closeout rides `session-130-closeout`.
- Its two sharpened lenses: **is nine roles a fleet or a roster** (S128 and S129 each reached for
  exactly one), and **is one-cold-pass-at-close the right review shape** when two read-only passes
  each found a fork the builder missed.
- Three ranked candidates for **S131** are carried in the summary and the GT prompt; the founder
  picks at the S130 closeout.

**New chat.**
