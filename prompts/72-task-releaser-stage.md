# Session 72 — The RELEASER station (pipeline station 8 — the SHIP gate)

> **Status:** APPROVED (standing founder direction recorded at the S70 GT: "finish the crew —
> Demo-er → Releaser, one per session"; carried through the S71 close). **Type: CODE.**
> The last ungoverned handoff: a session's work SHIPS (PR → merge → main synced → branches
> pruned) on convention alone. The S37 founder-flagged gap — "the workflow has no post-merge
> 'checkout main + prune merged branches' step; mandatory to close/start a session" — is still
> enforced by nobody. The Releaser makes ship hygiene a governed, enforced gate.

## Goal
Ship the Releaser — the 8th governed station: `vajra next --release NN` surfaces session NN's
ship state read-only (branch merged into main? local main synced with origin? merged
`session-*` branches left unpruned?); `--check-release NN` BLOCKS (exit 1) on unfinished ship
hygiene; wired into `--advance` so a session cannot close while the PRIOR session's release is
unfinished. Git-native evidence only (ancestry + refs, re-derived live — never a recorded
claim); surfaces + enforces, never pushes, merges, or deletes anything.

## Why this session
- Founder direction: finish the crew (one station per session); after SHOW (S71), SHIP is the
  last core handoff before the crew's later Monitor.
- Map-to-Vajra: the evidence already exists in git (merge ancestry, `origin/main`, local
  branch list) — no new artifact, no `release.md`, no network call, no `gh` dependency in the
  gate; the S37 return-to-main memory item becomes enforcement instead of a checklist line.
- The house patterns apply directly: the marker is *derived git state* (the S68 Coder lesson,
  git-shaped) — always re-derived live, never trusted as recorded (S69/S71).

## Acceptance (testable — every criterion is cited by a `## Plan` step below)
1. **WHEN** `vajra next --release NN` runs **THEN** it surfaces session NN's ship state
   read-only — session branch found/missing, merged-into-main or not (git ancestry), local
   `main` vs `origin/main` sync (when a remote exists), leftover merged `session-*` branches
   named — and never executes, pushes, fetches, or mutates anything.
2. **WHEN** `vajra next --check-release NN` runs **THEN** it BLOCKS (exit 1) when session NN's
   branch is NOT an ancestor of main, OR local main is behind/diverged from a known
   `origin/main`, OR merged `session-*` branches (other than the current one) are unpruned —
   naming each failure concretely; a repo where the state cannot be derived (no git, no main)
   FAILS, never silently passes.
