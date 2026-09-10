# Session 160 — Ground Truth (mandatory, 160 % 5 == 0)

**Date:** 2026-09-10  
**Type:** NO-CODE Ground Truth  
**Sessions audited:** S156–S159  
**Verdict:** 🟡 PARTIAL PASS

---

## Live instrument results

| Tool | Output | Verdict |
|---|---|---|
| `bash scripts/stranger-check.sh` | 21/21 PASS | 🟢 |
| `bash scripts/scaffold-drift.sh` | 17/17 PASS | 🟢 |
| `cargo fmt --check` | clean (no output) | 🟢 |
| `cargo test --lib` | 487 passed, 0 failed | 🟢 |
| `vajra next --dogfood-age` | S124 · 2026-08-20 · 35 sessions · 20 days | ⚠️ tool blind spot (see dogfood_staleness) |
| `vajra next --stations 156` | 3/8 | — |
| `vajra next --stations 157` | 4/8 | — |
| `vajra next --stations 158` | 6/8 | — |
| `vajra next --stations 159` | 4/8 | — |

---

## Audit 1 — vision_alignment

**Question:** Is the north-star still the right destination? Is current work the shortest path?

- North-star: *leave your agent working for days, come back, trust the result* — unchanged, coherent.
- S156–S159 were: admin close, tiny code fix (1 match arm), demo enforcement, advice re-audit. None advances the Autopilot Ladder or external adoption.
- Founder priorities at S140: (1) fresh-user upgrade ✅ S141-S143, (2) first-contact dogfood D2 ❌ STILL OUTSTANDING, (3) prove-then-cut-cost ❌ 15+ sessions deferred.
- **The Sept 15 release backstop is 5 days away (today = Sept 10).** v0.1 release conditions were met at S108 (crates.io, binaries, README, Homebrew tap). Rung 2 endurance and Rung 3 have NOT passed. 0 stars, ~19 downloads (last checked).

**Verdict:** 🟡 PARTIAL — vision coherent; current work is maintenance not advancement; D2 dogfood is overdue; adoption signal flat; the backstop is not a blocker (release already shipped) but Rung 2/3 are the real open items.

---

## Audit 2 — roadmap_alignment

**Question:** Does each phase map to the north-star? Is the next item highest-leverage?

- Roadmap phases: engine ✅ · installable ✅ · fleet ✅ (9 roles built) · ladder runs 🟡 (Rung 1 done, Rung 2 partial, Rung 3 not started).
- S161 candidates should be: D2 first-contact dogfood (founder priority 2) OR ladder Rung 2 retry (priority 3).
- **No roadmap item scheduled for ladder Rung 2/3.** This has been true since S103 pivot ("founder runs the long test himself"). The ladder has no session owner today.
- The S155 GT named "prove-then-cut-cost 11 sessions overdue"; this GT names it **15 sessions overdue**.

**Verdict:** 🟡 PARTIAL — roadmap is coherent but the ladder (the actual pitch) has slipped for 15+ sessions with no named owner.

---

## Audit 3 — state_drift

**Question:** Does STATE.md match reality?

Checked fields:
- `Active Branch: None — between sessions (S159 complete, S160 not yet started)` → CORRECT (S160 branch just created; not committed yet).
- `Active PRs: S159 PR: to be opened at closeout` → STALE. PR #191 was MERGED 2026-09-09. This is the same structural drift S65 / S125 named: the snapshot is written before the merge, so "to be opened" becomes stale the moment closeout runs.
- `What Currently Works` section → accurate.
- `session-156-admin-close` is still a live local branch (merged but not pruned) → STATE.md does not track this; Releaser gate surfaces it.

**Verdict:** 🟡 — one stale field (PR status); structural not operational; same class as prior sessions.

---

## Audit 4 — knowledge_staleness

**Question:** Is KNOWLEDGE.md current?

- 282 lines. Header: "282 lines as of S156 — pruned from 1364 lines at S155 GT" → ACCURATE.
- S156–S159 added no permanent facts that would require KNOWLEDGE.md entries (admin close, 1-line fix, demo enforcement, audit doc).
- No §6 decision log entry missing for S156–S159.

**Verdict:** 🟢 — KNOWLEDGE.md accurate and not bloated.

---

## Audit 5 — constraint_violation_review

**Question:** Any rule violations in S156–S159?

