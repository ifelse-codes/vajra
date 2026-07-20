# Session 81 — Harden verify-closeout: catch `<sha>` placeholder execution shas (CODE)

> **Status:** APPROVED (founder pick A at S80 GT close).
> **Type:** CODE — one story; extends `scripts/verify-closeout.sh`, no new command, no new
> dependency. Retroactively fixes `prompts/79-task-stale-opus-reprice.md`.

## Goal

S80's `pipeline_advance_check` found S79 closed with the Coder gate ABSENT: its `## Execution`
section in `prompts/79-task-stale-opus-reprice.md` still has `<sha>` placeholder literals — the
real commit shas landed in the *summary*, not the prompt file the Coder gate reads. The gate was
designed to block this; it didn't, because `verify-closeout.sh` never checks whether `## Execution`
shas are filled. **S81 closes that gap** and retroactively fixes S79 while it's fresh.

## Why this session

Every CODE session from S81 onward must have its `## Execution` shas verified at closeout — not
trusted. The S67/S68 house pattern says "existence-gate recorded markers"; verify-closeout.sh is the
house-wide gate that runs on every session close. Adding this check there means **it is impossible
to merge a CODE session whose prompt still has placeholder shas** (unless the founder explicitly
waives, as for GT/NO-CODE sessions).

## Acceptance (testable — every criterion is cited by a `## Plan` step below)

1. **WHEN** `verify-closeout.sh` runs on a CODE session where any `step N — done: <sha>` line in
   `## Execution` still contains the literal string `<sha>` (angle-bracket placeholder) **THEN** the
   check fails with a clear message (BLOCK, exit 1), naming which steps are unfilled.
2. **WHEN** `VAJRA_CLOSEOUT_WAIVER=N` is set **THEN** the new `check_execution_shas` check is waived,
   matching the existing pattern for `fidelity-review-accept` and `review-inputs-attested` (NO-CODE GT
   sessions always use the waiver; their `## Execution` is intentionally unfilled).
3. **WHEN** the session's prompt has no `## Execution` section (legacy / pre-S68 prompts) **THEN** the
   check WARNs at most — never a blocking FAIL (backward-compat, matching the Coder gate's own WARN
   for missing sections).
4. **WHEN** all plan steps have real (non-placeholder) shas or the section is absent **THEN** the
   check passes and does not alter verify-closeout's exit behavior (zero false positives on the
   existing sessions corpus).
5. `prompts/79-task-stale-opus-reprice.md` `## Execution` has real commit shas for steps 2–4 (step 1
   was research-only, no commit; annotated clearly, not a `<sha>` placeholder). After the fix,
   `vajra next --stations 79` shows Coder ABSENT ONLY for step 1 (research-only), not all 4 steps.
6. `cargo test --lib` stays green (no Rust source change required; bash-only gate extension).

## Design (the Architect gate — recorded rationale)

- **design-significant: no** — a bash-only guard extension to an existing script
  (`scripts/verify-closeout.sh`) + a retroactive prompt fix. No new Rust module, no new CLI
  command, no new dependency, no new data store. The extension follows the existing
  `check_fidelity_review` / `check_review_attestation` pattern (waiver-gated,
  fail-closed, artifact log) verbatim.
- The check reads the prompt file directly (bash `grep`/`awk`) — no binary dependency. This keeps
  verify-closeout.sh pure-bash (the current contract; adding a `vajra` binary call would break the
  script if the binary is absent or unbuilt).
- The placeholder pattern is exactly the literal string `<sha>` (angle-bracket name). The Coder gate
  (`src/coder/mod.rs`) already parses the same section; we are NOT re-implementing the gate — we
  are catching the specific failure mode (unedited template line) that the gate cannot see because
  `verify-closeout.sh` never calls it.

## Plan (ordered steps — cite the acceptance criteria each step covers)

1. Add `check_execution_shas` to `scripts/verify-closeout.sh`: reads `prompts/NN-task-*.md`,
   extracts the `## Execution` section, fails on any `step N — done: <sha>` line containing the
   literal `<sha>`, warns (not blocks) when the section is absent, and respects
   `VAJRA_CLOSEOUT_WAIVER`. covers: 1, 2, 3, 4
2. Retroactively fix `prompts/79-task-stale-opus-reprice.md`: replace the four `<sha>` placeholders
   with the real shas from the S79 summary (step 1 = research-only annotation; step 2 = `079d27f`;
   step 3 = `079d27f`; step 4 = `e9b6ff3`). covers: 5
3. Write `scripts/verify-session-81.sh` (including a live run that triggers the new check on a
   controlled fixture — a temp-prompt with a placeholder sha must FAIL; a temp-prompt with a real sha
   must PASS; the existing S79 prompt must now PASS). Write `scripts/demo-session-81.sh` (four
   `demo:<element>` markers: header · cases · summary_table · before_after). Summary + independent
   cold review + attestation. covers: 1, 3, 4, 6

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: 22232f7
- step 2 — done: 22232f7
- step 3 — done: 84dc73e

## Guardrails
- **One story:** add the `<sha>` placeholder check + retroactive S79 fix. Nothing else.
- **No new command, no new binary dependency, no new Rust module.** The fix is in
  `scripts/verify-closeout.sh` (bash-only).
- **Backward-compat:** pre-S68 prompts with no `## Execution` section must WARN only, never BLOCK.
  The check must pass cleanly against every existing prompt in `prompts/` before S81.
- **Waiver is the GT escape hatch:** `VAJRA_CLOSEOUT_WAIVER=N` waives the new check (same as the
  fidelity gate). Do not add a separate env-var.
- **New session = new chat.** Do not begin the S82 branch/plan in this chat.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` `scripts/verify-closeout.sh` gains `check_execution_shas` — the placeholder-sha closeout guard.
- `~` `prompts/79-task-stale-opus-reprice.md` `## Execution` section updated retroactively with real
  shas (step 1 annotated research-only; steps 2–4 have commit hashes).
- `-` Nothing removed; existing gate checks and the Coder gate itself (`src/coder/mod.rs`) are
  untouched.

## Deliverable
- `scripts/verify-closeout.sh` with `check_execution_shas` · `prompts/79-task-stale-opus-reprice.md`
  retroactive fix · `scripts/verify-session-81.sh` (fixture-driven; tests placeholder FAIL + real
  PASS + waiver PASS) · `scripts/demo-session-81.sh` (four markers) · `sessions/session-81-summary.md`
  + independent cold `sessions/session-81-review.md` (attested).
