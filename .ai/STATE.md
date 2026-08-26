# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S133 complete, S134 not yet started).**

S133 was CODE, re-picked by the founder in chat at the S132 closeout. **Goal achieved.** A session
cannot reach its close without either a real `design-advisor` governed handoff or a RECORDED,
substantive, VISIBLE reason why it did not need one. A silent skip is no longer possible; a
reasoned skip always is.

**What shipped:** `src/mandate/mod.rs` — named for the MECHANISM and generic over a `fleet::Role`,
so S134's `implementation-advisor` is a call site and not a third copy of the ladder. Six rungs,
decided in the module header rather than fallen out of the code, with rung 1 beating rung 3 on
purpose: **a forged claim is not cured by a sentence.** The reasoned skip is
`<role-name>: skipped — <reason>` in the session's own prompt — line-anchored, fence-skipping (both
kinds), gated by `advice::substantive_reason` verbatim, keyed on the ROLE NAME so S134 inherits the
grammar with no new parser. `vajra next --check-design-handoff NN` (its own sub-flag, no 8th
command) binds at `--advance` AND at `scripts/verify-closeout.sh`. `analyst::PROMPT_TEMPLATE`
carries the marker as a placeholder, so a freshly `vajra init`ed project blocks at session 1
despite the session-number threshold. Decision of record: the **DECISION-007 S133 addendum**, which
also declares the S131 condition it relaxes.

**The one gate here with NO `VAJRA_SKIP_*` escape, on purpose.** Twelve environment variables are
driven live, one at a time and all together, and it blocks every time; the module contains zero
`env::var` calls. Two limits recorded rather than implied: `VAJRA_CLOSEOUT_WAIVER` still waives the
closeout check (founder-held, un-forgeable BY THE AGENT), and `maturity: L1` still advises.

**THREE independent dispatches.** `design-advisor` FIRST, before any code (15 recs — 14 obeyed, 1
deferred); a cold `fidelity-reviewer` pass (**ACCEPT**, 14/18 SHIPPED, 10 recs — 8 obeyed, 2
deferred); and `implementation-advisor` as the JUDGE, grading all 22 `obeyed:` claims
`implemented:` and naming in writing where it came closest to a mismatch.

**Live evidence:** `scripts/verify-session-133.sh` **15/15 GREEN**, `scripts/demo-session-133.sh`
**9/9 GREEN**, 428 lib tests, clippy clean, `cargo fmt --check` clean. Falsifiability fixture RED
on **7 bypasses** and GREEN on renaming all 11 messages. `K of 8` pinned to its recorded baseline
(**8 of 8 at session 132**) and unchanged; the 7-command floor unchanged.

