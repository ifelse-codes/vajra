# Session 85 — Ground Truth (mandatory NO-CODE, every 5th; last = S80)

**Date:** 2026-07-20
**Arc under review:** S81→S84 (execution-sha closeout guard · Releaser ledger fallback · read-only-headless UX warning · typed `CannotEvaluate`)
**Lead lens:** A — did four gate-hardening/UX sessions advance the pipeline, or repeat the S80-flagged easy-green detour?

---

## Pipeline Advance Check (the headline — measured, not guessed)

`vajra next --stations NN` run live (current binary, `cargo build --release`) for S80→S84:

| Session | K-of-8 | Absent stations |
|---------|--------|-----------------|
| S80 (GT, NO-CODE) | **2/8** | Architect · Coder · QA · Demo-er · Releaser · Reviewer |
| S81 (CODE — sha guard) | **7/8** | Architect only |
| S82 (CODE — Releaser durability) | **7/8** | Architect only |
| S83 (CODE — headless warning) | **7/8** | Architect only |
| S84 (CODE — typed CannotEvaluate) | **7/8** | Architect only |

**Shape observations (live evidence, not summary claims):**

1. **Dead flat 7/8 across all four sessions.** Unlike S80's reading of S76→S79 (5→6→7→5, some movement, one regression), S81→S84 shows **zero** variation — the exact same station passes, every time, for four consecutive sessions. Architect is the only absence, and correctly so (none of the four recorded `design-significant: yes`).

2. **Important nuance — the flatness is partly the S82 fix working, not pure stagnation.** This reading uses the CURRENT binary (post-S82). Before S82, the Releaser dimension read ABSENT for any session whose branch was pruned post-merge (the S75/S80 structural-decay finding) — which is every session here. Running today's counter retroactively over S81-S84 shows Releaser PASSED via the ledger fallback for all four, which is S82's own fix demonstrating durability live. So part of "nothing changed" is actually "the measuring instrument itself got more reliable" — a real, if narrow, improvement to the GT's own headline tool. This is a genuine nuance the raw number hides.

3. **No new governed station was added.** All four sessions retyped an error signal, hardened a closeout check, fixed a counter read, or added a pre-flight warning — none introduced a new `--check-*` gate, a new pipeline stage, or moved any station from ABSENT to a newly-reachable PASSED. The ceiling stays 7/8 (Architect only fires on design-significant sessions; none of S81-S84 qualified).

**pipeline_advance_check verdict: 🔴 CONFIRMED FLAT — no pipeline advance across 4 sessions, the sharpest reading of this pattern to date.**
Compared to S80's 🟡 (some real movement, one regression), S85 finds an unambiguous flat line. The counter reliability improvement (point 2) is real credit, but it is not what `pipeline_advance_check` measures — it measures station count, and station count did not move.

---

## The 9 Required Audits

### 1. vision_alignment 🟡

