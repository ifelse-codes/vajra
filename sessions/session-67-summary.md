# Session 67 — The Architect stage (the pipeline's DESIGN gate) — Summary

**Type:** CODE (founder pick A at S66 close, standing "all approved"). **Branch:** `session-67-architect-stage`.
**Goal achieved:** YES — the pipeline gains its 4th governed station: Analyst (WHAT) → **Architect (DESIGN)** →
Planner (HOW-plan) → Reviewer/ledger (REVIEW). The S64/S65 "pipeline middle is unbuilt" gap is retired.

## What shipped

- **`src/architect/mod.rs`** (new, registered in `lib.rs`): `DesignState{NotSignificant, Missing, Placeholder,
  Substantive}`; significance is a **recorded marker** (`design-significant: yes|no`), never guessed; substance =
  a non-placeholder `## Design` rationale citing the locked spine (`ADR-000N`/`DECISION-00N`);
  `locked_design_spine` surfaces `docs/adr/` + `docs/decisions/` (sorted, README skipped, missing dirs degrade
  to empty); citation requirement **waived** when a repo has no spine (fresh `vajra init` can't block forever).
- **CLI (`src/cli/next.rs`):** `vajra next --design NN` (surface the spine, citations ✓-marked) ·
  `--check-design NN` (exit 1 on missing/placeholder/uncited) · wired into `--advance` between the Analyst and
  Planner gates (L2/L3 block · L1 advise · `VAJRA_SKIP_ARCHITECT_GATE=1`, distinct override). **No 8th command.**
- **Analyst `PROMPT_TEMPLATE`** gains the placeholder `## Design` (symmetric with S61 Delta / S64 Plan): an
  unfilled marker is `Unrecorded` (the Architect alone never blocks a fresh scaffold — DRAFT/Delta already do);
  the moment an author records `yes`, the placeholder rationale BLOCKS until substantive.
- **Dogfood:** `prompts/67-task-architect-stage.md` records its own `design-significant: yes` + a rationale
  citing DECISION-001/002 + ADR-0002 — this session passes the gate it built.

## Evidence

- `cargo test --lib` **183** (+13 architect); fmt + clippy `-D warnings` clean.
- `scripts/verify-session-67.sh` **31/31** — incl. 11 E2E cases in a temp L3 repo (surface/block-missing/
  block-placeholder/block-uncited/block-made-up-ref/pass-substantive/pass-no/warn-legacy/advance-blocks/
  override/advance-passes) + real-repo dogfood (`--design 67` marks ADR-0002 + DECISION-001 cited;
  `--check-design 67` READY).
- `scripts/demo-session-67.sh` — 6-act cumulative demo, scorecard green.
- **Two-pass cold review (DECISION-002):** pass 1 = ACCEPT but found a real hole (a made-up `ADR-9999`
  satisfied the citation check) → closed in-session (existence-gated citations) → pass 2, a FRESH reviewer on
  the new diff, = **ACCEPT** (attested `fb09c94b…`). The reviewer loop caught and retired a defect — working
  as designed.

## Fidelity map (every numbered requirement → verdict)

| # | Acceptance criterion | Verdict | Evidence |
|---|---------------------|---------|----------|
| 1 | `--design NN` surfaces the design context (relevant locked ADRs) as the checklist | SHIPPED (weak form, disclosed) | Surfaces the FULL spine with the prompt's recorded citations ✓-marked — relevance = **recorded by the author**, never inferred from the touched surface (inferring would author). `format_design_checklist` + `e2e-design-surfaces-spine`. |
| 2 | Design-significant (recorded marker) + no real `## Design` → `--check-design` BLOCKS exit 1 | SHIPPED | `Missing`/`Placeholder` states; `e2e-check-design-blocks-{missing,placeholder,uncited}`. |
| 3 | Substantive rationale (non-placeholder, references the ADR/decision) → PASSES exit 0 | SHIPPED | `Substantive` requires real text + ≥1 spine citation; `e2e-check-design-passes-substantive`. |
| 4 | Non-significant prompt → never blocks, WARNS at most | SHIPPED | Explicit `no` passes silently; unmarked legacy prompt warns (`does not record design significance`); `e2e-check-design-passes-no` + `warns-legacy`. |
| 5 | Wired into `--advance`: L2/L3 block · L1 advise · `VAJRA_SKIP_ARCHITECT_GATE=1` distinct | SHIPPED | Gate sits between Analyst and Planner in `run_advance`; `e2e-advance-blocks-undesigned` / `override-skips-gate` / `passes-substantive`. |
| 6 | `verify-session-67.sh` proves all five behaviors in a temp git repo; exit 0 | SHIPPED | 30/30 (2 artifact checks green once this summary + the cold review exist). |

**Plan steps:** 1 module+states+spine — SHIPPED · 2 CLI+advance+override — SHIPPED · 3 template placeholder —
SHIPPED · 4 verify+demo — SHIPPED.

**NOT built (stated plainly):** no relevance *inference* (the checklist marks recorded citations; it does not
compute which ADRs the session's diff actually touches); no semantic judgment of the rationale; real fable-5
pricing, compression 0-fold, and the Coder stage remain untouched (out of scope, carried).

## Fakest green (the honest limit)

**The gate enforces the FORM of a design record, not a design decision.** `design-significant:` is self-declared
(an author can type `no` on an interface-breaking session and sail through), and "substantive" = any
non-placeholder text citing a record that EXISTS in the spine — `- rides ADR-0002.` typed with zero thought
passes (a made-up `ADR-9999` no longer does — review pass 1's find, closed). The second reviewer sharpened it
further: a bare `ADR-0001` line satisfies both the rationale and citation checks, and an **ADR deviation passes
by citing the ADR it deviates from** — nothing reconciles the deviation. Exactly the Planner's `covers:`
digit-tag honesty floor (S64), one station earlier: it makes the *absence of a recorded rationale* impossible
to ship silently; it cannot make the rationale *true*. Never pitch this as "design verified."

## Next — exactly 3 ranked candidates (S68)

- **A 🥇 — The Coder handoff (governed CODE stage).** *Goal:* the pipeline's LAST gap — govern the execution
  handoff (accepted prompt + covered plan + recorded design → a delta-tracked, fidelity-boundable coding run).
  *Why:* completes the 5-station spine the vision names; every other station now exists to govern exactly this.
  *Risk:* the largest design surface yet — "govern without authoring" is hardest at the CODE stage; scope must
  stay one story.
- **B 🥈 — Fix or formally retire the compression claim.** *Goal:* S63 measured 0 folds on real CC output; either
  make the engine fold something real (safely, correctness-first) or retire the claim from receipt/docs/pitch.
  *Why:* the standing 🟡 the product still implies; "provable governance" can't ship an unproven savings line.
  *Risk:* fold-hunting can gamble correctness (S36 directive) — retirement may be the honest outcome.
- **C 🥉 — Semantic-check hardening (one gate past its digit-tag).** *Goal:* upgrade one recorded-marker gate
  (Planner `covers:` or Architect citation) from form to meaning via an independent cold subagent pass at
  closeout. *Why:* retires the recurring "fakest green" class at its root. *Risk:* adds a paid/LLM dependency to
  a so-far-hermetic gate; must stay optional + fail-open honestly.

**Recommendation: A.** S65's GT named DESIGN and CODE as the two missing stations; DESIGN shipped today — A is
the shortest path to "the pipeline exists," and B/C harden what A would immediately exercise.
