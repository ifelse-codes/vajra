---
role: design-advisor
session: 176
agent: claude-code-subagent (verified: toolu_01RYxbGjqgsjPbAWBbeXkRmg)
source-sha: a283fd523d4a4bca4b7b109e2dcc7628347515e028fbb70d1917ee06f9b3feec
captured: 2026-09-23T16:41:09Z
cost_usd: null
---

# Design-advisor handoff — session 176

# Design-advisor proposal — session 176

**Verdict:** `design-significant: yes`; cite `docs/decisions/DECISION-007-agent-fleet.md` (S116 addendum, "The `covers: N` contract: reused, not re-derived", lines 309–317) — the only spine record stating the Planner's coverage contract. The S64 Planner itself was never written up as its own record; do not cite a DECISION/ADR number for it. This change EXTENDS that contract without contradicting it (the addendum's "the station's gate is not touched" was scoped to S116).

**Decision:** the Planner checks both directions. Old: every acceptance criterion is cited by a step. New: every `covers: N` a step cites must be a criterion that exists. A plan citing numbers the Acceptance list lacks → a new blocking PlanState variant carrying the cited-but-missing numbers (sorted, de-duplicated); its message names them and the two likely causes (the list was cut/deleted, or its items are not written as `N.` lines). Blocks via `blocks()`, `plan_gate`, `format_plan_checklist`, and the stations counter.

**Kept (adds only, S173):** no criteria + a plan citing nothing stays Covered.

**Rejected:** (a) put it in `--validate` or a close re-run — a new gate on own paperwork, founder's yes needed; recorded as a residual finding. (b) zero criteria → not covered — breaks the kept rule, flips old prompts. (c) one combined two-list variant — every consumer handles two lists for a rare case. (d) grow `Uncovered` — mixes two causes in one message.

**Known limit (disclosed):** an edit that also deletes the `covers:` markers, or the whole `## Plan` (Absent → WARN), still passes — the S68 "jurisdiction is self-granted" class. This closes the F70 shape, not the class.

rec 1 — Record `design-significant: yes`: a new public `PlanState` variant matched outside the Planner (`src/stations/mod.rs`) plus a changed passing rule is an interface change, not a pure fix.
rec 2 — Cite `docs/decisions/DECISION-007-agent-fleet.md` (S116 `covers: N` addendum) and state that the S64 Planner has no record of its own; no new decision file.
rec 3 — Dangling-citation state wins over Uncovered (check it first); lock with a test: criteria 1–5, plan cites 1,2,3,7 → only the new state carrying [7].
rec 4 — The block message names both causes: the Acceptance list was cut/deleted, or its items are not numbered `N.`. Fix false blocks in the message, never hide a prompt or narrow the rule to keep a sweep green.
rec 5 — Write the known limit into the Design text: deleting the `covers:` markers or the whole `## Plan` still passes.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (2592 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
