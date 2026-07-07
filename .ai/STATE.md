# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S47 complete, S48 not yet started). S47 = CODE, the first direction-B session:
shipped the mid-run co-pilot **murmur** (a `UserPromptSubmit` advisory hook) on `session-47-midrun-copilot`.
Output: `sessions/session-47-summary.md`; commits `ea7e497` + `027afcb` + `5b01ef0`. ~$0 (local build/test).

## Active PRs
- None open. S47 branch `session-47-midrun-copilot` is committed locally, **not yet pushed** (publish-guard
  blocks the agent by design — founder pushes / sets `VAJRA_ALLOW_PUBLISH=1`).
- Merged: S46 live-redogfood [#41](https://github.com/ifelse-codes/vajra/pull/41) · S45 ground-truth
  [#40](https://github.com/ifelse-codes/vajra/pull/40) · S44 settings-json-merge
  [#39](https://github.com/ifelse-codes/vajra/pull/39) · S43 git-level-belt
  [#38](https://github.com/ifelse-codes/vajra/pull/38).
- Housekeeping: prune merged `session-46-*`/`session-45-*` local branches + the stale `origin/session-42-*`.

## Direction (set S18 … enforcement arc completed S37–S44, LIVE-VERIFIED S46 → pivot to B, first B session S47)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **S46 FOUNDER DIRECTION LOCK: build B, not A.** (A) "your AI can't go rogue" vs (B) "your AI does better
  work" — founder picked **B**. The enforcement guard is the FLOOR, proven live (S46); the co-pilot that
  makes the work *better* is the product. "Cheaper" for B = **less re-work**, NOT compression (~$0). Memory
  `vajra-direction-b-copilot`.
- **S47 shipped the first B slice — the mid-run murmur** (proactive, non-blocking guidance). But the honest
  read is *mechanism verified, value UNMEASURED* — so **S48 (founder pick A) = the obedience metric**, to
  prove or disprove that the guidance helps before building more co-pilot on top of it.
- **Enforcement moat: COMPLETE + LIVE-VERIFIED (S46).** `dogfood_check` 🟢 since S46 (first since S36).
- **Second agent stays parked** — cross-agent code still zero; direction B favors depth-of-value over breadth.
- **MVP framing (S47):** honest value story ✅ · enforcement-holds-live ✅ · frictionless install 🟡
  (crates.io path broken) · **"does better work" 🟡 — now BUILT (the murmur) but UNMEASURED; the new #1 is
  to measure it (S48).**

## What Currently Works
- **The co-pilot now has BOTH halves (S47).** Reactive/blocking = the loader (`hook-copilot-loader.sh`,
  PreToolUse, exit 2 at L2/L3) + guards. **Proactive/advisory = the murmur (`hook-copilot-murmur.sh`,
  S47):** a `UserPromptSubmit` hook that surfaces the `copilot.on` context relevant to the working-tree
  changes as an advisory (stdout, **exit 0 — never blocks**); signal = `git status --untracked-files=all`;
  `cmd:*` rules skipped; missing jq / no match / can't-decide → stays quiet; per-session debounce in a
  separate `murmur-` namespace. Scaffolded into `vajra init` byte-identical via `include_str!` + wired on a
  new `UserPromptSubmit` block; un-excluded in `Cargo.toml`. `verify-session-47.sh` **23/23 green**.
- **Enforcement moat, complete + scaffolded (S37→S44) + LIVE-VERIFIED (S46).** publish-guard + session-guard
  + jq-preflight (fail-closed on all 5 hooks) + git-level L2 belt + `.claude/settings.json` merge on init.
- **Darshan (S32) founder-confirmed live good** (S36); brownfield onboarding + auth (S34) hold live.
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter`.
  **`cargo test` = 119 lib** (+2 this session) + 12 adapter + integration; clippy + fmt clean.

## What Is Broken / Weak
- **🔴 "Does better work" is BUILT but UNMEASURED — the new #1 (S48 measures it).** The murmur (S47) fires
  correctly but is unproven to reduce wrong turns / re-work. No obedience or work-quality number exists yet.
  Building more guidance before measuring is the guard-era trap direction B warns against.
- **🟡 Accepted murmur v0 limit (S47):** in a fresh *uncommitted* repo, `-uall` lists every untracked file,
  so `prompts/*` murmurs on scaffolded prompts even when the agent isn't editing one; a committed repo shows
  only real changes → no bite. Low harm (advisory, debounced).
- **🟡 Efficiency is thin.** Compression saves ~$0 on real CC; value must be re-work reduction, not tokens.
- **🟡 cargo/npm/pytest never fold on real CC (S33/S41 carry).** Branch on `exit_code == Some(0)`, which
  real CC never sends → `_fail` passthrough under 300/400 lines. Own future compression session.
- **🟡 Install path: `cargo install vajractl` (README) is not the working install** (crates.io name taken)
  — real install = `cargo install --path`. Plus accepted publish-guard v0 quote-strip over-block (backlog).

## What Is In Progress
- **S47 DONE + closed** (mid-run murmur, ~$0). The co-pilot's proactive half ships; honest read = mechanism
  verified, value unmeasured. **Founder pivot to direction B is now in execution.** **Next (S48, founder
  pick A)** = the **obedience metric** — `obedience % = clean ÷ (clean + blocked/retried)` from the session
  trace, to prove/disprove the co-pilot helps. New chat. `prompts/48-task-obedience-metric.md`.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra`. Compression saved $0; ~$32 was cache-read.
- Session 46: ~$3.84 — four real `vajra claude -p` L3 runs (live-verified the moat; `dogfood_check` 🟢).
- Session 32–35, 37–45, **47**: ~$0.00 each — build/code + NO-CODE GT sessions (S47 = local build/test only).
- Cumulative: **~$65.8**. The dogfood gate is MEASURED and GREEN since S46.