## Active PRs
- **S133 — PR opens at closeout, after `.ai/` sync.**
- S132 [#153](https://github.com/ifelse-codes/vajra/pull/153) MERGED · S131
  [#150](https://github.com/ifelse-codes/vajra/pull/150) MERGED + hotfix
  [#151](https://github.com/ifelse-codes/vajra/pull/151) · S130
  [#149](https://github.com/ifelse-codes/vajra/pull/149) MERGED · S129
  [#148](https://github.com/ifelse-codes/vajra/pull/148) MERGED.

## Direction (governance is the product — shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`), fleet = real named agents behind the gates (`DECISION-007`).
- **Current direction, locked by the founder at the S130 closeout: MAKE THE FLEET REAL.** S131 made
  one role mandatory and its provenance provable; S132 made the fleet's ADVICE consequential;
  **S133 made the first BUILD-SHAPING advisor mandatory, with a reasoned skip that leaves a trace.**
- **Post-pivot path:** … S130 ✓ GT (locked S131–S134) → S131 ✓ fidelity-reviewer mandatory +
  provable → S132 ✓ `obeyed:` verified, not merely answered → **S133 ✓ design-advisor mandatory +
  the recorded reasoned skip → S134 = the same treatment for `implementation-advisor`.**

## What Currently Works
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. `K of 8` re-derived live this session and PINNED to
  its S132 baseline — the Mandate gate is a FLEET gate, not a ninth station.
- **Two mandatory fleet roles now.** `fidelity-reviewer` (S131) grades finished work at the END;
  `design-advisor` (S133) must be consulted before the close, or the skip must cost a sentence
  recorded in the repo.
- **The advice is consequential (S127 + S132) and now also UNSKIPPABLE-IN-SILENCE (S133).**
- **The enforcement floor, re-verified live:** 15/15 verify, 9/9 demo, falsifiability fixture RED
  on seven bypasses (each asserting its substitution landed and its red being a test failure, not a
  compile error) and GREEN on renaming every message.
- Ledger (S100), first contact (S128), one source for a stranger's rulebook (S129): unchanged, not
  re-verified live this session. v0.1 install: four real channels, unchanged.

## What Is Broken / Weak
- **🔴 A dispatch that happened ≠ advice that reached the design.** A session can write all its
  code, dispatch the advisor at close, land the handoff, and show every gate green. The cheap
  partial answer (compare `captured:` against the first code commit, WARN) was proposed by the
  advisor itself and deliberately NOT built — **ROADMAP F2f**.
- **🔴 The reasoned skip may become the default dodge.** Nothing counts it. The counting rule is
  fixed and runnable in `sessions/session-133-summary.md`: **skips outnumbering dispatches in any
  rolling 5-session window.**
- **🔴 The gate binds at CLOSE, not before code.** "Before code" is a workflow property, not a
  mechanism. Do not read acceptance 1's wording as a commit-time block.
- **🔴 Dispatch evidence is forgeable by anyone with shell access (S131, unchanged).**
  `VAJRA_CLAUDE_PROJECTS_DIR` redirects where that evidence is READ FROM — no env var bypasses the
  block, and the evidence a handoff is judged against is not signed.
- **🟡 `maturity: L1` still turns the Mandate gate advisory at `--advance`** and
  `.ai/CONSTRAINTS.yaml` is agent-writable. Nothing probes it live — **ROADMAP F2g (NEW)**.
- **🟡 Two copies of the mandatory-role ladder** (`src/mandate` and `src/fidelity`) — **ROADMAP F2e
  (NEW)**. S134 must be a CALL SITE, never a third copy.
- **🟡 A lazy judge still passes (S132, unchanged)**, and this session's judge had no shell: it
  resolved every sha against `.git/logs/HEAD` and called its own evidence "consistent" rather than
  "verified".
- **🟡 `refused:` is still the cheapest exit from the Advice gate.**
- **🟡 F2a (judge identity), F2b (the regress ends by hand), F2c (three selection rules)** — all
  open, none touched.
- **🟡 `parse_delta()`'s `.contains("delta")` landmine · VISION.md and `.ai/AGENTS.md:118`
  staleness · KNOWLEDGE.md growth (F4)** — carried, named again rather than silently dropped.
- **The fourth fork — still refused, still real.** `TPL_CONSTRAINTS` in `src/cli/init.rs` still
  lacks `commit.forbid_skip_hooks` / `commit.forbid_force_push_to`.
- **`vajra init` still blocks on stdin without EOF**; a stranger's first `vajra check` still exits 1.
- **Adoption:** not re-queried live this session (last live query: S130 GT — 0 stars · 0 forks ·
  0 issues · 19 downloads).
- **Dogfood: S124, `$3.2985`, 2026-08-20 — 9 sessions and 6 calendar days stale** (live
  `--dogfood-age` at this closeout). **The oldest un-run item on the roadmap**, deferred again.

## What Is In Progress
- **Nothing is mid-flight.** S133 is complete; `prompts/134-task-implementation-advisor-mandatory.md`
  is written.
- **S134 = the same treatment for `implementation-advisor`**, on S133's mechanism, as a CALL SITE
  (ROADMAP F2e) — the founder's locked sequence, and option A of the three presented at this
  closeout. It must also probe the `L1` escape (F2g) and either close F2e or record why not.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797**. **S104–109: ~$0 each.** **S110: $0** (NO-CODE GT).
- **S111–S117: $0 metered for build.** **S118: $4.0911771** authoritative. **S119: $0 metered.**
- **S120: $0** (NO-CODE GT). **S121–S123: $0 metered.** **S124: $3.2984944499999984** authoritative
  — the last paid dogfood. **S125: $0 metered.** **S126: $4.4482 authoritative.**
- **S128–S131: $0 metered.** **S132: $0 metered for build** — ~367k unmetered subagent tokens.
- **S133: $0 metered for build** (interactive) — **~550k unmetered subagent tokens** across three
  real dispatches (design-advisor ~139k, fidelity-reviewer ~150k, implementation-advisor ~126k)
  plus ~135k on a first fidelity pass that died mid-response to an API error and returned nothing.
- Cumulative: **~$91.2 + S76 (unknown, ≤ ~$26.6) + S111–S133 subagents (unknown, not small, and
  growing).**
