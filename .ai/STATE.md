# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S97 complete, S98 not yet started).
S97 = **DOGFOOD (paid, Ladder Rung 1)**: one real `vajra claude -p` turn drove chitra S08 through the
stations. **$1.2758 authoritative** (fable-5, exit 0, 16 turns). `--stations 08` = **2/8**; **Coder
`[ABSENT]` — doubly-blocked**: (a) chitra's older scaffold has no `## Execution` marker slots, (b)
headless can't supply a commit-approval token → zero commits → zero shas. Agent **refused to
self-commit even under `--dangerously-skip-permissions`** vs chitra's teeth-less convention gate
(3rd reconfirmation of voluntary obedience). **No green forced** — the honest partial IS the finding.
Evidence in `sessions/session-97-artifacts/` + `sessions/session-97-summary.md`.
`VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes` (no Vajra `src/` changes, no `## Execution` shas).

## Active PRs
- **S97 PR:** `session-97-e2e-pipeline-dogfood` (dogfood artifacts + report; no `src/` changes).
- Merged: S96 [#97](https://github.com/ifelse-codes/vajra/pull/97) ·
  S95 [#95](https://github.com/ifelse-codes/vajra/pull/95)/[#96](https://github.com/ifelse-codes/vajra/pull/96) ·
  S94 [#94](https://github.com/ifelse-codes/vajra/pull/94) · S93 [#93](https://github.com/ifelse-codes/vajra/pull/93).

## Direction (governance is the product — 8 governed stations; enforcement arc complete)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **Standing S95 GT verdict (still binding):** the ENFORCEMENT arc is complete (S93 obedience
  enforced, S94 identity-aware, fail-closed) — the **pipeline has not advanced since S72** (4th
  consecutive GT: S80/S85/S90/S95). **S97 dogfooded it end-to-end** (pattern-break, founder pick A):
  the launcher + governance work; the Coder station is **doubly-blocked** for a headless subject repo.
- **Coder-dark ROOT CAUSE (S97, live-evidenced):** (a) chitra was scaffolded by an *older* `vajra
  init` — its prompts (`00–03`) have **no `## Execution`/`## Delta`/`## Design`/`## Plan` marker
  slots**; `--stations` reads for markers the repo structurally can't contain (Analyst/Architect/
  Planner/Coder all `[ABSENT] — no prompt`, Demo-er missing header/cases/summary). (b) chitra's
  commit gate is a **conversational-token** gate a headless `-p` run can't satisfy → zero commits →
  zero shas. **Fix (→ prompt 98):** marker slots ride the scaffold · env-marker commit path for
  unattended runs (chitra has none — no `.githooks`, no `VAJRA_ALLOW_COMMIT`) · agents write markers,
  Vajra verifies. **S97 deliberately did NOT hand-author chitra's scaffold to force a green Coder** —
  that would build machinery + mute the finding (whether it populates *naturally* — it does not).
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood 🟢
  (S92 = 2026-07-21, $0.2713) — LAUNCHER only (2/8); pipeline never dogfooded end-to-end (S95). ③
  compression: never claimed until measured (0 folds). ④ payload counter = BUILT (S74), hardened
  (S82); S95 meta-check: read its per-station SHAPE, not just the K number.
- **House patterns (carried):** un-forgeable-env markers — `VAJRA_CLOSEOUT_WAIVER` (S56),
  `VAJRA_ALLOW_PUBLISH` (S37), `VAJRA_ALLOW_COMMIT` (S93); repo-identity resolution — a guard derives
  git facts only from the project's OWN git top-level, cannot-evaluate ⇒ fail-CLOSED (S94). Config
  toggle beats code fork: `publish_guard: off` / `commit_guard: off` in this repo, absent from the
  scaffold. Fakest-green classes: jurisdiction-self-granted (S69) · hollow-green (S69) ·
  voluntary-not-enforced (S76/S92, closed S93) · fail-open-on-cannot-evaluate (S94).

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt AUTHORITATIVE when `total_cost_usd` exists (S66/S78, proven S92 $0.2713),
  HONEST when it doesn't (S77); closeout blocks unfilled execution shas (S81); Releaser durable
  across pruning (S82); attestation recompute-and-compare (S86/S88); `--dogfood-age` live git query
  (S91) now shows **S97 · $1.2758** (date resolves once the S97 artifacts commit).
- **CI is green on `main`** (S96): `cargo fmt --check` + `clippy -D warnings` + `cargo test --lib`
  all pass on both ubuntu-latest and macos-latest. rustfmt pinned/verified 1.9.0-stable.
- **Commit gate ENFORCED (S93):** L2 `.githooks/pre-commit` (`VAJRA_ALLOW_COMMIT==NN`); L3
  `hook-commit-guard.sh` un-forgeable teeth. Scaffolded ON; `commit_guard: off` in this repo.
- **Guards repo-identity-aware (S94):** commit-guard + copilot-murmur pin git facts to the
  project's own git top-level; session-guard surfaces the governed project + flags nesting;
  fail-CLOSED when a project has no git of its own.
- **`cargo test --lib` 286** (unchanged — S96 was formatting-only, no new tests).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.
- **CONSTRAINTS.yaml `required_audits`** — 10 audits; all run in S95.

## What Is Broken / Weak
- **🟡 Station counter mis-measures older-scaffold repos (S97, new)** — `--stations` reads modern
  marker sections that a repo scaffolded by an older `vajra init` (chitra) doesn't contain, so it
  reports `[ABSENT]` for *convention absent* the same as for *work absent*. Fix belongs with the
  scaffold-marker upgrade + a counter that distinguishes the two.
- **🟡 Unattended completion blocked by conversational commit gate (S97, new)** — a headless `-p`
  run can't utter an approval token, so it can never reach a full closeout; needs an env-marker
  commit path (Vajra's own `VAJRA_ALLOW_COMMIT` shape) for ladder/autopilot runs. chitra has none.
- **🟡 Machinery-vs-payload gradient — 4th consecutive GT** — enforcement arc complete; pipeline
  unchanged since S72. S97 dogfooded it e2e; the reposition (S98) turns the pipeline into the engine
  of an autopilot-trust pitch rather than growing more machinery.
- **🟡 Coder/EXECUTE station: honest-green only under trivial mapping** — S96 made it PASS on a
  formatting-only session; the gate proves a real sha was recorded per plan step, not that a commit
  *semantically* executes the step. Real hard-work execution still unproven.
- **🟡 KNOWLEDGE §6 bloat (chronic, flagged S60)** — 416 lines / 69 dated entries / ~85K tokens;
  header "Reloaded every session" is false (it's load-order #7, on-demand). Prune candidate (S97 opt B).
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** — L3 `commit_guard: off`; L2 belt
  inline-forgeable; `--no-verify` bypasses both. Teeth proven by test + shipped ON in scaffolds.
- **🟡 Own-git non-session-branch marker fallthrough** + **exotic git shapes untested** (S94 residual).
- **🟡 Compression no-op on real CC (S63/S76)** — never claim until measured; cargo/npm/pytest fold gap.
- **🟡 Cross-agent breadth (original S25 ask) is still zero code** — founder-gated (S26/S70).
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — held at $15/$75 (S79).

## What Is In Progress
- **S97 DONE (DOGFOOD — paid e2e pipeline).** Next = **S98 = autopilot-trust reposition** (docs;
  founder pre-drafted `prompts/98-task-autopilot-trust-reposition.md`; founder flips its status line
  DRAFT→approval word before `--advance`). **New chat.** Then **S100 = NO-CODE GT.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- Session 53–75: ~$0 each. **S76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713 authoritative** (sonnet-4-6, dogfood).
  **S93/S94/S95: ~$0** · **S96: ~$0** (formatting-only). **S97: $1.2758 authoritative** (fable-5,
  e2e dogfood; + ~$0.26 nested-launch smoke = ~$1.54 session total).
- Cumulative: **~$75.9 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
