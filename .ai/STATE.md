# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S51 complete, S52 not yet started). S51 = **CODE/VERIFY · PAID** (direction B,
founder pick A): measured the value gap via a real-task A/B on chitra. Output: `sessions/session-51-summary.md`
+ `sessions/session-51-artifacts/` + `prompts/52-task-value-gap-harder.md` + `scripts/verify-session-51.sh`
(19/19); closeout committed on `session-51-value-gap`. Useful work landed in chitra (its own workflow).
S51 spend ~$1.52 (Arm A $0.8127 · Arm B $0.6813 · probe $0.0265).

## Active PRs
- None open. S51 committed locally on `session-51-value-gap` (publish-guard OFF in this repo — founder
  pushes / merges).
- Merged: S49 obedience-baseline [#44](https://github.com/ifelse-codes/vajra/pull/44) · S48 obedience-metric
  [#43](https://github.com/ifelse-codes/vajra/pull/43) · S47 mid-run murmur
  [#42](https://github.com/ifelse-codes/vajra/pull/42) · S46 live-redogfood
  [#41](https://github.com/ifelse-codes/vajra/pull/41).
- Housekeeping: after merge, prune merged `session-51-*`/`session-50-*`/`session-49-*` locals + stale
  `origin/session-42-*`. In chitra: `session-03-polish-docs` merged to chitra `main`;
  `session-04-readme-getting-started` holds S04 (`def0cfa`).

## Direction (set S18 … enforcement arc completed S37–S44, LIVE-VERIFIED S46 → pivot to B; B: S47 murmur, S48 metric, S49 baseline, S50 GT, **S51 first work-quality reading**)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **S46 FOUNDER DIRECTION LOCK: build B, not A.** (A) "your AI can't go rogue" vs (B) "your AI does better
  work" — founder picked **B**. Enforcement is the FLOOR (proven live S46); the co-pilot that makes the work
  *better* is the product. Memory `vajra-direction-b-copilot`.
- **S47→S49 built the measurement spine of the floor** (murmur → obedience metric → baseline). **S50 GT:** the
  spine measures obedience to the RAILS, not work-quality. **S51 took the first real work-quality reading** —
  and it is an **honest n=1 NULL: no measurable Vajra win, cost ~19% more, on a README one-shot.** The direction-B
  thesis is **UNPROVEN**, not disproven — the task was likely too easy to separate the arms. S52 = a harder task.
- **Enforcement moat: COMPLETE + LIVE-VERIFIED (S46); re-verified live S51** (co-pilot blocked this session's own
  `git commit`, exit 2). `dogfood_check` = **🟢 fresh** (first paid `vajra claude` since S46). Do not re-open the guard.
- **Second agent stays parked** — cross-agent code still zero; direction B favors depth-of-value over breadth.
- **MVP framing (S51):** honest value story ✅ · enforcement-holds ✅ (live) · frictionless install 🟡 (crates.io
  broken) · **"does better work" 🔴 — first measured reading = n=1 null; UNPROVEN. The harder-task test (S52) is
  the fairer proof.**

## What Currently Works
- **The value-gap A/B method (S51).** A repeatable, fair isolation: same real task, Arm A `vajra claude` (full
  Vajra layer, kept) vs Arm B plain `claude` (stripped worktree, discarded); same prompt/tools; authoritative
  `total_cost_usd` capture; objective correctness probes (themes/exports/methods/`toJSON`/file-existence/run-cmd).
  First run: n=1 null. Hand-built this session (S52 candidate B = codify it).
- **The obedience baseline (S49)** + **metric (S48).** `vajra meter [--all]` mines obedience % from traces.
- **The co-pilot has BOTH halves (S47).** Loader (PreToolUse, exit 2) + murmur (UserPromptSubmit, advisory).
- **Enforcement moat, complete + scaffolded (S37→S44) + LIVE-VERIFIED (S46/S51).** 10 hooks, jq-preflight ×6,
  git-belt (`core.hooksPath=.githooks`), `.claude/settings.json` merge on init.
- **Darshan (S32) + brownfield onboarding + auth (S34)** hold live.
- `vajra claude` · `next` · `check` · `init` · `estimate` · `meter`. `cargo test` = 129 lib (unchanged S51 — no
  src/ change).

## What Is Broken / Weak
- **🔴 "Does better work" is measured once = n=1 null (S51).** The direction-B thesis is UNPROVEN. S52 re-tests
  on a harder, convention-heavy task (where captured context should bite) before any verdict.
- **🔴 The vajra receipt overstates cost ~9× (S51, live-found).** Arm A receipt said $7.37; Claude's authoritative
  `total_cost_usd` was $0.81. Cache-pricing miscalibration → the "honest receipt" claim is currently wrong. Use
  `total_cost_usd` until fixed (was S52 candidate C, not picked). Backlog.
- **🟡 Baseline/obedience are descriptive, not causal (S48/S49, accepted).**
- **🟡 Efficiency thin / cargo-npm-pytest never fold on real CC (S33/S41 carry) / install path broken**
  (crates.io name taken → `cargo install --path`; + publish-guard v0 quote-strip over-block).
- **🟡 Env:** nested `claude`/`vajra claude` needs API-key billing (org disabled subscription for the CLI).

## What Is In Progress
- **S51 DONE + closed** (CODE/VERIFY, PAID, ~$1.52). Verdict: first work-quality reading = **honest n=1 null**;
  dogfood 🟢 refreshed; receipt bug found; chitra advanced (S03 merged, S04 committed). **Next (S52) = value gap
  on a HARDER task (n=2, PAID)** — founder pick A; the fairer proof. New chat. `prompts/52-task-value-gap-harder.md`
  ready. **Next mandatory NO-CODE GT = S55.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra`. Compression saved $0; ~$32 was cache-read.
- Session 46: ~$3.84 — four real `vajra claude -p` L3 runs (live-verified the moat).
- **Session 51: ~$1.52** — two paid A/B arms + probe (Arm A $0.8127 · Arm B $0.6813 · probe $0.0265). Authoritative
  `total_cost_usd` (NOT the vajra receipt, which overstated Arm A ~9× at $7.37).
- Session 32–35, 37–45, 47–50: ~$0.00 each — build/code + NO-CODE GT sessions.
- Cumulative: **~$67.3**. Dogfood gate MEASURED 🟢 GREEN at S51 (fresh; last live fire before that = S46).
