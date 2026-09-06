# Session 147 — Prove the 5 Quiet Roles

**Type:** CODE (files written, subagents dispatched; no Rust `src/` changes)
**Branch:** `session-147-prove-quiet-roles`
**Session:** 147

---

## Goal

Five of the ten fleet roles have been dispatched two or fewer times across 147 sessions:
`researcher` · `plan-advisor` · `demo-producer` · `release-coordinator` · `requirements-analyst`.

The open finding (F2, S140+S145): **a bound dispatch ≠ good advice.** Nobody has yet observed what these five actually produce on a real brief, or whether their output would change any work.

This session provides that evidence. Each role is dispatched — on a narrow, named-file brief — against the upcoming S148 task (cost-cutting: reduce the $11.74/session dogfood spend). Their advice is recorded verbatim, judged for whether it would change S148's design, and the audit is written to `sessions/session-147-quiet-roles-audit.md`.

---

## Acceptance criteria

1. All five roles dispatched with a narrow brief (named files only, no "read the repo").
2. Each role's advice recorded verbatim in the audit report.
3. Each advice block judged: **Changed** (the S148 draft was updated as a result) · **Noted** (recorded, not actioned, with stated reason) · **Hollow** (no signal — say so plainly).
4. `sessions/session-147-quiet-roles-audit.md` written and committed.
5. `prompts/148-task-<slug>.md` written (incorporating any Changed advice).
6. `verify-session-147.sh` exits 0 (structural + content checks — no live code to run).
7. `verify-closeout.sh 147` exits 0 including `check_required_crew`.
8. tech-lead dispatched FIRST; its required-role list honored (design-advisor, implementation-advisor, fidelity-reviewer minimally).

---

## Guardrails

- Each dispatch brief: ≤ 5 named files, one focused question. No "read everything."
- If a role returns hollow or incoherent advice, record it honestly — do NOT re-dispatch.
- If a dispatch dies mid-flight, mark it INCOMPLETE and do not self-certify.
- Cost cap: $5. If cumulative spend approaches $4, stop dispatching and report remaining as INCOMPLETE.
- No src/ Rust changes — session delivers documents only.
- Roles are dispatched against the S148 brief, not S147 itself (avoids circular grading).

---

## What this proves (or disproves)

A role that returns hollow or wrong advice when given a tight brief is decoration. A role that catches something real earns its mandate. The honest answer — whichever it is — is the payload.

---

## Design

`design-significant: no` — no new mechanism, no ADR needed. This session calls existing fleet dispatch infrastructure and writes session documents. The role-rendering machinery already exists; this is its first systematic five-role observation.

## Plan

Steps to be written after tech-lead dispatch and plan-advisor advice are incorporated.
