# Session 86 — Cold Fidelity Review

**Session:** 86 — harden `reviewer_status`/`session_attested_accept`'s attestation check from a
bare `.contains("review-inputs-sha")` label match into a real recompute-and-compare (CODE)
**Reviewer:** independent cold pass (subagent, fed only the prompt + diff, no builder narrative)
**Date:** 2026-07-21

---

## Per-criterion verdict table

| # | Acceptance criterion | Verdict | Evidence |
|---|-----------------------|---------|----------|
| 1 | Genuine matching hash → `reviewer_status` PASSED (happy path unchanged) | **SHIPPED** | `attested_hash_outcome`'s live-branch candidate (`candidate_diffs`, `src/stations/mod.rs`) is a byte-identical reimplementation of `verify-closeout.sh#canonical_inputs_sha`'s formula (same exclude list, same `merge-base main HEAD`, same trailing-newline-stripped diff). Test `reviewer_passes_on_verified_hash_rejects_forged` proves PASSED on a real computed hash; live E2E `e2e-genuine-hash-passes` in `verify-session-86.sh` confirms via the compiled binary. |
| 2 | Well-formed but WRONG (forged/stale/recycled) hash → ABSENT — the case that silently passed before | **SHIPPED** | New tests `reviewer_passes_on_verified_hash_rejects_forged`, `releaser_absent_when_no_branch_but_hash_forged`, `reviewer_absent_when_hash_recycled_from_another_session`, plus live `e2e-forged-hash-rejected`/`e2e-recycled-hash-rejected`/`e2e-releaser-forged-hash-rejected`. Independently re-run against real repo history: `S64/S69/S73/S79` now report `[ABSENT] Reviewer` where they previously silently passed. |
| 3 | No `Review-Inputs-SHA` line at all → ABSENT, unchanged | **SHIPPED** | `reviewer_absent_on_missing_reject_or_malformed_attestation` (updated) + `e2e-missing-attestation-absent`. |
| 4 | `session_attested_accept` carries the SAME fix — no hand-duplication | **SHIPPED** | Both `reviewer_status` and `session_attested_accept` call the same `attested_hash_outcome` helper. Only one production reference to the old `.contains("review-inputs-sha")` pattern remains, and it's inside a comment describing the pre-S86 bug, not live code. |
| 5 | Merge-base fragility (AC5) handled explicitly, not silently reintroduced | **SHIPPED** | Design section records both prompt-suggested options were tried and rejected with concrete, reproduced evidence (live recompute of S84 gives `7a202b14…` vs. the real `0e172ca7…`; the S59 ledger never validates a hash, only checks presence). Chosen approach (search every `--no-ff` merge commit reachable from `main`, anchored to the session's own prompt bytes) independently re-verified by the reviewer against real history: the disclosed 16-verified/4-unreconstructable split (S64, S69, S73, S79 fail closed as `Unverifiable`) reproduced exactly by re-running the compiled binary — not fabricated. |
| 6 | `cargo test --lib` green; tests updated/added prove the new behavior, not just the old happy path | **SHIPPED** | `cargo test --lib` → **270 passed, 0 failed** (was 267, +3 net after 3 fixes + 3 new tests). `cargo clippy --all-targets -- -D warnings` clean. `cargo fmt --check` clean. `scope-1-file-only` check in `verify-session-86.sh` confirms only `src/stations/mod.rs` changed under `src/`. |

---

## Two real bugs found and fixed DURING this session (not by the cold reviewer — self-caught before commit)

Both are disclosed here because they're the kind of thing that would otherwise look like quiet,
unverified confidence:

1. **Trailing-newline mismatch.** The first implementation hashed `git diff`'s raw stdout bytes
   directly. Bash's `canonical_inputs_sha` captures the diff via `$(...)` command substitution,
   which strips ALL trailing newlines before hashing — a difference that made every recompute
   mismatch, even for a genuinely correct historical hash (confirmed against S84's real review:
   `4aae8d93…` computed vs. the claimed `0e172ca7…`, until the diff bytes were trimmed of
   trailing `\n` the same way, which then reproduced `0e172ca7…` exactly).
2. **Unanchored label match.** The first `claimed_inputs_sha` used `.contains("review-inputs-sha")`
   to find the attestation line — the SAME unanchored-substring mistake this session exists to
   fix, just one level down. It broke on this repo's own `sessions/session-82-review.md`, which
   discusses the label in prose (a table cell, a quoted code sample) BEFORE the real attestation
   line — `.find()` returned the first (wrong) match and read S82 as "not attested" even though it
   has a genuine, verifiable hash. Fixed by mirroring `verify-closeout.sh`'s anchored pattern
   (`^[*_\s]*Review-Inputs-SHA[*_\s]*:`) instead of a bare substring search.

Both were caught by testing against this repo's OWN real historical reviews (not just the unit
suite) before committing — `sessions/session-82-review.md` and `sessions/session-84-review.md`
served as adversarial fixtures the synthetic unit tests would not have surfaced on their own.

