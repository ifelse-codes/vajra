# Session 137 — PAID DOGFOOD: chitra's `scatter` chart locked to the reference language

**Type:** CODE — a paid `vajra claude` dogfood. The code landed in
`/Users/suman/playground/chitra`; this Vajra session is the wrapper (no `src/` change here).
**The first time Vajra governed a real BUILD in an outside project** (S134 was read-only review).

## What shipped (in chitra, on `session-17-scatter-lock`)

`scatter()` now carries the LOCKED reference/panel language and joins the seven already-locked
charts (pie · donut · area · line · bar · sparkline*/histogram* in flight). Three commits, each
≤3 files (chitra's cap), off the roster commit `462a27b`:

| sha | what |
|-----|------|
| `bc760f1` | lock scatter() (renderer + `ScatterPlotOptions.eyebrow`/`.highlight` + README `LOCKED: scatter — session 17`) |
| `0af7317` | regenerate the scatter preview (DERIVED — `pnpm gen:charts`, scatter-only diff) |
| `5949192` | 14 falsifiability tests (the accent-once RGB census) |

**The design, decided WITH the founder (seen, not read):**
- **accent** = the single **max-y point of the primary series**, spent **once**; on the braille
  path it lights that point's own 2×4 **cell**, so it survives even when points share the cell.
  Everything else → the documented grey ramp `#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`. No
  `theme.colors[i%n]` rainbow. Optional `highlight` index overrides which point.
- **footer** = `n <count> · x <min>..<max> · y <min>..<max> · peak (<x>, <y>)`, peak in accent.
  **No Pearson r** — dishonest for non-linear / multi-series / zero-variance clouds.
- family chrome: dashed frame · eyebrow (`CORRELATION`) · `+`/`│` guide · two rule separators.
- empty / single-point / all-equal-y all render honestly (no `Infinity`/`NaN`).

**Founder signed off** on the rendered chart (color HTML + terminal), matching the locked language.

**Post-review refinement (chitra `38e5593`, with the founder, after seeing scatter on 609 real
Olympic athletes across 3 sports):** the founder judged that a single accent DOT is meaningless
once there are multiple series, so the rule became two-mode — **single series → the peak point;
multiple series → the whole primary GROUP is the accent hero** (all its points in accent, on top,
others grey; the footer names the group). A y-axis decimal fix rode along (fractional data like
heights `1.33..2.10` was collapsing to `2 2 1 1` — a real bug the dense-data test surfaced). chitra
tests (14/14) + README + previews updated; `verify-session-137.sh` now tests the group rule
(still 10/10). This is the dogfood working exactly as intended: real data drove a real design fix.

## What the governance actually did (the point of the dogfood)

- **The full ten-role crew is real in chitra, and this session USED it** — the first evidence, not
  just the roster. The **tech-lead was dispatched FIRST and its verdict bound**: 6 required
  (design-advisor, implementation-advisor, qa-specialist, demo-producer, fidelity-reviewer,
  release-coordinator), 3 reasoned-skip (researcher, requirements-analyst, plan-advisor).
- **The advice CHANGED the work** (the S133 open question — a mandate proves a dispatch, not
  influence — got its first data): the design-advisor's max-y accent + no-`r` footer were adopted
  verbatim; the implementation-advisor's single-**cell** accent (not line's 3-wide cap), the
  frame-first width math, and the empty-data guards all shaped the code as written. Neither was
  decorative.
- **Enforcement that fired:** Vajra's own co-pilot hook blocked the first chitra commit until
  `.ai/STATE.md` was loaded (advisory gate, real). chitra's own commit guard did **not** fire —
  this session runs in the Vajra project dir, so chitra's PreToolUse hooks are out of scope; the
  chitra 3-file cap and approval were obeyed by discipline, not by chitra's live hook. **Recorded
  as a finding, not a pass:** governing another repo's build from this repo's session means that
  repo's hooks do not protect it — only the operator's discipline does.

## Receipt (S134 discipline)

- **Authoritative $ = honest NULL.** This was an **interactive** `vajra claude` run; the on-disk
  transcript carries no `total_cost_usd` (that field rides only the headless `-p` result stream —
  the exact S77 root cause, recurring). No fake dollar figure is published.
