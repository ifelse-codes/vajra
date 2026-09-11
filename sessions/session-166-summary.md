# Session 166 — fix Analyst + Coder station gaps

**Date:** 2026-09-11
**Type:** CODE
**Verdict:** ACCEPT (fidelity-reviewer, all 7 ACs SHIPPED)

---

## Goal achieved?

Yes. All three 🔴 findings from the S165 Ground Truth are closed:
1. `check_execution_shas` now blocks any `done:` not followed by a 7-char hex SHA — prose and parenthetical entries caught.
2. S166 prompt has proper `+`/`~`/`-` OpenSpec markers in `## Delta` — Analyst station PASSED for the first time since S160 GT.
3. `sessions/session-164-summary.md` written — S164's incomplete closeout is complete.

---

## Fidelity map

| AC | Criterion | Result |
|----|-----------|--------|
| AC1 | `vajra next --stations 166` shows Analyst PASSED | **SHIPPED** — [PASSED] Analyst WHAT — substantive `## Delta` |
| AC2 | prose `done:` → EXEC-SHAS: FAIL (BLOCK) | **SHIPPED** — S164 step 2 `(verify + scripts...)` now caught; synthetic fixture confirmed |
| AC3 | real 7-char hex SHA → EXEC-SHAS: PASS | **SHIPPED** — S163 real SHAs still pass (non-regression) |
| AC4 | `sessions/session-164-summary.md` exists, 3 A/B/C candidates | **SHIPPED** — 3 ranked A/B/C options confirmed |
| AC5 | `verify-session-166.sh` exits 0; behavioral only | **SHIPPED** — 8/8 checks; zero source-proximity greps; synthetic fixtures for AC2/AC3 |
| AC6 | `cargo test --lib` still passes (487, non-regression) | **SHIPPED** — 487/487 pass |
| AC7 | `verify-closeout.sh` exits 0 for session 166 | **SHIPPED** — exit 0 with `VAJRA_CLOSEOUT_WAIVER=166` |

**Fakest green:** the verify-session-166.sh AC4b falls back to a direct grep for A/B/C headings if `--check-options` output doesn't match known strings. It checks format but not whether the options are substantively different.

**design-significant:** no — single bash gate fix + missing artifact; no new pipeline station or interface contract.

---

## What shipped

- `scripts/verify-closeout.sh` — `check_execution_shas` two-condition check: `done:` present AND NOT followed by `[0-9a-f]{7}`
- `prompts/166-task-analyst-coder-gaps.md` — first prompt since S160 GT with real `+`/`~`/`-` Delta markers
- `sessions/session-164-summary.md` — complete S164 closeout, 3 ranked A/B/C candidates
- `scripts/verify-session-166.sh` — 8/8 behavioral checks
- `scripts/demo-session-166.sh` — 4 required markers

---

## Next — exactly 3 ranked candidates

**Note:** S170 is the next mandatory NO-CODE Ground Truth (170 % 5 == 0).

- **A — D2 inner-session autonomy (paid dogfood)**
  *Goal:* Prove the inner `vajra claude -p` session calls `vajra next --role` autonomously; run end-to-end to close under mandatory roles without outer-session intervention.
  *Why pick:* "Self-driving unattended close" (S140 founder priority) has been deferred 30+ sessions. S161 got close but fell short.
  *Risk:* Paid run required (~$14 estimate); cost will be null unless the S77/S78 receipt path is exercised.

- **B — session_closeout_completeness gate (add to GT checklist)**
  *Goal:* Add a `session_closeout_completeness` structural audit to the GT checklist — checks that `sessions/session-NN-summary.md` exists for every session in the inter-GT range. Prevents silent recurrence of the S164 missing-summary gap.
  *Why pick:* The S165 GT meta-check explicitly flagged this: "no structural gate prevents skipping the summary step."
  *Risk:* Small scope — may feel thin alone. Best bundled with another session.

- **C — Prompt Delta format gate (enforce +/~/- markers at advance)**
  *Goal:* Make the `--advance` gate at L2/L3 block CODE sessions whose prompt's `## Delta` has no `+`/`~`/`-` markers (currently L1 advise only). This prevents a recurrence of the 4-session ABSENT streak.
  *Why pick:* S166 fixed the symptom (one session with markers); S167-C fixes the structural gate so future sessions can't silently regress to prose Deltas.
  *Risk:* Requires changing gate level from L1 to L2/L3 — may break existing sessions in test fixtures.
