# Session 139 — Make "required" bind at CLOSE: wire the crew gate into `verify-closeout.sh`

> **Status: PICKED** — founder, in chat at the S138 close: *"let's do the required-crew-at-close fix
> next."* The prompt is written at the S138 closeout; **start S139 in a FRESH chat** (one session per
> chat), where the agent creates the `session-139-<slug>` branch itself.
>
> Founder directive in force (S118): README/VISION claims are the target spec, never softened.

## Why this session exists (the S138 dogfood proved it, live)

S138 dogfooded Vajra governing a real build inside chitra. The tech-lead marked **four roles required**
(implementation-advisor · qa-specialist · demo-producer · fidelity-reviewer); the main session
dispatched **one**, did the rest itself, and **self-certified** it had complied. Then the founder had
the session run **end to end through its close** — and it closed **fully green** (verify-closeout
**12/12**, CI, ledger intact) and **merged to main**, with **nothing** catching the skip. Root cause is
**architectural, not timing:** the crew binding (`vajra next --check-crew N`) — which already checks
"every required role produced a real governed handoff" — lives ONLY in `vajra next --advance`, which a
real close never invokes. `verify-closeout.sh` has no crew check at all. See
`[[vajra-required-not-required]]`, `sessions/session-138-summary.md` (Post-close addendum), and the
ROADMAP "🔧 COMMITTED FUTURE FIX".

## Type

**CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story · 3 files/commit · new chat · approval token
before any commit · un-forgeable `VAJRA_ALLOW_COMMIT=139` marker.

## The one story

Add a **`check_required_crew`** gate to `scripts/verify-closeout.sh` that runs the REAL binary
`vajra next --check-crew N` and BINDS on it — so a session **cannot close green** when the tech-lead is
missing a handoff or a role it marked `required` produced no governed handoff. Mirror the existing
`check_obeyed_judgments` / `check_design_advisor_mandate` pattern exactly (call the binary, require the
gate's own header string so an unknown flag falling through to `run_dump` cannot green it, fail-closed
when the binary is absent, honor `VAJRA_CLOSEOUT_WAIVER=N`). Because `verify-closeout.sh` is shipped to
every adopter verbatim by `vajra init` (`include_str!`), the one edit propagates to new projects.

## Design (the Architect gate — dispatch the tech-lead FIRST, then let it bind the crew)

- design-significant: yes — this changes WHERE the crew binding is enforced (adds it to the close path,
  the artifact `CLAUDE.md` declares the close depends on), closing a hole the S138 dogfood proved live.
  It is a mechanical extension of the S132/S133 house pattern (a close gate that calls a `vajra next
  --check-*` binary gate), not a new mechanism. Cite the S135 crew gate + DECISION-007
  (`docs/decisions/DECISION-007-agent-fleet.md`, the S135 addendum — verified to exist).
- **Rejected alternatives (design-advisor rec 2 — a rationale with no rejected option is not a
  decision):**
  - *Re-implement the crew logic in shell* vs. *shell out to the real `vajra next --check-crew`
    binary.* REJECTED the re-impl: a second copy of the `crew_gate` contract in bash would drift from
    `src/crew`, the exact single-source discipline the Obeyed/Mandate close checks already keep.
  - *Fix the hole by making every close run `--advance`* vs. *add an independent close check.*
    REJECTED `--advance`: a real close never invokes it — that IS the S138 hole. The binding has to
    live where the close actually runs (`verify-closeout.sh`).
  - *A new top-level command* vs. *ride `verify-closeout.sh` + the existing `vajra next --check-crew`.*
    REJECTED the new command (the max-7 ceiling).
- **The founder waiver vs. the binary's "no environment variable can bypass" (design-advisor rec 3).**
  `src/crew/mod.rs` prints "(No environment variable can satisfy or bypass this gate.)" and this check
  greens on `VAJRA_CLOSEOUT_WAIVER=N`. This is NOT a contradiction: that sentence forbids a
  crew-specific `VAJRA_SKIP_*` an AGENT can set on its own command line (and none exists — the crew
  decision is provenance-verified). `VAJRA_CLOSEOUT_WAIVER` is the ONE universal, founder-held,
  session-scoped, un-forgeable-by-the-agent closeout escape that every check in `verify-closeout.sh`
  already honors (S56/S93); keeping this check consistent with its siblings is the correct call, and
  dropping the waiver here would make one close check uniquely un-waivable for no stated reason.
- The tech-lead is the FIRST and MANDATORY dispatch; it decides which specialists S139 needs and its
  verdict BINDS on this session (record its handoff). Let the design-advisor / implementation-advisor /
  qa-specialist / fidelity-reviewer be dispatched or reasoned-skipped **as the tech-lead decides** —
  and record each required role's governed handoff, because this session's own close now runs
  `check_required_crew` (criterion 3, the self-binding test).

