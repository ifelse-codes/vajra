# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S88 complete, S89 not yet started).
S88 = **CODE** — fixed the root cause S87 discovered live: `attested_hash_outcome`
(`src/stations/mod.rs`) and `canonical_inputs_sha` (`scripts/verify-closeout.sh`) both read the
prompt file's CURRENT bytes, never a review-time snapshot. Independent two-pass cold review:
pass 1 **REJECT** (this session's OWN bash-side AC3 proof fixture was hollow-green) → in-session
fix → pass 2 **ACCEPT**. Report: `sessions/session-88-review.md`.

## Active PRs
- Merged: S87 [#86](https://github.com/ifelse-codes/vajra/pull/86) · S86
  [#85](https://github.com/ifelse-codes/vajra/pull/85) · S85 (docs-only GT closeout,
  `session-85-closeout`) · S84 [#83](https://github.com/ifelse-codes/vajra/pull/83) · S83
  [#81](https://github.com/ifelse-codes/vajra/pull/81).
- **S88 PR:** TBD (`session-88-fix-canonical-inputs-sha-snapshot`) — 5 commits (Rust+bash fix
  incl. regression test; verify+demo scripts; execution-shas self-record; review-driven fixture
  fix; summary+review).

## Direction (governance is the product — 8 governed stations + a durable station counter)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S88 fixed DECISION-003's attestation-hash root cause.** Both hashing call sites used to read
  the prompt file's CURRENT on-disk/HEAD bytes rather than a snapshot from review time, so editing
  ANY historical prompt file (for any legitimate reason) silently un-attested that earlier
  session's already-ACCEPTed review — the exact bug S87 discovered live when its own legitimate
  edit to `prompts/76-...md` un-attested S76's review. **Rust fix:** `attested_hash_outcome` now
  reads each `(base, tip)` historical candidate's prompt bytes from THAT candidate's own git tree
  (new helper `prompt_bytes_at`, `git show <tip>:<rel>`) instead of one shared live-read buffer
  reused across every candidate. **Bash fix:** `canonical_inputs_sha` reads via `git cat-file -e` +
  `git show HEAD:path` instead of `cat`, guarded fail-closed, streamed raw (never through `$(...)`,
  which would strip the trailing newline and desync the two sides' byte preimage) — so an
  uncommitted stray edit can't silently change the hash about to be embedded.
- **Direct proof:** `vajra next --stations 76` — Reviewer + Releaser both flip back
  `ABSENT → PASSED`, live, against this repo's real S76→S87 history.
- **A real bonus finding, not anticipated by the prompt:** the full 26-review historical scan
  shows **S73 and S79 were ALSO victims of this exact bug** — previously misdiagnosed by S86 as
  "genuinely unreconstructable" (a different, disclosed cause). `git log --follow` proves a later
  session touched each prompt file (S74 → `prompts/73-...md`, S81 → `prompts/79-...md`), the
  identical shape as S87 → S76. New split: **22 Verified / 4 Absent out of 26** (up from 19/26
  pre-fix: 2 NotAttested pre-attestation-era sessions [S56, S57] + 2 genuinely-different-cause
  Unverifiable sessions [S64, S69], confirmed via the same `git log --follow` method to have NO
  later edit — correctly unchanged, disclosed since S86).
- **The independent cold review (fed only the prompt + diff, DECISION-002) found a real
  hollow-green in this session's OWN proof script — pass 1 REJECT:** the bash-side temp-repo
  fixture (`bash_emit_verify_pairing_survives_stray_edit`) used a single-digit session number
  (`5`), which tripped a PRE-EXISTING, unrelated padding bug in `check_review_attestation`
  (looks up `sessions/session-${N}-review.md` with an UNPADDED `$N`, while every emit path —
  including the fixture — zero-pads) — the lookup always fell through to `N/A: no review file`,
  printing an unconditional `ATTEST: PASS` regardless of whether the fix under test was even
  present. The underlying bash fix was independently confirmed correct; the proof of it was not.
  **Fixed in-session** (2-digit fixture number where padded/unpadded forms coincide + an explicit
  negative control proving the check discriminates fixed-vs-broken code, run against a genuine
  pre-fix `verify-closeout.sh` checkout) — **and while rebuilding it, hit a SECOND, unrelated
  pre-existing gotcha live**: `cmd | grep -q pattern` under `set -euo pipefail` triggers the
  documented S32 SIGPIPE/pipefail false-RED (confirmed via `PIPESTATUS=(141 0)`); fixed via the
  established capture-then-grep pattern. **Pass 2 ACCEPT**, adversarially re-verified by hand by
  the SAME reviewer (reproduced the full positive/negative/positive sequence independently,
  outside the delivered script). Mirrors the S67/S87 two-pass house pattern.
- **New house pattern (S88): a session's own regression-test FIXTURE can be hollow in a way that
  has nothing to do with the fix it's testing** — a pre-existing, unrelated bug elsewhere in the
  codebase (here: unpadded `$N` in a lookup this session never touched) can silently make a new
  test pass unconditionally. "Does the test fail without the fix?" must be checked by actually
  reverting the fix and re-running, not by reading the test's logic and assuming it's sound.
- **S85 GT findings, updated:** (1) the attestation substring-check — S86 DONE. (2) S76 `##
  Execution` `<sha>` placeholders — S87 DONE. (3) the live-bytes-vs-snapshot attestation bug —
  **S88 DONE** (plus S73/S79 repaired as a bonus). (4) `ROADMAP.md`'s "Where We Are" table — still
  stale, deferred a 5th session running, **picked as S89's target.**
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood: S76
  baseline, now **12 sessions (S77-S88) / 19+ calendar days** stale (2026-07-03 → 2026-07-21) — 🔴,
  founder-un-parkable, not re-picked at S86, S87, or S88. ③ compression: never claimed until
  measured (0 folds). ④ payload counter = BUILT (S74) + GT-verified (S75/S80/S85) + hardened for
  Releaser durability (S82).
- **House patterns (carried):** … a raw station-count reading (K-of-8) cannot distinguish "the
  counter got more accurate" from "the pipeline stalled" — read the SHAPE, not just the digit (S85
  meta-check). A "recompute and compare" fix must be tested against the SAME class of real, messy
  historical data the old bug actually failed on (S86). A fix to a historical record can
  retroactively break a DIFFERENT, already-closed governance mechanism that depends on that same
  record's bytes staying stable — check downstream dependents, not just the field being edited
  (S87). A session's own proof-of-work scripts are exactly as accountable to "prove it live" as the
  feature they're proving — an independent reviewer, not the builder, is what catches this (S87,
  recurred at S88). **NEW (S88): a regression test's fixture can be hollow for a reason UNRELATED
  to the fix under test — verify a test fails without the fix by actually reverting and re-running,
  not by reading its logic.**

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt is AUTHORITATIVE when a `total_cost_usd` exists (S66/S78), HONEST when it
  genuinely doesn't (S77), correctly priced on the interactive estimate (S79), the closeout gate
  blocks unfilled execution shas (S81), the station counter's Releaser dimension is durable across
  branch pruning (S82), `vajra claude -p` warns before a headless run hits the silent read-only wall
  (S83), the QA/Demo-er gates' cannot-evaluate BLOCK names WHICH of two reasons occurred (S84), the
  Reviewer/Releaser attestation check cryptographically verifies the claimed hash instead of
  trusting a bare label (S86), S76's Execution trace is fully recorded (S87), and **the attestation
  hash is now review-time-stable — a later session editing a historical prompt file can no longer
  retroactively un-attest an earlier session's review (S88), which also repaired S73 and S79 as a
  disclosed bonus.**
- **`cargo test --lib` 271** (270 + 1 new regression test, independently confirmed by the cold
  reviewer to fail without the fix).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.

## What Is Broken / Weak
- **🟡 `ROADMAP.md`'s "Where We Are" table is stale** (reads `Today | 2026-07-14` / `Session 60`
  inside an otherwise-current document) — deferred a 5th session running (S84→S88). **S89 target.**
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — kept at historical
  $15/$75 as a conservative estimate (disclosed S79, re-confirmed S80).
- **🟡 The signal-death edge case (`gate_run::code_or_conservative`) has no dedicated automated
  test** — S84's own cold review finding, low severity, unchanged.
- **🟡 A pre-existing (S73) `wait_or_timeout` `Err(_) => None` (a `try_wait()` OS-level error) is
  still classified as `CannotEvaluate::Timeout`** — unchanged, out of scope for every session since.
- **🟡 S83's own verify-script check `ac5-advisory-exit-code-untouched` is a near-tautology**
  against the $0 stub `claude` binary (disclosed S83, not fixed).
- **🔴 Dogfood: stale since S76 — now 12 sessions (S77-S88) / 19+ calendar days.** Escalated 🟡→🔴 at
  S85, still not re-picked (S86, S87, and S88 all went to sharper, freshly-discovered mechanism bugs
  instead). Refresh = founder-un-parkable MEASURE session; NOT picked at S89 either (founder chose
  the ROADMAP-table fix) — watch it closely at S90's GT.
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured (S70).
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70.
- **🟡 (S86, unchanged) `read_prompt`/`analyst::find_prompt_for` picks the FIRST prompt file
  matching a session's prefix via arbitrary directory order if more than one matches** — bash's
  `canonical_inputs_sha` explicitly fails closed on 0-or->1 matches; a rare divergence, untouched.
- **🟡 (S86, unchanged) No dedicated test exercises the "still on the open, not-yet-merged branch"
  live candidate path of `attested_hash_outcome` in isolation.**
- **🟡 (S86, unchanged) `candidate_diffs` rescans every merge commit reachable from `main` on every
  single-session query** — cheap today (~85 commits, ~2s/session), a scalability note.
- **🟡 (S88, new, low severity, reviewer-disclosed) `full_historical_scan`'s pass bar is a floor
  (`[ "$verified" -ge 16 ]`), not a strict zero-regression assertion** — a future run could in
  principle regress some of the original 16 while fixing new ones and still clear this bar. Not a
  correctness gap today (this session's own independent binary-diff proved zero regressions across
  all 26 reviews) — a hardening note for a future session.
- **🟡 (S86, unchanged) bash's `canonical_inputs_sha`/`--attest-only <N>` is architecturally a
  SINGLE `(base, tip)` candidate, correct only for the CURRENTLY open session at its own close** —
  it was never designed to, and still cannot, correctly re-verify an arbitrary HISTORICAL,
  already-merged session from an unrelated branch. The historical multi-candidate search that
  genuinely fixes cross-session verification is, and remains, the Rust side's job
  (`vajra next --stations N`). Disclosed, not a regression, out of scope for S88 (the prompt's own
  investigation framed bash as intentionally single-candidate).
- 🟡 `vajra init` template omits `pipeline_advance_check` (precedent) · ledger tamper-EVIDENT not
  PROOF + opt-in · guard nested-repo blindspot · install path.

## What Is In Progress
- **S88 DONE (CODE).** Founder picked **S89 = fix `.ai/ROADMAP.md`'s stale "Where We Are" table**
  (deferred 5 sessions running, now the longest-standing backlog item). `prompts/89-task-fix-
  roadmap-stale-table.md` written and approved. **S90 = the next mandatory NO-CODE ground truth.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **Session 77–88: ~$0 each** (S78 ~$0.055; the rest bash/Rust-only source fixes, local-subagent
  cold reviews — including S88's two-pass review — or read-only NO-CODE audits, not billed against
  the Claude Code session budget).
- Cumulative: **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
