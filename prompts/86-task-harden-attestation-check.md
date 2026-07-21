# Session 86 — Harden the attestation check: recompute, don't `.contains()` (CODE)

> **Status:** APPROVED (founder pick A at S85 GT close).
> **Type:** CODE — a Rust classifier hardening in `src/stations/mod.rs`, no new module, no new
> command. Likely design-adjacent (reads the S59 ledger) — see Design section; precedent = S82
> (also a ledger-read fix, also design-significant: no).

## Goal

`src/stations/mod.rs`'s `reviewer_status` (line ~279) and `session_attested_accept` (line ~362,
the Releaser's `NoBranch` fallback added S82) both classify an ACCEPT review as "attested" via:

```rust
let attested = text.lines().any(|l| l.to_lowercase().contains("review-inputs-sha"));
```

This checks only that the **label** `Review-Inputs-SHA` appears somewhere in the file — it never
reads the claimed hash value, and never recomputes or compares it. Contrast
`scripts/verify-closeout.sh#check_review_attestation`, which does this correctly: it extracts the
claimed 64-hex-char value, recomputes `canonical_inputs_sha()` (sha256 of the prompt file bytes +
the merge-base diff, excluding closeout-synced paths) live from git, and BLOCKs on any mismatch —
missing, forged, stale, or recycled attestations all fail.

**The gap:** a review file with `**Review-Inputs-SHA:** deadbeefdeadbeef...` (any 64 hex chars, or
even just the label with garbage after it) satisfies the Rust classifier's `.contains()` check —
`vajra next --stations NN` and `vajra next --stations NN`'s Reviewer/Releaser dimensions would
report **PASSED** for a session whose attestation the real closeout gate would have BLOCKED. This
is load-bearing for 2 stations (Reviewer directly, Releaser via the `NoBranch` fallback) and has
been disclosed-not-fixed since S82, re-disclosed S83/S84, reconfirmed unfixed at the S85 GT
(`sessions/session-85-ground-truth.md`).

**Fix:** make both classifiers verify the actual hash, not just the label's presence.

## Why this session

Ranked 🥇 for S86 by the S85 ground-truth audit (`sessions/session-85-ground-truth.md`) — re-ranked
**above** the older-standing S76 sha-placeholder fix specifically because this is a **live,
currently-exploitable weakness in an active governance gate** (a forgeable string fools a station
that's supposed to prove independent, attested review), not a historical record-keeping gap. It has
now stood disclosed across 3 CODE sessions (S82, S83, S84) plus this GT — the S85 GT's lens-A
finding was explicit: "disclosed, not hidden" stopped being sufficient cover at 3 sessions.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)

1. **WHEN** a review file has a well-formed `**Review-Inputs-SHA:** <hash>` line whose value
   matches the canonical recomputed hash for that session **THEN** `reviewer_status` reports
   PASSED — unchanged from today's behavior for the honest case.
2. **WHEN** a review file has the `Review-Inputs-SHA` label present but the value is WRONG (forged,
   stale, or recycled from another session) **THEN** `reviewer_status` reports ABSENT (or a status
   distinctly naming the mismatch) — this is the case that silently passes today and must not
   after this fix.
3. **WHEN** a review file has no `Review-Inputs-SHA` line at all **THEN** behavior is unchanged
   (ABSENT — "ACCEPT review not attested"), same as today.
4. `session_attested_accept` (the Releaser `NoBranch` fallback, S82) carries the same fix — not
   just `reviewer_status`. Both call sites must stop accepting a bare label match.
5. **Merge-base fragility is handled explicitly, not silently wrong.** `verify-closeout.sh`'s own
   `canonical_inputs_sha()` depends on `git merge-base main HEAD`, which the S83 finding already
   proved collapses once a session's branch is merged and pruned — the exact state every
   historical session is in by the time `--stations` reads it. Recomputing that same live git diff
   from Rust would hit the identical collapse for every past session. State plainly in the Design
   section which of the two known-sound alternatives (below) was chosen, and why the chosen one
   does NOT silently degrade back to a label-only check for historical sessions.
6. `cargo test --lib` stays green; existing `reviewer_status`/`session_attested_accept`/
   `--stations` tests are updated to prove the NEW behavior (a forged-hash case must be asserted
   ABSENT, not just re-asserting the old happy path). At least one new test proves a
   wrong-but-present hash is rejected.

## Why this session

(see above)

## Design (the Architect gate — recorded rationale)

Two known-sound directions exist; pick one and record why:

- **(a) Recompute `canonical_inputs_sha` logic from Rust, live, at read time.** Faithful to
  `verify-closeout.sh`'s existing algorithm (prompt bytes + merge-base diff, sha256). **Known
  problem (AC5):** `git merge-base main HEAD` collapses post-merge (S83 finding) — this would make
  the Rust check degrade back to unverifiable (or falsely ABSENT) for every already-merged
  historical session, which is most of what `--stations` reads. Would need a documented,
  deliberate choice about what happens when the merge-base can't be recovered (fail closed?
  fall back to label-only with a visible caveat? something else) — do not let this collapse
  silently reintroduce today's bug under a different name.
