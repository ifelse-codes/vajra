# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S105 complete, S106 not yet started).
S105 = **NO-CODE GROUND TRUTH** (mandatory, `105 % 5 == 0`), audited **S101–S104** through the
**MVP-shippability** lens. **Verdict = PARTIAL:** the governance **engine** is done and proven (S103
forced commit block, attested/chained ledger, authoritative receipts); the shippable **package** is
~0% — nothing published, README marks 3 install paths "NOT YET PUBLISHED", crate name settled on paper
only (`DECISION-006`). **3 🟢 · 7 🟡 · 0 🔴.** Costs reconcile to the penny (S102 $0.4644 · S103
$0.6797). Machinery-freeze rule (`DECISION-005`) declared **dead letter** post-pivot → Status corrected
to SUPERSEDED. All drift corrected in `.ai/` + docs. Report: `sessions/session-105-ground-truth.md`.

**🔀 FOUNDER PIVOT (S103, still in force):** no more paid multi-day Autopilot-Ladder *sessions* —
sessions now = **finish a shippable MVP**; the founder runs the long unattended test himself, then
release. Founder order **C → B → A**: C (team voice) = S104 DONE → **B (make it installable)** = S106
(next build, founder pick) → A (real named agent fleet) after the MVP ships.

## Active PRs
- **S105:** closeout bundle on `session-105-closeout` (GT report + prompt 106 + `.ai/` corrections +
  DECISION-005 supersession + VISION pivot + varta re-render) — PR to open + merge at founder direction.
- Merged: **S104 [#108](https://github.com/ifelse-codes/vajra/pull/108)** (`session-104-team-voice`) ·
  S103 (`session-103-endurance-adversarial`) · S102 (`main`, `05f836a`) · S101
  [#105](https://github.com/ifelse-codes/vajra/pull/105) · S100
  [#104](https://github.com/ifelse-codes/vajra/pull/104).

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust layer**.
  Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained tamper-evident
  (`DECISION-004`). **No pivot in the product** — the pivot (S103) is in HOW we spend sessions (finish
  the MVP, not run paid ladders).
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 (S106)** (stranger can install
  + 10-min quickstart, proven by a smoke test; crate name settled S101 `DECISION-006`) → A fleet.
  Release when v0.1 is stranger-shippable; the founder owns the long unattended real-world test.
- **The machinery-freeze rule (`DECISION-005`) is RETIRED** (S105 constitution_review): the pivot
  cancelled ladder *sessions*; S104 was neither a ladder run nor a fix-what-broke, and it shipped. The
  new law is the pivot itself — a session finishes a shippable-MVP slice.

## What Currently Works
- **The 8-station governed pipeline speaks like a team** (S104): `vajra next --stations` + the packet
  render named roles + plain status from one source; gates/K unchanged underneath.
- **Autopilot governance PROVEN with a FORCED block (S103):** on chitra a good-faith agent's commit
  was STOPPED by L3 `hook-commit-guard.sh` even under `--dangerously-skip-permissions`; a
  detached/resumable/budget-capped harness ran 6 tasks and its kill-switch fired on cap (Rung 2 PASS).
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested, chained ledger). Receipt
  AUTHORITATIVE when `total_cost_usd` exists, HONEST when it doesn't (S77); closeout blocks unfilled
  execution shas (S81); `--dogfood-age` live git query (S91).
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` → INTACT, tamper-evident (`DECISION-004`).
- **CI green on `main`** (both OS) · `vajra claude · next · check · init · estimate · meter · hook`
  — 7 commands, no 8th.

## What Is Broken / Weak
- **🟡 v0.1 is NOT stranger-shippable yet (S105 lead lens).** Engine done + proven; package ~0% —
  nothing published, README marks 3 install paths "NOT YET PUBLISHED", crate name is paper-only
  (`Cargo.toml` untouched). **S106 target.**
- **🟡 Installability is UNMEASURED (S105 meta-check).** No instrument answers "can a stranger ship
  with this?" — `vajra next --stations` read 7/8 on S101 while every install path was broken. S106
  ships the missing smoke test.
- **🟡 `--dogfood-age` blind to untracked receipts (S105 meta-check).** It reports last dogfood=S97;
  true last=**S103** — the S102/S103 run artifacts are untracked (`??`), so the git-derived query can't
  see them. Founder call: commit the receipts to un-blind it, or accept a documented known-blindspot.
- **🟡 KNOWLEDGE §6 bloat GROWING** (chronic since S60): **475 lines / ~91K tokens** (was 416/85K at
  S100); header "Reloaded every session" still false. Prune queued as an S106-alt option, not done.
- **🟡 `vajra.varta` re-render drifts every session** — `vajra check` FAILs "varta stale" again (was
  frozen at S100). No CLOSEOUT gate reads it, so the S100 fix didn't stick. Re-rendered this closeout;
  a durable gate is the real fix.
- **🟡 `fable-5` monthly credits exhausted (S102).** Paid dogfood costs real $ on sonnet/opus.
- **🟡 Old repos ship without guards (S102)** · **In THIS repo the commit gate is
  auditable-not-un-forgeable** (L3 `commit_guard: off`; L2 belt active; chitra's re-init'd guards ARE
  on, proven S102/S103) · **Compression no-op on real CC** (never claim until measured) · **Cross-agent
  breadth 0 code** (sequenced) · **Legacy opus ids** held at $15/$75.

## What Is In Progress
- **S105 DONE (NO-CODE GT — 3 🟢 · 7 🟡 · 0 🔴; PARTIAL lead lens).** Closeout bundle to PR + merge.
- **Next = S106 — CODE: make it installable (v0.1)** (founder pick ①): one working install path from a
  clean checkout + an installability smoke test + a README quickstart truth-pass. Prompt written:
  `prompts/106-task-installable-v01.md`. **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- Session 53–75: ~$0 each. **S76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative, S102/S103 re-verified this GT from per-run receipts). **S104:
  ~$0** (local reface). **S105: ~$0** (NO-CODE GT; no `vajra claude` run).
- Cumulative: **~$79.3 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
