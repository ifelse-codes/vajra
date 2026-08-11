# Session 117 — CODE: prove the Plan Advisor dispatches by name

> **Status:** APPROVED (founder pick A at the S116 closeout — "dispatch the Plan Advisor for real").
> Written at S116 closeout per `end_of_session.must_write_next_prompt_before_close`.

## Type
CODE — one story, ≤3 files per atomic commit, ~2h cap.

## Goal
S116 shipped the fleet's third role, the Plan Advisor (`plan-advisor`), as a scaffolded
`.claude/agents/plan-advisor.md` and a governed `vajra next --role plan-advisor --from` path — but
per the S111 limit, an agent file written mid-session is invisible to that same session's Task tool,
so the role has never actually been dispatched. This is a **fresh session** — the S116 commit that
wrote `.claude/agents/plan-advisor.md` is already on `main` (or its merged branch) by the time this
session boots, so the mechanism S115 proved for the Fidelity Reviewer (by-name dispatch works cleanly
in the very next fresh session) should hold here too. Prove it, on the third role, the same rigorous
way: not a copyable JSON blob, but independent evidence that the Task tool actually resolved
`subagent_type: "plan-advisor"` against the scaffolded file.

## Plan (ordered — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)
1. Inside this live session, dispatch `subagent_type: "plan-advisor"` on a real planning question —
   e.g. "propose ordered plan steps for a small real task in this repo, citing `covers: N` against a
   short list of acceptance criteria you are given" — and record whether the dispatch resolves by
   name on the first try (S115's finding) or still requires the boot-snapshot workaround. `covers: 1`
2. Capture independent evidence the dispatch was real and by-name (not a hand-typed copy of the
   prompt): the tool-call record naming `plan-advisor` as the resolved `subagent_type`, matched
   against the subagent's own transcript/meta, mirroring the S111 two-file cross-check. `covers: 1, 2`
3. Govern the subagent's returned plan proposal into `.ai/handoffs/session-117-plan-advisor.md` via
   the existing `vajra next --role plan-advisor --from` path — unchanged mechanism, real content.
   `covers: 2`
4. Confirm `vajra next --stations 117` reports the governed handoff beside `K of 8`, `K` unchanged —
   the same invariant re-exercised at a THIRD role's real dispatch, not just a written file. `covers: 3`
5. Write `scripts/verify-session-117.sh` + `scripts/demo-session-117.sh` (cumulative); confirm
   `cargo test --lib`, fmt, clippy, `fleet-smoke.sh` still green. `covers: 4`
6. Dispatch `subagent_type: "fidelity-reviewer"` by name for the independent cold review (prompt +
   diff only); write the session summary with the per-requirement fidelity map. `covers: 5`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: b52483b
- step 2 — done: b52483b
- step 3 — done: d09185a
- step 4 — done: 6d51c46
- step 5 — done: 6d51c46
- step 6 — pending

## Design
- design-significant: no — no new interface, no new module. This session proves an existing
  mechanism (S109/S111/S115's dispatch-and-govern path) on the third role and documents the finding
  as a `DECISION-007` addendum only if the result differs from S115's (e.g. if the mid-creating-session
  limit turns out NOT to have retired the way S115 showed for the Reviewer — that would itself be a
  load-bearing finding to record in writing, not silently absorb).

## Non-goals (not built this session)
- A fourth role, parallel dispatch, or multi-stage orchestration (`DECISION-007` still defers this).
- Consuming the Plan Advisor's output into the Planner **station**'s own grading logic (`src/planner/mod.rs`)
  — still the separate, larger consumption story named as a non-goal at S116.
- No 8th top-level command. Rides `init` + `next`, like roles 1–3.
- No blocking gate: nothing new fails a session.
- The overdue paid `vajra claude` dogfood (🔴 since S103, now 13+ sessions) — the founder explicitly
  chose this dispatch-proof over it again at the S116 closeout; if S117 does not reach it either, the
  next ground truth (S120) should press on it.

## Acceptance criteria
1. A real Plan Advisor subagent dispatch, `subagent_type: "plan-advisor"`, resolved by name inside
   this fresh session — recorded plainly whether it worked on the first try or needed a workaround.
2. Independent, non-copyable evidence of the real dispatch (matching tool-call/transcript identifiers
   across two independently-written files), not merely a governed handoff file existing.
3. The real subagent's plan proposal governed into `.ai/handoffs/session-117-plan-advisor.md`, and
   `vajra next --stations 117` reports it beside `K of 8` with `K` unchanged.
4. `cargo test --lib` green; `verify-session-117.sh` + `demo-session-117.sh` both exit 0.
5. Independent cold review, dispatched via `subagent_type: "fidelity-reviewer"` **by name** (fed only
   prompt + diff) — SHIPPED/PARTIAL/NOT-BUILT per numbered requirement, plus the fakest green,
   disclosed. Report whether the raw returned verdict landed in gate-passing shape unedited (the S115
   GT found a table-wrapped `**Verdict:**` line fails the gate's regex — name it again if it recurs).

## Guardrails
- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Branch: `session-117-<slug>`. Approval token required before any commit
  (`VAJRA_ALLOW_COMMIT=117 git commit …`).
- Communicate in the plainest English (founder standing request).
- Darshan every human reply · Varta against the live `.ai/`.
- **Never claim an agent ran because a handoff exists** — a contract-valid handoff proves a file, not
  a dispatch. This session's whole point is to supply the missing dispatch evidence for role 3.
- **Attest LAST** (S69, hit twice at S114): recompute `Review-Inputs-SHA` after the prompt's Execution
  shas are committed; confirm two consecutive `--inputs-sha` runs agree before embedding.
- New chat for S117 (one vajra-session per chat).

## Delta (vs ROADMAP — OpenSpec markers)
- `+` the fleet's third role gains a real, evidenced by-name dispatch (not just a scaffolded file).
- `~` no change to `fleet::ROLES`, the handoff format, or the dispatch mechanism — this session
  supplies evidence, not new code paths.
