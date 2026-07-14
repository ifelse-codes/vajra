# Session 61 — Analyst: make the Generate + Delta half REAL (pay down the S54 REJECT)

> **Status:** APPROVED (founder standing "all approved" + S60-GT pick **A**). **Type: CODE.**
> The S60 ground truth verdict: 5 sessions of gate-work outran the pipeline it governs (1 stage + a REJECT).
> S61 pivots to **payload** — give the fidelity gate its first ACCEPT *earned by real stage work*, by closing
> the two deterministic gaps in the S54 Analyst REJECT (`sessions/session-54-review.md`).

## Type
- **CODE**. Max 2 assumptions · 2 retries · ~2h · **1 story** · new chat · approval token before any commit.

## The gap this pays down (from the S54 cold review — of 5 stage-steps only Gate is real)
| Step | S54 verdict | S61 target |
|---|---|---|
| J3 **Generate** — write the prompt **+ update TASK.md** | PARTIAL (prompt ✓; TASK.md never updated, only a `println!`) | **SHIPPED** — the Analyst updates the `.ai/TASK.md` pointer on generate |
| J4 **Delta** — record +/~/− vs ROADMAP | PARTIAL — the "**fakest green**": a static placeholder block proven by `grep -q '## Delta'` | **SHIPPED** — the gate/validate rejects a **placeholder** Delta; only a *substantive* one passes |
| J1 Intake · J2 Options | NOT-BUILT (intent→A/B/C front half) | **OUT OF SCOPE** — the AI-shaped front half; S62 candidate. Say so plainly. |

## Goal
Turn the Analyst's Generate+Delta half from PARTIAL to SHIPPED, deterministically. Two changes, one story:
1. **Generate updates the spine.** When the Analyst generates `prompts/NN-task-<slug>.md`, it also updates the
   `.ai/TASK.md` **pointer** to point at the new session/prompt (the J3 gap — no second store; just the existing
   pointer). Idempotent; never clobbers human prose beyond the pointer line(s).
2. **Delta is enforced, not grepped.** `validate_prompt` distinguishes a **substantive** `## Delta` (real
   `+/~/−` entries the human filled in) from the **template placeholder** (the literal `<what this session
   ADDS…>` lines). The gate **escalates a missing-or-placeholder Delta from a warning to a BLOCK** (fail-closed
   L2/L3, advise L1) — the same move S56 made for the review table (word-count proxy → real in-row verdicts).
   `VAJRA_SKIP_ANALYST_GATE=1` still overrides. Legacy prompts without a Delta: decide + document the rule
   (recommend: block only prompts the Analyst itself scaffolds going forward, so legacy prompts stay valid —
   mirror the S54 backward-compat stance for required sections).

## Acceptance (what must be answered — testable, EARS-style)
1. **WHEN** the Analyst generates a prompt **THEN** `.ai/TASK.md`'s pointer names the new session/prompt —
   asserted by `verify-session-61.sh` against a real run in a temp repo (not a mock).
2. **WHEN** a prompt carries the untouched template Delta placeholder **THEN** `gate()` BLOCKS at L2/L3 (a
   non-author cannot advance on a hollow Delta); **WHEN** the Delta has real `+/~/−` entries **THEN** it passes.
   The old `grep -q '## Delta'` heading-check is **replaced** by a substantive assertion.
3. **The honest verdict:** does this move the S54 REJECT toward ACCEPT (Gate+Generate+Delta now real = 3 of 5),
   and is Intake/Options (the NOT-BUILT front half) *explicitly still open* — not quietly reframed as done?

## Deliverables
- The two changes in `src/analyst/mod.rs` (+ the CLI wiring in `src/cli/next.rs` if needed).
- `scripts/verify-session-61.sh` (exits 0): real `vajra next --scaffold`/`--advance` run in a temp repo asserts
  the TASK.md pointer update + placeholder-Delta BLOCK + substantive-Delta PASS + no second store + no 8th
  command; `cargo test` green (new unit tests for placeholder-vs-substantive Delta + the pointer write).
- `scripts/demo-session-61.sh` + the interactive HTML demo when asked.
- `sessions/session-61-summary.md` + **an independent cold fidelity review** (`sessions/session-61-review.md`,
  the DECISION-002 gate — a subagent fed only this prompt + the diff) + exactly 3 ranked S62 candidates
  (standing: 🥇 Intake/Options front half — finish the REJECT · 🥈 paid dogfood run [unmeasured since S52] ·
  🥉 gate hardening / KNOWLEDGE.md compression).
- Update memory `vajra-fidelity-over-discipline` with the honest "REJECT paid down from 1-of-5 to 3-of-5" finding.

## Guardrails
- **Slice to ONE story** — the Generate+Delta half only. Do NOT build Intake/Options this session (that is S62).
- Own the `.ai/` spine — the TASK.md pointer is the EXISTING store; add **no** second store, no 8th command.
- The Delta enforcement must be **deterministic** (a Rust binary can't *compute* a semantic delta — that is the
  agent's job; the binary's job is to *enforce a real one was recorded*, not to author it). Do not fake "computed."
- Darshan every human reply · Varta against the live `.ai/`. Approval token before any commit.

## Output
A working Analyst whose Generate+Delta half is real (TASK.md updated on generate; a placeholder Delta BLOCKS),
`verify-session-61.sh` green, an independent cold review, and a summary stating plainly that S61 moved the S54
REJECT from 1-of-5 to 3-of-5 with Intake/Options still open.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` Analyst updates the `.ai/TASK.md` pointer on generate (closes J3); a substantive-Delta check in `validate_prompt`.
- `~` The gate escalates missing/placeholder Delta from WARN → BLOCK; `verify-session-61.sh` replaces the S54
  `grep -q '## Delta'` heading-check with a substantive assertion.
- `-` Retires the "fakest green" the S54 cold review named (the placeholder Delta proven by a heading grep).
