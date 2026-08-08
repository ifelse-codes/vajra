# Session 116 — CODE: build the third fleet role — the Planner

> **Status: APPROVED (scope + role)** — founder pick at the S115 closeout: **B** (a third fleet role),
> then, asked to name it, **Planner** specifically — a read-only subagent, staying in the same
> advisory shape as roles 1–2 (Researcher, Fidelity Reviewer), not a code-writing role (Coder), which
> was named as a bigger, separate governance step and was NOT picked. The paid `vajra claude` dogfood
> (🔴 since S103 — now 12+ sessions, flagged again at S115) stays deferred, by explicit founder call,
> not by neglect — the S115 report names this and recommends the next GT revisit it if S117 doesn't
> reach it either.

## Goal

The fleet has two named roles (Researcher, Fidelity Reviewer), both proven end-to-end including
by-name dispatch (S111, and — for the Reviewer — S115). Add a third: the **Planner**, a subagent that
helps map a session's acceptance criteria into ordered plan steps, each citing the criteria it covers
(`covers: N`) — the same shape the Planner **station** (S64, `src/planner/mod.rs`) already grades.
Same machinery as roles 1 and 2: one `fleet::ROLES` entry → scaffolded subagent file → a governed,
validated handoff. Nothing about the handoff format, dispatch mechanism, or command set changes.

## Deliverables

1. A third entry in `fleet::ROLES` — the Planner — with a **read-only tool set** (Read/Grep/Glob,
   matching roles 1–2's pattern; no Write/Edit — the role proposes a plan, it does not write one into
   the prompt file itself) and a system prompt stating its contract: fed the session's goal +
   acceptance criteria, propose ordered plan steps, each explicitly citing which criterion/criteria it
   covers, in the exact `covers: N` shape `src/planner/mod.rs` already parses and grades.
2. `vajra init` scaffolds `.claude/agents/<key>.md` for it from that one source — no second copy.
3. `vajra next --role <key> --from <findings>` governs its output into a validated handoff, exactly as
   for roles 1–2. Fail-closed behaviour unchanged.
