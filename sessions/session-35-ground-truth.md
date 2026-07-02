# Session 35 — Ground Truth (NO-CODE)

**Type:** Mandated GT (`35 % 5 == 0`). Lens A (founder-picked, S34 closeout): verify the
"fix the core before breadth" bet + re-measure the second-agent gate.
**Branch:** `session-35-ground-truth`. No source-code edits, no PRs.

## 1. vision_alignment
- North star (`VISION.md`): one CLI that guides *any* agent, co-pilot not cop. Current repo
  is intentionally Claude-only (v1 scope, ADR-0001) — that's phasing, not drift.
- S32–S34 all deepened the Claude lane (Darshan, compression, onboarding) rather than
  widening to a second agent. Consistent with the S26 founder override: breadth is gated on
  Claude-lane satisfaction, and that gate is *still* the right one — no new evidence to pivot.
- **Verdict: aligned.** No direction drift.

## 2. roadmap_alignment
- Build queue items 1–3 (Darshan, compression, brownfield) done in order, each closing an
  S31 finding. Item 4 (this GT) is next-in-order and running now.
- Backlog has 4 S36 candidates competing for the #5 slot (ranked in §7).
- **Verdict: aligned**, roadmap accurately reflects reality (no stale `[x]` claims found).

## 3. state_drift
- `STATE.md` "What Currently Works" / "What Is Broken" match the code: `.claude/settings.json`
  merge gap and `exit_code == Some(0)` heuristic gap are both still present (unfixed, correctly
  flagged, not silently dropped).
- Active PR: #29 still open per `STATE.md` — confirmed via `git log` (not yet merged into this
  checkout's history at branch point... actually **merged**: `b98ca44` is the merge commit,
  now on `main`). **Finding:** `STATE.md` says PR #29 "open (merge after closeout)" but it was
  already merged before S35 started. Stale by one commit — cosmetic, self-correcting at S35
  closeout sync.
- **Verdict: minor drift (cosmetic only), no action beyond normal closeout sync.**

## 4. knowledge_staleness
- `KNOWLEDGE.md` §7 hook wire types correctly reflect the S33 snake_case fix. §9 Known
  Limitations still lists stderr-on-exit-0 and pricing staleness — both still true, not stale.
