# Session 54 — The Analyst stage (the pipeline's first governed specialist)

**Type:** CODE · **Branch:** `session-54-analyst-stage` · **Spend:** ~$0 (local build/test only).

## Goal — achieved?
**Yes.** Built the first governed SDLC stage: the **Analyst** turns intent into the **next governed
prompt** (Vajra's own spec, `prompts/NN-task-<slug>.md`) — *not* a foreign `spec.md` — and an
**advance gate** blocks starting a session whose prompt is missing / malformed / still DRAFT.
Rides `vajra next` (no 8th command); owns the `.ai/`+`prompts/` spine (no second store).

## What shipped
- `src/analyst/mod.rs` — `scaffold_prompt` (Borrow-Engine template) · `validate_prompt` → report ·
  `gate(root, N)` → block/warn verdict · `detect_second_store`. 11 unit tests.
- `vajra next --scaffold NN <slug>` (generate) · `--validate NN` (report) · gate wired into
  `--advance` (fail-closed L2/L3, advise L1, `VAJRA_SKIP_ANALYST_GATE=1` override).
- `scripts/verify-session-54.sh` (**31/31 green**) · `scripts/demo-session-54.sh` · this summary.
- `cargo test` **140 lib** (+11); fmt + clippy `-D warnings` clean. `src/main.rs` + `Cargo.toml`
  untouched (no 8th command, no new dep).

## Real run (not a mock) — the Analyst dogfooded itself
Generated **this session's own next prompt** with the tool:
`vajra next --scaffold 55 pipeline-ground-truth` → DRAFT → `--validate 55` = **NOT READY** → filled +
approved → `--validate 55` = **READY**. The S55 prompt a non-author could run now exists, in Vajra's
format, no new file type. Demo shows the full 76→77 handoff: DRAFT blocks, APPROVED advances.

## The four questions S54 had to answer (honest)
1. **Intent → a usable next prompt in Vajra's own format, no new file type?** ✅ Yes — proven live
   above; the artifact is `prompts/NN-task-*.md`, no `spec.md`.
2. **Is the gate real or advisory?** ✅ **Real.** `--advance` exits non-zero and holds `.ai/SESSION`
   when the target prompt is missing, malformed, or DRAFT (verify checks it live in a temp repo).
   *Honest boundary:* approval = a recorded `Status:` marker — the same trust model as a commit-
   approval token (an agent *could* forge it); tamper-evidence is the future cross-stage ledger.
3. **Stayed on the spine + within the cap?** ✅ Yes — output in `prompts/`+`.ai/`; still 7 commands;
   `detect_second_store` + verify assert no `spec.md`/`specs/` exists.
4. **Borrow Engine — what folded in, what stayed out?** Folded **into the prompt**: Spec Kit's
   sectioned structure (Goal/Deliverables), Kiro/EARS **testable** acceptance ("WHEN…THEN…"),
   OpenSpec **+/~/−** delta markers. Left out: the foreign `spec.md` file, EARS' full formal grammar,
   OpenSpec's separate change-proposal dir — all would have created a second store.

## Honest weaknesses / carry-forwards
- **One stage ≠ the pipeline.** This is the Analyst only; Planner/Architect/Implementer/Reviewer +
  the cross-stage **ledger** are unbuilt. The moat headline (cross-agent tamper-evident ledger) is
  still **0 code**.
- **Approval integrity is marker-based**, not yet git-hash-tied → the ledger (S56 cand.) is what makes
  it evidence.
- **Delta is warned, not blocked** (backward-compat with legacy prompts) — hardening candidate.
- "Better work" remains a **parked, n=2-null hypothesis** — S54 does not touch it.

## 3 ranked candidates for S56  (S55 = mandatory NO-CODE ground-truth, already scaffolded + approved)
- **A — The cross-stage delta ledger (the moat kernel).** *Goal:* append each stage's `+/~/−` delta
  to a git-tied, hash-chained `.ai/ledger` so governance becomes a **visible, tamper-evident**
  artifact. *Why:* closes the 0-code headline moat + upgrades Analyst approval from marker to
  evidence. *Risk:* durability/hash-chain scope can balloon — slice to append+verify only.
- **B — The Planner stage (stage two).** *Goal:* approved prompt → a governed task/step breakdown with
  its own gate, proving the pipeline *composes* beyond one stage. *Why:* turns "a stage" into "a
  pipeline". *Risk:* reads as Spec Kit's plan step unless the delta/gate wedge stays front.
- **C — Harden the Analyst gate (delta-blocking + git-tied approval).** *Goal:* make `## Delta`
  required and tie approval to a commit/signature, not a text marker. *Why:* closes the two honest
  boundaries above cheaply. *Risk:* lower leverage than shipping the ledger or the next stage.

**Recommendation:** **A** — it is the standing #1 (make governance *sellable/visible*) and it
retro-strengthens what S54 just shipped.
