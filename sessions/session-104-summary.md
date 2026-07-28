# Session 104 — Summary: the pipeline speaks like a team

**Type:** CODE (presentation/UX; small). **One story:** reface the 8 governed stations as a named
team instead of "station K-of-8" — mechanism identical. Founder pick **C** (S103 closeout), order
**C → B → A**.

## Goal achieved? YES

`vajra next --stations NN` and the `vajra next` handoff packet now lead with a human **team roster**
(each station a named role + a plain-English status line). The `K of 8` survives as a subtitle; the
gate pass/fail logic and the computed K are untouched.

- `cargo test --lib` = **296** (293 + 3 new); fmt + clippy clean.
- `scripts/verify-session-104.sh` = **8/8 GREEN**; `scripts/demo-session-104.sh` = exit 0, all 4
  sprint-demo elements.
- Commits: `2399cdf` (reface + packet reuse + tests), `23a0e6b` (verify + demo scripts).

### Before → After (`vajra next --stations 103`, real output)

```
BEFORE (headline was the plumbing):
  4 of 8 stations passed (derived from each gate's evidence ...)
  [PASSED] Analyst   WHAT   — substantive `## Delta`

AFTER (headline is the team; K kept as a subtitle below):
  ✓ Analyst   framed what to build
  — Architect no design recorded yet
  ✓ Planner   mapped a plan to the goal
  — Coder     no code committed yet
  ✓ Releaser  shipped it
  ✓ Reviewer  signed off
```

## Fidelity map (every requirement → evidence)

| # | Requirement (from prompt) | Status | Evidence |
|---|---|---|---|
| AC1 | `--stations` prints 8 named roles + plain status, not a bare K-of-8 (K may be subtitle) | **SHIPPED** | `format_station_report` prepends `format_team_roster`; K kept as subtitle; verify `reads-like-a-team` + `headline-not-a-number` |
| AC2 | Role names + phrasing defined ONCE, reused by `--stations` and the packet | **SHIPPED** | `ROLES` + `format_team_roster` in `stations`; both `--stations` and `run_dump` call it; `roles_cover_every_station` + verify `single-source-reuse` |
| AC3 | Gate logic untouched; `cargo test` green; computed K == pre-refactor K (a test pins it) | **SHIPPED** | no gate fn changed; 296 tests; `reface_preserves_k_and_shows_it` pins K; verify `k-unchanged-vs-subtitle` |
| AC4 | `verify-session-104.sh` exits 0; demo shows before→after | **SHIPPED** | verify 8/8; demo exit 0, `demo:before_after` present |
| D1 | `src/` role-narration layer wired into `--stations` + boot packet | **SHIPPED** | `src/stations/mod.rs`, `src/cli/next.rs` |
| D2 | verify + demo scripts | **SHIPPED** | `scripts/verify-session-104.sh`, `scripts/demo-session-104.sh` |
| D3 | summary (fidelity) + independent cold review (ACCEPT attested) + 3 ranked options | **SHIPPED** | this file · `sessions/session-104-review.md` · options below |
| PC | Reface only — existing tests UNCHANGED | **SHIPPED** | no existing test edited; roster prepended so `legacy_convention_prompt_is_unmeasurable_not_absent` still passes verbatim |

## What I did NOT build (plainly)

- **No gate/mechanism change** — by design. No new command, no new store, no real parallel agents
  (that is Option A, later).
- **The SessionStart bash hook still cats files directly** — the roster is reused by the `vajra
  next` packet (which AGENTS.md calls "the `.ai/` handoff packet"), not by `hook-session-start.sh`
  (bash can't reuse a Rust map without shelling to the binary). I read "boot packet" as the vajra
  packet; if the founder meant the hook, that is a small follow-up.

## Fakest green (the honest asterisks)

1. **The plumbing is demoted, not deleted.** To keep the "existing tests UNCHANGED" pass-condition
   literally true, the original `[PASSED]/[ABSENT]` table + K line are kept as an *auditable detail*
   block **below** the team roster (progressive disclosure). The headline reads like a team; the
   technical table is still visible if you scroll.
2. **Plain status is keyed only by outcome**, not by the finer reason. "Coder — no code committed
   yet" shows even when the real cause is "steps 1,2 unrecorded" or "no plan". That nuance still
   lives in the technical `note` (the detail block), not in the friendly line.

## Next options (ranked — founder picks)

**A — Make it installable (B in the C→B→A order; recommended lead).** One-sentence goal: a stranger
can `cargo install` / download vajra and run a 10-minute quickstart. Why pick: the MVP-pivot
(S103) says sessions now finish a *shippable* v0.1; install + quickstart is the gap between "works
on my machine" and "release". Key risk: crates.io name is taken (`vajractl` package) — packaging +
README quickstart must be truthful about the binary name.

**B — Real named agent fleet (A in the order; later).** One-sentence goal: spawn real
researcher/coder/QA agents on top, gates underneath as the trust engine. Why pick: it is the
FirstMate "feel" the founder is drawn to. Key risk: large; the MVP-pivot says ship first, fleet
after — likely premature now.

**C — Full reface (retire the plumbing table entirely).** One-sentence goal: replace the technical
`[PASSED]` table with the team roster outright (update the one surface test), so the wart is gone,
not just demoted. Why pick: closes fakest-green #1. Key risk: small, and arguably cosmetic vs.
shipping the MVP.

**Recommendation: A** (installable) — it is next in the founder's own C→B→A order and the shortest
path to a releasable v0.1.
