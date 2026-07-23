# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S98 complete, S99 not yet started).
S98 = **CODE (docs): AUTOPILOT-TRUST REPOSITION** — the lead becomes the *outcome* ("leave your agent
working for days, come back, trust the result"); the 8-station pipeline is reframed as the **engine**,
not the pitch (`DECISION-005`). Shipped: `docs/decisions/DECISION-005-autopilot-trust.md` (new) +
`VISION.md` autopilot lead + `.ai/ROADMAP.md` 6-Month Autopilot Plan (falsifiable Autopilot Ladder,
2026-09-15 release backstop, content machine, scoreboard, two kill signals, machinery-freeze rule,
frozen backlog). Docs only — **no `src/`**. Independent cold review **ACCEPT 6/6 SHIPPED**, attested
(`Review-Inputs-SHA: bc06d4d6…`), ledger extended. No honesty row softened. ~$0.

## Active PRs
- None open — between sessions.
- Merged (S98 + its two closeout-hardening follow-ups): docs
  [#99](https://github.com/ifelse-codes/vajra/pull/99) ·
  [#100](https://github.com/ifelse-codes/vajra/pull/100) (per-session verify/demo scripts — S98's own,
  added post-hoc) · [#101](https://github.com/ifelse-codes/vajra/pull/101) (`verify-closeout.sh` blocks
  a scriptless CODE session).
- Earlier: S97 [#98](https://github.com/ifelse-codes/vajra/pull/98) ·
  S96 [#97](https://github.com/ifelse-codes/vajra/pull/97) ·
  S95 [#95](https://github.com/ifelse-codes/vajra/pull/95)/[#96](https://github.com/ifelse-codes/vajra/pull/96).

## Direction (governance is the product — now sold as the autopilot trust layer)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`DECISION-001`), **sold as the AUTOPILOT TRUST LAYER** — pipeline = engine, not pitch
  (`DECISION-005`, S98). Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`),
  chained tamper-evident (`DECISION-004`).
- **The reposition (S98):** the crown jewel is *the loop you can bet on while away for days*. The
  canonical demo: "I left Claude alone on a real repo for 3 days — here's every action it tried, what
  got blocked, the fidelity verdicts, the receipt. I merged without reading every line." The 8 stations
  are the engine that makes that true.
- **The Autopilot Ladder replaces the feelings bar** (falsifiable): Rung 1 (=S97, done, hours) → Rung 2
  (1 day unattended, zero-leak + honest receipts + spot-check) → Rung 3 (2–3 days, ≥2 repos, +
  merge-without-line-by-line-review). **Guards ON every run.** **Release backstop:** v0.1 ships when
  Rung 3 passes once OR **2026-09-15**, whichever first. **Machinery-freeze rule:** a session runs the
  ladder or fixes what a run broke — nothing else.
- **S97 finding carried into Rung 2's design (live-evidenced):** Coder doubly-blocked — chitra's older
  scaffold has no `## Execution`/`## Delta` marker slots AND a headless `-p` run can't utter a
  commit-approval token → zero commits → zero shas. Agent refused self-commit even under
  `--dangerously-skip-permissions` vs a teeth-less gate (3rd voluntary-obedience reconfirm). Fix (S99
  option A): *agents write markers, Vajra verifies* + env-marker commit path + scaffold slots.
- **House patterns (carried):** un-forgeable-env markers — `VAJRA_CLOSEOUT_WAIVER` (S56),
  `VAJRA_ALLOW_PUBLISH` (S37), `VAJRA_ALLOW_COMMIT` (S93); repo-identity resolution — a guard derives
  git facts only from the project's OWN git top-level, cannot-evaluate ⇒ fail-CLOSED (S94). Fakest-green
  classes: jurisdiction-self-granted (S69) · hollow-green (S69) · voluntary-not-enforced (closed S93) ·
  fail-open-on-cannot-evaluate (closed S94) · convention-enforced-rule (S98 machinery-freeze — no code
  teeth; S100 GT audits it).

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained
  ledger). Receipt AUTHORITATIVE when `total_cost_usd` exists (S66/S78, proven S92 $0.2713 · S97
  $1.2758), HONEST when it doesn't (S77); closeout blocks unfilled execution shas (S81); Releaser
  durable across pruning (S82); attestation recompute-and-compare (S86/S88); `--dogfood-age` live git
  query (S91).
- **The reposition is installed in `.ai/`** (S98): `DECISION-005` + VISION lead + ROADMAP 6-Month
  Autopilot Plan — the next six months inherit the autopilot-trust direction from `.ai/`, not a chat.
- **Closeout gate hardened (S98 follow-up, #100/#101):** every CODE session carries its own
  `verify-session-NN.sh` + `demo-session-NN.sh` (step 5); `verify-closeout.sh` now BLOCKS a CODE
  session that closes without them (`check_verify_demo_scripts` / `--scripts-only`; NO-CODE GT `N%5==0`
  and `VAJRA_CLOSEOUT_WAIVER` exempt). Closes the hole that let S98 itself ship scriptless at a false
  11/11 green.
- **CI is green on `main`** (S96): `cargo fmt --check` + `clippy -D warnings` + `cargo test --lib` on
  ubuntu + macos; rustfmt pinned 1.9.0-stable.
- **Commit gate ENFORCED (S93):** L2 `.githooks/pre-commit` + L3 un-forgeable `hook-commit-guard.sh`
  (`VAJRA_ALLOW_COMMIT==NN`). Scaffolded ON; `commit_guard: off` in this repo.
- **Guards repo-identity-aware (S94):** git facts pinned to the project's own git top-level;
  fail-CLOSED when a project has no git of its own.
- **`cargo test --lib` 286** (unchanged — S98 was docs-only, no `src/`).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.

## What Is Broken / Weak
- **🟡 Machinery-freeze rule is convention-enforced only (S98, new)** — a written rule in ROADMAP +
  DECISION-005, no code gate. Its teeth depend on S100's GT actually asking "did machinery resume?".
  Disclosed as the session's fakest green.
- **🟡 Coder station doubly-blocked for headless/older-scaffold repos (S97)** — no `## Execution` marker
  slots in chitra's older scaffold + headless `-p` can't approve a commit. Blocks a clean Rung 2
  closeout until fixed (S99 option A: agents-write-markers + env-marker commit path + scaffold slots).
- **🟡 Station counter mis-measures older-scaffold repos (S97)** — `--stations` reads modern marker
  sections a repo scaffolded by an older `vajra init` doesn't contain → `[ABSENT]` conflates
  convention-absent with work-absent. Fix rides the scaffold-marker upgrade.
- **🟡 README carries stale claims (CTO audit, 2026-07-22)** — the ~8× receipt claim + unverifiable
  install paths. Truth-pass scheduled INSIDE the release-backstop task (NOT S98 — scope).
- **🟡 Autopilot trust is claimed as the lead but proven once (S97, Rung 1, partial)** — the Ladder is
  the plan to earn it; climbing it is S99+. Honest gap between the pitch and the evidence.
- **🟡 KNOWLEDGE §6 bloat (chronic, flagged S60)** — 416 lines / 69 entries / ~85K tokens; header
  "Reloaded every session" is false (load-order #7, on-demand). Frozen backlog item.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** — L3 `commit_guard: off`; L2 belt
  inline-forgeable; `--no-verify` bypasses. Teeth proven by test + shipped ON in scaffolds. NOTE:
  ladder runs require guards ON (DECISION-005).
- **🟡 Compression no-op on real CC (S63/S76)** — never claim until measured; cargo/npm/pytest fold gap.
- **🟡 Cross-agent breadth (original S25 ask) is still zero code** — now sequenced in the plan
  (neutral `agent-trace` evidence format first, months 3–6), not built.
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — held at $15/$75 (S79).

## What Is In Progress
- **S98 DONE (CODE / docs — autopilot-trust reposition) + 2 closeout-hardening follow-ups merged**
  (#100 per-session scripts · #101 the scriptless-CODE-session block). Next = **S99** (founder picks from 3 ranked
  candidates in `sessions/session-98-summary.md`: **A** Coder-marker fix [recommended] · **B** Rung 2
  ladder dogfood · **C** release-backstop slice). **New chat.** Then **S100 = NO-CODE GT** (lead lens:
  is the ladder being climbed, or did machinery resume?).

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- Session 53–75: ~$0 each. **S76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713 authoritative** (sonnet-4-6, dogfood).
- **S93/S94/S95/S96: ~$0** · **S97: $1.2758 authoritative** (fable-5 e2e dogfood; + ~$0.26 nested-launch
  smoke ≈ $1.54 session total). **S98: ~$0** (docs-only, no paid run).
- Cumulative: **~$77.5 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
