# DECISION-007 — agent fleet, slice 1: a named role dispatched as a governed step

- **Date:** 2026-08-02 (Session 109)
- **Status:** ACCEPTED
- **Type:** architecture decision (a new product direction — the named-agent fleet)
- **Relates to:** DECISION-001 (governance is the product), DECISION-005 (autopilot trust — "leave a
  team of agents working, come back, trust the result"), and the S103 fleet-vs-gates fork (opened at
  the founder pivot; recommended shape = **both**). This decision resolves that fork for the FIRST
  slice only and locks the dispatch + handoff mechanism it introduces.

---

## Context — why decide now

The product's headline is a **team** of agents you can trust unattended (DECISION-005). But in code,
`vajra claude` launches exactly **one** undifferentiated agent. The eight "stations" (S104) are
**gates + a team-voice roster** — labels over a single agent, not real separate agent invocations.
The fleet fork opened at S103 has **0 code**. B (installable v0.1) is complete (S106–S108), so A (the
fleet) is the right next leg — but a fleet is many sessions. This decision de-risks it by locking the
**one-agent-one-handoff primitive** before any parallelism or multi-stage orchestration is designed.

## The fork, resolved (first slice only)

**Both.** The fleet is **real named agents running behind the existing trust gates** — not a
gate-only pipeline, and not a fleet that routes around governance. A named role is a genuine scoped
agent invocation; the gates, receipts, and ledger already built stay the hidden trust engine. This
decision commits only to slice 1 (**one** role, the Researcher); it does **not** design the whole
fleet (parallelism, a second role, multi-stage orchestration are all explicitly deferred).

## Decision

### 1. Dispatch mechanism — ride `vajra claude`, no 8th command

A named role is dispatched by an **existing** command surface:

```
vajra claude --role <name> -p "<the task for this role>"
```

- `--role <name>` is **consumed by vajra** and stripped before the remaining args reach `claude`
  (max-7-commands rule intact; `vajra --help` still lists 7). An unknown role **fails closed**
  (exit non-zero) — vajra never dispatches a role it cannot scope.
- The role's **system prompt** is built from **one canonical source** — `src/fleet/mod.rs`, a single
  `Role { name, system_prompt, handoff_rel }` per role (the S104/S99 no-drift rule: role text lives
  in exactly one place). It is injected via Claude Code's real `--append-system-prompt` flag, so the
  role scopes the agent without vajra forking a prompt template.
- The call runs headless (`-p` + `--output-format json`) so the S78 result-stream tee captures the
  **real `total_cost_usd`** — a named role's cost is metered like any other run.

### 2. The agent command is injectable — the stub path (fail-closed, paid-free)

The dispatched command is `claude` by default, overridable by **`VAJRA_AGENT_CMD`**. A test/CI run
sets it to a fake command that emits a canned `type:"result"` JSON line. This is what CI and the
close-gate exercise — **a gate must never depend on a paid call**. If the agent command is missing
from `PATH`, dispatch **fails closed**. The **live paid call is the headline proof** (item below),
captured as an artifact and re-checked by the cold reviewer — never the gate's dependency.

### 3. The handoff contract — what a role writes, where, how it is consumed, how the delta is tracked

A dispatched role produces exactly one **governed handoff artifact**:

- **Where:** `.ai/handoffs/session-{NN}-{role}.md` — the `.ai/` spine **is** the memory
  (`feedback-map-concepts-to-vajra`); no new store, no database, no 8th artifact type invented.
- **What:** YAML-style frontmatter (`role`, `session`, `agent`, `source-sha` = sha256 of the exact
  role-scoped input, `captured` timestamp, `cost_usd` = metered or `null`) + the agent's captured
  body + a **`## Handoff Delta`** section.
- **How the next stage consumes it:** the frontmatter keys are the machine-readable contract; the
  body is the human-readable finding. A malformed or empty handoff **fails closed** — an unusable
  handoff must never read as a successful step.
- **Delta tracking:** `## Handoff Delta` records what this handoff adds **relative to the prior
  stage** (for slice 1, the prior stage is the session prompt / Analyst's WHAT — there is no prior
  handoff, so the delta states "new: first researcher handoff for this session" plus the byte count).
  This makes the handoff a *tracked* artifact with a recorded delta, not an opaque dump.

## Alternatives considered

- **A new `vajra research` / `vajra agent` top-level command** — rejected: breaks the max-7 rule
  (DECISION design-rule) for no capability a flag can't carry; an 8th command needs a separate
  explicit founder approval.
- **A new handoff store (DB / `.vajra/` dir / JSON index)** — rejected: `feedback-map-concepts-to-
  vajra` says map to Vajra's own mechanism first. `.ai/` already IS the memory; a markdown artifact
  under `.ai/handoffs/` reuses it.
- **Designing the whole fleet now** (roles table, parallel dispatch, orchestration) — rejected as
  scope creep; the named key risk of this session. One agent, one handoff, one live call.

## Consequences

- **Locked:** fleet = real named agents behind the existing gates; dispatch via `vajra claude
  --role`; handoff = `.ai/handoffs/session-{NN}-{role}.md` with the frontmatter + `## Handoff Delta`
  contract; agent command injectable via `VAJRA_AGENT_CMD`; unknown role / missing cmd /
  malformed handoff all fail closed.
- **Deferred (out of scope, need their own decision):** a second/third role, parallel dispatch,
  multi-stage orchestration (role N's handoff feeding role N+1's prompt automatically), cross-agent
  runtimes, a full unattended paid ladder run.
- **Reversible?** The dispatch flag and handoff format are additive; nothing existing changes
  behavior. A later decision can extend the handoff contract without breaking slice-1 artifacts.
