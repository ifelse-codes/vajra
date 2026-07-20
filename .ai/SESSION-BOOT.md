# Session Boot

## Current Session
- **Number:** 79 — COMPLETE
- **Type:** **CODE — re-price the stale static opus rate** (founder pick A of 3 ranked S78
  candidates). Extends ADR-0004 (meter/receipt) with a compiled-in pricing-value change; no new
  command. **Finishes the receipt-accuracy story S76→S78 for the interactive/estimate path S78 left
  untouched.**
- **Headline result:** `vajra estimate` — the only cost figure an interactive user sees (no result
  stream to recover a true $ from) — now prices the current default model at the confirmed
  **$5/$25 per MTok**, not the stale $15/$75 (opus-4.0/4.1-era). Sourced live from the `claude-api`
  skill (cached 2026-06-24), not from memory.
- **What shipped:** `src/meter/mod.rs` — specific-before-generic `MODEL_PRICING` entries for
  `claude-opus-4-8`/`-4-7`/`-4-6` at $5/$25, ahead of the generic `claude-opus-4` fallback (now
  explicitly "legacy/unconfirmed opus" — 4.0/4.1/4.5 — at the historical $15/$75, a recorded
  granularity decision). `UNKNOWN_MODEL_PRICING`'s value is unchanged ($15/$75) but its rationale
  corrected (opus is no longer the priciest tier; Fable 5 is) and reconfirmed `>=` every real rate.
  `src/cli/estimate.rs` — `DEFAULT_MODEL` bumped from the bare `"claude-opus-4"` (which now falls
  through to the legacy rate) to `"claude-opus-4-8"` — the actual interactive-path fix.
- **Honest limit (disclosed):** legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source
  in the cached pricing table, so they keep the historical rate as a conservative estimate, not a
  guess. The S66/S78 authoritative-cost path is untouched (confirmed byte-identical by the cold
  reviewer).
- **Proof:** `verify-session-79.sh` **11/11** · `demo-session-79.sh` 4 markers, genuinely live
  (`vajra estimate` re-executed independently by the reviewer) · cold review **ACCEPT** attested
  **`efdc652b…`** · `cargo test --lib` **258** (+2) · clippy+fmt clean. **Spend ~$0** (compiled-in
  rate correction, no paid run needed).
- **Branch:** `session-79-stale-opus-reprice` (PR to `main` — founder call).
- **Date last updated:** 2026-07-19.

## Repo State Snapshot
- `.ai/SESSION` = 79.
- **Pipeline = 8 governed stations + a receipt that is authoritative on headless runs (S78), honest
  on interactive (S77), and now correctly priced on the interactive estimate (S79).** 7 commands, no
  8th.
- Remote: `origin` → `https://github.com/ifelse-codes/vajra`.

## Next Session
- **Number:** 80
- **Type:** **The mandatory NO-CODE ground truth** (every 5th session; last was S75). Docs only —
  `forbid_code_changes: true`, `forbid_commits: true`, `forbid_prs: true`.
- **Prompt:** `prompts/80-task-ground-truth.md` (to be authored at S79 closeout, per the standard
  8-audit template). **Branch:** `session-80-ground-truth` (or a GT-exempt `-closeout`/`-enforcement`
  suffix). **New chat.**
- **3 ranked S81 candidates** (post-GT — the founder may re-aim these; see
  `sessions/session-79-summary.md` for full rationale):
  - 🥇 A — `--stations` ship-evidence durability (S75 finding; the Releaser dimension decays once
    branch refs are pruned — relevant right before/after S80 leans on the counter again).
  - 🥈 B — read-only-headless UX + typed `CannotEvaluate::{Timeout,SpawnFailure}` (S76/S73).
  - 🥉 C — readable-roadmap one-pager (backlog; a derived summary, no hand-maintained second copy).

## Carry-Forwards
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S80; do NOT start it here.
- **⚠ The Releaser gate is LIVE:** merge the S79 PR, sync main, prune `session-79-stale-opus-reprice`
  before closing S80 — or `--advance` refuses (that is the feature).
- **S70 founder decisions (binding):** compression never-claim-until-measured · payload counter BUILT
  + GT-verified · dogfood DONE at S76 (aging — no paid `vajra claude` run since S76; S80 should
  re-check this).
- **House patterns:** existence-gate recorded markers (S67/S68) · re-run executable markers live
  (S69) · element-scan live (S71) · re-derive git-state from refs (S72, limit S75) · bound+kill live
  gate (S73) · derived metric reuses each gate's classifier (S74) · re-read a debt's origin before
  retiring it (S75) · dogfood pins a CURRENT binary + headless needs a permission flag (S76) · an
  honest null beats a confident fake (S77) · capture the tool's OWN end-of-session number by
  tee-inspecting its result stream, never reconstruct it (S78) · **NEW (S79): when a generic
  model-id prefix stops being uniform-rate (a version split), audit every OTHER caller of that
  pricing function for a bare/ambiguous default string that will now silently fall through to the
  wrong bucket** — `vajra estimate`'s `DEFAULT_MODEL` was exactly such a caller, not caught by the
  meter's own tests.
- **Deferred debts after S79:** `--stations` ship durability = **S81 pick A** · read-only-headless UX
  + typed `CannotEvaluate` = **B** · readable-roadmap one-pager = **C** · whole-stdout RAM buffer on
  headless capture (bound if a long run ever needs it) · cross-agent cost (Codex/Grok's own figure)
  = the founder-gated breadth ask · compression make-it-real (0 folds, never claim) · `vajra init`
  template lacks `pipeline_advance_check` · guard nested-repo blindspot · install path.
- **S80 = the mandatory NO-CODE GT.**
