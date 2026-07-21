# Session 88 — Cold Fidelity Review

**Session:** 88 — hash a review-time snapshot of the prompt, not its live bytes (CODE)
**Reviewer:** independent cold pass (subagent, fed only the prompt + diff, no builder narrative)
**Date:** 2026-07-21

---

## Two-pass review (the S67/S87 house pattern: reject → fix in-session → fresh independent re-verify)

### Pass 1 — REJECT

The core fix — both hashing call sites (`src/stations/mod.rs#attested_hash_outcome`,
`scripts/verify-closeout.sh#canonical_inputs_sha`) — was judged genuinely correct: the reviewer
independently reverted the Rust fix in an isolated worktree and confirmed the new regression test
(`reviewer_stays_verified_after_a_later_session_edits_the_same_prompt_file`) actually fails without
it; independently ran a full 26-session historical scan (old binary vs. new) and got the identical
split this session reports; independently confirmed via `git log --follow` that S73 and S79 were
real, previously-undiagnosed victims of the same bug (the "bonus finding").

But the session's OWN proof of one specific acceptance criterion was hollow:

1. **AC3's bash-side fixture (`bash_emit_verify_pairing_survives_stray_edit`,
   `scripts/verify-session-88.sh`) passed unconditionally, regardless of whether the fix was
   present.** The fixture used a single-digit session number (`5`). `check_review_attestation`
   (pre-existing code in `verify-closeout.sh`, not touched by this session's fix) looks up
   `sessions/session-${N}-review.md` with an UNPADDED `$N`, while every emit path in this
   codebase — including this fixture — zero-pads (`session-05-review.md`). With `N=5` the two
   strings never match, so the lookup always fell through to `N/A: no review file` → an
   unconditional `ATTEST: PASS`. The reviewer proved this empirically by reverting the bash fix
   entirely and re-running the identical fixture: identical `PASS` output, before and after.

The underlying bash fix (`git show HEAD:path` instead of `cat`) was independently confirmed
correct by the reviewer using a realistic 2-digit fixture number of their own — the bug was
entirely in this session's OWN test, not the fix. A secondary, non-blocking gap was also flagged:
AC2's "state the split plainly" was only spot-checked against 5 of 26 sessions, with no artifact
stating a headline number.

### In-session fix (commit `0640862`)

- `scripts/verify-session-88.sh`: fixture switched to a 2-digit session number (`95`, where
  zero-padded and unpadded forms coincide) so `check_review_attestation`'s lookup actually
  succeeds; added an explicit **negative control** — the identical fixture run against a genuine
  pre-fix `verify-closeout.sh` (checked out via `git show main:...`) must FAIL after the stray
  edit, proving the check discriminates fixed-vs-broken code rather than always printing PASS.
- **A second, unrelated gotcha surfaced live while rebuilding this check:** `cmd | grep -q
  pattern` under `set -euo pipefail` triggers the documented S32 SIGPIPE/pipefail false-RED
  (`grep -q` closes the pipe on its first match → the upstream `bash verify-closeout.sh` process
  receives SIGPIPE → exits 141 → `pipefail` reports the whole pipeline failed even though `grep`
  matched). Confirmed via `PIPESTATUS=(141 0)`. Fixed via the established capture-then-grep
  pattern (`out=$(cmd); grep -q pattern <<<"$out"`).
- Added `full_historical_scan`: a new check that sweeps all 26 real `ACCEPT` reviews (not a
  5-session spot-check) and prints an explicit `HISTORICAL SCAN: 22 Verified / 4 Absent … out of
  26` headline. `demo-session-88.sh` updated to read this from the verify script's own artifact
  log (`.ai/verify/session-88/latest/full-historical-scan-split-reported.log`) rather than
  `grep`-ing stdout — avoiding the same SIGPIPE class a second time — and to capture the full
  verify run once instead of re-invoking it per demo case.

### Pass 2 — ACCEPT

The SAME reviewer re-verified the fix adversarially, independently, not trusting the delivered
script's own report:

- Manually reproduced the full N=95 fixture step-by-step outside the script (positive control →
  negative control against a real `git show main:scripts/verify-closeout.sh` checkout → final
  assertion), with `set -x` tracing every command. Confirmed the three-way sequence is real and
  discriminating: positive control PASSes, negative control genuinely FAILs against the real
  pre-fix code, and the actual fix PASSes despite the stray edit.
- Independently reproduced the SIGPIPE/pipefail claim with a standalone synthetic pipeline
  (`PIPESTATUS=(141 0)`) — confirmed it is a real, general bash behavior, not a fabricated
  justification.
- Independently re-read the historical-scan artifact log and re-verified the arithmetic (22
  Verified / 4 Absent / 26) matches their own pass-1 independent count, with each of the 4
  "Absent" sessions individually attributable to a genuinely different, disclosed cause (2
  NotAttested pre-attestation-era sessions, 2 genuinely-unreconstructable Unverifiable sessions).
- Re-ran `cargo test --lib` (271 pass), `cargo clippy --all-targets -- -D warnings` (clean),
  `cargo fmt -- --check` (clean) directly, confirming no regression from the fixture-only change.
- Re-confirmed scope: same 5 files as pass 1, no new CLI surface, no `CONSTRAINTS.yaml` change.
- Flagged one non-blocking nit: `full_historical_scan`'s pass bar is `[ "$verified" -ge 16 ]` (a
  floor, not a strict zero-regression assertion) — acceptable given the reviewer's own pass-1
  binary diff already proved zero regressions and the underlying Rust logic is unchanged in the
  fix commit, but worth hardening in a future session.

---

## Final Acceptance Criteria

| # | Acceptance criterion | Verdict | Evidence |
|---|-----------------------|---------|----------|
| 1 | A later session's edit no longer un-attests an earlier one | **SHIPPED** | Reviewer independently reverted the Rust fix in an isolated worktree and confirmed the new regression test genuinely fails without it; confirmed `--stations 76` flips live against this repo's real history. |
| 2 | Historical scan re-run, split stated plainly, S76 confirmed flipped to Verified | **SHIPPED** | Was reporting-gap-flagged in pass 1 (5-session spot-check, no headline artifact) — now an explicit, artifact-logged `HISTORICAL SCAN: 22 Verified / 4 Absent … out of 26` line, independently arithmetic-reverified by the reviewer against their own pass-1 count. |
| 3 | Live-branch emit/verify pairing survives an uncommitted stray edit | **SHIPPED** | Was PARTIAL/hollow-green in pass 1 (a single-digit fixture number silently defeated by an unrelated pre-existing padding bug, printing an unconditional PASS). Fixed with a 2-digit fixture + an explicit negative control; reviewer independently reproduced the full positive/negative/positive sequence by hand in pass 2, outside the delivered script. |
| 4 | `cargo test --lib` green with a genuine, non-hollow regression test | **SHIPPED** | Reviewer independently reverted the fix and confirmed the specific new test fails without it; re-confirmed 271 pass / clippy clean / fmt clean directly (not just via the verify script) in pass 2. |
| 5 | Scope held to the two hashing call sites + tests | **SHIPPED** | `git diff --name-only main..HEAD` re-checked in pass 2: same 5 files as pass 1, no `src/cli`, no `CONSTRAINTS.yaml` change, hash preimage shape unchanged. |

**Verdict:** ACCEPT

**Review-Inputs-SHA:** `493282c7aa59d563000cf5becf87e1c80951764f915b54bfaf95f871982afbef`
