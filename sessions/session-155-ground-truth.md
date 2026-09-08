# Session 155 — Ground Truth Report

**Date:** 2026-09-08  
**Type:** Mandatory NO-CODE Ground Truth (155 % 5 == 0)  
**Overall verdict: 🟡 PARTIAL PASS**

---

## Live audit results (commands run)

| Check | Result |
|---|---|
| `cargo fmt --check` | 🟢 EXIT 0 |
| `cargo test --lib` | 🟢 486/486 PASS |
| `bash scripts/stranger-check.sh` | 🟢 21/21 PASS |
| `bash scripts/scaffold-drift.sh` | 🟢 17/17 PASS |
| `bash scripts/verify-closeout.sh` (on main) | 🔴 14 PASS / 2 FAIL |
| `vajra next --stations 154` | 5/8 |
| `vajra next --dogfood-age` | S124 / 2026-08-20 / 30 sessions / 19 days |

---

## Audit 1 — vision_alignment 🟢

**Question:** Does the current build still map to the stated vision in VISION.md?

- VISION.md is accurate, honest, and current (corrected S100, reframed S53, repositioned S98, pivoted S103).
- Current work (governance + fleet + pipeline stations) maps directly to "provable agent governance."
- No overclaim — VISION.md plainly states: cross-agent = 0 code, Autopilot Ladder at Rung 1, "better work" is hypothesis not the pitch.
- The last 5 sessions (S151–S154 + S150 GT) all served the pipeline and constitution fidelity — on-vision.

**Verdict: 🟢** Vision is accurate and current work is the shortest path to it.

---

## Audit 2 — roadmap_alignment 🟡

**Question:** Is the current roadmap the shortest path to the vision, or has it drifted?

- ROADMAP.md is correctly updated through S154.
- S156–S157 are pre-planned (advice-influence re-audit) but require 3–4 more sessions of data — we're at 3.
- **Drift:** the "prove-then-cut-cost" arc is marked "🟡 deferred since S145 · Highest-priority for S155+ range" in STATE.md. It has now been deferred 11 sessions (S145→S155). The $11.74/session baseline (S144) is the adoption blocker. The roadmap names it but nothing has been scheduled.
- No scope creep; sessions S151–S154 were disciplined (fmt fix, DOCUMENT, CODE).

**Verdict: 🟡** Roadmap is accurate but prove-then-cut-cost is 11 sessions overdue. It must be scheduled now.

---

## Audit 3 — state_drift 🟡

**Question:** Does STATE.md accurately reflect the repo? Any stale claims?

Claims verified and their status:

| STATE.md claim | Live check | Result |
|---|---|---|
| "486 lib tests" | `cargo test --lib`: 486/486 | ✓ accurate |
| "verify-closeout 17/17 GREEN (pending)" | On main: 14/17 PASS · 2 FAIL | ⚠ pending is accurate; main RED is expected pre-merge |
| "Active PRs: S154 pending · S153 pending" | Confirmed pending | ✓ accurate |
| "KNOWLEDGE.md 475+ lines" | `wc -l`: 1364 lines | ✗ stale — 889 lines off |
| "Dogfood-age tool blind spot — reads S124 (this repo)" | `--dogfood-age`: S124 confirmed | ✓ accurately described |

**Stale finding:** STATE.md says "475+ lines" for KNOWLEDGE.md; actual is 1364. The STATE.md description is a quoted header from the KNOWLEDGE.md file itself, which hasn't been updated since S105.

**Verdict: 🟡** One stale size claim; all structural claims accurate.

---

## Audit 4 — knowledge_staleness 🔴

**Question:** Is KNOWLEDGE.md accurate? Anything permanent that is missing or wrong?

- KNOWLEDGE.md §1–§5 (core sections): accurate.
- §6 decision log (append-only): **1364 total lines**, but the KNOWLEDGE.md header still reads "475 lines / ~91K tokens as of S105." The file has grown by 889 lines (3× larger) since that note was written. The header is stale by 11 GT cycles.
- At 1364 lines, §6 is no longer an on-demand lookup — it's a significant context burden if loaded in full.
- "Prune to permanent lessons is queued (chronic since S60)" — this has been deferred 95+ sessions.

**Verdict: 🔴** The KNOWLEDGE.md header is wrong by 3×. The §6 bloat is now measurable and the defer-chain spans more than a year of sessions. A prune pass is overdue.

---

## Audit 5 — constraint_violation_review 🟢

