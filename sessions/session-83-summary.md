# Session 83 — Warn before a headless read-only run (CODE) — summary

**Type:** CODE — one new function + one call-site wire in `src/cli/launch.rs`, no new module, no
new command, no new dependency. Founder pick B (UX-warning half) at S82 close.

## Headline

`vajra claude -p "..."` with no permission-mode flag is a read-only agent: headless Claude Code
has no approval channel, so every Write/Edit/Bash call is silently denied. Nothing said so before
the run started — S76's paid dogfood ride-along burned a real call against exactly this wall, and
the fix was carried as a debt across S73/S76/S77/S78/S81. `run()` now prints one advisory stderr
warning before `claude` is ever spawned, naming the wall and the fix.

## What shipped

- **`has_permission_flag(args) -> bool`** (`src/cli/launch.rs`) — exact-token scan for
  `--dangerously-skip-permissions` / `--permission-mode`, same style as the existing `is_headless`.
- **`should_warn_readonly_headless(args) -> bool`** — `is_headless(args) && !has_permission_flag(args)`,
  the single testable decision `run()` acts on.
- **`READONLY_HEADLESS_WARNING`** constant + one `eprintln!` call site in `run()`, placed right
  after `let headless = is_headless(args);` and before `merge_hook_settings()` — fires on both the
  settings-injection-ok and settings-injection-failed branches identically.
- **2 new unit tests**: `has_permission_flag_detects_either_flag_exact_token` (exact-token, not
  substring) and `should_warn_readonly_headless_matrix` (the warn/no-warn matrix across ACs 1-4).
- **`scripts/verify-session-83.sh`** (11 checks) + **`scripts/demo-session-83.sh`** (four
  `demo:<element>` markers) — both drive the REAL `run()` launch path end-to-end via a stub
  `claude` binary prepended onto `PATH`, so the E2E proof costs $0 and needs no credentials.

## Proof

- `bash scripts/verify-session-83.sh` → **11/11 PASS**.
- `cargo test --lib` → **263 passed** (+2 over `main`'s 261).
- `cargo clippy --all-targets -- -D warnings` and `cargo fmt --check` → clean.
- Live E2E (stub `claude`, real launch path): headless+no-flag warns; `--dangerously-skip-permissions`
  silent; `--permission-mode plan` silent; interactive (`--model opus`, no `-p`) never warns; exit
  code 0 in every case.

## Fidelity map (prompt requirement → delivery)

| # | Requirement | Verdict | Evidence |
|---|-------------|---------|----------|
| 1 | Headless + no permission flag → stderr warning before spawn | **SHIPPED** | `should_warn_readonly_headless_matrix`; live stub-binary run |
| 2 | `--dangerously-skip-permissions` present → no warning | **SHIPPED** | Same test; live run |
| 3 | `--permission-mode <mode>` present → no warning, any mode | **SHIPPED** | Tested with 2 distinct mode values |
| 4 | Interactive (no `-p`/`--print`) → never warns regardless of flags | **SHIPPED** | Structural short-circuit on `is_headless`; live run confirms |
| 5 | Advisory only: no exit-code change, no block, no `args` mutation | **SHIPPED** | Bare `if`/`eprintln!`, no control-flow effect; `command.args(args)` untouched |
| 6 | `cargo test --lib` stays green; new tests mirror existing style | **SHIPPED** | 263 (+2), same exact-token-scan idiom as `is_headless_detects_print_flags_only` |

**NOT built:** nothing from the prompt was skipped. The independent cold review
(`sessions/session-83-review.md`) confirms all 6 numbered criteria SHIPPED — ACCEPT.

## Honest limits (fakest green, reviewer-sharpened)

- **`ac5-advisory-exit-code-untouched` in `scripts/verify-session-83.sh` is a near-tautology.**
  The stub `claude` binary always exits 0, so both invocations under test are guaranteed to return
  0 regardless of whether the warning logic does anything — the check would only catch a bug blunt
  enough to be obvious from the diff itself. The AC5 property genuinely holds (verified by reading
  the code: the warning branch has no control-flow path), but this specific verify check is
  decorative, not load-bearing. Not fixed this session — the honest fix is a real process whose
  exit code the harness can vary, which is a bigger test-infra lift than a 1-story session bears.
- **AC4's "interactive + permission-flag-present" combination is never exercised by any
  test/demo/verify case** — only manually confirmed by the cold reviewer. Behavior is structurally
  correct (short-circuit on `is_headless` first), but the Plan's "tests cover ACs 1-4 directly"
  claim is a hair looser than delivered for this specific sub-case.

## Attestation

- **Review-Inputs-SHA:** `7b15529e8ae709e53d2bf745ad73c4642897d2ecc8267d1e0c4764139accd075`
  (`sha256(prompt ‖ delivery-diff)`; delivery diff = `src/cli/launch.rs`, commit `17279d8`, per
  `scripts/verify-closeout.sh --inputs-sha 83`). See `sessions/session-83-review.md` for the
  independent cold verdict (ACCEPT).

## Coder-gate execution (plan step → landing commit)

- step 1 (`has_permission_flag`) → `17279d8`
- step 2 (`should_warn_readonly_headless` + warning wire in `run()`) → `17279d8`
- step 3 (unit tests) → `17279d8`

## 3 ranked S84 candidates

- **🥇 A — the typed `CannotEvaluate::{Timeout,SpawnFailure}` half** (the natural S84 follow-on,
  carried forward from the S82/S83 split): `src/gate_run.rs`'s streamed QA path collapses timeout
  and spawn-failure into one untyped `None`, losing the distinction the S73 fakest-green finding
  named. Key risk: none material — it's the other half of an already-scoped, already-approved
  story; small and bounded.
- **🥈 B — S76 retroactive sha fix** (short, standing since S81, re-surfaced every session since
  as a carried debt): fill the 4 `<sha>` placeholders in `prompts/76-task-dogfood-ride-along.md`
  with real S76 shas; verify `--check-exec-shas 76` passes. Key risk: none material — a clean,
  bounded fix that's been waiting 7 sessions.
- **🥉 C — harden the attestation check itself** (S82's disclosed finding, now the standing weak
  point behind 2 stations): `session_attested_accept` / `reviewer_status` both trust a bare
  substring match on `"review-inputs-sha"` rather than recomputing the hash `verify-closeout.sh`
  already computes. Fix = have the station counter call the same `canonical_inputs_sha` logic.
  Key risk: bash logic would need porting to Rust, or the counter would need to shell out — first
  real design tension in this arc; likely the largest of the three candidates.

**S85 = the next mandatory NO-CODE ground truth** (`85 % 5 == 0`) regardless of which candidate is
picked for S84.
