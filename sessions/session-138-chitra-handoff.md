# S138 — Founder handoff: run the real dogfood inside chitra

**Goal:** lock chitra's `heatmap` chart to the family design language, via a `vajra claude` session
run **from inside chitra** — the corrected method (S137 ran it the wrong way). You drive it
interactively; I (this Vajra chat) recorded the baseline and will record the evidence when you report
back.

**Baseline captured (read-only, for the byte-identical restore proof):**
- chitra session-16 branch HEAD: `462a27b`
- session-16 tracked-WIP tree sha: `1c27670022b52acd800501d0473b26db56aff7a4`
- untracked (left in place, harmless): `.commandcode/`, `prompts/16-task-sparkline-histogram-lock.md`,
  `sessions/mudra-chart-review-2026-08-26.md`

---

## Step A — Park session-16 WIP (in a chitra terminal). Reversible.

```bash
cd /Users/suman/playground/chitra
git stash push -m "VAJRA-S138-PARK: session-16 sparkline+histogram WIP"
git status --short   # tracked WIP should be gone; only the 3 untracked paths remain
```

## Step B — Start the native chitra session on a clean base

```bash
git checkout main
git log --oneline -1        # expect the scatter merge (PR #19) at/near HEAD
vajra claude
```

Let chitra's own session create its branch and run its own workflow (its hooks, its fleet, its
`.ai/`). Do NOT hand-create the branch if chitra's constitution has the agent do it.

## Step C — Paste this brief into the interactive chitra session

> Lock the `heatmap` chart to chitra's reference/panel design language — the same family the scatter
> chart joined at session 17. Follow chitra's own constitution and workflow (dispatch chitra's crew
> as its rules require; the design-advisor proposes the visual details first, I sign off on the
> render). Reference the locked contract in `packages/core/README.md` (the scatter / bar / line
> LOCKED blocks) and the locked renderers (`packages/core/src/charts/scatter.ts`, `bar.ts`,
> `line.ts`). Adapt the family rules onto a grid/matrix:
> - dashed panel frame (`┌╌…╌┐`), uppercase letter-spaced eyebrow, the `│`/`+` guide language, and
>   the `│ ╌…╌ │` rule separators;
> - the intensity ramp IS the documented grey ramp `#ECECEF → #C6C6CE → #A4A4AE → #6A6A75`, with the
>   **one accent hue spent exactly once** on the single most salient cell (the max-value cell) — never
>   a `theme.colors[i % n]` rainbow;
> - a summary footer of facts true for arbitrary matrix data (e.g. `rows·cols · min..max · peak
>   (r,c)`), peak in accent — propose it, I lock it;
> - empty/degenerate grids render safely (framed panel, no `Infinity`/`NaN`).
> Edit `packages/core/src/charts/heatmap.ts` and the spec in `scripts/chart-specs.ts`; regenerate
> previews with `pnpm gen:charts` (never hand-edit generated previews); add a `### LOCKED: heatmap
> chart — session NN design` block to `packages/core/README.md`; add falsifiability tests
> (`packages/core/tests/heatmap.test.ts`) asserting the accent appears exactly once and the ramp is
> the documented grey ramp. Keep every subagent dispatch tight — NAMED FILES, never "read the repo"
> (I'm on a $20/month plan). Verify chitra's own pipeline is green before you finish.

## Step D — Sign off (seen, not read)

Render the locked heatmap and LOOK at it. Only lock it if it matches the family language. Your verdict
is the acceptance criterion, not a diff.

## Step E — Restore session-16 afterward

```bash
git checkout session-16-sparkline-histogram-lock
git stash pop
# byte-identical check: the tree sha below must equal 1c27670022b52acd800501d0473b26db56aff7a4
git rev-parse "$(git stash create x)^{tree}" 2>/dev/null || echo "nothing to stash-create (clean)"
```

---

## Report back to THIS Vajra chat (so I can record S138's evidence)

1. **chitra branch + commit shas** the heatmap lock landed on.
2. **Which of chitra's hooks fired** (any `[copilot]`/guard/boot output you saw), and **which fleet
   roles were dispatched** (tech-lead? design-advisor? others?) — and did the advice **change the
   work**?
3. **Any gate that blocked** you (a commit refused, a `--check-*` exit 1, a closeout gate).
4. **Cost:** the run is interactive, so the authoritative `$` is an honest null (S77) — but tell me if
   a `vajra` receipt printed anything. I'll compute RAW subagent tokens from the transcripts.
5. **Your design verdict** (signed off / redirected / rejected).

## ⚠ File-overlap note

The parked session-16 WIP modifies `types.ts`, `blocks.ts`, and the auto-generated docs data
(`charts.ts`, `ansi-charts.json`). The heatmap lock happens on a **different branch**, so there is no
direct conflict — `git stash pop` in Step E restores session-16's tree untouched. The docs data
regenerates cleanly on either branch. Only if the heatmap work needed to change `types.ts`/`blocks.ts`
would you see a merge later — flag it if so.
