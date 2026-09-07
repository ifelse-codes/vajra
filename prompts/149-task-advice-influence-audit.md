# Session 149 — DOCUMENT: advice-influence audit

## Goal

Prove (or disprove) that crew advice actually changes session work — not just that it was dispatched and acknowledged.

The open finding since S133: **a role was dispatched ≠ its advice reached the design**. S138 showed
the tech-lead's required crew was ignored end-to-end with no gate catching it. S147 showed all 5
quiet roles gave "Changed" advice on paper — but that grading was self-reported. This session
independently re-grades advice influence for 3 recent sessions and produces a clear recommendation.

## Deliverable

`sessions/session-149-advice-influence-audit.md` — an audit report that:

1. Selects 3 recent sessions where `implementation-advisor` and/or `fidelity-reviewer` handoffs
   are recorded (look for `obeyed:` disposition blocks in the session summaries/reviews).
2. For each session: lists every piece of specific advice given (by `rec N` or numbered item)
   and grades it **Changed** / **Noted** / **Hollow** with a one-line evidence citation.
   - **Changed** — a specific decision, code change, or deliverable item is traceable to this advice;
     cite the commit SHA or the section that changed.
   - **Noted** — the advice was acknowledged in writing but nothing in the diff changed because of it.
   - **Hollow** — the advice was generic enough that it cannot be tied to any specific output; or the
     handoff exists but no specific advice is recorded.
3. A summary table: session × role × verdict (Changed / Noted / Hollow) × count.
4. **Recommendation** (yes/no + 2–3 sentences): should we build a mechanical check that forces
   the session author to record which advice they acted on and how? Or is that enforcement likely
   to produce fake compliance?

## Design

design-significant: no

design-advisor: skipped — DOCUMENT session; `design-significant: no` declared above; deliverable is a single markdown file with no architecture surface; no ADR or design record is created or modified.

No new gates, no new code, no new Vajra commands. This is evidence-gathering before any enforcement
decision. The only artifact is the audit report.

## Plan

covers: 1 — Select 3 sessions with recorded advisor handoffs (implementation-advisor or
  fidelity-reviewer with specific `rec N` items in `.claude/agents/` or session summaries)

covers: 2 — For each session: read the handoff, read the diff / summary, grade each piece of
  advice Changed / Noted / Hollow with evidence

covers: 3 — Write summary table (session × role × verdict × count)

covers: 4 — Write recommendation section (yes/no + reasoning on mechanical enforcement)

covers: 5 — Fidelity review: cold pass grades the audit against AC1–AC4

## Acceptance Criteria

- **AC1** — 3 sessions selected, each with at least one `implementation-advisor` or
  `fidelity-reviewer` handoff that contains specific numbered advice (not just a verdict line).
- **AC2** — Every piece of advice in each handoff is graded Changed/Noted/Hollow with a
  one-line evidence citation; no advice item is skipped or merged with another.
- **AC3** — Summary table present; counts add up to the per-session advice totals.
- **AC4** — Recommendation section present; takes a clear yes/no position with reasoning.
- **AC5** — `sessions/session-149-advice-influence-audit.md` committed and the verify script
  asserts it exists and contains the summary table header.

## Guardrails

- NO new code. NO new gates. NO changes to Rust source, scripts, or `.ai/` files except
  `STATE.md`, `TASK.md`, `ROADMAP.md`, and `KNOWLEDGE.md` at closeout.
- Session summaries and role handoff files are READ ONLY evidence; do not edit them.
- Grades must cite EVIDENCE (diff, SHA, quoted text) — not the advisor's own claim that the
  advice was followed.
- If a handoff exists but no specific advice is recorded, grade the whole handoff as Hollow
  and note it; do not upgrade the grade to Noted on the strength of a general verdict.

## Delta

**Why now:** The F2f gap (advice-influence) has been named in AGENTS.md since S133, flagged again
at S138 (tech-lead's required crew ran but was ignored). S147 did a self-reported "Changed" audit
on 5 quiet roles — this session does an INDEPENDENT re-grade on the high-stakes roles
(implementation-advisor, fidelity-reviewer) to get honest numbers before deciding whether to build
enforcement.

**What changes:** one new file (`sessions/session-149-advice-influence-audit.md`). Nothing else.
