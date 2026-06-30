# Session 29 — Propagate the one-session-per-chat guard into `vajra init`

**Type:** CODE · **Branch:** `session-29-session-guard-propagation` · **PR:** [#21](https://github.com/ifelse-codes/vajra/pull/21) — open (merge after closeout)

## Goal achieved? — YES

Closes the **second half** of the S28 split. A freshly-`init`ed project now inherits the S26 one-session-per-chat guard (S28 already shipped Darshan). One artifact, four wiring points, the proven S22/S28 `include_str!` pattern.

## What shipped

| Wiring point | Change in `src/cli/init.rs` |
|---|---|
| The hook | `TPL_HOOK_SESSION_GUARD = include_str!("../../scripts/hook-session-guard.sh")` + emitted executable (byte-identical) |
| Settings | guard added to `.claude/settings.json` PreToolUse(Bash), beside the co-pilot (one matcher, two hooks) |
| The gate | `one_session_per_chat: true` in `TPL_CONSTRAINTS` `session:` block |
| Gitignore | new `TPL_GITIGNORE` → ignores `.ai/.session-owner` (the owner record) |

`Cargo.toml`: `!scripts/hook-session-guard.sh` un-exclude so `cargo install` compiles (verified via `cargo package --list`). Scaffold **18 → 20 files** (`.gitignore` + guard hook).

## Evidence

- `scripts/verify-session-29.sh` → **ALL GREEN (19/19)** — rust gates, 4 new scaffold tests, hook-in-cargo-package, real `vajra init` into a temp repo, the scaffolded guard **actually blocks** N→N+1 in the same chat (exit 2), S22 co-pilot + S28 Darshan regressions.
- `scripts/demo-session-29.sh` — fresh project (20 files) inherits + enforces; live block shown.
- `cargo fmt` ✓ · `clippy -D warnings` ✓ · 98 lib tests (4 new) ✓.
- The S22 co-pilot fired live on this session's own `git commit` (dogfood).

## Decisions / guardrails

- No 8th command · no new dep · no `src/` guard logic (embed-only, never spawned — contrast the co-pilot, which `first_run_aha` spawns) · ≤3 files/commit (feature + proof split) · 1 story · 2 assumptions held (new `.gitignore` file; guard rides the existing Bash matcher).

## Next — S30 is the MANDATED ground-truth (NO-CODE, `NN % 5 == 0`)

S30 cannot be a code session. The three options below are **lead lenses** for that audit (drawn from ROADMAP carry-forwards); the audit runs all required audits regardless, but you pick what it pressure-tests first.

### A. Founder-satisfaction gate (Recommended)
- **Goal:** Decide whether Vajra-on-Claude is now "satisfying" — the S26 gate that parks the second agent.
- **Why pick this:** Three propagation sessions (S27–S29) all served "make Claude satisfying"; the gate is the founder's call and unblocks everything downstream.
- **Key risk:** A "yes" promotes the second agent (big scope); a "no" risks more Claude polish that S25 already flagged as spent leverage.

### B. Cross-agent breadth audit
- **Goal:** Re-test the S25 north-star finding — is Claude-only still the right focus, or is vendor-neutrality starving?
- **Why pick this:** The only differentiating wedge pillar still has zero code; the dashboard stays green while the gap may widen.
- **Key risk:** Re-litigates the S26 founder override; could thrash direction without new evidence.

### C. Propagation-completeness + dogfood-readiness
- **Goal:** Confirm the loop (co-pilot + Darshan + guard all in `init`) is whole, and audit readiness to dogfood on a real project.
- **Why pick this:** Propagation is now complete (S22→S29); the backlog dogfood session is the natural validator.
- **Key risk:** Dogfooding is a code/usage session — the GT can only tee it up, not run it.
