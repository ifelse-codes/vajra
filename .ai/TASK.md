# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 29 — Propagate the session-guard into `vajra init` (CODE) — COMPLETE

- **Type:** CODE — propagate the S26 one-session-per-chat guard into the `vajra init` scaffold (the S22/S28 `include_str!` pattern).
- **Shipped:** `src/cli/init.rs` — `TPL_HOOK_SESSION_GUARD = include_str!("../../scripts/hook-session-guard.sh")` + emit it executable + wire into `.claude/settings.json` PreToolUse(Bash) + `one_session_per_chat: true` in `TPL_CONSTRAINTS` + a new `TPL_GITIGNORE` (`.ai/.session-owner`). `Cargo.toml` un-excludes the hook. Scaffold 18 → 20 files. 4 new scaffold tests. verify-session-29.sh green (19/19). **PR [#21](https://github.com/ifelse-codes/vajra/pull/21) — open (merge after closeout).** Closes the S28 split; propagation arc (S22+S28+S29) complete.

Between sessions. Next: read `prompts/30-task-ground-truth.md`.

## Next Session

Read prompt: `prompts/30-task-ground-truth.md` — **S30 GROUND-TRUTH (NO-CODE)**, lead lens = the **founder-satisfaction gate**: is Vajra-on-Claude now satisfying enough to promote the second agent? Runs all required audits (vision/roadmap/state/knowledge/constraints/constitution/cost) + the meta-check. No code, no commits, no PRs. User signs off before code resumes.

## Build Queue (from ROADMAP.md, in order)

### Phases 1–3 + Varta arc + propagation — COMPLETE
1–13 + propagation. ~~claude · init · check · next --advance · budget guard · next e2e · Varta v0 · co-pilot loader · scaffold propagation · first-run aha · render `.ai/`→.varta · installer · maturity · legacy cleanup · pre-run estimate · chat-guard · Darshan · Darshan-in-init · guard-in-init~~ — DONE (S07–S29).

### Next leap (re-ranked S26 — founder override of the S25 audit)
1. ~~**Enforce one-session-per-chat**~~ — DONE (S26).
2. ~~**Darshan — human-facing glanceable output skill**~~ — DONE (S27).
3. ~~**Propagate Darshan into `vajra init`**~~ — DONE (S28).
4. ~~**Propagate the session-guard into `vajra init`**~~ — DONE (S29). Propagation arc complete.
5. **S30 = ground-truth (NO-CODE)** — founder-satisfaction gate lead lens.

### Backlog (parked until founder declares Vajra-on-Claude "satisfying")
- **Add second agent (Codex/Cursor)** — the north-star gap (S25), **owner-gated**. S30 GT decides the gate.
- **Dogfood / verification session** — now unblocked (propagation arc complete); strong post-GT candidate.
- **North-star breadth indicator** (RED until ≥2 agents) — S25 meta-finding.
- Audit ledger v2 · third agent · policy/governed-memory/MCP.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (next = S30) — audits **direction + discipline** drift.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** (enforced by `hook-session-guard.sh`, now in `vajra init` too).
