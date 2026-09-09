# Session 159 — Advice-influence re-audit: did S152's rules reduce the Hollow rate?

> **Status:** APPROVED — founder pick (2026-09-09)

## Type
- **DOCUMENT** (~1.5h cap)

## Goal

S149 audited advice from design-advisor and fidelity-reviewer across S146/S147/S148 and found:
- **22 items graded: 13 Changed (59%) · 1 Noted · 8 Hollow (36%)**
- **Implementation-advisor: 85% Changed. Fidelity-reviewer: 22% Changed.**
- Root cause: "carry-forward, non-blocking" is a dispose-and-forget label — every rec so labelled graded Hollow.

S152 added a rule to fix this: the carry-forward label is banned without a named target session; a rec without a target must be written as `carry-forward → SNN` or acknowledged as Noted in the summary.

We now have **6 sessions of new data** (S153–S158) to measure whether the rule changed behaviour. Run the same audit methodology on S153–S158 and report the new Changed/Noted/Hollow breakdown. The question is simple: did the rule work?

## Acceptance criteria

| AC | Criterion |
|----|-----------|
| AC1 | `sessions/session-159-advice-influence-reaudit.md` exists and covers all 6 sessions (S153–S158), all mandatory-dispatch advice items from design-advisor and fidelity-reviewer |
| AC2 | Each advice item is graded Changed/Noted/Hollow with a corroborating evidence citation (SHA, file:line, or explicit "no evidence") — not the advisor's own claim |
| AC3 | A summary table reports the new overall rate and compares it to the S149 baseline (59% Changed, 36% Hollow) |
| AC4 | Key findings section states plainly whether the carry-forward rule reduced the Hollow rate, with the numbers to back it |
| AC5 | `scripts/verify-session-159.sh` passes — at minimum: audit file exists and is non-trivial (≥ 100 lines), summary table present, all 6 sessions referenced |

## Guardrails

- **No code changes.** No edits to `scripts/`, `src/`, or `.ai/AGENTS.md`. This is a read-and-measure session.
- Grade advice from **design-advisor** and **fidelity-reviewer** only — the same roles as S149. Skip tech-lead and implementation-advisor (different influence dynamic; keeping the comparison clean).
- Evidence must be **corroborating** — a commit SHA, a file:line, or a statement in the session summary that names the advice item. The advisor's own claim that advice was followed does not count.
- Do not grade sessions S149–S152 again — those are the baseline, already reported.

## Plan

1. For each session S153–S158: read the design-advisor handoff (`.ai/handoffs/session-NNN-design-advisor.md`) and the fidelity-reviewer handoff (`.ai/handoffs/session-NNN-fidelity-reviewer.md`); extract all recommendations. covers: 1
2. Grade each rec Changed/Noted/Hollow using the session summary (`sessions/session-NNN-summary.md`) or review file as corroborating evidence. covers: 2
3. Build the summary table: session-by-session breakdown + overall rate vs S149 baseline. covers: 3
4. Write key findings: did the carry-forward rule work? What new patterns emerged? covers: 4
5. Write `scripts/verify-session-159.sh`. covers: 5

## Design

design-significant: no

Pure measurement session — no new code, no new interface, no ADR. Reads handoffs and session summaries; produces a report and a verify script. No architectural decision surface.

## Delta

S149 established the baseline and diagnosed the Hollow problem. S152 added the carry-forward rule. This session measures the outcome — did 6 sessions of the new rule change the rate? If yes, the mechanic works. If no, the next step is a structured enforcement gate (S149 said "if Noted > 30% after a re-audit, build the mechanical check").
