# Session 90 — Ground Truth Audit

**Date:** 2026-07-21
**Type:** NO-CODE mandatory GT (`90 % 5 == 0`; last GT = S85)
**Scope:** S86–S89
**Branch:** `session-90-closeout`

---

## Headline Verdicts

| Audit | Verdict | Short finding |
|---|---|---|
| `vision_alignment` | 🟡 PASS | Direction correct; cross-agent breadth still 0 code |
| `roadmap_alignment` | 🟡 PASS | Plan coherent; next item is dogfood refresh |
| `state_drift` | 🔴 FAIL | "19+ calendar days stale since S76 (2026-07-03)" is wrong — S76 was 2026-07-18 (S36's date was cited by mistake) |
| `knowledge_staleness` | 🟡 PASS | KNOWLEDGE.md current through S85; S86–S89 session detail absent (expected — Rule 5) |
| `constraint_violation_review` | 🟢 PASS | No hard-rule violations in S86–S89 |
| `constitution_review` | 🟢 PASS | AGENTS.md still serves the vision; no perverse incentive found |
| `cost_review` | 🟢 PASS | Costs tracked honestly; S76 "unknown" is correct |
| `dogfood_check` | 🔴 STALE | 13 sessions (S77–S89) / **2–3 calendar days** since S76 (2026-07-18); no paid run since |
| `pipeline_advance_check` | 🟡 FINDING | S86/S87/S88 = 7/8 ✓; S89 = **5/8** — Demo-er missing markers + Reviewer hash mismatch |

---

## 1. `vision_alignment`

**Verdict: 🟡 PASS**

Questions:
- *Is the north-star still the right destination?* **Yes.** Provable agent governance via a governed SDLC pipeline. Nothing since S85 undermines this.
- *Is current work the shortest path, or scope creep?* **Mostly yes.** S86–S89 were all in-pipeline hardening: attestation correctness (S86), S76 execution sha fill (S87), attestation snapshot fix (S88), ROADMAP cleanup (S89). All bounded, legitimate debt. The concern raised at S85 (easy-green detour) remains a pattern — four consecutive sessions of mechanism repair vs. net-new station progress.
- *What evidence would force a pivot?* Two more paid dogfood runs showing the 8-station pipeline doesn't change real user behavior — but we haven't had those runs.

**Watch:** cross-agent breadth is still 0 code. This is the founding differentiator and the S25 north-star gap indicator is still unbuilt. Not an emergency (founder-gated) but it's aging.

---

## 2. `roadmap_alignment`

**Verdict: 🟡 PASS**

- Each phase still maps to the north-star (governance → pipeline → measure → breadth).
- Next item = dogfood refresh (highest-leverage). The backlog is correctly ordered.
- No item is now obsolete. The "cross-agent 2nd agent" item is founder-gated, not obsolete.
- The "derived readable-roadmap one-pager" was S89's actual delivery — DONE.
- The ROADMAP "Where We Are" table is now current (S89 fixed it after 27 sessions stale).

**Gap:** the ROADMAP says S89's Dogfood staleness = "12 sessions / 19+ days since S76 (2026-07-03)." See `state_drift` — this date is wrong.

---

## 3. `state_drift`

**Verdict: 🔴 FAIL**

**Primary finding — date error carried from S36 into S76 dogfood staleness tracking:**

STATE.md (and SESSION-BOOT.md) both state:
> "Dogfood: stale since S76 — now 12 sessions (S77–S89) / 19+ calendar days"
> "S90 GT — 12+ sessions / 19+ calendar days stale since S76 (2026-07-03)"

**2026-07-03 is S36's date, not S76's.** Git evidence:
```
2026-07-18  S76 closeout (1/2)
2026-07-19  Merge pull request #74 … session-76-dogfood-ride-along
```

S76 was 2026-07-18/19. The correct staleness as of today (2026-07-21):
- **Sessions:** 13 (S77–S89) ← the count was right
- **Calendar days:** **2–3** (since 2026-07-18/19) ← the date was wrong

The "19+ days" figure appears to be a carry-forward from measuring staleness against S36 (2026-07-03, the first big dogfood), not S76. This entered the state docs and was never corrected.

**Other STATE.md claims — verified correct:**
- `cargo test --lib` = 271 ✓ (confirmed)
- Pipeline = 8 stations ✓
- Active branch = None (between sessions) ✓
- Cost tracking accurately reflects known/unknown ✓

---

## 4. `knowledge_staleness`

**Verdict: 🟡 PASS**

- KNOWLEDGE.md covers through S85 in detail. S86–S89 facts are not yet in KNOWLEDGE.md — consistent with Rule 5 (per-session detail lives in `sessions/` not here). No permanent facts appear stale.
- The S86–S89 permanent lessons (attestation recompute-and-compare works; live-bytes is the safe canonical_inputs_sha approach; docs-only consolidation has non-script-verifiable content fidelity) should be added at closeout.
- One mild concern: KNOWLEDGE.md records that S76 dogfood ran on "2026-07-03" in some older entries about S36. Those are correct (they refer to S36). The error is in STATE.md/SESSION-BOOT.md attributing S36's date to S76 staleness.

---

## 5. `constraint_violation_review`

**Verdict: 🟢 PASS**

Reviewing S86–S89 against `CONSTRAINTS.yaml`:

| Session | Branch | Files/commit | Approval | No-main | Stories | Verify |
|---|---|---|---|---|---|---|
| S86 | `session-86-harden-attestation-check` ✓ | ≤3 ✓ | recorded ✓ | ✓ | 1 ✓ | 26/26 ✓ |
| S87 | `session-87-fix-s76-execution-shas` ✓ | ≤3 ✓ | recorded ✓ | ✓ | 1 ✓ | documented ✓ |
| S88 | `session-88-fix-canonical-inputs-sha-snapshot` ✓ | ≤3 ✓ | recorded ✓ | ✓ | 1 ✓ | documented ✓ |
| S89 | `session-89-fix-roadmap-stale-table` ✓ | ≤3 ✓ | recorded ✓ | ✓ | 1 ✓ | 16/16 ✓ |

No violations. The 2-assumption / 2-retry caps appear honored in all four sessions. The `VAJRA_CLOSEOUT_WAIVER` was used correctly for NO-CODE or docs-only sessions where `## Execution` shas don't apply.

**Rule now blocking the vision?** None identified. The "no autonomous commits" rule continues to serve the product.

---

## 6. `constitution_review`

**Verdict: 🟢 PASS**

- AGENTS.md's 10-step loop is intact and still serves the vision.
- The fidelity/discipline distinction (DECISION-002) remains the correct hard rule — S86–S89 each had cold independent reviews.
- The "new session = new chat" rule (step 10) was honored across S86–S89.
- No clause creates a perverse incentive visible from this session's vantage.

**Meta-check — did this audit's own mechanism miss a kind of drift?**

Yes, one class: **the auditor cannot verify that S86–S89 cold reviews were genuinely independent.** The ACCEPT verdicts are present and hashes are attested, but the GT audit reads the review file — it cannot know if the "independent" reviewer was fed anything beyond the prompt + diff. This is the DECISION-002 structural limit, disclosed in AGENTS.md. Not a new finding, but worth naming again.

Also: the 9-audit checklist in `CONSTRAINTS.yaml` is measured against discipline (were sessions S86–S89 compliant?). It is structurally weak at catching **vision drift** from a series of individually-clean sessions — exactly the "easy-green detour" pattern S80/S85/S90 each flag. The checklist is necessary but not sufficient.

---

## 7. `cost_review`

**Verdict: 🟢 PASS**

| Session | Spend | Notes |
|---|---|---|
| S86 | ~$0 | Rust code only; no paid claude run |
| S87 | ~$0 | Docs fill; no paid claude run |
| S88 | ~$0 | Rust code only; no paid claude run |
| S89 | ~$0 | Docs only; no paid claude run |

Cumulative: **~$73.7 + S76 unknown (≤ ~$26.6 opus-estimate)**

The S76 "unknown" is honestly recorded — `total_cost_usd` is captured in the `-p` stream, but the receipt can only report what was observable; fable-5 wasn't priced at S76 time (fixed S77). This is an honest accounting gap, not a tracking error.

The $5/session warn-mode budget cap has never fired. Budget cap is still WARN not KILL — noted as a standing question but not a violation.

---

## 8. `dogfood_check`

**Verdict: 🔴 STALE**

Has real work run through `vajra claude` since S85 (last GT, 2026-07-20)?

**No.** S86–S89 were all code/docs sessions that did NOT use `vajra claude` to drive a real task.

Staleness since S76 (last paid dogfood):
- **Sessions stale:** 13 (S77, S78, S79, S80 GT, S81, S82, S83, S84, S85 GT, S86, S87, S88, S89)
- **Calendar days stale:** **2–3** (S76 committed 2026-07-18, merged 2026-07-19; today 2026-07-21)

**Correction vs. prior state:** STATE.md claimed "19+ calendar days stale." The calendar day count was wrong (it used S36's date 2026-07-03). The session count (13) was close but the count in STATE.md said 12 (S77–S89 is 13 sessions). Both are corrected here from git evidence.

**What this means:** The 8-station governed pipeline has NOT been run on a real task since S76. The S86–S88 hardening (attestation checks, execution sha fill) was TESTED in verify scripts and E2E fixtures, but never run in a live `vajra claude` session. The hollow-green class (S69) applies here: the tests pass, the gates exist, but live behavior is unmeasured.

Per `CONSTRAINTS.yaml#ground_truth.dogfood_questions`:
> "If not, any 'is Vajra-on-Claude satisfying?' verdict is unmeasured by definition — flag it, do not guess."

**Flagged.** No satisfaction verdict is possible.

**Note on the founder's S70 decision:** dogfood was deferred-by-decision at S70. That decision ages — 13 sessions later, the pipeline has changed substantially (S81–S89: closeout guard, Releaser durability, headless warning, typed CannotEvaluate, attestation hardening, S76 shas, live-bytes fix, ROADMAP cleanup). The live experience may have drifted significantly from the S76 baseline. The deferred-by-decision label is still valid but this GT recommends revisiting the gate.

---

## 9. `pipeline_advance_check`

**Verdict: 🟡 FINDING (S89 shows 5/8)**

Live `vajra next --stations NN` output for S86–S89:

```
=== S86 ===  7/8
  [PASSED] Analyst   WHAT
  [ABSENT] Architect DESIGN  — not design-significant (expected for fix sessions)
  [PASSED] Planner   HOW
  [PASSED] Coder     DID
  [PASSED] QA        WORKS   (static)
  [PASSED] Demo-er   SHOW    (static)
  [PASSED] Releaser  SHIP
  [PASSED] Reviewer  REVIEW  — hash verified

=== S87 ===  7/8
  [PASSED] Analyst   WHAT
  [ABSENT] Architect DESIGN  — not design-significant
  [PASSED] Planner   HOW
  [PASSED] Coder     DID
  [PASSED] QA        WORKS   (static)
  [PASSED] Demo-er   SHOW    (static)
  [PASSED] Releaser  SHIP    — via ledger (branch pruned, S82 durability)
  [PASSED] Reviewer  REVIEW  — hash verified

=== S88 ===  7/8
  [PASSED] Analyst   WHAT
  [ABSENT] Architect DESIGN  — not design-significant
  [PASSED] Planner   HOW
  [PASSED] Coder     DID
  [PASSED] QA        WORKS   (static)
  [PASSED] Demo-er   SHOW    (static)
  [PASSED] Releaser  SHIP
  [PASSED] Reviewer  REVIEW  — hash verified

=== S89 ===  5/8  ← FINDING
  [PASSED] Analyst   WHAT
  [ABSENT] Architect DESIGN  — not design-significant
  [PASSED] Planner   HOW
  [PASSED] Coder     DID
  [PASSED] QA        WORKS   (static)
  [ABSENT] Demo-er   SHOW    — demo script missing markers: header, cases, summary_table, before_after
  [PASSED] Releaser  SHIP
  [ABSENT] Reviewer  REVIEW  — hash mismatch (cannot reconstruct diff)
```

**Shape reading (per the S85 nuance):** The 7/8 flat line across S86–S88 is expected — all three were non-design-significant fix sessions; Architect's absence is structural, not a stall. The Releaser durability fix (S82) is what makes S87's "via ledger" path work correctly. Reading the shape: the pipeline is nominally advancing with no new stations (the spine is complete at 8; 7/8 is the ceiling for non-design sessions).

**S89 finding — 5/8 is new and unexpected:**

1. **Demo-er ABSENT** — `demo-session-89.sh` exists but does not emit `demo:<element>` markers (`header`, `cases`, `summary_table`, `before_after`). S89 was docs-only; the demo was written before S71's element-marker contract was fully applied to docs sessions. The script runs and exits 0, but the element scan fails. This is a **session-specific gap** — the demo shows the ROADMAP diff correctly but lacks the required markers.

2. **Reviewer ABSENT (hash mismatch)** — The S89 review file has `Review-Inputs-SHA: 7992ca91…` but `--stations 89` reports "matches no reconstructable diff." S89 was a docs-only session (ROADMAP.md, prompt, verify, demo — no `src/` change). The `canonical_inputs_sha` reconstruction may not handle docs-only diffs correctly, or the hash was computed against a snapshot that differs from what the tool can reconstruct. This is a new data point on the attestation system's robustness for non-code sessions.

**Severity:** Medium. S89 is a docs-only session; neither the Demo-er nor the Reviewer gap changes what shipped (the ROADMAP cleanup is real and verifiable). But the Reviewer hash mismatch means the attestation chain has a break at S89, and the Demo-er gap means the marker contract wasn't applied retroactively to the docs session's demo.

**Counter pattern:** No station has been added since S72 (the 8-station spine is complete by definition). The counter ceiling for non-design sessions is 7/8. Any session at 5/8 or below is a flag.

---

## Meta-Check

**Did this audit's mechanism miss a kind of drift?**

Two gaps:

1. **Easy-green detour (3rd consecutive GT finding the same shape):** S85 found it; S86–S89 were each bounded and real, but the four-session run chose mechanism repair over dogfood or new capability. The GT audit can label this retroactively but has no pre-session tripwire. Adding a "sessions-since-dogfood" count to the mandatory GT inputs (alongside K-of-8) would surface it earlier. **Recommendation: track sessions-since-dogfood as a GT-required live query.**

2. **The calendar-day staleness error survived S85–S89 undetected:** STATE.md's "19+ days since S76 (2026-07-03)" was wrong, yet three subsequent GTs (S80, S85) didn't catch it (S80 cited the "17+ days" variant). The GT audits counted sessions correctly but read the calendar date from state docs rather than computing from git. **Rule: dogfood staleness (session count AND calendar days) must be computed from git, not read from STATE.md.**

---

## Overall Synthesis

Three tiers:

**🔴 Fix before next session:**
- Correct STATE.md / ROADMAP "Where We Are" dogfood date from "2026-07-03" → "2026-07-18" (S76's actual date). Calendar days = 2–3, not 19+.
- S89 Demo-er missing markers and Reviewer hash mismatch — decide whether to add markers to `demo-session-89.sh` and re-attest, or formally waive (docs-only session; the gap is low-stakes but the Reviewer break is in the ledger chain).

**🟡 Watch, not emergency:**
- Easy-green detour: 3 GTs in a row found the same shape. The next CODE session should prefer dogfood refresh or a new capability over mechanism hardening.
- Cross-agent breadth: still 0 code, still the founding differentiator gap.

**🟢 Clean:**
- All 4 sessions (S86–S89) honored the process. Fidelity gate held. No rule violations. Costs accurate. KNOWLEDGE.md current.

---

## Carry-Forward to S91+

**Recommended candidates** (drawn from ROADMAP backlog + this GT's findings):

**A 🥇 — Dogfood refresh (paid)**
Goal: run the full 8-station pipeline on a real task via `vajra claude`; measure the governed experience end-to-end.
Why pick: 13 sessions since the last paid run; the pipeline has changed substantially (S81–S89); live evidence beats all mechanism arguments; founder decision S70 deferred-but-not-cancelled.
Risk: fable-5/opus cost is real; S76 found `--dangerously-skip-permissions` wall — that's now warned (S83) but still a workflow friction point.

**B 🥈 — Fix S89 Reviewer hash mismatch**
Goal: diagnose why docs-only sessions produce an unverifiable `Review-Inputs-SHA`; fix `canonical_inputs_sha` or add a waiver path for docs-only sessions; re-attest S89 if viable.
Why pick: breaks the ledger chain at S89; surface finding from this GT's live `--stations 89` run.
Risk: small scope, bounded, but may be a deeper attestation gap for any non-src-change session.

**C 🥉 — Sessions-since-dogfood as mandatory GT input**
Goal: add a live `vajra next --dogfood-age` or similar command that reports sessions and calendar days since the last `total_cost_usd > 0` receipt; make it a required GT check alongside `--stations`.
Why pick: this GT caught a staleness date error that three prior GTs missed because they read from state docs; a live derived query would prevent recurrence.
Risk: small Rust change, but a new derived metric requires deciding what "a paid session" means (receipt-based).
