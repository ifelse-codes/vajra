# Session 66 — Make the receipt authoritative (retire the ~4.71× overstatement) — CODE

> **Status:** APPROVED (founder pick B at S65 GT close; standing "all approved"). **Type: CODE.** One story.
> Branch `session-66-<slug>` from `main`, new chat. Governance-credibility fix — the standing 🔴.

## Goal
Make the vajra cost receipt report the **authoritative** dollar figure, not a token-recomputed estimate that
overstates cost **~4.71×** (S63) / **~8–9×** (S51–52). Prefer the JSONL's own `total_cost_usd`; when it is
absent, fall back to the computed estimate **explicitly labeled as an estimate**; and never silently price an
unknown model (e.g. `claude-fable-5`) as opus. Retire the STATE 🔴, honestly.

## Why this session
- **Root cause (found S65 GT, not guessed):** `src/meter/mod.rs::line_dollars` recomputes cost from a
  compiled-in `MODEL_PRICING` table that has only `claude-opus-4`/`claude-sonnet-4`/`claude-haiku`. The S63
  run was **`claude-fable-5`**, which falls through `pricing_for`'s default `(15.0, 75.0)` = **opus pricing** —
  the dominant driver of the 4.71× overstatement. The SDK-authoritative `total_cost_usd` is **never read**.
- **Credibility is the product.** A governance tool whose own receipt lies 4.71× is, by the north-star's own
  word, **not "provable"** (S65 vision + roadmap audits, both 🟡 on this). Deferred since S51 (~14 sessions).

## Acceptance (testable — EARS-style; every criterion is cited by a `## Plan` step below)
1. **WHEN** a session JSONL carries a `total_cost_usd` field **THEN** the receipt's headline dollar figure is
   that authoritative value (not the token-recomputed estimate).
2. **WHEN** the JSONL lacks `total_cost_usd` (older/partial logs) **THEN** the receipt falls back to the
   computed estimate **and labels it explicitly** (e.g. `[estimate]`), never presenting it as the authoritative bill.
3. **WHEN** the model is absent from the compiled-in pricing table (e.g. `claude-fable-5`) **THEN** the computed
   estimate does not silently apply opus pricing — it warns/labels the unknown-model fallback so a fable run is
   never reported at ~4.7×.
4. **WHEN** the receipt prints both an authoritative total and a computed estimate **THEN** the two are clearly
   distinguished so no reader mistakes the estimate for the charge.
5. **WHEN** `scripts/verify-session-66.sh` runs **THEN** it proves on a fixture JSONL that the headline equals
   `total_cost_usd` and the S63-class fable-priced-as-opus overstatement is gone; exit 0.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Parse `total_cost_usd` from the JSONL and thread it through `SessionCost` as the authoritative headline;
   `format_receipt` prints it as the charge. covers: 1, 4
2. Add the estimate-fallback path: when `total_cost_usd` is absent, show the computed figure with an explicit
   `[estimate]` label distinct from the authoritative line. covers: 2, 4
3. Fix the unknown-model fallback in `pricing_for`/`line_dollars` — register `claude-fable-5` (or emit a loud
   unknown-model warning) so no model is silently priced as opus. covers: 3
4. Write `scripts/verify-session-66.sh` + `scripts/demo-session-66.sh` proving headline == `total_cost_usd`
   on a fixture and no fable-as-opus overstatement. covers: 5

## Guardrails
- **One story.** Touch the meter/receipt path (`src/meter/mod.rs`, `src/cli/meter.rs`) + verify/demo only.
  Max 3 files per atomic commit. No 8th command. Update ADR-0004 only if the cost formula's contract changes.
- Do **not** delete the computed estimate — it stays as a labeled fallback (offline/legacy JSONL with no
  `total_cost_usd`). The authoritative number is preferred, the estimate is disclosed.
- Fidelity review (DECISION-002): independent cold pass fed only this prompt + the delivery diff. Attested.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` Receipt now prefers SDK-authoritative `total_cost_usd`; adds an unknown-model guard.
- `~` The compiled-in token estimate is demoted from "the bill" to a **labeled fallback**.
- `-` Retires the STATE 🔴 "receipt overstates ~4.71×" and the "honest receipt is wrong" contradiction.

## Deliverable
- `src/meter/mod.rs` + `src/cli/meter.rs` + `scripts/verify-session-66.sh` (green) + `scripts/demo-session-66.sh`
  + `sessions/session-66-summary.md` + `sessions/session-66-review.md` (independent ACCEPT, attested).
- Carries forward: **S67 candidates** should include the Architect stage (pipeline station 3, the deferred
  breadth) + fix/retire compression 0-fold + strengthen Planner coverage beyond a digit-tag.
