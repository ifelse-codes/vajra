# Session 152 — Obedience Documentation Rule + Carry-Forward Audit

## Goal

Close two governance gaps S149 exposed:

1. When an agent skips or disobeys a recommendation, it must explain WHY — not just tag it
   `deferred:` or `refused:` with a throwaway note. A proper written justification must be present.

2. When a rec is carried forward to a future session, it must name that session explicitly —
   so it lands on the ROADMAP and is not silently lost.

Both rules go into `.ai/AGENTS.md`. Then audit the 8 hollow carry-forwards from S149 and route
each one to a named session or retire it with a reason.

## Deliverables

1. **Obedience-skip rule** — written into `.ai/AGENTS.md` (obedience section):
   when a builder does not follow a rec (marks it `deferred:` or `refused:`), they MUST write
   a proper explanation — what the rec said, why it is being skipped, and (if deferred) which
   session will address it. A one-word label with no explanation is not acceptable.
   Example format:
   ```
   refused: rec 3 from implementation-advisor — reason: the recommended approach conflicts with
   ADR-0003's passthrough contract; fixing at the architecture level is deferred to S154.
   ```

2. **Carry-forward rule** — written into `.ai/AGENTS.md` (fidelity-reviewer section):
   a rec carried forward from a prior session MUST name a target session in the ROADMAP.
   A re-copy with no named target is hollow and must be graded as NOT-BUILT by the next reviewer.

3. **Audit the 8 hollow carry-forwards from S149** — read `sessions/session-149-review.md` and
   the S149 fidelity-reviewer's findings. For each of the 8 hollow items:
   - Assign a named target session and add a ROADMAP entry, OR
   - Retire it with a one-line reason (already closed, no longer relevant).
   Write the full disposition in `sessions/session-152-carryforward-audit.md`.

4. **Update ROADMAP** — each non-retired item from the audit gets a real ROADMAP entry
   naming the session that will address it.

## Design

design-significant: no

design-advisor: skipped — prose rule additions to AGENTS.md and a ROADMAP audit; no new
architecture, no ADR impact, no code changes.

## Guardrails

- Zero code changes. `.ai/AGENTS.md` and `.ai/ROADMAP.md` edits only (plus the audit doc).
- Do NOT invent enforcement gate code — that is a future CODE session if the rules prove needed.
- Do NOT touch sessions other than routing the 8 S149 orphans.
- Rules go into AGENTS.md as prose, not new files.

## Acceptance criteria

1. `.ai/AGENTS.md` contains the obedience-skip rule: a skipped/refused rec must carry a proper
   written justification (what, why, when — not a one-word label).
2. `.ai/AGENTS.md` contains the carry-forward rule: a carried-forward rec must name a target
   session; re-copy without a target = hollow = NOT-BUILT at next review.
3. `sessions/session-152-carryforward-audit.md` dispositions all 8 S149 hollow items
   (assigned-to-session or retired-with-reason — none left undisposed).
4. Every non-retired item has a matching ROADMAP entry naming its target session.
5. `verify-closeout.sh` exits 0.

## Delta

**Why now:** S149 measured 36% hollow advice (8/22). The S149 reviewer recommended banning
carry-forward without a named target. S150 GT confirmed it. Two compounding failures: (a) skipped
recs have no required explanation so reviewers cannot judge whether the skip was justified;
(b) carried-forward recs have no required destination so they disappear between sessions.

**What is NOT in scope:** enforcement gates, code changes, sessions other than S149's 8 items,
redesigning any role's core contract.

**What S155 GT will audit:** whether the two rules exist in AGENTS.md, whether the ROADMAP entries
name real future sessions, and whether any of those sessions have since been completed.
