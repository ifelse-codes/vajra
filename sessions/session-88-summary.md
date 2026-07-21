# Session 88 — Hash a review-time snapshot, not the live prompt file — summary

**Type:** CODE — fixes the root cause S87 discovered live: both hashing call sites that verify a
session review's attestation read the prompt file's CURRENT bytes, never a snapshot from
review/commit time, so editing ANY historical prompt file silently un-attests an earlier session's
already-ACCEPTed review. Founder pick 🥇 A of 3 ranked candidates at S87 close.

## Headline

Fixed both call sites:
- **Rust** (`src/stations/mod.rs#attested_hash_outcome`): read each `(base, tip)` historical
  candidate's prompt bytes from **that candidate's own git tree** (`git show <tip>:<rel>`, new
  helper `prompt_bytes_at`) instead of one shared live-read buffer reused across every candidate.
- **Bash** (`scripts/verify-closeout.sh#canonical_inputs_sha`): read the prompt via `git show
  HEAD:path` instead of `cat`, guarded by a `git cat-file -e` existence pre-check, streamed raw
  (never through `$(...)`, which would strip the trailing newline and desync the two sides' byte
  preimage) — so an uncommitted stray edit can't silently change the hash about to be embedded.

**Direct proof:** `vajra next --stations 76` — Reviewer and Releaser both flip back
`ABSENT → PASSED`, live, against this repo's real S76→S87 history (the exact incident that
triggered this session).

**A real bonus finding, not anticipated by the prompt:** the full historical scan (all 26 real
ACCEPT reviews) shows **S73 and S79 were ALSO victims of this same bug** — previously misdiagnosed
by S86 as "genuinely unreconstructable" (a different, disclosed cause). `git log --follow` proves a
later session touched each prompt file (S74 → `prompts/73-...md`, S81 → `prompts/79-...md`), the
identical shape as S87 → S76. New split: **22 Verified / 4 Absent out of 26** (up from 19/26
pre-fix: 16 Verified per the S86 baseline + S76 freshly broken by S87, minus S73/S79 misdiagnosed).
S64 and S69 correctly stay Unverifiable — confirmed via the same `git log --follow` method to have
**no** later-session edit, a genuinely different, unchanged cause.

**The independent cold review (fed only the prompt + diff, adversarial, per DECISION-002) found a
real hollow-green in this session's OWN proof script — not the core fix:** the bash-side temp-repo
fixture used a single-digit session number (`5`), which tripped a pre-existing, unrelated padding
bug in `check_review_attestation` (`sessions/session-${N}-review.md`, unpadded `$N`, while every
emit path — including the fixture — zero-pads). The lookup silently never found the review file,
short-circuiting to an unconditional `N/A → PASS` regardless of whether the fix under test was even
present. Verdict: **REJECT**. Fixed in-session (switched the fixture to a 2-digit session number,
95, where padded/unpadded forms coincide; added an explicit negative control that runs the SAME
fixture against a genuine pre-fix `verify-closeout.sh` and asserts it correctly FAILs, proving the
check discriminates fixed-vs-broken at all). While rebuilding this check, hit — and fixed — a
SECOND, unrelated pre-existing gotcha live: `cmd | grep -q pattern` under `set -euo pipefail`
(the documented S32 SIGPIPE/pipefail false-RED) broke the rebuilt check's positive control; fixed
via the established capture-then-grep pattern (`out=$(cmd); grep -q pattern <<<"$out"`).

## What shipped

- **`src/stations/mod.rs`** — `prompt_bytes_at` (new helper) + `attested_hash_outcome` rewritten to
  call it per-candidate; new regression test
  `reviewer_stays_verified_after_a_later_session_edits_the_same_prompt_file` (independently
  confirmed by the reviewer to fail without the fix — a real regression test, not a hollow one).
- **`scripts/verify-closeout.sh`** — `canonical_inputs_sha`'s prompt read switched from `cat` to a
  `git cat-file -e` + `git show HEAD:path` pair.
- **`scripts/verify-session-88.sh`** — 19 checks: cargo hygiene; the direct S76 fix; the bonus
  S73/S79 finding (`git log --follow` + station report); S64/S69 correctly unchanged; a full
  26-review historical scan with an explicit printed headline (`HISTORICAL SCAN: 22 Verified / 4
  Absent … out of 26`) rather than a partial spot-check; the bash-side temp-repo fixture (rebuilt
  post-review with a 2-digit session number, a negative control, and capture-then-grep); scope
  checks.
