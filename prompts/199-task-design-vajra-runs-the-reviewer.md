# Session 199 — DESIGN: Vajra runs the required reviewer itself (Haiku answer d) + the README "tested with" line (c)

> **Status:** DRAFT — written by the S198 agent from the founder's pick (2026-10-15: option 2 of
> `sessions/session-198-summary.md`, "Design: Vajra runs the reviewer"). The founder reads it and runs
> `vajra approve 199` in his own terminal; the gate reads the record, not this line.

## Type
session_type: DOCUMENT
- **DOCUMENT (design only — no code).** Max 2 assumptions · 2 retries · ~2h · 1 story (the design record) · new chat.

## Goal
Write down how Vajra itself — not the session's agent — launches the required cold review at close, on a model
Vajra picks, so a cheap coding model cannot skip the review or write its own "independent" ACCEPT (rudra S20 on
Haiku 4.5: 0 helpers ran, the agent wrote its own review, the close went RED and it said "fully closed" — F122).
And put the founder's own "tested with" words in the README (S195 answer c). Nothing is built this session.

## Deliverables
1. **The design record** — a DECISION-007 addendum or a new DECISION-012 (the design-advisor recommends which; the
   founder decides) that answers, each with the option chosen and the ones rejected:
   - **when** Vajra launches the review (inside `verify-closeout.sh`, a `vajra review NN` the close calls, or at
     `vajra claude`'s exit) and what the agent may still do by hand;
   - **how** it runs (`claude -p`, the fidelity-reviewer's own definition, read-only tools, which inputs — the prompt
     and the branch diff only, as DECISION-002 says) and **on which model** (picked by Vajra or the founder, never
     the session's; no hand-kept list of "small" models — the S195 price-list lesson);
   - **cost and time** per close, said plainly, and who says yes to spending it (no paid run without the founder's
     yes — today's rule);
   - **where the verdict lands** (`sessions/session-NN-review.md` + its stamp, or a record the agent cannot write,
     like `.ai/approvals/`), and how the close tells it from a review the agent typed;
   - **what it replaces** — the S131/S133 "the agent dispatches the reviewer" rule (DECISION-002/-007) and the
     `required-crew` / `fidelity-handoff` close checks — and what stays;
   - **projects**: how a `vajra init` project gets it (`--sync-fleet`), and what happens with no `claude` on PATH or
     a non-Claude tool (F91/F94/F95 stay parked — name, don't design);
   - **the limit**: what an agent can still fake (bar-raising, not tamper-proof — name it like DECISION-011 does).
2. **The README "tested with" line (option c)** — the founder's own words, given in-session: an observed fact
   (instruction-only steps followed on Opus in rudra S16–S19 and S21; skipped on Haiku 4.5 in S20; the blocks held on
   both), never a softened promise (VISION/README are the spec).
3. **The build plan** — the next CODE session's steps, sized to one session, written into ROADMAP (not built).

## Acceptance
| AC | Check |
|---|---|
| AC1 | The record exists under `docs/decisions/` (addendum or new file), answers every question in D1 with the choice and the rejected options, and names its limit. |
| AC2 | The README carries the "tested with" line in words the founder approved in-session (quoted in the summary). |
| AC3 | ROADMAP has the build session's plan; the record and the plan agree on what is replaced and what stays. |
| AC4 | `scripts/verify-session-199.sh` checks the record's sections and the README line by reading the files (a DOCUMENT session); no code changes on the branch (a `git diff --stat` against the session's start commit shows no `src/` / `scripts/hook-*` change). |

## Design
design-significant: yes
- A new or changed decision record that deviates from DECISION-002/-007's "the agent dispatches the reviewer". The
  design-advisor runs before the record is written (S133 mandate).

## Carried in
- **From S198 (founder pick, 2026-10-15):** F118 and N18 fixed (`sessions/session-198-summary.md`); ROADMAP's
  known-bug list keeps S197 design-advisor rec 10 (a `--steps` line for the close record), F126, the rest of N7,
  F97's opt-out key, `tests/gt_cadence_shared.rs`'s loose assertion, S188's named gaps → the S200 checklist.
- **Carried from S198 (its tech-lead rec 5):** record whether S198's GREEN push went through the S196 push belt — no
  S198 commit can show a push that happens after its own close. Write it into S198's summary at this session's start,
  from `gh pr view <S198's PR>` and the close result for its head (`.ai/verify/closeout/<stamp>/result`).
- **The evidence to design from:** `sessions/session-195-ground-truth.md` Goal 2 (options a–d, the founder-approved
  verdicts) · `sessions/session-194-summary.md` (rudra S20 on Haiku: Agent 0, self-written review, RED close) ·
  `sessions/session-196-summary.md` (rudra S21 on Opus: every step ran) · DECISION-002, DECISION-007 (S131/S133,
  S196 addenda), DECISION-011 (controls the agent cannot type).
- **Founder rulings:** no paid run by the agent without his yes; read the tool's own cost, never grow a price list;
  no new policing of Vajra's own paperwork; README/VISION are the spec — never soften them; release not yet.
- **Next ground truth: S200** (the next multiple of 5, derived by `scripts/lib-ground-truth.sh`) — the review-only
  guard blocks its commits until the founder's `vajra approve 200 --close`.

## Guardrails
- No code. No paid run (a `claude -p` trial of the design needs the founder's yes first and is optional).
- The README words are the founder's; the agent proposes, he approves or rewrites, in-session.
- Anything found on the way is filed, not fixed.

## Plan
<the S199 agent writes this after the tech-lead>

## Delta
- `+` the design record for Vajra launching the required cold review at close (Haiku answer d)
- `+` the README "tested with" line in the founder's words (answer c)
- `+` the build session's plan in ROADMAP

## Advice
