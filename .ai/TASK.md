# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 22 — Scaffold propagation (CODE) — COMPLETE

- **Type:** CODE
- **Goal:** make `vajra init` emit the S20 ground-truth audits + the S21 co-pilot loader, so every scaffolded project inherits them.
- **Outcome:** `src/cli/init.rs` now scaffolds the `ground_truth:` + `copilot:` blocks (+ refreshed `approval_tokens` + `ground_truth_commit_exempt_branch_suffixes`), ships `scripts/hook-copilot-loader.sh` via `include_str!` (byte-identical to canonical — no drift), and wires it into `.claude/settings.json`. `Cargo.toml` un-excludes that one hook so `cargo install` compiles. verify-session-22.sh green (12/12); proven against a real `vajra init` into a temp dir. Report: `sessions/session-22-summary.md`. PR #12.

Between sessions. Next: read `prompts/23-task-first-run-aha.md`.

## Next Session

Read prompt: `prompts/23-task-first-run-aha.md` — **S23 CODE: first-run "aha"** (make `vajra init` → a *felt* win in ~2 min). The last open Phase 2 item — landing it closes Phase 2.

## Build Queue (from ROADMAP.md, in order)

### Phase 1 — Pre-release (blocking) — COMPLETE
1–6. ~~claude · init · check · next --advance · budget guard · next e2e~~ — DONE (S07–S12)

### Phase 2 — Varta: the agent's language + the co-pilot (S18 direction)
7. ~~**Varta v0 — the skill**~~ — DONE (S19).
8. ~~**Co-pilot loader**~~ — DONE (S21). `⚡on` fires + Varta enforces.
8a. ~~**Scaffold propagation**~~ — DONE (S22). `vajra init` emits the S20 GT audits + S21 co-pilot.
9. **First-run "aha"** *(NEXT — S23)* — `vajra init` → visible/felt win in ~2 minutes. Closes Phase 2.

### Phase 3 — Ship — COMPLETE
~~Installer · maturity levels · legacy cleanup · pre-run cost estimate~~ — DONE (S13, S14, S16, S17)

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth — audits **direction + discipline** drift. Next: S25.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
