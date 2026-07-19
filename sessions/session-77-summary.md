# Session 77 — Receipt truth on real runs (CODE) — summary

**Goal:** on the runs users actually make (headless, `claude-fable-5`), stop the receipt lying about
cost. S76's paid dogfood printed `$14.39 / $12.18 "total"` figures that were an opus-priced estimate
of an **unpriced** model, over a transcript that carried **no** authoritative figure at all.

**Achieved:** yes — within ADR-0004 (meter/receipt), no new command, **$0 spent** (reused the S76
captured fixtures). `cargo test --lib` **249** · `verify-session-77.sh` **11/11** · demo **4/4** markers
· independent cold subagent review **ACCEPT** (attested `a756c9db…`). Commits `086a1b6`, `35a6165`.

## Before → After (metered live from real S76-class data)

```
BEFORE (S76):  $14.3894  total  [estimate · fable-5 priced as opus upper bound, not real rates]  (fable-5 64 lines)
AFTER  (S77):  no authoritative cost available  (fable-5 64 lines)
               ~$9.5929  token estimate  [estimate]
```

The opus-priced "total" is gone; the estimate is now at real fable rates and clearly labeled secondary;
the headline states the honest truth instead of dressing an estimate up as the bill.

## Fidelity map (every numbered requirement → evidence)

| # | Requirement | Status | Evidence |
|---|---|---|---|
| 1 | fable-5 in `MODEL_PRICING` at real rates, not opus upper bound | SHIPPED | `src/meter/mod.rs` `claude-fable-5` @ $10/$50 (catalog, cached 2026-06-24); estimate drops from opus-bound $14.39 → fable $9.59 on run1 |
| 2 | no-authoritative → "no authoritative cost available", never a `$… total` | SHIPPED | `format_receipt` `None` branch; verify `meter-headline-not-a-total` green |
| 3 | root cause recorded (nesting vs version vs other-line) | SHIPPED | in-code comment: on-disk CC session transcript never carries `total_cost_usd` (only the `-p` result stream does); documented known limit |
| 4 | regression test on a real S76 fixture; suite green | SHIPPED | `s76_fable_headless_fixture_…` on the committed real-data fixture; 249 lib tests |
| 5 | verify + demo prove before→after with 4 markers | SHIPPED | `verify-session-77.sh` 11/11; `demo-session-77.sh` header/before_after/cases/summary_table |

**Did NOT build (plainly):** a *true* dollar figure for headless/fable runs. The on-disk transcript
genuinely carries none, so S77 stops the lie without inventing the truth — the recovery is S78's job.

**Fakest green (disclosed):** the fixture's "real S76" status is self-attested — `verify` greps the
fixture for provenance strings, which a fabricated file would also pass, and the source `run.jsonl` is
gitignored. Numbers are internally self-consistent ($0.250029) so it is non-material, but it is the
load-bearing trust boundary; never pitch it as cryptographically verified.

**New debt surfaced:** the meter's `claude-opus-4` rate is stale ($15/$75 = opus-4.0/4.1 era; opus-4-8
is $5/$25) — it now *overstates* opus runs by ~3×. Out of S77's one-story scope; logged for a future
receipt-accuracy pass.

## Next options (exactly 3 — A/B/C)

- **A — Recover the true $ (the receipt arc's close).** Wire the launcher to capture Claude Code's own
  end-of-session cost (the `-p` result stream's `total_cost_usd`) so headless runs get a TRUE figure,
  not just "no authoritative cost available". *Why:* the founder's own post-S76 direction (memory
  `vajra-receipt-pricing-from-tool`) and the exact repair S77's root-cause finding pointed to. *Risk:*
  a launcher change (`src/cli/launch.rs`), must not break interactive runs.
- **B — Read-only-headless UX + typed cannot-evaluate.** Surface up front that `vajra claude -p` with no
  permission flag is silently read-only (the S76 run-1 wall); split QA's untyped `None` into
  `CannotEvaluate::{Timeout, SpawnFailure}` (the S73 fakest green). *Risk:* two stories — pick one.
- **C — `--stations` ship-evidence durability.** Make the S74 payload counter's Releaser/ship dimension
  survive branch pruning (S75 GT finding). *Risk:* lowest-leverage; the counter already works.

**Founder pick: A** — recover the true dollar figure. → `prompts/78-task-*.md`. **S80 = the next
mandatory NO-CODE ground-truth.**
