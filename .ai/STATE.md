# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S50 complete, S51 not yet started). S50 = **NO-CODE ground-truth** (mandatory
every-5th; last = S45), lead lens B (dogfood/enforcement). No source edits, no PRs. Output:
`sessions/session-50-ground-truth.md` (the audit) + `prompts/51-task-value-gap.md`; closeout committed on the
exempt `session-50-closeout` branch. ~$0 (read-only verification: `cargo test`, `git`, `grep`).

## Active PRs
- None open. S50 is docs-only; the audit branch `session-50-dogfood-enforcement-gt` + closeout branch
  `session-50-closeout` are committed locally (publish-guard OFF in this repo — founder pushes / merges).
- Merged: S49 obedience-baseline [#44](https://github.com/ifelse-codes/vajra/pull/44) · S48 obedience-metric
  [#43](https://github.com/ifelse-codes/vajra/pull/43) · S47 mid-run murmur
  [#42](https://github.com/ifelse-codes/vajra/pull/42) · S46 live-redogfood
  [#41](https://github.com/ifelse-codes/vajra/pull/41).
- Housekeeping: after merge, prune merged `session-49-*`/`session-48-*` local branches + the stale
  `origin/session-42-*`.

## Direction (set S18 … enforcement arc completed S37–S44, LIVE-VERIFIED S46 → pivot to B; B sessions S47 murmur, S48 metric, S49 baseline; S50 GT re-audited)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **S46 FOUNDER DIRECTION LOCK: build B, not A.** (A) "your AI can't go rogue" vs (B) "your AI does better
  work" — founder picked **B**. The enforcement guard is the FLOOR, proven live (S46); the co-pilot that
  makes the work *better* is the product. "Cheaper" for B = **less re-work**, NOT compression (~$0). Memory
  `vajra-direction-b-copilot`.
- **S47→S49 built the measurement spine of B:** murmur → obedience metric → baseline. **S50 GT verdict:** the
  spine measures the *floor* (obedience to the RAILS), not work-quality; **work-quality is still UNMEASURED**
  — S51 (founder pick A) takes the first real reading.
- **Enforcement moat: COMPLETE + LIVE-VERIFIED (S46); re-verified present S50.** `dogfood_check` is now
  **🟡 measured-then-aging** — no paid `vajra claude` run since S46. Do not re-open the guard (S46 pivot).
- **Second agent stays parked** — cross-agent code still zero; direction B favors depth-of-value over breadth.
- **MVP framing (S50):** honest value story ✅ · enforcement-holds (present-verified) ✅ · frictionless install
  🟡 (crates.io path broken) · **"does better work" 🟡 — floor measured + yardsticked (S47→S49); work-quality
  itself still UNMEASURED (S51 = the harder proof).**

## What Currently Works
- **The obedience baseline (S49).** `vajra meter --all [dir]` runs the S48 metric over every transcript in a
  directory (default `~/.claude/projects/<cwd-slug>`) → a **worst-first** ranked table + aggregate (n / median
  / range / total blocks / empties skipped). `src/obedience/mod.rs`; real read: substantive (≥10 calls, n=52)
  median 98.9%, band 95–100%. Descriptive, not causal; a floor.
- **The obedience metric (S48).** `vajra meter <session.jsonl>` prints `obedience % = clean ÷ (clean+blocked)`
  mined read-only from the trace (a Vajra rail block surfaces as `tool_result{is_error, "PreToolUse:… hook
  error … [vajra …]"}`); runs on past sessions.
- **The co-pilot has BOTH halves (S47).** Reactive/blocking = the loader (`hook-copilot-loader.sh`, PreToolUse,
  exit 2 at L2/L3) + guards. Proactive/advisory = the murmur (`hook-copilot-murmur.sh`, `UserPromptSubmit`,
  exit 0). Both scaffolded into `vajra init` byte-identical.
- **Enforcement moat, complete + scaffolded (S37→S44) + LIVE-VERIFIED (S46), re-verified present S50.**
  publish-guard + session-guard + jq-preflight (in 6 hooks) + git-level L2 belt (`core.hooksPath=.githooks`) +
  `.claude/settings.json` merge on init. All 10 hooks present + wired; scaffold keeps guard ON.
- **Darshan (S32) founder-confirmed live good** (S36); brownfield onboarding + auth (S34) hold live.
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter` (with
  `--all` baseline). **`cargo test` = 129 lib** + adapter + integration; clippy + fmt clean (re-verified S50).

## What Is Broken / Weak
- **🔴 Work-quality is still UNMEASURED — the standing #1 (S51 measures it).** The floor is measured (S48) +
  yardsticked (S49), but obedience proves the agent obeyed the rails, NOT that the output was better. The
  direction-B thesis ("does better work") is not yet proven by a number.
- **🟡 `dogfood_check` is aging (S50):** the moat is present-verified but the last *live* fire was S46; no paid
  `vajra claude` run since. 🟢-measured is decaying toward 🟢-assumed. Cheapest refresh = a paid run (S51) or a
  $0 payload-replay (mechanism-only).
- **🟡 Baseline is descriptive, not causal (S49, accepted).** Inherits the S48 blind spot (only hook-attributed
  blocks; a silently-worked-around rule is invisible).
- **🟡 Accepted murmur v0 limit (S47):** a fresh *uncommitted* repo `-uall` over-lists `prompts/*`.
- **🟡 Efficiency is thin / cargo-npm-pytest never fold on real CC (S33/S41 carry) / install path broken**
  (crates.io name taken → real install = `cargo install --path`; + publish-guard v0 quote-strip over-block).

## What Is In Progress
- **S50 DONE + closed** (NO-CODE ground-truth, ~$0). Verdict: paper moat intact, live moat 🟡 aging;
  work-quality UNMEASURED. **Next (S51) = measure the value gap (real-task baseline, PAID)** — founder pick A;
  the first work-quality number + a live moat refresh. New chat. `prompts/51-task-value-gap.md` ready.
  **Next mandatory NO-CODE GT = S55.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra`. Compression saved $0; ~$32 was cache-read.
- Session 46: ~$3.84 — four real `vajra claude -p` L3 runs (live-verified the moat; `dogfood_check` 🟢).
- Session 32–35, 37–45, 47, 48, 49, **50**: ~$0.00 each — build/code + NO-CODE GT sessions (S50 = read-only
  verification: `cargo test` + `git` + `grep`).
- Cumulative: **~$65.8**. The dogfood gate was MEASURED GREEN at S46; **🟡 aging as of S50** (no paid run since).
