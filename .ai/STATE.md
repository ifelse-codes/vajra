# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S52 complete, S53 not yet started). S52 = **CODE/VERIFY · PAID** (direction B,
founder pick A): measured the value gap on a **harder** task — a real publishable `dist/` build for
`@chitra/core` — via the same real-task A/B on chitra. Output: `sessions/session-52-summary.md` +
`sessions/session-52-artifacts/` + `prompts/53-task-reframe-governance-product.md` +
`scripts/verify-session-52.sh`; closeout committed on `session-52-value-gap-harder`. Useful work landed in
chitra (its own workflow). S52 captured spend **~$3.55** (+ ~$1.4 sunk on a killed foreground run ≈ **~$4.95**).

## Active PRs
- None open. S52 committed locally on `session-52-value-gap-harder` (publish-guard OFF in this repo — founder
  pushes / merges).
- Merged: S49 obedience-baseline [#44](https://github.com/ifelse-codes/vajra/pull/44) · S48 obedience-metric
  [#43](https://github.com/ifelse-codes/vajra/pull/43) · S47 mid-run murmur
  [#42](https://github.com/ifelse-codes/vajra/pull/42) · S46 live-redogfood
  [#41](https://github.com/ifelse-codes/vajra/pull/41).
- Housekeeping: after merge, prune merged `session-52-*`/`session-51-*` locals. In chitra: S04 README + S05
  ground-truth + **S06 real dist build** all merged to chitra `main` (`61a9e67`); Arm B worktree discarded.

## Direction (set S18 … enforcement arc completed S37–S44, LIVE-VERIFIED S46 → pivot to B; B: S47–S49 spine, S51 first work-quality reading, **S52 second reading = n=2 null → S53 reframes to governance**)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **S46 FOUNDER DIRECTION LOCK was B.** (A) "your AI can't go rogue" vs (B) "your AI does better work" — founder
  picked B. **S51+S52 measured B and got an n=2 NULL** (no measurable work-quality win; +12–19% cost; on the
  harder task both arms produced the *same solution and the same bug*). Governance/drift-prevention (the FLOOR /
  direction A) is what kept working, live, every session. **Founder pick at S52 close: reframe Vajra around
  GOVERNANCE as the product (S53)** — evidence-led, gated on the "beat just-git-hooks" differentiator test.
  Memory `vajra-direction-b-copilot`.
- **Enforcement moat: COMPLETE + LIVE-VERIFIED (S46); re-verified live S51 + S52** (co-pilot blocked this
  session's own `git commit`; session-guard blocked a branch; Arm A refused to code in a NO-CODE slot). Do not re-open the guard.
- **Second agent stays parked** — cross-agent code still zero (the moat's cross-agent claim is aspirational, a fact S53 must state plainly).

## What Currently Works
- **The value-gap A/B method (S51+S52), now n=2.** Same real chitra task, Arm A `vajra claude` (governed, kept)
  vs Arm B plain `claude` (Vajra-stripped throwaway worktree, discarded); identical prompt/tools; authoritative
  `total_cost_usd`; objective correctness probes. **Lesson (S52): headless Opus build tasks exceed the 10-min
  foreground cap → run the arms backgrounded.**
- **Governance / drift-prevention — the repeatedly-demonstrated value.** S52: governed run refused to code in a
  NO-CODE ground-truth slot; the governed GT caught real chitra discipline drift; Vajra's guards fired live 3×.
- **The obedience baseline (S49) + metric (S48).** `vajra meter [--all]` mines obedience % from traces.
- **The co-pilot has BOTH halves (S47).** Loader (PreToolUse, exit 2) + murmur (UserPromptSubmit, advisory).
- `vajra claude` · `next` · `check` · `init` · `estimate` · `meter`. `cargo test` = 129 lib (unchanged S52 — no
  `src/` change). Darshan + Varta + co-pilot + enforcement moat (10 hooks) hold live.

## What Is Broken / Weak
- **🔴 "Does better work" is measured twice = n=2 null (S51 README + S52 dist build).** Direction B is UNPROVEN;
  S53 reframes to governance (the thing that works). Not disproven — the fair-test doubt stands (single bounded
  tasks under-test the long-horizon claim) — but not the lead.
- **🔴 The vajra receipt overstates cost ~8× (re-confirmed S52).** Arm A build: receipt $11.72 vs authoritative
  $1.40. "Honest receipts" is currently wrong on a real run. Use `total_cost_usd` until fixed. Backlog.
- **🟡 Guard nested-repo blindspot (S52, live-found).** `session-guard` + `copilot-loader` can't tell a nested
  subject repo's `session-NN` branches from Vajra's own → false-tripped when orchestrating chitra. S53 candidate.
- **🟡 Efficiency thin / cargo-npm-pytest never fold on real CC (S33/S41 carry) / install path broken**
  (crates.io name taken → `cargo install --path`).
- **🟡 Env:** nested `claude`/`vajra claude` needs API-key billing (org disabled subscription for the CLI).

## What Is In Progress
- **S52 DONE + closed** (CODE/VERIFY, PAID, ~$4.95). Verdict: **n=2 null on work-quality** (both arms same
  solution + same `.tsbuildinfo` bug; +12% cost); real value shown = governance/drift-prevention. dogfood 🟢
  refreshed (guards fired live 3×); receipt ~8× bug re-confirmed; chitra advanced (S05 GT + **S06 dist build**
  landed on chitra `main`, npm-buildable). **Next (S53, founder pick) = reframe Vajra around GOVERNANCE as the
  product (NO-CODE positioning)** — gated on the differentiator test. New chat.
  `prompts/53-task-reframe-governance-product.md` ready. **Next mandatory NO-CODE GT = S55.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 — two real runs against `/private/tmp/chitra`.
- Session 46: ~$3.84 — four real `vajra claude -p` L3 runs (live-verified the moat).
- Session 51: ~$1.52 — two paid A/B arms + probe.
- **Session 52: ~$4.95** — captured $3.55 (probe $0.07 · Arm A refusal $0.26 · chitra GT $0.56 · Arm A build
  $1.40 · Arm B build $1.26) + ~$1.4 sunk on a 10-min killed foreground run. Authoritative `total_cost_usd`
  (NOT the vajra receipt, which overstated Arm A ~8× at $11.72).
- Session 32–35, 37–45, 47–50: ~$0.00 each — build/code + NO-CODE GT sessions.
- Cumulative: **~$72.3**. Dogfood gate MEASURED 🟢 GREEN at S52 (guards fired live 3×).
