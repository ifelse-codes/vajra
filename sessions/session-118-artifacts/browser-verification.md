# S118 step 6 — operator browser verification of the chitra S11 payload

Not the agent's self-report. Every row below was produced by loading
`http://localhost:5199/` (chitra docs dev server, `PORT=5199 BASE_PATH=/ pnpm run dev`)
and driving the real page.

## Pass 1 — as delivered by the governed run (commit `e9ce6b8`)

Clicked all 20 chart pages, recording the status pill each time:

| Result | Count | Charts |
|---|---|---|
| `Ready` (renders) | **1** | line |
| `Error` | **19** | bar, area, sparkline, histogram, scatter, pie, donut, heatmap, progress, gauge, horizontalBar, timeline, radar, boxplot, waterfall, funnel, candlestick, treemap, sankey |

Error messages observed: `missing ) after argument list` (most charts),
`Unexpected token ';'` (sparkline).

Also observed:
- The syntax highlighter printed its own markup as buffer text — line 1 read
  `"tok-kw">import { line } "tok-kw">from "@chitra/core";`
- `↺ Reset` restored the buffer but left the previous (often errored) preview on screen.
- Live evaluation **was** genuinely live: replacing the buffer with a hand-typed program
  produced a real caught error and `exit 1`, so the page executes code rather than
  replaying a stored string.

## Pass 2 — after the operator repair (`6fa1d67`, `68bfc51`, `fd8a5fd`)

| Result | Count |
|---|---|
| `Ready` (renders) | **20 of 20** |
| `Error` | 0 |

- Token-leak elements in the DOM: **0** (the only `tok-` match left is the stylesheet rule).
- Edit → Run: changing `title: "Monthly Sales"` to `"PATCHED Sales"` in the bar buffer and
  pressing ▶ Run changed the preview heading to `PATCHED Sales`, `exit 0`.
- **⌘/Ctrl+Enter works.** An earlier report that it did not was wrong: the synthetic
  keypress sent by the browser-automation tool did not carry `metaKey`. A dispatched
  `KeyboardEvent{key:"Enter", metaKey:true}` fires the handler (`defaultPrevented: true`)
  and re-runs — buffer `KEYTEST` → preview `KEYTEST Sales` without touching the Run button.
- Deliberate syntax error → caught, red error block, `exit 1`, page did not crash.

## Falsifiability of the new check

`artifacts/chitra-docs/scripts/check-catalog-examples.ts` executes all 20 examples, all 3
renderers, and a broken buffer. Reintroducing the `applyOverrides` brace defect drops it
from **24/24 to 5/24** — failing on exactly the 19 charts that were broken. It is a real
check, not another grep.

## Criterion map for the chitra S11 brief (operator verdict)

| # | Criterion | As delivered by the run | After repair |
|---|---|---|---|
| 1 | two-panel view for every chart | **PARTIAL** — shell yes, content broken on 19/20 | SHIPPED |
| 2 | vim-styled buffer | **PARTIAL** — all features present, but markup leaked as text | SHIPPED |
| 3 | terminal preview panel | SHIPPED | SHIPPED |
| 4 | Run executes in-browser; errors caught | **PARTIAL** — genuinely live, but invalid JS for 19/20 | SHIPPED |
| 5 | toolbar (run/copy/download/renderer/theme/reset) | **PARTIAL** — Reset left a stale preview | SHIPPED |
| 6 | tests + typechecks + drift gate green; core untouched | SHIPPED | SHIPPED |
| 7 | verify + demo exit 0 | **hollow** — 14/14 green on a broken page | SHIPPED (15/15, one check now executable) |
| 8 | summary maps every criterion; independent review | **NOT-BUILT as specified** — the map was wrong on 4 of 8 rows and the "independent" review passed it | corrected by operator addendum |

The repair was done by the **operator**, not by the governed run. Stated plainly so the
run is not credited with work it did not do.
