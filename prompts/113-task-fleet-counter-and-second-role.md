# Session 113 — CODE: make fleet work visible to the counter, then choose the second role

> **Status: APPROVED (scope)** — founder pick **A** at the S112 closeout. Confirm the shape at
> kickoff (specifically: which of the three counter designs below), then execute. The other two S112
> candidates stay deferred: the paid dogfood run (B, 🔴 stale since S103) and an opt-in blocking
> consumption gate (C).

## Goal

Vajra can now write a governed fleet handoff (S109), prove it came from a real by-name subagent
dispatch (S111), and read it back into the pipeline (S112). **The pipeline's own progress metric
cannot see any of it.** `vajra next --stations NN` reports K of 8 stations, and a session that
dispatched a named agent, governed its findings, and consumed them downstream scores exactly the same
as one that did none of that. This gap has been flagged at S110 GT, carried at S111, and carried
again at S112 — three sessions of "flagged, not fixed".

Make fleet work **measurable** by the counter, without breaking what K means. Then **choose** the
second fleet role, from evidence about what the pipeline actually lacks.

## Deliverables

1. Fleet work is visible in `vajra next --stations NN` — derived from real evidence on disk (a
   governed, contract-valid handoff for session NN), never a self-asserted marker.
2. **K-of-8 stays comparable across sessions.** Whatever the design, a reader must be able to compare
   S74's K to S113's K and have it mean the same thing. If the chosen design changes K's definition,
   the prompt's `## Design` must say so explicitly and the ROADMAP/STATE must carry the break.
3. A recorded decision on **the second fleet role** — which one, and why it is the one the pipeline
   most lacks — written into the DECISION-007 record as an addendum. Choosing it is the deliverable;
   *building* it is NOT (see non-goals).
4. `scripts/verify-session-113.sh` + `scripts/demo-session-113.sh`, both green, both proving
   behaviour: the same repo, the same command, and the counter output differs *only* because fleet
   evidence exists.
5. `sessions/session-113-summary.md` + an independent cold review
   (`sessions/session-113-review.md`) — two passes if the first finds a real hole (the S67/S112
   pattern, which has now paid off three sessions running).

## Non-goals (not built this session)

- **Do not BUILD the second role.** Slice 1 ships one role by decision (DECISION-007); adding a
  second is its own session, taken only after this one records *which* and *why*.
- No 8th top-level command — this rides `next`, like everything else the fleet does.
- No blocking gate. Fleet evidence reports; it does not fail a session (S112 candidate C, still
  deferred).
- No change to the handoff format or the dispatch mechanism.
- Do not "fix" the K number retroactively for past sessions.

## Design

- design-significant: yes
- The load-bearing choice is **where fleet evidence lands relative to K**. Three shapes, with the
  known trade-off of each — the session must pick ONE at kickoff and record why:
  - **(a) A 9th station.** Honest and visible, but breaks the "8 stations" spine that
    `DECISION-001`/the ROADMAP and every past K reading rest on. Cross-session K becomes
    incomparable.
  - **(b) Fold it into an existing station's verdict** (e.g. the Analyst PASSES partly because a
    governed handoff informed the WHAT). Keeps K at 8, but silently changes what an existing PASSED
    means — the most dangerous option, because old and new K look identical while measuring
    different things.
  - **(c) Report it as a separate line beside K** ("fleet: 1 governed handoff, consumed"), leaving
    the 8-station K untouched. **Recommended.** K stays comparable by construction; fleet work stops
    being invisible; nothing about an existing verdict changes.
- Whichever is chosen, the evidence must be DERIVED (read the handoff off disk and validate it, as
  `fleet::read_handoffs` already does), never a marker an author types.
- **PICKED AT KICKOFF (S113, founder "all approved"): shape (c) — a separate line BESIDE K.**
  **K-of-8's meaning is UNCHANGED**: the eight stations, their classifiers, and the count they
  produce are untouched, so S74's K and S113's K mean exactly the same thing (criterion 3 is
  satisfied by preservation, not by recording a break). Fleet evidence is an ADDITIONAL derived
  line — never a 9th station (a), never folded into an existing station's verdict (b). Rejected
  (a) because it breaks the 8-station spine every past K reading rests on; rejected (b) because
  old and new K would look identical while measuring different things — the exact false green this
  project exists to kill.
