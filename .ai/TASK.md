# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 33 — Compression schema fix (CODE) — COMPLETE

- **Type:** CODE. Fixed the S31 finding #2 root cause: compression never fired on real Claude Code.
- **Shipped:** removed `#[serde(rename_all = "camelCase")]` from `HookInput` (kept it on `HookToolResponse`; `exit_code` stays `Option`). Real CC sends snake_case top-level keys (`tool_name/tool_input/tool_response`); the old attribute silently failed to parse every real payload → `{}` passthrough since S03/S07. Reproduced the bug first (regression test against a real-shaped payload), then confirmed the fix flips it to a fold. Rewrote all pre-existing fixtures (which encoded the wrong casing) to the real shape; kept one renamed test documenting the old camelCase-top-level shape correctly fails open. `scripts/verify-session-33.sh` green (9/9).
- **Meta-rule honored:** advised → enforced, second instance (S32 was Darshan).
- **New finding surfaced, not fixed:** `cargo`/`npm`/`pytest` heuristics key off `exit_code == Some(0)` directly, not the engine's inferred success — real CC never sends `exit_code`, so those three heuristics still won't fold typical output. Out of scope; candidate for a future session.
- **PR:** pending.

Between sessions. Next: read `prompts/34-task-brownfield-onboarding.md`.

## Next Session

Read prompt: `prompts/34-task-brownfield-onboarding.md` — **S34 CODE: brownfield onboarding (S31 #3).** A guided "session 0: study this existing codebase" kickoff + rethink hook placement so scaffolded hooks don't land inside the project's own `scripts/` package + a `vajra claude` auth pre-check. One story, ≤3 files.

## Build Queue (from ROADMAP.md, in order — fix the core, ranked by satisfaction)

1. ~~Darshan enforcement (S32)~~ — **DONE.**
2. ~~Compression schema fix (S33)~~ — **DONE.**
3. **Brownfield onboarding (S34)** — finding #3.
4. **Add second agent (Codex/Cursor)** — stays parked until the core is fixed.
5. **S35 = NO-CODE ground truth** (every 5th session).

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S30; next = S35) — audits **direction + discipline** drift.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** (enforced by `hook-session-guard.sh`, now in `vajra init` too).
- **Every fix moves a feature from *advised* → *enforced*** (S31 meta-finding — Vajra's own wedge).
