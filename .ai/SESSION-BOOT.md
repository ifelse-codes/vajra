# Session Boot

## Current Session
- **Number:** 51 — COMPLETE
- **Type:** **CODE/VERIFY · PAID** — direction B, founder pick A. Measured the **value gap**: the same real
  chitra task run twice — Arm A `vajra claude` (kept) vs Arm B plain `claude` (stripped worktree, discarded) —
  on a pre-declared rubric (correctness · corrections · cost). First real **work-quality** reading.
- **Branch:** `session-51-value-gap` (Vajra). The useful work landed in **chitra** (its own repo/workflow).
- **Date last updated:** 2026-07-08

## Repo State Snapshot
- `.ai/SESSION` = 51.
- `main`: up to Session 50. S51 output = `sessions/session-51-summary.md` + `sessions/session-51-artifacts/`
  + `prompts/52-task-value-gap-harder.md` + `scripts/verify-session-51.sh` (19/19) + closeout, **committed
  locally on `session-51-value-gap`** (publish-guard OFF in this repo; founder pushes / merges).
- Remote: `origin` → `https://github.com/ifelse-codes/vajra`.
- **Verdict (n=1, honest):** **no measurable Vajra work-quality win; cost ~19% MORE** ($0.8127 vs $0.6813).
  Both arms **equal** on core API correctness (themes, exports, methods, `toJSON` shape). Vajra arm
  **marginally worse** on peripheral correctness — it faithfully mirrored chitra's **own broken**
  `CONTRIBUTING.md` (wrong clone URL + a `node file.ts` run command that can't execute TS) — and marginally
  **better** on task structure (explicit ordered new-user path). **Thesis UNPROVEN — the task was too easy to
  separate the arms.**
- **`dogfood_check` → 🟢 refreshed** (first paid `vajra claude` since S46). Enforcement fired live (co-pilot
  blocked this session's own `git commit`, exit 2). **NEW bug found:** the vajra receipt overstated cost
  **~9×** ($7.37 vs Claude's authoritative $0.81) — cache-pricing miscalibration; the "honest receipt" is wrong.
- **chitra advanced for real:** S03 finished + merged to chitra `main`; **S04 README committed** (`def0cfa`,
  chitra `session-04-readme-getting-started`) — Arm A's output with the 1 correction folded in.
- S51 spend ~**$1.52** (Arm A $0.8127 · Arm B $0.6813 · probe $0.0265). Cumulative ~**$67.3**. Under $5 cap.

## Next Session
- **Number:** 52
- **Type:** **CODE/VERIFY · PAID** — **founder pick A: value gap on a HARDER task (n=2).** Re-run the A/B on a
  real multi-step, convention-heavy chitra task (lead = the publishable `dist/` build for `@chitra/core`) where
  captured `.ai/` context could plausibly prevent drift/re-work — the axis a README one-shot could not test.
  Adds a **constraint-adherence** rubric axis. Takes the second reading; still small-n.
- **Prompt:** `prompts/52-task-value-gap-harder.md` (ready).
- **Branch:** `session-52-<slug>` off `main` — **new chat.**

## Carry-Forwards
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S52; do NOT start it here.
- **Post-merge (S37 return-to-main step):** after the S51 branch merges, checkout `main` + prune merged
  `session-51-*` (and older `session-50-*`/`session-49-*`) branches; prune stale `origin/session-42-*`.
  In chitra: `session-03-polish-docs` merged to chitra `main`; `session-04-readme-getting-started` holds S04.
- **Direction is B** — "make the AI do better work". S51 = first work-quality reading = **honest n=1 null.**
  Do NOT rescue the thesis; a harder-task null (S52) would be a major, honest signal. Enforcement stays
  complete + live-verified; do not re-open it.
- **Use `total_cost_usd`, NOT the vajra receipt** — receipt overstates ~9× (S51 finding). Fix = a future
  session (was S52 candidate C, not picked).
- **S55 = next mandatory NO-CODE ground-truth** (every 5th; last = S50).
- **Carry (compression):** cargo/npm/pytest exit-code fold gap — never fold on real CC; own future session.
- **Carry (env):** nested `claude`/`vajra claude` needs API-key billing (org disabled subscription for the CLI);
  S51's paid arms ran on API credits after the founder enabled it.