- **`scripts/demo-session-88.sh`** — genuine before/after via a real pre-fix build of `main` in a
  disposable `git worktree` (not a mock, not a `git show`-swap on a single file — a full binary
  built from `main`'s actual committed source); all 4 required `demo:<element>` markers; the
  historical-scan headline surfaced in its own case.
- **`prompts/88-task-fix-canonical-inputs-sha-snapshot.md`** — this session's own `## Execution`
  filled in with real landing commit shas (self-application, the S81 gate).

## Proof

- `cargo test --lib`: 271 pass (270 + 1 new), `cargo clippy -- -D warnings` clean, `cargo fmt`
  clean.
- `vajra next --stations 76`: Reviewer + Releaser `ABSENT → PASSED`, 5/8 → 7/8. Reproduced live
  both before this fix (via a real worktree build of `main`) and after.
- Full historical scan (26 real ACCEPT reviews): **22 Verified / 4 Absent** (S56, S57 = NotAttested,
  pre-attestation-mechanism sessions, unchanged; S64, S69 = Unverifiable, confirmed genuinely
  different unchanged cause; S73, S76, S79 = flipped Absent → Verified by this fix).
- `bash scripts/verify-session-88.sh` → **19/19 PASS**. `bash scripts/demo-session-88.sh` → exit 0,
  all 4 `demo:*` markers present, worktree cleaned up (`git worktree list` confirmed clean after).
- Scope: `git diff --name-only main..HEAD` = `prompts/88-...md`, `scripts/demo-session-88.sh`,
  `scripts/verify-closeout.sh`, `scripts/verify-session-88.sh`, `src/stations/mod.rs`. No
  `src/cli/*`, no `.ai/CONSTRAINTS.yaml` change. Hash preimage shape unchanged
  (`sha256(prompt_bytes \0 diff_bytes)`) on both sides — only WHICH prompt bytes feed it.

## Fidelity map (prompt requirement → delivery)

| # | Requirement | Verdict | Evidence |
|---|-------------|---------|----------|
| 1 | A later session's edit no longer un-attests an earlier one, proven live on real git history | **SHIPPED** | Reviewer independently reverted the fix in an isolated worktree, confirmed the new Rust test genuinely fails without it; confirmed `--stations 76` flips live against this repo's real history. Reviewer also confirmed the AC's literal mention of `--attest-only 76` was itself imprecise in the prompt (that entry point is architecturally single-candidate, disclosed, unchanged) and that the delivered work is honest about this scope boundary. |
| 2 | Historical scan re-run, S76 confirmed flipped to Verified, split stated plainly | **SHIPPED** (reviewer initially flagged a reporting gap — no artifact stated a headline number; fixed post-review with an explicit `HISTORICAL SCAN: …` line covering all 26 reviews, not a 5-session spot-check) | Reviewer independently ran the full 26-review sweep and got the identical split (22/4/26) I now print explicitly. |
| 3 | Live-branch emit/verify pairing still works (AC3) | **SHIPPED** (reviewer's REJECT — this criterion's OWN proof was hollow-green; fixed in-session, see Headline) | Underlying bash fix was independently confirmed correct by the reviewer using a realistic fixture; the DELIVERED proof of it was not, until fixed. |
| 4 | `cargo test --lib` green with a genuine (non-hollow) regression test | **SHIPPED** | Reviewer independently reverted the fix and confirmed the specific new test fails without it. |
| 5 | Scope held to the two hashing call sites + tests + required scripts | **SHIPPED** | Reviewer confirmed via `git diff --name-only`: no `src/cli`, no `CONSTRAINTS.yaml` change, preimage shape unchanged. |

**NOT built:** nothing from the prompt was skipped. `ROADMAP.md`'s stale table and the dogfood
refresh were explicitly out of scope (per the prompt's own guardrails) and untouched.

## Honest limits (fakest green, reviewer-sharpened)

- **The AC3 hollow-green, stated plainly:** the first cut of `bash_emit_verify_pairing_survives_
  stray_edit` used session number `5`. `check_review_attestation` (pre-existing code, this session
  never touched it) looks up `sessions/session-${N}-review.md` with an UNPADDED `$N`, while every
  emit path in this codebase — including the fixture itself — zero-pads. With `N=5` those two
  strings never match (`session-5-review.md` vs. the fixture's `session-05-review.md`), so the
  lookup always falls through to the `N/A: no review file` branch, which unconditionally prints
  `ATTEST: PASS` — regardless of whether the bash fix under test was even present. The check exited
  0 and looked green while proving nothing about AC3. This is the exact "green that looks done but
  is hollow" class the constitution's culture exists to catch — caught by an independent reviewer,
  not self-caught, precisely why DECISION-002 requires one.
- **A second, unrelated gotcha surfaced live while rebuilding that same check:** the rebuilt
  positive control initially used `cmd | grep -q pattern`, which under `set -euo pipefail` (both in
  this script AND in `verify-closeout.sh` itself) triggers the documented S32 SIGPIPE/pipefail
  false-RED (`grep -q` closes the pipe on its first match → the upstream `bash verify-closeout.sh`
  process gets SIGPIPE → exits 141 → `pipefail` reports the whole pipeline as failed, even though
  `grep` matched). Confirmed via `PIPESTATUS=(141 0)`. Fixed via the same capture-then-grep pattern
  this codebase already established at S32 (`out=$(cmd); grep -q pattern <<<"$out"`) — a known
  house gotcha, re-discovered by stepping directly into it, not a new class of bug.
- **The bash side's disclosed, unchanged scope boundary:** `canonical_inputs_sha`/`--attest-only`
  is architecturally a SINGLE `(base, tip)` candidate (`merge-base(main, HEAD-of-caller)`), correct
  only for the CURRENTLY open session at its own close. It was never designed to, and still cannot,
  correctly re-verify an arbitrary HISTORICAL, already-merged session `N` from an unrelated branch
  — confirmed live: `bash scripts/verify-closeout.sh --attest-only 76`, run from this session's own
  branch, still reports a MISMATCH (a meaningless one, computed against an empty/wrong diff, not a
  regression). The historical multi-candidate search that genuinely fixes cross-session
  verification is, and remains, the Rust side's job (`vajra next --stations N`) — proven throughout
  this session's own proof. Not fixed here; was never this session's scope (the prompt's own
  investigation section frames bash as intentionally single-candidate).
- **`prompt-touched-by-later-session`'s heuristic is a house-convention pattern match, not a formal
  proof:** it reads the MOST RECENT commit's subject line's leading `S<NN>` token. This correctly
  avoids a full-text-scan false positive (S69's own delivery commit says "...3 ranked S71
  candidates" in prose — a naive full-text scan would misread that as evidence S71 touched the
  file) but assumes this repo's `S<NN>: ...` / `S<NN> ...` commit-subject convention holds, which it
  does across this repo's real history (empirically confirmed for all 4 sessions checked) but isn't
  independently guaranteed for all future commits.

## Attestation

- **Review-Inputs-SHA:** `493282c7aa59d563000cf5becf87e1c80951764f915b54bfaf95f871982afbef`
  (`sha256(prompt ‖ delivery-diff)` per `scripts/verify-closeout.sh --inputs-sha 88`). Independent
  two-pass cold review: **pass 1 REJECT** (a hollow-green AC3 fixture, fixed in-session) → **pass 2
  ACCEPT** (same reviewer, adversarially re-verified by hand, not trusting the delivered script's
  own report). See `sessions/session-88-review.md` for the full record.

## Coder-gate execution (plan step → landing commit)

- step 1 (read both call sites, confirm the bug) → `70c47af`
- step 2 (fix Rust + bash) → `70c47af`
- step 3 (re-run historical scan, report split) → `9b1d006` (initial), extended post-review with
  the explicit headline check — see the review's REJECT→fix cycle
- step 4 (regression tests against a real git fixture) → `70c47af`

## 3 ranked S89 candidates

- **🥇 A (recommended) — the dogfood refresh (founder-un-parkable, now 12 sessions / 19+ calendar
  days stale since S76).** Escalated 🔴 at S85, not picked at S86, S87, or S88 (all three went to
  sharper, freshly-discovered mechanism bugs instead — a legitimate but now 3-session-long pattern
  of deferral). Key risk: real spend; every session it's not picked, "is Vajra-on-Claude satisfying"
  stays unmeasured by definition, and the gap between measured governance-correctness and measured
  usage keeps widening.
- **🥈 B — fix `ROADMAP.md`'s stale "Where We Are" table.** Quick, cosmetic, concrete evidence for
  the standing readable-roadmap-one-pager pain — deferred 5 sessions running now (S84→S88). Key
  risk: none material — lowest-stakes, but the deferral streak itself is becoming a minor
  discipline-drift signal worth naming even though it's never been the highest-leverage pick.
- **🥉 C — extend the S88 fix's own historical-scan method into a standing `vajra check`-style
  audit** (a command or GT-audit step that runs the full 26-review sweep and flags any Absent
  review whose prompt file's `git log --follow` shows a later-session touch, so a FUTURE S73/S76/S79
  shape gets caught automatically instead of by a founder-picked investigative session). Key risk:
  scope creep — this session already found and fixed the root cause; a standing audit is a
  nice-to-have hardening, not a correctness gap, and risks turning into its own multi-session arc
  if not tightly bounded.
