# chitra Session 11 — the catalog page: two-panel terminal editor + live terminal preview

## 0. Governance preamble (read before you touch anything)

You are running inside `/Users/suman/playground/chitra`, a **Vajra-governed repo**.

1. STOP and read, in order: `.ai/AGENTS.md`, `.ai/SESSION`, `.ai/SESSION-BOOT.md`, `.ai/TASK.md`,
   `.ai/STATE.md`, `.ai/CONSTRAINTS.yaml`. Obey them. They outrank convenience.
2. This is **chitra session 11**. `git checkout -b session-11-catalog-two-panel` from `main` **first**.
   Never work on `main`.
3. Your **first deliverable** is `prompts/11-task-catalog-two-panel.md`, written from this brief
   (chitra's rules require the session prompt file to exist, with `## Plan` steps carrying
   `covers: N` markers and a `## Design` marker).
4. Commits require the un-forgeable marker: `VAJRA_ALLOW_COMMIT=11 git commit ...`. Max 3 files per
   atomic commit. Never `--no-verify`.
5. **Do NOT push. Do NOT open a PR. Do NOT publish anything.** Finish locally on the branch and stop.
   The founder reviews the UI in a browser before anything leaves this machine.
6. No new external npm dependencies. The one dependency you MAY add is the workspace-internal
   `@chitra/core` (`workspace:*`) into `artifacts/chitra-docs`. Everything already in the docs
   `package.json` is fair game (`react-resizable-panels` is already there and is the right tool for
   the split).

## 1. Goal

Rebuild the chitra docs site's chart catalog (`artifacts/chitra-docs`) so every chart is presented
the way TanStack Charts' catalog presents one: **a single page, two panels side by side** — code on
the left, live preview on the right. Reference: <https://tanstack.com/charts/catalog/charts/55-indexed-multi-line>.

But chitra is a *terminal* chart library, so both panels are terminal-native, not web-native:

- **Left = a vim/neovim buffer in a terminal**, not a web code box.
- **Right = a terminal window** showing the program's real output.

## 2. LEFT PANEL — the vim-styled editor

- **Chrome:** a thin top strip with a breadcrumb path (`▸ catalog/<chart-id>/example.ts`) and
  **file tabs** styled as terminal buffer tabs (not browser tabs): `example.ts` (active),
  `data.ts`, `output.txt`. Tabs switch the buffer.
- **Buffer:** monospace; right-aligned **dim line-number gutter**; a subtle **current-line
  highlight**; `~` tilde markers on every row past end-of-file (the neovim empty-buffer signature);
  a **block cursor**.
- **Syntax highlighting** for TypeScript — keywords, strings, numbers, comments, identifiers —
  coloured from the active chart theme's palette. Use a small hand-rolled tokenizer; do NOT pull in
  a heavyweight editor package.
- **Vim modeline** pinned to the bottom of the panel: mode indicator (`-- NORMAL --` flipping to
  `-- INSERT --` while the user types), the file path, the filetype, `Ln n, Col n`, and a percentage
  position — same information a real neovim statusline carries.
- **The buffer is EDITABLE.** Typing into it is the input to the live re-run (§4).

## 3. RIGHT PANEL — the terminal preview

- **Chrome:** a terminal title bar carrying the chart title and a **status pill** — `Ready` /
  `Running…` / `Error` — mirroring the "Ready" chip in the reference screenshot.
- **Body:** a shell prompt line (`$ tsx example.ts`), then the chart output rendered from ANSI
  through the existing `artifacts/chitra-docs/src/ansi.ts` `ansiToHtml` helper.
- **Footer:** a status line — `[exit 0 · <n>ms · renderer=<r> · theme=<t>]`. On failure: a red error
  block with the real message and a non-zero exit line.

## 4. THE LIVE RE-RUN (explicitly picked by the founder — do not fake this)

Pressing **Run / Refresh** must **actually execute chitra code in the browser** and re-render the
right panel from that execution. Re-displaying a pre-generated string is a FAIL.

