# Session 34 — Brownfield Onboarding (CODE) — Summary

## Goal achieved?

**Yes.** S31 finding #3 — the last of the three core breakages — closed, third instance of
the *advised → enforced* meta-rule. Branch `session-34-brownfield-onboarding`,
PR [#29](https://github.com/ifelse-codes/vajra/pull/29).

Three-part story (one story: "vajra onboards an existing codebase safely"):

1. **Session-0 onboarding** — `vajra init` detects a brownfield repo (any root entry the
   scaffold doesn't own → `is_brownfield()`) and boots it into **session 00**: a guided
   study-the-repo brief (`prompts/00-task-brownfield-onboarding.md`) that fills
   `KNOWLEDGE.md`/`STATE.md` with observed reality before any feature work. `SESSION`=00,
   `TASK.md`/`SESSION-BOOT.md` point at the brief; the session-01 kickoff still carries the
   user's goal. Greenfield path unchanged (session 01).
2. **Hook placement** — scaffolded `hook-*.sh` now land in `.ai/hooks/` (Vajra's lane),
   never the project's own `scripts/` package; `settings.json` template updated. Per-session
   verify/demo scripts stay in `scripts/` (contract unchanged).
3. **Auth pre-check** — `vajra claude` fails fast with an actionable message when no Claude
   Code credentials exist. Presence-only, never a paid call: `ANTHROPIC_API_KEY` →
   `~/.claude/.credentials.json` → `oauthAccount` in `~/.claude.json` → macOS Keychain
   (`Claude Code-credentials`). `VAJRA_SKIP_AUTH_CHECK=1` bypasses. Closes the S18 gap.

## Evidence (not just green tests — the S30/S31 false-green lesson)

- `scripts/verify-session-34.sh` **green (11/11)** — the E2E checks run the *built binary*
  against real-shaped temp repos: brownfield → session 00; greenfield → 01; hooks out of a
  project that has its own `scripts/`; forced no-creds → fail-fast + bypass works.
- **Real brownfield repos:** scaffolded copies of `darpan` (TS monorepo with its own
  `scripts/` package and pre-existing `AGENTS.md`/`CLAUDE.md`) and `TradingAgents` (Python).
  Both: session 00 + brief emitted, hooks stayed out of their `scripts/`, existing files
  skipped (idempotence held).
- **Auth check live on this machine:** Keychain hit → silent pass (`vajra claude --version`
  launched); fake `security` + empty `HOME` + no key → clear fail-fast, exit 1; bypass ran.
- `cargo test` 133 pass (110 lib + 23 integration), clippy clean, fmt clean.
- Commits honor the 3-file cap (verified per-commit in the verify script).

## New findings (recorded, not fixed — out of scope)

- **`.claude/settings.json` merge gap:** a brownfield repo that already has
  `.claude/settings.json` (like `darpan`) gets it **skipped** on init → the scaffolded
  hooks in `.ai/hooks/` are never wired. Needs a merge strategy (same class as the
  launcher's `--settings` merge). Future 1-story session candidate.
- Carry-forward from S33 (still open, still not S34's job): `cargo`/`npm`/`pytest`
  heuristics key off `exit_code == Some(0)`, which real CC never sends.

## Next — S35 is the MANDATED ground-truth (NO-CODE, `NN % 5 == 0`)

All three S31 core breakages are now closed (S32 Darshan, S33 compression, S34 brownfield).
S35 cannot be a code session. The options below are **lead lenses** for the audit (drawn
from ROADMAP carry-forwards); it runs all `required_audits` regardless — including
`dogfood_check`, which will ask whether real work has run through `vajra claude` since S31
(the cost ledger says: it hasn't).

### A. "Fix the core" bet verification + second-agent gate re-measure (Recommended)
- **Goal:** Verify the three fixes are *felt*, not just green — and re-ask the parked
  second-agent gate now that the core is nominally whole.
- **Why pick this:** This is the exact question S31 deferred everything for; the gate is
  founder satisfaction, and the fixes exist precisely to move it.
- **Key risk:** Zero `vajra claude` spend since S31 means satisfaction is still *unmeasured*
  — the honest verdict may be "run a dogfood first," teeing up S36 instead of clearing the gate.

### B. Enforcement-wedge audit (the meta-rule, pressure-tested)
- **Goal:** Audit every shipped feature against the wedge: which are *enforced* (hook/gate/
  fail-closed) vs still *advised* (prose an agent can ignore)? Is the S32–S34 pattern complete?
- **Why pick this:** 2 of 3 S31 breakages were Vajra violating its own wedge; the settings-merge
  gap found this session suggests the list isn't empty yet.
- **Key risk:** Produces a fix backlog, not a direction call — the second-agent question stays
  unanswered another cycle.

### C. Backlog grooming + notes compression (the claude-mem GT refinement)
- **Goal:** Order the post-GT queue (settings-merge gap, `exit_code` heuristics, obedience
  metric, second agent) and run the backlog's idea (d): compress/reorganize accumulated
  session notes so the co-pilot's memory stays small.
- **Why pick this:** Three carry-forwards now compete for S36; the GT is the sanctioned
  docs-only slot to rank them and prune note bloat.
- **Key risk:** Housekeeping lens — defers both the gate call and the wedge audit.