- Evidence source: `fleet::read_handoffs(root, session)` — a contract-valid handoff on disk counts;
  a malformed one is NAMED and does not count; no fleet work prints nothing at all.

## Plan (ordered steps — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)

1. Derive fleet evidence in `src/stations/mod.rs` — a `FleetEvidence` value on `StationReport`,
   built by calling `fleet::read_handoffs(root, session)` (validated on disk, never a typed marker),
   holding the roles whose handoff is contract-valid and the paths+reasons of any malformed one.
   It contributes **nothing** to `passed()`/`K of 8`. `covers: 1, 2, 3`
2. Render it as a separate line beside K in `stations::format_station_report` — silent when the
   session has no fleet artifact at all (output byte-identical to today), a `fleet:` line when a
   governed handoff exists, and a `⚠ … — not counted` line naming a malformed one. `covers: 1, 2, 3`
3. Unit tests in `src/stations/mod.rs` against a tempdir: valid handoff → fleet line present and K
   unchanged · malformed handoff → named, not counted, K unchanged · absent → output identical to
   the pre-change render. `covers: 1, 2, 5`
4. Record the **DECISION-007 addendum**: which role is second, and the evidence from this repo that
   drove the choice. Decision only — no role code, no `fleet::ROLES` entry. `covers: 4`
5. `scripts/verify-session-113.sh` + `scripts/demo-session-113.sh`, both exit 0, both proving the
   BEHAVIOUR (same repo, same command, output differs only because fleet evidence exists); every
   single-test check goes through `named_test_passed()` from `scripts/verify-session-112.sh`.
   `covers: 1, 2, 5`
6. `sessions/session-113-summary.md` with the per-requirement fidelity map, then an independent
   cold review into `sessions/session-113-review.md` (second pass if pass 1 finds a real hole).
   `covers: 6`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: aec216e
- step 2 — done: aec216e
- step 3 — done: aec216e (hardened by 94f369a + 993cd71 after cold-review passes 1 and 2)
- step 4 — done: 394444d
- step 5 — done: d0ade90
- step 6 — done: d041d04

## Acceptance criteria

1. `vajra next --stations NN` surfaces fleet evidence for a session that has a governed handoff, and
   surfaces nothing new for one that does not — proven by running the same command against both.
2. The evidence is derived from the handoff on disk (validated, not merely present) — a malformed
   handoff must not read as fleet work done.
3. K-of-8 is either unchanged in meaning, or its change is explicitly recorded in `## Design`, STATE
   and ROADMAP. A silent redefinition is a FAIL.
4. The second role is chosen and the reasoning recorded in the DECISION-007 addendum, with what
   evidence drove it. No role is built.
5. `cargo test --lib` green; a `verify-session-113.sh` + `demo-session-113.sh` pair, both exit 0.
6. Independent cold review (fed only prompt + diff) — SHIPPED/PARTIAL/NOT-BUILT per numbered
   requirement, plus the fakest green, disclosed.

## Guardrails

- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Branch: `session-113-<slug>`. Approval token required before any commit
  (`VAJRA_ALLOW_COMMIT=113 git commit …`).
- Communicate in the plainest English (founder standing request).
- Own the `.ai/` spine — no second store, no unapproved 8th command.
- Darshan every human reply · Varta against the live `.ai/`.
- **Reuse `named_test_passed()` from `scripts/verify-session-112.sh`** for any check that names a
  single test — a bare `cargo test --lib <filter>` exits 0 when the filter matches nothing, so it is
  green after that test is renamed or deleted (S112 cold-review pass 2).

## Delta (vs ROADMAP — OpenSpec markers)

- `+` fleet work becomes measurable by the pipeline's own progress counter (the S110 GT meta-check,
  carried unfixed through S111 and S112).
- `~` `vajra next --stations` gains fleet evidence in its report; K-of-8's meaning is preserved or
  its change is recorded explicitly.
- `-` retires the carried 🟡 "the K-of-8 counter has no unit for fleet work", and the open question
  "which role is second?".
