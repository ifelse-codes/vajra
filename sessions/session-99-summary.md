# Session 99 — Coder Reachable Unattended (CODE) — Summary

**Goal:** make the Coder station reachable by an UNATTENDED run — fix the two blocks S97 (Autopilot
Ladder Rung 1) hit live on chitra. The sanctioned "fix what a ladder run broke" under the
machinery-freeze rule (`DECISION-005`); the enabler for Rung 2.

**Goal achieved:** YES. Both blocks fixed; two-pass independent cold review **REJECT → ACCEPT**,
attested, ledger extended. Scope held (no station redesign, no new command, no README).

## Evidence (what shipped)

| Deliverable | File | Commit |
|---|---|---|
| init kickoff rendered from the ONE canonical `analyst::PROMPT_TEMPLATE` (a fresh repo is station-measurable from S01) | `src/cli/init.rs` | `ad240c8` |
| `Outcome::Legacy` — convention-absent ≠ work-absent; cause + remedy surfaced; never counts toward K/8 | `src/stations/mod.rs` | `c7dcf63` |
| commit pre-authorization surfaced on `vajra next` AND the SessionStart boot packet, classified exactly as `hook-commit-guard.sh` | `src/cli/next.rs`, `scripts/hook-session-start.sh` | `666ff5a` |
| verify (32/32) + demo | `scripts/verify-session-99.sh`, `scripts/demo-session-99.sh` | `7d1bb0e` |
| pass-1 REJECT fixes (real ratchet · real cross-surface · real guard parity · on-surface disclosure) | src + scripts | `b76ff58`, `a385e1e` |

- `cargo test --lib` **293** (was 286) · `cargo fmt --check` + `clippy -D warnings` clean.
- `bash scripts/verify-session-99.sh` → **32/32, exit 0** (drives the real binary + real hook + real
  guard in a throwaway `vajra init` repo — behavioural, not grep-of-source).
- `vajra next --stations 99` → **6 of 8** (Releaser/Reviewer pending merge + this review).

## Fidelity check — every requirement mapped (independently reviewed, two-pass, cold)

Full verdict in `sessions/session-99-review.md` (`Review-Inputs-SHA: 6dbcf20a…`).

| # | Requirement | Verdict |
|---|---|---|
| D1–D4 | init template · LEGACY outcome · packet pre-auth · verify+demo | **SHIPPED** |
| A1 | kickoff carries markers, asserted by a test that fails on a second copy | **SHIPPED** (pass-1 tautology fixed) |
| A2 | zero-marker prompt → LEGACY (cause+remedy), never ABSENT; over-fire guarded | **SHIPPED** |
| A3 | pre-granted vs token-required in the packet | **SHIPPED** |
| A4 | verify exits 0 (A1–A3); demo before/after | **SHIPPED** |
| A5 | pre-auth line stated as advisory + agent-forgeable; no retro-fit | **SHIPPED** (pass-1 doc-only fixed) |
| G1–G6 | one story · no redesign/command/store/README · ≤3 files/commit · `VAJRA_ALLOW_COMMIT=99` | **SHIPPED** |
| D5 | summary + 3 candidates | this file |

**Overall: ACCEPT.**

## What I did NOT build (stated plainly)

- **No retro-fit of prompts already on disk.** Step 1 fixes what `vajra init` *emits*; older repos
  (like chitra) get modern prompts from `vajra next --advance` or restored guards from re-running
  `vajra init` (skip-if-present) — the scaffold is not rewritten under them.
- **No enforcement moved into the pre-auth surfaces.** They are ADVISORY and **agent-forgeable** —
  they read their own process env, which the agent controls. The un-forgeable teeth stay with the L3
  `hook-commit-guard.sh`, which reads its OWN launch env before the command runs. verify proves the
  two agree with each other AND with the guard's real allow/block decision.
- **No live Rung 2 run.** This session removes the blockers; actually running a day unattended is the
  next ladder step, not this fix.

## Fakest "green" here

`commit_authorization_mirrors_the_guard` (unit test) — its name promises guard parity but it only
checks the Rust classifier against hardcoded values; the guard is never invoked inside the unit test.
It is **disclosed** (the test doc points to the live parity in `verify-session-99.sh`) and
**backstopped** (that script drives the real `hook-commit-guard.sh` and asserts `0/2/2`). Honest floor,
not a hollow one — but if someone deleted the verify block, the unit test alone would still read green.

## The classification exists twice (Rust + bash) — disclosed

The commit-auth rule is now implemented in `commit_authorization()` (Rust, for `vajra next`) and in
`hook-session-start.sh` (bash, for the boot packet) — two surfaces are two runtimes. `verify-session-99.sh`
asserts the two agree per env and that both agree with the guard, but nothing *structurally* prevents a
future edit to one from drifting from the other. This is the price of surfacing the state on the boot
packet a headless run always reads; the alternative (Rust-only) would leave that surface silent.

## Cost

~$0 (no paid `vajra claude` run — this is machinery to *enable* the paid Rung 2 run, not the run).

## Next — 3 ranked S100/S101 candidates (A/B/C)

*(S100 is a FIXED mandatory NO-CODE ground truth regardless of this pick — its lead lens is "is the
ladder being climbed, or did machinery resume?". This choice sets S101. Under the machinery-freeze
rule, S101 either runs the ladder or fixes what a run broke.)*

### A — Autopilot Ladder Rung 2 (one-day unattended dogfood, chitra) — *recommended*
- **Goal:** run the ladder now that the Coder blocks are removed — multi-task, one day unattended on
  chitra, guards ON, `VAJRA_ALLOW_COMMIT` pre-authorized at launch; measure zero-leak + honest receipts
  + fidelity-verdict correctness on a founder spot-check.
- **Why pick this:** S99 was the enabler; A is the payoff and the crown-jewel move. It is the truest
  test and will surface the next real break rather than a pre-guessed one.
- **Key risk:** chitra's on-disk prompts are still legacy (S99 does not retro-fit) — the run must first
  `vajra next --advance` chitra onto modern prompts, or it re-hits the marker wall in a new form.

### B — chitra scaffold upgrade path (make the enabler reach the real subject repo)
- **Goal:** give chitra modern station-marker prompts (via `--advance` / a re-init pass) so Rung 2 runs
  on a measurable repo, and confirm `--stations` reads it as modern, not LEGACY.
- **Why pick this:** removes A's key risk before spending on the paid run; small, surgical.
- **Key risk:** bends toward machinery again — only justified as "prep the ladder run", not open-ended.

### C — release-backstop slice (README truth-pass + crate-rename scoping)
- **Goal:** start the 2026-09-15 backstop: retire the stale ~8× receipt claim, fix unverifiable install
  paths, scope the crate rename.
- **Why pick this:** clears the audit's two truth-gaps early.
- **Key risk:** neither a ladder run nor a fix-what-broke — bends the freeze rule; better sequenced once
  Rung 2/3 give the README real numbers to tell the truth about.
