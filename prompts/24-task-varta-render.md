# Session 24 — Render `.ai/` → generated `.varta` (CODE)

## Goal
Produce a glanceable `.varta` artifact that is **one-way generated from the live `.ai/`** — regenerated on demand, never hand-kept. A persisted `.varta` returns only because it can be *generated* (the S19 condition), so it cannot drift and cannot silently lose config.

## Why now
S19 shipped Varta as **language-only** and deliberately **dropped** the hand-written `vajra.varta` companion (a second copy drifts from `.ai/` and lost budget/maturity config). The standing follow-up was: bring `.varta` back *only* as a generated render. S22 (`include_str!`) and S23 (live hook fire) both proved the "one source of truth, generated/embedded, drift-guarded" pattern — so this is now low-risk. It completes the Varta story and is **lean** ahead of the S25 ground-truth (NO-CODE).

## Scope (1 story)
- A **renderer**: read the live `.ai/` (at minimum `CONSTRAINTS.yaml`; consider `SESSION`/`STATE.md` headers) and emit the ⚡ grammar (the 9 locked constructs) — `⚡project`, `⚡forbid`, `⚡require`, `⚡max`, `⚡pipeline`, `⚡final`, `⚡on`, `⚡assert`, `⚡enum`.
- A **drift guard**: a check that the on-disk generated file equals a fresh render (the S22 `cmp` pattern) — proves it is generated, not hand-edited.
- Tests + `scripts/verify-session-24.sh` + cumulative demo.

## Key decision (must answer in the summary)
1. **What triggers the render — without adding an 8th top-level command?** (7-command cap is a ROADMAP rule.) Options: extend `vajra check` (it already inspects `.ai/`), a flag on an existing command, render-to-stdout only, or wire it into closeout/verify. Pick one, record why.
2. **How is `.ai/CONSTRAINTS.yaml` parsed?** There is **no `serde_yaml` dep** today (hooks hand-parse line-by-line, per KNOWLEDGE §6). Either hand-parse the few fields needed or request the dep explicitly — do not add a dependency without approval.
3. **Where does the artifact live + is it committed or git-ignored?** (A committed artifact needs the drift guard in CI/verify; an ignored one is regenerated each time.)

## Constraints
- Branch `session-24-varta-render`. Max 3 files / atomic commit. Max 1 story. ~2h cap.
- `scripts/verify-session-24.sh` must exit 0. Demo cumulative. ADRs locked. No new dep without approval.
- **S25 is the next session and is NO-CODE ground-truth** — keep S24 lean and leave a clean surface.

## Output
- A `.varta` generated from the live `.ai/`, drift-guarded, proven by verify + demo + `sessions/session-24-summary.md` (answer the 3 decisions + 3 next options).
