# Session 62 — Analyst: Intake + Options (finish the stage, close the S54 REJECT)

> **Status:** APPROVED (founder standing "all approved" + S61-close pick **A**). **Type: CODE.**
> S61 paid down the S54 Analyst REJECT from ~1-of-5 to **3-of-5** (Gate S54 · Generate + Delta S61).
> S62 builds the last two stage-steps — **Intake (J1)** and **Options (J2)** — moving the cold review to
> **5-of-5** and making the S54 REJECT ACCEPT-able without a waiver. This is the AI-shaped front half; the
> honest line (learned S61): a binary cannot *author* intent or options — its job is to **surface the inputs**
> and **enforce that a real intake + exactly 3 options were recorded**, never to fake "generated."

## Type
- **CODE**. Max 2 assumptions · 2 retries · ~2h · **1 story** · new chat · approval token before any commit.

## The gap this closes (from the S54 cold review — the last 2 of 5 stage-steps)
| Step | S54 verdict | S62 target |
|---|---|---|
| J1 **Intake** — turn intent (prior session + user words) into the job | NOT-BUILT (scaffold takes a literal slug; nothing consumes intent) | **SHIPPED** — the Analyst surfaces the intake inputs (prior SESSION + ROADMAP next-builds) so the agent authors the job from real context, not a bare slug |
| J2 **Options** — exactly 3 A/B/C candidates from ROADMAP | NOT-BUILT (no A/B/C, no ROADMAP read) | **SHIPPED** — the gate ENFORCES that a prompt records **exactly 3** ranked options (the A/B/C the founder picks from), deterministically; not authored by the binary |
| J3 Generate · J4 Delta · J5 Gate | SHIPPED (S54+S61) | unchanged — do not regress |

## Goal
Turn the Analyst's Intake + Options half from NOT-BUILT to SHIPPED, deterministically and honestly. Two moves,
one story:
1. **Intake surfaces real context.** `vajra next --scaffold` (or a sibling `--intake`) reads the prior
   `.ai/SESSION` + the ROADMAP "Next builds" block and prints them as the intake the agent must fold into the
   Goal — so the job comes from context, not a slug. No second store; ride the existing `.ai/` spine.
2. **Options are enforced, not authored.** `validate_prompt` learns to count **recorded** options; the gate
   BLOCKS a prompt (or a closeout) that does not carry **exactly 3** ranked next-session candidates — the same
   move S61 made for Delta (enforce a *recorded* thing; the binary does not compute it). Decide + document
   where the 3 options live (recommend: the summary's existing "3 ranked candidates", already required by
   `end_of_session.must_present_n_options` — enforce the existing contract, add no new artifact).

## Acceptance (what must be answered — testable, EARS-style)
1. **WHEN** the Analyst runs intake **THEN** it prints the prior session number + the ROADMAP next-builds so a
   non-author sees the real inputs — asserted by `verify-session-62.sh` against a real run in a temp repo.
2. **WHEN** a session artifact records fewer than / more than 3 ranked options **THEN** the gate BLOCKS (L2/L3);
   **WHEN** exactly 3 are recorded **THEN** it passes. A non-author cannot close a session on 2 or 4 options.
3. **The honest verdict:** does this make the S54 REJECT ACCEPT-able (Intake + Options now real = **5 of 5**),
   and is the binary honestly *enforcing/surfacing* — not faking *authored* intent/options? State it plainly.

## Deliverables
- The Intake + Options changes in `src/analyst/mod.rs` (+ CLI wiring in `src/cli/next.rs` if needed).
- `scripts/verify-session-62.sh` (exits 0): a real run asserts intake surfaces prior-session + ROADMAP inputs;
  the 3-options gate BLOCKS on 2/4 and PASSES on 3; no second store; no 8th command; `cargo test` green.
- `scripts/demo-session-62.sh` + the interactive HTML demo when asked.
- `sessions/session-62-summary.md` + **an independent cold fidelity review** (`sessions/session-62-review.md`,
  the DECISION-002 gate — a subagent fed only this prompt + the diff) + exactly 3 ranked S63 candidates.
- Consider re-auditing S54 cold now that all 5 steps exist: does the Analyst stage finally earn **ACCEPT**?
- Update memory `vajra-fidelity-over-discipline` with the "REJECT closed 3-of-5 → 5-of-5" finding.

## Guardrails
- **Slice to ONE story** — Intake + Options only. Do NOT start the next stage (Planner/Architect) this session.
- Own the `.ai/` spine — surface existing stores (SESSION + ROADMAP + the summary's 3 options); add **no** second
  store, no 8th command.
- **Deterministic + honest** — a Rust binary cannot author intent or options (that is the agent's job); enforce
  that a real one was recorded + surface the inputs. Do not fake "computed/generated" (the S54 fakest-green trap).
- Darshan every human reply · Varta against the live `.ai/`. Approval token before any commit.

## Output
A working Analyst whose Intake + Options half is real (intake surfaces prior-session + ROADMAP; the gate enforces
exactly 3 recorded options), `verify-session-62.sh` green, an independent cold review, and a summary stating
plainly whether S54's Analyst REJECT is now ACCEPT-able (5-of-5) with the binary honestly enforcing, not faking.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` Analyst intake surfaces prior-session + ROADMAP next-builds; a recorded-3-options check in `validate_prompt`.
- `~` The gate escalates missing/≠3 options to a BLOCK; `verify-session-62.sh` asserts intake-surfacing + the
  options count by behavior, not a heading grep.
- `-` Retires the last two NOT-BUILT Analyst steps (Intake J1 + Options J2) — the S54 REJECT becomes ACCEPT-able.
