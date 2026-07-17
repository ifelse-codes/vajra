# Session Boot

## Current Session
- **Number:** 71 — COMPLETE
- **Type:** **CODE** — the **Demo-er station** (pipeline station 7, the SHOW gate; founder pick B
  at the S70 GT, sharpened to the sprint demo: before → after, "seeing it the user knows what
  this session delivered").
- **Shipped:** `src/demoer/mod.rs` (+11 unit tests, 214 lib total) — `vajra next --demo NN`
  surfaces the recorded `CONSTRAINTS.yaml#demo` contract read-only; `--check-demo NN` RE-RUNS
  the demo LIVE and blocks on a non-zero exit OR a `demo:<element>` marker missing from the
  live output (hollow exit-0 demos die on the element scan); wired into `--advance` on the
  CLOSING session after QA (`VAJRA_SKIP_DEMOER_GATE=1` distinct, skips the run itself,
  disclosed). `before_after` is a required element (repo + scaffold);
  `scripts/demo-session-template.sh` EXISTS now (the S70 gap), propagated `include_str!`
  byte-identical. Permission dodge killed (chmod-000 BLOCKS; existence = `is_file()`).
- **Proof:** `verify-session-71.sh` **43/43** · demo-71 green (4 markers live) · independent
  cold review **ACCEPT** (5/5 SHIPPED, 27 adversarial probes), attested `a51a44d6…` ·
  fmt/clippy clean · commits ≤3 files. Fakest green (disclosed): marker-stuffing — the gate
  proves the demo PRINTS its elements, never that it demonstrates (the `covers:`-class floor,
  now six gates wide).
- **Branch:** `session-71-demoer-stage` (PR to `main` — founder call to merge). **S71 spend ~$0.**
- **Date last updated:** 2026-07-17

## Repo State Snapshot
- `.ai/SESSION` = 71 (advanced via `vajra next --advance` at closeout — the four closing gates
  fired on the GT session 70: Options/Coder/QA/Demo-er all WARN-or-pass as specified for
  NO-CODE sessions; the forward gates found prompts/71 READY).
- **Pipeline = 7 governed stations:** WHAT (Analyst) · DESIGN (Architect) · HOW-plan (Planner) ·
  DID (Coder) · WORKS (QA) · **SHOW (Demo-er, S71)** · REVIEW (fidelity + attested ledger) +
  the authoritative receipt. 7 commands, no 8th.
- Remote: `origin` → `https://github.com/ifelse-codes/vajra`.

## Next Session
- **Number:** 72
- **Type:** **CODE** — the **Releaser station** (pipeline station 8, the SHIP gate; standing
  founder direction "finish the crew"). Git-native ship hygiene enforced at close: session
  branch merged into main (ancestry), local main synced with origin, merged `session-*`
  branches pruned — the S37 founder-flagged return-to-main gap becomes enforcement.
  `--release/--check-release`, `VAJRA_SKIP_RELEASER_GATE=1` distinct, no network in the gate.
- **Prompt:** `prompts/72-task-releaser-stage.md` (APPROVED, gate-checked READY ×3).
  **Branch:** `session-72-releaser-stage`. **New chat.**

## Carry-Forwards
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S72; do NOT start it here.
- **S70 founder decisions (binding):** dogfood deferred-by-decision (crew first, founder-led
  manual run after) · compression never-claim-until-measured · payload counter = backlog.
- **House patterns:** existence-gate every recorded marker (S67/S68); re-run live every
  executable marker (S69); element-scan the live output (S71); existence = `is_file()`, never
  readability (S71).
- **Deferred debts after S71:** self-granted-jurisdiction class SIX-wide (disclosed) · no
  timeout on live gate runs (QA+Demo-er) · compression make-it-real (never claim) · payload
  counter [backlog] · dogfood (founder-gated) · fable-5 price · guard nested-repo blindspot ·
  install path · readable-roadmap one-pager (backlog) · Demo-er minors (dir-at-path ·
  empty-list fallback · static-scan comments) · QA empty-env-value skip.
- **S75 = the next mandatory NO-CODE GT.**
