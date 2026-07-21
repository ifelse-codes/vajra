# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S86 complete, S87 not yet started).
S86 = **CODE** — hardened `reviewer_status`/`session_attested_accept` (`src/stations/mod.rs`) from
a bare `.contains("review-inputs-sha")` label match into a real recompute-and-compare against the
canonical `sha256(prompt bytes \0 delivery diff)` hash. Independent cold review: **ACCEPT** (all 6
acceptance criteria SHIPPED). Report: `sessions/session-86-review.md`.

## Active PRs
- Merged: S85 (docs-only GT closeout, `session-85-closeout`) · S84
  [#83](https://github.com/ifelse-codes/vajra/pull/83) · S83
  [#81](https://github.com/ifelse-codes/vajra/pull/81) · S82
  [#80](https://github.com/ifelse-codes/vajra/pull/80) · S81
  [#79](https://github.com/ifelse-codes/vajra/pull/79).
- **S86 PR:** TBD (`session-86-harden-attestation-check`) — 2 commits (Design decision, then
  implementation + tests + verify/demo scripts).

## Direction (governance is the product — 8 governed stations + a durable station counter)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S86 closed the top-ranked S85 GT finding:** the attestation substring-check
  (`.contains("review-inputs-sha")`) stood disclosed 3 CODE sessions (S82→S84) plus the S85 GT
  while load-bearing for 2 governed stations (Reviewer, Releaser) — a forged, stale, or
  recycled-from-another-session `Review-Inputs-SHA` could silently fake-pass either. Fixed:
  `attested_hash_outcome` (shared by both call sites) recomputes the SAME canonical hash
  `verify-closeout.sh#canonical_inputs_sha` commits to, searching every reconstructable diff (the
  live not-yet-merged branch, plus every `--no-ff` merge commit reachable from `main`) rather than
  trusting one possibly-pruned branch ref.
- **Empirically validated against this repo's real history, not just unit-tested:** live recompute
  via a naive `git merge-base main HEAD` was tested directly and confirmed BROKEN post-merge (S84's
  hash recomputes to `7a202b14…` today vs. the real `0e172ca7…` — base collapses to HEAD once main
  absorbs the branch, exactly the AC5/S83 fragility risk, now proven not assumed). The S59 ledger
  was inspected directly and confirmed to never validate a hash (only checks a well-formed value is
  present) — reading it would not have satisfied AC2 either. The chosen merge-commit-archaeology
  approach reproduces the exact claimed hash for 16 of 20 real historical ACCEPT reviews; the
  remaining 4 (S64, S69, S73, S79) reproduce under no candidate even after exhaustively searching
  every merge commit in the repo's history — most plausibly `canonical_inputs_sha`'s own
  exclude-list changed since their hash was computed, not forgery. Those 4 correctly flip from a
  false PASSED (pre-S86) to a disclosed, fail-closed `Unverifiable`/ABSENT — a deliberate trade-off
  (AC5), not a silent regression.
- **Two real bugs self-caught before commit, by testing against this repo's OWN historical
  reviews** (not just synthetic unit fixtures): (1) the diff hash didn't match because bash's
  `$(...)` command substitution strips trailing newlines before hashing and the first Rust
  implementation didn't; (2) the attestation-line finder used the SAME unanchored
  `.contains("review-inputs-sha")` mistake this session exists to fix, one level down — it matched
  prose in `sessions/session-82-review.md` that discusses the label before the real attestation
  line, misreading a genuinely-attested session as unattested. Both fixed by mirroring
  `verify-closeout.sh`'s exact algorithm (trailing-newline-stripped diff; anchored
  `^[*_\s]*Review-Inputs-SHA[*_\s]*:` line match).
- **New house pattern (S86): when hardening a check that trusts recorded evidence, test it against
  this repo's OWN real historical artifacts, not only synthetic fixtures** — both self-caught bugs
  above were invisible to the unit suite (whose fixtures are clean-by-construction) and only
  surfaced by running the new code against `sessions/session-82-review.md` and
  `sessions/session-84-review.md`, this repo's real, messy, already-shipped data.
- **S85 GT findings, updated:** (1) the attestation substring-check — **S86 DONE**, no longer a
  live exploit surface. (2) S76 `## Execution` `<sha>` placeholders — still open, now **9 sessions
  overdue** (standing since S81). (3) `ROADMAP.md`'s "Where We Are" table — still 24+ sessions
  stale, not touched this session (explicitly out of scope per the S86 prompt's guardrails).
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood: S76
  baseline, now **10 sessions (S77-S86) / 18 calendar days** stale (2026-07-03 → 2026-07-21,
  computed against today's real date) — 🔴, founder-un-parkable, still not re-picked. ③ compression:
  never claimed until measured (0 folds). ④ payload counter = BUILT (S74) + GT-verified (S75, S80,
  S85) + hardened for Releaser durability (S82).
- **House patterns (carried):** … a "derived, never-asserted" counter dimension that goes
  structurally-always-ABSENT because its PRIMARY evidence source decays over time gets fixed with a
  SECONDARY evidence fallback from another already-trusted store (S82). An advisory UX warning
  lives entirely outside the governance-gate machinery (S83). A state enum's variant that conflates
  "no code" with "code present" inside ONE `Option`-wrapped case should split into a distinct typed
  variant at every layer it's threaded through (S84). A raw station-count reading (K-of-8) cannot
  distinguish "the counter got more accurate" from "the pipeline stalled" — read the SHAPE, not
  just the digit (S85 meta-check). **NEW (S86): a "recompute and compare" fix must be tested
  against the SAME class of real, messy historical data the old bug actually failed on — a clean
  synthetic fixture will not surface the two subtlest bugs (encoding mismatches, unanchored text
  matching) that a real repo's history will.**

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt is AUTHORITATIVE when a `total_cost_usd` exists (S66/S78), HONEST when
  it genuinely doesn't (S77), correctly priced on the interactive estimate (S79), the closeout
  gate blocks unfilled execution shas (S81), the station counter's Releaser dimension is durable
  across branch pruning (S82), `vajra claude -p` warns before a headless run hits the silent
  read-only wall (S83), the QA/Demo-er gates' cannot-evaluate BLOCK names WHICH of two reasons
  occurred (S84), and **the Reviewer/Releaser attestation check cryptographically verifies the
  claimed hash instead of trusting a bare label (S86)**.
- **`cargo test --lib` 270** (+3 net this session: 3 new tests, 3 existing tests updated to prove
  the new behavior instead of the old label-only happy path).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.

## What Is Broken / Weak
- **🟡 S76 `## Execution` has `<sha>` placeholders** — S81 true positive, not yet fixed. Standing
  since S81, now **9 sessions overdue**. Not picked at S86 (attestation hardening ranked higher —
  live exploit surface vs. a historical record gap); still open for S87.
- **🟡 `ROADMAP.md`'s "Where We Are" table is stale** (reads `Today | 2026-07-14` / `Session 60`
  inside an otherwise-current document) — concrete evidence for the standing
  readable-roadmap-one-pager pain. Not touched this session (explicitly out of scope).
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — kept at historical
  $15/$75 as a conservative estimate (disclosed S79, re-confirmed S80).
- **🟡 The signal-death edge case (`gate_run::code_or_conservative`) has no dedicated automated
  test** — S84's own cold review finding, low severity, unchanged.
- **🟡 A pre-existing (S73) `wait_or_timeout` `Err(_) => None` (a `try_wait()` OS-level error) is
  still classified as `CannotEvaluate::Timeout`** — unchanged, out of scope for every session since.
- **🟡 S83's own verify-script check `ac5-advisory-exit-code-untouched` is a near-tautology**
  against the $0 stub `claude` binary (disclosed S83, not fixed).
- **🔴 Dogfood: stale since S76 — now 10 sessions (S77-S86) / 18 calendar days.** Escalated 🟡→🔴
  at S85, still not re-picked. Refresh = founder-un-parkable MEASURE session.
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured (S70).
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70.
- **🟡 (S86, disclosed by the independent cold review) `read_prompt`/`analyst::find_prompt_for`
  picks the FIRST prompt file matching a session's prefix via arbitrary directory order if more
  than one file matches** — bash's `canonical_inputs_sha` explicitly fails closed on 0-or->1
  matches; a rare divergence, pre-existing (not introduced by S86), untouched by this diff.
- **🟡 (S86) No dedicated test exercises the "still on the open, not-yet-merged branch" live
  candidate path of `attested_hash_outcome` in isolation** — all new S86 test fixtures go through
  merge+prune (the harder, historical case); the live-branch formula is a verbatim copy of the
  pre-existing bash algorithm, so risk is low, but this session's own prompt-branch closeout (using
  the live path for real, per `verify-closeout.sh --attest-only 86` PASS) is the only end-to-end
  proof of that specific path today.
- **🟡 (S86) `candidate_diffs` rescans every merge commit reachable from `main` on every
  single-session query** — cheap today (~85 commits, ~2s/session), a scalability note for if the
  repo's session count grows an order of magnitude.
- 🟡 `vajra init` template omits `pipeline_advance_check` (precedent) · ledger tamper-EVIDENT not
  PROOF + opt-in · guard nested-repo blindspot · install path.

## What Is In Progress
- **S86 DONE (CODE).** Next session (S87) not yet picked — 3 candidates presented to the founder
  at this closeout (S76 sha placeholders · ROADMAP stale-table fix · the dogfood refresh, now
  founder-un-parkable per S70/S85). **S90 = the next mandatory NO-CODE ground truth.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **Session 77–85: ~$0 each** (S78 ~$0.055; the rest bash-only, local-subagent cold reviews, or
  read-only NO-CODE audits, not billed against the Claude Code session budget). **Session 86: ~$0**
  (bash/Rust-only source fix; cold review used the local `general-purpose` subagent).
- Cumulative: **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
