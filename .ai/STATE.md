# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S92 complete, S93 not yet started).
S92 = **DOGFOOD** — paid `vajra claude` ride-along on chitra S08 (`release.yml`).
Result: **$0.2713 authoritative** cost; governed agent wrote `release.yml`+verify(15/15)+demo on
`session-08-release-workflow`, then refused the autonomous commit (VOLUNTARY obedience). Dogfood 🔴→🟢.
Report: `sessions/session-92-ground-truth.md`.

## Active PRs
- Merged: S91 [#90](https://github.com/ifelse-codes/vajra/pull/90)/[#91](https://github.com/ifelse-codes/vajra/pull/91) ·
  S90 (NO-CODE GT) · S89 [#88](https://github.com/ifelse-codes/vajra/pull/88) ·
  S88 [#87](https://github.com/ifelse-codes/vajra/pull/87) · S87 [#86](https://github.com/ifelse-codes/vajra/pull/86).
- **S92 PR:** TBD (`session-92-dogfood-paid-pipeline`).

## Direction (governance is the product — 8 governed stations, now dogfood-proven)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S92 outcome:** the pipeline was exercised as a lived experience over a real subject repo for
  **$0.27**. Receipt authoritative (S78 delivered), staleness self-measuring (S91 delivered),
  governance held — but **voluntarily** at the commit boundary (no hook checks for approval).
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood:
  **now 🟢 — S92 = 2026-07-21, $0.2713** (was S76, 🔴 for 15 sessions). ③ compression: never
  claimed until measured (0 folds; S92 receipt shows sonnet-4-6, no fold data surfaced). ④ payload
  counter = BUILT (S74) + GT-verified + hardened (S82).
- **House patterns (carried):** dogfood staleness derived from git via `--dogfood-age` (S91), never
  STATE.md's date. Un-forgeable-env gate (`VAJRA_CLOSEOUT_WAIVER`, S56) — S93 reuses it at the
  commit boundary. Fakest-green classes: jurisdiction-self-granted (S69) · hollow-green (S69) ·
  voluntary-not-enforced obedience (S76/S92, S93 target).

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt AUTHORITATIVE when `total_cost_usd` exists (S66/S78) — **proven live in
  S92 dogfood ($0.2713 captured via the tee path)** — HONEST when it doesn't (S77), correctly
  priced on the estimate (S79); closeout blocks unfilled execution shas (S81); Releaser durable
  across pruning (S82); headless read-only warned (S83); typed cannot-evaluate BLOCK (S84);
  attestation cryptographically verified (S86); S76 Execution recorded (S87); hash review-stable
  (S88); ROADMAP compact (S89); S89 Reviewer PASSED (S91B); **`--dogfood-age` derives staleness
  live from git (S91C) — now shows S92 · $0.2713.**
- **`cargo test --lib` 283** (unchanged — S92 had no src/ changes).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.
- **CONSTRAINTS.yaml `required_audits`** — 10 audits.

## What Is Broken / Weak
- **🔴→🟡 Commit-gate obedience is VOLUNTARY** — S92 (+ S76) confirmed the agent self-stops at
  `commit.autonomous: false` but **no hook enforces it**; L2 pre-commit blocks only main/>3/drift.
  **S93 (picked) closes this** with an un-forgeable approval gate.
- **🟡 `--dogfood-age` date `<unresolvable from git log>` pre-commit** — cost resolves (read from
  the receipt) but the git-derived Added-date needs the artifacts committed. Resolves post-closeout.
- **🟡 chitra S08 left open** — governed agent stopped at chitra's commit gate; completing it
  (approval → commit → verify/demo/PR) is a separate chitra session, not this Vajra dogfood.
- **🟡 S92 "CI passes" = chitra `verify-session-08.sh` (15/15), not a real GitHub Actions run** —
  no `v*` tag pushed, so npm publish never actually executed. Structural pass only.
- **🟡 S89 Demo-er station ABSENT** — `demo-session-89.sh` emits no `demo:<element>` markers
  (historical; low severity).
- **🟡 `--inputs-sha` post-merge-tip edge case still ABSENT** — hash computed after merge has no
  intermediate candidate (disclosed S91; different root cause from S89).
- **🟡 `--dogfood-age` artifact naming is convention-based** (`receipt.stderr.txt`/`vajra-receipt.txt`).
- **🟡 Compression is a no-op on real CC (S63/S76; S92 surfaced no fold data)** — never claim until measured.
- **🟡 Cross-agent breadth (original S25 ask) is still zero code** — founder-gated per S26/S70.
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — held at $15/$75 (S79).
- **🟡 `full_historical_scan` pass bar is a floor (`verified >= 16`)** (S88, low severity).
- **🟡 `candidate_diffs` rescans every merge on every single-session query** — cheap today (~2s), O(n).
- 🟡 `vajra init` template omits `pipeline_advance_check` precedent · ledger tamper-EVIDENT not
  PROOF + opt-in · guard nested-repo blindspot · install path.

## What Is In Progress
- **S92 DONE (DOGFOOD).** Next = S93 (CODE — prove the commit gate has teeth). **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **Session 77–91: ~$0 each** (S78 ~$0.055). **Session 92: $0.2713 authoritative** (sonnet-4-6, dogfood).
- Cumulative: **~$74.0 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