**Question:** Any session in the last 5 that violated a CONSTRAINTS.yaml rule?

Reviewing S151, S152, S153, S154 (S150 was the last GT):

| Session | Type | Violations |
|---|---|---|
| S151 | CODE | None found. cargo fmt + verify guard. 4/4 ACCEPT. |
| S152 | DOCUMENT | None found. Obedience + carry-forward rules added. 4/5 ACCEPT. |
| S153 | DOCUMENT+CODE | None found. 4 carry-forward items closed. 4/5 SHIPPED cold + AC5 at close. |
| S154 | CODE | One waiver: required-crew (tech-lead provenance false-negative — see Special Input 2). No autonomous commits, no main commits. 6/6 ACCEPT. |

The S154 required-crew waiver was explicitly flagged by STATE.md and named in the S155 prompt. No hidden violations.

**Verdict: 🟢** No unreported constraint violations.

---

## Audit 6 — constitution_review 🟢

**Question:** Does AGENTS.md still reflect how the project is actually run? Any rule blocking the vision?

- S152/S153 added three new protocol sections: Obedience Protocol · Carry-Forward Rule · Handoff-Condensation Transparency · Hollow-Advice Retirement Standard · DOCUMENT-Session Verify Script Standard. All reflect real enforcement gaps that were found in practice.
- The EXECUTE step (step 4) was updated at S154 to require `## Execution` traces with real shas in CODE sessions — reflecting the S154 build.
- **Potential blocker check:** The "One vajra-session per chat" hard rule is noted as "convention until Vajra enforces it" — it has never been violated, but this is soft enforcement.
- No rule was observed blocking the vision. The constitution is accurate.

**Meta-check on constitution:** The constitution defines 13 hard rules. The most-exercised path (GT sessions, DOCUMENT sessions, the NO-CODE exceptions) has no equivalent hard rule for "GT sessions must address carry-forward backlog items." S153 addressed 4 S149 items; S155 is being asked to pick up 2 carry-forwards from S154's review. This is informal — it works but the GT's role as the backlog pickup is not codified.

**Verdict: 🟢** AGENTS.md is accurate and current. No rule blocks the vision.

---

## Audit 7 — cost_review 🟡

**Question:** What is the real cost per session? Is it trending the right direction?

| Session | Type | Cost |
|---|---|---|
| S144 | Paid dogfood (chitra) | **$11.742472** (AUTHORITATIVE) |
| S145–S154 | Sessions (no paid run) | ~$0 each (subagent tokens unmetered) |

- The only authoritative data point since S105 GT is S144 ($11.74). Prove-then-cut-cost is the ONLY path to changing this number.
- **Adoption blocker assessment:** $11.74 for a single real governed session is expensive. A solo dev doing 2 sessions/day would spend ~$23/day. There's no public baseline to compare, but the founder named it a blocker in S140.
- Subagent token costs (e.g., S134: $1.61 + 421K unmetered subagent tokens) remain partially invisible to the receipt.
- The `prove-then-cut-cost` arc has been deferred for 11 sessions since S145. No action has been taken.

**Verdict: 🟡** Cost is high and the prove-then-cut-cost arc is chronically deferred. Must be scheduled.

---

## Audit 8 — dogfood_check 🟡

**Question:** How old is the last paid dogfood run? Is the age acceptable?

Live from `vajra next --dogfood-age`:
```
last dogfood session : 124
date (git-derived)   : 2026-08-20
cost (authoritative) : $3.2985
sessions since       : 30 (S124 → current S154)
calendar days since  : 19 day(s)
```

**Known blind spot:** The tool reads only this repo's receipts. The real last dogfood was **S144 in chitra** ($11.74, headless, 129 turns). The tool reports S124 — 19 days and 30 sessions ago — because cross-repo dogfoods leave no receipt in this repo.

Corrected picture: last paid dogfood was S144 (11 sessions, ~4 sessions ago in calendar terms). The founder explicitly deferred more dogfood after S144, waiting for the prove-then-cut-cost arc. The S144 dogfood was the last "prove it works expensively" run.

**STATE.md note on blind spot:** "Dogfood-age tool blind spot — reads S124 (this repo); real last was S144. LOW priority." The tool output and the actual state are misaligned by design. This should be disclosed in the GT output.

**Verdict: 🟡** Dogfood is 11 real sessions stale (using the corrected S144 baseline). The gap is within the founder's conscious decision, not an oversight. Acceptable for now but must not extend past another GT.

---

## Audit 9 — pipeline_advance_check 🟡

