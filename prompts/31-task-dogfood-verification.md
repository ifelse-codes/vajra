# Session 31 — Dogfood / Verification: run real work through `vajra claude` (CODE)

> **The S30 ground-truth verdict made this #1.** The founder-satisfaction gate (S26 override, parks the second agent) is **unmeasured** — cumulative spend is ~$0.46, *all from S07*. `vajra claude` — the actual product loop — has not been run for real in 22 sessions. You cannot declare Vajra-on-Claude "satisfying" from build-sessions. **This session generates the evidence.**

## Goal (one story)

Run a **real, non-trivial unit of work through `vajra claude`** — the full loop: launch → compression hook fires → meter/receipt on exit — and capture what the founder actually experiences. Then the founder renders the gate verdict **with evidence in hand**.

This is a *verification/dogfood* session, not a feature session. The "code" is exercising the existing binary in anger and recording the truth, plus any **small** fix that the dogfood proves is blocking (≤3 files, one story — not a polish spree).

## What to actually do

1. **Build + run the real loop.** `cargo build --release`, then drive a genuine task through `vajra claude` (e.g. have it do a small real edit in a scratch repo). Confirm: settings injection is additive, the PostToolUse compression hook fires on real output, the receipt prints honest numbers on exit. Capture the receipt.
2. **Record the founder's lived experience** — not "tests pass," but: was it *satisfying*? Where did it feel like friction (the S18 onboarding gap — `vajra claude` has no auth pre-check; the S25 "spent leverage" polish)? Name the single biggest day-to-day pain.
3. **Cost reality:** this session *will* spend real API $ (first since S07). Update the cost ledger honestly — this is the point, not a regression.
4. **Verdict on the gate (the whole reason for S30→S31):** with evidence now in hand, is Vajra-on-Claude satisfying enough to **promote the second agent**? Y → S32 returns the second agent to #1 (sanity-check ADR-0002's adapter contract is genuinely vendor-neutral first). N → fix the *one* real pain the dogfood surfaced, then re-test.

## Guardrails

- One story (dogfood the loop + record verdict). Any fix must be the *single* blocking one the run proved — ≤3 files, no scope creep into S25's "spent leverage" polish.
- Branch `session-31-<slug>`. No `main` commits, no autonomous commits, ≤3 files/commit, ~2h cap.
- `verify-session-31.sh` green before closeout; `scripts/verify-closeout.sh` exits 0.
- Honor the **new `dogfood_check` audit axis** (added S30): the cost ledger is the evidence that real work ran.

## Carry-forwards into S31

- Propagation arc (S22→S29) is complete — no propagation work remains.
- Second agent stays parked — gate is **"unmeasured," not "unsatisfied."** This session measures it.
- Still open, candidate fixes if the dogfood proves them blocking: `vajra claude` auth pre-check (S18 gap); `vajra estimate` 3:1 ratio unvalidated.
- PR-status "drift" is retired as an accepted snapshot-before-merge artifact (S30) — do not re-flag it.
