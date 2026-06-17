# Session 00 — Discovery & Scaffolding

## Trigger
User asked to read source-material, understand agent-first-workflow-bootstrap.md, and install the dev scaffold in this repo.

## Goal
Install complete AI-collaboration scaffold. No product code.

## Deliverables
- [ ] `.ai/` directory with 8 core files
- [ ] Root pointers: `AGENTS.md`, `CLAUDE.md`, `.cursorrules`
- [ ] Hook system: 6 `scripts/hook-*.sh` + `ai-session` wrapper
- [ ] Tracked git hooks: `.githooks/pre-commit`, `pre-push`
- [ ] Verify scripts: `verify-closeout.sh`, `verify-session-template.sh`, `init-session.sh`, `rollback-closeout.sh`
- [ ] Session 00 audit pair: this file + `sessions/session-00-summary.md`

## Constraints Operative
- No product code. No dependencies. No framework choices.
- Max 2 assumptions across whole scaffold.
- Every file referenced by at least one other file (no orphans).
- File limit: 250 lines max (AGENTS.md may exceed but stay <500).

## Decisions Made
- Ground truth cadence: every 5 sessions (configurable)
- Max files per commit: 3
- Session cap: ~2 hours
- Use jq for JSON parsing in hooks (from factory-session-kickoff-prompt.md)
- Include cost tracking section in STATE.md

## Exit Criteria
- `verify-closeout.sh` exits 0 with 8/8 PASS.
- All hooks executable.
- Git hooks activated: `git config core.hooksPath .githooks`.

## Explicit Non-Goals
- No CI setup (L1 deferred).
- No remote setup (L0 deferred).
- No product architecture decisions.
