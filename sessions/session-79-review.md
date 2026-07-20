# Session 79 — Independent cold fidelity review

> Produced by a separate adversarial pass (general-purpose subagent) fed only the prompt
> (`prompts/79-task-stale-opus-reprice.md`) + the delivery diff (`git diff 42c81cc..HEAD`,
> sessions/prompts/.ai-closeout paths excluded), explicitly barred from the builder's summary
> (DECISION-002 / DECISION-003). The reviewer re-sourced the pricing data itself from the
> `claude-api` skill (not trusting the diff's comments), re-ran `cargo test --lib`, clippy, fmt,
> `verify-session-79.sh`, `demo-session-79.sh`, and independently re-ran `cargo run -- estimate`.
> Verdict recorded verbatim below; the attestation binds it to the delivered code.

**Verdict:** ACCEPT
**Review-Inputs-SHA:** c6111ba56783a890d6eccf790877cc3d54f9a727ee0f94801554509bb3449ce3

> Attestation = `sha256(prompt ‖ delivery-diff)` via `scripts/verify-closeout.sh --inputs-sha 79`,
> the delivery diff being the non-excluded committed change (3 commits: `src/meter/mod.rs` +
> `docs/adr/0004-...md`, `src/cli/estimate.rs` + `docs/adr/0005-...md`, the two S79 scripts).
> Bar-raising, not tamper-proof (DECISION-003): kills a recycled / stale / delivery-decoupled
> verdict, not builder authorship.
>
> **Re-attest note (S58 discipline):** `vajra.varta` is not on `canonical_inputs_sha`'s exclude list
> (only `sessions/`, `prompts/`, and the closeout-synced `.ai/*` files are). Re-rendering it at
> closeout (a derived artifact from `.ai/`, no semantic change to the reviewed delivery) shifted the
> hash from the pass-time `efdc652b…` to the final `c6111ba5…` above. The reviewer's verdict and
> per-criterion findings are unaffected — nothing they inspected changed — so the SHA was refreshed
> rather than re-running the cold pass, matching the S58 precedent for a within-scope post-pass
> touch to a hashed-but-non-substantive file.

## Per-requirement verdict table (reviewer's, verbatim)

| # | Criterion | Status | Evidence the reviewer re-verified |
|---|-----------|--------|-----------------------------------|
| 1 | Current opus (`claude-opus-4-8`) prices at real current rate ($5/$25), not stale $15/$75 | SHIPPED | Loaded the `claude-api` skill itself: current cached table (2026-06-24) confirms Opus 4.8/4.7/4.6 = $5.00/$25.00 per MTok. Read `src/meter/mod.rs` in full — three new `ModelPricing` entries (`claude-opus-4-8`, `-4-7`, `-4-6`) at `(5.0, 25.0)` sit before the generic `claude-opus-4` entry. Ran `cargo run --quiet -- estimate` live: output shows `@ $5/MTok` input / `@ $25/MTok` output. Unit test `opus_4_8_prices_at_current_rate_legacy_opus_keeps_historical_rate` passes. |
| 2 | Older/legacy opus ids handled per a documented, non-silent granularity decision | SHIPPED | Same test asserts `pricing_for("claude-opus-4-1-20250805")` and `pricing_for("claude-opus-4-20250514")` both still return `(15.0, 75.0)`, falling through to the generic entry the source comments label "Legacy/unconfirmed opus fallback." Documented in `docs/adr/0004` and `docs/adr/0005`, not just asserted in a test. `specific-opus-entries-precede-generic` in the verify script locks the ordering. |
| 3 | `UNKNOWN_MODEL_PRICING` stays an intentional upper bound, never an undercount | SHIPPED | Confirmed via the skill: Fable 5/Mythos 5 (priciest real entries) are $10/$50; `UNKNOWN_MODEL_PRICING = (15.0, 75.0)` is numerically unchanged, rationale corrected in-code to "1.5x Claude Fable 5's ... the priciest rate actually in the table." New test `unknown_model_pricing_still_exceeds_every_known_rate` iterates every `MODEL_PRICING` entry, asserting `>=` on both dimensions — passes. |
| 4 | `cargo test --lib` green; regression locks the corrected figure; S66/S78 authoritative-path tests unaffected | SHIPPED | Ran `cargo test --lib`: **258 passed, 0 failed**. `meter_cost_formula_matches_hand_calculation` re-derived by hand at $5/$25 (`0.095048`, arithmetic checked). Diffed `apply_captured_cost`, `extract_result_cost`, and the result-line parsing against the pre-session file at the merge-base — byte-for-byte identical except comment text. |
| 5 | `verify-session-79.sh` proves the rate + upper-bound invariant; `demo-session-79.sh` shows genuine live before→after with the 4 markers | SHIPPED | verify = **11/11 PASS**, including a live check that runs `cargo run --quiet -- estimate` and greps for `$5/MTok` while asserting absence of `$15/MTok`. demo genuinely executes `cargo run -- estimate` for AFTER (independently re-run, matching output) and the BEFORE line is a correctly-labeled static comparison confirmed against `git show <merge-base>:src/meter/mod.rs`. All four `[demo:...]` markers present. |

## Bugs / risks (reviewer, verbatim)
- **None material.** Prefix-collision risk (`starts_with("claude-opus-4-6")` matching a
  hypothetical future `claude-opus-4-60`) pre-existed with the original generic prefix and this
  change actually narrows the blast radius, not widens it — theoretical, no such model exists.
- `UNKNOWN_MODEL_PRICING` and the legacy `claude-opus-4` fallback are numerically identical
  ($15/$75, historical coincidence) — the invariant test uses `>=` correctly, and this is disclosed
  honestly in the demo's "Honest limit" text rather than hidden.

## Scope check (reviewer, verbatim)
One story. Exactly 6 files across 3 commits (≤2 files/commit, under the 3-file cap): the two ADR
docs, `src/meter/mod.rs`, `src/cli/estimate.rs`, and the two S79 scripts. No new CLI command, no
station-logic changes (verified untouched), S66/S78 authoritative-cost path functionally untouched
(diffed against the pre-session file). A pure compiled-in rate-value correction plus its regression
tests and gate scripts, exactly as scoped.

## Reviewer's justification (verbatim)
> I independently re-sourced the pricing data from the `claude-api` skill rather than trusting the
> diff's comments, and it matches exactly: current opus (4.6/4.7/4.8) at $5/$25, Fable 5 at $10/$50,
> giving an unchanged $15/$75 upper bound now reframed as 1.5× Fable rather than "opus." I reran
> every test and script myself from a clean shell: `cargo test --lib` (258/258), clippy (clean), fmt
> (clean), `verify-session-79.sh` (11/11), `demo-session-79.sh` (genuinely live, confirmed by
> independently re-running the same `cargo run -- estimate` command), and diffed the pre/post
> `src/meter/mod.rs` against the merge-base to confirm the authoritative S66/S78 path was untouched
> and the specific-before-generic prefix ordering was real, not just claimed. Every acceptance
> criterion in the prompt is met with evidence I generated myself, and I found no undercount risk,
> no guardrail violation, and no scope creep. This earns ACCEPT.
