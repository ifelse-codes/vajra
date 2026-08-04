# Session 112 — CODE: downstream handoff-consumption

> **Status: APPROVED** — proposed at S111 closeout, confirmed by the founder at S112 kickoff
> ("approved continue"). The alternative on the table (S110 GT candidate C, a second fleet role)
> stays deferred: a lone unread handoff gets *more* orphaned, not less, if a second role doubles
> the count before anything reads the first.

## Goal

`vajra next --role researcher --from <findings>` writes a governed, validated handoff to
`.ai/handoffs/session-NN-researcher.md` — but nothing downstream reads it. The 8-station pipeline and
the fleet are, right now, two overlapping stories that never actually touch: a founder (or a future
agent) has to know to go look in `.ai/handoffs/` by hand. Make at least ONE existing station
(recommend: the Analyst, since a researcher's findings naturally feed the WHAT stage) surface a
session's researcher handoff automatically when one exists for that session — so the fleet's output
actually feeds the pipeline it claims to be part of, not just a filed-away artifact.

## Deliverables

1. A READER for governed handoffs in `src/fleet/` — parse a validated handoff back into its parts,
   with the three honest outcomes (absent · malformed · found) and a renderer that inlines findings.
2. The Analyst consumes it: `vajra next --intake` (and `--scaffold`, which prints the same intake)
   folds this session's governed findings in as a first-class input.
3. The packet (`vajra next`) and the Analyst gate (`vajra next --validate NN`) surface it too, so
   the agent that boots on the packet sees the research without being told to look.
4. `scripts/verify-session-112.sh` + `scripts/demo-session-112.sh`, both green, both proving the
   behaviour end-to-end (not the file's existence).
5. `sessions/session-112-summary.md` + an independent cold review (`sessions/session-112-review.md`).

## Non-goals (not built this session)

- A second fleet role — stays deferred (S110 candidate C, DECISION-007).
- Changing the handoff format itself (frontmatter contract, `## Handoff Delta`) — S109/S111 both
  treat that as locked; this session only adds a READER, not a new WRITER contract.
- An unattended `claude -p` dispatch mode — still DECISION-007-deferred.
- No 8th top-level command. This rides an existing surface (`next`), not a new one.
- No BLOCKING gate on unread findings. Consumption is advisory this session; making it enforceable
  is a separate decision (a gate that fires on an artifact an agent may legitimately not need would
  be a false-teeth gate).

## Design

- design-significant: yes
- New public surface in an existing module (`fleet::parse_handoff` / `read_handoff` /
  `read_handoffs` / `format_handoff_brief`) plus a changed signature (`analyst::gather_intake`).
  It rests on `DECISION-007-agent-fleet.md`: the handoff contract and its location in the `.ai/`
  spine stay exactly as locked — this session adds the read direction the decision always implied
  ("the `.ai/` spine IS the memory") and never a second store or a new artifact type.
- Shape chosen: the PARSER stays pure (`parse_handoff`), and the fs read is one narrow, read-only
  edge in the same module. The alternative — putting the reader in `analyst` — was rejected because
  the handoff contract belongs to `fleet` (one owner, no drift), and every future consuming station
  would then have to reach through the Analyst to read it.
- The path, not the frontmatter, is the session source of truth: a handoff found at session 112's
  path IS session 112's, whatever its `session:` line claims. This mirrors the house pattern of
  existence-gating recorded markers rather than trusting a self-assertion.

## Plan (ordered steps — cite the acceptance criteria each step covers)

1. Add the read side to `src/fleet/mod.rs` — `parse_handoff` (pure), `read_handoff`/`read_handoffs`
   (fs-read-only), `format_handoff_brief` (inlines findings), with unit tests for
   absent/malformed/found and path-is-SoT. `covers: 2`
2. Wire it into the Analyst's intake in `src/analyst/mod.rs` — `Intake.fleet_handoffs`, rendered
   inline; absence renders nothing; a malformed handoff is named. `covers: 1, 2`
3. Surface it on the packet and the Analyst gate in `src/cli/next.rs`. `covers: 1, 2`
4. Write `scripts/verify-session-112.sh` + `scripts/demo-session-112.sh` with the live end-to-end
   before/after proof and the real-data (session 111 handoff) check. `covers: 3, 4`
5. Write the summary + fidelity map and take an independent cold review. `covers: 5`

## Execution (the Coder gate — each plan step's landing commit)

- step 1 — done: 3cba22c3c8b81219ce887c2f4687248eb071c620
- step 2 — done: 29639f6b573e03fc2ef7fa69eee5a75c72377b22
- step 3 — done: 8c0867c51e58437b449a3f4b7d500fa3c8ea3875
- step 4 — done: 68b8766baa6f14fc2a5286783b81331d7e924f78
- step 5 — done: <sha — recorded at closeout>

## Acceptance criteria

1. At least one existing station's `vajra next` output visibly surfaces the current session's
   researcher handoff when one exists, with the findings inlined (a path alone is not consumption).
2. Absence is silent and harmless — a session with no handoff behaves exactly as today, no new
   warnings or failures. A handoff that exists but is off-contract is NAMED, never swallowed.
3. A real end-to-end proof: govern a handoff through the real writer, then show the consuming
   station's output actually changed because of it — not just "the file exists, trust me."
4. `cargo test --lib` green; CI both OS; a `verify-session-112.sh` + `demo-session-112.sh` pair,
   both exiting 0.
5. Independent cold review (fed only prompt + diff) — SHIPPED/PARTIAL/NOT-BUILT per numbered
   requirement, plus the fakest green, disclosed.

## Guardrails

- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Branch: `session-112-handoff-consumption`. Approval token required before any commit.
- Communicate in the plainest English (founder standing request).
- Own the `.ai/` spine — no second store, no unapproved 8th command.
- Darshan every human reply · Varta against the live `.ai/`.

## Delta (vs ROADMAP — OpenSpec markers)

- `+` the READ direction for governed fleet handoffs: `fleet::read_handoffs` +
  `format_handoff_brief`, consumed by three Analyst surfaces.
- `~` `analyst::gather_intake` now takes the session whose fleet handoffs to fold in; the intake
  block gains a `fleet handoffs` section when (and only when) one exists.
- `-` retires the S110/S111 carried gap "nothing downstream consumes the researcher handoff".
