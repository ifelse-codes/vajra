# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S49 complete, S50 not yet started). S49 = CODE (reporting), founder pick A:
shipped the **obedience baseline** — `vajra meter --all [dir]` batches the S48 metric over a directory of
transcripts → a worst-first ranked table + aggregate (median/range). Output: `sessions/session-49-summary.md`
+ `sessions/session-49-baseline.md`; commits `4717029` (feat) + `35e081c` (verify+artifact) + closeout.
~$0 (local build/test).

## Active PRs
- None open. S49 branch `session-49-obedience-baseline` is committed locally (publish-guard is OFF in this
  repo — founder pushes / merges).
- Merged: S48 obedience-metric [#43](https://github.com/ifelse-codes/vajra/pull/43) · S47 mid-run murmur
  [#42](https://github.com/ifelse-codes/vajra/pull/42) · S46 live-redogfood
  [#41](https://github.com/ifelse-codes/vajra/pull/41) · S45 ground-truth
  [#40](https://github.com/ifelse-codes/vajra/pull/40).
- Housekeeping: prune merged `session-48-*`/`session-47-*` local branches + the stale `origin/session-42-*`.

## Direction (set S18 … enforcement arc completed S37–S44, LIVE-VERIFIED S46 → pivot to B; B sessions S47 murmur, S48 metric, S49 baseline)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **S46 FOUNDER DIRECTION LOCK: build B, not A.** (A) "your AI can't go rogue" vs (B) "your AI does better
  work" — founder picked **B**. The enforcement guard is the FLOOR, proven live (S46); the co-pilot that
  makes the work *better* is the product. "Cheaper" for B = **less re-work**, NOT compression (~$0). Memory
  `vajra-direction-b-copilot`.
- **S47→S49 built the measurement spine of B:** S47 the mid-run murmur (mechanism, value UNMEASURED) → S48
  the obedience metric (a number for one session) → **S49 the obedience baseline (the yardstick).** Honest
  read carried at each rung: this measures obedience to the RAILS, not work-quality — a floor.
- **Enforcement moat: COMPLETE + LIVE-VERIFIED (S46).** `dogfood_check` 🟢 since S46. Do not re-open.
- **Second agent stays parked** — cross-agent code still zero; direction B favors depth-of-value over breadth.
- **MVP framing (S49):** honest value story ✅ · enforcement-holds-live ✅ · frictionless install 🟡
  (crates.io path broken) · **"does better work" 🟡 — the floor is now measured AND has a yardstick (S47→S49);
  work-quality itself is still UNMEASURED (option B, the harder proof).**

## What Currently Works
- **The obedience baseline (S49).** `vajra meter --all [dir]` runs the S48 metric over every transcript in
  a directory (default `~/.claude/projects/<cwd-slug>`) and prints a **worst-first** ranked table + aggregate
  (n / median / range / total blocks / empties skipped). `src/obedience/mod.rs` (`baseline_for_dir` /
  `aggregate` / `sort_rows` / `format_baseline`, unit-tested) via `src/cli/meter.rs` `--all`; table → stdout,
  read-only, no 8th command, no new dep. Real read: 63 sessions; **substantive (≥10 calls, n=52) median 98.9%,
  band 95–100%** — the S48 live reading was dead-on normal. 27/27 verify.
- **The obedience metric (S48).** `vajra meter <session.jsonl>` prints `obedience % = clean ÷ (clean+blocked)`
  mined read-only from the trace (a Vajra rail block surfaces as `tool_result{is_error, "PreToolUse:… hook
  error … [vajra …]"}`); runs on past sessions. `src/obedience/mod.rs`.
- **The co-pilot has BOTH halves (S47).** Reactive/blocking = the loader (`hook-copilot-loader.sh`,
  PreToolUse, exit 2 at L2/L3) + guards. Proactive/advisory = the murmur (`hook-copilot-murmur.sh`,
  `UserPromptSubmit`, exit 0). Both scaffolded into `vajra init` byte-identical.
- **Enforcement moat, complete + scaffolded (S37→S44) + LIVE-VERIFIED (S46).** publish-guard + session-guard
  + jq-preflight (fail-closed on all 5 hooks) + git-level L2 belt + `.claude/settings.json` merge on init.
- **Darshan (S32) founder-confirmed live good** (S36); brownfield onboarding + auth (S34) hold live.
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter` (now with
  `--all` baseline). **`cargo test` = 129 lib** (+5 this session) + adapter + integration; clippy + fmt clean.

## What Is Broken / Weak
- **🔴 Work-quality is still UNMEASURED — the standing #1 (option B measures it).** The floor is now measured
  (S48) and has a yardstick (S49), but obedience proves the agent obeyed the rails, NOT that the output was
  better. The direction-B thesis ("does better work") is not yet proven by a number.
- **🟡 Baseline is descriptive, not causal (S49, accepted):** it says what obedience *has been*, not that
  Vajra caused it; small n + high cluster mean the all-sessions median (100%) is weak — use the substantive
  ≥10-call view. Inherits the S48 blind spot (only hook-attributed blocks; a silently-worked-around rule is invisible).
- **🟡 Accepted murmur v0 limit (S47):** a fresh *uncommitted* repo `-uall` over-lists `prompts/*`.
- **🟡 Efficiency is thin.** Compression saves ~$0 on real CC; value must be re-work reduction, not tokens.
- **🟡 cargo/npm/pytest never fold on real CC (S33/S41 carry).** Branch on `exit_code == Some(0)`, which
  real CC never sends → `_fail` passthrough under 300/400 lines. Own future compression session.
- **🟡 Install path: `cargo install vajractl` (README) is not the working install** (crates.io name taken)
  — real install = `cargo install --path`. Plus accepted publish-guard v0 quote-strip over-block (backlog).

## What Is In Progress
- **S49 DONE + closed** (obedience baseline, ~$0). The number now has a yardstick. **Next (S50) = mandatory
  NO-CODE ground-truth** (every 5th; last = S45) — all 8 `required_audits`; founder picks the LEAD lens
  (A direction-B value · B dogfood/enforcement · C process-cost + note-compression). New chat.
  `prompts/50-task-<slug>.md` written after the pick.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra`. Compression saved $0; ~$32 was cache-read.
- Session 46: ~$3.84 — four real `vajra claude -p` L3 runs (live-verified the moat; `dogfood_check` 🟢).
- Session 32–35, 37–45, 47, 48, **49**: ~$0.00 each — build/code + NO-CODE GT sessions (S49 = local build/test only).
- Cumulative: **~$65.8**. The dogfood gate is MEASURED and GREEN since S46.