**North-star:** provable agent governance, shaped as a governed multi-agent SDLC pipeline (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
**Still right?** Yes — no evidence this session contradicts the north-star. Governance-instrument correctness (S81-S84) is a legitimate sub-goal of "provable," not a detour from it.
**Drift?** Moderate. Four straight sessions spent on gate-internals (closeout guard, counter read, UX warning, error typing) rather than pipeline depth or dogfood. Individually each is defensible; the *pattern* — the same shape S80 already flagged — is the second consecutive GT to find it. VISION.md's claims (discipline ✅ real, fidelity ✅ real, cross-agent 🔴 aspirational) are unchanged and still accurate.

---

### 2. roadmap_alignment 🟡

**ROADMAP.md** top-of-file running log (`Prior · Session NN` entries) is current through S84 and accurate. **But** the "Where We Are" quick-reference table (`.ai/ROADMAP.md:301-309`) is stale — it reads `Today | 2026-07-14`, `Last closed session | Session 60`, `Active session | ... S61 not yet started`, i.e. **24 sessions behind** the file's own banner. `## Rules For This Document` rule 1 says "Update at every closeout" — this section has not been, for at least 24 closeouts. This is a genuine internal inconsistency (the same file contradicts itself depending on which section you read), not previously named this precisely by any prior GT (S60/S65/S70/S75/S80 all discussed KNOWLEDGE.md §6 length, none flagged this specific ROADMAP.md self-contradiction).
**Drift?** This sharpens, rather than introduces, the standing "readable-roadmap one-pager" backlog item (since ~S69) — it is no longer just a bloat/readability complaint, it is a **structural staleness bug in the document itself**. Ranked into S86 candidates below (see C).

---

### 3. state_drift 🟢

**STATE.md** checked line by line against observed reality:

| Claim | Verified |
|-------|---------|
| `.ai/SESSION` = 84 | ✅ confirmed |
| `cargo test --lib` **267 passed** | ✅ live run: `267 passed; 0 failed` |
| S84 PR `#83` merged | ✅ `gh pr view 83` → `state: MERGED`, `mergedAt: 2026-07-20T16:25:41Z` |
| `main` synced with `origin/main` | ✅ `git rev-parse main` == `git rev-parse origin/main` == `62ea366` |
| Merged local branches pruned | ✅ `git branch --merged main` shows none beyond main/session-85 |
| Active Branch = "None — between sessions" | ✅ matches `closeout_active_branch_value` contract verbatim |
| Cost ledger: S77-S83 ~$0 each, S84 ~$0 | ✅ matches git log (bash-only commits, no paid-API evidence) |

No STATE.md drift found. Accurate, matches S80's clean reading pattern.

---

### 4. knowledge_staleness 🟡

- **KNOWLEDGE.md:** 375 lines (+7 since S80's 368, over 5 sessions ≈ 1.4 lines/session — slower growth than the S76→S80 window). §6 changelog spans lines 57-124 (68 lines) — flagged since S60, unresolved through S65/S70/S75/S80/S85, now **5 GTs standing**, chronic but not accelerating.
- **ROADMAP.md staleness (new, sharper finding):** see `roadmap_alignment` above — the "Where We Are" table is 24 sessions stale inside an otherwise-current document. This is the concrete evidence that finally justifies promoting the "readable-roadmap one-pager" item off pure backlog status.
- **S84 house pattern correctly recorded:** "split an `Option`-wrapped ambiguity into a distinct typed variant at every layer it's threaded through" — accurately captures the `CannotEvaluate` propagation from `gate_run` into `QaState`/`DemoState`.

---

### 5. constraint_violation_review 🟢

**No CONSTRAINTS.yaml violations found in S81-S84:**
- Branch patterns: `session-81-*` … `session-84-typed-cannot-evaluate` — all match `session-NN-<slug>` ✅
- File caps (≤3/commit): S81 (guard, ≤3) · S82 (3 src files) · S83 (1 file, `src/cli/launch.rs`) · S84 (3 files: `gate_run.rs`, `qa/mod.rs`, `demoer/mod.rs`) — all within cap ✅
- Max 1 story/session: each of S81-S84 was a single bounded fix, no combined stories (unlike S39's explicit A+B override) ✅
- Approval tokens: explicit founder approval recorded for each session ✅
- Closeout-verify-premerge lesson (S83 finding) applied at S84 — confirmed in STATE.md and this session's own read of the commit sequence (`d0cf43f`/`b01c34e`/`fc16aba` all land before the PR #83 merge commit `62ea366`) ✅

---

### 6. constitution_review 🟡

**AGENTS.md** load order, session loop, and hard rules were followed correctly across S81-S84 — no rule blocks the vision.

**Direct answer to the lead lens's own question — did `max 1 story per session` bias toward small, certain fixes over the larger standing debts?**
Yes, on the evidence. Across the 8 sessions since the last dogfood run (S77-S84), only S76 itself involved real product usage; S77-S79 were the S80-flagged receipt easy-green arc, and S81-S84 repeat the shape one axis over (gate correctness/UX instead of receipt accuracy). In that stretch, two debts stood untouched despite being older and, in the attestation case, more consequential: the S76 sha placeholders (standing since S81, now 8 sessions overdue) and the attestation substring-check (standing since S82, disclosed 3 consecutive sessions). The 1-story cap does not by itself force smallness — but combined with the "green-every-session incentive gradient" (S60 finding, now confirmed a 3rd/4th time), it correlates with picking the smallest clean win available each session rather than the oldest, riskiest debt. This is not a rule violation; it is the exact pattern the rule's combination with human/agent incentive was designed to be checked against by the GT.

**Meta-check on this audit's own mechanism:**
- `pipeline_advance_check`'s raw K-of-8 number cannot distinguish "the pipeline stalled" from "the counter got more accurate" (point 2 under the headline). Both produce a flat-or-improving reading. This GT's own mandatory instrument has no way to separate the two without a human reading the `--stations` output closely, as done here. Worth a future refinement: tag counter-only fixes distinctly from pipeline-depth fixes in the station report itself.
- `dogfood_check`'s question list still lacks a severity gradient (flagged at S80, unresolved) — see below, this GT had to construct the "is 17 days / 8 sessions still 🟡 or now 🔴" judgment call manually rather than reading it off a threshold.

---

### 7. cost_review 🟢

| Window | Spend | Source |
|--------|-------|--------|
| S81 (closeout guard) | ~$0 | bash-only, local subagent cold review |
| S82 (Releaser durability) | ~$0 | no paid API call |
| S83 (headless warning) | ~$0 | bash-only source fix |
| S84 (typed CannotEvaluate) | ~$0 | bash-only source fix, local subagent cold review |
| **Cumulative S00→S84** | **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate)** | STATE.md cost section |

Cost ledger is honest and matches git history — every S81-S84 commit is a bash/source-only change with no paid-API evidence in the trail. No fabricated figures.

---

### 8. dogfood_check 🔴

**Last paid `vajra claude` run:** S76, 2026-07-03.
**Today:** 2026-07-20.
**Age: 8 sessions (S77, S78, S79, S80, S81, S82, S83, S84) · 17 calendar days.**

This is more than double S80's reading (3 sessions / 2 days) at the prior GT, and the gap has now compounded across **two consecutive GTs without a fresh paid run**. Escalating to 🔴 (from S80's 🟡) for two concrete reasons, not just elapsed time:
1. **Every governance mechanism touched since S76 — the closeout sha guard (S81), the Releaser ledger fallback (S82), the headless warning (S83), the typed CannotEvaluate distinction (S84) — is verified only against synthetic temp repos and stub binaries, never a real agent in a real session.** S82 in particular changes what the Releaser station reports as SHIPPED; that is now load-bearing for governance claims with zero live-agent confirmation.
2. **The S70 founder decision ("dogfood: S76 baseline") is now old enough, and enough new gate logic has shipped since, that "Vajra-on-Claude is satisfying" is not a claim this GT can respond to at all** — not "unsatisfying," genuinely unmeasured, and the unmeasured window is now wider than at any point since S76 itself closed the S31/S36 dogfood gap.

**No satisfaction verdict rendered — stating the age precisely, per the prompt's mandate, not guessing.**

---

### 9. pipeline_advance_check 🔴 (see headline section above)

Summary of key shape findings:
- S80 (GT): 2/8, expected for NO-CODE
- S81→S84: **flat 7/8**, zero variation, Architect the only absence throughout
- No new pipeline station, no new classifier, no new `--check-*` gate across all four sessions
- Partial credit: S82's fix makes the Releaser dimension durable/accurate for the first time across this reading — a real improvement to the counter's trustworthiness, distinct from (and not the same as) pipeline depth

---

## Lens A Verdict — Did 4 hardening/UX sessions advance the pipeline, or repeat the S80-flagged easy-green detour?

**CONFIRMED — and now a 2-session recurring pattern, not a one-off.**

**The qualifier (each session was individually honest and real):** S81 closed a genuine `verify-closeout.sh` gap (the S79 sha-placeholder bypass). S82 fixed a genuinely broken counter dimension (Releaser structural decay, confirmed by 2 prior GTs). S83 fixed a UX gap that had burned a real dogfood run (S76). S84 closed a fakest-green finding carried since S73 across 7 sessions. None of these four was manufactured busywork — each traces to a real, previously-disclosed problem, and each shipped with a clean cold review and live E2E proof.

**The detour finding (the pattern, not any single session):** Exactly the S80 shape, one level over:
- 4 consecutive sessions · all ~$0 · all clean-green · all on ONE axis (gate/UX correctness) instead of pipeline depth or dogfood
- The K-of-8 shape is now **flatter** than S80's own finding (dead 7,7,7,7 vs S80's 5,6,7,5) — a sharper confirmation, not a softer one
- Two older, arguably higher-stakes debts (S76 sha fix, attestation substring hardening) were passed over in favor of four smaller, more self-contained wins in every one of the four sessions
- Dogfood decayed from 3 sessions/2 days (S80's reading) to 8 sessions/17 days (this GT) — the gap widened across the exact window this GT is reviewing
- **This is the second consecutive mandatory GT (S80, S85) to find the same "small hardening wins over standing debt" shape.** A pattern confirmed twice in a row is no longer a per-session judgment call — it is evidence the incentive gradient itself (not any single session's choice) needs to be named as the finding.

**Direct answer on "disclosed, not hidden":** No longer sufficient. The attestation substring-check has been disclosed at S82, carried through S83, re-disclosed at S84, and reconfirmed still-unfixed at S85 (`src/stations/mod.rs:279,362`, still `.contains("review-inputs-sha")`) — 3 full CODE sessions of standing plus this GT. It is load-bearing for 2 governed stations (Reviewer + Releaser) **today**, meaning a forged or stale attestation string could silently fake-pass either station right now. This is a live risk to the fidelity gate itself (`DECISION-002`/`DECISION-003`'s core promise), not a historical record-keeping gap. It should have outranked at least S84 (a diagnostic-clarity fix with no security or gaming implication). Re-ranked below accordingly.

---

## 3 Ranked S86 CODE Candidates

(GT re-ranks with fresh evidence — this reorders S84's carried list, not just repeats it)

### 🥇 A — Harden the attestation substring-check (re-ranked up from S84's 🥈 B)

**Goal:** `session_attested_accept`/`reviewer_status` (`src/stations/mod.rs:279,362`) currently do `.contains("review-inputs-sha")` — a bare substring match, not a recomputed hash. Replace with an actual recompute-and-compare against the attested `canonical_inputs_sha` (the mechanism `verify-closeout.sh --attest-only` already uses for the live closeout gate).

**Why pick this now:** It is the single item that has been disclosed-not-fixed the longest while remaining **actively load-bearing for 2 governed stations today** — not a retroactive cleanup, a live weakness in the fidelity/ledger promise that is Vajra's actual moat (`DECISION-002`/`003`/`004`). This GT's own lens-A interrogation concludes "disclosed ≠ sufficient" at 3+ sessions of standing; S86 should act on that conclusion directly rather than carry it a 4th time.

**Key risk:** The recompute needs the exact same inputs `verify-closeout.sh` hashes (prompt + diff) reproduced inside `src/stations/mod.rs` — a second implementation of the same hash logic risks drifting from the script's own, unless it's extracted into one shared source (bash → Rust, or vice versa) rather than duplicated by hand.

---

### 🥈 B — S76 retroactive execution-sha fix (re-ranked down from S84's 🥇 A)

**Goal:** `prompts/76-task-real-dogfood-run.md`'s `## Execution` section still has `<sha>` placeholder literals — the true positive S81's guard was built to catch, standing since S81, now **8 sessions overdue**.

**Why pick this:** Short, mechanical, high closeout-hygiene value — the exact class of gap S67/S68's "existence-gating recorded markers" house pattern exists to prevent, and it is the oldest standing item on the board.

**Why not 🥇:** Lower live risk than A — it's a retroactive/historical-record correctness gap, not a currently-exploitable weakness in an active gate. A's forgeable-string risk is ongoing; B's gap is contained to one already-closed session's paper trail.

**Key risk:** Low — purely mechanical (fill real shas from `git log`, matching S81's `check_execution_shas` guard requirements). Confirm the guard's own `VAJRA_CLOSEOUT_WAIVER` logic doesn't need touching.

---

### 🥉 C — Fix ROADMAP.md's stale "Where We Are" table (sharpened from S84's 🥉 C "readable one-pager")

**Goal:** Either (a) make the "Where We Are" quick-reference table (`.ai/ROADMAP.md:301-309`) update automatically/mechanically at every closeout so it can't silently fall 24 sessions behind again, or (b) fold it into the top-of-file running log so there is only one place that needs updating — closing the self-contradiction this GT found (banner says S84, table says S60/S61).

**Why pick this:** This GT found a concrete, checkable instance of the standing "readable-roadmap one-pager" pain — not just "the file is long," but "the file actively disagrees with itself," which directly violates `## Rules For This Document` rule 1 ("update at every closeout"). Founder-flagged notebook-bloat pain (S69+) now has sharp evidence, not just a vague discomfort.

**Why not 🥇/🥈:** Lower governance stakes than A or B — this is a documentation-hygiene gap, not a gate-correctness or fidelity-integrity gap. No station's PASS/ABSENT reading depends on this table.

**Key risk:** Scope creep — "readable roadmap" has been backlogged since ~S69 as a bigger reframing question (a derived one-pager, generated not hand-maintained, per `[[feedback-distill-no-drift]]`). S86 should scope this narrowly (fix or remove the stale table) rather than reopen the larger one-pager design question in a single session.

---

## Summary Table

| Audit | Verdict | Key finding |
|-------|---------|-------------|
| vision_alignment | 🟡 | North-star right; 4 sessions narrow (gate-internals) vs. pipeline/dogfood depth |
| roadmap_alignment | 🟡 | Top-of-file log current; "Where We Are" table 24 sessions stale — new, sharper finding |
| state_drift | 🟢 | STATE.md matches reality; no gap found |
| knowledge_staleness | 🟡 | §6 changelog chronic (5th GT flagging it); ROADMAP self-contradiction now concrete evidence |
| constraint_violation_review | 🟢 | No violations S81-S84; all branches/file-caps/story-limits held |
| constitution_review | 🟡 | No rule blocks vision; 1-story cap + green-incentive gradient biases toward small wins over standing debt (confirmed on direct question) |
| cost_review | 🟢 | Ledger honest; ~$73.7 + S76 unknown; S81-S84 all ~$0 |
| dogfood_check | 🔴 | 8 sessions / 17 calendar days since S76 — escalated from S80's 🟡; 4 new/changed gates live-unverified |
| pipeline_advance_check | 🔴 | Flat 7/8 across S81-S84, zero variation — sharper than S80's 5→6→7→5; counter-accuracy improved (S82) but station count did not |

**Meta-check:** The GT's own `pipeline_advance_check` instrument conflates "counter got more accurate" (S82's real Releaser-durability fix) with "pipeline stalled" (no new station) — both read as a flat/improving K-of-8. Separately, `dogfood_check`'s question list still lacks the severity gradient S80 already flagged as missing (unresolved 1 GT later) — this GT had to construct the 🟡→🔴 escalation judgment manually rather than reading it off a threshold.

**Lens A verdict: easy-green detour CONFIRMED, now a 2-consecutive-GT pattern** — each of S81-S84 was individually real and honest, but the four-session shape is flatter than S80's own finding of the same pattern in S76-S79, and the "disclosed, not hidden" cover for the attestation check has run out at 3 sessions of standing.

**3 ranked S86 CODE candidates:**
- 🥇 A — Harden the attestation substring-check: recompute-and-compare, not `.contains()` — live risk to 2 governed stations, re-ranked up from carried 🥈
- 🥈 B — S76 retroactive execution-sha fix — oldest standing item (8 sessions overdue), re-ranked down from carried 🥇 (lower live risk than A)
- 🥉 C — Fix ROADMAP.md's stale "Where We Are" table — new concrete evidence for the standing readable-roadmap pain, scoped narrowly
