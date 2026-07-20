# Session 83 — Cold Fidelity Review

**Session:** 83 — warn before a headless read-only run (CODE)
**Reviewer:** independent cold pass (subagent, fed only the prompt + diff, no builder narrative)
**Date:** 2026-07-20

---

## Per-requirement verdict table

| # | Requirement | Verdict | Evidence |
|---|-------------|---------|----------|
| 1 | Headless + no permission flag → stderr warning BEFORE `claude` is spawned | **SHIPPED** | `src/cli/launch.rs:37-39` fires `eprintln!` strictly before `merge_hook_settings()`/`command.spawn()` (spawn only happens inside `wait_and_meter`). Confirmed live against a stub `claude` binary: `vajra claude -p "do a thing"` prints the warning before the stub runs. Unit test `should_warn_readonly_headless_matrix` and verify check `ac1-headless-no-flag-warns` both green. |
| 2 | `--dangerously-skip-permissions` present → no warning | **SHIPPED** | `has_permission_flag` (`launch.rs:94-97`) exact-token-matches it; test + verify check `ac2-skip-permissions-silent` PASS; manually confirmed no output. |
| 3 | `--permission-mode <mode>` present → no warning, any mode | **SHIPPED** | Function checks only for the flag token, not its value; tested with two different values (`"plan"`, `"acceptEdits"`); verify `ac3-permission-mode-silent` PASS. |
| 4 | Interactive (no `-p`/`--print`) → never warns, regardless of permission flags | **SHIPPED**, coverage gap noted | `should_warn_readonly_headless` short-circuits on `is_headless(args)` first, so a permission flag cannot trigger a warning without `-p`/`--print` also present — structurally impossible. Manually verified the specific "interactive + permission-flag-present" combination the AC calls out: no warning, exit 0. **Gap:** no unit test, demo case, or verify check exercises that exact combination — the AC4 test cases are only `&[]` and `&["--model","opus"]`, neither containing a permission flag. Behavior is correct; the "tests cover ACs 1-4 directly" claim is a hair looser than advertised for this sub-case. |
| 5 | Advisory only: no exit-code change, no block, no `args` mutation | **SHIPPED** (code-level) | `command.args(args)` passes the original untouched slice at both call sites; the warning branch is a bare `if cond { eprintln!(...) }` with no `return`/`process::exit`, so it cannot alter control flow by construction. |
| 6 | `cargo test --lib` stays green; new tests mirror `is_headless_detects_print_flags_only`'s style | **SHIPPED** | Ran directly: `test result: ok. 263 passed; 0 failed`. Both new tests present, same exact-token/no-substring style as the existing test. |

---

## Fakest green

**`ac5-advisory-exit-code-untouched` in `scripts/verify-session-83.sh`** is a near-tautology, not a real proof. The stub `claude` binary is `exit 0` unconditionally, so both invocations under test (with and without `--dangerously-skip-permissions`) are guaranteed to return 0 regardless of whether the warning logic does anything at all. It would only catch a bug blunt enough that reading the 3-line diff would already reveal it — it proves nothing about a real nonzero-exit Claude Code process propagating correctly. The AC5 property does hold (confirmed by reading the code: the warning branch has no control-flow effect), but this specific verify check is decorative, not load-bearing.

---

## Other defects (low severity)

1. AC4's "interactive + permission-flag-present" sub-case is never exercised by any test/demo/verify case, only manually confirmed by this review. Behavior is correct; the coverage claim is slightly overstated.
2. `has_permission_flag_detects_either_flag_exact_token`'s substring/exact-token negative case only tests `--permission-mode` buried in a value string, not `--dangerously-skip-permissions` — same `==` mechanism covers both, so this is an asymmetry in test thoroughness, not a functional gap.

---

## Guardrails / scope check

`git diff main...session-83-readonly-headless-warning --stat` touches only `prompts/83-task-readonly-headless-warning.md`, `scripts/demo-session-83.sh`, `scripts/verify-session-83.sh`, and `src/cli/launch.rs` — no `src/gate_run.rs`, no QA/Demo-er cannot-evaluate typing. No `Cargo.toml`/`Cargo.lock`/`CONSTRAINTS.yaml` diff — no new dependency, command, or governance key. `cargo clippy --all-targets -- -D warnings` and `cargo fmt --check` both clean on an independent rerun. `scripts/verify-session-83.sh` reruns 11/11 green on a fresh execution, not just the builder's log.

---

## What was NOT built

Nothing from the prompt was skipped. Both footnotes above are verification-quality gaps (a behavior that is correct but under-tested), not delivery gaps — no acceptance criterion is unmet.

---

**Verdict:** ACCEPT

All six acceptance criteria are shipped and independently verified by running the real code (not trusting the diff or the builder's claims): unit tests, `cargo test --lib` (263, +2), `clippy`, `fmt`, and a live E2E run of the warn/no-warn matrix against a stub `claude` binary. No functional bugs, no scope creep, no silent enforcement creep (no new exit path, no CONSTRAINTS.yaml key, no waiver mechanism added).

**Review-Inputs-SHA:** 7b15529e8ae709e53d2bf745ad73c4642897d2ecc8267d1e0c4764139accd075
