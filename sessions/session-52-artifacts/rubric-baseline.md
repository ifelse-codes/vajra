# S52 — Value gap on a HARDER task · rubric + baseline (declared BEFORE running)

## Task
Make `@chitra/core` `pnpm build` emit a real publishable dist/ (ESM + CJS + .d.ts) matching package.json exports; keep zero deps, public API, 116 tests green, importable both ways.

## Baseline (chitra main @ def0cfa, captured pre-run)
- runtime dependencies: {} (zero) ✅
- `pnpm build` = `tsc --noEmit` → exit 0 (typecheck only, NO emit)
- `pnpm test` → 116/116 pass (7 files)
- packages/core/dist: does NOT exist

## Rubric (must DISTINGUISH the arms — S51's rubric was passable by both)
1. **Correctness** — after arm: `pnpm build` emits dist/index.js (ESM) + dist/index.cjs (CJS) + dist/index.d.ts;
   ESM import resolves; CJS require resolves; `pnpm test` still 116/116; `tsc` typecheck still clean.
   Score each objectively PASS/FAIL.
2. **Corrections** — founder interventions / re-work rounds needed to reach shippable (fewer = better).
3. **Constraint-adherence** — (the axis a README could not test)
   - zero runtime deps preserved (no new "dependencies")
   - public API unchanged (exports map, toPlain()/toJSON() shape, agent-output helpers kept)
   - build-time deps only added as devDependencies
4. **Cost** — authoritative total_cost_usd (from `--output-format json`), NOT the vajra receipt (S51: overstates ~9x).

## Arms
- Arm A — `vajra claude` on chitra `session-05-dist-build` (full .ai/ governance). KEPT → lands as chitra progress.
- Arm B — plain `claude` in a throwaway worktree with the Vajra layer stripped (.ai/ .claude/ CLAUDE.md varta/ darshan/ .githooks/). DISCARDED.
- Same prompt (shared-task-prompt.txt), same `--dangerously-skip-permissions`, same model (default Opus 4.8), same cost capture.

## n
S51 (n=1, README, null) + S52 (n=2, dist build). Still small. A harder-task null = a major honest signal — do not rescue.
