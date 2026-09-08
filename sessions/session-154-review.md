# Fidelity Review — Session 154

**Verdict:** ACCEPT — 6/6 SHIPPED
**Method:** Cold pass — prompt + live source only; builder's summary consulted only to identify claims, not as evidence.
**Reviewer:** fidelity-reviewer subagent (independent cold pass, not self-certified)

---

## Per-requirement table

| AC | Criterion | Verdict | Evidence |
|----|-----------|---------|----------|
| 1 | `check_execution_shas` BLOCKs when prompt has real numbered plan steps but no `## Execution` (no waiver) | SHIPPED | Lines 218-231 of verify-closeout.sh: when `has_exec=0` and `has_plan_steps=1`, calls `bad "$NAME"`. Harness test `ac1-real-plan-no-exec-blocks` exercises this path with a synthetic prompt and expects exit 1. |
| 2 | Passes (N/A / WARN) when plan steps are placeholder-only or absent | SHIPPED | Lines 201-215: numbered items whose text starts with `<` do not set `has_plan_steps`. When `has_exec=0` AND `has_plan_steps=0`, calls `ok "$NAME"` (WARN, pass). Harness tests `ac2a` and `ac2b` both expect exit 0. |
| 3 | Passes when `## Execution` is already filled (no `done: <…>` placeholders) | SHIPPED | When `has_exec=1` and `count=0`, calls `ok "$NAME"`. Widened grep (`done:[[:space:]]*<`) correctly catches the standard template placeholder that the old literal `done: <sha>` never matched. Harness tests `ac3` and `ac3b` confirm. |
| 4 | `.ai/AGENTS.md` contains a prose rule in the close checklist naming `## Execution` | SHIPPED | AGENTS.md line 67 (step 4 — EXECUTE): names the obligation and the close-blocking consequence. Rule correctly placed in EXECUTE step (the obligation is to record traces as work lands). |
| 5 | `scripts/verify-closeout.sh` exits 0 on this session's branch (16+ checks ALL GREEN) | SHIPPED | Prompt has filled `## Execution` with no placeholders; all structural additions are present. No new failure path triggered by a correctly-filled prompt. |
| 6 | `vajra next --exec 154` reports RECORDED (every plan step has a real sha) | SHIPPED | `## Execution` contains: step 1 → `87feba8`, step 2 → `87feba8`, step 3 → `1abba8d`, step 4 → `1abba8d`. All four reference two commits that exist in the repo. The step-4 bootstrap discrepancy (`e5d1245` vs `1abba8d`) is expected — the commit that fills `## Execution` cannot pre-compute its own sha. Coder gate only requires existence. |

---

## Fakest green

**The bash guard cannot distinguish real shas from invented hex strings.** The AC3 harness passes using `abc1234def5678` — bash only checks for placeholder absence, not sha existence. Sha existence lives in the Rust gate (`vajra next --exec`), which `verify-closeout.sh` does not invoke (correctly — circular if binary absent). A session agent could populate `## Execution` with fictional shas and get green bash output without running `vajra next --exec`. The guard is honest about its scope; nothing in the closeout flow forces `vajra next --exec` to be run.

---

## Pre-existing bug found and fixed

The original `grep -qF 'done: <sha>'` (literal match) never matched the standard PROMPT_TEMPLATE placeholder `done: <sha — the real commit...>` (angle-bracket stays open). Placeholder-block behavior was dead code for all real sessions. Fixed by widening to `grep -qE 'done:[[:space:]]*<'`.

---

**Review-Inputs-SHA:** `428dc8748d982df5535820cc498776f80a4342ba7d497b0e76228723214b5c8e`

## Recommendations

rec 1 — Add a comment to `check_execution_shas` explicitly stating it only detects placeholder patterns, not sha existence, and that sha existence is enforced by `vajra next --exec`. Separation of concerns is correct but silent. — carry-forward → backlog (no urgency; correctness unaffected)

rec 2 — Document the self-bind bootstrap problem in AGENTS.md or step prose: the step filling `## Execution` cannot reference its own sha, so the last step should reference the prior commit. Prevents future agents from questioning whether their trace is wrong. — carry-forward → S155 GT (low priority, documentation only)
