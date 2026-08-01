# Session 109 — CODE: fleet slice 1 — one real named agent as a governed step

> **Status:** APPROVED (founder pick A, S108 closeout — "Start the fleet"). The C→B→A order's **A**,
> first slice. B (installable v0.1) completed at S108 (every install channel live + proven). Written at
> S108 closeout per `end_of_session.must_write_next_prompt_before_close`.

## Goal

Ship the **smallest real slice** of the named agent fleet: make `vajra` dispatch **one** named agent
role (a **Researcher**) as a governed step that produces a **delta-tracked handoff artifact** the
pipeline can carry forward — proven by a falsifiable instrument, **not** a claim. This turns the
pipeline's named *stations* (labels/gates, S104) into the first real *agent* doing scoped work behind
the existing trust gates. One agent, one handoff. Nothing else.

## Why this session (evidence)

- The product's headline is **"leave a team of agents working, come back, trust the result"**
  (`DECISION-005`). Today `vajra claude` launches exactly one undifferentiated agent; the 8 "stations"
  are gates + a team-voice roster (S104), not real separate agent invocations. The fork opened at S103
  (fleet-vs-gates; recommended shape = **both**) has **0 code**.
- B is done and v0.1 is stranger-shippable, so A is the right next leg — but a fleet is many sessions.
  This slice de-risks it by proving the **one-agent-one-handoff** primitive end to end before any
  parallelism or multi-stage orchestration.

## This is design-significant → design gate applies

The fleet is a new architectural direction, so the Architect station applies:
- Record `design-significant: yes` and write a **`## Design`** section citing a **new** decision record
  you author this session — e.g. `docs/decisions/DECISION-007-agent-fleet.md` — that locks: fleet =
  real named agents behind the existing gates (fork resolved as "both"); **how** `vajra` dispatches a
  named role (the mechanism); and the **handoff contract** (what a role writes, where, how the next
  stage consumes it, how the delta is tracked). Keep it to the one first-slice decision — do NOT design
  the whole fleet.

## Scope (max 1 story · ≤3 files per commit · ~2h cap)

**In:**
1. **`DECISION-007` (the fleet slice-1 design)** — the decision record above. Existence-gated by the
   Architect gate (a made-up id blocks).
2. **One named-agent dispatch surface** — `vajra` can run the Researcher role with a **role-scoped
   prompt** and capture a **governed handoff artifact**. **Ride an existing command surface** (e.g.
   `vajra claude --role researcher` or an extension of `vajra next`) — **do NOT add an 8th top-level
   command** (max-7 rule; an 8th needs an explicit separate founder approval). The role prompt is built
   from one canonical source (no drift, cf. S104/S99); the handoff is a tracked artifact with a
   recorded delta to the prior stage.
3. **A falsifiable smoke** (extend `scripts/install-smoke.sh` or a sibling) that proves the plumbing
   with a **stub agent** (e.g. `VAJRA_AGENT_CMD`-style injection → a fake command, **no paid call**):
   dispatch → handoff artifact exists + well-formed → gate/delta applied; **fail closed** if the agent
   is missing, the handoff is absent/malformed, or the role is unknown. A real paid `claude -p`
   Researcher run is **optional/deferred** (note it; don't gate on spend).

**Out (defer):** parallel agents · a second/third named role · full multi-stage orchestration ·
cross-agent runtimes · any paid ladder run · an 8th top-level command.

## Acceptance criteria

1. `DECISION-007` exists under `docs/decisions/`, cited by a non-placeholder `## Design`, and passes
   the Architect gate (`vajra next --check-design 109` / `--advance`).
2. `vajra` dispatches the **Researcher** role with a role-scoped prompt and writes a **governed handoff
   artifact** — demonstrated live with a **stub agent** (no paid call), on an existing command surface
   (no 8th top-level command; `vajra --help` still lists 7).
3. The smoke **exits non-zero** on: unknown role · missing agent command · absent/malformed handoff.
   A skipped-and-green is a REJECT.
4. `cargo test --lib` green; CI green both OS; the 8-station gate logic and receipts unchanged in
   behavior (new code is additive).
5. `scripts/verify-session-109.sh` → all green (incl. a fail-closed probe); `scripts/demo-session-109.sh`
   → exit 0 with the required markers (header/cases/summary_table/before_after).
6. Independent cold review (`sessions/session-109-review.md`) → ACCEPT, attested; ledger chain intact.

## Guardrails

- Branch `session-109-<slug>`; commits carry `VAJRA_ALLOW_COMMIT=109`.
- **Max 7 top-level commands** — do NOT add an 8th without a separate explicit founder "yes"; ride an
  existing command/flag. If the design genuinely needs an 8th, STOP and ask first.
- **Map to Vajra's own mechanism first** (`feedback-map-concepts-to-vajra`): the prompt IS the spec,
  `.ai/` IS the memory, stations already name roles — reuse them; don't invent a new store/artifact by
  reflex. If a new artifact is unavoidable, justify it in `DECISION-007`.
- **No paid run required** — prove the plumbing with a stub agent; a real paid Researcher run is a
  separate, deferred, founder-gated step (the S103 pivot: the founder runs long/paid tests himself).
- Keep it to **one agent, one handoff** — resist designing the whole fleet. Scope creep here is the
  named key risk.
- S110 is the next mandatory NO-CODE ground truth — leave the tree green and the counter honest.