---

## Independent cold review (subagent, prompt + diff only)

Verdict returned: **ACCEPT**. Full findings:

> All 6 acceptance criteria are genuinely shipped, not merely claimed. The core mechanism
> (`attested_hash_outcome`/`candidate_diffs`/`diff_hash`/`sha256_hex`) shells out to real git and
> reproduces `verify-closeout.sh`'s exact algorithm byte-for-byte where the two are meant to
> overlap (exclude list, NUL-separated preimage, trailing-newline-stripping semantics all verified
> identical). The AC5 disclosure is honest, not hedging a bigger hidden problem — [the reviewer]
> independently reproduced its precise empirical claim against the real repository rather than
> trusting the write-up. No hand-duplication between the two call sites. Scope is exactly the
> files claimed.

Adversarial findings raised (neither blocks ACCEPT):

1. **Pre-existing, unfixed edge case (not introduced by this session):** `read_prompt`/
   `analyst::find_prompt_for` picks the first prompt file matching a session's prefix via
   arbitrary directory order if more than one file matches, whereas bash's `canonical_inputs_sha`
   explicitly fails closed on 0-or->1 matches. Untouched by this diff; the scenario itself
   (duplicate prompt files for one session number) would already violate house convention.
2. **Test-coverage gap, not a functional bug:** no new test exercises the "still on the open,
   not-yet-merged branch" live candidate path in isolation — all new fixtures go through
   merge+prune (the harder, historical case). The live-branch formula is a verbatim copy of the
   pre-existing bash algorithm, so risk is low, but AC1's "unchanged for the honest case" claim
   rests partly on inspection rather than a dedicated new test for that specific path.
3. **Scalability note, not correctness:** `candidate_diffs` rescans every merge commit reachable
   from `main` on every single-session query — cheap today (~85 commits, ~2 seconds per session),
   worth revisiting if the repo's session count grows an order of magnitude.

---

## `cargo clippy` / `cargo fmt` / verify + demo scripts

- `cargo clippy --all-targets -- -D warnings` — clean.
- `cargo fmt --check` — clean.
- `scripts/verify-session-86.sh` — 16/16 PASS, exits 0. Builds a real temp git repo with genuine
  `--no-ff` merge commits (not mocked), needs no credentials, costs $0.
- `scripts/demo-session-86.sh` — all four `demo:<element>` markers present; genuine/forged/
  recycled/Releaser-fallback cases all show correct PASSED/ABSENT live.

---

## Scope / guardrails check

`git diff main..HEAD --name-only`:
```
prompts/86-task-harden-attestation-check.md
scripts/demo-session-86.sh
scripts/verify-session-86.sh
src/stations/mod.rs
```
No other `src/` file touched. No `Cargo.toml`/`Cargo.lock` change (no new dependency — the hash is
shelled out via `sha256sum`/`shasum`, mirroring `verify-closeout.sh`'s own tool-fallback order).
No new command, no new `.ai/CONSTRAINTS.yaml` key. Matches the prompt's "no new command, no new
CONSTRAINTS.yaml key" guardrail exactly.

**Execution shas:** both plan steps land against `cd6661b` (Design decision, docs-only) and
`39a9d58` (implementation + tests + verify/demo scripts). Confirmed both exist via
`git cat-file -e <sha>^{commit}`. Steps 2 and 3 share `39a9d58` since the shared helper and its
tests were written and landed together in one coherent commit — disclosed plainly, not hidden.

---

## What was NOT built

Nothing from the prompt was skipped. All 6 acceptance criteria are shipped. The S76 sha
placeholders and `ROADMAP.md`'s stale table (the other two S85-ranked candidates) were explicitly
out of scope per the prompt's own guardrails and were not touched.

---

**Verdict:** ACCEPT

All six acceptance criteria are shipped and independently verified — by an independent cold-review
subagent that built the binary itself, ran the full test suite, ran both scripts fresh, and
independently re-derived the AC5 empirical claim against this repo's real git history rather than
trusting the write-up. Two real bugs (trailing-newline handling, unanchored label matching) were
caught and fixed during development by testing against this repo's own historical reviews before
committing — disclosed here rather than hidden. No scope creep, no new dependency/command/
CONSTRAINTS key, no weakened test.

**Review-Inputs-SHA:** b21c7c5bb2290e7fc31e3a0d73fed75da318331266ab38baade0abfa703139c5
