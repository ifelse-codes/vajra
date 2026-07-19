# Session Boot

## Current Session
- **Number:** 78 — COMPLETE
- **Type:** **CODE — recover the true $** (founder pick A of 3 ranked S77 candidates). Extends
  ADR-0004 (meter/receipt) with a capture path in the launcher; no new command. **Closes the
  receipt arc: S77 stopped the lie, S78 recovers the truth.**
- **Headline result:** on a headless `vajra claude -p` run, the receipt headline is now the coding
  tool's OWN end-of-session cost — a real **`$0.0277 total`** in the live smoke run — where S77
  could only say "no authoritative cost available". Read from the terminal `type:"result"` line of
  the run's stdout stream, not from Vajra's price list.
- **What shipped:** `src/cli/launch.rs` — `is_headless(args)` gates a byte-level tee: headless runs
  pipe stdout, stream every byte through (never swallowed — criterion 3) + keep a copy; interactive
  runs keep an inherited TTY, unchanged (criterion 2). `src/meter/mod.rs` — `extract_result_cost`
  reads `total_cost_usd` from the result line (stream-json + single `json` object); `None` for
  text/interactive/non-JSON. `SessionCost::apply_captured_cost` promotes it to S66's
  `authoritative_dollars`, fill-only (never overrides a transcript's own figure).
- **Honest limit (disclosed):** headless-only (interactive genuinely has no result stream — S77's
  honest fallback stays); whole-stdout buffered in RAM for the scan (bounded by output size);
  Claude Code only; the stale static opus estimate is untouched (S79 candidate).
- **Proof:** `verify-session-78.sh` **15/15** · `demo-session-78.sh` 4 markers · cold review
  **ACCEPT** attested **`daabaa7a…`** · `cargo test --lib` **256** (+7) · clippy+fmt clean · **live
  end-to-end** (real `-p` run headlined a true `$… total`, stdout untouched). **Spend ~$0.055**
  (two cheap haiku smoke runs).
- **Branch:** `session-78-recover-true-cost` (PR to `main` — founder call).
- **Date last updated:** 2026-07-19

## Repo State Snapshot
- `.ai/SESSION` = 78.
- **Pipeline = 8 governed stations + a receipt that now RECOVERS the true $ on headless runs** (and
  stays honestly null on interactive). 7 commands, no 8th.
- Remote: `origin` → `https://github.com/ifelse-codes/vajra`.

## Next Session
- **Number:** 79
- **Type:** **CODE — founder pick pending** from the 3 ranked S79 candidates below. S80 is the next
  mandatory NO-CODE ground truth.
- **3 ranked S79 candidates:**
  - **🥇 A — stale-opus re-pricing:** re-price the static `claude-opus-4` rate ($15/$75 →
    opus-4-8 $5/$25) so the token *estimate* stops overstating opus runs ~3× — finishes receipt
    accuracy for the interactive/estimate path S78 left untouched. Risk: low value now that headless
    is authoritative; sharpens only the estimate path.
  - **🥈 B — `--stations` ship-evidence durability** (S75 GT finding): the Releaser dimension of the
    payload counter decays once branch refs are pruned; harden the GT's own mandatory instrument
    right before S80. Risk: meatier than it looks (needs a durable ship-evidence source).
  - **🥉 C — read-only-headless UX + typed `CannotEvaluate::{Timeout,SpawnFailure}`:** surface that
    `-p` without a permission flag is silently read-only + split the S73 untyped-`None` fakest-green.
    Risk: two loosely-related things bundled.
- **Prompt:** to be written on the founder's pick (`prompts/79-task-<slug>.md`). **Branch:**
  `session-79-<slug>`. **New chat.**

## Carry-Forwards
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S79; do NOT start it here.
- **⚠ The Releaser gate is LIVE:** merge the S78 PR, sync main, prune `session-78-recover-true-cost`
  before closing S79 — or `--advance` refuses (that is the feature). (S77's PR #75 is already merged
  + pruned, so S78's own Releaser gate was pre-satisfied.)
- **S70 founder decisions (binding):** compression never-claim-until-measured · payload counter BUILT
  + GT-verified · dogfood DONE at S76.
- **House patterns:** existence-gate recorded markers (S67/S68) · re-run executable markers live
  (S69) · element-scan live (S71) · re-derive git-state from refs (S72, limit S75) · bound+kill live
  gate (S73) · derived metric reuses each gate's classifier (S74) · re-read a debt's origin before
  retiring it (S75) · dogfood pins a CURRENT binary + headless needs a permission flag (S76) · an
  honest null beats a confident fake (S77) · **NEW (S78): capture the tool's OWN end-of-session
  number by tee-inspecting its result stream byte-for-byte — never reconstruct it, never grow the
  price list; pipe only stdout (stdin/stderr inherited) so the tee can't deadlock.**
- **Deferred debts after S78:** stale static opus rate ($15/$75 → $5/$25) = **S79 pick A** ·
  `--stations` ship durability = **B** · read-only-headless UX + typed `CannotEvaluate` = **C** ·
  whole-stdout RAM buffer on headless capture (bound if a long run ever needs it) · cross-agent cost
  (Codex/Grok's own figure) = the founder-gated breadth ask · compression make-it-real (0 folds,
  never claim) · `vajra init` template lacks `pipeline_advance_check` · guard nested-repo blindspot ·
  install path · readable-roadmap one-pager (backlog).
- **S80 = the mandatory NO-CODE GT after S75.**
