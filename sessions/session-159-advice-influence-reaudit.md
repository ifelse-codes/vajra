# Session 159 — Advice-influence re-audit

**Date:** 2026-09-09  
**Methodology:** Same as S149 — grade each advice item Changed/Noted/Hollow with corroborating evidence. S152 introduced a new compliant carry-forward category; this audit tracks it separately to measure the rule's impact.  
**Scope:** Design-advisor and fidelity-reviewer only. Sessions S153–S158. S149 baseline: 59% Changed · 1 Noted · 36% Hollow (22 items).

---

## Session coverage

| Session | Type | Design-advisor dispatched? | Fidelity-reviewer dispatched? |
|---------|------|---------------------------|-------------------------------|
| S153 | DOCUMENT+CODE | No | Yes — formal handoff (`.ai/handoffs/session-153-fidelity-reviewer.md`) |
| S154 | CODE | No | Yes — review only (`sessions/session-154-review.md`; no `.ai/handoffs/` entry) |
| S155 | NO-CODE GT | N/A | N/A (Ground Truth — no code/design deliverable) |
| S156 | DOCUMENT+admin | No (crew skip, by design) | Yes — review only (`sessions/session-156-review.md`; no `.ai/handoffs/` entry) |
| S157 | CODE | No | Yes — formal handoff (`.ai/handoffs/session-157-fidelity-reviewer.md`) |
| S158 | CODE | Yes — formal handoff (`.ai/handoffs/session-158-design-advisor.md`) | Yes — formal handoff (`.ai/handoffs/session-158-fidelity-reviewer.md`) |

**Absence of design-advisor from S153–S157:** tech-lead did not mark design-advisor required in those sessions. Design-advisor is mandatory-dispatch only when tech-lead flags it. S158 is the only session in this window where the design-advisor ran.

---

## Item-by-item grading

### S153 — Fidelity-reviewer (2 items)

**rec 1 — Run `verify-closeout.sh` on the session-157 branch before merging; record exit code.**  
Grade: **Changed**  
Evidence: `sessions/session-153-summary.md` Obeyed Dispositions: `obeyed: implemented — 16/16 GREEN confirmed pre-merge (S83 rule)`. Corroborated by S153 review: "verify-closeout.sh 16/16 GREEN confirmed on branch before merge."

**rec 2 — For the next DOCUMENT session, add an actual awk/grep check against a real handoff file (not the AGENTS.md note itself) so the Brief: standard is enforced rather than just described.**  
Grade: **Carry-forward (compliant)**  
Evidence: `sessions/session-153-summary.md` Obeyed Dispositions: `carry-forward → S155 GT checklist (backlog — needs a DOCUMENT session with a real role handoff to target; S153 itself has no such handoff file).` Names S155 as the target; includes a reason. Compliant with S152 naming rule. Not yet acted on after S155 (S155 was NO-CODE; no code fix was possible); rec remains open.

---

### S154 — Design-advisor: not dispatched (0 items)

### S154 — Fidelity-reviewer (2 items)

**Source:** `sessions/session-154-review.md` (no formal `.ai/handoffs/` entry; review performed but not captured as a governed handoff).

**rec 1 — Add a comment to `check_execution_shas` explicitly stating it only detects placeholder patterns, not sha existence, and that sha existence is enforced by `vajra next --exec`.**  
Grade: **Carry-forward (compliant)**  
Evidence: `sessions/session-154-review.md`: `carry-forward → backlog (no urgency; correctness unaffected)`. Names backlog with reason. Compliant per S152 (backlog carry-forwards must appear on the next GT checklist = S160). No evidence of action in S155–S158.  
Structural note: the S154 session summary has no "Obeyed Dispositions" section — rec disposition appears only in the reviewer's own document, not in the builder's record.

**rec 2 — Document the self-bind bootstrap problem in AGENTS.md or step prose: the step filling `## Execution` cannot reference its own sha, so the last step should reference the prior commit.**  
Grade: **Carry-forward (compliant)**  
Evidence: `sessions/session-154-review.md`: `carry-forward → S155 GT (low priority, documentation only)`. Names S155 as target. Compliant per S152. S155 was NO-CODE — the GT did not add this AGENTS.md note; rec remains open.  
Structural note: same tracking gap as rec 1 — disposition in reviewer's file only, not in builder's summary.

---

### S155 — NO-CODE Ground Truth (0 items)

No design-advisor or fidelity-reviewer applicable. Ground Truth sessions produce no code/design deliverable; the review mechanism does not apply.

