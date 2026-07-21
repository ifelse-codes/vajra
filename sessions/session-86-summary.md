# Session 86 — Harden the attestation check — summary

**Type:** CODE — one shared helper (`attested_hash_outcome`, `src/stations/mod.rs`) replacing a
bare label match at both its call sites. No new module, command, dependency, or CONSTRAINTS.yaml
key. Founder pick A at the S85 ground-truth close (top-ranked, live-exploit-surface finding).

## Headline

`reviewer_status`/`session_attested_accept` accepted any review file containing the LABEL
`Review-Inputs-SHA` anywhere, without ever checking the claimed value — a forged, stale, or
recycled-from-another-session attestation silently passed both the Reviewer and Releaser stations.
Disclosed since S82, re-disclosed S83/S84, reconfirmed unfixed at the S85 GT. **Neither
prompt-suggested design option survived contact with this repo's real history** — both were tested
directly, not assumed, before picking a third approach (see Design section below and the prompt's
own updated `## Design`).

## What shipped

- **`attested_hash_outcome(root, session, review_text) -> AttestOutcome`** — the shared helper both
  `reviewer_status` and `session_attested_accept` now call. Recomputes `sha256(prompt bytes \0
  delivery diff)` — the SAME preimage `verify-closeout.sh#canonical_inputs_sha` commits to — and
  searches every reconstructable diff for one that matches the claimed hash.
- **`candidate_diffs(root)`** — enumerates every (base, tip) pair worth trying: the live
  not-yet-merged branch (`merge-base main HEAD`), plus every `--no-ff` merge commit reachable from
  `main` (`git log --merges --format=%P main`). A `--no-ff` merge preserves both parents forever,
  even after the branch ref itself is pruned (the required S37 end-state) — this is what makes
  historical reads work at all.
