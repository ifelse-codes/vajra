# Session Boot

## Current Session
- **Number:** 34 — COMPLETE
- **Type:** CODE — Brownfield onboarding (S31 finding #3, last of the three core breakages).
- **Branch:** `session-34-brownfield-onboarding`
- **Date last updated:** 2026-07-02

## Repo State Snapshot
- `.ai/SESSION` = 34.
- `main`: includes up to Session 33 (PR #27 merged). S34 on `session-34-brownfield-onboarding`, PR [#29](https://github.com/ifelse-codes/vajra/pull/29) open.
- Remote: `origin` → `https://github.com/ifelse-codes/vajra`.
- This session (three-part story, one story): **(1) Session-0 onboarding** — `vajra init` detects a brownfield repo (`is_brownfield()`: any root entry the scaffold doesn't own) and boots it into session 00 with a guided study-the-repo brief (`prompts/00-task-brownfield-onboarding.md`) that fills KNOWLEDGE/STATE with reality before feature work; greenfield unchanged. **(2) Hook placement** — scaffolded `hook-*.sh` land in `.ai/hooks/`, never the project's own `scripts/`; settings.json template updated; verify/demo session scripts stay in `scripts/`. **(3) Auth pre-check** — `vajra claude` fails fast without credentials (env key → `~/.claude/.credentials.json` → `oauthAccount` marker → macOS Keychain; presence-only; `VAJRA_SKIP_AUTH_CHECK=1` bypasses). Closes the S18 gap.
- **Evidence:** verify-session-34.sh green (11/11) — E2E runs the built binary against real-shaped temp repos. Verified on real brownfield copies (`darpan` TS monorepo with its own `scripts/`, `TradingAgents`). Auth check verified live (Keychain pass / forced no-creds fail-fast / bypass). `cargo test` 133 pass, clippy clean.
- **Meta-rule: third instance of *advised → enforced*** (S32 Darshan, S33 compression, S34 brownfield).
- **New finding (out of scope):** brownfield repos that already have `.claude/settings.json` get it skipped on init → scaffolded hooks never wired. Needs a merge strategy; future 1-story candidate.

## Next Session
- **Number:** 35
- **Type:** **GROUND TRUTH (NO-CODE, mandated `NN % 5 == 0`)** — lead lens (founder pick A): "fix the core" bet verification + second-agent gate re-measure. `dogfood_check` will flag ~$0 spend since S31 — an "unmeasured" verdict teeing up an S36 dogfood is the honest likely outcome.
- **Read prompt:** `prompts/35-task-ground-truth-gate-remeasure.md`
- **Branch:** `session-35-ground-truth` (from `main`). No code, no commits, no PRs.

## Carry-Forwards
- **All three S31 core breakages closed** (S32 #1 Darshan, S33 #2 compression, S34 #3 brownfield). Second agent stays parked until the founder clears the gate — S35 re-asks it.
- **Open advised-mode gaps for S36 ranking:** `.claude/settings.json` merge (S34 finding); `cargo`/`npm`/`pytest` `exit_code == Some(0)` heuristics (S33 finding); obedience-metric/pace-notes backlog (2026-07-01); a real dogfood run.
- **Meta-rule held 3×:** every fix moves a feature *advised → enforced* — Vajra's own wedge.
