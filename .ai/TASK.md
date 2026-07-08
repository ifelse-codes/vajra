# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 51 — Measure the value gap (real-task A/B on chitra, PAID) · direction B — COMPLETE

- **Verdict (n=1, honest):** **no measurable Vajra work-quality win; cost ~19% more.** Both arms equal on
  core API correctness; the Vajra arm mirrored chitra's own *broken* `CONTRIBUTING.md` (peripheral slip) and
  had a marginally better ordered new-user path. **Thesis UNPROVEN — the README one-shot was too easy to
  separate the arms.**
- **Duties landed:** value-gap number (null at n=1) · `dogfood_check` 🟢 refreshed (first paid `vajra claude`
  since S46; co-pilot fired live exit-2; **+1 bug: receipt overstates cost ~9×**) · **chitra advanced for
  real** (S03 merged to chitra `main`; S04 README committed `def0cfa`).
- **Output:** `sessions/session-51-summary.md` + `sessions/session-51-artifacts/` + `verify-session-51.sh`
  (19/19). S51 spend ~$1.52. **Founder pick = A** → S52 = value gap on a HARDER task.

Between sessions. Next = **S52 — Value gap on a HARDER task (n=2, PAID)** · `prompts/52-task-value-gap-harder.md`.

## Next Session (S52 — Value gap on a HARDER task · direction B · CODE/VERIFY · PAID)

- **Type:** CODE/VERIFY, **PAID.** Re-run the A/B on a real multi-step, convention-heavy chitra task (lead =
  publishable `dist/` build for `@chitra/core`) where captured `.ai/` context could prevent drift/re-work — the
  axis a README one-shot could not test. Adds a **constraint-adherence** rubric axis. n=2, still small.
- **Output:** `sessions/session-52-summary.md` (rubric + both arms + honest verdict vs the S51 null + 3 S53
  candidates). Arm A committed in chitra.
- **Branch:** `session-52-<slug>` off `main` — **new chat.** **Prompt:** `prompts/52-task-value-gap-harder.md` (ready).

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S50; next mandatory = S55).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S52; do NOT start it here.
- **Direction is B (S46 lock), in execution:** make the AI do BETTER WORK, not just block it. **S51 = first
  work-quality reading = honest n=1 null — do not rescue the thesis.** Use `total_cost_usd`, not the vajra
  receipt (overstates ~9×). Memory `vajra-direction-b-copilot`.