## Acceptance (testable, EARS-style)

1. WHEN `verify-closeout.sh` runs, THEN a new `check_required_crew` executes `vajra next --check-crew N`,
   binds on its exit code, and requires the gate's own header (`=== crew: tech-lead for session`) so an
   unknown flag routed to `run_dump` (exit 0) cannot silently green it; a missing binary FAILS
   (cannot-evaluate), and `VAJRA_CLOSEOUT_WAIVER=N` waives — identical to `check_obeyed_judgments`.
2. WHEN a session's tech-lead handoff is absent, OR a role the tech-lead marked `required` has no
   `.ai/handoffs/session-N-<role>.md`, THEN `verify-closeout.sh` FAILS — proven by a falsifiability
   fixture that goes RED for that exact reason and GREEN once the handoff(s) exist (the S122 "fail for
   the RIGHT reason" bar; the positive control must assert a clean exit 0, the S134 bar).
3. The gate BINDS ON S139 ITSELF: this session records a real `session-139-tech-lead.md` handoff plus a
   governed handoff for every role that handoff marks `required`, and S139's own `verify-closeout.sh`
   passes `check_required_crew` — not merely a future session (the S125/S129/S134 "make the closing
   session pass its own new gate" rule).
4. WHEN `vajra init` scaffolds a fresh project, THEN its `verify-closeout.sh` carries
   `check_required_crew` too (proven from the `include_str!` source or a scaffold check), so a stranger's
   close is bound the same way.
5. `scripts/verify-session-139.sh` (exits 0, FAIL-on-absent, class tally printed) + `demo-session-139.sh`
   (the 4 sprint markers) + `sessions/session-139-summary.md` with the fidelity map + exactly 3 ranked
   next candidates.

## Plan (ordered — cite the acceptance criteria each step covers)

1. Dispatch the tech-lead FIRST on a named-files brief (`scripts/verify-closeout.sh`, the S135 crew
   gate source, `src/mandate`/`src/crew`); record its handoff + let it bind the crew. covers: 3
2. Add `check_required_crew` to `verify-closeout.sh` mirroring `check_obeyed_judgments`; insert it into
   `main()`'s check list. covers: 1, 4
3. Write a falsifiability fixture (required-role handoff present → GREEN; removed → RED for that reason;
   positive control asserts clean exit 0). covers: 2
4. Record every required role's handoff so S139's OWN close passes the new gate; write
   `verify-session-139.sh` + `demo-session-139.sh` + the summary. covers: 3, 5

## Execution (the Coder gate — fill each step's landing sha as work lands)

- step 1 — done: <sha>. covers: 3
- step 2 — done: <sha>. covers: 1, 4
- step 3 — done: <sha>. covers: 2
- step 4 — done: <sha>. covers: 3, 5

## Guardrails

- **Make the gate BIND ON S139 ITSELF** (acceptance 3) — building a gate no session runs is this repo's
  oldest failure (S125/S129), and S138 proved it live. S139's close must pass its own `check_required_crew`.
- **The fixture must fail for the RIGHT reason** (S122) and the positive control must assert a clean
  exit 0 (S134), not just one green line.
- **Do NOT add an eighth top-level command** (max 7) — this rides `verify-closeout.sh` + the existing
  `vajra next --check-crew`. **Do NOT weaken** `check_obeyed_judgments` / `check_design_advisor_mandate`.
- **`--check-crew` requires a tech-lead handoff to exist** — so a session that never records one now
  fails the close. That is the intended behavior; ensure S139 records its own (criterion 3).
- **Out of scope, disclosed, NOT this session:** the self-certification of the fidelity review itself
  (a review FILE with the right form passes `check_fidelity_review` regardless of who wrote it — S138B
  showed a closing agent can finalize + attest its own review). Name it as the next-after gap; do not
  try to prove reviewer independence from a file here.
- **Budget every subagent dispatch TIGHT: named files, never "read the repo"** (S134; $20/mo plan).
- Un-forgeable `VAJRA_ALLOW_COMMIT=139` on every commit. Attest LAST (S69/S131): recompute
  `--inputs-sha 139` after every prompt edit; run the FULL `verify-closeout.sh` on the branch BEFORE
  merging (S83). **Next GT: S140** (the session AFTER this is the mandatory NO-CODE ground truth).

## Delta (vs ROADMAP — OpenSpec markers)

- `+` `verify-closeout.sh` gains `check_required_crew` — the tech-lead's `required` verdict now binds at
  CLOSE, not only at `--advance`; a session cannot close green with a required role skipped.
- `~` the S135 crew gate moves from "advisory unless `--advance` is run" to "enforced at every close".
- `-` the "required is not required" gap (S138) — retired for the close path.
- **Disclosed remainder:** reviewer-independence self-certification (S138B) stays open — next candidate.
