# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 77 — Receipt truth on real runs (CODE) — COMPLETE

- **Within ADR-0004 (meter/receipt):** added `claude-fable-5` to `meter::MODEL_PRICING` at real sourced
  rates ($10/$50, Claude model catalog cached 2026-06-24) — it was absent → priced at the opus upper
  bound ($15/$75), overstating. And changed the receipt so that when no authoritative `total_cost_usd`
  exists the headline reads "no authoritative cost available" + a clearly-secondary `~$… token estimate`,
  never a `$… total`.
- **Root cause recorded (criterion 3):** the JSONL vajra meters is the on-disk CC session transcript,
  which never carries `total_cost_usd`; that lives only on the headless `-p` result stream (a different
  artifact). Not a nesting bug — documented as a known limit; recovering it is S78.
- Read prompt: `prompts/77-task-receipt-truth.md`. Reports: `sessions/session-77-summary.md` +
  `-review.md` (ACCEPT, attested `a756c9db…`). `verify-session-77.sh` 11/11; demo 4/4.
- Regression test on a real S76 fixture (`sessions/session-76-artifacts/fixtures/s76-fable-headless.jsonl`).
  `cargo test --lib` 249. **$0 spent** (reused S76 fixtures).

Between sessions. **Next = S78 — CODE, recover the true $** (founder pick A of 3 ranked S78 candidates);
`prompts/78-task-recover-true-cost.md` (APPROVED). **New chat.**

## Next Session (S78 — CODE, recover the true $)
- Wire the launcher to capture Claude Code's OWN end-of-session cost — the headless `-p` result stream's
  `total_cost_usd` — and feed it to the S66 authoritative-cost path so real headless runs get a TRUE
  figure, not just "no authoritative cost available". Interactive runs unchanged. Extends ADR-0004; no
  new command. Never swallow the agent's stdout.
- Branch `session-78-recover-true-cost`. **S80 = the next mandatory NO-CODE GT.**
- Standing S79 candidates (if S78 surfaces no sharper pick): read-only-headless UX + typed
  `CannotEvaluate::{Timeout,SpawnFailure}` · `--stations` ship-evidence durability (S75 GT finding) ·
  re-price the stale static `claude-opus-4` rate ($15/$75 → opus-4-8 $5/$25; S77-surfaced debt).

## Always-True Reminders
- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground-truth (next = **S80**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S78; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`) + chained tamper-evident (`DECISION-004`). **Pipeline = 8 governed stations + a
  receipt that now tells $ truth or admits it can't (S77).** **S78 = recover the truth: read the tool's
  own cost.**
