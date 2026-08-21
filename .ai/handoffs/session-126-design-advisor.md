---
role: design-advisor
session: 126
agent: claude-code-subagent
source-sha: 9a784d8aef38a90f65df764fc8487b3cbf873b05c8ae44d65e33384e982f6722
captured: 2026-08-21T11:26:21Z
cost_usd: null
---

# Design-advisor handoff — session 126

# Design Advisor brief — Session 127

## 1. Design-significance recommendation

**`design-significant: yes`**

This is unambiguously significant on two of the three triggers:

- **A new or changed interface.** Today a station gate reads exactly one thing — a recorded marker inside the session's own prompt (Architect reads `design-significant:`, Planner reads `covers: N`, Coder reads `step N — done: <sha>`, QA re-runs a recorded verify marker). S127 introduces a *second class of gate input*: a governed handoff file at `.ai/handoffs/session-NN-<role>.md`, with its own frontmatter contract (`role`/`session`/`agent`/`source-sha`/`captured` + `## Handoff Delta`). Making a gate *consume* that is a new binding contract between the fleet's write side (DECISION-007) and a station's gate.
- **A deviation from a locked record.** DECISION-007's S116 addendum (lines 316-317) explicitly names "consuming a handoff into a station's own gate" and marks it **"explicitly deferred as a non-goal."** Every fleet addendum since (S121, S122, S123) repeats the standing limit that the station "is not touched, and does not learn the role key," and S114's open-item-2 locked that `verify-closeout.sh` and the Reviewer station keep reading exactly one artifact each. S127 reverses that posture. That is not a pure fix; it moves a locked line.

`design-significant: no` would be wrong here and the gate would be right to have nothing to enforce — but the whole point of S127 is a new binding input, so leaving the marker at `no` (or unrecorded) would let a station-consuming-a-handoff change land with zero recorded design rationale. The Architect gate reads that marker and never guesses; an unrecorded marker is not a neutral omission.

## 2. Proposed `## Design` rationale (for the author to record verbatim in `prompts/127-task-*.md`)

> ## Design
>
> design-significant: yes
>
> **What changes.** Until now the fleet WRITES governed handoffs (DECISION-007) and, since S112, a station can READ them (`fleet::read_handoff` → `HandoffRead::{Absent,Malformed,Found}`), but no gate CONSUMES one as a binding input — a handoff is advisory next to the pipeline it belongs to. S127 wires one station's gate to bind on a contract-valid governed handoff, using the existing S112 read side, so that a fleet role's output becomes real gate-consumed evidence rather than a file that sits orphaned.
>
> **Why this is a deviation, stated plainly.** DECISION-007's S116 addendum deferred exactly this ("consuming a handoff into a station's own gate ... explicitly deferred as a non-goal"), and its S114 open-item-2 locked "the gate keeps reading exactly one artifact." S127 knowingly moves that line and MUST record a new addendum (or a superseding DECISION) that lifts the deferral — this `## Design` is the proposal; the lock is the addendum, not this prompt.
>
> **How it stays inside the house pattern (existence-gated recorded markers).** The gate binds on a RECORDED, EXISTENCE-CHECKED artifact, never a guessed or inferred one — the same move as Architect (`design-significant:` + a spine record that EXISTS), Planner (`covers: N`), Coder (`git cat-file -e <sha>`), and QA (a marker re-run live). Concretely: the gate consumes a handoff only when `read_handoff` returns `Found` (a file that PASSED `validate_handoff` — frontmatter block present, `source-sha` present, `## Handoff Delta` present); `Malformed` fails closed and is never swallowed as `Absent`; `Absent` stays silent and legacy-compatible so a session with no fleet work closes exactly as before. Consumption INLINES the findings head (a path alone is not consumption — `format_handoff_brief`) and discloses omitted lines, so a truncated brief can never read as the whole thing.
>
> **Fail-closed and no-new-surface.** Rides `vajra next`; no 8th top-level command, no new store (`.ai/` IS the memory), no new artifact type. The handoff's `source-sha` is the tamper-evidence tie-back to the exact findings — consuming the handoff inherits DECISION-004's tamper-EVIDENT posture, not tamper-proofing; do not claim the consumed input cannot be forged, only that a forged/stale one is detectable and a malformed one fails closed.
>
> **Alternatives rejected.**
> - *A gate that reads the raw findings file directly (bypass the governed handoff).* Rejected — it throws away `source-sha` and the delta, the very things that make a handoff evidence rather than prose (mirrors DECISION-007 S114's rejection of "pointer only").
> - *A new store / DB / index for consumable handoffs.* Rejected — `.ai/` already IS the memory (DECISION-007, `feedback-map-concepts-to-vajra`); a new store is the reflex that memory forbids.
> - *Make the handoff the RECORD OF RECORD that the gate reads INSTEAD of the prompt's own marker.* Rejected — it would strip the marker contract every station is built on and let the fleet route around the prompt-owned gate. The handoff is a PRE-STAGE INPUT the gate consumes; the prompt's recorded marker stays the record of record (DECISION-007 S114 open-item-2, applied to the read side).
> - *A gate that WARNs on a missing handoff instead of failing closed on a malformed one.* Rejected — that is the "jurisdiction is self-granted" fake-green class (S68): a consumer that swallows a broken artifact as absent has no teeth. `Malformed` must fail closed; only genuine `Absent` is silent.
> - *`design-significant: no`.* Rejected — a new binding gate input plus a locked-deferral reversal is not a pure fix.

## 3. Cited design record (verified to exist)

**`docs/decisions/DECISION-007-agent-fleet.md`** — verified present on disk. This is the correct and only citation: it is the locked record that (a) defines the governed-handoff contract S127 consumes, and (b) contains the exact deferral S127 lifts (S116 addendum, lines 316-317).

**This design DEVIATES from the record it cites** — DECISION-007 currently marks handoff-into-gate consumption as an explicit non-goal. Per my role I state that plainly: the Architect gate checks the *form* of the citation (a recorded marker + a spine record that EXISTS), not whether the design obeys what it cites, so citing DECISION-007 will PASS the gate — but the citation alone does not make the deviation legitimate. **S127 needs a NEW DECISION-007 addendum (or a superseding DECISION record) that lifts the S116 deferral and locks the consume-side contract.** The `## Design` above must not read as "DECISION-007 already allows this"; it must read as "S127 deviates from DECISION-007's deferral and records the addendum that lifts it." Do not invent an ADR id for this; DECISION-007 is the live record and its addendum chain is the established way this fleet arc records each new slice.

## Relevant file paths (all absolute)
- `/Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md` — cite this; deferral to lift at lines 316-317 (S116 addendum)
- `/Users/suman/playground/vajra/src/fleet/mod.rs` — the handoff write side (`format_handoff`/`validate_handoff`) and the S112 read side (`parse_handoff`, `read_handoff`, `HandoffRead`, `format_handoff_brief`) S127 consumes; lines 717-856
- `/Users/suman/playground/vajra/src/architect/mod.rs` — the existence-gated recorded-marker house pattern to mirror; lines 1-80
- `/Users/suman/playground/vajra/.ai/handoffs/session-122-qa-specialist.md` — a live example of the handoff contract a gate would consume

**One flag for the author and the Architect station:** the prompt file `prompts/127-task-*.md` does not exist yet. My output is a proposal — I do not write the `## Design` section. The author records the marker and the rationale above; the Architect gate then reads them. Until recorded, the marker is unrecorded, which the gate treats as a block for a design-significant session — not a neutral omission.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (7835 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
