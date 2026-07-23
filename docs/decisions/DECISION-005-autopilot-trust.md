# DECISION-005 — Reposition to the AUTOPILOT TRUST LAYER (the pipeline is the engine, not the pitch)

- **Date:** 2026-07-23 (Session 98)
- **Status:** ACCEPTED
- **Type:** direction / positioning decision (not an architecture ADR) — same class as DECISION-001
- **Relates to:** DECISION-001 (governance as the product) and DECISION-002 (fidelity over
  discipline). This **refines the LEAD**, it does not reverse either: governance is still the
  product and fidelity is still its heart — autopilot trust is the *outcome* those two now sell.
- **Provenance:** 2026-07-22 — an independent external CTO audit
  (`vajra-cto-audit-2026-07-22`, verdict **PAUSE TO PROVE**) + an 11-question founder interview the
  same day. This decision encodes the **founder's own answers** into the governed system; it is not
  the auditor's plan imposed. Sequenced after S97 (the e2e pipeline dogfood = Ladder Rung 1), whose
  findings **confirm** Rung 2's design rather than contradict it.

---

## Context — why reposition now

**What the audit said (PAUSE TO PROVE):** the machinery is credible and unusually disciplined, but
after 96 sessions there are **zero external users**, the release bar is a moving *feeling* ("when I
feel confident, no drift"), and two smaller truth-gaps exist — the enforcement teeth are **off in
Vajra's own repo** (`publish_guard`/`commit_guard: off`) and the README still carries a **stale ~8×
receipt claim** plus unverifiable install paths. Verdict: stop building machinery, start proving the
loop with usage.

**What the founder answered (recorded so nothing lives only in a chat):**

| Question | Founder's answer |
|---|---|
| What is Vajra to you? | **A company** — exit by **acquisition**; the ideas must win visibly |
| Crown jewel? | **"The loop — the trust one can put on agents on autopilot, bet on it while away for days"** |
| Why zero users in 96 sessions? | All four: never-felt-ready + building-is-comfort-zone + dogfood-first rationale + no network |
| The machinery gradient (4 GTs)? | "It was genuinely necessary — credibility." Honored: the machinery is what makes multi-day autonomy *demonstrable*; usage now catches up to it |
| The 8-station pipeline? | **"The pipeline IS the vision"** — non-negotiable; make it work, don't shrink it |
| Cross-agent? | Claude-first for dogfood ease; release when confident; other agents in parallel later |
| Release bar? | "When I feel confident across multiple repos, no drift" — a FEELINGS bar (the admitted moving-bar disease) → translated below into falsifiable rungs + a DATE backstop |
| Commitment? | Serious part-time (~15–30 h/wk), **6-month proof deadline** (≈ 2027-01) |
| Working in public? | Yes to all: deep-dives, Show HN, video demos, 1:1 outreach — **AI-generated content pipeline** preferred |
| Spend? | **$1k+/month if signal is good** |
| Kill signal? | "The trust loop doesn't hold" (technical). Did NOT pick "I never shipped" — historically the likelier failure → the date backstop exists precisely for this |

**The through-line:** the crown jewel the founder named is not "an 8-station pipeline." It is
**trust one can put on an agent left running on autopilot for days.** The pipeline is *how* that
trust is earned and made demonstrable — the engine — but it has been pitched as the product itself
(mechanism-first). Four consecutive ground-truths (S80/S85/S90/S95) flagged the same thing from the
inside: the machinery grew while the payload — real usage — stalled. The reframe aligns the pitch
with the crown jewel and forces usage to catch up.

---

## Decision

**Vajra stops being pitched as "a governed 8-station SDLC pipeline" (mechanism-first) and becomes
"the AUTOPILOT TRUST LAYER — leave your agent working for days, come back, and trust the result"
(outcome-first).**

The 8 stations stop being the pitch and become the **engine** of the pitch. The canonical demo, for
Hacker News and for an acquirer alike:

> *"I left Claude alone on a real repo for 3 days. Here's every action it tried, what got blocked,
> the fidelity verdicts, the receipt. I merged without reading every line."*

This is the same move-class as S53 (DECISION-001 reframed compression → governance): a direction
lock recorded as a decision record + `VISION.md` lead + `.ai/ROADMAP.md` rewrite, so the next six
months of sessions inherit it from `.ai/`, **not** from a chat transcript.

---

## The Autopilot Ladder (replaces the feelings-based release bar)

Each rung has a **falsifiable** pass condition — all sub-conditions required. This kills "when I
feel confident" by definition.

| Rung | Autonomy | Pass condition (ALL required) |
|---|---|---|
| **1** (= S97, DONE) | ~1 task, hours, 1 repo (chitra) | Full station shape recorded; Coder-dark diagnosed |
| **2** | **1 day unattended**, multi-task, chitra | Zero governance leaks · honest receipts · fidelity verdicts correct on founder spot-check |
| **3** | **2–3 days unattended, ≥2 repos** | All of Rung 2 **+ the merge test: founder merges the work WITHOUT line-by-line review** |

- **Guards ON for every ladder run** — `publish_guard`/`commit_guard` armed. Autopilot-trust demos
  require the real teeth; this also retires the audit's "teeth off in own house" finding.
- **Rung 1 finding (S97), carried into Rung 2's design:** the Coder station went dark not because
  work was absent but because (a) chitra's *older* scaffold has no `## Execution`/`## Delta`/`##
  Design`/`## Plan` marker slots, and (b) a headless `-p` run cannot utter chitra's conversational
  commit-approval token → zero commits → zero shas. The agent **refused to self-commit even under
  `--dangerously-skip-permissions`** against a teeth-less convention gate (3rd voluntary-obedience
  reconfirmation). The fix is not more machinery — it is **agents write the markers, Vajra verifies**
  (the pipeline becomes invisible to the agent, readable to the human) plus an **env-marker commit
  path** for unattended runs (Vajra's own `VAJRA_ALLOW_COMMIT` shape).

---

## The machinery-freeze rule

**A session either runs the ladder, or fixes something a ladder run broke. Nothing else gets
built.**

The machinery backlog becomes "whatever the runs break" — including the Coder-marker toil above.
This kills the 4-GT easy-green gradient **by construction**: you cannot detour into a satisfying
green code session that no ladder run demanded. The rule goes into `.ai/ROADMAP.md`'s rules section
and every existing machinery backlog item is demoted to "only if a ladder run breaks it."

---

## Release backstop (kills the moving bar)

**v0.1 ships when Rung 3 passes once OR on 2026-09-15 — whichever comes FIRST.** No feelings
required.

- **Release = installable by a stranger:** final crate name (the current one is taken — the rename
  is in scope of the release task), tagged binaries, a README **truth-pass**, a 10-minute
  quickstart. **Release ≠ launch.**
- The README truth-pass (retire the stale ~8× receipt claim, fix unverifiable install paths) is
  scheduled **inside** this backstop task — deliberately **NOT** in S98 (touching README here would
  be scope creep; S98 is direction docs only).

---

## Evidence-content machine (weeks ~6–12)

Every ladder run **auto-drafts content from its own artifacts** — the ledger, the blocked actions,
and the receipts ARE the material. Weekly AI-drafted / founder-edited posts, then 2–3 real launches
(Show HN, r/ClaudeAI, X). Publishing becomes an **output of the loop**, routing around the
comfort-zone blocker the founder named (building is easy; shipping/posting is not).

## Signal → scale (months 3–6)

Ten named 1:1s (agent-tool builders, agency founders) shown the Rung-3 demo. On signal: spend to
$1k/mo, more repos, and cross-agent begins with the **cheap middle move** — a **neutral evidence
format** (align the ledger/receipts with the open `agent-trace` spec) **before** any second runtime.
Cross-agent is the acquisition-legibility card: a category, not a Claude plugin. (Still **0 cross-agent
code today** — this is a sequenced plan, not a claim.)

---

## Scoreboard + TWO kill signals

**Scoreboard:**
- **Wk 8:** Rung 3 passed once · v0.1 installable by a stranger.
- **Month 4:** 3 launches done · weekly evidence posts running · 10 named 1:1s attempted.
- **Month 6:** ≥1 of — 100+ stars / 5 external repos running it / 1 acquirer-adjacent conversation.

**Kill A (founder's — technical):** the trust loop keeps failing at Rung 2–3 (drift, leaks, gamed
gates) → the thesis is broken; stop or rebuild.

**Kill B (auditor's — market, added):** the loop HOLDS but the market stays silent after 3 real
launches → **pivot** the fidelity auditor into a standalone agent-PR acceptance checker (the one
component with demand outside the full-pipeline bet).

Two kill signals because the two likely failure modes are different: the founder fears the loop
breaking; the history says the likelier failure is **never shipping**. The date backstop + Kill B
guard the second.

---

## What this does NOT claim (honesty preserved, per DECISION-001/002)

- **Cross-agent is still 0 code.** The neutral-format move is months out and sequenced, not shipped.
- **Compression is never claimed until measured** — 0 folds on a real run (S63/S76) stands.
- **"Better work" stays a hypothesis** (n=2 null, S51/S52), not the pitch.
- **The pipeline has run end-to-end exactly once** (S97, Rung 1, a disclosed partial). Autopilot
  trust is the *goal the Ladder climbs toward*, not a capability we assert today.
- Reposition changes the **lead**, never the disclosures. If a rewritten claim reads stronger than
  the evidence, it gets cut.

## Consequences

- `VISION.md` re-led with autopilot trust; the pipeline reframed as the engine; every honesty row
  preserved verbatim-or-stronger (this decision's companion).
- `.ai/ROADMAP.md` gains a **6-Month Autopilot Plan** (Ladder + 2026-09-15 backstop + content
  machine + signal→scale + scoreboard + both kills); the machinery-freeze rule added to its rules;
  the backlog re-ranked so every machinery item is "only if a ladder run breaks it."
- **S100 (next NO-CODE ground-truth)** gets a new lead lens: *is the ladder being climbed, or did
  machinery resume?*

## Revisit if

- The trust loop holds through Rung 3 **and** the market responds → double down; re-weight spend and
  cross-agent per the signal→scale phase.
- Rung 2–3 keep failing on the same class of leak → **Kill A**: the thesis is broken.
- The loop holds but 3 launches draw silence → **Kill B**: pivot to the standalone acceptance checker.
- 2026-09-15 arrives with Rung 3 unproven → ship v0.1 anyway (the backstop is the point) and treat
  the miss as data, not a reason to move the bar again.
