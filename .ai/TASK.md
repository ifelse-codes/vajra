# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 48 — the obedience metric (direction B, founder pick A, CODE) — COMPLETE

- **Delivered:** `obedience % = clean ÷ (clean + blocked)` mined **read-only** from the session trace,
  surfaced on `vajra meter`. A Vajra rail block already surfaces in the trace as
  `tool_result{is_error, "PreToolUse:… hook error … [vajra …]"}` → no hook change, runs on **past**
  sessions. `src/obedience/mod.rs` + `src/lib.rs` + `src/cli/meter.rs`; `scripts/verify-session-48.sh`.
  Output = `sessions/session-48-summary.md`.
- **Verdict:** `verify-session-48.sh` **20/20 green**; `cargo test` **124 lib** (+5). Live: 98.9% on a
  real session · 0% on the S46 isolation run (publish-guard). **Honest read: measures obedience to the
  RAILS, not work-quality** — a floor, first rung of the ladder.
- **Founder direction: B in execution.** Enforcement is the floor (complete + live-verified S46); the
  co-pilot value is the product. Measure before building more — this session is the number.

Between sessions. Next = S49 — **awaiting founder pick (A/B/C)** from the S48 summary.

## Next Session (S49 — awaiting founder pick)

- **A (recommended):** baseline read — the metric across several past sessions for context ($0).
- **B:** measure the value gap (real-task baseline, PAID) — the work-quality question obedience omits.
- **C:** trace-mine missing `⚡on` advisories (look-only) → co-pilot content backlog.
- **Prompt:** `prompts/49-task-<slug>.md` — written after the pick. **Branch:** `session-49-<slug>` — new chat.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S45; next mandatory = S50).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S49; do NOT start it here.
- **Direction is B (S46 lock), in execution:** make the AI do BETTER WORK (correct results, less re-work,
  less babysitting), not just block it. Enforcement is complete + live-verified — do not re-open it.
  **The obedience metric is a floor, not work-quality.** Memory `vajra-direction-b-copilot`.
