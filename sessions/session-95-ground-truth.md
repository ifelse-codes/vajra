# Session 95 — Ground Truth Audit

**Date:** 2026-07-22
**Type:** NO-CODE mandatory GT (`95 % 5 == 0`; last GT = S90)
**Scope:** S91–S94
**Branch:** `session-95-closeout` (exempt suffix)

---

## Headline Verdicts

| Audit | Verdict | Short finding |
|---|---|---|
| `vision_alignment` | 🟡 PASS | North-star correct; but pipeline unchanged since S72; cross-agent breadth still 0 code |
| `roadmap_alignment` | 🟡 FINDING | Backlog's top "High" item ("Dogfood refresh 🔴 overdue since S76") is **stale** — S92 refreshed it |
| `state_drift` | 🟢 PASS | STATE.md current; S94-PR-"TBD" is the accepted snapshot-before-merge artifact (S30), not drift |
| `knowledge_staleness` | 🟡 FINDING | §6 changelog **still growing unbounded** — 416 lines / 69 entries / ~85K tokens; header claim false |
| `constraint_violation_review` | 🟢 PASS | No hard-rule violations S91–S94; branches conform; no direct-main commits |
| `constitution_review` | 🟢 PASS | AGENTS.md serves the vision; the easy-green gradient is the one standing perverse incentive |
| `cost_review` | 🟢 PASS | Tracked honestly; S92 $0.2713 authoritative; cumulative ~$74.3 + S76 unknown |
| `dogfood_check` | 🟢 FRESH | S92 (2026-07-21, $0.2713) ran real work; but only the LAUNCH loop — pipeline never dogfooded end-to-end |
| `dogfood_staleness` | 🟢 OK | `--dogfood-age`: S92 / 2026-07-21 / $0.2713; agrees with STATE.md; 1 day / 2–3 sessions stale |
| `pipeline_advance_check` | 🟡 FINDING | **Coder ABSENT in ALL of S91–S94** — incl. 2 code-shipping sessions; the EXECUTE station is dark 4-for-4 |

**Lead lens A (machinery vs. payload): the enforcement arc is now genuinely complete; the pipeline itself has NOT advanced since S72 — the next session must break the pattern (4th consecutive GT).**

---

## 1. `vision_alignment`

**Verdict: 🟡 PASS**

- *North-star still right?* **Yes.** Provable agent governance, shaped as a governed multi-agent SDLC pipeline (`DECISION-001`). Nothing since S90 undermines it. S92's paid dogfood re-confirmed governance is real and *was* voluntary — closing that (S93) strengthened the thesis.
- *Shortest path, or scope creep?* **Defensible but narrowing.** S93/S94 were a legitimate *response* to a real dogfood finding (obedience was VOLUNTARY = the moat literally leaked; the nested blindspot could cross-authorize a commit). Not invented work. **But** they are guardrail hardening, not pipeline payload — the 8-station spine is unchanged since S72 (23 sessions).
- *Evidence that would force a pivot?* An end-to-end pipeline dogfood showing the stations don't change real behavior; or a user who needs the 2nd agent. **We have neither — because neither has been attempted.**

**Watch:** cross-agent breadth = 0 code, the founding differentiator, aging since S25. Founder-gated (S26/S70), not an emergency, but the enforcement arc being *done* removes the depth-work excuse for deferring it.

---

## 2. `roadmap_alignment`

**Verdict: 🟡 FINDING**

- Each phase still maps to the north-star (governance → pipeline → measure → breadth).
- **Stale backlog item (finding):** ROADMAP "Backlog → High" leads with *"🔴 Dogfood refresh — overdue since S76 (2026-07-18)."* **S92 refreshed the dogfood** (2026-07-21, $0.2713) — the item is stale and mis-flagged 🔴. It should be retired or rewritten to the honest gap (below).
- **The honest next-highest-leverage item is NOT in the backlog as such:** an *end-to-end* pipeline dogfood (all 8 stations, not the launcher only) — S92 exercised **2/8**. The backlog conflates "run `vajra claude`" (done S92) with "exercise the pipeline" (never done).
- No item is obsolete. The 2nd-agent item remains founder-gated, correctly.

---

## 3. `state_drift`

**Verdict: 🟢 PASS**

STATE.md claims cross-checked against the live repo today:

| Claim | Live check | Result |
|---|---|---|
| `cargo test --lib` = 286 | ran: **286 passed; 0 failed** | ✓ |
| Dogfood 🟢 S92 = 2026-07-21, $0.2713 | `--dogfood-age`: S92 / 2026-07-21 / $0.2713 | ✓ (S90's date fix held) |
| Pipeline = 8 stations | `--stations` confirms 8-station shape | ✓ |
| Active branch = None (between sessions) | git: main clean before this GT | ✓ |
| `git status` clean of `src/` | `git status --short src/` = empty | ✓ |

- **S94 PR = "TBD":** STATE.md lists the S94 PR as "TBD"; it was in fact merged (#94). This is the **accepted snapshot-before-merge artifact** — S30 formally retired this as *not drift* (the STATE snapshot is honestly taken at closeout, before the post-closeout merge). Recorded, not flagged.
- No stale date or count found. The S90 `state_drift` 🔴 (S76 date error) stays fixed.

---

## 4. `knowledge_staleness`

**Verdict: 🟡 FINDING (chronic — flagged S60, unremediated)**

- **§6 changelog bloat is still growing unbounded.** `KNOWLEDGE.md` = **416 lines, 69 dated `- 2026…` session entries, ~85K tokens** (a Read of it caps out at 25K tokens showing only ~lines 1–103). Rule 5 says per-session detail belongs in `sessions/`, not here — §6 violates its own rule 69× and grows every closeout.
- **The header is now false:** `KNOWLEDGE.md` opens *"Permanent facts only … Reloaded every session."* At ~85K tokens it is neither permanent-facts-only nor safely reloadable — the boot hook loads files 2–6 (SESSION…CONSTRAINTS), **not** KNOWLEDGE (load-order #7, "on demand"). If anything ever honored "reloaded every session," it would blow the `<5% footprint` design rule single-handedly.
- Permanent facts through S94 are otherwise accurate; no individual fact found wrong.
- **Recommendation:** prune §6 to genuinely-permanent lessons (ADR outcomes, house patterns, gotchas); move per-session narrative to `sessions/`; correct the header. This is cheap, bounded, and clears a 7-GT-old finding.

---

## 5. `constraint_violation_review`

**Verdict: 🟢 PASS**

| Session | Branch | Merged via | No main commit | Verify |
|---|---|---|---|---|
| S91 | `session-91-fix-attestation-and-dogfood-staleness` + `session-91-update-s92-prompt` | PR #90, #91 | ✓ | 283 tests |
| S92 | `session-92-dogfood-paid-pipeline` | PR #92 | ✓ | dogfood |
| S93 | `session-93-prove-commit-gate-teeth` | PR #93 | ✓ | 27/27 |
| S94 | `session-94-nested-repo-guard` | PR #94 | ✓ | 23/23 |

- All branches match `^session-\d{2,}-[a-z0-9-]+$`. All work reached main via PR merge — no direct-main commits (git `--first-parent` shows only merge commits across S90–S94).
- S91 ran **two** bounded branches/PRs (attestation fix + S92-prompt update) — within the 1-story discipline (each a separate small story).
- Approval recorded; ≤3 files/commit honored (S94 = 3 feature + 3 closeout commits per its summary). 2-assumption / 2-retry caps honored.
- **No rule now blocks the vision.** "No autonomous commits" continues to serve the product (S92 proved the agent *voluntarily* obeyed it, which is exactly why S93 made it enforced).

---

## 6. `constitution_review`

**Verdict: 🟢 PASS (with one standing perverse-incentive flag)**

- AGENTS.md's 10-step loop, the DECISION-002 fidelity/discipline split, and "new session = new chat" (step 10) all intact and honored S91–S94.
- **Perverse incentive (the recurring one):** the *"verify exits 0 = done"* gate is fully satisfiable by mechanism/guardrail hardening (easy to script green) and only weakly by pipeline payload / dogfood (hard, costs $, partly unscriptable). Nothing in the constitution structurally rewards *advancing the pipeline* over *adding another gate*. This is the **easy-green gradient**, now flagged by **4 consecutive GTs (S80, S85, S90, S95)**. It is not a violation — every session was clean — it is a gravity well.

**Meta-check (mandatory) — see the dedicated section below.**

---

## 7. `cost_review`

**Verdict: 🟢 PASS**

| Session | Spend | Basis |
|---|---|---|
| S91 | ~$0 | Rust + docs; no paid `vajra claude` run |
| S92 | **$0.2713** | Paid dogfood, authoritative `total_cost_usd` (sonnet-4-6) |
| S93 | ~$0 | Rust/shell; no paid run |
| S94 | ~$0 | Shell + verify/demo; no paid run |

- Cumulative: **~$74.3 + S76 unknown (≤ ~$26.6 opus-estimate).** Consistent with S90's ~$73.7 + S92's $0.2713.
- S76 "unknown" remains honestly recorded (fable-5 unpriced at run time). No session had cost silently dropped.
- $5/session warn-mode budget cap has still never fired (per-session, checked post-exit, warn-not-kill) — standing question, not a violation.

---

## 8. `dogfood_check`

**Verdict: 🟢 FRESH — with a load-bearing caveat**

- **Yes**, real work ran through `vajra claude` since S90: **S92** (2026-07-21, $0.2713 authoritative). Within 1 day / ~3 sessions. Fresh by any staleness bar.
- **Caveat (the honest reading):** S92's `--stations` shape is **2/8** (Analyst + Planner only). S92 dogfooded the **launch loop** — spawn, meter, receipt, and the (then-voluntary) commit refusal — **not** the 8-station pipeline. **The pipeline stations (Coder/QA/Demo-er/Releaser driving a real task) have never been dogfooded end-to-end.**
- So: the *launcher* is dogfood-fresh; the *pipeline* is dogfood-**never**. "Is Vajra-on-Claude satisfying?" is answerable for the launch loop (S92: yes, governance held), **unmeasured** for the pipeline.

---

## 9. `dogfood_staleness`

**Verdict: 🟢 OK (1 day / 2–3 sessions)**

Live `vajra next --dogfood-age`:
```
last dogfood session : 92
date (git-derived)   : 2026-07-21
cost (authoritative) : $0.2713
receipt file         : receipt.stderr.txt
sessions since       : 2 (S92 → current S94)
calendar days since  : 1 day(s)
```

- **Agrees with STATE.md** (S92, 2026-07-21, $0.2713) ✓. No date drift — the S90 correction holds.
- **One nuance:** the tool reports *"current S94"* because `.ai/SESSION` = 94 (not advanced to 95 until this closeout). Real sessions-since at S95 = **3** (S92→S95). Expected artifact — `SESSION` advances at closeout, and the tool correctly reads the live file, not STATE.md.
- Staleness **acceptable** given direction. (See `dogfood_check` for the pipeline-vs-launcher distinction the staleness metric cannot see.)

---

## 10. `pipeline_advance_check`

**Verdict: 🟡 FINDING — the Coder station is dark 4-for-4**

Live `vajra next --stations NN`:

```
S91 → 7/8   Analyst✓ Architect✓ Planner✓ Coder[ABSENT] QA✓ Demo✓ Releaser✓ Reviewer✓
S92 → 2/8   Analyst✓ Architect[absent:not-sig] Planner✓ Coder[ABSENT] QA[absent] Demo[absent] Releaser[absent] Reviewer[absent]
S93 → 7/8   Analyst✓ Architect✓ Planner✓ Coder[ABSENT] QA✓ Demo✓ Releaser✓ Reviewer✓
S94 → 6/8   Analyst✓ Architect[absent:not-sig] Planner✓ Coder[ABSENT] QA✓ Demo✓ Releaser✓ Reviewer✓
```

- **Systemic gap (the audit explicitly asks to name a chronically-absent station):** **Coder is ABSENT in all four sessions — including S93 and S94, which each shipped 3 real commits.** The Coder gate (`## Execution` → `step N — done: <sha>`, git-existence-gated) is built machinery that *even code-shipping sessions do not populate*. The pipeline's own EXECUTE station is dark.
- **Shape reading (per the S75/S85/S90 nuance):** No station added since S72 — 8 is the ceiling, the spine is complete. K-of-8 for a CODE session tops out at 6–7/8 (Architect-not-significant + Coder-absent). S92's 2/8 is expected for a launcher dogfood. **The number is not the story — the SHAPE is:** one station has never fired in the audited window.
- **This is the single sharpest piece of "machinery vs. payload" evidence in the whole GT:** a station was built (S68) and is not used by the sessions that would use it.

---

## Lead Lens A — Machinery vs. Payload

**Finding: the enforcement arc is now genuinely complete; the pipeline itself has not advanced since S72.**

Since S90, the four sessions were:

| Session | Type | What it moved | Pipeline payload? |
|---|---|---|---|
| S91 | CODE | Reviewer hash fix + `--dogfood-age` measurement | No — measurement |
| S92 | DOGFOOD | Proved commit-obedience was VOLUNTARY | No — evidence |
| S93 | CODE | Commit obedience voluntary → ENFORCED | No — guardrail |
| S94 | CODE | Nested-repo guard identity-aware | No — guardrail |

- **Net-new pipeline payload since S90: zero.** The Coder station is dark 4-for-4; no station gained capability.
- **The honest counter-weight:** S93/S94 were the *correct shortest-path response to a real dogfood finding* — S92 empirically showed the moat leaked (obedience was voluntary; a nested repo could cross-authorize a commit). Closing that was load-bearing, not a comfortable detour. Given S92's evidence, S93→S94 were the right sessions.
- **But the gradient is now 4 GTs deep** (S80/S85/S90/S95). And crucially: **the enforcement holes S92 exposed are now closed** (obedience enforced, identity-aware, fail-closed). The "we must harden the guardrails first" justification has **run out of runway** — the guardrails are hardened.
- **Verdict:** the next session must break the machinery pattern. The two pattern-breakers with the most evidence behind them:
  1. **End-to-end pipeline dogfood** — the Coder-dark + S92-was-2/8 findings both say the *pipeline* (not the launcher) has never been driven on a real task. This is the measurement that would actually tell us if the 8 stations are usable, and it produces the evidence the 2nd-agent decision needs.
  2. **The cross-agent 2nd agent** — 0 code, the founding differentiator; with the enforcement arc done, depth-work no longer justifies deferring breadth.

---

## Meta-Check (Mandatory)

**Did this audit's own mechanism miss a kind of drift?**

**1. The payload counter is consulted but structurally can't catch machinery-vs-payload on its own.** The S74 `--stations NN` counter *is* now a mandatory GT input (the S25/S60/S70 meta-gap is closed on the "is it consulted?" axis — good). **But** it measures per-session station-PASS evidence, capped at 8, against a spine that's been complete since S72. It **cannot distinguish** "the pipeline gained a real new capability" from "another enforcement hook shipped" — both leave K-of-8 unchanged. The drift the counter was built to catch still requires the human lead-lens read. **The counter's one machinery-vs-payload-visible signal is the SHAPE, not the number** — "Coder ABSENT 4×" is exactly the tripwire, but only if the GT reads per-station chronic absence, not just K. **Recommendation: make "any station ABSENT for N consecutive sessions" an explicit GT flag,** not something the auditor has to notice by eye.

**2. `--dogfood-age` measures launch-loop freshness, not pipeline-exercise freshness.** It counts any `total_cost_usd > 0` receipt as a dogfood. S92 (2/8, launcher-only) makes the metric read 🟢 while the *pipeline* has never been dogfooded end-to-end. The staleness metric structurally cannot see the launcher-vs-pipeline distinction that `dogfood_check` had to make by hand. **Not a false green exactly — an incomplete sensor.** Naming it so a future GT doesn't read "dogfood 🟢" as "pipeline proven."

Both are the S25 pattern one turn deeper: a green metric that measures a real thing while the north-star question sits just outside its field of view.

---

## Overall Synthesis

**🟢 Clean:** All four sessions honored the process — branches conform, no main commits, costs honest, tests green (286), STATE.md current, S90's date fix held. Governance is real and now *enforced* (S93) and *identity-aware* (S94).

**🟡 Watch (not emergencies):**
- **Easy-green gradient — 4th consecutive GT.** The enforcement arc is complete; the next session should be a pattern-breaker (pipeline dogfood or cross-agent), not a 5th guardrail.
- **Coder station dark 4-for-4** — the pipeline's EXECUTE station is unused even by code-shipping sessions.
- **KNOWLEDGE.md §6 bloat** — 416 lines / 69 entries / ~85K tokens; header false; flagged since S60, never remediated.
- **Pipeline never dogfooded end-to-end** — S92 was 2/8 (launcher only).

**🔧 Cheap hygiene surfaced:**
- Retire/rewrite the stale ROADMAP "Dogfood refresh 🔴 overdue since S76" backlog item (S92 refreshed it).
- Prune KNOWLEDGE §6 + fix its header.

---

## Carry-Forward to S96+ (candidates)

Drawn from ROADMAP backlog + this GT's findings. Ranked to break the machinery pattern.

**A 🥇 — End-to-end pipeline dogfood (paid)**
Goal: drive a real task through all 8 stations via `vajra claude`, populating the Coder `## Execution` shas — measure whether the *pipeline* (not just the launcher) is usable.
Why pick: Coder dark 4-for-4; S92 exercised only 2/8; the pipeline has never run end-to-end on real work; live evidence beats mechanism arguments; it produces the evidence the 2nd-agent decision needs; breaks the 4-GT machinery gradient.
Key risk: real $ (~$0.3–3); the S83 headless read-only wall; may reveal the Coder marker workflow is impractical — which is itself the finding.

**B 🥈 — Cross-agent 2nd agent (Codex/Cursor launcher)**
Goal: wire a second agent to prove ADR-0002's adapter contract is genuinely cross-agent (or expose hidden Claude-coupling).
Why pick: 0 code, the founding differentiator, the S25 north-star gap; the enforcement arc is done, so depth-work no longer justifies deferring breadth.
Key risk: founder-gated (S26/S70 — returns when the Claude experience is deemed satisfying); large, design-bearing; a real fork the founder must open.

**C 🥉 — KNOWLEDGE.md §6 prune + header fix (docs)**
Goal: cut the 69-entry unbounded changelog to permanent lessons, move per-session narrative to `sessions/`, fix the false "Reloaded every session" header.
Why pick: chronic finding since S60; ~85K tokens is actively harmful if ever loaded; cheap, bounded, clears the finding.
Key risk: docs-only content fidelity (S89 class — verify can't fully check); losing a genuinely-permanent fact during the prune. **Note:** this is itself easy-green — picking it over A/B would be the 5th consecutive machinery session.
