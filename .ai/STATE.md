# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S48 complete, S49 not yet started). S48 = CODE (instrumentation), founder pick A:
shipped the **obedience metric** (`obedience % = clean ÷ (clean + blocked)`, read-only from the session
trace, surfaced on `vajra meter`) on `session-48-obedience-metric`. Output: `sessions/session-48-summary.md`;
commits `6f8c8be` + `dd8066c` + closeout. ~$0 (local build/test).

## Active PRs
- None open. S48 branch `session-48-obedience-metric` is committed locally (publish-guard is OFF in this
  repo — founder pushes / merges).
- Merged: S47 mid-run murmur [#42](https://github.com/ifelse-codes/vajra/pull/42) · S46 live-redogfood
  [#41](https://github.com/ifelse-codes/vajra/pull/41) · S45 ground-truth
  [#40](https://github.com/ifelse-codes/vajra/pull/40) · S44 settings-json-merge
  [#39](https://github.com/ifelse-codes/vajra/pull/39).
- Housekeeping: prune merged `session-47-*`/`session-46-*` local branches + the stale `origin/session-42-*`.

## Direction (set S18 … enforcement arc completed S37–S44, LIVE-VERIFIED S46 → pivot to B; B sessions S47 murmur, S48 metric)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **S46 FOUNDER DIRECTION LOCK: build B, not A.** (A) "your AI can't go rogue" vs (B) "your AI does better
  work" — founder picked **B**. The enforcement guard is the FLOOR, proven live (S46); the co-pilot that
  makes the work *better* is the product. "Cheaper" for B = **less re-work**, NOT compression (~$0). Memory
  `vajra-direction-b-copilot`.
- **S47 shipped the mid-run murmur** (proactive, non-blocking) but left the honest gap *mechanism verified,
  value UNMEASURED*. **S48 built the measurement — the obedience metric** — closing the S30/S31 "no metric
  measures usage" gap. Honest read: it measures obedience to the RAILS, not work-quality (a floor).
- **Enforcement moat: COMPLETE + LIVE-VERIFIED (S46).** `dogfood_check` 🟢 since S46.
- **Second agent stays parked** — cross-agent code still zero; direction B favors depth-of-value over breadth.
- **MVP framing (S48):** honest value story ✅ · enforcement-holds-live ✅ · frictionless install 🟡
  (crates.io path broken) · **"does better work" 🟡 — the murmur is built (S47) and now has an obedience
  yardstick (S48); work-quality itself is still UNMEASURED (option B).**

## What Currently Works
- **The obedience metric (S48).** `vajra meter <session.jsonl>` prints `obedience %`, `clean`, `blocked`,
  and the blocking hook(s) — mined read-only from the trace (a Vajra rail block surfaces as
  `tool_result{is_error, "PreToolUse:… hook error … [vajra …]"}`). `src/obedience/mod.rs` (pure,
  unit-tested) called from `src/cli/meter.rs`; no hook change, no new dep, no 8th command; runs on past
  sessions. Live: 98.9% (copilot-loader block) · 0% on the S46 isolation run (publish-guard). 20/20 verify.
- **The co-pilot has BOTH halves (S47).** Reactive/blocking = the loader (`hook-copilot-loader.sh`,
  PreToolUse, exit 2 at L2/L3) + guards. Proactive/advisory = the murmur (`hook-copilot-murmur.sh`,
  `UserPromptSubmit`, exit 0 — never blocks), scaffolded into `vajra init` byte-identical.
- **Enforcement moat, complete + scaffolded (S37→S44) + LIVE-VERIFIED (S46).** publish-guard + session-guard
  + jq-preflight (fail-closed on all 5 hooks) + git-level L2 belt + `.claude/settings.json` merge on init.
- **Darshan (S32) founder-confirmed live good** (S36); brownfield onboarding + auth (S34) hold live.
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter`.
  **`cargo test` = 124 lib** (+5 this session) + 12 adapter + integration; clippy + fmt clean.

## What Is Broken / Weak
- **🔴 Work-quality is still UNMEASURED — the new #1 (option B measures it).** Obedience % (S48) proves the
  agent obeyed the rails, NOT that the output was better. It's a floor / proxy — the first rung of the
  ladder. The direction-B thesis ("does better work") is not yet proven by a number.
- **🟡 Obedience-metric blind spot (S48, accepted):** counts only hook-attributed blocks (coupled to CC's
  `hook error` wording + Vajra's `[vajra …]` marker). A rule silently worked around, or rework with no
  hook fire, is invisible → the number is a floor on friction, not a ceiling.
- **🟡 Accepted murmur v0 limit (S47):** in a fresh *uncommitted* repo, `-uall` lists every untracked file,
  so `prompts/*` murmurs even when the agent isn't editing one; a committed repo shows only real changes.
- **🟡 Efficiency is thin.** Compression saves ~$0 on real CC; value must be re-work reduction, not tokens.
- **🟡 cargo/npm/pytest never fold on real CC (S33/S41 carry).** Branch on `exit_code == Some(0)`, which
  real CC never sends → `_fail` passthrough under 300/400 lines. Own future compression session.
- **🟡 Install path: `cargo install vajractl` (README) is not the working install** (crates.io name taken)
  — real install = `cargo install --path`. Plus accepted publish-guard v0 quote-strip over-block (backlog).

## What Is In Progress
- **S48 DONE + closed** (obedience metric, ~$0). The number exists and is honest. **Next (S49)** = founder
  pick from A/B/C: **A** baseline read ($0), **B** value-gap real-task run (PAID — the work-quality proof),
  **C** trace-mine `⚡on` advisories. New chat. `prompts/49-task-<slug>.md` written after the pick.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra`. Compression saved $0; ~$32 was cache-read.
- Session 46: ~$3.84 — four real `vajra claude -p` L3 runs (live-verified the moat; `dogfood_check` 🟢).
- Session 32–35, 37–45, 47, **48**: ~$0.00 each — build/code + NO-CODE GT sessions (S48 = local build/test only).
- Cumulative: **~$65.8**. The dogfood gate is MEASURED and GREEN since S46.
