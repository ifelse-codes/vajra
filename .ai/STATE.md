# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S130 complete, S131 not yet started).**

S130 was the mandatory NO-CODE ground truth (`130 % 5 == 0`), auditing S126–S129. **Verdict:
PARTIAL PASS.** Both product-facing audits registered at S128/S129 (`stranger_check`,
`scaffold_drift_check`) were RUN LIVE for the first time ever this session — both GREEN
(21/21, 17/17). `verify-closeout.sh --ledger-verify` re-confirmed INTACT. Constraint compliance for
S126–S129 was independently re-verified directly against git (not taken on a research agent's word):
zero violations, zero real `--no-verify` use, no commit over 3 `src/` files.

**Headline finding: the fleet is a roster, not a fleet, and the trend is getting worse.** Governed
handoffs dispatched per session: S126 **5** → S127 **3** → S128 **1** → S129 **0**. The one gate
that touches a handoff (S127's Advice gate) only fires if a handoff already exists — it never
complains when a session dispatches zero advisors, exactly what S129 did. Layered on top:
`src/cli/next.rs:283` hardcodes every handoff's provenance to the literal string
`"claude-code-subagent"`, never derived from real dispatch evidence, so even the 9 handoffs across
S126–128 carry an unverifiable claim.

**Second lens: one cold pass at close is not enough.** S129 needed two cold passes to catch two
forks, both inside the blast radius of its own fix. This session adds a third data point of the
same shape: `parse_delta()` in `src/analyst/mod.rs:318` (`heading.contains("delta")`) carries the
exact bug class that silently broke the Planner gate for many sessions — untriggered so far by
luck of formatting (two of this repo's own prompt titles, `prompts/59-*` and `prompts/61-*`, already
sit on the trigger condition), not by correctness. No test in `src/analyst/mod.rs` covers it.

**Two documents found stale, in the direction that UNDERSTATES progress (not overclaims):**
`VISION.md:5,21` still says "Rung 1 of 3" (Rung 2 passed at S103) and "package ~0%" (v0.1 shipped
S108); `.ai/AGENTS.md:118` calls one-session-per-chat "convention until Vajra enforces it" though
`hook-session-guard.sh` has enforced it since S26. Neither fixed this session (NO-CODE) — both
flagged for a small bundle-able fix.

**🟢 The founder locked the S131–S134 sequence at this closeout**, after a plain-language
walkthrough of the fleet finding. Their own words for why the reviewer/tester role goes first: it
should "ensure the session complete[s] all acceptance criteria and what it build[s] is actually
high quality work — not fake stamping and shortcuts."

- **S131** — make the `fidelity-reviewer` governed handoff MANDATORY (existence-gated at closeout,
  like every other Vajra gate) and replace its hardcoded provenance with real dispatch evidence
  (reusing the S111/S117 parent-tool-call-ID ↔ subagent-`meta.json` cross-check design).
- **S132** — verify the reviewer's advice was actually OBEYED, not merely answered — closes the S127
  residual (4 factually-wrong `obeyed:` labels once passed the gate, caught only by a cold reader).
- **S133** — founder decides: keep or kill the compression engine (1,005 LOC, $0 real savings,
  measured twice at S63 and S124). Bounded cleanup session either way.
- **S134** — a real paid dogfood run from a FRESH scaffold, not this repo — every paid dogfood in
  130 sessions has run inside the repo that builds Vajra.
- **Rung 3 (3-day unattended, multi-repo) and outside adoption are PUSHED BACK past S134, explicit
  founder call, named not-code-closeable** — a coding session cannot run a literal multi-day clock,
  and cannot code a stranger into starring or downloading the project. S131–S134 get the product
  ready for both; neither is a deliverable of this sequence.

**Numbers:** all 12 required GT audits answered · ledger INTACT · 0 `src/` changes, 0 commits on
the GT branch (`session-130-ground-truth`) · closeout rides `session-130-closeout` (exempt suffix).

## Active PRs
- **S130 GT — no PR** (NO-CODE sessions produce no code PR; the closeout bundle merges directly).
- S129 [#148](https://github.com/ifelse-codes/vajra/pull/148) MERGED · S128
  [#147](https://github.com/ifelse-codes/vajra/pull/147) MERGED · S127
  [#145](https://github.com/ifelse-codes/vajra/pull/145) MERGED · S126
  [#143](https://github.com/ifelse-codes/vajra/pull/143) MERGED · S125
  [#140](https://github.com/ifelse-codes/vajra/pull/140) MERGED.

## Direction (governance is the product — shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Fleet = real named agents behind the existing gates
  (`DECISION-007`).
- **Current direction, locked by the founder at the S130 closeout: MAKE THE FLEET REAL, starting
  with the one role that guards fidelity itself.** Not a new pre-work advisor — the role already
  closest to load-bearing, hardened until it can't be faked or skipped.
- **The founder's S125 gate is still open: nine roles is "done"; "and WORKING" is unproven.** S131
  is the first session that answers it with a real, blocking mechanism instead of another optional
  role.
- **Post-pivot path:** S118 ✓ dogfood → S119 ✓ clean-room → S120 ✓ GT → S121 ✓ QA Specialist →
  S122 ✓ guardrails → S123 ✓ role fenced → S124 ✓ paid dogfood → S125 ✓ GT (PARTIAL) →
  S126 ✓ fleet complete → S127 ✓ Advice gate → S128 ✓ first contact → S129 ✓ one source →
  **S130 ✓ GT (PARTIAL PASS), locked S131–S134 → S131 = make fidelity-reviewer mandatory + real.**

## What Currently Works
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE (S78 tee path). K=8/8 re-derived
  live this session for S126–S129 — shape holds, though QA/Demo-er are structurally
  `[static — not live-green]` for any past session once merged (reproduced live: re-running
  `verify-session-129.sh` post-merge now returns RED by design — its own comment predicted this).
- **The enforcement floor is real, re-verified again this session.** `vajra check` 9/11 (the 2
  expected FAILs are pre-`--render` staleness, not regressions); `hook-pre-write.sh` fired live
  mid-session, correctly blocking a Write outside its allowed paths during the GT branch — and
  reconfirmed its own known bug (block reason to stdout, not stderr).
- **Two instruments now RUN, not just registered:** `scripts/stranger-check.sh` (21/21) and
  `scripts/scaffold-drift.sh` (17/17), both live this session, both GREEN. The "registered, not
  run" residual from S128/S129 is retired for these two — but the general lesson (a gate nobody
  executes is not a gate) produced a THIRD instance this session (`parse_delta()`, above).
- **The fleet roster is COMPLETE at NINE named roles (S126)** — but usage is falling, not flat: see
  the headline finding above.
- **The Advice gate (S127)** — proves ANSWERED, never obeyed; S132 is the fix.
- **First contact works (S128)**, **one source for a stranger's rulebook, 3 of ~7 lists (S129)** —
  both re-verified live this session, no regression.
- **Ledger** (S100): re-confirmed INTACT again this session, live.
- **v0.1 install: four real channels**, stranger-shippable as measured at S110.

## What Is Broken / Weak
- **🔴 The fleet is a roster, and worsening — not a static problem, a declining one.** S131/S132 are
  the direct response, locked this closeout.
- **🔴 A second live landmine, same bug class as the Planner's:** `parse_delta()`
  (`src/analyst/mod.rs:318`), untriggered but armed — the trigger condition already exists in this
  repo's own prompt titles. Not fixed this session (NO-CODE); flagged for a quick bundle-able fix.
- **🟡 VISION.md and `.ai/AGENTS.md:118` are stale**, understating real progress. Not fixed this
  session; flagged for a quick bundle-able fix.
- **🟡 KNOWLEDGE.md is 1,061 lines / 290KB, +65% since S120's 642 lines** — the exact bloat S125
  diagnosed, worse four sessions later, still unfixed (F4, backlog).
- **The fourth fork — still refused, still real, re-verified unfixed this session.**
  `TPL_CONSTRAINTS` in `src/cli/init.rs` still lacks `commit.forbid_skip_hooks` and
  `commit.forbid_force_push_to` entirely, and `communication.forbid` still ships 4 of our 5 —
  confirmed by direct source read, not repeated from memory. Parked behind S131–S134, not dropped.
- **Cost blind spot growing, not shrinking:** S129 alone carried ~267k unmetered subagent tokens
  (two `fidelity-reviewer` passes); this GT session's own 4 parallel research subagents add a
  comparable order of magnitude, also $0 metered.
- **`vajra init` still blocks on stdin without EOF**; a stranger's first `vajra check` still exits 1.
- **Adoption re-confirmed unchanged, via live query not memory:** `gh api` + the crates.io API this
  session both confirm **0 stars · 0 forks · 0 real issues · 19 downloads.**
- **Dogfood: S124, 5 sessions / 4 days stale at S130.** Real, not fabricated, but 5 sessions of
  machinery since.

## What Is In Progress
- **Nothing is mid-flight.** S130 is complete; S131 is locked and its prompt is written
  (`prompts/131-task-fleet-mandatory-gate.md`).
- **Locked, not queued:** S131 (fleet mandatory) → S132 (fleet obeyed) → S133 (compression
  keep/kill) → S134 (fresh-scaffold dogfood). Rung 3 and outside adoption pushed back past S134.

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
  passes, ~113k + ~154k) — the largest unmetered review spend on record until this session.
- **S130: $0 metered** (interactive NO-CODE GT) — **~266k unmetered subagent tokens** across 4
  parallel research dispatches (KNOWLEDGE/constitution, constraint audit, vision/roadmap, gate
  hunt), a comparable order of magnitude to S129's. The blind spot is structural and growing as
  cold-review discipline increases, not shrinking.
- Cumulative: **~$91.2 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S130 subagents (unknown, not
  small, and growing).**