- **RAW subagent tokens = 486,695** across 3 advisory dispatches (from
  `~/.claude/projects/*/*/subagents/agent-<id>.jsonl`, the files `vajra meter` folds):
  tech-lead 100,278 · design-advisor 211,303 · implementation-advisor 175,114. The tool-results'
  `subagent_tokens` line reported only **112,301** — the new-tokens-only figure understates the
  RAW by **~4.3×** (the S134 45× / S135 20× trap; the RAW is the honest number). Well inside the
  tech-lead's ~3.35M allowance; the four closeout roles add to this and are reported in the review.

## chitra proved UNDISTURBED (S134 four ways)

Captured BEFORE any write, re-proven byte-identical AFTER the build + stash restore:
- session-16 HEAD `462a27b…` unchanged · working-tree tracked-diff sha `25c82ddb…` **identical**
  (all 8 per-file blob hashes matched) · the older `kilo WIP` stash intact · `main` `12531f1…`
  unchanged · only the intended `session-17-scatter-lock` branch added.
- The founder's in-flight session-16 (sparkline/histogram) work was `git stash`-parked as
  `VAJRA-S137-PARK` and restored to the exact bytes; the founder chose this path at session start.

## Verify

`scripts/verify-session-137.sh` — **10 checks (6 EXEC · 3 STRUCT · 1 BEHAV), all FAIL-on-absent
(S69), 10/10 green, run live at close.** Renders chitra's real locked scatter from a throwaway
`session-17` worktree (zero-dep, via tsx), **runs chitra's own 14 committed scatter tests live**
against that worktree, and asserts the undisturbed baseline. The cold `fidelity-reviewer` returned
**ACCEPT**; its fakest-green catch (the live-vitest check had been dropped, not fixed — the S129
registered-not-run pattern) was **closed in-session** by the live-test check, moving criterion 2
from PARTIAL to SHIPPED (5 of 5). See `sessions/session-137-review.md`.

## The finding this repo could not have written itself — CORRECTED (founder, post-close)

**Original framing (now retracted):** "the Coder/Execution gate is single-repo; a dogfood builds in
another repo — a product gap." That was overstated.

**The honest finding: the true dogfood was never actually performed — this session was run in the
WRONG PLACE.** Vajra is meant to be run *inside* the project it governs (`cd chitra && vajra claude`),
so the whole session is a chitra session: chitra's hooks fire, chitra's fleet is dispatched, and
every check looks at chitra's evidence because chitra is the project it runs in. **That is not what
happened.** This session ran **inside the Vajra repo** and reached into chitra from the outside with
plain `git`/file commands — a Vajra session that poked chitra across the fence, not a chitra session
governed by Vajra. So chitra's own commit guard never fired (flagged at the time), the dispatched
fleet was Vajra's (byte-identical, but Vajra's), and the Coder gate looked in the Vajra repo because
that is where the session lived. **The cross-repo "blind spot" is an ARTIFACT of that wrong setup,
not a Vajra failure.** Run the proper way — `vajra claude` inside chitra — the Coder gate would look
in chitra, find the commits sitting right there, and pass. Analogy: I didn't find that the inspector
can't check another city's office; I sent the inspector to the wrong building, so of course his
drawer was empty. **Vajra did not fail. The dogfood method was wrong, and no real user would run it
this way.**

## Next — 3 ranked candidates (re-ordered after the correction)

1. **Run the dogfood FOR REAL: `vajra claude` INSIDE chitra.** Launch Vajra as the resident, native
   session of chitra and have it govern a chitra build from the inside — one repo, chitra's own hooks
   and fleet and gates, all evidence in chitra. Find out whether Vajra actually works as the resident
   manager of a project that isn't its own, or whether something breaks. This is the test S137 was
   supposed to be and wasn't. (highest — the honest next step)
2. **Measure advice INFLUENCE, not just dispatch (S133's open F2f).** S137 was the first session with
   data that a mandated role's advice changed the work. Build the light check that records, per rec,
   whether the `obeyed:` sha's diff actually reflects the advice — turning "was consulted" into
   "changed the result."
3. **Continue the chitra chart-lock ladder OR close the `--sync-fleet` stale-vs-edit hole (S136 🔴).**
   Either lock the next unlocked chart (more governed-build miles) or stamp each rendered role file
   with a content hash so a stale render is distinguishable from a user edit.

**Note on "make the Coder gate repo-aware":** DROPPED as a standalone candidate. It only looks needed
because of the wrong setup; if #1 is run properly the gate is fine. Revisit ONLY if running inside
chitra actually surfaces it for real.
