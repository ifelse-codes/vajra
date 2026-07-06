# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S46 complete, S47 not yet started). S46 = CODE/VERIFY, PAID live re-dogfood on
`session-46-live-redogfood`; no source-code change (deliverable = live evidence + docs). Output:
`sessions/session-46-summary.md` + committed artifact `sessions/session-46-live-hook-fire.txt`.

## Active PRs
- None open. Merged: S45 ground-truth [#40](https://github.com/ifelse-codes/vajra/pull/40) · S44
  settings-json-merge [#39](https://github.com/ifelse-codes/vajra/pull/39) · S43
  git-level-belt [#38](https://github.com/ifelse-codes/vajra/pull/38) · S42 `jq`-preflight
  [#37](https://github.com/ifelse-codes/vajra/pull/37) · S41 compression fail-gate
  [#36](https://github.com/ifelse-codes/vajra/pull/36).
- Housekeeping: one stale `origin/session-42-*` remote branch lingers (local branches pruned cleanly).

## Direction (set S18 … enforcement arc completed S37–S44, LIVE-VERIFIED S46 → pivot to B)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **S46 FOUNDER DIRECTION LOCK: build B, not A.** Offered (A) "your AI can't go rogue" (safety/guardrail)
  vs (B) "your AI does better work" (correct results, less re-work, less babysitting), the founder picked
  **B**. The enforcement guard is the FLOOR, now proven; the co-pilot that makes the work *better* is the
  product. **The enforcement arc is DONE — stop polishing the guard.** This is a return to the north star
  the S37→S46 guard work drifted from (the drift S25/S30/S40/S45 kept flagging). "Cheaper" for B comes
  from **less re-work**, NOT compression (~$0). Memory `vajra-direction-b-copilot`.
- **Enforcement moat: COMPLETE + LIVE-VERIFIED (S46).** `dogfood_check` 🟢 for the first time since S36.
  A real autonomous agent's `git push` was blocked at exit 2 in the captured JSONL (run 4, isolation
  harness); 4/4 live runs leaked nothing. **Two layers proven:** (1) governance-in-context — today's
  Claude self-refuses the guarded action 3/3 in a full scaffold; (2) the hook backstop still blocks when
  governance is stripped. The S36 leak was the *absence* of the guard (built S37), not a defiant agent.
- **Second agent stays parked** — cross-agent code still zero. The S26 gate now HAS its input (enforcement
  holds live), but direction B favors depth-of-value over breadth; the 2nd agent is not a B move.
- **MVP framing (S46):** honest value story ✅ · enforcement-holds-live ✅ (was the blocker, now closed) ·
  frictionless install 🟡 (crates.io path broken) · **"does better work" 🔴 unbuilt/unmeasured — the new #1.**

## What Currently Works
- **Enforcement moat, complete + scaffolded (S37→S44) + LIVE-VERIFIED (S46).** publish-guard
  (`git push`/`gh pr create`/`merge` block at L2/L3 unless `VAJRA_ALLOW_PUBLISH=1`) + session-guard (arms
  on `git checkout -b session-(N+1)` and `vajra next --advance`) + jq-preflight fail-closed on all 5 hooks
  + git-level L2 belt (`.githooks/*`, `core.hooksPath=.githooks`) + `.claude/settings.json` merge on init.
  All scaffolded byte-identical via `include_str!`; greenfield + brownfield. **S46 caught the publish-guard
  firing exit-2 against a live autonomous agent's real `git push`** (nested JSONL, not a synthetic payload).
- **Live agent-behaviour finding (S46):** today's Claude, given the scaffolded constitution, refuses
  guarded outward actions on its own (3/3 full-scaffold runs) — the governance layer works before the hook.
- **Darshan (S32) founder-confirmed live good** (S36); brownfield onboarding + auth (S34) hold live;
  **auth resolves for a nested `claude -p`** (contra S31/S36 — the earlier 401 was env-specific).
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter`.
  **`cargo test` = 135 green** (117 lib + 12 adapter + 6 integration; last full run S45); clippy + fmt clean.

## What Is Broken / Weak
- **🔴 "Does better work" (direction B) is unbuilt and unmeasured — the new #1.** Vajra today is a
  safety/guidance layer; it has NOT been shown to make the AI produce *correct results more cheaply with
  less babysitting*. No baseline exists (Vajra-vs-plain on a real task). S47 candidate A measures it.
- **🟡 Efficiency is thin.** Compression saves ~$0 on real CC; Vajra *adds* a one-time context-load cost
  (cache-write $0.03–1.02/run in S46). The "quiet bonus" is effectively zero — the value must be re-work
  reduction, not tokens.
- **🟡 cargo/npm/pytest never fold on real CC (S33/S41 carry).** Branch on `exit_code == Some(0)`, which
  real CC never sends → `_fail` passthrough under 300/400 lines. Own future compression session.
- **🟡 Boot-packet cost (#18) — DEPRIORITIZED by S46.** S36's ~$32 cache-read was vajra's own heavy `.ai/`;
  a scaffolded project's cache-read is tiny ($0.03–0.19). Bites the vajra repo, not a normal user.
- **🟡 Install path: `cargo install vajractl` (README) is not the working install** (crates.io name
  taken/unpublished) — real install = `cargo install --path`.
- **🟡 Accepted publish-guard v0 limits** (line-based quote-strip over-blocks a multi-line quoted command —
  observed live this session on the orchestrator's own command; fail-safe direction) + merge key-reorder + budget-cap-didn't-bite — backlog.

## What Is In Progress
- **S46 DONE + closed** (live re-dogfood, PAID ~$3.84). Moat live-verified, `dogfood_check` 🟢.
  **Founder pivot to direction B.** **Next (S47)** = a **B** session (pending founder pick A/B/C in the
  summary; A = measure the value gap, recommended). New chat.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 31: first real `vajra claude` dogfood since S07 (chitra; exact $ not captured).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra`. Compression saved $0; ~$32 was cache-read.
- Session 32–35, 37–45: ~$0.00 each — build/code + NO-CODE GT sessions.
- **Session 46: ~$3.84** — four real `vajra claude -p` runs (L3 dogfood): $1.2221 + $1.8299 + $0.3908 +
  ~$0.40 (run 4 errored mid-response, meter unprinted). Compression $0; cache-read tiny ($0.03–0.19).
- Cumulative: **~$65.8**. **The dogfood gate is now MEASURED and GREEN** (flagged 🔴 at S30/S35/S40/S45).
