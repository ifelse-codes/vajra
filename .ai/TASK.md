# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 32 — Darshan enforcement (CODE) — COMPLETE

- **Type:** CODE. Moved Darshan *advised → enforced* (S31 finding #1, founder-ranked first).
- **Shipped:** the `SessionStart` boot hook (`scripts/hook-session-start.sh`) now prints a Darshan directive into every boot packet — one rule (inlined) + `darshan/SKILL.md` pointer + `▶ ACK NOW` speak-back. `src/cli/init.rs` embeds the canonical hook via `include_str!` (kills the pre-existing drift); `Cargo.toml` un-excludes it so it ships. `scripts/verify-session-32.sh` green (18/18).
- **Meta-rule honored:** advised → enforced. Follow-on documented (not built): a `Stop`-hook wall-of-text heuristic for machine enforcement.
- **PR:** [#24](https://github.com/ifelse-codes/vajra/pull/24).

Between sessions. Next: read `prompts/33-task-compression-schema-fix.md`.

## Next Session

Read prompt: `prompts/33-task-compression-schema-fix.md` — **S33 CODE: compression schema fix (S31 #2).** Remove `rename_all="camelCase"` from `HookInput` ONLY (keep it on `HookToolResponse`); `exit_code` stays `Option`; add a regression test from a **verbatim captured real CC payload**. Reproduce the passthrough bug BEFORE the fix, confirm the fold after. One story, ≤3 files.

## Build Queue (from ROADMAP.md, in order — fix the core, ranked by satisfaction)

1. ~~Darshan enforcement (S32)~~ — **DONE.**
2. **Compression schema fix (S33)** — finding #2, exact 2-file fix vs the captured payload.
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
