# Session Boot

## Current Session
- **Number:** 87 — COMPLETE
- **Type:** **CODE** (docs-only). Filled `prompts/76-task-dogfood-ride-along.md`'s 4 unfilled
  `## Execution` `<sha>` placeholders — content-matched to their real landing commits, not the
  scrambled "(N/4)" commit-message numbering the prompt itself warned about.
- **Headline result:** the core fix is solid (AC1/AC4, confirmed by an independent reviewer reading
  all 6 candidate commits' diffs itself). Two things surfaced live during this session that were
  NOT anticipated by the prompt:
  1. **A real, unplanned side effect:** filling in S76's shas retroactively un-attests S76's OWN
     review. S86's `canonical_inputs_sha` hashes the prompt file's LIVE bytes, not a review-time
     snapshot — so this legitimate fix flips S76's Reviewer/Releaser `--stations` dimensions from
     PASSED to ABSENT (6/8 → 5/8), even as Coder (this session's actual target) correctly flips
     ABSENT → PASSED. Confirmed live via `verify-closeout.sh --attest-only 76`. Disclosed
     immediately, picked as the S88 target (founder pick A of 3 ranked candidates).
  2. **A hollow-green finding in this session's OWN proof scripts**, caught by the independent
     cold reviewer on pass 1 (REJECT): `demo-session-87.sh`'s before/after silently broke (printed
     identical output) once its own commit made `HEAD~1` the fix commit itself, while its summary
     table still claimed the transition was shown; `verify-session-87.sh`'s scope check was
     structurally tautological (could never fail). Both scripts still exited 0 and printed
     all-green. Fixed in-session, adversarially re-verified by the SAME reviewer (made the scope
     check fail on purpose; read the demo's real live output) — pass 2 **ACCEPT**. Mirrors the S67
     two-pass house pattern.
- **Independent cold review:** pass 1 REJECT → in-session fix → pass 2 **ACCEPT**, all 5 acceptance
  criteria SHIPPED.
- **Report:** `sessions/session-87-review.md`, attested `d2e4c1ac…`.
- **Date last updated:** 2026-07-21.

## Repo State Snapshot
- `.ai/SESSION` = 87.
- **Pipeline = 8 governed stations, unchanged in COUNT.** Session 76's Reviewer/Releaser dimensions
  now correctly (if unfortunately) read ABSENT — a disclosed, live consequence of this session's
  fix, not a new bug in the pipeline machinery itself.
- `verify-closeout.sh` unchanged (this session added `scripts/verify-session-87.sh` +
  `scripts/demo-session-87.sh`; no change to the closeout gate script itself).
- Remote: `origin` → `https://github.com/ifelse-codes/vajra`.

## Next Session
- **Number:** 88
- **Type:** **CODE** — fix `canonical_inputs_sha`/`attested_hash_outcome` to hash a review-time
  snapshot of the prompt file, not its current live bytes (the root cause this session's own fix
  exposed).
- **Prompt:** `prompts/88-task-fix-canonical-inputs-sha-snapshot.md`. **Branch:**
  `session-88-fix-canonical-inputs-sha-snapshot`. **New chat.**

## Carry-Forwards
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S88; do NOT start here.
- **S88's fix must re-validate the real historical Verified/Unverifiable split** (16/20 at S86, now
  effectively 16/21 after S87's edit un-attested S76) — S76 flipping back to Verified is the
  clearest proof the fix works; report the new split plainly, don't silently let it drift.
- **Dogfood is 🔴 — now 11 sessions (S77-S87) / 18+ calendar days stale since S76.** Not picked at
  S86 or S87 — founder-un-parkable per S70/S85, watch it keep aging past S88.
- **`ROADMAP.md`'s "Where We Are" table is still stale** — deferred 3 sessions running now
  (ranked 🥉 again at this close, not picked).
