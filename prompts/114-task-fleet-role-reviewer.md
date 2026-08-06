# Session 114 — CODE: build the second fleet role — the Reviewer

> **Status: APPROVED (scope)** — founder pick **A** at the S113 closeout. S113 *chose* this role from
> evidence and recorded why (`DECISION-007` S113 addendum); S114 *builds* it. The other two S113
> candidates stay deferred: the paid `vajra claude` dogfood (B, 🔴 since S103 — now 11 sessions) and
> an opt-in blocking consumption gate (C).

## Goal

The fleet has exactly one named role (the Researcher). The job it should obviously cover next is the
one this repo already does **every single session, by hand**: the independent cold fidelity review
that DECISION-002 makes mandatory and that 46 `sessions/*-review.md` files record. Today its brief is
re-typed from memory each time — the exact drift the canonical `fleet::ROLES` source exists to kill.

Ship the Reviewer as a **second governed role**, using the same machinery as the first: one canonical
role definition → scaffolded subagent file → a governed, validated handoff. Nothing about the
handoff format, the dispatch mechanism, or the command set changes.

## Deliverables

1. A second entry in `fleet::ROLES` — the Reviewer — with a **read-only tool set** and a system
   prompt that states the adversarial cold-review contract (fed only the prompt + the diff; grade
   every numbered requirement SHIPPED/PARTIAL/NOT-BUILT; name the fakest green; never self-certify).
2. `vajra init` scaffolds `.claude/agents/<key>.md` for it from that one source — no second copy of
   the role text anywhere.
3. `vajra next --role <key> --from <findings>` governs its verdict into a validated handoff, exactly
   as it does for the Researcher. Fail-closed behaviour unchanged.
4. **The name collision resolved explicitly** (the S113 addendum's open item): a role keyed
   `reviewer` reads ambiguously against the **Reviewer station** already counted in `K of 8`. Pick a
   distinct key or state in the code + the decision record that the role IS that station's agent.
   Silence is a FAIL.
5. **The double-record question answered, in writing:** the fidelity verdict already lives in
   `sessions/session-NN-review.md` (read by `verify-closeout.sh`, attested by `Review-Inputs-SHA`,
   chained in the ledger). Decide and record whether the handoff is a *pointer to* that artifact, a
   *pre-stage input* to it, or a duplicate to be avoided — and make the code match the decision.
   Two competing records of the same judgment is the failure mode to avoid.
6. `scripts/verify-session-114.sh` + `scripts/demo-session-114.sh`, both green, both proving
   behaviour — the fleet counter (S113) must show **two** governed handoffs when both exist, with
   `K of 8` unchanged.
7. `sessions/session-114-summary.md` + an independent cold review (`sessions/session-114-review.md`),
   two passes if the first finds a real hole (the pattern has now paid off four sessions running).

## Non-goals (not built this session)

- No third role, no parallel dispatch, no multi-stage orchestration (still deferred, DECISION-007).
- No 8th top-level command — this rides `init` + `next`, like the Researcher.
- No blocking gate: nothing new fails a session (candidate C stays deferred).
- No change to the handoff format, the dispatch mechanism, or the S113 counter's contract.
- Do NOT replace the existing `sessions/session-NN-review.md` artifact or the closeout gate that
  reads it.

## Design

- design-significant: yes
- The load-bearing choices, to be recorded in a `DECISION-007` S114 addendum (the decision record
  this design cites):
  - **the role key** (collision with the Reviewer station — deliverable 4), and
  - **the handoff's relationship to `sessions/session-NN-review.md`** (deliverable 5).
- **Reuse, do not re-derive:** `fleet::ROLES` + `render_subagent_definition` + `format_handoff` /
  `validate_handoff` / `read_handoffs` already do all of the work. If this session writes a second
  scaffolding path, a second handoff writer, or a second role-text source, that is the defect.
- **Known mechanism limit (S111, still true):** a `.claude/agents/*.md` written mid-session is
  invisible to that same session's Task tool — Claude Code snapshots the agent files at boot. The
  role lands this session and is first dispatchable by name in the NEXT one. Plan the proof around
  that; do not claim an in-session by-name dispatch.

## Plan (ordered steps — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)

1. <first ordered step — replace me; annotate which acceptance criteria it satisfies>
2. <next step — the Planner gate BLOCKS until every acceptance criterion above is covered>

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha — the real commit that landed this step; the Coder gate BLOCKS closing the
  session until every numbered plan step records a commit that EXISTS>

## Acceptance criteria

1. `vajra init` in a fresh repo scaffolds **two** agent files, both rendered from `fleet::ROLES` —
   proven by running it, not by reading the code.
2. `vajra next --role <key> --from <file>` writes a handoff that `validate_handoff` accepts, and
   fails closed on unknown role / missing `--from` / empty findings (same guarantees as slice 1).
3. With both roles' handoffs present for one session, `vajra next --stations NN` reports
   **2 governed handoffs, naming both roles**, and `K of 8` is unchanged — the S113 invariant holds
   at the count that did not exist when it was written.
4. The name collision and the double-record question are both decided **in writing** in a
   `DECISION-007` S114 addendum, and the code matches those decisions.
5. `cargo test --lib` green; `verify-session-114.sh` + `demo-session-114.sh` both exit 0.
6. Independent cold review (fed only prompt + diff) — SHIPPED/PARTIAL/NOT-BUILT per numbered
   requirement, plus the fakest green, disclosed.

## Guardrails

- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Branch: `session-114-<slug>`. Approval token required before any commit
  (`VAJRA_ALLOW_COMMIT=114 git commit …`).
- Communicate in the plainest English (founder standing request).
- Own the `.ai/` spine — no second store, no unapproved 8th command.
- Darshan every human reply · Varta against the live `.ai/`.
- **Reuse `named_test_passed()`** for any check naming a single test (a bare `cargo test --lib
  <filter>` exits 0 on a filter matching zero tests).
- **`[[:space:]]`, never `\s`, in any script check** — BSD/macOS `grep -E` reads `\s` as a literal
  `s` (S113 pass 1). Pair every negative guard ("X was NOT built") with a positive control.
- **Never claim an agent ran because a handoff exists** (S113): a contract-valid handoff proves a
  file, not a dispatch.

## Delta (vs ROADMAP — OpenSpec markers)

- `+` the fleet gets its second named role — the job this repo already performs every session by
  hand becomes canonical, scaffolded, and governed.
- `~` `fleet::ROLES` grows from one entry to two; `vajra init` scaffolds two agent files; the S113
  fleet line reports two governed handoffs.
- `-` retires the S113 addendum's two open items (the role key collision, the double-record
  question) and the standing 🟡 "the fleet has exactly one role".
