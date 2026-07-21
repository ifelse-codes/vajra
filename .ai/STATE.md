# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S87 complete, S88 not yet started).
S87 = **CODE (docs-only)** — filled `prompts/76-task-dogfood-ride-along.md`'s 4 unfilled
`## Execution` `<sha>` placeholders, content-matched to their real landing commits. Independent
two-pass cold review: pass 1 **REJECT** (this session's own verify/demo scripts didn't actually
prove what they claimed) → in-session fix → pass 2 **ACCEPT**. Report: `sessions/session-87-review.md`.

## Active PRs
- Merged: S86 [#85](https://github.com/ifelse-codes/vajra/pull/85) · S85 (docs-only GT closeout,
  `session-85-closeout`) · S84 [#83](https://github.com/ifelse-codes/vajra/pull/83) · S83
  [#81](https://github.com/ifelse-codes/vajra/pull/81) · S82
  [#80](https://github.com/ifelse-codes/vajra/pull/80).
- **S87 PR:** TBD (`session-87-fix-s76-execution-shas`) — 4 commits (sha fix; verify+demo scripts;
  bugfix from pass-1 REJECT; summary+review).

## Direction (governance is the product — 8 governed stations + a durable station counter)
- **The product = provable agent governance**, shaped as a **governed multi-agent SDLC pipeline**
  (`VISION.md` + `DECISION-001`). Fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`), chained tamper-evident (`DECISION-004`).
- **S87 closed the oldest standing record-hygiene debt** (S76's 4 unfilled `<sha>` placeholders, 9
  sessions overdue) by content-matching each Plan step to its real landing commit — NOT the "(N/4)"
  commit-message numbering, confirmed scrambled relative to Plan-step order (the commit labeled
  "(4/4)" is actually step 2's evidence, not step 4's).
- **S87 also surfaced, live, a real and previously-unknown gap in S86's mechanism:** filling in
  S76's shas retroactively un-attests S76's OWN review. `canonical_inputs_sha` (bash,
  `verify-closeout.sh`) and `attested_hash_outcome`/`read_prompt` (Rust, `src/stations/mod.rs`) both
  hash the prompt file's CURRENT on-disk bytes, never a snapshot from review time — confirmed by
  reading the Rust source: `attested_hash_outcome` reads the prompt ONCE and reuses that single live
  buffer across every `(base, tip)` candidate, instead of reading each candidate's prompt bytes from
  its own commit tree. Editing ANY historical prompt file, for any reason, silently un-attests that
  session's review. Confirmed live: `verify-closeout.sh --attest-only 76` now FAILs (`claimed:
  4b87434c… != expected: 8a5d84a6…`) though S76's delivered code and verdict never changed;
  `vajra next --stations 76` reads 5/8 (down from 6/8) — Coder correctly PASSES, but Reviewer and
  Releaser both flip to ABSENT as an unavoidable side effect of the same edit. Disclosed
  immediately, not fixed this session (docs-only scope), **picked by the founder as the S88 target.**
- **S87's own verify/demo scripts failed their independent cold review on pass 1 — a real,
  self-inflicted "hollow green" the constitution's culture exists to catch:** `demo-session-87.sh`'s
  before/after used `git show HEAD~1:` for the "BEFORE" swap; once the verify/demo scripts landed in
  their own commit, `HEAD~1` became the FIX commit itself, so BEFORE and AFTER printed IDENTICAL
  output while the demo's summary table still claimed the transition was shown.
  `verify-session-87.sh`'s `scope_is_one_file` check used a pathspec starting POSITIVE-restricted to
  `$TARGET`, making its negative exclusions dead code — the check could never fail even if `src/`
  had been modified. Both scripts still exited 0 and printed all-green. **Fixed in-session and
  adversarially re-verified by the SAME independent reviewer** (proved the scope-check fix by
  deliberately making it fail on a throwaway `.ai/ROADMAP.md` edit on a disposable branch; proved
  the demo fix by reading its real live output, not its exit code) — **pass 2 ACCEPT.** Mirrors the
  S67 two-pass house pattern (reject → fix in-session → fresh independent re-verify).
- **New house pattern (S87): a session's OWN verify/demo scripts are not exempt from the "prove it
  live, don't assert it" discipline the session's actual deliverable is held to** — a green exit
  code from a script that doesn't structurally test what it claims is the same overclaim class as a
  self-graded feature, one level down in the tooling.
- **S85 GT findings, updated:** (1) the attestation substring-check — S86 DONE. (2) S76 `##
  Execution` `<sha>` placeholders — **S87 DONE**, but replaced by a sharper, freshly-discovered gap
  in the SAME mechanism (the live-bytes-vs-snapshot bug), now S88's target. (3) `ROADMAP.md`'s
  "Where We Are" table — still stale, deferred a 4th session running.
- **S70 founder decisions (binding until revisited):** ① crew DONE (8 stations) ✓. ② dogfood: S76
  baseline, now **11 sessions (S77-S87) / 18+ calendar days** stale (2026-07-03 → 2026-07-21) — 🔴,
  founder-un-parkable, not re-picked at S86 or S87. ③ compression: never claimed until measured (0
  folds). ④ payload counter = BUILT (S74) + GT-verified (S75/S80/S85) + hardened for Releaser
  durability (S82).
- **House patterns (carried):** … a raw station-count reading (K-of-8) cannot distinguish "the
  counter got more accurate" from "the pipeline stalled" — read the SHAPE, not just the digit (S85
  meta-check). A "recompute and compare" fix must be tested against the SAME class of real, messy
  historical data the old bug actually failed on (S86). **NEW (S87): a fix to a historical record
  can retroactively break a DIFFERENT, already-closed governance mechanism that depends on that same
  record's bytes staying stable — check downstream dependents, not just the field being edited. NEW
  (S87): a session's own proof-of-work scripts are exactly as accountable to "prove it live" as the
  feature they're proving — an independent reviewer, not the builder, is what catches this.**

## What Currently Works
- **The 8-station governed pipeline** riding `vajra next` (+ station gates at `--advance`): Analyst ·
  Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer (fidelity gate + attested,
  chained ledger). Receipt is AUTHORITATIVE when a `total_cost_usd` exists (S66/S78), HONEST when it
  genuinely doesn't (S77), correctly priced on the interactive estimate (S79), the closeout gate
  blocks unfilled execution shas (S81), the station counter's Releaser dimension is durable across
  branch pruning (S82), `vajra claude -p` warns before a headless run hits the silent read-only wall
  (S83), the QA/Demo-er gates' cannot-evaluate BLOCK names WHICH of two reasons occurred (S84), the
  Reviewer/Releaser attestation check cryptographically verifies the claimed hash instead of
  trusting a bare label (S86), and **S76's own Execution trace is now fully recorded — but its
  review's attestation currently reads ABSENT (5/8, not 6/8) as a direct, disclosed consequence of
  S86's mechanism not yet handling a legitimately-edited historical prompt file — S88's target.**
- **`cargo test --lib` 270** (unchanged this session — no `src/` change, docs-only).
- **`vajra claude · next · check · init · estimate · meter · hook`** — 7 commands, no 8th.

## What Is Broken / Weak
- **🔴 (NEW, S87) `canonical_inputs_sha`/`attested_hash_outcome` hash the prompt file's LIVE bytes,
  not a review-time snapshot** — any future edit to a historical prompt file un-attests that
  session's review. Currently live-exploiting itself: `sessions/session-76-review.md` reads
  `Unverifiable`/ABSENT even though S76's code and verdict never changed. **S88 target.**
- **🟡 `ROADMAP.md`'s "Where We Are" table is stale** (reads `Today | 2026-07-14` / `Session 60`
  inside an otherwise-current document) — deferred a 4th session running (ranked 🥉 again, not
  picked).
- **🟡 Legacy opus ids (4.0/4.1/4.5) have no confirmed current-rate source** — kept at historical
  $15/$75 as a conservative estimate (disclosed S79, re-confirmed S80).
- **🟡 The signal-death edge case (`gate_run::code_or_conservative`) has no dedicated automated
  test** — S84's own cold review finding, low severity, unchanged.
- **🟡 A pre-existing (S73) `wait_or_timeout` `Err(_) => None` (a `try_wait()` OS-level error) is
  still classified as `CannotEvaluate::Timeout`** — unchanged, out of scope for every session since.
- **🟡 S83's own verify-script check `ac5-advisory-exit-code-untouched` is a near-tautology**
  against the $0 stub `claude` binary (disclosed S83, not fixed).
- **🔴 Dogfood: stale since S76 — now 11 sessions (S77-S87) / 18+ calendar days.** Escalated 🟡→🔴 at
  S85, still not re-picked (S86 and S87 both went to sharper, freshly-discovered mechanism bugs
  instead). Refresh = founder-un-parkable MEASURE session.
- **🟡 Compression is a no-op on real CC (S63 + S76: 0 folds)** — never claim until measured (S70).
- **🟡 Cross-agent breadth (the ORIGINAL S25 ask) is still zero code** — founder-gated per S26/S70.
- **🟡 (S86, unchanged) `read_prompt`/`analyst::find_prompt_for` picks the FIRST prompt file
  matching a session's prefix via arbitrary directory order if more than one matches** — bash's
  `canonical_inputs_sha` explicitly fails closed on 0-or->1 matches; a rare divergence, untouched.
- **🟡 (S86, unchanged) No dedicated test exercises the "still on the open, not-yet-merged branch"
  live candidate path of `attested_hash_outcome` in isolation.**
- **🟡 (S86, unchanged) `candidate_diffs` rescans every merge commit reachable from `main` on every
  single-session query** — cheap today (~85 commits, ~2s/session), a scalability note.
- **🟡 (S87, disclosed by the S87 prompt's own repeated "single-file" framing vs. its actual 3-file
  footprint) `CONSTRAINTS.yaml#verify.required_for_done` structurally requires a verify+demo script
  per CODE session, which a genuinely single-artifact-change prompt doesn't always anticipate when
  it writes "one file, no other changes."** Not a bug — both cold-review passes read it as
  acceptable session-scaffolding — but worth a future prompt-writing convention update.
- 🟡 `vajra init` template omits `pipeline_advance_check` (precedent) · ledger tamper-EVIDENT not
  PROOF + opt-in · guard nested-repo blindspot · install path.

## What Is In Progress
- **S87 DONE (CODE, docs-only).** Founder picked **S88 = fix `canonical_inputs_sha`/
  `attested_hash_outcome` to hash a review-time snapshot, not live bytes** — the freshly-discovered
  gap this session's own fix exposed. `prompts/88-task-fix-canonical-inputs-sha-snapshot.md`
  written and approved. **S90 = the next mandatory NO-CODE ground truth.**

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 36: ~$61.4 · Session 46: ~$3.84 · Session 51: ~$1.52 · Session 52: ~$4.95 · Session 63: ~$1.27.
- Session 53–75: ~$0 each. **Session 76: real but UNKNOWN** (fable-5 unpriced; opus-estimate ≤ ~$26.6).
  **Session 77–87: ~$0 each** (S78 ~$0.055; the rest bash/Rust-only source fixes, local-subagent
  cold reviews — including S87's two-pass review — or read-only NO-CODE audits, not billed against
  the Claude Code session budget).
- Cumulative: **~$73.7 + S76 (unknown, ≤ ~$26.6 opus-estimate).**
