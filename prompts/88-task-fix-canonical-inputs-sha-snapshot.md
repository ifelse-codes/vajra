# Session 88 — Hash a review-time snapshot, not the live prompt file (CODE)

> **Status:** APPROVED (founder pick A of 3 ranked candidates at S87 close).

## Goal

S87 (a legitimate, approved, docs-only fix) proved live that S86's attestation mechanism has a
structural gap: both the bash gate (`scripts/verify-closeout.sh#canonical_inputs_sha`) and its Rust
twin (`src/stations/mod.rs#attested_hash_outcome`/`read_prompt`) hash the prompt file's **current,
live on-disk bytes** — never a snapshot of what the file looked like when the review was actually
attested. Editing a historical `prompts/NN-task-*.md` file for ANY reason — even S87's, filling in
`<sha>` placeholders — silently changes the hash input out from under an already-attested,
already-ACCEPTed review. Confirmed live: `verify-closeout.sh --attest-only 76` now FAILs (`claimed:
4b87434c… != expected: 8a5d84a6…`) purely because S87 touched `prompts/76-task-dogfood-ride-along.md`
— S76's own delivered code and its review's verdict did not change at all.

Fix it so that verifying session N's attestation reads the prompt file **as it existed at N's own
review/merge time**, not whatever is on disk today.

## Why this session

This isn't a hypothetical. It just happened, for real, in this repo's own history, one session ago.
Every future session that touches an old prompt file (another sha backfill, a typo fix, anything)
will keep re-triggering this exact false-negative unless the mechanism is fixed at the root. Ranked
🥇 (recommended) over the standing dogfood-refresh and ROADMAP-table candidates because this is a
freshly-discovered, actively-recurring correctness gap in a load-bearing governance mechanism
(DECISION-003/004), not a stale-but-stable debt.

## Investigation starting point (not a conclusion — verify before committing to an approach)

Read both hashing call sites yourself; do not assume they behave identically.

1. **`src/stations/mod.rs#attested_hash_outcome`** (line ~416): calls `read_prompt(root, session)`
   **once**, then reuses that single live-read `prompt` byte buffer across **every** `(base, tip)`
   candidate `candidate_diffs` returns (the live branch, plus every `--no-ff` merge commit reachable
   from `main`). The diff component is already correctly read per-candidate via `git diff base tip`
   — only the prompt-bytes component is stuck on one live read. A plausible fix: for each
   `(base, tip)` candidate, read the prompt file's blob **from `tip`'s tree**
   (`git show <tip>:prompts/NN-task-*.md`) instead of the live working-tree file, so a historical
   session's hash is checked against the prompt as it stood at ITS OWN merge, immune to a later
   session's edits.
2. **`scripts/verify-closeout.sh#canonical_inputs_sha`** (line ~283): `cat "${prompts[0]}"` reads
   the live file directly; only ONE `(base, tip)` pair is tried (`git merge-base main HEAD` — this
   function is only ever invoked for the CURRENTLY open, not-yet-merged session at its own close, so
   there is no historical search to begin with). A plausible symmetric fix: read the prompt via
   `git show HEAD:prompts/${padded}-task-*.md` instead of `cat`, so an uncommitted stray edit to the
   prompt file can't silently affect the hash the reviewer is about to embed — verify this doesn't
   break the common case (prompt file is normally committed well before `--inputs-sha` runs).
3. **Do not assume the fix is symmetric or that one code change covers both.** They're different
   languages, different call patterns (one tries N candidates, one tries exactly 1), and one is the
   EMIT side (`--inputs-sha`, called by the reviewer to produce a hash to embed) while the other is
   the VERIFY side (`check_review_attestation` + `attested_hash_outcome`, called to check a claimed
   hash). Get both right, and get the emit/verify pairing right — a hash computed one way at emit
   time must be reproducible the other way at verify time, or every FUTURE session's attestation
   breaks too.
4. **Re-validate against this repo's real history, the S86 house pattern — do not trust a clean
   synthetic fixture alone.** Before this session, the disclosed split was 16 Verified / 4
   Unverifiable (S64, S69, S73, S79) out of 20 real ACCEPT reviews; S87 added a 21st claim
   (`sessions/session-76-review.md`, currently Unverifiable due to the very bug this session fixes).
   After the fix, re-run the full historical scan and report the new split. **S76 becoming Verified
   again is the single clearest sign the fix actually works** — its own code/review never changed;
   only a LATER, unrelated file happened to touch the same prompt path. If S76 does NOT become
   Verified again, the fix is wrong or incomplete.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)

