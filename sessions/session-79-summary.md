# Session 79 — Re-price the stale static opus rate (CODE) — summary

**Type:** CODE — extends ADR-0004 (meter/receipt); a compiled-in pricing-value change, no new
command. Founder pick **A** of the 3 ranked S78 candidates. **Finishes the receipt-accuracy story
S76→S78 for the interactive/estimate path S78 left untouched.**

## Headline
`vajra estimate` (and the meter's token estimate for any current-opus transcript) now prices
`claude-opus-4-8` — the actual default model — at the confirmed current rate **$5/$25 per MTok**,
not the stale $15/$75 (an opus-4.0/4.1-era rate). On an interactive run there is no result stream,
so the estimate IS the only cost figure a user sees — this was the last live overstatement in the
receipt-accuracy arc S76→S77→S78 left standing.

## What shipped
- **`src/meter/mod.rs`** — three specific-before-generic `MODEL_PRICING` entries
  (`claude-opus-4-8`/`-4-7`/`-4-6` at $5/$25, sourced live from the `claude-api` skill, cached
  2026-06-24) ahead of the generic `claude-opus-4` fallback (`pricing_for` is first-prefix-match).
  The generic entry now explicitly means "legacy/unconfirmed opus" (4.0, 4.1, 4.5, any dated
  snapshot) and keeps the historical $15/$75 — a recorded granularity decision, not a silent guess.
  `UNKNOWN_MODEL_PRICING`'s numeric value is unchanged ($15/$75) but its rationale is corrected:
  it is no longer "the opus rate" (opus is now cheaper than Claude Fable 5's $10/$50) — reframed as
  1.5x Fable 5, reconfirmed `>=` every real rate in the table by a new regression test.
- **`src/cli/estimate.rs`** — `DEFAULT_MODEL` was the bare `"claude-opus-4"`, which used to resolve
  identically to every opus-4-x id. After the meter's split it silently fell through to the legacy
  $15/$75 fallback, so the pre-run cost estimate needed the specific `"claude-opus-4-8"` id to price
  correctly — this is the session's actual interactive-path target.
- **`docs/adr/0004-meter-receipt-design.md`** + **`docs/adr/0005-pre-run-cost-estimate.md`** — the
  "opus = priciest tier" framing and the bare `pricing_for("claude-opus-4")` reference corrected to
  match the new code.

## Proof
- `cargo test --lib` **258 passed** (+2 over S78's 256: the current-opus-rate regression + the
  unknown-model-upper-bound invariant). clippy + fmt clean.
- `verify-session-79.sh` **11/11** — prefix ordering, hand-calc regression, unknown-model invariant,
  the S66/S78 authoritative-path tests untouched, and a LIVE `vajra estimate` check asserting
  `$5/MTok` present and `$15/MTok` absent.
- `demo-session-79.sh` — all four `demo:<element>` markers; the AFTER panel runs `cargo run --
  estimate` live (re-executed independently by the cold reviewer, matching output), not a canned
  string.
- **No paid run needed** — this is a compiled-in rate correction; S79 spend **~$0**.

## Honest limits (disclosed)
- **Legacy opus ids (4.0, 4.1, 4.5) have no confirmed current-rate source** in the `claude-api`
  skill's cached pricing table (only 4.6/4.7/4.8 are published). They keep the historical $15/$75 as
  a conservative, non-decreasing estimate rather than a guess at their present-day billing.
- **The S66/S78 authoritative-cost path is untouched** — this session only sharpens the labeled
  `[estimate]` fallback used when no `total_cost_usd` exists; confirmed byte-identical by the cold
  reviewer's diff against the pre-session file.

## Attestation
- **Review-Inputs-SHA:** `efdc652b79ce9d27e70fc67eb389bf3de5f5261fb7bfcaa2a7401c7d81ae308e`
  (`sha256(prompt ‖ delivery-diff)`; delivery diff = the three S79 commits below). See
  `sessions/session-79-review.md` for the independent cold verdict (ACCEPT).

## Coder-gate execution (plan step → landing commit)
- step 1 (source current rates via the `claude-api` skill) → research only, no commit
- step 2 (update `MODEL_PRICING` + granularity + `UNKNOWN_MODEL_PRICING`) → `079d27f`
- step 2, interactive-path finish (`estimate.rs` `DEFAULT_MODEL`) → `8d6d7f5`
- step 3 & 4 (regression tests + verify/demo) → `e9b6ff3` (tests landed alongside `079d27f`/`8d6d7f5`;
  scripts in `e9b6ff3`)

## Next session
- **S80 = the mandatory NO-CODE ground truth** (every 5th session). See `sessions/session-79-review.md`
  for this session's fidelity verdict; the 3 ranked candidates below are for **S81**, after the GT.

### 3 ranked S81 candidates (post-GT)
- **🥇 A — `--stations` ship-evidence durability** (S75 GT finding, carried through S79 as candidate
  B): the payload counter's Releaser dimension decays once branch refs are pruned — hardens the
  GT's own mandatory instrument, and S80 will lean on `vajra next --stations` again.
- **🥈 B — read-only-headless UX + typed `CannotEvaluate::{Timeout,SpawnFailure}`** (S76/S73,
  carried as S79 candidate C): surface that `-p` without a permission flag is silently read-only;
  split the untyped `None` fakest-green in QA's streamed path.
- **🥉 C — readable-roadmap one-pager** (backlog, flagged repeatedly since S69): a DERIVED
  human-readable summary over `.ai/ROADMAP.md` + `.ai/STATE.md` so the founder isn't reading the raw
  notebook — generate-only, no hand-maintained second copy (`feedback-distill-no-drift`).
