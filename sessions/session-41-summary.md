# Session 41 — Fix the compression fail-gate (correctness-first) — SUMMARY

**Type:** CODE (founder pick B at S40 close). **Branch:** `session-41-fix-compression-exit-gate`.
**Story:** unblock the known-safe format-aware folds regardless of `exitCode`; keep the generic
path conservative; **never hide a failure** (founder directive `vajra-compression-correctness-first`).

## Goal achieved? ✅ YES

The S36-proven defect is fixed **correctness-first**. Real Claude Code omits `exitCode` for Bash, so
`is_success` inferred "failure" and the pre-selection fail-gate blocked **every** 30–399-line command
(S36: 0 folds live). The gate now runs **after** heuristic selection and applies **only** to
heuristics that do **not** guarantee the failure signal survives.

- **`heuristic/mod.rs`** — new trait method `preserves_failure_signal() -> bool` (default `false`:
  the conservative generic path stays gated).
- **`heuristic/git.rs`** — the git family overrides it to `true` (git log head+tail keeps the newest
  commits; git status / git diff --stat are pure passthrough — they can't hide a byte).
- **`default_engine.rs`** — select heuristic first; gate only when `!preserves_failure_signal()`.

**Deliberately NOT touched (carry-forward):** cargo/npm/pytest branch on `exit_code == Some(0)`, so
with no `exitCode` they take their `_fail` branch. Unblocking them would gamble — e.g.
`compress_cargo_test_fail` prints `"…errors present"` on a *passing* ≥400-line run. Their exit-code
coupling is a separate fix (ROADMAP backlog).

## Evidence

| Live proof — real-shape payload (no `exitCode`) → `vajra hook`, $0 | Before | After |
|---|---|---|
| `git log --oneline -60` (60 lines) | passthrough | ✅ **folds**; tail `commit 59` survives |
| generic failure, error-at-head, 81 lines | passthrough | passthrough (never gamble) |
| generic `ls` 80 lines | passthrough | passthrough (conservative) |
| `git status` large | full | full (decision-critical) |
| `exitCode:0` present / ≥400 lines | folds | folds (unchanged) |

- **`scripts/verify-session-41.sh`: 20/20 GREEN** — Rust gates + source-wiring assertions + the live
  fold-table proof above.
- **Regression tests** (`tests/hook_adapter.rs`, real-shape, no `exitCode`):
  `git_log_no_exit_code_folds_after_s41` (the WIN + tail survives) ·
  `genuine_failure_no_exit_code_passthroughs_both_ways` (the invariant that must never regress) ·
  `generic_ls_no_exit_code_stays_conservative`.
- `cargo test` 107 lib + 12 adapter + integration all pass; clippy clean; fmt clean.
- **3 source files** (fix) + tests + verify script. Commits: `98376db` (fix) · `a5086a6` (proof).

## Cost
- **Session 41: ~$0.00** — the fold table was proven for $0 via `vajra hook` payload replay (S36
  method); no paid `vajra claude` run. The dogfood gate stays UNMEASURED (see next-options B).

## Next — exactly 3 (drawn from ROADMAP)

### A — Git-level hooks + `jq`-preflight (S42 = founder pick C at S40) — RECOMMENDED / pre-committed
- **Goal:** scaffold a tracked `.githooks/pre-push` + `pre-commit` + `core.hooksPath` into `vajra init`
  (ROADMAP #17) as a belt-and-suspenders L2 layer, **bundling** the S40 `jq`-missing → fail-open fix
  (AGENTS.md L147: "a check that cannot evaluate FAILS").
- **Why pick this:** closes the one real *latent* leak (jq fail-open) + the raw-`echo > .ai/SESSION`
  bypass in one session; it's the founder's already-locked S42 pick.
- **Key risk:** two concerns in one session (git-level scaffold + jq preflight) could strain the
  1-story / ≤3-file discipline — may need a clean split.

### B — Re-dogfood: live-verify the S37→S41 moat (S40 GT candidate A, standing item #17a)
- **Goal:** run the real `vajra claude` loop at L3 against a scaffolded project; prove the publish-guard
  + session-guard block a live agent and that S41 compression now folds live — render the
  founder-satisfaction gate verdict with evidence.
- **Why pick this:** the moat has been **test-verified, not live-verified since S36** (dogfood gate
  🔴 UNMEASURED); S41 just added a compression change that has only been proven via payload replay.
- **Key risk:** costs real $ (S36 interactive run was ~$58, cache-read dominated); needs a live agent
  that actually attempts a push.

### C — cargo/npm/pytest exit-code heuristic gap (the S41 carry-forward, ROADMAP backlog)
- **Goal:** make cargo/npm/pytest heuristics key off the engine's inferred success instead of
  `exit_code == Some(0)` (which real CC never sends), so build/test output folds correctly — safely.
- **Why pick this:** it's the natural completion of the compression correctness work; those three
  heuristics still never fold typical output on real CC.
- **Key risk:** the fail-branch-on-success paths are subtle (the `"errors present"` fabrication) —
  correctness-first here means careful, possibly conservative, design.