1. **WHEN** `prompts/76-task-dogfood-ride-along.md` is (hypothetically, or actually, in a test
   fixture) edited again after this fix ships **THEN** `verify-closeout.sh --attest-only 76` and
   `vajra next --stations 76`'s Reviewer/Releaser dimensions are UNAFFECTED by that edit — proven
   live, not asserted, using a real git history (a temp repo with genuine `--no-ff` merges, the S86
   precedent, or this repo's own real history where safe/reversible).
2. **WHEN** the full historical scan re-runs against this repo's real 21 ACCEPT reviews (S86's 20 +
   S87's new one) **THEN** the report states the new Verified/Unverifiable split plainly, and
   confirms `sessions/session-76-review.md` specifically flips back to Verified (the direct proof
   this fix repairs what S87 broke).
3. **WHEN** a review is emitted fresh on a live, still-open branch (`--inputs-sha N` right before
   writing a NEW review) **THEN** the emitted hash is still reproducible by the verify side
   immediately after — the emit/verify pairing must not break for the ordinary, common case that
   works today.
4. **WHEN** `cargo test --lib` runs **THEN** it stays green, with new/updated tests proving the
   fixed behavior (a prompt file edited after a historical session's merge no longer changes that
   session's hash), not merely re-asserting the old live-read happy path.
5. Scope stays inside the two hashing call sites and their direct tests — no new command, no new
   `CONSTRAINTS.yaml` key, no change to what gets hashed (still `prompt bytes \0 delivery diff`),
   only WHICH prompt bytes are read.

## Design (the Architect gate — recorded rationale)

design-significant: **no** — precedent: S86's own "harden the attestation check" and S82's Releaser
ledger-fallback fix were both the same shape of change (correctness hardening of an existing
internal classifier, no new store/command/dependency) and both marked not design-significant. This
session serves `DECISION-003-verdict-input-attestation.md`'s existing intent more faithfully — it
does not deviate from or supersede it.

## Plan (ordered steps — cite the acceptance criteria each step covers)

1. Read both call sites (`src/stations/mod.rs`, `scripts/verify-closeout.sh`) and confirm the exact
   shape of the live-read bug in each, per the Investigation section above. `covers: 1`
2. Fix the Rust side: read each `(base, tip)` candidate's prompt bytes from `tip`'s own tree, not one
   shared live read. Fix the bash side's single live-candidate read symmetrically. `covers: 1, 3, 5`
3. Re-run the full historical scan (S86's method: every real ACCEPT review in `sessions/`) against
   the fixed code; confirm and report the new Verified/Unverifiable split, specifically confirming
   S76 flips back to Verified. `covers: 2`
4. Add/update tests proving the fixed behavior against a real git fixture (temp repo, genuine
   `--no-ff` merges, S86's precedent) where a later commit edits an already-merged session's prompt
   file and the earlier session's hash is proven unaffected. `covers: 1, 4`

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>

## Guardrails

- **One story:** fix the prompt-bytes-snapshot bug only. Do NOT touch `ROADMAP.md`'s stale table or
  start dogfood/measurement work (both explicitly deferred, not picked this round).
- **No new command, no new CONSTRAINTS.yaml key, no change to the hash's overall shape** (still
  `sha256(prompt \0 diff)`) — only which prompt bytes feed it.
- Max 3 files per atomic commit · ~2h cap · test against this repo's OWN real historical review
  files, not synthetic fixtures alone (the S86 house pattern — both S86's self-caught bugs were
  invisible to clean fixtures and only surfaced against real messy history).
- **S90 is the next mandatory NO-CODE ground truth** (`90 % 5 == 0`) — S88, S89 are normal.

## Delta (the Analyst gate — what this session ADDS to the governed pipeline)

- `~` `attested_hash_outcome`/`canonical_inputs_sha`: fixes a live-discovered false-negative where
  editing ANY historical prompt file retroactively un-attests that session's review — closes the
  gap S87 surfaced, hardens DECISION-003's mechanism rather than replacing it.
