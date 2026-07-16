# Session 71 — The DEMO-ER station (pipeline station 7 — the SHOW gate)

> **Status:** APPROVED (founder pick B at the S70 GT close, sharpened in-session). **Type: CODE.**
> Founder's words, the contract: *"we build actual demo — when I say 'next session', seeing it the
> user can know what this session delivered, and the before-and-after comparison. It is just like a
> sprint demo."* The station makes that a governed, enforced gate — not a hope.

## Goal
Ship the Demo-er — the 7th governed station: every closing session must have a **sprint demo** a
human can watch — what this session delivered, **before → after** — surfaced by `vajra next --demo NN`
and enforced (live-re-run, the S69 house pattern) by `--check-demo NN` at `--advance`. Surfaces +
enforces, never authors the demo.

## Why this session
- Founder direction: finish the crew (Demo-er → Releaser, one per session); S70 GT recorded the pick.
- The demo spine already EXISTS (`CONSTRAINTS.yaml#demo`: `script_pattern` + `cumulative` +
  `required_elements` + `presentation_rules`) but nothing enforces it — same pre-S69 shape QA had
  ("house rule, no teeth"). Map-to-Vajra: own this spine; no `demo.md`, no second store.
- Known gap found at S70: `scripts/demo-session-template.sh` is named in CONSTRAINTS but **does not
  exist on disk** — the station's session must create it (in scope: it IS the demo spine).

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** `vajra next --demo NN` runs **THEN** it surfaces the session's demo contract read-only —
   script exists/MISSING, `required_elements` (header · cases · summary_table · **before_after**)
   found/missing, an honest-cost note — and never executes anything.
2. **WHEN** `vajra next --check-demo NN` runs **THEN** it RE-RUNS `scripts/demo-session-NN.sh` LIVE
   (the S69 executable-marker pattern — a recorded green is never accepted) and BLOCKS (exit 1) on
   non-zero exit OR missing required elements, naming the real failure; a check that cannot evaluate
   FAILS (unrunnable/killed script blocks, never passes).
3. **WHEN** `--advance` closes session NN at L2/L3 **THEN** the Demo-er gate binds on the session
   being CLOSED (L1 advises; `VAJRA_SKIP_DEMOER_GATE=1` is a distinct override — other stations'
   skips do not skip it, and it skips the slow live run itself, disclosed); no demo script (NO-CODE
   GT / legacy) → WARN with the deletion dodge named in the gate's own output.
4. **WHEN** a session's demo runs **THEN** it shows the sprint-demo shape: a `before_after` section
   (what this session delivered vs the session before) is a required element enforced by the gate,
   `scripts/demo-session-template.sh` exists carrying all 4 elements, and `CONSTRAINTS.yaml#demo`
   records `before_after` in `required_elements` — demo stays cumulative.
5. **The station is proven live:** `cargo test --lib` grows; `scripts/verify-session-71.sh` runs
   E2E cases in a temp git repo (red demo blocks · green passes · missing-element blocks · no-script
   WARNs · all `--advance` outcomes · override distinctness both directions); no 8th command, no new
   dependency, no second store.

## Design (the Architect gate — recorded rationale)
- design-significant: yes — a new pipeline station touching the `--advance` gate chain.
- Rationale: the Demo-er is station 7 of the governed pipeline shape locked in
  `docs/decisions/DECISION-001-governance-as-product.md` (governed stations with enforced handoffs);
  its marker is *executable* (a demo script), so per the S69 house pattern it is **re-run live,
  never trusted as recorded** — the same evidence-upgrade QA made for verify scripts, applied to
  demos. The contract is the existing `CONSTRAINTS.yaml#demo` spine (no new store), extended with
  one recorded element (`before_after`) to carry the founder's sprint-demo requirement. The gate
  enforces the demo EXISTS, RUNS, and shows before→after; the human-facing presentation (interactive
  HTML slide deck) stays the agent's Darshan job per `demo.presentation_rules` — the binary never
  renders.

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Build `src/demoer/mod.rs`: read the `#demo` contract (script_pattern + required_elements, house
   line-scan, scaffold defaults on missing keys), `DemoState`, element scan, live runner
   (fail-closed) + unit tests; register in `lib.rs`. covers: 1, 2
2. Wire the CLI: `vajra next --demo NN` (read-only surface) + `--check-demo NN` (live re-run, exit 1)
   + `--advance` binding on the CLOSING session (L2/L3 block · L1 advise ·
   `VAJRA_SKIP_DEMOER_GATE=1` distinct) + the no-script WARN naming the dodge. covers: 1, 2, 3
3. Make the sprint-demo shape real: create `scripts/demo-session-template.sh` (header · cases ·
   summary_table · before_after), add `before_after` to `CONSTRAINTS.yaml#demo.required_elements`,
   propagate to the `vajra init` scaffold (the S22 `include_str!` pattern; check `Cargo.toml`
   exclude-negation). covers: 4
4. Prove it: `scripts/verify-session-71.sh` E2E in a temp git repo (red/green/missing-element/
   no-script/advance/override cases) + `scripts/demo-session-71.sh` (dogfood: S71's own demo carries
   before→after) + independent cold review + attestation (`--inputs-sha 71` emitted at review time).
   covers: 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: be263a4
- step 2 — done: 95f8b39
- step 3 — done: e13f02c
- step 4 — done: a3cd5b0

## Guardrails
- **One story:** the Demo-er station. The readable-roadmap one-pager is a NATURAL RIDER only if it
  fits inside the demo's before→after surface with zero extra store — else it stays in backlog.
- Surfaces + enforces, **never authors** a demo; binary never renders HTML (presentation = Darshan).
- Max 3 files per commit · approval tokens before any commit · branch `session-71-demoer-stage`.
- Honest-cost disclosure: the live demo re-run at `--advance` costs real seconds (same as QA);
  the override skips the run itself — say so in the gate output.
- Fakest-green candidates to disclose up front: hollow demo (`exit 0` + empty sections passes the
  run but NOT the element scan — scan must be real), deletion dodge (no script → WARN, named),
  self-granted jurisdiction (the known five-wide class — disclose, don't hide).

## Delta (vs ROADMAP — OpenSpec markers)
- `+` Pipeline station 7: the Demo-er (SHOW gate) — `src/demoer/mod.rs` + `--demo/--check-demo` +
  `--advance` binding + `VAJRA_SKIP_DEMOER_GATE`.
- `+` `before_after` as a required demo element (the founder's sprint-demo contract) + the missing
  `scripts/demo-session-template.sh` created + scaffold propagation.
- `~` The crew count: 6 → 7 governed stations (Releaser next, Monitor later).
- `-` Nothing removed; compression/dogfood/payload-counter debts carried per the S70 founder
  decisions (see `sessions/session-70-ground-truth.md` §Founder decisions).

## Deliverable
- `src/demoer/mod.rs` + `src/lib.rs` + `src/cli/next.rs` wiring · `scripts/demo-session-template.sh`
  + `CONSTRAINTS.yaml#demo` element + scaffold propagation · `scripts/verify-session-71.sh` +
  `scripts/demo-session-71.sh` · `sessions/session-71-summary.md` + independent cold
  `sessions/session-71-review.md` (attested) · closeout `.ai/` sync + exactly 3 ranked S72 candidates
  (standing: Releaser · compression-truth work · payload counter [backlog]).
