# Session 66 — Make the receipt authoritative (retire the ~4.71× overstatement) — CODE

**Type:** CODE · one story · founder pick B (S65 GT) · standing "all approved".
**Branch:** `session-66-receipt-authoritative`. **Spend:** ~$0 (local Rust + one cold-review subagent).

## Goal (achieved)
The vajra receipt now reports the **authoritative** dollar figure — the JSONL's own
`total_cost_usd` — as the headline charge; the token recompute is demoted to a labeled
`[estimate]`; and an unknown model (`claude-fable-5`) is flagged instead of being silently priced
as opus. The standing 🔴 (governance tool whose own receipt lied 4.71×) is retired.

## Root cause (verified against real data, not guessed)
`src/meter/mod.rs` recomputed cost from a compiled-in table with only opus/sonnet/haiku; a
`claude-fable-5` run fell through `pricing_for`'s default `(15,75)` = opus, and the SDK's
`total_cost_usd` was never read. **Proof:** S63 `sessions/session-63-artifacts/run-result.json`
carries `total_cost_usd: 1.2662`; the receipt printed `$5.9665` → **4.71×**. The fix reproduces
that estimate exactly ($5.9664) and demotes it below the $1.2662 authoritative headline.

## What shipped
- `parse_jsonl` captures `total_cost_usd` from the headless `type:"result"` line (main transcript
  only; subagent partials routed to a throwaway `Option` so they can't overwrite it).
- `SessionCost` gains `authoritative_dollars: Option<f64>`, `unknown_models: Vec<String>`, and
  `billed_dollars()` (authoritative-or-estimate) — used by the receipt headline **and** the budget cap.
- `format_receipt`: headline = authoritative when present (estimate shown beneath, labeled); else the
  estimate IS the headline, tagged `[estimate]`. Unknown models get `[estimate · <model> priced as
  opus upper bound]` + a `not in pricing table` warning; absent-authoritative gets a `no total_cost_usd` note.
- `is_known_model` guard (kept `pricing_for`'s signature so `estimate.rs` is untouched).
- `launch.rs` budgets against `billed_dollars()`.

## Fidelity map (independent cold review — `sessions/session-66-review.md`, attested `3788c443…`)
| Requirement | Verdict |
|---|---|
| A1 headline == total_cost_usd | SHIPPED |
| A2 fallback labeled `[estimate]` | SHIPPED |
| A3 unknown model not silently opus-priced | SHIPPED (warn-route) |
| A4 two figures distinguished | SHIPPED |
| A5 verify proves it, exit 0 | SHIPPED |
| Plan 1–4 | SHIPPED |

**Cold verdict = ACCEPT** (5 SHIPPED · 0 PARTIAL · 0 NOT-BUILT). Fed only the prompt + the delivery diff.

## Fakest green (named, not buried)
`UNKNOWN_MODEL_PRICING` is a **behavioral no-op rename** — fable-5 is still *computed* at opus rates;
all the real correction is the authoritative preference, not "fixing" the pricing. The seam: a fable-5
run with **no** `total_cost_usd` would still headline the inflated number — **labeled**, and headless
runs always carry `total_cost_usd`, so it is disclosed-not-billed, not a leak. Registering a real
fable-5 price is deferred until a confirmed number exists (inventing one would be a worse lie).

## Evidence
- `cargo test --lib` **170 passed** (+2); `cargo fmt --check` + `clippy -D warnings` clean.
- `scripts/verify-session-66.sh` **15/15** on the code (the 2 closeout checks — summary + review —
  now satisfied → full green at closeout). E2E reproduces S63 on a fixture and proves the headline is
  $1.2662, the $5.9664 estimate is labeled and never the headline `total`.
- 2 commits, ≤3 files each: `d6d603d` (meter + launch), `bc5b5df` (verify + demo).

## What I did NOT build
- Real fable-5 per-token pricing (no confirmed price; opus upper bound is labeled, not silently applied).
- The no-`total_cost_usd`-fable-run seam (headless always carries it; disclosed).
- No change to compression (still 0-fold no-op) or the Planner digit-tag — out of scope, one story.

## Next — 3 ranked candidates for S67 (drawn from ROADMAP)
- **🥇 A — The Architect stage (pipeline station 3).** Goal: a governed design/interface gate between
  the Planner (HOW-plan) and a future Coder, closing the pipeline's middle. *Why:* the deferred breadth
  from S64/S65; the pipeline is 3 stations (WHAT · HOW-plan · REVIEW) with the DESIGN gap the sharpest.
  *Risk:* "governed design decision" is fuzzier to enforce than a coverage digit or a cost field.
- **🥈 B — Fix or formally retire the compression 0-fold no-op.** Goal: make compression actually fold
  on real CC, or remove the savings claim honestly. *Why:* the last product claim the loop doesn't
  deliver (S63: 0 folds). *Risk:* may be unfixable on real CC → ends as a retraction, not a feature.
- **🥉 C — Strengthen Planner coverage beyond a self-asserted digit-tag.** Goal: a semantic check that a
  `covers: N` step relates to criterion N, not just that the author typed the number. *Why:* the S64
  fakest green. *Risk:* a Rust binary can't judge semantics without an LLM call — scope/architecture question.
