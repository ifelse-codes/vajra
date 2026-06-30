# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 28 — Propagate Darshan into `vajra init` (CODE) — COMPLETE

- **Type:** CODE — propagate the S27 Darshan skill into the `vajra init` scaffold (the S22 `include_str!` pattern).
- **Shipped:** `src/cli/init.rs` — `TPL_DARSHAN = include_str!("../../darshan/SKILL.md")` + emit `darshan/SKILL.md` (byte-identical) + a **Speaking Skills (Load at Boot)** section in `TPL_AGENTS`. Scaffold 17 → 18 files. No `Cargo.toml` change (`darshan/` already ships), no 8th command, no new dep, no `src/` renderer. verify-session-28.sh green (12/12). **PR [#19](https://github.com/ifelse-codes/vajra/pull/19) — merged (`c65fc10`).**
- **Decisions:** **Darshan-only this session** (prompt's pre-authorized scope-split); the S26 **session-guard** propagation deferred to **S29**.

Between sessions. Next: read `prompts/29-task-session-guard-propagation.md`.

## Next Session

Read prompt: `prompts/29-task-session-guard-propagation.md` — **S29 CODE: propagate the S26 session-guard into `vajra init`** (`hook-session-guard.sh` via `include_str!` + settings PreToolUse wiring + `one_session_per_chat: true` + a new `.gitignore` for `.ai/.session-owner` + a `Cargo.toml` un-exclude). Closes the second half of the S28 split. **Then S30 = ground-truth (NO-CODE).**

## Build Queue (from ROADMAP.md, in order)

### Phases 1–3 + Varta arc — COMPLETE
1–13. ~~claude · init · check · next --advance · budget guard · next e2e · Varta v0 · co-pilot loader · scaffold propagation · first-run aha · render `.ai/`→.varta · installer · maturity · legacy cleanup · pre-run estimate~~ — DONE (S07–S24).

### Next leap (re-ranked S26 — founder override of the S25 audit)
1. ~~**Enforce one-session-per-chat**~~ — DONE (S26). `scripts/hook-session-guard.sh`.
2. ~~**Darshan — human-facing glanceable output skill**~~ — DONE (S27). `darshan/SKILL.md` + AGENTS.md boot pointer.
3. **Propagate Darshan + session-guard into `vajra init`** — picked S28. `prompts/28-task-init-propagation.md`.

### Backlog (parked until founder declares Vajra-on-Claude "satisfying")
- **Add second agent (Codex/Cursor)** — the north-star gap (S25), but **owner-gated**. Returns to #1 only when the founder is satisfied with Claude.
- **Dogfood / verification session** — use Varta+Darshan on a real project, log friction, fix-or-defer. Strong candidate once propagation lands.
- **North-star breadth indicator** (RED until ≥2 agents) — S25 meta-finding.
- Audit ledger v2 · third agent · policy/governed-memory/MCP.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (next = S30) — audits **direction + discipline** drift.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** (enforced by `hook-session-guard.sh`).