---

### S156 — Design-advisor: not dispatched, crew skip (0 items)

`sessions/session-156-summary.md`: "Crew skip markers added to `prompts/156-task-admin-close.md` (DOCUMENT session, no dispatch needed)." Crew skip by builder decision — tech-lead was not required for an administrative DOCUMENT session.

### S156 — Fidelity-reviewer (2 items)

**Source:** `sessions/session-156-review.md` (no formal `.ai/handoffs/` entry).

**rec 1 — Replace the SESSION-number proxy for AC1 with a git ancestry check (`git merge-base --is-ancestor <pr-sha> main`) or document that AC1 evidence lives in STATE.md + git log, not the verify script.**  
Grade: **Hollow**  
Evidence: No disposition in `sessions/session-156-summary.md`. No carry-forward label anywhere in the session record. No corroborating evidence that this was acted on in S157 or S158. The rec is untracked.

**rec 2 — Add an AC5 falsifiability check to future prune sessions: record headline phrases from the original that must survive, grep them in the pruned file.**  
Grade: **Hollow**  
Evidence: Same — no disposition in S156 summary, no carry-forward label, no downstream action.  
Structural note: Both S156 recs are Hollow because the session has no formal handoff file and no "Obeyed Dispositions" section in the summary. The tracking loop broke entirely when the review was filed only in `sessions/` with no corresponding `.ai/handoffs/` entry and no summary tracking.

---

### S157 — Design-advisor: not dispatched (0 items)

### S157 — Fidelity-reviewer (2 items)

**Source:** `.ai/handoffs/session-157-fidelity-reviewer.md` (formal handoff).

**rec 1 — At closeout, run `scripts/verify-closeout.sh` on the session-157 branch before merging, and record its exit code.**  
Grade: **Noted**  
Evidence: This is the standing S83 convention. S157 closed without waiver (summary: "VAJRA_CLOSEOUT_WAIVER not needed for this session — the fix works for S157 itself"), which implies verify-closeout ran and passed. However, the S157 summary has no "Obeyed Dispositions" section and no explicit `obeyed: implemented` record. Behavioral evidence (clean closeout) confirms the action; no explicit disposition trace was written.

**rec 2 — The `new-match-arm-present` grep should be removed from future verify scripts in favour of relying solely on `cargo test`; a structural-position grep for a match arm is not falsifiable in the way the test suite is.**  
Grade: **Hollow**  
Evidence: The S157 summary's A/B/C options listed C as "remove grep-based verify checks (CODE hygiene)" — meaning the rec was visible to the builder. Founder chose A (S158 demo enforcement) instead of C. No carry-forward label was recorded for rec 2; no named session assigned. The rec was bypassed without disposition.

---

### S158 — Design-advisor (5 items)

**Source:** `.ai/handoffs/session-158-design-advisor.md` (formal handoff). All dispositions tracked in `prompts/158-task-demo-enforcement.md` `## Advice` table.

**rec 1 — Record `design-significant: yes` in `## Design` section of the session prompt.**  
Grade: **Changed**  
Evidence: `prompts/158-task-demo-enforcement.md` `## Advice`: `obeyed — see above`. `## Design` section shows `design-significant: yes`. Corroborated by `sessions/session-158-review.md` which confirms the design-significant marker is present.

**rec 2 — Flip `is_code_session()` from negative-exclusion to affirmative-inclusion: match `\*\*CODE\*\*` in the Type section.**  
Grade: **Changed**  
Evidence: `prompts/158-task-demo-enforcement.md` `## Advice`: `obeyed — implemented in this session (affirmative-matching fix applied after original commit f28bee9)`. `sessions/session-158-review.md`: "Post-commit: affirmative-matching fix applied to `is_code_session()` per design-advisor rec 2." `## Design` section of the prompt documents the affirmative-inclusion pattern adopted.

**rec 3 — Confirm `--demo-only` still calls `is_code_session()` before running marker checks rather than bypassing type detection.**  
Grade: **Noted**  
Evidence: `prompts/158-task-demo-enforcement.md` `## Advice`: `confirmed — --demo-only → check_demo_markers → is_code_session() at top`. This was a verification request, not an actionable change; the rec was satisfied by inspection and documented as confirmed.

