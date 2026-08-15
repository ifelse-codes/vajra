# Session 119 — CODE: teach the QA station to smell a grep-only verify suite

> **Status:** DRAFT — written at the S118 closeout per `end_of_session.must_write_next_prompt_
> before_close`. **The founder has not yet picked.** Options A/B/C are in
> `sessions/session-118-summary.md`; this file drafts **A**, my recommendation. If the founder picks
> B or C, replace this file rather than editing it.

## Type

**CODE.** Max 2 assumptions · 2 retries · 1 story · 3 files per atomic commit · ~2h ·
`VAJRA_ALLOW_COMMIT=119` · new chat.

## Why this session

S118 paid **$4.09** to discover that a green verify suite proved nothing. chitra's
`verify-session-11.sh` reported **14 of 14 ALL GREEN** while 19 of its 20 chart pages showed an
error instead of a chart, because all 11 of its catalog checks were `grep` for source strings —
`grep -q "new Function"`, `grep -q "catalog-page"`. A check that greps for the presence of code
cannot see whether that code runs.

Every governance gate behaved correctly through that run. **None of them asks whether the delivered
thing works.** This is the S54 fidelity-over-discipline finding reproduced on a paid run, one
pipeline generation later — and unlike S54, we now know the shape of the tell.

## Goal

Make the QA station able to say: *this verify script cannot fail on a broken build.*

`vajra next --check-qa NN` (riding the existing `next` command — **no 8th command**) reads the
session's verify script and reports the **proportion of its checks that never execute the subject**:
a check whose command is only `grep` / `rg` / `test -f` / `[ -f … ]` / `ls` over repo files is
*static*; a check that invokes a build, a test runner, or a script is *executable*. Surface the
ratio and name the static checks. Advisory in `--advance` at L1; a WARN (never a hard block) at
L2/L3, because a legitimately structural check exists and this is a heuristic.

## Plan (ordered — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)

1. Add `src/qa/mod.rs` (or extend the existing QA gate module) with a classifier over a verify
   script's `run_check` invocations: `Static` (grep/rg/test/ls/[ over paths) · `Executable`
   (anything invoking a runner, script, or binary) · `Unknown`. Pure function over script text,
   unit-tested. `covers: 1, 2`
2. Wire `vajra next --check-qa NN`: print each check with its class, the ratio, and a plain-English
   verdict line. `covers: 3`
3. Wire the advisory into `--advance` (WARN at L2/L3, advise at L1, `VAJRA_SKIP_QA_SMELL=1`).
   `covers: 4`
4. Regression fixtures: chitra's ORIGINAL `verify-session-11.sh` (11 of 14 static → flagged) and its
   repaired version (one executable catalog check → not flagged). Both committed as fixtures so the
   detector is proven against the real case that motivated it. `covers: 5`
5. `scripts/verify-session-119.sh` + `scripts/demo-session-119.sh`; `cargo test --lib`, fmt, clippy
   green. `covers: 6`
6. Cold `fidelity-reviewer` pass fed only this prompt + the diff; summary with the per-requirement
   fidelity map + the fakest green; attest LAST. `covers: 7`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done:
- step 2 — done:
- step 3 — done:
- step 4 — done:
- step 5 — done:
- step 6 — done:

## Design

- design-significant: **yes** — a new classifier surface inside an existing station. It must cite
  `docs/decisions/` for the choice to WARN rather than block, and record the honest limit below.

## Non-goals (not built this session)

- **Not** deciding whether a check is *correct* — only whether it *executes*. A script that runs a
  test suite testing nothing still passes this detector. Say so plainly; it is the fakest green of
  the design, present from the start.
- No 8th command. No changes to the ledger or attestation.
- Not the Planner-gate bug (`task_2162b487`) and not the blocking fleet gate — both still queued.

## Acceptance criteria

1. A pure classifier exists with unit tests covering Static / Executable / Unknown.
2. Multi-line and heredoc `run_check` bodies classify correctly (chitra's script uses
   `run_check "name" bash -c '…'` with embedded newlines).
3. `vajra next --check-qa NN` prints per-check classes, the static ratio, and a verdict line.
4. `--advance` WARNs at L2/L3, advises at L1, and honors `VAJRA_SKIP_QA_SMELL=1`.
5. Fixtures prove the detector flags chitra's original 14/14-green suite and clears the repaired one.
6. `verify-session-119.sh` exits 0; demo exits 0; tests/fmt/clippy green.
7. Cold review ACCEPT, attested, summary carries the fidelity map and the fakest green.

## Guardrails

- **This is a heuristic and must never claim more.** It answers "does this check execute anything?",
  never "is this check meaningful?".
- No new dependencies without an explicit founder yes.
- Attest LAST (S69/S114/S116/S117): recompute `Review-Inputs-SHA` only after the Execution shas are
  committed, and confirm two consecutive `verify-closeout.sh --inputs-sha 119` runs agree.

## Delta (vs ROADMAP — OpenSpec markers)

- **ADDED:** the first gate that looks at whether a session's *own verification* can fail.
- **MODIFIED:** the QA station — currently re-runs the script live (S69/S73) but accepts whatever it
  contains.
- **UNCHANGED:** 8 stations, 7 commands, 3 fleet roles, the ledger, the receipt.
