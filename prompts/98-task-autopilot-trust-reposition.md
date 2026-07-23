# Session 98 — Direction lock: AUTOPILOT TRUST (reposition + the 6-month ladder roadmap)

> **Status:** DRAFT
> *(Founder: after reading, rewrite the line above so it ends in the approval word — the Analyst
> gate blocks `--advance` into 98 until then. Kept off that line deliberately: `parse_approval`
> in `src/analyst/mod.rs:342-348` matches the approval word BEFORE the draft word on the same
> line — a live-found false-positive bug, reported at authoring time, 2026-07-22.)*
> **Provenance:** 2026-07-22 — independent external CTO audit (`~/vajra-cto-audit-2026-07-22.md`,
> verdict **PAUSE TO PROVE**) + an 11-question founder interview the same day. This prompt encodes
> the founder's own answers into the governed system; it is not the auditor's plan imposed.
> **Sequencing:** S97 (e2e pipeline dogfood = Ladder Rung 1) runs FIRST. If S97's findings
> contradict anything below (especially Rung 2's design), amend this prompt BEFORE approving —
> that is the human ✋ Analyst gate doing its job. S97's closeout step 8 points here instead of
> writing a fresh prompt.

## The founder's answers this prompt encodes (recorded so nothing lives only in a chat)

| Question | Founder's answer |
|---|---|
| What is Vajra to you? | **A company** — exit by **acquisition**; the ideas must win visibly |
| Crown jewel? | **"The loop — the trust one can put on agents on autopilot, bet on it while away for days"** |
| Why zero users in 96 sessions? | All four: never-felt-ready + building-is-comfort-zone + dogfood-first rationale + no network |
| The machinery gradient (4 GTs)? | "It was genuinely necessary — credibility." (Honored: the machinery is what makes multi-day autonomy *demonstrable*; usage now catches up to it) |
| The 8-station pipeline? | **"The pipeline IS the vision"** — non-negotiable; make it work, don't shrink it |
| Cross-agent? | Claude-first for dogfood ease; release when confident; other agents in parallel later |
| Release bar? | "When I feel confident across multiple repos, no drift" — a FEELINGS bar (the admitted moving-bar disease) → translated below into falsifiable rungs + a DATE backstop |
| Commitment? | Serious part-time (~15–30 h/wk), **6-month proof deadline** (≈ Jan 2027) |
| Working in public? | Yes to all: deep-dives, Show HN, video demos, 1:1 outreach — **AI-generated content pipeline** preferred |
| Spend? | **$1k+/month if signal is good** |
| Kill signal? | "The trust loop doesn't hold" (technical). Note: did NOT pick "I never shipped" — historically the likelier failure → the date backstop below exists precisely for this |

## Goal

Encode the repositioning into the governed system — docs only, no `src/`:

**Vajra stops being pitched as "a governed 8-station SDLC pipeline" (mechanism-first) and becomes
"the AUTOPILOT TRUST LAYER — leave your agent working for days, come back, and trust the result"
(outcome-first).** The 8 stations stop being the pitch and become the *engine* of the pitch. The
canonical demo, for HN and for an acquirer alike: *"I left Claude alone on a real repo for 3 days.
Here's every action it tried, what got blocked, the fidelity verdicts, the receipt. I merged
without reading every line."*

This is the same class of move as S53 (DECISION-001 reframed compression→governance): a direction
lock recorded as a decision record + VISION lead + ROADMAP rewrite, so the next 6 months of
sessions inherit it from `.ai/`, not from a chat transcript.

## The plan being installed (the content the deliverables must carry)

### 1 · The Autopilot Ladder (replaces the feelings-based release bar)

| Rung | Autonomy | Pass condition (falsifiable — ALL required) |
|---|---|---|
| 1 (= S97) | ~1 task, hours, 1 repo (chitra) | Full station shape recorded; Coder-dark diagnosed |
| 2 | **1 day unattended**, multi-task, chitra | Zero governance leaks · honest receipts · fidelity verdicts correct on founder spot-check |
| 3 | **2–3 days unattended, ≥2 repos** | All of Rung 2 **+ the merge test: founder merges the work WITHOUT line-by-line review** |

- **Guards ON for every ladder run** (`publish_guard`/`commit_guard` armed) — autopilot-trust
  demos require the real teeth; this also retires the audit's "teeth off in own house" finding.
- **The machinery-freeze rule (goes into ROADMAP rules):** *a session either runs the ladder, or
  fixes something a ladder run broke. Nothing else gets built.* The machinery backlog becomes
  "whatever the runs break" — including Coder-marker toil, where the expected fix is *agents write
  the markers, Vajra verifies* (the pipeline becomes invisible to agents, readable to the human).
  This kills the 4-GT easy-green gradient by construction.

### 2 · Release backstop (kills the moving bar)

**v0.1 ships when Rung 3 passes once OR on 2026-09-15 — whichever comes FIRST.** Release =
installable by a stranger (final crate name — current one is taken, rename is in scope of that
release task — tagged binaries, README truth-pass, 10-minute quickstart). Release ≠ launch; no
feelings required. README truth-pass (stale ~8× receipt claim, unverifiable install paths) is
scheduled INSIDE this backstop task — NOT in S98.

### 3 · Evidence-content machine (weeks ~6–12)

Every ladder run auto-drafts content from its own artifacts — the ledger, blocked actions, and
receipts ARE the material. Weekly AI-drafted / founder-edited posts; then 2–3 real launches
(Show HN, r/ClaudeAI, X). Publishing becomes an *output of the loop*, routing around the
comfort-zone blocker.

### 4 · Signal → scale (months 3–6)

Ten named 1:1s (agent-tool builders, agency founders) with the Rung-3 demo. On signal: spend to
$1k/mo, more repos, and cross-agent begins with the cheap middle move — a **neutral evidence
format** (align ledger/receipts with the open `agent-trace` spec) before any second runtime.
Cross-agent is the acquisition-legibility card: a category, not a Claude plugin.

### 5 · Scoreboard + TWO kill signals

- **Wk 8:** Rung 3 passed once · v0.1 installable by a stranger.
- **Month 4:** 3 launches done · weekly evidence posts running · 10 named 1:1s attempted.
- **Month 6:** ≥1 of — 100+ stars / 5 external repos running it / 1 acquirer-adjacent conversation.
- **Kill A (founder's):** the trust loop keeps failing at Rung 2–3 (drift, leaks, gamed gates) →
  thesis broken; stop or rebuild.
- **Kill B (auditor's, added):** the loop HOLDS but the market stays silent after 3 real launches →
  pivot the fidelity auditor into a standalone agent-PR acceptance checker.

## Deliverables

1. **`docs/decisions/DECISION-005-autopilot-trust.md`** — the direction lock: context (audit
   verdict + interview provenance, the founder-answer table above), the reframe (pipeline =
   engine, not pitch), the Ladder, the machinery-freeze rule, the release backstop, both kill
   signals, and revisit conditions. Same honesty register as DECISION-001/002.
2. **`VISION.md`** — new lead: the one-sentence becomes autopilot-trust ("leave your agent working
   for days…"); the pipeline section reframed as the engine that earns the trust; ALL existing
   honesty disclosures preserved (cross-agent still 0 code · compression never-claim · "better
   work" hypothesis) — no claim beyond evidence.
3. **`.ai/ROADMAP.md`** — "Where We Are" updated + a new **6-Month Autopilot Plan** section
   carrying: the Ladder table, the 2026-09-15 release backstop, the content-machine cadence, the
   signal→scale phase, the scoreboard, both kill signals; the machinery-freeze rule added to
   "Rules For This Document"; Backlog re-ranked — every machinery item demoted to "only if a
   ladder run breaks it".
4. Closeout per house rules: pointers synced, `## Execution` shas filled, independent cold review
   (ACCEPT + attestation + ledger).

## Acceptance Criteria

1. `DECISION-005-autopilot-trust.md` exists; records the reframe, the provenance (audit +
   interview, with the founder-answer table), the Ladder, the machinery-freeze rule, the
   2026-09-15 backstop, and Kill A + Kill B. `covers: 1`
2. `VISION.md` leads with autopilot trust; the stations are framed as the engine; every existing
   honesty row survives verbatim-or-stronger (grep-checkable: "0 cross-agent code", compression
   never-claim, better-work hypothesis). `covers: 2`
3. `.ai/ROADMAP.md` contains the Ladder table with the falsifiable pass conditions (zero-leak +
   spot-check + merge test) and the dated release backstop. `covers: 3`
4. `.ai/ROADMAP.md` contains the scoreboard (wk-8 / month-4 / month-6) and BOTH kill signals,
   including Kill B's named pivot (fidelity-auditor standalone). `covers: 3`
5. The machinery-freeze rule appears in ROADMAP's rules section. `covers: 3`
6. Docs-only: `git diff` touches no `src/` file; independent cold review ACCEPT, attested
   (`--inputs-sha 98`), ledger extended. `covers: 4`

## Design

design-significant: **no** — docs/direction session, no `src/` change. This refines the shape of
`docs/decisions/DECISION-001-governance-as-product.md` exactly the way its own S53 refinement
section did (reposition recorded as a decision, not code). Cite DECISION-001 and DECISION-002.

## Plan

1. Write `DECISION-005-autopilot-trust.md` (context → decision → ladder → freeze rule → backstop
   → kill signals → revisit conditions). `covers: 1`
2. Rewrite `VISION.md` lead + pipeline framing to autopilot-trust; preserve every honesty
   disclosure. `covers: 2`
3. Rewrite `.ai/ROADMAP.md`: 6-Month Autopilot Plan section (ladder + backstop + content machine
   + scale phase + scoreboard + kill signals), rules addition, backlog re-rank. `covers: 3, 4, 5`
4. Independent cold review (prompt + diff only) → ACCEPT + `Review-Inputs-SHA` → fill
   `## Execution` shas → closeout sync. `covers: 6`

## Execution

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>

## Guardrails

- Max 2 assumptions · max 2 retries · max 1 story · ~2h cap.
- **Docs-only** — no `src/`, no README (README truth-pass belongs to the release-backstop task the
  new ROADMAP schedules; touching it here would be scope creep).
- CODE-session rules apply (it ships tracked docs): fidelity review + attestation + execution shas
  required, no waiver. `VAJRA_ALLOW_COMMIT=98` per commit.
- Branch: `session-98-autopilot-trust-reposition`. **New chat.**
- Do not soften the honesty rows while rewriting VISION — the reposition changes the LEAD, never
  the disclosures. If a claim reads stronger than the evidence table in the CTO audit, cut it.
- S100 is the next mandatory NO-CODE GT: its lead lens should be "is the ladder being climbed, or
  did machinery resume?" — note this in ROADMAP.

## Delta (Analyst gate)

- `+` `docs/decisions/DECISION-005-autopilot-trust.md` — the direction lock
- `~` `VISION.md` — autopilot-trust lead; pipeline reframed as engine; disclosures preserved
- `~` `.ai/ROADMAP.md` — 6-Month Autopilot Plan + rules + backlog re-rank
- `~` `.ai/STATE.md`, `SESSION-BOOT.md`, `TASK.md`, `SESSION` — closeout sync only
