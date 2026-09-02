---
role: design-advisor
session: 139
agent: claude-code-subagent (verified: toolu_01Q7kezA5787JEyxiqJiuTfs)
source-sha: 901be142237f7fd761027aeb147bcd79cea7df742468acd509bd85c67d54f53f
captured: 2026-09-02T05:08:05Z
cost_usd: null
---

# Design-advisor handoff — session 139

Verified against the spine: `docs/decisions/DECISION-007-agent-fleet.md` exists and its **S135 addendum** ("the `tech-lead`, the tenth role") locks exactly the crew gate the design cites — provenance-verified tech-lead handoff, every `required` role produces a real handoff, phase-1 no-off-switch, threshold 0. The citation resolves.

**Verdict:** The change is faithful and the set-e-safe deviation is the RIGHT call — endorse it. But before close the author owes two written decisions: the `## Design` names no rejected alternatives (a description, not a decision), and it does not reconcile the founder waiver with DECISION-007's literal "no environment variable can bypass this gate." Both are exactly the class the Architect gate cannot catch — it checks the citation resolves, not whether the design obeys what it cites.

rec 1 — Affirm `design-significant: yes` and the DECISION-007 / S135 citation; both hold. This adds a NEW enforcement site to the close path and extends a LOCKED decision's reach (the S135 crew binding moves from `--advance`-only to every close). That is a changed enforcement surface plus a scope change to a locked record — squarely `yes`, not a pure fix. The cited record and its S135 crew-gate addendum both exist; do not downgrade this to `no`.

rec 2 — Add the rejected alternatives to the `## Design` body. As written it argues "mechanical extension of the S132/S133 house pattern" but names nothing it turned down. The real forks this change made: (a) re-implement the crew logic in shell vs. shell out to the real `vajra next --check-crew` binary — rejected re-impl because it would drift from `src/crew`; (b) fix the hole by making every close run `--advance` vs. adding an independent close check — rejected `--advance` because a real close never invokes it (that IS the S138 hole); (c) a new top-level command vs. riding `verify-closeout.sh` — rejected the command (max-7). One line each. A rationale with no rejected option is not yet a decision.

rec 3 — Resolve, in the `## Design`, whether the founder waiver is a DEVIATION from the record it cites. `src/crew/mod.rs` prints, verbatim, "(No environment variable can satisfy or bypass this gate.)" — yet `check_required_crew` greens on `VAJRA_CLOSEOUT_WAIVER=N`. Either (a) state in the `## Design` why the founder-held, session-scoped, un-forgeable-by-agent closeout waiver is categorically NOT the "off switch" DECISION-007 forbids (this is the function comment's position, and it is defensible — it is the universal closeout escape, not a crew-specific `VAJRA_SKIP_*`), or (b) if the founder intends the crew close-gate to be as unwaivable as the in-binary gate advertises, drop `waiver_ok` from this check. Do not leave the two records silently contradicting each other; the Architect gate passes a citation that the design disobeys.

rec 4 — Endorse the set-e-safe capture (`out="$(...)" && code=0 || code=$?`) — it is correct: on failure `code=$?` binds the real exit status, and the AND-OR list's last command always succeeds so `set -e` never fires. AND: the two siblings carry the identical latent bug. `check_obeyed_judgments` and `check_design_advisor_mandate` use the bare `out="$(...)"; code=$?`, which under `set -euo pipefail` ABORTS the whole script the instant `--check-obeyed`/`--check-design-handoff` exits non-zero — i.e. on THEIR OWN blocking path (a mismatch or a missing mandate), before the FAIL reason prints and before the summary runs. That is the exact S122 "fail for the wrong reason." Prefer hardening all three in this session — same file, a one-list change per site, hardening not weakening (the guardrail forbids weakening, not this). If one-story/budget forbids it, record it as a numbered next candidate and fix the comment, which as written reads as if the bare form is safe in the siblings — it is not; it is merely un-exercised.

rec 5 — Placement is acceptable: the checks are independent (each appends to `RESULTS` and bumps `PASS`/`FAIL`), so order is cosmetic, not load-bearing. Optional improvement: move `check_required_crew` ABOVE `check_design_advisor_mandate`, to mirror the real dispatch order — the tech-lead is the FIRST/MANDATORY dispatch and is the gate that decides whether the design-advisor is even `required`. Note the deliberate overlap so it is on the record, not discovered later: when the tech-lead marks `design-advisor` required, that role is now gated twice (its own S133 mandate check plus this crew check) — belt-and-suspenders, both fail-closed, not a bug.

rec 6 — Prove the run_dump header-guard rather than assume it. The defense against an old/gate-less binary is grepping for `=== crew: tech-lead for session`, but that string is emitted by the CLI surface, not by `src/crew`. In the S122 fixture, assert that the REAL `vajra next --check-crew` output actually contains that exact header (so a future CLI wording drift is caught, not silently converted to a fail-closed block), and exercise an unknown-flag / gate-less path to show the guard truly BLOCKS. Disclose the shared residual, since it applies equally to the two siblings: if `run_dump` can echo agent-authored file content, the header string can be planted in a dumped file to force exit-0-plus-header — a narrow false-green vector inherent to the house "grep the output for a header" pattern.

rec 7 — Confirm the S131 local-machine-only provenance limit does not newly red CI or a stranger's close. `check_required_crew` shells to a binary that re-verifies the tech-lead (and every required role's) dispatch against `~/.claude/projects`; a runner with no such history fails closed. DECISION-007's S131 addendum explicitly says that provenance gate "is not wired into any CI/remote closeout path today." Verify the same is true here — that the binary-backed close checks are run only locally pre-merge (S83), not in a CI path that would now BLOCK every session that lacks local dispatch history.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (5968 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