**Question:** Is the pipeline advancing, or is machinery growing while payload stalls?

| Session | Type | Stations (derived) | Notable |
|---|---|---|---|
| S148 | CODE | 4/8 | Architect✓ QA✓ Releaser✓ Reviewer✓ |
| S151 | CODE | 4/8 | Analyst✓ QA✓ Releaser✓ Reviewer✓ |
| S152 | DOCUMENT | 2/8 | Analyst✓ QA✓ (structural floor for DOC) |
| S153 | DOCUMENT | 2/8 | Analyst✓ QA✓ (structural floor for DOC) |
| S154 | CODE | 5/8 | Analyst✓ Planner✓ **Coder✓** QA✓ Demo-er✓ |

Shape analysis:
- **CODER station passed for the first time at S154.** This is real progress — the CODER gate was the perpetual absent station in CODE sessions before S154.
- **DOCUMENT sessions structurally max at 2/8** (no Plan, no Demo-er, no Coder, Releaser/Reviewer absent until merged). The counter reads low for DOCUMENT work by design, not by defect.
- **Demo-er is absent** in CODE sessions except S154 — S151 scores 4/8 with no Demo-er. This is the "Demo-er absent in CODE sessions" 🟡 disclosed in STATE.md.
- **Releaser and Reviewer** are absent in S152-S154 because those PRs are unmerged on main.

The pipeline is advancing (CODER now passes; S154 = 5/8, highest score for a non-shipping session). The shape is correct for the session types.

**Verdict: 🟡** Advancing, but DOCUMENT sessions create a persistent 2/8 floor, and Demo-er is still missing from most CODE sessions. Not alarming — known gaps.

---

## Audit 10 — dogfood_staleness 🟡

**Question:** Does `--dogfood-age` agree with STATE.md? Is staleness acceptable?

- `--dogfood-age` reports S124 / 2026-08-20 / 30 sessions / 19 days.
- STATE.md reports the same blind spot explicitly: "reads S124 (this repo); real last was S144."
- They agree on the blind spot. They disagree on the real answer (S124 vs S144).
- The tool's git-derived output is correct for the vajra repo. The STATE.md's note is also correct.
- Staleness (using corrected S144 baseline): 11 sessions, approximately 5 calendar days since S144 was on 2026-09-03 (estimated from session sequence, not git-verified for chitra).

