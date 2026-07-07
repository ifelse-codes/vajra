# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 47 — mid-run co-pilot murmur (direction B, first value session, CODE) — COMPLETE

- **Delivered:** the proactive, non-blocking half of the co-pilot. `scripts/hook-copilot-murmur.sh`
  (`UserPromptSubmit`, advisory, **exit 0 — never blocks**) surfaces the `copilot.on` context relevant to
  the working-tree changes each turn; reuses the loader's rule-parse + per-session debounce, inverts the
  posture. Scaffolded into `vajra init` byte-identical via `include_str!` + a new `UserPromptSubmit` block;
  `Cargo.toml` un-excludes it. Output = `sessions/session-47-summary.md`.
- **Verdict:** `verify-session-47.sh` **23/23 green**; `cargo test` **119 lib** (+2). **Honest read:
  mechanism verified, value UNMEASURED** — the murmur fires right, but is unproven to reduce re-work.
- **Founder direction: B in execution.** Enforcement is the floor (complete + live-verified S46); the
  co-pilot value is the product. "Cheaper" = less re-work, not compression.

Between sessions. Next = S48, the obedience metric (founder pick A).

## Next Session (S48 — the obedience metric, founder pick A)

- **Delivers:** compute `obedience % = clean ÷ (clean + blocked/retried)` from the session trace so we can
  tell whether the murmur (+ guard) actually help — measure before building more co-pilot. Instrumentation
  only; no new guidance. Measures obedience, not yet work-quality (name that blind spot).
- **Prompt:** `prompts/48-task-obedience-metric.md` (ready).
- **Branch:** `session-48-<slug>` off `main` — **new chat.**

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S45; next mandatory = S50).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S48; do NOT start it here.
- **Direction is B (S46 lock), in execution:** make the AI do BETTER WORK (correct results, less re-work,
  less babysitting), not just block it. Enforcement is complete + live-verified — do not re-open it.
  **Measure before building more co-pilot** (S48 = the number). Memory `vajra-direction-b-copilot`.