**rec 4 — Write a new DECISION record for session-type detection contract and demo marker enforcement pattern, citing DECISION-002 as motivation.**  
Grade: **Hollow**  
Evidence: `prompts/158-task-demo-enforcement.md` `## Advice`: `deferred — to a DOCUMENT session; scope exceeds S158 budget`. No session number named. Under S152 rule, an acceptable deferred disposition requires either a named session number (`deferred → S159`) or `backlog` with a reason and GT-checklist appearance requirement. "To a DOCUMENT session" satisfies neither. No ROADMAP entry. No carry-forward in STATE.md.

**rec 5 — Add a `timeout 60` guard to the `bash "$D" 2>&1` call in `check_demo_markers` to prevent a slow demo script from blocking closeout indefinitely.**  
Grade: **Carry-forward (compliant)**  
Evidence: `prompts/158-task-demo-enforcement.md` `## Advice`: `deferred — lower priority; the live run already exits fast; add in S159 or later if a slow demo surfaces`. S159 is named as a target session. Compliant with S152 naming rule.

---

### S158 — Fidelity-reviewer (2 items)

**Source:** `.ai/handoffs/session-158-fidelity-reviewer.md` (formal handoff). Dispositions tracked in `prompts/158-task-demo-enforcement.md` `## Advice` table.

**rec 1 — Improve `demo-session-158.sh` cases to exercise the blocking path (a synthetic CODE session with no demo script or missing markers) so the demo proves what it claims rather than only showing exemptions.**  
Grade: **Hollow**  
Evidence: `prompts/158-task-demo-enforcement.md` `## Advice`: `deferred — the exemption path is the correct live behavior for the only session scripts available; a synthetic blocking case requires a fixture session`. No session number named; no backlog label. STATE.md records `🟡 Demo cases don't exercise the blocking path` — but STATE.md acknowledgment is not the same as a named carry-forward. Under S152 rule: non-compliant disposition.

**rec 2 — Replace the `grep -A5 "is_code_session" | grep -q "demo"` source-proximity heuristic in `verify-session-158.sh` with a behavioral integration test.**  
Grade: **Hollow**  
Evidence: `prompts/158-task-demo-enforcement.md` `## Advice`: `deferred — source-grep documents intent; the --demo-only 158 call at the end of verify-session-158.sh is the behavioral check`. No session number named; no backlog label. Under S152 rule: non-compliant disposition.

---

## Summary table

### Per-session breakdown

| Session | Role | Items | Changed | Noted | Carry-forward (compliant) | Hollow |
|---------|------|-------|---------|-------|--------------------------|--------|
| S153 | Fidelity-reviewer | 2 | 1 | 0 | 1 | 0 |
| S154 | Fidelity-reviewer | 2 | 0 | 0 | 2 | 0 |
| S155 | — | 0 | — | — | — | — |
| S156 | Fidelity-reviewer | 2 | 0 | 0 | 0 | 2 |
| S157 | Fidelity-reviewer | 2 | 0 | 1 | 0 | 1 |
| S158 | Design-advisor | 5 | 2 | 1 | 1 | 1 |
| S158 | Fidelity-reviewer | 2 | 0 | 0 | 0 | 2 |
| **Total** | | **15** | **3** | **2** | **4** | **6** |
| **Rate** | | **100%** | **20%** | **13%** | **27%** | **40%** |

### Comparison to S149 baseline

The S149 audit used a 3-category system: Changed / Noted / Hollow. It did not have a "carry-forward (compliant)" category because S152 didn't exist yet. To compare directly, this table folds carry-forwards into Hollow (the S149 treatment) and also shows the 4-category view.

**3-category (direct apples-to-apples with S149 — carry-forwards count as Hollow, matching S149 treatment):**

| Metric | S149 baseline | S159 |
|--------|---------------|------|
| Items graded | 22 | 15 |
| Changed | 59% (13) | 20% (3) |
| Noted | 5% (1) | 13% (2) |
| Hollow (incl. carry-forwards) | 36% (8) | 67% (10) |

