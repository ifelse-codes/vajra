# Session 91 Summary — Fix S89 Reviewer hash mismatch + `--dogfood-age` live query

**Date:** 2026-07-21
**Type:** CODE (B+C — founder-approved combination like S39 A+B)
**Branch:** `session-91-fix-attestation-and-dogfood-staleness`
**Prompt:** `prompts/91-task-fix-attestation-and-dogfood-staleness.md`

## Fidelity Table

| AC | Description | Verdict |
|---|---|---|
| 1 | `vajra next --stations 89` Reviewer PASSED (not ABSENT-by-hash-mismatch) | **SHIPPED** |
| 2 | Fix is general — intermediate commits enumerated for all historical sessions | **SHIPPED** |
| 3 | `--dogfood-age` prints sessions-since + calendar-days + git-derived source declaration | **SHIPPED** |
| 4 | Output names last paid session (S76) + git-derived ISO date (2026-07-18) | **SHIPPED** |
| 5 | `cargo test --lib` ≥ 271 tests | **SHIPPED** (283, +12 new) |
| 6 | Cold independent review: ACCEPT | *see session-91-review.md* |

**All 5 AC-coded deliverables: SHIPPED.**

## What Shipped

**B — Fix `candidate_diffs()` to enumerate intermediate commits** (`src/stations/mod.rs`):
- Root cause: S89 had 5 commits; `--inputs-sha` computed at intermediate commit `bcc675f`/`af8bcbf`
  before final closeout commit `fffb6ac` modified the prompt (added execution shas). Rust
  reconstruction used the tip with its modified prompt bytes → hash mismatch.
- Fix: for each historical merge's `(p1, p2)` pair, enumerate ALL commits in `base..p2` via
  `git log --format=%H base..p2`, adding `(base, intermediate)` as additional candidates.
  Generalises to any session where `--inputs-sha` was computed before the final prompt edit.
- New test: `reviewer_passes_when_hash_computed_at_intermediate_branch_commit` (+1 station test).

**C — `vajra next --dogfood-age`** (`src/dogfood/mod.rs` + `src/lib.rs` + `src/cli/next.rs`):
- Scans `sessions/session-NN-artifacts/` for `receipt.stderr.txt` or `vajra-receipt.txt`
  (S76/S63 full-run pattern); excludes `live-*` prefixes (S78 smoke tests).
- Date derived via `git log --follow --format=%ai --diff-filter=A` on the artifact file — never
  read from STATE.md.
- Cost from `sessions/session-NN-artifacts/run-result.json` (`total_cost_usd`) when present.
- Julian Day Number arithmetic for calendar-days (no external crates).
- 11 new dogfood tests.
- Live output: S76 · 2026-07-18 (git-derived) · 14 sessions · 3 calendar days.

**CONSTRAINTS.yaml** — added `dogfood_staleness` to `required_audits` (now 10 audits) with
`dogfood_staleness_questions` block (run `--dogfood-age`, compare to STATE.md, flag drift).

## Fakest Green

`candidate_diffs()` adds O(n·k) candidates (n = merge commits, k = commits per branch). The fix
works for S89 because the intermediate commit exists and the diff from that base matches the hash.
But: if a session computed `--inputs-sha` AFTER merging to main (not before), the merge commit's
p2 is already the final tip — no intermediate candidate helps. That is a different root cause and
would still appear ABSENT. Disclosed.

Also: `--dogfood-age` detects sessions by `receipt.stderr.txt` or `vajra-receipt.txt` presence.
If a future paid run uses a different artifact naming, it will be missed. The naming convention is
not enforced at the protocol level — it's a fragile grep-based convention. Disclosed.

## Commits

| SHA | Description |
|---|---|
| `720cc44` | S91 (B): fix Reviewer ABSENT on intermediate-commit attestation |
| `aaf56ff` | S91 (C/1): add `vajra next --dogfood-age` live staleness query |
| `a7e7ecb` | S91 (C/2): CONSTRAINTS.yaml — add dogfood_staleness to required GT audits |
| `b1893dd` | S91: verify + demo scripts + execution trace |