| Session | Violation | Severity |
|---|---|---|
| S158 | design-advisor rec 4 deferred without named session — violates S152 carry-forward rule | 🔴 |
| S158 | fidelity-reviewer recs 1 & 2 deferred without named session — violates S152 | 🔴 |
| S155 | S153-FR carry-forward (C5 circular check) targeted S155 but GT took no action | 🟡 |
| S155 | S154-QA recs 1–3 targeted S155 but GT took no action | 🟡 |
| All | Releaser station NEVER passes (merged locals not pruned) — structural, not a violation per se | 🟡 |

S158 non-compliant carry-forwards (recs deferred with no named session) = **3 active violations** of the S152 rule. They were flagged in STATE.md but not resolved. This GT must assign them.

**Verdict:** 🔴 THREE active S152 carry-forward violations from S158. Resolution in §Carry-Forward Decisions below.

---

## Audit 6 — constitution_review

**Question:** Any AGENTS.md rule now blocking the vision?

- All rules reviewed. None blocks the vision.
- `One vajra-session per chat` — convention today, enforcement roadmapped. Not blocking.
- The obedience / carry-forward / condensation rules (S152/S153) are load-bearing and well-formed.
- Fidelity ≠ discipline rule is the most important guard and is being exercised (two-pass reviews, cold subagent).

**Meta-check:** The GT audits cover discipline (rules followed) well. But **no audit measures whether the pipeline PAYLOAD advances** (the S25/S60/S65/S70/S74 meta-gap). `--stations NN` was added at S74 specifically for this. Using it:

| Session | K/8 | Notes |
|---|---|---|
| S156 | 3/8 | DOCUMENT — Analyst/Architect/Planner/Demo-er absent by design |
| S157 | 4/8 | CODE — Demo-er absent (no demo script for tiny fix); Releaser always absent |
| S158 | 6/8 | CODE — best in window; Demo-er + Releaser absent |
| S159 | 4/8 | DOCUMENT — Analyst/Architect absent by design |

Pattern: Releaser ABSENT in all 4 (one merged branch, `session-156-admin-close`, never pruned). Demo-er absent for S157 (no demo on a 1-line fix — defensible). S158 at 6/8 is the high-water mark.

**Verdict:** 🟢 — no rule blocks the vision. Structural: the Releaser station cannot reach PASS without explicit pruning step at close.

---

## Audit 7 — cost_review

**Question:** Are costs tracked? Is the cap relevant?

- S156–S159: ~$0 metered each (local, no headless `-p` runs).
- Last paid run: S144 ($11.742, chitra full-loop dogfood). Real cumulative: ~$116.
- Per-session cap: $5.00. No session breached it since S138B ($5.41 cap breach, recorded).
- Prove-then-cut-cost arc: deferred since S145 (15 sessions). The context compression that was the original ADR-0001 bet has never been validated under real cost pressure. This is not a cost-review finding; it is a direction finding.

**Verdict:** 🟢 — costs tracked, cap not breached. Prove-then-cut-cost arc remains deferred by founder decision.

---

## Audit 8 — dogfood_check

**Question:** Has real work run through `vajra claude` since the last ground-truth (S155)?

- S155 GT: 2026-09-08. S160 GT: 2026-09-10.
- S156–S159 were all local sessions (no `vajra claude` invocation, no paid run).
- No dogfood between S155 GT and S160 GT.

**Verdict:** 🔴 — no dogfood run in the inter-GT window. Caveat: 2 days between GT sessions, and the prior paid run (S144) was 6 days before S155 GT. The real staleness measure is `--dogfood-age`.

---

## Audit 9 — pipeline_advance_check

**See instrument results above + constitution_review §pipeline.** Summary:

- S156–S159 each ran with fidelity-reviewer + tech-lead (S156: review-only, no formal handoffs).
- S156 missed formal handoffs → carries `-- fleet: (none)` in `--stations`.
- S157/S158/S159 have 3, 3, 2 governed handoffs respectively.
- Pipeline advancing for CODE sessions (S158 at 6/8). DOCUMENT/GT sessions structurally lower.
- Releaser ABSENT systemically due to unpruned `session-156-admin-close`.

**Verdict:** 🟡 PARTIAL — pipeline advances for CODE sessions; DOCUMENT sessions structurally partial; Releaser station blind spot is structural.

---

## Audit 10 — dogfood_staleness

**Live query: `vajra next --dogfood-age`**

```
last dogfood session : 124
date (git-derived)   : 2026-08-20
cost (authoritative) : $3.2985
sessions since       : 35 (S124 → current S159)
calendar days since  : 20 day(s)
```