- `@chitra/core` is browser-safe (verified: no `node:` built-ins, no `fs`/`path`/`child_process`
  imports anywhere in `packages/core/src`). Import it into the docs bundle and call it at runtime.
- **Editing the left buffer and pressing Run must change the right panel.** Implement a bounded
  evaluator: strip `import` lines from the buffer, evaluate the remaining source with `new Function`
  with the chitra chart API and the demo data injected into scope, and take the resulting chart
  string. **No network, no remote code, no `eval` of anything fetched.**
- Runtime and syntax errors must be **caught** and shown inside the preview panel (red, real
  message, non-zero exit line). The page must never crash or white-screen.
- **Cmd/Ctrl+Enter runs.**

## 5. TOOLBAR (these options, not more)

| Control | Behaviour |
|---|---|
| ▶ Run / ⟳ Refresh | re-executes the buffer (§4) |
| ⧉ Copy | copy code · copy rendered output |
| ⇩ Download | the example source as `.ts`, the rendered output as `.txt` |
| Renderer | `braille` · `blocks` · `ascii` — re-runs on change |
| Theme | the 7 existing themes — re-runs on change |
| ↺ Reset | restore the pristine example |
| Status pill | `Ready` / `Running…` / `Error` |

## 6. Scope and invariants

- **One catalog page component, used by ALL charts** in `src/data/charts.ts` (20 of them). No chart
  left behind on the old layout.
- **Do NOT change any chart output in `packages/core`.** The S09 circular and S10 line design
  language is LOCKED. This session is a docs-site presentation change.
- These must stay green: `pnpm --filter @chitra/core run test`, `pnpm --filter @chitra/core run
  typecheck`, the docs `typecheck`, and `pnpm gen:charts:check` (the chart drift gate).

**Priority order if you run short on budget or time** — land each fully before starting the next,
and state plainly what you did not reach:

- **P1** two-panel shell + vim-styled editable buffer + terminal preview, across all charts
- **P2** the toolbar (run/copy/download/renderer/theme/reset + status pill)
- **P3** live in-browser re-execution of the edited buffer

## 7. Acceptance criteria (numbered, testable)

1. `artifacts/chitra-docs` renders a **two-panel** catalog view — code left, preview right — for
   every chart in `src/data/charts.ts`, with a resizable split.
2. The left panel is a **vim/neovim-styled buffer**: line-number gutter, current-line highlight,
   `~` past-EOF markers, block cursor, TS syntax colouring, file tabs, and a modeline that shows
   `-- NORMAL --` / `-- INSERT --`, path, filetype, and `Ln, Col`.
3. The right panel is a **terminal window**: title bar + status pill, `$` prompt line, ANSI output
   via `ansiToHtml`, and an exit/timing status line.
4. **Run actually executes chitra code in the browser**: editing the buffer and pressing Run (or
   Cmd/Ctrl+Enter) changes the rendered output; a deliberate syntax error shows a caught error
   block with a non-zero exit line instead of crashing the page.
5. The toolbar ships Run/Refresh, Copy code, Copy output, Download `.ts`, Download `.txt`, renderer
   switch, theme switch, and Reset — all functional.
6. `pnpm --filter @chitra/core run test`, both typechecks, and `pnpm gen:charts:check` are green;
   `packages/core` chart output is byte-identical to `main`.
7. `scripts/verify-session-11.sh` exits 0 and `scripts/demo-session-11.sh` exits 0 (built from the
   repo's templates, artifacts under `.ai/verify/session-11/`).
8. `sessions/session-11-summary.md` maps EVERY numbered criterion above to
   SHIPPED / PARTIAL / NOT-BUILT with evidence, states what was not built, and names the fakest
   green. An independent cold fidelity review lands at `sessions/session-11-review.md`.

## 8. Close

Stop when the branch is complete locally. **No push, no PR.** Report: what shipped, what did not,
the fakest green, and the exact commands the founder should run to see the page in a browser.
