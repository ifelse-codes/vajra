# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 34 — Brownfield onboarding (CODE) — COMPLETE

- **Type:** CODE. Closed S31 finding #3, the last of the three core breakages — third *advised → enforced* instance.
- **Shipped:** (1) `vajra init` detects a brownfield repo and boots it into **session 00** with a guided study-the-repo brief (`prompts/00-task-brownfield-onboarding.md`) that fills KNOWLEDGE/STATE with reality before feature work. (2) Scaffolded hooks land in `.ai/hooks/`, never the project's own `scripts/`. (3) `vajra claude` auth pre-check fails fast without credentials (presence-only; `VAJRA_SKIP_AUTH_CHECK=1` bypass). verify-session-34.sh green (11/11); verified on real brownfield copies (`darpan`, `TradingAgents`) + live auth paths.
- **New finding, not fixed:** existing `.claude/settings.json` is skipped on init → scaffolded hooks never wired; needs a merge strategy (future 1-story candidate).
- **PR:** [#29](https://github.com/ifelse-codes/vajra/pull/29) — open (merge after closeout).

Between sessions. Next: read `prompts/35-task-ground-truth-gate-remeasure.md`.

## Next Session

Read prompt: `prompts/35-task-ground-truth-gate-remeasure.md` — **S35 GROUND TRUTH (NO-CODE, mandated `NN % 5 == 0`).** Founder-picked lens A: verify the "fix the core before breadth" bet paid off + re-measure the second-agent gate. All required audits run; `dogfood_check` will flag ~$0 spend since S31 — an "unmeasured → S36 dogfood" verdict is the honest likely outcome. No code, no commits, no PRs.

## Build Queue (from ROADMAP.md, in order)

1. ~~Darshan enforcement (S32)~~ — **DONE.**
2. ~~Compression schema fix (S33)~~ — **DONE.**
3. ~~Brownfield onboarding (S34)~~ — **DONE.**
4. **S35 = GROUND TRUTH (NO-CODE)** — bet verification + gate re-measure (lens A).
5. **S36 candidates (S35 ranks them):** real dogfood run · `.claude/settings.json` merge · `exit_code` heuristic fix · obedience metric (backlog) · second agent (gate-dependent).

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S30; **next = S35, i.e. NOW**) — audits **direction + discipline** drift.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** (enforced by the session-guard hook, in `vajra init` too).
- **Every fix moves a feature from *advised* → *enforced*** (S31 meta-finding — Vajra's own wedge; held 3×).
