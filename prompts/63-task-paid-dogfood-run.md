# Session 63 — Paid dogfood run: measure the governed loop as EXPERIENCE (PAID)

> **Status:** APPROVED (founder standing "all approved" + S62-close pick **A**). **Type: PAID DOGFOOD**
> (mostly run + measure + report; minimal-to-no `src/` change — this is a measurement session, not a feature).
> The whole S55→S62 arc (fidelity gate → attestation → ledger → the now-complete Analyst) is proven as
> **machinery** (154 lib tests) but **UNMEASURED as lived experience** — no paid `vajra claude` run since S52
> (10 sessions; two Ground-Truths flagged `dogfood_check` 🟡🔴 OVERDUE). S63 spends ~$1–5 to close that gap.

## Type
- **PAID DOGFOOD.** Max 2 assumptions · 2 retries · ~2h · **1 story** · new chat · approval token before any
  commit. Budget: **cap ~$5** (`total_cost_usd` is authoritative — the vajra receipt overstates ~8×, S52).

## Goal
Run **one real, non-trivial task** through `vajra claude` (the governed loop, on a real subject repo — e.g.
chitra, or another repo the founder names) and answer the question the arc has never measured: **is the governed
loop good to USE?** Capture the authoritative `total_cost_usd`, observe which governance actually fired live
(Darshan obedience, Varta/co-pilot murmur, the Analyst gate, the fidelity/attestation/ledger closeout), and
judge — honestly — whether governance *helped the work*, was *neutral overhead*, or *got in the way*. This is a
measurement, not a feature: the deliverable is evidence + an honest verdict, not new binary behavior.

## Acceptance (what must be answered — testable, EARS-style)
1. **WHEN** a real task runs through `vajra claude` **THEN** the session records the authoritative
   `total_cost_usd` (not the receipt) + which hooks/gates fired live, captured in
   `sessions/session-63-dogfood.md` — a non-author can see the real spend + the real governance events.
2. **WHEN** the run completes **THEN** the report maps each governance surface (Darshan · Varta/co-pilot ·
   Analyst gate · fidelity/attestation/ledger closeout) to *fired / did-not-fire / helped / hindered*, with
   evidence (transcript lines, receipts, artifacts), and `vajra meter --all` obedience% for the session.
3. **The honest verdict (state plainly):** did governance make the work *better*, *neutral*, or *worse*, and is
   `dogfood_check` refreshed 🟢 (a paid run happened) — or does the arc stay UNMEASURED? No guessing; the cost
   ledger is the proof.

## Deliverables
- `sessions/session-63-dogfood.md` — the run's evidence: task, subject repo, `total_cost_usd`, governance-fired
  table, `vajra meter` obedience%, and the honest good-to-use verdict.
- `scripts/verify-session-63.sh` (exits 0) — asserts the dogfood report exists + records a real `total_cost_usd`
  + the governance-fired table + the obedience read; whatever `src/` changed (if any) stays green (fmt/clippy/test).
- `scripts/demo-session-63.sh` + the interactive HTML demo when asked.
- `sessions/session-63-summary.md` + **an independent cold fidelity review** (`sessions/session-63-review.md`,
  the DECISION-002 gate) + exactly 3 ranked S64 candidates.
- If the run surfaces a real bug (e.g. the receipt ~8× overstatement, the guard nested-repo blindspot), record it
  — do NOT fix it this session unless it blocks the measurement (1-story discipline).

## Guardrails
- **Slice to ONE story** — one real task, measured. Do NOT start the Planner stage or fix backlog bugs this session.
- **Authoritative cost only** — `total_cost_usd` from the transcript, NEVER the vajra receipt (overstates ~8×, S52).
- **Run backgrounded** — headless Opus builds exceed the 10-min foreground cap (S52 lost ~$1.4 to a mid-verify kill).
- **Honest null is a valid result** — if governance is neutral or worse, say so plainly (S51/S52 were honest nulls
  on "better work"; this measures *experience*, a distinct axis). Do not rescue the thesis.
- Darshan every human reply · Varta against the live `.ai/`. Approval token before any commit; **S65 = mandatory GT**.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` A paid `vajra claude` dogfood measurement of the governed loop as *experience* (`sessions/session-63-dogfood.md`),
  refreshing `dogfood_check` 🟢 after 10 unmeasured sessions.
- `~` Turns the S55→S62 arc from "proven machinery, UNMEASURED experience" into a real, cost-ledgered reading;
  updates the running cost total + STATE's dogfood status.
- `-` Retires the standing `dogfood_check` 🟡🔴 OVERDUE flag (or, if governance hinders, converts it into a named,
  evidenced defect to fix later).
