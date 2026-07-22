# Session 96 — CI green: fix the rustfmt 1.9.0 drift

**Type:** CODE (founder-directed after S95 close). **Branch:** `session-96-fmt-drift-fix`.
**PR:** [#97](https://github.com/ifelse-codes/vajra/pull/97). **Cost:** ~$0 (no `vajra claude`).

## Goal — achieved?

**Yes.** `main`'s only red CI step was `cargo fmt --check` on 3 pre-existing drifted files.
Ran `cargo fmt` (zero logic change); CI is now green on both `ubuntu-latest` and `macos-latest`.

## Evidence

- `rustfmt --version` = **1.9.0-stable** (matches CI's `dtolnay/rust-toolchain@stable`).
- `cargo fmt --check` drift set was **exactly 3**: `src/cli/next.rs`, `src/dogfood/mod.rs`,
  `src/stations/mod.rs` — the set flagged at S95 close, unchanged.
- After `cargo fmt`: `cargo fmt --check` exit 0 · `cargo clippy --all-targets -- -D warnings` exit 0
  · `cargo test --lib` **286** pass.
- `git diff --stat main...HEAD` = 3 src files (fmt-only) + `scripts/verify-session-96.sh` +
  `scripts/demo-session-96.sh`. No other code file; no non-`src/` logic change.
- `scripts/verify-session-96.sh` → **4/4 GREEN** (fmt-check, clippy, test-286+, scope-3-src-files).
- **CI (PR #97): green both OS** — `test (ubuntu-latest)` pass 40s · `test (macos-latest)` pass 54s.
- Provable zero-logic: the cold reviewer confirmed `git show main:$f | rustfmt` is **byte-identical**
  to each committed HEAD file for all 3 — rustfmt rewraps whitespace only, so the token stream is
  preserved exactly.

## Fidelity map (every numbered requirement → evidence)

| AC | Requirement | Verdict | Evidence |
|----|-------------|---------|----------|
| 1 | `cargo fmt --check` exits 0 (whole crate) | **SHIPPED** | exit 0 after `cargo fmt`; verify step `fmt-check` PASS |
| 2 | `cargo clippy --all-targets -- -D warnings` exits 0 | **SHIPPED** | exit 0; verify step `clippy` PASS |
| 3 | `cargo test --lib` green (286+) | **SHIPPED** | 286 passed, 0 failed; verify step `test-lib-286plus` PASS |
| 4 | Exactly the 3 known src files; no other code change | **SHIPPED** | `git diff` = 3 src (fmt-only) + 2 session scripts (expected per Delta); rustfmt(main)==HEAD |
| 5 | CI green on both OS | **SHIPPED** | PR #97: ubuntu pass, macos pass |
| Bonus | Coder station PASS (`## Execution` shas filled) | **SHIPPED** | steps 1–5 record commits that exist; `vajra next --stations 96` reports Coder passed (first non-dark since S72) |

**What I did NOT build:** nothing beyond scope — no refactor, no logic, no 4th file. The rustfmt
repo-wide drift (weak item since S91/S93) is now closed.

**Fakest "green" here:** the Coder-station bonus. Steps 1–5 all resolve to existing commits, but
step 5 ("fill Execution shas at closeout") points at the closeout-sync commit — the Coder gate proves
the author *recorded* a real sha per plan step, never that the commit *semantically* performs the
step. For a formatting-only session that mapping is close to trivially true; do not read this as
"the pipeline executed a hard task." (S95's Coder-dark finding is a pattern-break, not eliminated —
S97's paid dogfood is the real test.)

## Independent cold review

`sessions/session-96-review.md` — independent subagent, fed only the prompt + the delivery diff.
**Verdict: ACCEPT.** It independently ran fmt/clippy/test and proved the byte-identical
rustfmt equality (zero-logic is provable, not asserted). AC5/CI noted out-of-band (confirmed green
here). Attested with `Review-Inputs-SHA`.

## Next options (A/B/C)

- **A — S97 DOGFOOD (paid, end-to-end pipeline)** *(pre-locked at S95, prompt exists)*: drive a real
  task through all 8 stations on chitra's dangling S08; goal = high honest K-of-8 with **Coder PASSED**
  live + a Coder-dark diagnosis. *Why:* the 4th-consecutive-GT machinery-vs-payload finding demands a
  payload/dogfood pattern-break, not another guardrail. *Risk:* the S83 headless read-only wall; paid
  (~$0.3–3).
- **B — Prune KNOWLEDGE §6 bloat (NO-CODE-ish docs)**: 416 lines / 69 entries / ~85K tokens; header
  false. *Why:* chronic since S60; cheap; improves every future boot. *Risk:* low leverage vs. the
  pipeline gap; risks losing a load-bearing fact if pruned carelessly.
- **C — Retire stale ROADMAP/STATE weak-items & tidy**: fold now-closed items (rustfmt drift ✅,
  nested-guard ✅). *Why:* keeps the ground-truth surface honest. *Risk:* lowest leverage; deferrable.

**Recommendation: A** — it is the founder's pre-locked pick and the only option that breaks the
easy-green gradient the last four GTs flagged.