**Verdict: 🟡** Tool and STATE.md agree on the blind spot. Real staleness is acceptable (11 sessions since S144 chitra dogfood, within the founder's decision).

---

## Audit 11 — stranger_check 🟢

Live output: **21/21 PASS**

```
=== stranger-check summary ===
  checks passed   21
  checks failed    0
  every check above executes the real binary in a real empty directory.
  GREEN — a stranger's first ten minutes work.
```

All criteria pass: `--version`, `--help`, front door fails closed on unknown subcommands (exit 2), `verify-closeout.sh` doesn't crash on bash 3.2, `vajra check` is honest on arrival, governance derivation arithmetic closes.

No new first-contact defects found. No stranger-visible changes since S150.

**Verdict: 🟢**

---

## Audit 12 — scaffold_drift_check 🟢

Live output: **17/17 PASS**

```
=== scaffold-drift: 17 passed, 0 failed ===
GREEN — a stranger is governed by 13/13 rules, 10/12 audits, 7/7 axes; every difference declared with a reason.
```

Carry-forward noted (from S129 cold review, still open): `src/cli/init.rs` hand-types `communication.forbid`, `load_order`, `demo.required_elements` against live twins in `.ai/CONSTRAINTS.yaml`; those lists are NOT part of the derived inventory. The GREEN is scoped to the three declared lists.

**Verdict: 🟢** Within declared scope. The out-of-scope hand-typed twins remain a latent drift risk.

---

## Special S155 Inputs

### 1. CODER station now passes (S154) — is it systematic or a one-off?

`vajra next --stations 154` confirms: `[PASSED] Coder DID — all plan steps record an existing commit`.

**Assessment:** This is real but fragile.
- S154 is the **first** CODE session to pass the CODER gate. The gate was added at S68, and 14+ CODE sessions failed it (no `## Execution` or placeholder shas).
- The S154 fix: (a) widened the placeholder grep to catch the actual template placeholder, (b) added the AGENTS.md obligation in step 4.
- **Systemic question:** Will the next CODE session pass? The obligation is now in AGENTS.md. The gate now correctly detects the template placeholder. But the gate is form-checking (`## Execution` section exists, no `<...>` placeholders) — it does not verify sha existence end-to-end from the verify-closeout script.
- **Verdict on systematicity:** Better than before but not yet proven across two consecutive CODE sessions. The first real test is the next CODE session. Call it 🟡 — gate fixed, not yet habit.

### 2. Tech-lead provenance false-negative (S154 waiver) — systemic or one-off?

From the required-crew log:
```
provenance: "subagent transcript recorded gitBranch 'session-135-tech-lead',
             not a session-154-* branch — this dispatch belongs to a different session"
```

**Root cause:** The provenance verifier trusts the `gitBranch` field embedded in the subagent transcript. When the tech-lead subagent was dispatched for S154, it recorded the git branch that was active in its execution context (`session-135-tech-lead`). This could happen if:
- The tech-lead was launched before the session branch was created, or
- The subagent's git context reflected a parent session's checkout state.

**Systemic or one-off?** **Systemic.** Any session where the tech-lead subagent is dispatched before the session branch is checked out will record the wrong branch. The verifier's `session-NN-*` branch pattern match will fail. This is not a S154-specific bug — it's a structural assumption that the subagent always runs with the session branch active.

**Should it be fixed?** Yes. The fix should verify dispatch provenance by tool-use ID (which is session-agnostic and cryptographically assigned) rather than branch name (which is context-dependent). A small CODE session fix. **Candidate for A or B next session.**

### 3. S152 carry-forward rules — have they reduced hollow advice?

Reviewing S152, S153, S154 reviews for compliance with the new rules:

| Session | Recs | Named carry-forward | Backlog with reason | Unnamed/hollow |
|---|---|---|---|---|
| S152 | 2 | 1 (→ S153) | 1 (backlog) | 0 |
| S153 | 2 | 1 (→ S155 GT) | 1 (backlog) | 0 |
| S154 | 2 | 1 (→ S155 GT) | 1 (backlog) | 0 |

**Result:** 100% compliance in the 3 sessions since S152. Zero unnamed carry-forwards.

**Caveat:** n=3 is too small for a statistical verdict on the Hollow rate. The advice-influence re-audit (S156–S157) is the right instrument. The early signal is positive but not conclusive.

### 4. C5 (verify-153) — Brief: check is circular

Confirmed by the S153 fidelity reviewer (fakest green section):
> "C5 greps for 'Brief:' within 5 lines of the DOCUMENT-Session section header. That string lives in the AGENTS.md note itself. The check passes because the description mentions 'Brief:', not because any actual verify script has ever run a Brief: awk check against a real DOCUMENT-session handoff."

**Status:** OPEN, unfixed. Carried to S155 GT (per S153 review rec 2). The fix requires a real DOCUMENT session with a real role handoff to target — the next DOCUMENT session should include this check. **Assign to the next DOCUMENT session.**

### 5. KNOWLEDGE.md size — is it now a real problem?

- Actual line count: **1364 lines**
- Header claim: "475 lines / ~91K tokens as of S105"
- Net growth: **889 lines** since S105 (19 GTs ago)
- §6 (decision log, append-only) is the source of all growth

**Is it a real problem?** Yes, now:
- The header is wrong by 3× and was last updated at S105 — the stale claim itself causes confusion.
- At 1364 lines, §6 is approaching the size of a full context load on its own.
- The AGENTS.md load order marks §6 "NOT reloaded in full every session (on demand)" — but the entire file is still loaded by any agent that reads it. On-demand is a convention, not enforcement.
- The prune has been deferred since S60 (95+ sessions). Each GT adds this note without scheduling the fix.

**Verdict:** A KNOWLEDGE.md prune is now a real session's worth of work. It should be scheduled — not just noted — in the next A/B/C options.

### 6. Cost — prove-then-cut-cost urgency

- Last authoritative cost: $11.74 (S144 chitra dogfood)
- Deferred: 11 sessions since S145
- No cost analysis has been run
- The prove-then-cut-cost arc was flagged as the "highest-priority for S155+ range" in STATE.md

**Urgency assessment:** High. The $11.74 baseline is not getting better by deferral. Each additional CODE/DOCUMENT session adds subagent token costs (S147 had 731K unmetered subagent tokens) that are invisible to the receipt. The adoption blocker is real and unaddressed. **This must be A or B next session.**

---

## Meta-check: what does this audit miss by design?

1. **The verify-closeout on main is RED (2 FAIL)** — this GT runs from main, not from a session branch. The 2 FAILs are expected (S153/S154 PRs not merged), but the state "closeout NOT done" is real. The GT doesn't include "are all pending PRs merged before the next session?" as a required check.

2. **Pending PRs as session hygiene** — S153 and S154 PRs are both pending. The closeout rule says verify-closeout must pass on the session branch pre-merge, and it did. But with both unmerged, `verify-closeout.sh` on main is RED, and the next session starts from a technically-failed baseline. The GT should explicitly flag unmerged PRs.

3. **The dogfood-age tool reports the wrong answer** — every GT reads S124 (19 days / 30 sessions) instead of S144 (the real last dogfood). The tool blind spot is documented but not fixed. The GT doesn't question whether the tool's output is the right input for the dogfood verdict.

4. **Advice-influence rate** — the GT measures whether carry-forward rules are *followed* (structural compliance), but not whether advice *influenced the work* (the S149 finding). The systemic Hollow rate from S149 (53% for fidelity-reviewer carry-forwards) was the original motivation for S152. Three sessions is too few to re-measure it.

---

## Summary verdicts

| Audit | Verdict |
|---|---|
| vision_alignment | 🟢 Accurate and on-track |
| roadmap_alignment | 🟡 Prove-then-cut-cost 11 sessions overdue |
| state_drift | 🟡 KNOWLEDGE.md size stale in STATE.md header |
| knowledge_staleness | 🔴 1364 lines; header says 475 (S105). 889-line stale claim. |
| constraint_violation_review | 🟢 No violations (S151–S154) |
| constitution_review | 🟢 AGENTS.md accurate and current |
| cost_review | 🟡 $11.74/session; prove-then-cut-cost not started |
| dogfood_check | 🟡 11 sessions since S144 (within founder decision) |
| pipeline_advance_check | 🟡 CODER passes at S154 (first time); Demo-er absent most CODE sessions |
| dogfood_staleness | 🟡 Tool reads S124; STATE.md documents blind spot |
| stranger_check | 🟢 21/21 PASS |
| scaffold_drift_check | 🟢 17/17 PASS |
| cargo_fmt | 🟢 PASS |
| lib_tests | 🟢 486/486 PASS |

**Overall: 🟡 PARTIAL PASS**

---

## 3 Next-Session Candidates

### A — Fix tech-lead provenance false-negative (CODE, ~2h)

**Goal:** Change the provenance verifier so it validates dispatch by tool-use ID (session-agnostic, cryptographically assigned) rather than by `gitBranch` (context-dependent at dispatch time).  
**Why pick this:** The required-crew gate is broken for any session where the tech-lead subagent is dispatched before the session branch is checked out. This is systemic, not a S154 one-off. Every future session can reproduce it. The gate's core purpose (proving the tech-lead ran for THIS session) is undermined.  
**Key risk:** The tool-use ID may not be surfaced in a way the verifier can reliably read from the handoff format. A fallback (session-number-from-handoff-filename) may be needed.

### B — Start prove-then-cut-cost arc (CODE/INVESTIGATE, ~2h)

**Goal:** Run a cost breakdown of `vajra claude` on a real chitra session — instrument which subagent calls, which station dispatches, and which hook overhead is the biggest cost driver. Produce a ranked list of cuts with a cost model.  
**Why pick this:** $11.74/session has been the adoption blocker since S145 and has been deferred 11 consecutive sessions. The founder flagged this as priority (3) at S140 and it is now the longest-standing unscheduled item. No other improvement matters more for external adoption.  
**Key risk:** The cost breakdown may reveal that subagent calls (unmetered today) are the dominant cost — which would require the S78 receipt arc to be revisited to meter subagents.

### C — Administrative close: merge pending PRs + KNOWLEDGE.md prune (DOCUMENT+admin, ~1h)

**Goal:** Merge S153 and S154 PRs (getting verify-closeout on main to GREEN), then prune KNOWLEDGE.md §6 from 1364 lines to ~300 (keep permanent lessons, retire dated decision log entries).  
**Why pick this:** Verify-closeout on main is RED (2 FAILs) because two PRs are pending. Starting the next session from a RED baseline is sloppy. KNOWLEDGE.md at 1364 lines is now a measurable problem. Both are administrative but both have compounding effects.  
**Key risk:** The §6 prune requires careful judgment about what is "permanent" vs. "historical decision log." The risk of losing a useful entry is low but non-zero.

---

**Founder pick: C — Administrative close (merge S153 + S154 PRs + KNOWLEDGE.md prune). 2026-09-08.**
