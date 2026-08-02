# Session 109 — CODE: fleet slice 1 — one real named agent as a governed step

> **Status:** APPROVED (founder pick A, S108 closeout — "Start the fleet"). The C→B→A order's **A**,
> first slice. B (installable v0.1) completed at S108 (every install channel live + proven). Written at
> S108 closeout per `end_of_session.must_write_next_prompt_before_close`.

## Goal

Ship the **smallest real slice** of the named agent fleet: make `vajra` dispatch **one** named agent
role (a **Researcher**) as a governed step that produces a **delta-tracked handoff artifact** the
pipeline can carry forward — proven by **one real, small, paid Researcher call** (a live `claude -p`-style
sub-agent), **not** a claim or a fake. This turns the pipeline's named *stations* (labels/gates, S104)
into the first real *agent* doing scoped work behind the existing trust gates. One agent, one handoff,
one live call. Nothing else.

> **Founder decision (S108 follow-up):** make this slice **real, not dry** — wire in an actual paid
> Researcher sub-agent (one small, budget-capped call), don't just prove the plumbing with a stub. Keep
> a **stub path** alongside it so CI and the fail-closed gate never depend on a paid call — but the
> headline proof is a live sub-agent producing a real handoff. This is the first paid session since S103
> (expected spend: small — a single scoped call, hard-capped).

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

## Design (the Architect gate — recorded marker + spine-citing rationale)

- design-significant: yes
- **Rests on `docs/decisions/DECISION-007-agent-fleet.md`** (authored this session) and
  `docs/decisions/DECISION-001-governance-as-product.md` / `DECISION-005-autopilot-trust.md`. The
  fleet is a new architectural direction (real named agents behind the gates), so the Architect
  station applies. **Shape and why, not the alternative:** the role is a **native Claude Code
  subagent** — `vajra init` scaffolds `.claude/agents/researcher.md` from the ONE canonical source
  (`fleet::ROLES`, no drift), the live session runs it via the Task tool, and `vajra next --role
  researcher --from <findings>` governs its brief into a delta-tracked, validated handoff at
  `.ai/handoffs/session-NN-researcher.md` (the `.ai/` spine IS the memory —
  `feedback-map-concepts-to-vajra` — so no new store). This rides existing commands (init scaffolds,
  next governs) — no 8th command. **Why subagent over a `claude -p` subprocess** (built first, then
  replaced, founder call): Vajra is an external binary that cannot *call* a subagent, so its job is
  to scaffold the role + govern the handoff — exactly the coach role it already plays (S44 scaffolds
  `.claude/settings.json`); the subagent also inherits the session's auth (no headless login wall)
  and meters for free. DECISION-007 records the full rationale + the deferred scope (one agent, one
  handoff — the whole fleet stays out).

## Scope (max 1 story · ≤3 files per commit · ~2h cap)

> **Mechanism redirect (founder call, mid-S109):** the first build spawned a `claude -p` subprocess
> (`vajra claude --role`) — it hit a headless "Not logged in" auth wall only the human can clear.
> Founder chose **subagent-only**: the role is a **native Claude Code subagent** Vajra scaffolds +
> governs; there is **no separate paid `claude -p` call** (the subagent runs inside the live session,
> inheriting its auth). Items below reflect the redirect; the original text is preserved in the S109
> summary's fidelity map.

**In:**
1. **`DECISION-007` (the fleet slice-1 design)** — the decision record above. Existence-gated by the
   Architect gate (a made-up id blocks).
2. **Scaffold the role as a native subagent** — `vajra init` writes `.claude/agents/researcher.md`
   from the ONE canonical source (`fleet::ROLES`, no drift, cf. S104/S99). **Rides `vajra init`** — no
   8th top-level command.
3. **Govern the handoff** — `vajra next --role researcher --from <findings>` wraps the subagent's
   brief into a **delta-tracked, validated handoff** at `.ai/handoffs/session-NN-researcher.md`
   (frontmatter + body + `## Handoff Delta`; `.ai/` IS the memory — no new store). **Rides `vajra
   next`** — no 8th command.
4. **The live proof — one real Researcher subagent run.** Dispatch a genuine Researcher subagent (the
   Task tool, scoped by the scaffolded definition), then govern its brief into the handoff — captured
   as a session artifact + re-checked by the cold reviewer. Its cost rolls into the session receipt.
5. **A falsifiable smoke** (`scripts/fleet-smoke.sh`) proving scaffold + govern with plain files
   (**no paid call, no live agent**): `vajra init` scaffolds the subagent def → govern findings →
   handoff exists + well-formed + delta applied; **fail closed** on unknown role · missing `--from` ·
   missing/empty findings. A skipped-and-green is a REJECT.

**Out (defer):** parallel agents · a second/third named role · full multi-stage orchestration ·
cross-agent runtimes · an unattended `claude -p` dispatch mode · an 8th top-level command.

## Acceptance criteria

1. `DECISION-007` exists under `docs/decisions/`, cited by a non-placeholder `## Design`, and passes
   the Architect gate (`vajra next --check-design 109` / `--advance`).
2. Vajra scaffolds the **Researcher** as a native Claude Code subagent (`vajra init` →
   `.claude/agents/researcher.md`, from the canonical source) AND governs a subagent brief into a
   **delta-tracked, validated handoff** (`vajra next --role researcher --from`), on existing command
   surfaces (no 8th top-level command; `vajra --help` still lists 7). Proven by (a) a **real
   Researcher subagent run** whose brief becomes the handoff — captured as an artifact; (b) the
   fail-closed smoke (no paid call, no live agent).
3. The smoke **exits non-zero** on: unknown role · missing `--from` · missing/empty findings. A
   skipped-and-green is a REJECT.
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
- **A real Researcher subagent run IS the headline proof** (founder redirect, mid-S109 — supersedes
  the S108-follow-up "paid `claude -p` call"). The subagent runs inside the live session (no headless
  auth wall, no separate paid call); its cost rolls into the session receipt (disclose the session
  total in the summary). The fail-closed smoke stays paid-free so CI + the close-gate never depend on
  a live agent.
- Keep it to **one agent, one handoff** — resist designing the whole fleet. Scope creep here is the
  named key risk.
- S110 is the next mandatory NO-CODE ground truth — leave the tree green and the counter honest.
