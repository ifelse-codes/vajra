# Session 166 — analyst-coder-gaps: fix Analyst station + Coder bash gate

> **Status:** APPROVED — founder pick A (2026-09-11, post S165 GT)

## Type
- **CODE** (~2h cap)

## Goal

Close three 🔴 findings from the S165 Ground Truth: (1) patch `check_execution_shas` in `verify-closeout.sh` to block prose/parenthetical `done:` entries (not just `done: <...>` angle-bracket placeholders); (2) ensure this prompt has proper `+`/`~`/`-` OpenSpec markers so the Analyst station PASSES for the first time since S160; (3) write the missing `sessions/session-164-summary.md` to complete S164's incomplete closeout.

## Deliverables
- Patched `scripts/verify-closeout.sh` — `check_execution_shas` blocks any `done:` line that does not carry a valid 7-40 hex-char git SHA
- `prompts/166-task-analyst-coder-gaps.md` (this file) — `## Delta` with real `+`/`~`/`-` markers so `vajra next --stations 166` shows Analyst PASSED
- `sessions/session-164-summary.md` — complete S164 closeout (3 ranked A/B/C candidates)
- `scripts/verify-session-166.sh` (exits 0; behavioral — no source-proximity greps)
- `scripts/demo-session-166.sh` (4 required markers)

## Acceptance (what must be answered — testable, EARS-style)

| AC | Criterion |
|----|-----------|
| AC1 | `vajra next --stations 166` shows Analyst PASSED (not ABSENT) |
| AC2 | WHEN `check_execution_shas` is run against a prompt whose `## Execution` has `done: (prose description)`, THEN it exits non-zero (BLOCK) |
| AC3 | WHEN `check_execution_shas` is run against a prompt whose `## Execution` has a real 7-char hex SHA, THEN it exits 0 (PASS) |
| AC4 | `sessions/session-164-summary.md` exists with exactly 3 ranked A/B/C candidates |
| AC5 | `scripts/verify-session-166.sh` exits 0; all checks are behavioral (invoke real binaries or scripts, not grep-against-source) |
| AC6 | `cargo test --lib` still passes (487 tests, non-regression) |
| AC7 | `verify-closeout.sh` exits 0 for session 166 |

## Design

design-significant: no — single bash gate fix + missing artifact; no new pipeline station or interface contract.
design-advisor: skipped — design-significant: no; fix to an existing guard pattern (same class as S163 hollow-check fixes).

## Plan

1. Write `sessions/session-164-summary.md` — complete S164's incomplete closeout with 3 ranked A/B/C candidates. covers: 4
2. Patch `check_execution_shas` in `scripts/verify-closeout.sh`: replace the `done: <` grep with a check that blocks any `done:` not followed by a 7-40 hex-char SHA; update the embedded comment. covers: 2, 3
3. Write `scripts/verify-session-166.sh` with behavioral tests: (a) prove `--check-exec-shas` BLOCKS prose `done:`, (b) prove it PASSES a real SHA, (c) prove Analyst station PASSED for session 166. covers: 5
4. Write `scripts/demo-session-166.sh` with 4 required markers. covers: 5
5. Run `cargo test --lib`, `verify-closeout.sh`; confirm exit 0. covers: 6, 7

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>
- step 5 — done: <sha — closeout commit>

## Guardrails

- Max 3 files per atomic commit.
- Do not touch `check_execution_shas` for sessions OTHER than the bash gate logic. Do not refactor unrelated checks.
- The new SHA check must remain backward-compatible: prompts with no `## Execution` section still use the existing `has_plan_steps` path (WARN/BLOCK unchanged).
- `sessions/session-164-summary.md` is a document artifact only — no code changes for the S164 closeout.

## Delta (vs ROADMAP — OpenSpec markers)

- `+` `check_execution_shas` blocks prose/parenthetical `done:` entries — closes the S165 🔴 bash gate gap
- `+` `sessions/session-164-summary.md` — completes S164's incomplete closeout
- `~` `prompts/166-task-analyst-coder-gaps.md` (this file) — first prompt since S160 GT with real OpenSpec markers in `## Delta`; Analyst station PASSES for session 166
