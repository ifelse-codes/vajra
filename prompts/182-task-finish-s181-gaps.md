# Session 182 — finish S181's own gaps: ship the controls into existing projects

> **Status:** DRAFT — the founder picks this from S181's three options and approves it with `vajra approve 182` in his own terminal (the gate reads that record, not this line).

## Type
session_type: CODE
- **CODE**. Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.

## Evidence
`sessions/session-181-review.md` (pass 2 recs 1–3 and the disclosed limits), `sessions/session-181-summary.md`, `docs/decisions/DECISION-011-controls-the-agent-cannot-type.md`.

## Goal
S181 made the founder's controls hard for the agent to type in Vajra's own repo. A project that already uses Vajra (rudra) gets none of it: `--sync-fleet` never edits its settings and does not ship the approvals hooks. Close that, and fix S181's two carried test gaps.

## Deliverables
1. `scripts/verify-session-181.sh:75`: replace the whole-suite check with a positive assertion (at least one `test result: ok`, no `FAILED`, non-zero cargo exit fails).
2. A gate-level obeyed-handoff test in `tests/stamp_gate.rs` (edit the findings, run `vajra next --check-obeyed`).
3. Ship the Write/Bash approvals guards to scaffolded projects (`.ai/hooks/`, stamped, so `--sync-fleet` upgrades them).
4. `vajra init --sync-fleet` reports (never edits) a project with no `session_rules_from`, naming the exact line to add and the session to use.
5. Tie the `--allow-all` record to one session number (the branch it was launched on, or the session named at launch).

## Acceptance
1. The whole-suite verify check fails when the test suite does not compile (fixture proves it).
2. Editing an obeyed-handoff's findings makes `--check-obeyed` block, end to end.
3. A freshly scaffolded project blocks an agent Write/Bash into its approvals folder; an old project gets the hook through `--sync-fleet`.
4. `--sync-fleet` on a project without `session_rules_from` prints the line to add and writes nothing to its settings file.
5. An `--allow-all` record for session A does not approve session B.
6. Every check runs the real thing (no source greps); `verify-closeout.sh` exits 0 on the branch before merge.

## Design
design-significant: _to be decided by the design-advisor_ (Deliverables 3–5 change the scaffold and the approval gate; cite DECISION-011).

## Plan
_(the agent writes this with the plan-advisor; every step cites `covers: N`.)_

## Execution
_(step N — done: <sha> as work lands.)_

## Guardrails
- No autonomous commits: the founder runs them, or launches with `VAJRA_ALLOW_COMMIT=182`. The agent never sets it.
- ≤3 files per commit; ≤2 assumptions; ≤2 retries. A fresh cold fidelity review at close (F81).
- Guard changes only add (S173). No new ceremony; nothing that polices Vajra's own paperwork.
- Parked, NOT this session: other coding tools (OpenCode first), F67 receipt pricing, release/publish.

## Delta
- `+` approvals hooks shipped to scaffolded projects; `--sync-fleet` report for a missing `session_rules_from`; `--allow-all` tied to a session; obeyed-gate stamp test
- `~` `scripts/verify-session-181.sh` whole-suite check
- `-` nothing removed
