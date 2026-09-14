# Fidelity Review — Session 168

**Role:** fidelity-reviewer (cold subagent; did not build this; read only the contract, the diff, the verify script and the summary)
**Session:** 168
**Date:** 2026-09-14
**Inputs:** `prompts/168-task-demo-final.md` + `sessions/session-168-artifacts/review-diff.patch` (merge-base..HEAD) + `scripts/verify-session-168.sh` + `sessions/session-168-summary.md`
**Handoff:** `.ai/handoffs/session-168-fidelity-reviewer.md`
**Passes:** four. Passes 1–3 (all ACCEPT) each found a dodge of the kit rules, fixed in-session: an indented ` demo:complete` passing as legacy · `\033[demo:complete` counted raw but not stripped, and `dk_marker complete` rescuing a typed PASS · an unfilled outline with zero checks and a hand-printed `complete`. Pass 4 is the pass of record, on the final code.
**Verdict:** ACCEPT
**Review-Inputs-SHA:** 49dbb9659c5b55886debd2c7d8d295ca60078964aedb1a2827dfe819b4bfb9f1

## Method controls

Read-only; nothing run. The prompt's `## Execution` and `## Advice` were not taken as evidence. The SHA covers the prompt and the handoffs as committed at close, recomputed twice after the pass of record, with no code, script or decision-record change in between: (1) after this pass's recommendations were answered in `## Advice` (was `a536c3f3…`); (2) after the independent obeyed judge's handoff (`.ai/handoffs/session-168-implementation-advisor.md`, 24 implemented · 1 mismatch) landed and tech-lead rec 5 was re-answered from `obeyed:` to a reasoned `deferred:` (was `e14d6939…`); (3) after a CI-config-only change — `fetch-depth: 0` in `.github/workflows/ci.yml`, because a depth-1 clone failed the two git-history demo-template tests (red since S167's PRs). No product code, kit, script or decision record changed after the pass of record.

## Per-AC verdict (pass of record)

| AC | Grade | Evidence |
|----|-------|----------|
| AC1 `dk_check` runs a command; bare tokens refused; `-q` counted | SHIPPED | `dk_check` refuses empty / PASS / FAIL / all-digit with `demo:check-failed`; everything else runs through `dk_run_v`; verify AC1a–d, AC1f |
| AC2 `--demo-facts` stable, read-only, exit 0 | SHIPPED | `facts.rs` `FACT_KEYS` / `demo_facts`; `demo_facts_never_runs_a_script`; verify AC2a–c |
| AC3 Vajra-filled tiles + scorecard | SHIPPED | `dk_vajra_tiles` / `dk_vajra_scorecard`; verify AC3a line-for-line |
| AC4 gate: `complete` + true facts; legacy warned; fixtures | SHIPPED | `demo_report_with`, `is_kit_built`, `check_facts`; fixtures incl. indented / escaped / hand-printed `complete`; verify rows match reason text |
| AC5 design on the record | SHIPPED | DECISION-010; DECISION-009 pointer; `complete` in CONSTRAINTS.yaml + scaffold |
| AC6 stranger end to end | SHIPPED | fresh `vajra init`: filled template READY; typed PASS, forged fact, unfilled + `dk_marker complete` blocked |
| AC7 StaleRender; chitra dry-run | PARTIAL | StaleRender test real; chitra lists the kit as `would create` (no S167 kit render there) |
| AC8 light theme, NO_COLOR, boxes | SHIPPED | verify AC8a–e + Rust test |
| AC9 S167 migrated | SHIPPED | demo/verify/tests migrated; AC6f re-pinned to S167's own range |
| AC10 demo-producer | SHIPPED | verified dispatch; brief + agent file; recs spot-checked |
| AC11 S168 demo | SHIPPED | Vajra-filled calls; S167-kit before; real-gate rows; pty deck; `--check-demo 168` |
| AC12 non-regression; behavioral verify | PARTIAL | AC5a–e / AC10a grep markdown; verify exit not recorded in the delivery at review time |
| AC13 release 0.2.0 | NOT-BUILT | no bump / tag / publish — pending merge + founder go |
| AC14 honest limits | PARTIAL | "what the gate proves" overclaimed (corrected in the summary after the pass; DECISION-010 → S169) |

**10 of 14 SHIPPED · 3 PARTIAL · 1 NOT-BUILT.**

## Fakest green

`demo:check-passed` fixes a hand-printed marker with another hand-printable marker: zero real checks plus a hand-printed `demo:check-passed x` and `demo:complete`, with true facts, closes READY; `dk_check "tests" cargo test >/dev/null` then a hand-printed `complete` hides a real failure. Same disclosed hand-printed-marker class — not a new hole, but a false sentence about what is proven. The gate proves the facts are true and that the kit's own failure lines were not left in the output.

## Recommendations (answered in the prompt's `## Advice`)

1. rec 1 — correct "what the gate proves" (summary now; DECISION-010 → S169).
2. rec 2 — live disclosed-floor row (zero checks + hand-printed markers → READY) → S169.
3. rec 3 — replace or relabel verify AC5a–e / AC10a → S169.
4. rec 4 — real verify exit and counts in the summary (done).
5. rec 5 — AC13 NOT-BUILT until install-smoke ×3 on v0.2.0 → ROADMAP S168-release.
6. rec 6 — prove the AC7 kit-upgrade half on a project with an S167 render → backlog, S170 GT pickup.
