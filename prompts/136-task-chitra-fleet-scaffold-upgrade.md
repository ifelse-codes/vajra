# Session 136 — chitra-fleet-scaffold-upgrade: make the ten-role fleet REAL in the one outside project

> **Status:** DRAFT — the Analyst gate (`vajra next --advance`) BLOCKS starting this session while
> DRAFT. Flip to `APPROVED` once the founder signs off.
>
> **This is the DEFAULT S136 pick (candidate 1 from the S135 summary). The founder may re-pick at the
> S136 start** — the other two candidates are **(2) phase 1b, the all-nine observation** (budgeted
> from S135's ~4–5M-raw numbers) and **(3) close criterion 7** (carry the recorded budget into each
> role's dispatch brief — a small read surface, no ladder edit, turns S135's 11/12 into 12/12).
> Founder directive in force (S118): README/VISION claims are the target spec, not softened.

## Type
- **CODE**. Max 2 assumptions · 2 retries · ~2h · 1 story · new chat · approval token before any commit.

## Goal

Upgrade chitra's Vajra scaffold from 4 of 9 role files to the full TEN-role roster (the nine
specialists + the `tech-lead`), so the S135 crew gate is a REAL feature in the one project that is
not Vajra itself. Today chitra carries 4 of 9 `.claude/agents/*.md` and 0 of 8 stations wired, so
`vajra next --check-crew` there could never bind — the `tech-lead` is a Vajra-only feature until this
lands (the exact "true here, decorative there" gap the founder named). This session makes the roster
real in chitra; it does NOT run a paid dogfood (that is its own session, gated on the founder).

## Deliverables
- chitra's `.claude/agents/` carrying all TEN role definitions, rendered from Vajra's ONE canonical
  source (`fleet::render_subagent_definition`) — never hand-typed, so no drift (the S104/S99 rule).
- A recorded account, in chitra's own spine, of what the scaffold upgrade changed and what it did NOT
  (stations, thresholds, the crew gate's applicability at chitra's current maturity level).
- `scripts/verify-session-136.sh` (exits 0) proving the ten files exist in chitra AND match Vajra's
  canonical render byte-for-byte (a drift check, run against a REAL chitra checkout, machine-local).
- `sessions/session-136-summary.md` + exactly 3 ranked next candidates.

## Acceptance (what must be answered — testable, EARS-style)
1. WHEN the verify script lists chitra's `.claude/agents/`, THEN all ten role files are present
   (`researcher … release-coordinator … tech-lead`), each matching `fleet::render_subagent_definition`
   byte-for-byte — a hand-typed or drifted copy FAILS, never a silent skip (S69).
2. WHEN `vajra next --check-crew <chitra-session>` is run inside chitra, THEN it BEHAVES per chitra's
   maturity level, and the summary states plainly what that behaviour is (block vs advise) and why —
   the S135 crew gate's real applicability in a real outside project, measured not assumed.
3. The summary states plainly whether chitra now carries the STATIONS too, or only the ROLE FILES —
   S134 found chitra at `0 of 8` stations at `maturity: L3`; this session must not let a roster
   upgrade read as a pipeline chitra is not actually running.
4. chitra's in-flight work is UNDISTURBED, proven the S134 four ways (HEAD, index hash, stash list,
   branch identical; every new path pre-declared by name).

## Design (the Architect gate — record the decision, cite the ADR/DECISION it rests on)
- design-significant: <yes|no — decide with the design-advisor; likely `no` if this is pure scaffold
  rendering with no new interface, `yes` if it changes how `vajra init`/upgrade writes into an
  existing governed project>
- <rationale — dispatch the design-advisor FIRST (the S133 mandate) to decide whether upgrading an
  ALREADY-GOVERNED project's scaffold needs a new mechanism or reuses `vajra init`'s existing
  skip-if-present render; cite DECISION-007 (the fleet) and its S135 addendum (the tech-lead)>
- design-advisor: <DELETE this line and dispatch the role instead, or record a substantive skip reason>

## Plan (ordered steps — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)
1. <dispatch the design-advisor FIRST; decide the upgrade mechanism (reuse `vajra init` render vs new). covers: 1>
2. <render + place the ten role files into chitra from the canonical source. covers: 1>
3. <run `vajra next --check-crew` inside chitra; record its real behaviour at chitra's maturity. covers: 2, 3>
4. <prove chitra undisturbed the four ways; write verify + summary. covers: 4>

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>

## Guardrails
- Slice to ONE story. Own the `.ai/` spine — no second store, no unapproved 8th command.
- Darshan every human reply · Varta against the live `.ai/`.
- **chitra has its own constitution and its own hooks — read `chitra/.ai/` and obey chitra's rules
  inside chitra. Do NOT import Vajra's. Do NOT disturb its in-flight work** (S134's rule, reused).
- **Do NOT run a paid dogfood this session** — the roster upgrade is the story; a dogfood is its own
  founder-gated session (D2, still outstanding).
- Budget every subagent dispatch TIGHT: a narrow brief and NAMED FILES, never "read the repo" (S134).
  On the $20/mo plan, S135 held 4 dispatches to ~2.5M raw by naming files — keep that discipline.
- Report the RAW subagent token total, never a new-tokens-only figure (S134 45× / S135's own 20× catch).

## Delta (vs ROADMAP — OpenSpec markers)
- `+` chitra's `.claude/agents/` gains the six missing specialist files + the `tech-lead` — the full
  ten-role roster, so the S135 crew gate is real in the one outside project.
- `~` the `tech-lead` stops being a Vajra-only feature (the S135 disclosed gap narrows toward closed).
- `-` nothing retired.