4. **The name collision resolved explicitly, in writing** — same open item the Reviewer hit
   (`DECISION-007` S114 addendum) and the exact reason its key is `fidelity-reviewer`, not `reviewer`.
   A role keyed `planner` reads ambiguously against the **Planner station** already counted in
   `K of 8` (`src/planner/mod.rs`, S64). Pick a distinct key (recommend something in the shape of
   `plan-advisor` or `planning-assistant` — final wording is this session's call) or state explicitly,
   in code + the decision record, that the role IS that station's agent and why that is not the same
   trap `reviewer` almost fell into. Silence is a FAIL — the same rule DECISION-007 already enforces.
5. `scripts/verify-session-116.sh` + `scripts/demo-session-116.sh`, both green, both proving
   behaviour — the fleet counter (S113) must show **three** governed handoffs when all three exist in
   one session, `K of 8` unchanged.
6. `sessions/session-116-summary.md` + an independent cold review
   (`sessions/session-116-review.md`) — **dispatch it with `subagent_type: "fidelity-reviewer"` by
   name**, now proven live and working (S115); do not fall back to an ad-hoc `general-purpose`
   subagent. Two passes if the first finds a real hole (the pattern has paid off five sessions
   running, REJECTED once at S114).

## Non-goals (not built this session)

- No fourth role, no parallel dispatch, no multi-stage orchestration (DECISION-007 still defers this).
- No 8th top-level command — rides `init` + `next`, like roles 1–2.
- No blocking gate: nothing new fails a session.
- No change to the handoff format, the dispatch mechanism, or the S113 counter's contract.
- Do NOT give the Planner role write access to the prompt file, plan file, or any source — it proposes,
  it does not author. (This is a stronger constraint than roles 1–2 needed to state explicitly, because
  "planning" sounds adjacent to "editing the plan" in a way "researching" and "reviewing" did not.)
- Do NOT touch `src/planner/mod.rs`'s station-side grading logic — the role's output is read by a
  human or a future station-side consumer, not auto-fed into the Planner station's own gate this
  session (that would be a second, larger story: consumption, mirroring S112's Researcher-handoff
  consumption arc, deliberately deferred).

## Design

- design-significant: yes
- The load-bearing choice to record in a `DECISION-007` S116 addendum: **the role key** (collision
  with the Planner station — deliverable 4), with rejected alternatives, mirroring the S114 addendum's
  shape exactly.
- **Reuse, do not re-derive:** `fleet::ROLES` + `render_subagent_definition` + `format_handoff` /
  `validate_handoff` / `read_handoffs` already do all of the work — S114 proved this needs zero
  changes to `vajra init`, zero new handoff writer. If this session writes any of those a second time,
  that is the defect.
- **Dispatch-by-name is now proven, not a mechanism limit to route around** (S111 found it fails
  mid-creating-session; S115 proved it works in the very next fresh session). Plan the proof the same
  way S115 did: this session cannot dispatch a subagent named `<planner-key>` on itself (created
  mid-session, same S111 limit), but it CAN — and should — dispatch `fidelity-reviewer` by name for
  its own closeout cold review, since that role already exists from S114/S115.

## Plan (ordered steps — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)

1. Add the `<planner-key>` entry to `fleet::ROLES` with its read-only tool list and system prompt
   (the `covers: N` contract, fed goal + acceptance criteria, proposes ordered steps). One source, no
   second scaffolding or handoff path. `covers: 1, 2`
2. Record the `DECISION-007` S116 addendum: the role key and why (distinct from `planner`, mirroring
   the `fidelity-reviewer` precedent), with rejected alternatives. `covers: 4`
3. Scaffold this repo's own `.claude/agents/<planner-key>.md` from that one source, byte-identical to
   `render_subagent_definition` output. `covers: 1`
4. Write `scripts/verify-session-116.sh`: a fresh `vajra init` scaffolds THREE agent files all
   byte-equal to the render; the new role's fail-closed set; THREE handoffs in one session →
   `fleet: 3 governed handoff(s)` naming all three roles while `K of 8` stays byte-identical to the
   no-fleet report; the existing no-second-source guard extended to cover the third role.
   `covers: 1, 2, 3, 5`
5. Write `scripts/demo-session-116.sh` (cumulative) showing all three roles, the governed handoff, and
   the three-handoff fleet line, with the required demo markers. `covers: 5`
6. Run `cargo test --lib` + both scripts green, then dispatch `subagent_type: "fidelity-reviewer"` by
   name for the independent cold review (prompt + diff only), and write the session summary with the
   per-requirement fidelity map. `covers: 5, 6`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: db61455
- step 2 — done: db61455
- step 3 — done: e9d1c3d
- step 4 — done: e9d1c3d
- step 5 — done: e9d1c3d
- step 6 — done: 688a544

## Acceptance criteria

1. `vajra init` in a fresh repo scaffolds **three** agent files, all rendered from `fleet::ROLES` —
   proven by running it, not by reading the code.
2. `vajra next --role <key> --from <file>` writes a handoff that `validate_handoff` accepts, and fails
   closed on unknown role / missing `--from` / empty findings (same guarantees as roles 1–2).
3. With all three roles' handoffs present for one session, `vajra next --stations NN` reports
   **3 governed handoffs, naming all three roles**, and `K of 8` is unchanged.
4. The name collision is decided **in writing** in a `DECISION-007` S116 addendum, and the code
   matches the decision.
5. `cargo test --lib` green; `verify-session-116.sh` + `demo-session-116.sh` both exit 0.
6. Independent cold review, dispatched via `subagent_type: "fidelity-reviewer"` **by name** (fed only
   prompt + diff) — SHIPPED/PARTIAL/NOT-BUILT per numbered requirement, plus the fakest green,
   disclosed. Report whether the raw returned verdict landed in gate-passing shape unedited, or needed
   reformatting — the S115 GT found a real gap here (a table-wrapped `**Verdict:**` line fails the
   gate's regex); if it recurs, name it again rather than silently reformatting past it.

## Guardrails

- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Branch: `session-116-<slug>`. Approval token required before any commit
  (`VAJRA_ALLOW_COMMIT=116 git commit …`).
- Communicate in the plainest English (founder standing request).
- Own the `.ai/` spine — no second store, no unapproved 8th command.
- Darshan every human reply · Varta against the live `.ai/`.
- **Reuse `named_test_passed()`** for any check naming a single test.
- **`[[:space:]]`, never `\s`, in any script check** — BSD/macOS `grep -E` reads `\s` as a literal `s`.
- **Never claim an agent ran because a handoff exists**: a contract-valid handoff proves a file, not a
  dispatch. (This session, uniquely, CAN additionally claim a real dispatch for the cold review itself
  — `fidelity-reviewer` already exists and is proven dispatchable; say so precisely, don't conflate it
  with the new role, which is NOT dispatchable in its own creating session, per S111.)
- **Attest LAST** (S69, hit twice at S114): recompute `Review-Inputs-SHA` after the prompt's Execution
  shas are committed; confirm two consecutive `--inputs-sha` runs agree before embedding.

## Delta (vs ROADMAP — OpenSpec markers)

- `+` the fleet gets its third named role — a read-only Planner subagent, in the same advisory shape
  as roles 1–2.
- `~` `fleet::ROLES` grows from two entries to three; `vajra init` scaffolds three agent files; the
  S113 fleet line reports three governed handoffs.
- `-` retires the S116 addendum's one open item (the role key collision, resolved in writing).
