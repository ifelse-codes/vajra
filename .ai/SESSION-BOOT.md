# Session Boot

## Current Session
- **Number:** 03 — COMPLETE
- **Type:** CODE — ClaudeCodeHookAdapter + wire types
- **Branch:** `session-03-hook-adapter`
- **Date last updated:** 2026-06-20

## Live URLs / Endpoints
None.

## Repo State Snapshot
- `.ai/SESSION` = 03.
- `main`: baseline + S00–S02 closeout files.
- `session-03-hook-adapter`: adapter + wire types implemented and verified. PR pending (no remote).
- Enforcement layers L2–L5 in place. L0/L1 deferred until remote + CI exist.

## Next Session
- **Number:** 04
- **Type:** CODE
- **Story:** CLI Launcher + `--settings` Injector
- **Read prompt:** `prompts/04-task-launcher.md`
- **Branch:** `session-04-launcher`

## Carry-Forwards
- Activate git hooks per clone: `git config core.hooksPath .githooks`.
- Set git user identity globally.
- Add remote to enable L0 + L1 (enables `gh pr create`).
- Resolve `LINE_CAP` discrepancy: code has 200, ADR-0003 specifies 30 — fix in S04.