**Tool blind spot confirmed:** The tool reads only this repo's receipts. Real last dogfood = S144 (chitra, $11.742, 2026-09-04, 16 sessions ago, ~6 days before S155 GT). The tool cannot see cross-repo runs. This blind spot has been documented since S140 and rated LOW priority. It persists.

**Does STATE.md agree?** STATE.md says `Last closed session | Session 136…` in the `Where We Are` table (stale from S136's snapshot; the roadmap is more current). No explicit dogfood-date field in STATE.md as a maintained item.

**Verdict:** 🟡 — tool blind spot persists (known, LOW). Real last dogfood = S144 (~21 days before S160 GT). No dogfood since.

---

## Audit 11 — stranger_check

```
=== stranger-check summary ===
  checks passed: 21
  checks failed: 0
  GREEN — a stranger's first ten minutes work.
```

**Verdict:** 🟢 21/21 PASS.

---

## Audit 12 — scaffold_drift_check

```
=== scaffold-drift: 17 passed, 0 failed ===
GREEN — 13/13 binding rules, 10/12 audits, 7/7 axes carried.
```

Scaffold warning printed by the tool itself: `src/cli/init.rs` still hand-types `communication.forbid`, `load_order`, `demo.required_elements` against live twins in `.ai/CONSTRAINTS.yaml`. Named by S129 pass-2 cold review, refused in-session with reason, still top of the next pick.

**Verdict:** 🟢 17/17 PASS. Disclosed hand-typing limit unchanged.

---

## Carry-Forward Decisions (S160 GT resolution)

Items brought to this GT from STATE.md:

| # | Item | Origin | Decision |
|---|---|---|---|
| 1 | S156-FR-r1: replace SESSION-number proxy for AC1 with git ancestry check | S156 fidelity-reviewer | **backlog** — applies to administrative prune/merge sessions only; no prune session scheduled; write a note in verify template instead when one arises |
| 2 | S156-FR-r2: add AC5 falsifiability check to future prune sessions | S156 fidelity-reviewer | **backlog** — same as above; applies at the time a prune session is authored |
| 3 | S157-FR-r2: remove grep checks from future verify scripts; rely on cargo test | S157 fidelity-reviewer | **backlog** — applies gradually as new scripts are written; a dedicated session is disproportionate; the pattern applies to every new verify script from now |
| 4 | S158-DA-r4: write DECISION record for session-type detection contract | S158 design-advisor (S152 violation) | **→ S161** (assign to next CODE or DOCUMENT session regardless of type; write a DECISION record for `is_code_session()` and demo marker contract; ~30 min) |
| 5 | S158-FR-r1: improve demo-session-158.sh to exercise blocking path | S158 fidelity-reviewer (S152 violation) | **→ S161** (add a synthetic fixture session that is CODE but has no demo script; runs the blocking path live) |
| 6 | S158-FR-r2: replace source-proximity grep with behavioral integration test in verify-session-158.sh | S158 fidelity-reviewer (S152 violation) | **→ S161** (add a behavioral test that actually calls `check_demo_markers` on a no-marker synthetic) |
| 7 | S159-FR-r1: strengthen verify-session-159.sh greps to count all 15 items | S159 fidelity-reviewer | **backlog** — S159 is a closed historical session; the pattern (count-not-presence) should apply to future audit verify scripts |
| 8 | S153-FR: C5 circular check (greps AGENTS.md note, not real handoff file) — targeted S155, not acted on | S153 fidelity-reviewer | **→ S161** (fix the `check_required_crew` Brief: grep to target a real handoff file, not the AGENTS.md prose that documents the requirement) |
| 9 | S154-QA recs 1–3: waiver path, tightening-delta, full script invocation | S154 qa-specialist | **backlog confirmed** (already in STATE.md; waiver path and tightening-delta are low-risk edge cases; full-script invocation is partially superseded by the S158 live-demo gate) |

**S161 mandatory carry-forwards (items 4, 5, 6, 8):** Any session beginning as S161 — CODE or DOCUMENT — MUST address all four before closing. These violate S152 and have been deferred twice.

---

## Meta-check: what did this audit miss?

The GT instruments measure governance fitness — rules followed, tests passing, stranger happy. They cannot observe:

1. **Market readiness**: 0 stars, ~19 downloads. No mechanism in any audit asks "did anyone outside this repo try it this week?" This has been true for 160 sessions and 20+ days public.
2. **Sept 15 backstop tracking**: The release backstop (2026-09-15) is 5 days away. v0.1 release conditions were met at S108; the backstop is technically satisfied. But the Autopilot Ladder (the real pitch) has no session owner and no scheduled run. No audit measures this gap.
3. **Advice influence**: S159 re-audit showed Hollow rate at 67% (vs 36% baseline). New Hollow patterns: sessions without formal handoffs break tracking; deferred items without named sessions (now corrected for S158). The S152 rule fixed one pattern and two new ones emerged. This is a sign that Hollow-advice is a structural property of how advice is generated and reviewed, not a fixable rule-gap.

---

## Summary scorecard

| Audit | Verdict |
|---|---|
| 1 · vision_alignment | 🟡 Coherent but stalled (maintenance ≠ advancement) |
| 2 · roadmap_alignment | 🟡 Ladder has no session owner (15+ sessions) |
| 3 · state_drift | 🟡 One stale field (PR status, structural) |
| 4 · knowledge_staleness | 🟢 282 lines, accurate |
| 5 · constraint_violation_review | 🔴 3 active S152 violations (S158 carry-forwards) — resolved here → S161 |
| 6 · constitution_review | 🟢 No blocking rules; pipeline 6/8 peak (S158) |
| 7 · cost_review | 🟢 $0 in window; cap not breached |
| 8 · dogfood_check | 🔴 No dogfood in inter-GT window (2 days; real last = S144) |
| 9 · pipeline_advance_check | 🟡 CODE sessions advancing (S158 6/8); Releaser structural gap |
| 10 · dogfood_staleness | 🟡 Tool blind spot (S124 reported, real = S144 ~21 days) |
| 11 · stranger_check | 🟢 21/21 |
| 12 · scaffold_drift_check | 🟢 17/17 |

**Overall: 🟡 PARTIAL PASS.** 4 green · 4 yellow · 2 red (constraint violations + no inter-GT dogfood). Constraint violations are resolved by assigning to S161. Dogfood red is structural (2-day GT window, no paid work in that window).

---

## 3 Candidate next sessions (A / B / C)

### A — D2: First-contact dogfood (founder priority 2, OUTSTANDING)

**Goal:** Run `vajra init` on a fresh empty repo, drive a full session loop — governed by chitra's own fleet — to a verified close with at least the 3 mandatory roles (tech-lead, design-advisor, fidelity-reviewer) producing real handoffs.  
**Why pick this:** It is founder priority 2 since S140. It exercises the install → govern → close path a real stranger would follow. D1 (governed real work in chitra) was satisfied at S134. D2 has been deferred for 20 sessions.  
**Key risk:** Paid run (~$5–$12 based on S138/S144). The session closes only when `verify-closeout.sh` exits 0 under a real governed run, which took ~$8.39 at S138B. Budget cap = $5; may require founder waiver.

### B — S161: Close the S158 carry-forwards + C5 fix (DOCUMENT/CODE, mandatory 4 items)

**Goal:** Write DECISION record for `is_code_session()` / demo marker contract (S158-DA-r4), add blocking-path fixture to demo-session-158.sh (S158-FR-r1), add behavioral integration test to verify-session-158.sh (S158-FR-r2), fix C5 circular grep in verify-closeout.sh (S153-FR).  
**Why pick this:** These 4 items are S152 violations (deferred twice without named sessions). They are not optional — the fidelity-reviewer must grade them NOT-BUILT if carried again. Scope is bounded: 4 specific items, all small.  
**Key risk:** Low. This is protocol debt, not product advancement. Taking it first delays D2 again.

### C — Autopilot Ladder Rung 2 retry (paid dogfood)

**Goal:** Run `vajra claude` in chitra unattended for 1 day with guards ON (publish_guard + commit_guard armed), multi-task. Pass condition: zero governance leaks · honest receipts · fidelity verdicts correct on founder spot-check.  
**Why pick this:** It is the actual demo that earns the trust claim. Rung 1 done at S97; Rung 2 partial (S102, endurance not met). Without a completed rung, the "leave your agent for days" north-star is unverified.  
**Key risk:** Paid, literal 1-day clock (founder runs it). Requires chitra to be in a clean state. If guards fail, the session is a 🔴 finding, not a close.

---

*Awaiting founder pick. Recommended: A (D2 dogfood) — it is the oldest open founder priority and the most load-bearing gap before any adoption push. B is mandatory regardless and should be bundled with whatever S161 is, not taken alone.*