3. **WHEN** `--advance` closes session NN at L2/L3 **THEN** the Releaser gate binds on the
   PRIOR session (NN's predecessor with a session branch/prompt): its unfinished ship hygiene
   refuses the close; L1 advises; `VAJRA_SKIP_RELEASER_GATE=1` is a distinct override (other
   stations' skips do not skip it, both directions); a fresh repo (no prior session branch, no
   remote) WARNS at most, the dodge named in the gate's own output.
4. **WHEN** a repo is scaffolded **THEN** the ship contract is recorded, not implied:
   `CONSTRAINTS.yaml` gains a `release:` section (require_merged_prior, require_main_synced,
   require_pruned) read by the gate with scaffold defaults on missing keys; this repo's
   CONSTRAINTS records it and `vajra init` propagates it (the S22/S57 pattern).
5. **The station is proven live:** `cargo test --lib` grows; `scripts/verify-session-72.sh`
   runs E2E cases in a temp git repo with a real bare `origin` (merged passes · unmerged
   blocks · unsynced main blocks · unpruned blocks · fresh-repo WARNs · all `--advance`
   outcomes · override distinctness both directions · L1 advise); `scripts/demo-session-72.sh`
   carries the four `demo:<element>` markers (the S71 Demo-er gate now live-scans this
   session's own close); no 8th command, no new dependency, no second store.

## Design (the Architect gate — recorded rationale)
- design-significant: yes — a new pipeline station touching the `--advance` gate chain.
- Rationale: the Releaser is station 8 of the governed pipeline shape locked in
  `docs/decisions/DECISION-001-governance-as-product.md` (governed stations with enforced
  handoffs); its evidence is *derived git state*, so per the S68 Coder lesson (existence via
  `git cat-file`) and the S69/S71 executable-marker lesson (re-run live, never trust a
  recording), the gate re-derives ancestry/sync/prune facts from git at check time — there is
  no recorded text to forge. The independence of the verdict chain stays with the Reviewer
  (`docs/decisions/DECISION-002-fidelity-over-discipline.md`); the Releaser only governs ship
  MECHANICS. Fail-closed posture per AGENTS.md ("a check that cannot evaluate FAILS"). No
  network in the gate: `origin/main` is judged from the local ref (fetch staleness disclosed
  as an honest limit, not silently resolved).

## Plan (ordered steps — cite the acceptance criteria each step covers)
1. Build `src/releaser/mod.rs`: read the `#release` contract (house line-scan, scaffold
   defaults), derive `ShipState` from git (branch-for-session, `merge-base --is-ancestor`,
   main-vs-origin/main ahead/behind, merged `session-*` list), `release_gate` fail-closed +
   unit tests; register in `lib.rs`. covers: 1, 2
2. Wire the CLI: `vajra next --release NN` (read-only surface) + `--check-release NN` (exit 1)
   + the `--advance` binding on the PRIOR session (L2/L3 block · L1 advise ·
   `VAJRA_SKIP_RELEASER_GATE=1` distinct) + the fresh-repo WARN naming the dodge. covers: 1, 2, 3
3. Record the contract: `release:` section in this repo's `.ai/CONSTRAINTS.yaml` + the
   `vajra init` scaffold CONSTRAINTS (S22/S57 propagation; check Cargo.toml needs no new
   negation — no new script file). covers: 4
4. Prove it: `scripts/verify-session-72.sh` E2E in a temp git repo with a bare `origin`
   (merged/unmerged/unsynced/unpruned/fresh/advance/override/L1 cases) +
   `scripts/demo-session-72.sh` (four markers; before → after = "ship hygiene was a checklist
   line" vs "the close refuses until shipped") + independent cold review + attestation
   (`--inputs-sha 72` emitted at review time). covers: 5

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>

## Guardrails
- **One story:** the Releaser station. No PR-body generation, no `gh` calls, no auto-prune —
  surfaces + enforces only; pruning/merging stay human acts the gate waits for.
- Max 3 files per commit · approval tokens before any commit · branch
  `session-72-releaser-stage` · ~2h cap.
- Honest limits to disclose up front: local-ref staleness (the gate reads `origin/main` as
  last fetched — it cannot see an unfetched remote merge; say so in the surface), the
  self-granted-jurisdiction class (a repo with no remote/no prior branch WARNs — named), and
  the gate governs ship MECHANICS, not release QUALITY.
- Fakest-green candidates: "merged" proves ancestry, not that the merge was the reviewed PR;
  sync/prune checks pass trivially in single-branch toy repos — disclose, don't hide.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` Pipeline station 8: the Releaser (SHIP gate) — `src/releaser/mod.rs` +
  `--release/--check-release` + `--advance` binding + `VAJRA_SKIP_RELEASER_GATE`.
- `+` `CONSTRAINTS.yaml#release` recorded contract + scaffold propagation; the S37
  return-to-main founder item becomes enforced.
- `~` The crew count: 7 → 8 governed stations (Monitor stays later; core crew complete).
- `-` Nothing removed; compression/dogfood/payload-counter debts carried per the S70 founder
  decisions.

## Deliverable
- `src/releaser/mod.rs` + `src/lib.rs` + `src/cli/next.rs` wiring · `CONSTRAINTS.yaml#release`
  + scaffold propagation · `scripts/verify-session-72.sh` + `scripts/demo-session-72.sh` ·
  `sessions/session-72-summary.md` + independent cold `sessions/session-72-review.md`
  (attested) · closeout `.ai/` sync + exactly 3 ranked S73 candidates (standing: compression
  truth · payload counter [backlog] · semantic/depth hardening of the six-wide marker floor).