- No entry yet for S34 (brownfield onboarding, hook placement, auth pre-check) as a permanent
  fact — checked: it's append-only and S34's mechanics are covered by STATE.md instead, which
  is correct per `state_md_mode: snapshot` / `knowledge_md_mode: append-permanent-only` (S34
  didn't introduce a new *permanent* fact beyond what §7/§8 already generalize).
- **Verdict: current, no stale entries found.**

## 5. constraint_violation_review
- Checked `CONSTRAINTS.yaml` limits against S32–S34 commits: each session stayed 1 story,
  ≤3 files per atomic commit (verified via `git log --stat` per session — largest S34 commit
  touched 3 files), branch-per-session pattern followed, approval tokens present before merge.
- **Verdict: no violations found in S32–S34.**

## 6. constitution_review
- `.ai/AGENTS.md` load order followed this session (SESSION → BOOT → TASK → STATE →
  CONSTRAINTS → KNOWLEDGE → ROADMAP → prompt) before any audit ran.
- **Meta-check:** is any rule now blocking the vision instead of protecting it? The
  *advised → enforced* meta-rule (S31) has fixed 3 instances but keeps finding new
  advised-mode gaps (`.claude/settings.json` merge, `exit_code` heuristic) — see §8. This is
  the constitution doing its job (surfacing debt), not blocking anything.
- **Verdict: no rule is currently obstructive.**

## 7. cost_review
- `STATE.md` Cost Tracking: cumulative ~$0.46 (S07) + one uncaptured S31 dogfood run. **Zero**
  `vajra claude` spend S32→S35. Confirmed via `git log` since S31: every commit is a code/docs
  commit (build, test, verify, closeout) — no receipt artifacts, no dogfood session files.
- **Verdict: spend is real and matches the ledger — no cost drift. But the ledger itself is the
  dogfood_check's headline finding (below).**

## 8. dogfood_check — THE headline finding
- **Question:** has real work run through `vajra claude` since the last GT (S30)? **Since S31,
  no.** One dogfood run happened in S31 itself (against `chitra`); zero since.
- S32–S34 verified their fixes with `cargo test`, `verify-session-NN.sh`, and one-off
  `--version`/binary smoke checks — **not** with a live, multi-turn `vajra claude` session
  doing real work.
- **This means:** the "advised → enforced" claims for Darshan, compression, and brownfield
  onboarding are *test-verified*, not *daily-use-verified*. The GT prompt predicted this
  exactly ("dogfood_check will bite... ~$0 spend since S31") and it did.
- **Verdict: UNMEASURED.** Per `dogfood_questions`, an unmeasured gate must not be guessed at.

## Gate call: second-agent promotion

**NOT cleared. Still unmeasured — same call as S30, one session later.**

The S26 override requires the founder to *declare* Vajra-on-Claude satisfying, and satisfaction
requires lived usage. Three real bugs got fixed and test-proven, but nobody has sat inside a
`vajra claude` session since S31 to feel whether they're actually fixed. Declaring the gate
clear on test evidence alone would repeat the exact failure mode S31 uncovered (green tests,
broken feel). **Recommendation: S36 = a real dogfood session**, not the second agent.

## Tension pressure-test: is the wedge structurally leaky?

Two *advised*-mode gaps surfaced organically during S33/S34 work (not from a dedicated audit):
`.claude/settings.json` merge and `exit_code` heuristics. This is **two data points, not a
pattern** — both are found-while-building, both are narrow (a merge algorithm; a field-source
swap), neither reopens a *closed* S31 finding. Normal edge debt from shipping fixes fast, not
evidence the "advised → enforced" wedge is broken. Worth tracking so a 3rd/4th one *would*
indicate a pattern.

## Ranked S36 candidates (leverage, not ease)

1. **Real dogfood session** — highest leverage: it's the only way to un-block the second-agent
   gate and the only way to know if S32–S34 actually feel fixed. Everything else is speculative
   until this runs.
2. **`.claude/settings.json` merge** — second-highest: brownfield is the realistic adoption
   path (most repos aren't greenfield); without this fix, brownfield onboarding's hooks
   silently never wire, undermining S34's actual value in the field.
3. **`exit_code` heuristic fix** — real but narrower: only affects 3 of N compression paths,
   and line-count folding already covers the common case (per KNOWLEDGE §7/§9).
4. **Obedience metric** — valuable but explicitly staged/backlog, not blocking anything; do
   after usage exists to measure (can't measure obedience with ~$0 usage either).

## Next session options (exactly 3)

**A. S36 = Real dogfood session (recommended)**
- Goal: run `vajra claude` on a real task end-to-end, capture the receipt, feel the 3 fixes.
- Why: only path to clearing the second-agent gate honestly; directly answers "are the fixes
  felt, not just green?"
- Risk: may surface new findings (a 4th core breakage) — acceptable, that's the point.

**B. S36 = `.claude/settings.json` merge**
- Goal: brownfield init merges into existing settings.json instead of skipping it.
- Why: closes the highest-leverage known code gap; unblocks brownfield's real-world value.
- Risk: without a fresh dogfood run first, still building on an unmeasured gate.

**C. S36 = `exit_code` heuristic fix**
- Goal: `cargo`/`npm`/`pytest` compression keys off inferred success, not the unsent `exit_code`.
- Why: smallest, cleanest 1-story fix; closes a named S33 finding.
- Risk: lowest leverage of the three — cosmetic relative to the unmeasured gate.

**Founder sign-off required before code resumes.**
