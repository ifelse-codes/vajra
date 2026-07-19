# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 78 — Recover the true $ (CODE) — COMPLETE

- **Within ADR-0004 (meter/receipt), no new command:** the launcher now captures the coding tool's
  OWN end-of-session cost on headless runs. `src/cli/launch.rs` `is_headless(args)` gates a
  byte-level tee (headless pipes stdout, streams every byte through untouched + keeps a copy;
  interactive keeps an inherited TTY, unchanged). `src/meter/mod.rs` `extract_result_cost` reads
  `total_cost_usd` from the terminal `type:"result"` line; `SessionCost::apply_captured_cost`
  promotes it to S66's `authoritative_dollars` (fill-only, never overrides a transcript's own).
- **Result:** a headless run's receipt headline is now a real `$… total` (live smoke: `$0.0277`),
  where S77 could only say "no authoritative cost available". Interactive stays honestly null.
- Read prompt: `prompts/78-task-recover-true-cost.md`. Reports: `sessions/session-78-summary.md` +
  `-review.md` (ACCEPT, attested `daabaa7a…`). `verify-session-78.sh` 15/15; demo 4 markers.
- Real captured result-stream fixture + committed live before→after evidence under
  `sessions/session-78-artifacts/`. `cargo test --lib` **256** (+7). **Spend ~$0.055** (two cheap
  haiku smoke runs).

Between sessions. **Next = S79 — CODE, founder pick pending** from 3 ranked candidates below. **New
chat.**

## Next Session (S79 — CODE, founder pick pending)
- **3 ranked candidates (founder picks; I recommend A):**
  - **🥇 A — stale-opus re-pricing:** static `claude-opus-4` $15/$75 → opus-4-8 $5/$25 (stops the
    estimate overstating opus ~3×; finishes receipt accuracy for the interactive/estimate path).
  - **🥈 B — `--stations` ship-evidence durability** (S75 GT finding): harden the payload counter's
    Releaser dimension (decays once branch refs are pruned) before S80's GT relies on it.
  - **🥉 C — read-only-headless UX + typed `CannotEvaluate::{Timeout,SpawnFailure}`** (S76/S73).
- Write `prompts/79-task-<slug>.md` on the pick. Branch `session-79-<slug>`. **S80 = the next
  mandatory NO-CODE GT.**

## Always-True Reminders
- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (next = **S80**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S79; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`) + chained tamper-evident (`DECISION-004`). **Pipeline = 8 governed stations + a
  receipt that now RECOVERS the true $ on headless runs (S78) and stays honestly null on
  interactive (S77).** **Receipt arc S76→S77→S78 is CLOSED for headless.**