- **`diff_hash`/`sha256_hex`** — the exact `verify-closeout.sh` exclude list and NUL-separated
  preimage, shelling out to `sha256sum`/`shasum -a 256` (no new crate dependency, mirroring the
  bash script's own tool-fallback order).
- **`claimed_inputs_sha`/`is_attestation_line`/`extract_hex64`** — extraction anchored to the SAME
  pattern `verify-closeout.sh#check_review_attestation` uses
  (`^[*_\s]*Review-Inputs-SHA[*_\s]*:`), not a bare substring search.
- **`AttestOutcome { NotAttested, Verified, Unverifiable }`** — a 3-way typed result (the S84 house
  pattern: split a conflated case into a distinct variant rather than force a boolean).
  `Unverifiable` fails closed (never PASSES) but is honestly distinct from a confident "forged"
  claim — see Honest limits below.

## Proof

- `bash scripts/verify-session-86.sh` → **16/16 PASS** — builds a REAL temp git repo with genuine
  `--no-ff` merge commits (not mocked) and drives the compiled `vajra` binary end-to-end through
  genuine/forged/recycled/missing/Releaser-fallback cases.
- `cargo test --lib` → **270 passed** (+3 net: 3 new tests, 3 existing tests updated to prove the
  NEW behavior rather than re-assert the old label-only happy path).
- `cargo clippy --all-targets -- -D warnings` and `cargo fmt --check` → clean.
- Scope: `git diff --name-only main -- src/` == exactly `src/stations/mod.rs`. No
  `Cargo.toml`/`Cargo.lock` change.
- **Dogfooded on itself, live:** this session's own `sessions/session-86-review.md`, attested
  while the branch was still open (pre-merge), reads `[PASSED] Reviewer REVIEW — attested ACCEPT
  review, hash verified` under the new classifier — proof the live not-yet-merged-branch candidate
  path works for real, not just in a synthetic fixture.

## Fidelity map (prompt requirement → delivery)

| # | Requirement | Verdict | Evidence |
|---|-------------|---------|----------|
| 1 | Genuine matching hash → PASSED (happy path unchanged) | **SHIPPED** | `reviewer_passes_on_verified_hash_rejects_forged` + live `e2e-genuine-hash-passes` + this session's own dogfooded attestation |
| 2 | Well-formed but WRONG hash → ABSENT (was a silent pass) | **SHIPPED** | New tests + live E2E; independently reproduced on real history: S64/S69/S73/S79 now correctly ABSENT |
| — | (named sub-case) recycled from a different session → ABSENT | **SHIPPED** | `reviewer_absent_when_hash_recycled_from_another_session` + live demo case 2 |
| 3 | No attestation line → ABSENT, unchanged | **SHIPPED** | `reviewer_absent_on_missing_reject_or_malformed_attestation` |
| 4 | `session_attested_accept` shares the fix, no hand-duplication | **SHIPPED** | Both call sites invoke the same `attested_hash_outcome`; only one remaining `.contains("review-inputs-sha")` reference, inside a comment describing the OLD bug |
| 5 | Merge-base fragility (AC5) handled explicitly, not silently reintroduced | **SHIPPED** | Design section records both prompt-suggested options tested and rejected with reproduced evidence; chosen approach's 16/20 real-history split independently re-verified by the cold reviewer |
| 6 | `cargo test --lib` green; tests prove the new behavior | **SHIPPED** | 270 (+3); every fake `"abc123"`/`"abc"` fixture updated to a real computed hash or reclassified as the malformed case it actually is |

**NOT built:** nothing from the prompt was skipped. The independent cold review
(`sessions/session-86-review.md`) confirms all 6 numbered criteria SHIPPED — ACCEPT.

## Honest limits (fakest green, reviewer-sharpened)

- **`Unverifiable` conflates two causes and cannot tell them apart:** a forged/stale/recycled
  attestation (the threat this session targets) and a genuinely-old session whose hash predates a
  change to `canonical_inputs_sha`'s own algorithm/exclude-list (S64, S69, S73, S79 — empirically
  confirmed unreproducible via exhaustive search, not merely untested). Both fail closed as
  ABSENT. This is a deliberate, disclosed trade-off (the constitution's L4: "a check that cannot
  evaluate FAILS"), not a silent bug — but it means 4 historical sessions' Reviewer/Releaser
  dimension will read differently in `--stations` after this session than before.
- **No dedicated test isolates the live not-yet-merged-branch candidate path** in unit-test
  isolation — every new S86 test fixture goes through merge+prune (the harder, historical case).
  The live-branch formula is a verbatim copy of the pre-existing bash algorithm, so risk is low,
  and this session's OWN dogfooded attestation (above) proves the path works for real — but the
  cold reviewer correctly flagged this as a coverage gap, not a functional bug.
- **A pre-existing, S86-independent edge case:** `read_prompt`/`analyst::find_prompt_for` picks
  the first prompt file matching a session's prefix via directory order if more than one exists,
  whereas bash's `canonical_inputs_sha` explicitly fails closed on 0-or->1 matches. Untouched by
  this diff.
- **`candidate_diffs` rescans every merge commit reachable from `main` per query** — cheap today
  (~85 commits, ~2 seconds per session), a scalability note if the repo's session count grows an
  order of magnitude.

## Attestation

- **Review-Inputs-SHA:** `b21c7c5bb2290e7fc31e3a0d73fed75da318331266ab38baade0abfa703139c5`
  (`sha256(prompt ‖ delivery-diff)`; delivery diff = `src/stations/mod.rs` +
  `scripts/verify-session-86.sh` + `scripts/demo-session-86.sh`, per
  `scripts/verify-closeout.sh --inputs-sha 86`). See `sessions/session-86-review.md` for the
  independent cold verdict (ACCEPT).

## Coder-gate execution (plan step → landing commit)

- step 1 (design decision, tested both prompt-suggested options against real history, recorded why
  neither was chosen) → `cd6661b`
- step 2 (shared `attested_hash_outcome` helper, both call sites) → `39a9d58`
- step 3 (test updates + new genuine/forged/recycled coverage + verify/demo scripts) → `39a9d58`

Steps 2 and 3 landed together in one commit — the shared helper and its tests were written and
verified as one coherent unit, disclosed plainly rather than split into artificial commits.

## 3 ranked S87 candidates (post-S86 close)

- **🥇 A (recommended, not picked) — the dogfood refresh:** run a real paid `vajra claude` session.
  Stale since S76 — now **10 sessions (S77-S86) / 18 calendar days** — escalated 🔴 at S85,
  founder-un-parkable per S70. Key risk: real spend, and it's a MEASURE session (no code), so it
  doesn't advance the pipeline's payload counter — but it's the only way to get a live satisfaction
  signal, and the gap keeps widening the longer it's deferred.
- **🥈 B (PICKED) — fill S76's `## Execution` unfilled `<sha>` placeholders:** oldest standing
  debt, 9 sessions overdue, pure record-hygiene (no live exploit surface, unlike what S86 just
  closed). Key risk: matching each Plan step to the right commit requires reading real diffs, not
  just pattern-matching the "(N/4)" commit-message numbering (which does NOT align 1:1 with the
  Plan's step order — flagged explicitly in the S87 prompt).
- **🥉 C — fix `ROADMAP.md`'s stale "Where We Are" table:** quick, cosmetic, concrete evidence for
  the standing readable-roadmap-one-pager pain. Key risk: none material — the lowest-stakes of the
  three, kept deferred two sessions running.

**Founder picked B.** `prompts/87-task-fix-s76-execution-shas.md`. **S90 = the next mandatory
NO-CODE ground truth**, unaffected by which candidate was picked.
