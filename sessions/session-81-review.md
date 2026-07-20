# Session 81 — Cold Fidelity Review

**Session:** 81 — Harden verify-closeout: catch `<sha>` placeholder execution shas (CODE)
**Reviewer:** independent cold pass (no session context)
**Date:** 2026-07-20

---

## Per-requirement verdict table

| # | Requirement | Verdict | Evidence |
|---|-------------|---------|----------|
| 1 | `<sha>` placeholder in `## Execution` → BLOCK (exit 1), naming unfilled steps | **SHIPPED** | `check_execution_shas` in `scripts/verify-closeout.sh` (line 169): `grep -qF 'done: <sha>'` on each line inside the section; calls `bad()` → exit 1 with PLACEHOLDER lines logged. Live: `--check-exec-shas 99` on fixture → FAIL confirmed. |
| 2 | `VAJRA_CLOSEOUT_WAIVER=N` waives the new check | **SHIPPED** | `waiver_ok()` (line 201) checks `VAJRA_CLOSEOUT_WAIVER = $N`; when true, calls `ok()` instead of `bad()`. Covered by `ac2-waiver-passes` in verify-session-81.sh. |
| 3 | Absent `## Execution` section → WARN only, never BLOCK (backward-compat) | **SHIPPED** | `has_exec=0` path (line 175) logs "WARN: no ## Execution section…" and calls `ok()`. Covered by `ac3-absent-section-warns-not-blocks`. |
| 4 | All real shas / absent section → check passes; zero false positives on corpus | **SHIPPED** | `count=0` path calls `ok()`. `corpus_scan` in verify-session-81.sh covers S68–S80 non-GT sessions; GT sessions tested with waiver; S76 documented as true positive (not false positive). |
| 5 | `prompts/79-task-stale-opus-reprice.md` has real shas for steps 2–4; step 1 annotated research-only; `--stations 79` Coder ABSENT only for step 1 | **SHIPPED** | S79 prompt now reads: step 1 = `research-only, no commit`; step 2 = `079d27f`; step 3 = `079d27f`; step 4 = `e9b6ff3`. `vajra next --stations 79` output: `[ABSENT] Coder DID — steps 1 not recorded` (only step 1, not all 4). `--check-exec-shas 79` exits 0. |
| 6 | `cargo test --lib` stays green (no Rust source change) | **SHIPPED** | `ac6-lib-suite-green` in verify-session-81.sh runs `cargo test --quiet --lib`. Summary confirms 258 passed. No Rust source touched. |

---

## Implementation spot-checks

**Heading detection** (`## Execution (the Coder gate)`): the parser lowercases the line, strips `^#*[space]*` via `sed`, then takes `awk '{print $1}'`. For `## execution (the coder gate)` this yields `first_word = execution`. Comparison `[ "$first_word" = "execution" ]` is TRUE. Correct.

**Placeholder grep** (`grep -qF 'done: <sha>'`): `-F` is literal-string mode. The template line `- step 1 — done: <sha>` contains the substring `done: <sha>`. Match is correct. No regex escape issues.

**Waiver scoping**: `waiver_ok()` requires `VAJRA_CLOSEOUT_WAIVER` to equal `$N` as a string. A stale waiver from another session does not pass. Correct.

**Absent-section handling**: `has_exec=0` if no heading matching `execution` is found anywhere in the file. Pre-S68 prompts have no `## Execution` — they warn and pass. Correct.

**Focused entry point** (`--check-exec-shas [N]`): placed before the main flow at line 436; mirrors `--fidelity-only` and `--attest-only`. Wired into the main closeout flow at line 507 between `check_cost_tracking` and `check_fidelity_review`. Correct.

**S76 true positive**: the corpus scan explicitly marks `--check-exec-shas 76` as a true positive (`prompts/76-task-dogfood-ride-along.md` also has 4 unfilled `<sha>` placeholders). Framed as separate historical debt, not an S81 scope item. That framing is accurate — the prompt guardrail says "one story: S79 fix only."

---

## Fakest green

**The S81 prompt's own `## Execution` is still unfilled.**

`prompts/81-task-execution-sha-guard.md` lines 73–75 read:

```
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
```

The actual landing shas are provided in `sessions/session-81-summary.md` (step 1+2 = `22232f7`; step 3 = `84dc73e`), but they were never propagated to the prompt file. Running the new check against the current session proves this:

```
$ bash scripts/verify-closeout.sh --check-exec-shas 81
PLACEHOLDER:  - step 1 — done: <sha>
PLACEHOLDER:  - step 2 — done: <sha>
PLACEHOLDER:  - step 3 — done: <sha>
BLOCK: 3 step(s) in prompts/81-task-execution-sha-guard.md still have 'done: <sha>' placeholder(s)
EXEC-SHAS: FAIL
```

The session shipped the fix for the exact failure mode it was built to prevent, then committed that failure mode in its own prompt. `verify-session-81.sh` avoids catching this by not including session 81 in the corpus scan (it covers S68–S80 only). The shas are available in the summary, so the fix is a one-line-per-step propagation — but the delivery as diffed leaves the S81 closeout blocked (absent a founder waiver or a follow-up commit).

This is the "hollow green" class identified in S69: the check lights green on fixture tests while the session itself never passes its own gate.

---

## What was NOT built

Nothing from the numbered acceptance criteria was skipped. The S81 prompt's unfilled `## Execution` is outside the six numbered ACs (which address the behavior of the check, the waiver, backward-compat, the corpus, and the S79 retroactive fix). The gap is a closeout-readiness issue, not a delivery gap against the stated ACs.

---

**Verdict:** ACCEPT

All six acceptance criteria are satisfied by the delivered code. The `check_execution_shas` function is correct: placeholder detection, waiver handling, absent-section backward-compat, and the S79 retroactive fix all work as specified. `cargo test --lib` is unaffected. The S81 prompt's own unfilled `## Execution` is a self-application gap that must be resolved before closeout (fill `22232f7` and `84dc73e` from the summary, or the founder waives), but it does not invalidate the delivery's correctness against the six numbered ACs.

**Review-Inputs-SHA:** c11797a973a1b085d5038fcd1f12775f1aa33ec335b42e9616dc4f0e3a89eb2f
