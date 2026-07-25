# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S100 complete, S101 not yet started).
S100 = **NO-CODE GROUND TRUTH** (mandatory, `100 % 5 == 0`; audited S96–S99). Lead lens: *is the
autopilot ladder being climbed, or did machinery resume?* → **PARTIAL PASS.** The ladder is being
climbed (Rung 1 paid + real at S97; S99 was a genuine fix-what-broke, nothing else), and the
machinery-freeze rule held — on a **sample size of 1**. Score: **4 🟢 · 5 🟡 · 1 🔴**.
**The finding is one level down and lands on S101:** both instruments this GT must use —
`vajra next --stations` (K-of-8) and the attested fidelity ledger — are **blind to DOGFOOD and GT
sessions**, which the freeze rule now makes the norm. Report: `sessions/session-100-ground-truth.md`.

## Active PRs
- **S100 open:** GT closeout bundle on `session-100-closeout` (report + drift corrections + `.ai/` sync).
- Merged: S99 [#103](https://github.com/ifelse-codes/vajra/pull/103) · S98
  [#99](https://github.com/ifelse-codes/vajra/pull/99) /
  [#100](https://github.com/ifelse-codes/vajra/pull/100) /
  [#101](https://github.com/ifelse-codes/vajra/pull/101) /
  [#102](https://github.com/ifelse-codes/vajra/pull/102) · S97
  [#98](https://github.com/ifelse-codes/vajra/pull/98) · S96
  [#97](https://github.com/ifelse-codes/vajra/pull/97).

## Direction (governance is the product — sold as the autopilot trust layer)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`DECISION-001`), **sold as the AUTOPILOT TRUST LAYER** — pipeline = engine, not pitch
  (`DECISION-005`, S98). Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`),
  chained tamper-evident (`DECISION-004`). **S100 re-confirmed the north-star; no pivot.**
- **The Autopilot Ladder** (falsifiable): Rung 1 (=S97, done, hours) → Rung 2 (1 day unattended,
  zero-leak + honest receipts + spot-check) → Rung 3 (2–3 days, ≥2 repos, + merge-without-review).
  **Guards ON every run.** **Release backstop:** v0.1 ships when Rung 3 passes once OR **2026-09-15**,
  whichever first. **Machinery-freeze rule:** a session runs the ladder or fixes what a run broke.
- **S100 addition to the direction:** *a ladder run's deliverable is a claim, not a diff.* Until a
  ladder run produces reviewable evidence (and is reviewed), "we ran N days unattended" is a story,
  not a proof — and the proof is the entire product claim.

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained
  ledger). Receipt AUTHORITATIVE when `total_cost_usd` exists (S66/S78, proven S92 $0.2713 · S97
  $1.2758), HONEST when it doesn't (S77); closeout blocks unfilled execution shas (S81); Releaser
  durable across pruning (S82); attestation recompute-and-compare (S86/S88); `--dogfood-age` live git
  query (S91).
- **Ledger verified live at S100:** `verify-closeout.sh --ledger-verify` → **INTACT**, 36 records,
  head `521e66c1…`. Tamper-evident, not tamper-proof (by design, `DECISION-004`).
- **Coder station no longer dark (S100 close of the S95 finding):** PASSED in S96, S98, S99.
  `--stations`: **S96 7/8 · S97 1/8 · S98 7/8 · S99 8/8** (S99 = the first full sweep).
- **Coder reachable unattended (S99):** `vajra init`'s kickoff carries the station markers; a
  pre-marker prompt reports `[LEGACY]`, never `[ABSENT]`; commit pre-authorization
  (`VAJRA_ALLOW_COMMIT=NN`) surfaced on `vajra next` AND the boot packet — advisory + agent-forgeable,
  the L3 guard keeps the teeth.
- **Closeout gate hardened (S98 #100/#101):** every CODE session carries `verify-session-NN.sh` +
  `demo-session-NN.sh`; `verify-closeout.sh` BLOCKS a CODE session without them.
- **CI green on `main`** (S96, both OS) · **`cargo test --lib` 293** · `vajra claude · next · check ·
  init · estimate · meter · hook` — 7 commands, no 8th.

## What Is Broken / Weak
- **🔴 Ladder runs are invisible to both GT instruments (S100 meta-check, NEW).** `--stations` reads
  DOGFOOD/GT sessions at 1–3 of 8 *by construction* (S90 1/8 · S92 2/8 · S95 3/8 · S97 1/8), and the
  fidelity gate is **waived** on them — S97, the paid ladder run, closed with **no
  `sessions/session-97-review.md`**, self-certified in its own summary. Under the freeze rule those
  sessions are now the norm, so the counter will report a stall while the product advances. Fix =
  an **evidence contract** for ladder runs, not more machinery (S101 candidate B / A's mitigation).
- **🟡 The fidelity waiver is unbounded.** `waiver_ok()` is un-forgeable in *identity*
  (`VAJRA_CLOSEOUT_WAIVER == N`) but waives the *entire* gate, including the review's existence.
  Aggravator: `sessions/session-97-summary.md:4` records the token as `dogfood-no-src-changes`, which
  `waiver_ok()` would reject — the audit trail of a governance demo misrecords the bypass token.
- **🟡 `must_write_next_prompt_before_close` violated at S99 close** — `prompts/100-*.md` did not exist;
  this session wrote it. Root cause: `check_session_pair` gates the *current* session's prompt, never
  the next one, so closeout went 10/10 green with the rule broken.
- **🟡 `vajra check` has been red for 20 sessions** — `vajra.varta` was frozen at S79 (score 10/11)
  and no gate reads `vajra check`. Re-rendered at this closeout; the *gate* gap remains (frozen).
- **🟡 S98 ran 4 PRs under one session number** (#99–#102) against `max_stories_per_session: 1` — two
  were self-corrections of its own step-5 miss. Session boundary blurred; recorded, not retro-fixed.
- **🟡 S99 does NOT retro-fit prompts already on disk** — chitra's `prompts/00–03` are still legacy;
  `--advance` chitra before Rung 2 or it re-hits the marker wall (`[LEGACY]`, correctly).
- **🟡 Commit-auth classification lives twice** (Rust + bash); verify asserts agreement, nothing
  structurally prevents drift.
- **🟡 README carries stale claims (CTO audit 2026-07-22)** — ~8× receipt claim + unverifiable install
  paths. Truth-pass scheduled INSIDE the release-backstop task.
- **🟡 Autopilot trust is the lead but proven once** (S97, Rung 1, partial 2/8). Honest gap between
  pitch and evidence; the Ladder is the plan to close it.
- **🟡 KNOWLEDGE §6 bloat (chronic, flagged S60, 9th GT reporting it)** — **416 → 461 lines**; header
  "Reloaded every session" still false (load-order #7, on demand). Frozen backlog item.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** — L3 `commit_guard: off`; L2 belt
  inline-forgeable; `--no-verify` bypasses. Ladder runs require guards ON (DECISION-005).
- **🟡 Compression no-op on real CC (S63/S76)** — never claim until measured.
- **🟡 Cross-agent breadth is still zero code** — sequenced (neutral `agent-trace` format first), not built.
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — held at $15/$75 (S79).

## What Is In Progress
- **S100 DONE (NO-CODE GT — S96–S99 audited)**, closeout bundle on `session-100-closeout`.
  **Founder sign-off required before code resumes.** Next = **S101**, founder picks:
  **A** Autopilot Ladder Rung 2 (paid, one-day unattended on chitra — *recommended, with the S100
  mitigation: write the run's evidence contract into the prompt*) · **B** ladder-run evidence contract
  (make the ladder auditable before climbing it — closes the 🔴) · **C** release-backstop slice
  (README + VISION truth-pass, crate rename scoping). Full text:
  `sessions/session-100-ground-truth.md`. **New chat** for S101.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- Session 53–75: ~$0 each. **S76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713 authoritative** (sonnet-4-6, dogfood).
- **S93/S94/S95/S96: ~$0** · **S97: $1.2758 authoritative** (fable-5 e2e dogfood; + ~$0.26 nested-launch
  smoke ≈ $1.54 session total). **S98: ~$0** (docs-only). **S99: ~$0** (machinery). **S100: ~$0**
  (NO-CODE GT; no `vajra claude` run).
- Cumulative: **~$77.5 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