- **(b) Read the ALREADY-COMPUTED hash from the S59 attested-verdict ledger** (`--ledger`,
  `record_hash = sha256(prior ‖ N ‖ verdict ‖ input_sha)`, DECISION-004) instead of recomputing
  live. The ledger is durable — it doesn't depend on a live merge-base that can vanish post-prune.
  This mirrors the **S82 house pattern exactly**: "when a derived counter dimension goes
  structurally-always-[wrong] because its PRIMARY evidence source decays over time, fix it with a
  SECONDARY evidence fallback from another already-trusted store" — the ledger is that store here,
  same as it was for S82's Releaser fix. Tradeoff: only covers sessions that ran `--ledger` at
  closeout (check whether that's already mandatory or still opt-in per ROADMAP's S59 entry before
  assuming full coverage).

Recommend (b) given the direct precedent and the AC5 fragility risk in (a), but this session's own
Architect step makes the final call with the actual ledger-coverage facts in hand.

### Decision actually made: neither (a) nor (b) as literally written — a third, empirically-tested
approach

Both were tried against THIS repo's real history before picking, not assumed:

- **(a) live recompute** was tested directly: `git merge-base main HEAD` for a real merged session
  (S84) run today, on main, does NOT fail closed — it silently computes a DIFFERENT, WRONG hash
  (base collapses to HEAD, diff goes empty), which would have made the classifier falsely reject
  nearly every historical ACCEPT this repo already has. Confirmed, not assumed: recomputing S84's
  hash this way today gives `7a202b14…`; the review's real claim is `0e172ca7…`.
- **(b) reading the S59 ledger** was inspected directly (`scripts/verify-closeout.sh#_ledger_sha_of`
  /`build_ledger`): the ledger's "ATTESTED" column only records whether a well-formed 64-hex value
  is PRESENT — it never calls `canonical_inputs_sha` or compares anything. Reading it would upgrade
  the check from "label present" to "well-formed value present," but a well-formed **wrong** value
  (AC2's forged/recycled case) would still pass. (b) does not satisfy AC2 as written.

**What was actually built:** recompute-and-compare, but searching every RECONSTRUCTABLE diff
instead of trusting one (possibly-pruned) branch ref — the live not-yet-merged branch AND every
`--no-ff` merge commit reachable from `main` (this repo's merge convention preserves both parents
forever, even after the branch ref is deleted). The claimed hash is anchored to the session's OWN
prompt bytes, so a value recycled from a different session's genuine hash cannot match (different
preimage) without a SHA-256 collision. **Empirically validated against this repo's real history**
(not merely unit-tested): searched all 20 currently-committed ACCEPT reviews — 16 reproduce exactly
via a merge commit's parents; 4 (S64, S69, S73, S79) reproduce under NO candidate, even after
exhaustively searching every merge commit in the repo's history — most plausibly because
`canonical_inputs_sha`'s own exclude-list/algorithm changed since their hash was computed, not
forgery. Those 4 correctly read as `Unverifiable` (fails closed) under the new check; this is a
disclosed, deliberate trade-off (AC5), not a silent bug reintroduction — a garbage/forged/recycled
value can no longer silently PASS, which is the property this session exists to deliver.

design-significant: **no** (precedent: S82's Releaser ledger-fallback fix, same shape of change,
was also marked not design-significant). The chosen approach reads existing git history and the
existing prompt file — no new crate dependency, no new store, no new command, no ADR-level change
to Vajra's own architecture; it hardens an existing internal classifier's correctness.

## Plan (ordered steps — cite the acceptance criteria each step covers)

1. Decide (a) vs (b) per the Design section, using the actual current ledger-coverage state (does
   every closed session have a ledger entry, or only some?). Record the decision and why. `covers: 5`
2. Implement the chosen verification in a shared helper (both `reviewer_status` and
   `session_attested_accept` must call the SAME logic — no hand-duplication). `covers: 1, 2, 3, 4`
3. Update every existing test asserting the old label-only behavior; add new test(s) proving a
   forged/wrong-but-present hash is rejected and a genuinely matching hash still passes. `covers: 6`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>

## Guardrails

- **One story:** the attestation hash-check hardening only. Do NOT touch the S76 sha placeholders
  or `ROADMAP.md`'s stale "Where We Are" table (the other two S85-ranked candidates, not picked
  this session).
- **No new command, no new CONSTRAINTS.yaml key.** This tightens an existing classifier's
  correctness; it is not a new governance rule.
- **Do not let AC5's fragility ship silently.** If the chosen fix still degrades to a weaker check
  under some condition (e.g. a session with no ledger entry), that condition and its resulting
  behavior must be stated plainly in the summary's fidelity table — the exact "disclosed, not
  hidden" standard this session exists to raise.
- **S87 is a normal CODE session** (`87 % 5 != 0`) — no forced GT.

## Delta (the Analyst gate — what this session ADDS to the governed pipeline)

- `+` `reviewer_status`/`session_attested_accept` verify the actual attested hash instead of a
  bare label match — closes a live weakness in 2 governed stations (Reviewer, Releaser), disclosed
  since S82, standing 3 sessions before this fix.