**4-category (compliant carry-forwards counted separately — S152's new category):**

| Metric | S149 baseline | S159 |
|--------|---------------|------|
| Items graded | 22 | 15 |
| Changed | 59% (13) | 20% (3) |
| Noted | 5% (1) | 13% (2) |
| Carry-forward (compliant) | — | 27% (4) |
| Hollow (unnamed/untracked) | 36% (8) | 40% (6) |

**Caveat:** S149 graded implementation-advisor (85% Changed) alongside fidelity-reviewer (22% Changed), which pushed the overall Changed rate to 59%. This audit covers design-advisor and fidelity-reviewer only — the same scope as the S149 fidelity-reviewer sub-population (22% Changed then; 10% now).

---

## Key findings

### Finding 1: The carry-forward rule worked for its specific target — the pattern it killed is gone

S149's diagnosis: "every rec labelled 'carry-forward, non-blocking' graded Hollow." The 8 Hollow items in S149 were ALL of this form: carry-forward labels with no named destination.

In S159's 15 items, zero carry-forwards are unnamed. All 4 carry-forwards name either a specific session (S155, S159) or `backlog` with a reason. The anonymous dispose-and-forget pattern that S152 targeted is absent from this window.

**Verdict: The S152 rule eliminated its stated target class.**

### Finding 2: The overall Hollow rate did not improve — new Hollow patterns replaced the old one

Under the 3-category comparison (matching S149 methodology): S149 Hollow = 36%; S159 Hollow = 67%. Under the 4-category view (compliant carry-forwards counted separately): 40% Hollow vs 36%.

New Hollow patterns identified:

**Pattern A — Sessions without formal handoffs break the tracking loop entirely (S156).**  
S156's fidelity-reviewer ran but filed the review in `sessions/session-156-review.md` only (no `.ai/handoffs/` entry). The S156 summary has no "Obeyed Dispositions" section. Both recs are untracked and Hollow. The S153/S157/S158 pattern (handoff in `.ai/handoffs/` + disposition table in the session record) worked; S156 dropped it silently.

**Pattern B — Named deferred items without session numbers violate S152 but look compliant (S158).**  
S158's fidelity-reviewer recs 1 and 2 were formally `deferred` in the `## Advice` table — but without naming a session number. Under S152 this is non-compliant (the rule requires a session number or `backlog` with GT appearance). The S158 `## Advice` table demonstrates the S153 tracking habit is absorbed, but the NAMING sub-requirement is not fully followed.

**Pattern C — Design-advisor rec 4 (DECISION record) was deferred without a named target.**  
"To a DOCUMENT session" is not a carry-forward → SNN. No ROADMAP entry exists for this work.

### Finding 3: Fidelity-reviewer Changed rate dropped from 22% (S149) to 10% (S159)

Of 10 fidelity-reviewer items in this window, 1 was Changed (S153 rec 1 — run verify-closeout). The role's recs are typically process-process improvements that the builder either: (a) treats as standing convention (Noted), (b) formally defers without following through, or (c) leaves untracked.

The fidelity-reviewer's highest-leverage rec in this window — "remove grep-based checks from future verify scripts" (S157 rec 2) — was visible in the A/B/C options and was not chosen. It was also not carry-forwarded. It is Hollow.

### Finding 4: Design-advisor Changed rate is 40% in its first measured window

Of 5 design-advisor items, 2 were Changed (recs 1 and 2 from S158). This is higher than fidelity-reviewer's historical rate. The design-advisor runs only when tech-lead marks it required; in this 6-session window it ran once (S158). Not enough data for a confident pattern.

### Finding 5: The tracking mechanism works when formal handoffs are present

S153, S157, S158 all have formal `.ai/handoffs/` entries and the builder's session record includes disposition tracking. In all three, every rec is accounted for (Changed, Noted, or named carry-forward). S154 and S156 lack formal handoffs — and in both, the tracking is either in the reviewer's file only (S154) or missing entirely (S156).

---

## Conclusion

**Did the S152 carry-forward rule reduce the Hollow rate?**

Partially. The specific mechanism it targeted (unnamed carry-forward as a dispose-and-forget label) is gone. All carry-forwards in this window name a target. That is the rule working as designed.

However, the overall Hollow rate (40% in the 4-category view; 67% in the 3-category comparison) is not better than S149 (36%). New Hollow patterns emerged that the rule does not address: sessions without formal handoffs lose rec tracking entirely; "deferred" dispositions that skip naming a session violate S152 but are hard to detect at the time of writing.

**The S149 trigger condition:** "if Noted > 30% after a re-audit, build the mechanical check."  
Strict Noted count: 13%. Does not trigger on this metric alone.  
However, the combined unresolved rate (Hollow + non-Acting carry-forwards = 60% in 3-category) exceeds 30%.

**Recommended next step:** A mechanical enforcement gate is warranted — not because the Noted rate is high, but because the Hollow rate did not improve and new bypass patterns emerged. Two specific gaps for the gate to close:
1. `deferred` without a named session in the `## Advice` table should be flagged at closeout.
2. Sessions that dispatch fidelity-reviewer but produce no `.ai/handoffs/session-NNN-fidelity-reviewer.md` should WARN (or BLOCK) at closeout — the tracking loop breaks without the formal handoff.
