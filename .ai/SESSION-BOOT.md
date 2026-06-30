# Session Boot

## Current Session
- **Number:** 31 — COMPLETE
- **Type:** CODE — dogfood / verification (became **docs-only**, option C: findings recorded, no code fix).
- **Branch:** `session-31-dogfood-verification`
- **Date last updated:** 2026-06-30

## Repo State Snapshot
- `.ai/SESSION` = 31.
- `main`: includes up to Session 29 (PR #21 merged, commit `8c3c832`). S30 = NO-CODE GT (closeout on exempt branch, no PR). S31 docs-only on `session-31-dogfood-verification`.
- Remote: `origin` → `https://github.com/ifelse-codes/vajra`.
- This session: **first real `vajra claude` usage since S07.** Ran the real loop against an existing TS pnpm monorepo (`chitra`) — `vajra init` + a "learn the codebase" session. **Gate verdict: DO NOT promote the second agent.** Three shipped `[x]`-done features are dead in the real loop (the S30 false-green shape, proven 3×), **ranked by daily satisfaction:** (1) **Darshan not obeyed** (prose pointer, never enforced — agent dumps walls of text, felt every reply); (2) **compression never fires** on real CC (adapter `HookInput` camelCase vs real CC snake_case top-level — pinned against a captured payload; low daily $ impact); (3) **brownfield onboarding unguided** (init works on existing repos but no learn-the-codebase session; hooks pollute the project's own `scripts/`). **Meta-finding:** 2 of 3 are Vajra violating its own "enforcement, not prompts" wedge. Report: `sessions/session-31-summary.md`; detail in `.ai/KNOWLEDGE.md` S31.
- **Decision this session:** record findings (option C, docs only); fix the core before the second agent; **S32 = Darshan enforcement first** (most-felt).

## Next Session
- **Number:** 32
- **Type:** CODE — **Darshan enforcement** (S31 finding #1, founder-ranked first). Make the agent actually load + follow `darshan/SKILL.md` every session (it currently dumps walls of text). Minimum: surface it in the `SessionStart` boot packet so it loads each session; design stronger enforcement (a hook can't read the agent's prose — design-bearing). Move Darshan from *advised* → *enforced*. One story, ≤3 files.
- **Read prompt:** `prompts/32-task-darshan-enforcement.md`
- **Branch:** `session-32-<slug>` (from `main`).

## Carry-Forwards
- **Fix the core before breadth** — second agent stays parked; gate is now MEASURED → do not promote until the 3 core breakages are fixed.
- **Order is by satisfaction, not fix-ease:** S32 Darshan enforcement (#1) · then compression schema fix (#2, exact 2-file fix vs the captured payload) · then brownfield onboarding (#3).
- **Compression fix is pre-pinned:** remove `rename_all="camelCase"` from `HookInput` only; keep it on `HookToolResponse`; add a regression test from a verbatim captured real CC payload (KNOWLEDGE S31).
- **Meta-finding to carry:** every fix must move the feature from *advised* → *enforced* (Vajra's own wedge).
- **S31 docs-only** — open a PR for the doc updates or fold into S32. PR-status "drift" stays retired (do not re-flag).
