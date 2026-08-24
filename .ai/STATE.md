# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S131 complete, S132 not yet started).**

S131 was CODE (locked at the S130 closeout, founder pick: `fidelity-reviewer` first). **Goal
achieved.** A session can no longer close with zero `fidelity-reviewer` handoffs — the exact
falling-usage failure S130's ground truth measured (S126 5 handoffs → S127 3 → S128 1 → S129 **0**)
— and the handoff's `agent:` provenance field is no longer the hardcoded literal
`"claude-code-subagent"` a hand-typed file could copy for free.

**What shipped:** `src/dispatch/mod.rs` (the S111/S117/S123 evidentiary shape — two
independently-written Claude Code files agreeing on a tool-use id neither side controls — made a
pure, unit-tested `cross_check`, plus a third fact those addenda left open: the subagent
transcript's own recorded `gitBranch`, binding a dispatch to the SESSION being gated); `src/fidelity/mod.rs`
(the mandatory existence+provenance gate — absent/malformed/unverifiable are three distinct
BLOCKING outcomes, no legacy WARN escape unlike every other stage gate here); `--check-fidelity-handoff`
(own command, not folded into `--check-advice` — the two gates check genuinely different things);
wired into `--advance`, `VAJRA_SKIP_FIDELITY_GATE=1` the documented override.
`scripts/verify-session-131.sh` (10/10 GREEN, run live) + `scripts/demo-session-131.sh` (8/8 GREEN,
run live, all four required elements) drive the REAL release binary against throwaway repos, never
this one. `.ai/handoffs/session-131-fidelity-reviewer.md` is this session's OWN governed handoff,
written from a REAL live dispatch — the gate S131 hardens, satisfied by real evidence, not a
fixture.

**Independent cold review: ACCEPT, 7/8 SHIPPED** (`sessions/session-131-review.md`), attested
(`Review-Inputs-SHA` matches on two consecutive `--inputs-sha 131` runs, `review-inputs-attested`
PASS). Its rec 1 (name the forgery bar plainly) obeyed in-session; rec 2/3 obeyed via the summary's
disclosure + the live-run tallies; rec 4 (bind a dispatch's own content to the specific `--from`
findings file — a real, not-quick-fix hardening question) deferred to `.ai/ROADMAP.md` F2, not
folded into this session's locked one-story scope.

**The fakest green, named plainly (cold review's own call, and correct):** the whole provenance
chain rests on trusting UNSIGNED files (`agent-*.meta.json` + `.jsonl`) with no cryptographic or
process binding to a subagent that actually ran — this session's own fixtures (three `printf`
calls) prove exactly how cheap that is to forge. "Provable" means the bar over a hardcoded string
is real, not that the claim is tamper-proof; the DECISION-007 addendum now says so in those words.

**A live gotcha hit and recorded (`.ai/KNOWLEDGE.md`):** `verify-closeout.sh --inputs-sha N`'s
preimage hashes the LIVE PROMPT FILE directly, not only the diff — filling `## Execution`/
`## Advice`/`## Design` in the prompt AFTER a first hash computation silently invalidates it even
though `prompts/` is excluded from the diff half. Recomputed and re-embedded as the final edit,
per "attest LAST" (S69), applied more strictly than before.

**Prompt/Execution/Advice fully filled** (8 plan steps, all real landing shas; 4 fidelity-reviewer
recommendations, all answered — 3 obeyed, 1 deferred with a real ROADMAP entry, not a bare path).
**`prompts/132-task-verify-advice-obeyed.md` written** (S132, locked at the S130 closeout): closes
the S127 residual (a recorded `obeyed:` disposition is not the same as a TRUE one — the
`implementation-advisor` rec 9 specimen, `obeyed: 8cd3bea`, stub still present, caught only by a
cold reader). Two open design questions left explicit for S132, not pre-decided here. Planner +
Architect gates both report READY on it.

## Active PRs
- **S131 — PR not yet opened this session** (opens at closeout, after `.ai/` sync).
- S129 [#148](https://github.com/ifelse-codes/vajra/pull/148) MERGED · S128
  [#147](https://github.com/ifelse-codes/vajra/pull/147) MERGED · S127
  [#145](https://github.com/ifelse-codes/vajra/pull/145) MERGED · S126
  [#143](https://github.com/ifelse-codes/vajra/pull/143) MERGED · S125
  [#140](https://github.com/ifelse-codes/vajra/pull/140) MERGED.
- S130 was NO-CODE GT — no code PR; its closeout bundle merged directly as #149.

## Direction (governance is the product — shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Fleet = real named agents behind the existing gates
  (`DECISION-007`), and as of S131, **one of them (`fidelity-reviewer`) is now MANDATORY, not just
  registered.**
- **Current direction, locked by the founder at the S130 closeout: MAKE THE FLEET REAL, starting
  with the one role that guards fidelity itself.** S131 delivered the first real, blocking
  mechanism — the founder's own S130 gate ("nine roles is 'done'; 'and WORKING' is unproven") is
  now answered for ONE role, with real evidence, not assertion. Eight roles remain optional.
- **Post-pivot path:** S118 ✓ dogfood → S119 ✓ clean-room → S120 ✓ GT → S121 ✓ QA Specialist →
  S122 ✓ guardrails → S123 ✓ role fenced → S124 ✓ paid dogfood → S125 ✓ GT (PARTIAL) →
  S126 ✓ fleet complete → S127 ✓ Advice gate → S128 ✓ first contact → S129 ✓ one source →
  S130 ✓ GT (PARTIAL PASS), locked S131–S134 → **S131 ✓ fidelity-reviewer mandatory + provable →
  S132 = verify the advice was actually OBEYED, not just answered.**

## What Currently Works
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. `K of 8` unchanged in derivation and shape this
  session — re-checked live, `S131`'s new Fidelity gate is a FLEET gate, not a 9th station.
- **The fleet's first mandatory role (S131, NEW).** A session cannot close without a real
  `fidelity-reviewer` handoff whose provenance independently re-verifies. Fabricated/hand-typed
  handoffs are refused; a real dispatch from the WRONG session is refused too (`gitBranch` bind).
  Nine roles registered, ONE mandatory, eight still optional — falling-usage trend from S126-S129
  is not itself re-measured yet (that needs a future session's real dispatch counts, not this one's
  fixtures).
- **The enforcement floor is real, re-verified this session.** `scripts/verify-session-131.sh`
  (10/10) and `scripts/demo-session-131.sh` (8/8) both run live against throwaway repos; falsifiability
  fixture is red-on-bypass / green-on-rename, matching the S122/S127 contract for real (two unit
  tests had to be decoupled from exact message text to make this honest, S131's own in-session fix).
- **The Advice gate (S127)** — proves ANSWERED, never obeyed; S132 is the fix, now scoped and its
  prompt written.
- **First contact works (S128)**, **one source for a stranger's rulebook, 3 of ~7 lists (S129)** —
  unchanged this session, not re-verified live (no reason to expect regression; `stranger-check.sh`
  / `scaffold-drift.sh` untouched).
- **Ledger** (S100): unchanged this session, not re-verified live.
- **v0.1 install: four real channels**, stranger-shippable as measured at S110, unchanged.

## What Is Broken / Weak
- **🔴 The fleet is still a roster with ONE mandatory role, not nine.** S131 made ONE gate real;
  it did not fix the falling-usage trend for the other eight, and does not claim to.
- **🔴 Dispatch evidence is forgeable by anyone with shell access to this machine (S131's own
  fakest green, disclosed in the DECISION-007 addendum).** "Provable" raises a bar over a hardcoded
  string; it is not tamper-proof.
- **🟡 A new, named residual (S131 cold review rec 4, `.ai/ROADMAP.md` F2):** `reverify` proves a
  real dispatch of the right role/session occurred; it does not bind that dispatch's OWN returned
  content to the specific `--from` findings file later ingested. Deferred, not closed.
- **🟡 The S127 residual is still open** — an `obeyed:` disposition's TRUTH is unverified;
  `implementation-advisor` rec 9 (`obeyed: 8cd3bea`, stub still present) still passes today's Advice
  gate. S132's own job, prompt written, not yet built.
- **🟡 `parse_delta()`'s `.contains("delta")` landmine (S130 GT finding)** — untriggered, unfixed
  this session (out of S131's locked scope; not named in S131's own Non-goals but also not
  reproduced or re-checked this session — carry it forward, do not assume it self-resolved).
- **🟡 VISION.md and `.ai/AGENTS.md:118` staleness (S130 GT finding)** — not touched this session
  (NO-CODE-adjacent doc fix, out of S131's locked one-story scope).
- **🟡 KNOWLEDGE.md is now larger still** (grew by ~25 lines this session, on top of S130's
  1,061-line / 290 KB baseline that was already +65% since S120) — F4 backlog, not this session's
  job, named again so it is not silently carried forward unremarked.
- **The fourth fork — still refused, still real, unchanged this session.** `TPL_CONSTRAINTS` in
  `src/cli/init.rs` still lacks `commit.forbid_skip_hooks` / `commit.forbid_force_push_to`;
  `communication.forbid` still ships 4 of our 5. Parked behind S131–S134, not dropped.
- **`vajra init` still blocks on stdin without EOF**; a stranger's first `vajra check` still exits 1.
- **Adoption:** not re-queried live this session (no reason to expect a change; last live query was
  S130's GT — 0 stars · 0 forks · 0 real issues · 19 downloads).
- **Dogfood: S124, now 7 sessions / 4 days stale at S131 (unchanged calendar age; session count
  grew).** S134 is the locked next fresh-scaffold paid dogfood.

## What Is In Progress
- **Nothing is mid-flight.** S131 is complete; S132 is locked and its prompt is written
  (`prompts/132-task-verify-advice-obeyed.md`), Planner + Architect gates both READY on it.
- **Locked, not queued:** S132 (fleet obeyed) → S133 (compression keep/kill) → S134 (fresh-scaffold
  dogfood). Rung 3 and outside adoption pushed back past S134.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each.**
- **S110: $0 (NO-CODE GT).** **S111–S117: $0 metered for build** (subagent tokens roll in
  unitemized).
- **S118: $4.0911771** authoritative (sonnet, headless `-p`, 1331s).
- **S119: $0 metered.** **S120: $0** (NO-CODE GT). **S121–S123: $0 metered.**
- **S124: $3.2984944499999984** authoritative (sonnet, headless `-p`) — the last paid dogfood.
- **S125: $0 metered** (interactive NO-CODE GT).
- **S126: $4.4482 authoritative** — five headless `claude -p` dispatches.
- **S128: $0 metered for build** (one `fidelity-reviewer` subagent pass, unitemized).
- **S129: $0 metered for build** — **~267k unmetered subagent tokens** (two `fidelity-reviewer`
  passes, ~113k + ~154k).
- **S130: $0 metered** (interactive NO-CODE GT) — **~266k unmetered subagent tokens** across 4
  parallel research dispatches.
- **S131: $0 metered for build** (interactive Sonnet 5) — **~90k unmetered subagent tokens** (one
  real `fidelity-reviewer` dispatch, `toolu_01FsZj2Rs9E6vdhsgKo7SUSX`, 12 tool uses, 220s).
- Cumulative: **~$91.2 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S131 subagents (unknown, not
  small, and growing).**
