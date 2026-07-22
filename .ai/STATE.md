# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S94 complete, S95 not yet started).
S94 = **CODE** — close the nested-repo guard blindspot (S52), now load-bearing after S93.
Made the PreToolUse guards **repo-identity-aware**: git facts are pinned to the project's OWN git
top-level (require `git -C "$ROOT" rev-parse --show-toplevel` == `$ROOT`), never an enclosing repo;
the governed project is surfaced on every advise/block; and a subject with **no git of its own** is
**fail-CLOSED** — no marker (not the enclosing repo's `94`, not an arbitrary one) can authorize a
commit there. Two-pass cold review: pass 1 caught a fail-open (the nested no-own-git path fell to
"any non-empty marker allows") → fixed with a cannot-evaluate gate → pass 2 ACCEPT, attested
`8a05903e…`. verify-session-94.sh **23/23**; `cargo test` 286; demo 4/4 markers.
Summary: `sessions/session-94-summary.md`. Review: `sessions/session-94-review.md`.

## Active PRs
- Merged: S93 [#93](https://github.com/ifelse-codes/vajra/pull/93) ·
  S92 [#92](https://github.com/ifelse-codes/vajra/pull/92) ·
  S91 [#90](https://github.com/ifelse-codes/vajra/pull/90)/[#91](https://github.com/ifelse-codes/vajra/pull/91).
- **S94 PR:** TBD (`session-94-nested-repo-guard`, 3 commits `5218091`/`1e6d664`/`363e90c`).

## Direction (governance is the product — 8 governed stations; commit gate enforced; guards repo-identity-aware)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S94 outcome:** the S52 nested-repo blindspot (session-guard / copilot / commit-guard keying on
  `session-NN` + a git repo, unable to tell Vajra's own branches from a subject's during a dogfood)
  is CLOSED. commit-guard + copilot-murmur were the two guards that read git from `$ROOT` and could
  bleed to an enclosing repo; both now pin to the project's own git top-level. session-guard was
  already file-pinned — it gains identity surfacing + a nesting flag. Guards ride `include_str!`, so
  `vajra init` inherits them byte-identical (no `init.rs` change).
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood 🟢
  (S92 = 2026-07-21, $0.2713). ③ compression: never claimed until measured (0 folds). ④ payload
  counter = BUILT (S74) + GT-verified + hardened (S82).
- **House patterns (carried):** un-forgeable-env markers — `VAJRA_CLOSEOUT_WAIVER` (S56),
  `VAJRA_ALLOW_PUBLISH` (S37), `VAJRA_ALLOW_COMMIT` (S93). **New (S94): repo-identity resolution —
  a guard derives git facts only from the project's OWN git top-level (`--show-toplevel == $ROOT`,
  canonical `pwd -P`); cannot-evaluate ⇒ fail-CLOSED, never the permissive fallback.** Config toggle
  beats code fork: `publish_guard: off` / `commit_guard: off` in this repo, absent from the scaffold.
  Fakest-green classes: jurisdiction-self-granted (S69) · hollow-green (S69) · voluntary-not-enforced
  (S76/S92, closed S93) · **fail-open-on-cannot-evaluate (S94, caught by cold review pass 1, fixed)**.

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt AUTHORITATIVE when `total_cost_usd` exists (S66/S78, proven S92 $0.2713),
  HONEST when it doesn't (S77); closeout blocks unfilled execution shas (S81); Releaser durable
  across pruning (S82); attestation recompute-and-compare (S86/S88); `--dogfood-age` live git query
  (S91) shows S92 · $0.2713.
- **Commit gate ENFORCED (S93):** L2 `.githooks/pre-commit` (`VAJRA_ALLOW_COMMIT==NN`); L3
  `hook-commit-guard.sh` un-forgeable teeth. Scaffolded ON; `commit_guard: off` in this repo.
- **Guards repo-identity-aware (S94):** commit-guard + copilot-murmur pin git facts to the
  project's own git top-level; session-guard surfaces the governed project + flags nesting;
  fail-CLOSED when a project has no git of its own. verify-session-94.sh 23/23.
- **`cargo test --lib` 286** (unchanged — S94 touched only shell + verify/demo).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.
- **CONSTRAINTS.yaml `required_audits`** — 10 audits.

## What Is Broken / Weak
- **🟡 Own-git non-session-branch marker fallthrough** — off a `session-NN` branch, any non-empty
  `VAJRA_ALLOW_COMMIT` authorizes (session-binding enforced only on `session-NN`). Pre-existing;
  S94 left it intact under the zero-regression mandate (S94 review, fakest green).
- **🟡 Exotic git shapes untested** — S94's nested-vs-own detection is tested only for the plain-dir
  shape; worktrees / submodules / symlinked roots all resolve fail-CLOSED (safe) but are untested,
  and an exotic mount where `--show-toplevel` disagrees with `pwd -P` would wrongly BLOCK a
  legitimate own-repo commit.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** — L3 is `commit_guard: off`
  (build-agent exemption); L2 belt is inline-forgeable and `--no-verify` bypasses both. Teeth proven
  by test + shipped ON in scaffolds (S93 fakest green).
- **🟡 Repo-wide rustfmt 1.9.0 drift** — `next.rs` / `dogfood/mod.rs` / `stations/mod.rs` fail a
  crate-wide `cargo fmt -- --check` (S91-era). Housekeeping.
- **🟡 Compression is a no-op on real CC (S63/S76)** — never claim until measured; cargo/npm/pytest
  exit-code fold gap (S33/S41) still open.
- **🟡 Cross-agent breadth (original S25 ask) is still zero code** — founder-gated per S26/S70.
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — held at $15/$75 (S79).
- **🟡 `--ledger-verify` opt-in, not in mandatory closeout run** · `full_historical_scan` pass bar is
  a floor · `candidate_diffs` O(n·k) rescan.

## What Is In Progress
- **S94 DONE (CODE).** Next = **S95 = mandatory NO-CODE ground truth** (`95 % 5 == 0`). **New chat.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- Session 53–75: ~$0 each. **S76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713 authoritative** (sonnet-4-6, dogfood).
  **S93: ~$0** (CODE). **S94: ~$0** (CODE — shell-only; no paid `vajra claude` run).
- Cumulative: **~$74.3 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
