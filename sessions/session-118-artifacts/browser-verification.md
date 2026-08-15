# S118 step 6 — operator browser verification of the chitra S11 payload

Not the agent's self-report. Every row below was produced by loading
`http://localhost:5199/` (chitra docs dev server, `PORT=5199 BASE_PATH=/ pnpm run dev`)
and driving the real page.

**What is CAPTURED vs what is NARRATION** — a first cold review REJECTED this file for
presenting an operator's typed prose as verification evidence. That was correct. The
split now:

| Claim | Backing |
|---|---|
| the delivered page errored / the repaired page renders | **captured** — `screenshots/before-*.png`, `screenshots/after-*.png` (real PNGs) |
| all 20 examples evaluate, on all 3 renderers | **captured + re-runnable** — `mutation-proof.txt`, `mutation-test.sh` (81/81) |
| the new check is falsifiable | **captured + re-runnable** — same file, 5/81 with the defect reintroduced |
| the 20-page click-through counts (1 Ready / 19 Error) | **narration** — driven live in the browser pane, not captured to disk |
| ⌘/Ctrl+Enter re-runs; Reset left a stale preview | **narration** — live interaction, not captured |

**Screenshot capture method:** headless Chrome
(`--headless=new --screenshot --window-size=1600,1000`) against the running dev server.
The app has no URL routing, so a temporary same-origin driver page in `public/` selected
the chart inside an iframe; it was deleted after capture and is not part of any commit.
The BEFORE shots were taken by checking out the run's own `e9ce6b8` version of
`CatalogPage.tsx`, capturing, and restoring (verified: 0 modified files afterward).

## Pass 1 — as delivered by the governed run (commit `e9ce6b8`)

**Captured:** `screenshots/before-bar-chart.png`, `screenshots/before-sparkline.png` —
both show the red `Error` pill, the error block, `exit 1` in the footer, and the
`"tok-kw">import` markup leak on line 1.

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

## Pass 2 — after the operator repair (`6fa1d67`, `68bfc51`, `fd8a5fd`, `46117df`)

**Captured:** `screenshots/after-bar-chart.png`, `after-sparkline.png`, `after-pie-chart.png`
— `Ready` pill, rendered chart, `exit 0`, clean syntax colouring.

| Result | Count |
|---|---|
| `Ready` (renders) | **20 of 20** |
| `Error` | 0 |

- No `tok-*` class name appears as visible buffer TEXT any more. (The highlighter still
  emits `tok-*` classes by design — the fixed defect was those class fragments being
  rendered as literal characters. The `before-*.png` / `after-*.png` pair shows this
  directly on line 1.)
- Edit → Run: changing `title: "Monthly Sales"` to `"PATCHED Sales"` in the bar buffer and
  pressing ▶ Run changed the preview heading to `PATCHED Sales`, `exit 0`.
- **⌘/Ctrl+Enter works.** An earlier report that it did not was wrong: the synthetic
  keypress sent by the browser-automation tool did not carry `metaKey`. A dispatched
  `KeyboardEvent{key:"Enter", metaKey:true}` fires the handler (`defaultPrevented: true`)
  and re-runs — buffer `KEYTEST` → preview `KEYTEST Sales` without touching the Run button.
- Deliberate syntax error → caught, red error block, `exit 1`, page did not crash.

## Falsifiability of the new check

`artifacts/chitra-docs/scripts/check-catalog-examples.ts` executes all 20 examples against
all 3 renderers plus a deliberately broken buffer — **81 checks**. Reintroducing the
`applyOverrides` brace defect drops it to **5/81**, failing on exactly the 19 charts that
were broken. Captured in `mutation-proof.txt`; re-runnable via `mutation-test.sh`, which
restores the file under a trap and prints the post-restore git status.

The renderer sweep originally ran on `CHARTS[0]` only — the `line` chart, the one chart
that survived the defect because it already declared a `renderer` key and never took the
broken injection path. A cold review caught that; the sweep now covers every chart
(`46117df`).

**Still unchecked by any automated test:** the highlighter markup-leak fix and the
Reset-re-runs-the-preview fix. Both live in React render/handler code the headless script
never touches; both are evidenced only by the before/after screenshots.

## Criterion map for the chitra S11 brief (operator verdict)

| # | Criterion | As delivered by the run | After repair |
|---|---|---|---|
| 1 | two-panel view for every chart | **PARTIAL** — shell yes, content broken on 19/20 | SHIPPED |
| 2 | vim-styled buffer | **PARTIAL** — all features present, but markup leaked as text | SHIPPED |
| 3 | terminal preview panel | SHIPPED | SHIPPED |
| 4 | Run executes in-browser; errors caught | **PARTIAL** — genuinely live, but invalid JS for 19/20 | SHIPPED |
| 5 | toolbar (run/copy/download/renderer/theme/reset) | **PARTIAL** — Reset left a stale preview | SHIPPED |
| 6 | tests + typechecks + drift gate green; core untouched | SHIPPED | SHIPPED |
| 7 | verify + demo exit 0 | **PARTIAL** — the scripts did exit 0, but 14/14 green on a broken page means the suite proved nothing (hollow) | SHIPPED (15/15, one check now executable) |
| 8 | summary maps every criterion; independent review | **NOT-BUILT as specified** — the map was wrong on 4 of 8 rows and the "independent" review passed it | corrected by operator addendum |

The repair was done by the **operator**, not by the governed run. Stated plainly so the
run is not credited with work it did not do.
