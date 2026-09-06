# Session 147 — Quiet Roles Audit

**Session:** 147 — Prove the 5 Quiet Roles
**Branch:** session-147-prove-quiet-roles
**Brief:** Each of the five least-dispatched fleet roles (researcher, plan-advisor, demo-producer, release-coordinator, requirements-analyst) was dispatched on a narrow brief against the upcoming S148 cost-cutting task. Advice is recorded verbatim below, judged Changed / Noted / Hollow, and summarized in the table at the end.

---

## plan-advisor

**Brief:** 3 files (S147 prompt, tech-lead handoff, STATE.md). Two questions: (1) S147 plan sequencing, (2) S148 cost-cutting direction.

**Verbatim advice (S148 cost direction — recs 11–13):**

> rec 11 — ROOT CAUSE: the $11.74 is dominated by the 129-turn main headless session (context growth), NOT by the 875K subagent tokens. S134 cost $1.61 with 19.2M subagent tokens; S144 cost $11.74 with 875K — 22× fewer subagent tokens yet 7× the cost. The math points to the main session. 129 turns on a real codebase (chitra's horizontalBar + 217 tests) means context accumulated over many turns. At turn 129, the model is paying input-token cost for the entire conversation history on every call. That quadratic context growth is the bill.

> rec 12 — HIGHEST-LEVERAGE DELIVERABLE: implement a targeted Bash-output truncation rule in the existing PostToolUse hook for test-runner output, measured with a before/after token count on a replay of the S144 JSONL transcript. The rule detects test-runner output (cargo test, pytest, jest — pattern-matched on output shape) and truncates to: total-count line + FAIL/ERROR/PANIC lines only + a "N lines truncated" notice. This is (a) provably correct — no failure info lost, (b) high-leverage — a 217-line test output collapses to 5–20 lines on a green run, (c) measurable against the S144 JSONL replay without a live run.

> rec 13 — CORRECTNESS GUARD: passthrough on non-matching output; never drop FAIL/ERROR/PANIC lines; always include total-count summary; measure token reduction on S144 replay before claiming savings.

**Verbatim advice (S147 plan — 10 steps, coverage table):** Full output in `.ai/handoffs/session-147-plan-advisor.md`. Plan is a 10-step ordered sequence with AC coverage; steps 1–4 already executed at advice time; confirms no AC is uncovered. Also flags: plan-advisor is itself one of the five quiet-role observations and the audit must quote this output verbatim.

**Judgment: Changed**

The S148 cost direction (recs 11–13) drove the entire S148 brief direction. The core claim — context growth over turns is the cost driver, not subagent tokens — is the framing S148 is built on. S148's target (close gaps in existing test-runner heuristics) follows directly from rec 12. S147's plan (recs 1–10) confirmed the structure already in use; no change to plan from governance advice. Changed applies because rec 12 is the S148 deliverable specification.

---

## researcher

**Brief:** 2 files (STATE.md, session-144-summary.md). One question: is there evidence to confirm or refute the "129-turn context growth" root cause? What operations were most token-voluminous?

**Verbatim advice:**

> Bottom line: The two files do NOT contain enough data to confirm or refute the plan-advisor's assertion. They confirm the subagents were token-efficient, but they provide no cost split between the main 129-turn session and the subagents, and no per-operation token data.

> The $11.742472 figure is a session total, not itemised. session-144-summary.md reports the authoritative cost as a single number: `$11.742472 · 129 turns · 25.4 min`. No breakdown between the main headless session and the five subagent dispatches exists anywhere in either file.

> The subagent tokens are token-efficient, not cost-efficient (exact cost unknown). Composition: input 104 · output 20,935 · cache-read 636,247 · cache-write 218,262. Cache-read tokens (636K, ~73% of the subagent total) are billed at a fraction of input-token rates. This is consistent with the subagents NOT being the cost driver, but the files do not price it out to confirm.

> No per-operation volume data exists. Neither file mentions how many tokens were consumed by test-runner output, file reads, or compilation.

> rec 1 — Before accepting the "129-turn context growth" root cause, instrument a replay or inspect the S144 JSONL transcript for per-turn `usage` fields to get the main-session token breakdown separately from the subagent dispatch costs.

> rec 2 — Add a cost-attribution field to the session receipt that separately reports (a) main-session cost and (b) aggregate subagent cost.

> rec 3 — If test-runner output is a suspected cost driver in future sessions, add a `## Token hot-spots` field to the dogfood summary capturing the top-3 largest tool outputs by token count.

**Judgment: Changed**

Rec 1 changes S148: before implementing truncation, the session must first MEASURE the root cause from the S144 JSONL transcript per-turn usage fields. Without that measurement, S148 cannot honestly claim cost savings. This adds a mandatory measurement step (AC6) to S148. The "measure before claiming" requirement in rec 13 of the plan-advisor was advice; the researcher makes it a blocking requirement with a concrete method (per-turn usage fields in the JSONL). The S148 prompt will include this as a gated first step.

---

## requirements-analyst

**Brief:** 2 files (S147 prompt, plan-advisor handoff with S148 cost direction recs 11–13). One question: propose testable acceptance criteria for S148; flag gaps in the plan-advisor description.

**Verbatim advice:**

> **AC1** — Detection triggers on known test-runner output: WHEN the PostToolUse hook receives tool output containing the canonical summary line of `cargo test`, `pytest`, or `jest`, THEN the hook's return value differs from the input, verifiable by unit tests using one fixture per framework.

> **AC2** — Summary line preserved verbatim: WHEN the hook truncates test-runner output, THEN the hook's return value contains the framework's own pass/fail count summary line copied verbatim from the input.

> **AC3** — FAIL/ERROR/PANIC lines not dropped: WHEN the input contains one or more lines that match the framework's failure-marker pattern (to be defined in the prompt — see gap 5), THEN every such line appears in the hook's return value unchanged.

> **AC4** — Truncation notice present and well-formed: WHEN the hook drops any lines, THEN the return value contains exactly one line matching the canonical notice format (to be specified in the prompt — see gap 2).

> **AC5** — Passthrough on non-matching output: WHEN the hook receives tool output that does not contain any test-runner summary pattern, THEN the hook returns exactly the original bytes, verifiable by byte-level diff.

> **AC6** — S144 replay produces a positive token reduction: WHEN `scripts/verify-session-148.sh` runs against the S144 JSONL replay file, THEN the script prints `tokens before: N  tokens after: M` where M < N, and exits 0.

> **AC7** — All-pass run produces short output: WHEN the hook processes test-runner output with zero failures, THEN the returned output is at most [threshold] lines.

> **AC8** — `cargo test` exits 0 across all paths.

> **Gap 1** — Pattern definition is prose, not spec. Exact patterns or a normative fixture set must be defined.
> **Gap 2** — Truncation notice format unnamed. `[vajra] N lines truncated` is proposed; the prompt must define it.
> **Gap 3** — S144 JSONL replay file path is not given. May not be in the repository.
> **Gap 4** — Green-run output cap is illustrative ("5–20 lines"), not normative. A hard number is required.
> **Gap 5** — FAIL/ERROR/PANIC line-matching rule is ambiguous. cargo=FAILED, jest=FAIL, pytest=FAILED — case sensitivity and matching rule must be specified.
> **Gap 6** — No truncation floor defined. Without a minimum input line count, an implementation could truncate trivially small outputs.
> **Gap 7** — "Before claiming savings" is advice, not a gate. The prompt must state whether zero/negative reduction is blocking or informational.

**Judgment: Changed**

The 8 ACs and 7 gaps substantially reshape the S148 prompt beyond the plan-advisor's 3-sentence description. The gap list is the highest value-add: without resolving gaps 1–7, a verify script cannot be written. S148's prompt will incorporate all 8 ACs and resolve all 7 gaps explicitly. This is the most consequential Changed judgment in the audit.

---

## demo-producer

**Brief:** 2 files (plan-advisor handoff, demo-session-template.sh). One question: what should scripts/demo-session-148.sh show for each required element (header, cases, summary_table, before_after)?

**Verbatim advice (key finding):**

> **CRITICAL FINDING:** `src/engine/heuristic/cargo.rs`, `pytest.rs`, `npm.rs` already implement compression for `cargo test`, `pytest`, and `npm test`/`npm run test`. The `ClaudeCodeHookAdapter` in `src/adapter/claude_code.rs` already prepends `[vajra: N lines folded — VAJRA_RAW=1 before \`vajra claude\` to see full output]`. The real fixture at `research/compression-fixtures/raw/cargo-test.txt` is 86 lines. The `DefaultEngine` has `LINE_CAP = 30` (passthrough below this) and `FAIL_PASSTHROUGH_CAP = 400`.

> The gap visible from code reading: (a) bare `jest` command is not in the dispatch table — only `npm test`/`npm run test`; (b) the fail path for medium-size failing test output (30–399 lines) passes through unchanged regardless of the heuristic.

> The demo must show the concrete gap S148 closes — not a generic "compression exists" claim. A before/after that shows "86 lines shrink to 3" for a heuristic that already existed before S148 misrepresents what the session delivered.

> **demo:header** — "Session 148 — test-runner output truncation gap-close: bare jest detection added; an 86-line green cargo test run compresses to ~3 lines; FAIL/PANIC lines never dropped; non-test-runner passthrough unchanged."

> **demo:cases** — 5 cases via `$BIN hook` with crafted JSON: C1 cargo test green (real fixture), C2 cargo test FAIL (420+ lines, FAIL/PANIC must survive), C3 pytest green (50 synthetic lines), C4 jest bare detection (the new S148 behavior), C5 non-Bash tool_name passthrough.

> **demo:before_after** — BEFORE: bare jest payload → {} (passthrough, not detected pre-S148). AFTER: bare jest → compressed output with jest summary line.

> **demo:summary_table** — Runner | In | Out | Saved | Status (computed from live case signals, not hardcoded).

> rec 1 — Before/after must anchor to the specific gap S148 closes, not to already-working cargo truncation.
> rec 4 — Use static fixture files in research/compression-fixtures/hook-payloads/ for reproducibility.
> rec 5 — Summary table must be computed from live signals.

**Judgment: Changed**

The discovery that heuristics for cargo/pytest/npm ALREADY EXIST is a scope correction that changes S148's framing from "implement test-runner truncation" to "close the remaining gaps in existing heuristics." Without this finding, S148 would have duplicated existing code. The specific gaps (bare jest, fail-path for 30–399 lines) are the actual S148 deliverable. This is the most critical course-correction in the audit.

---

## release-coordinator

**Brief:** 2 files (tech-lead handoff, CONSTRAINTS.yaml). One question: ordered ship steps for S147; does a document-only session need a PR?

**Verbatim advice:**

> **1. Does a document-only session still need a PR?** Yes. CONSTRAINTS.yaml `forbid_direct_work_on: [main, master]` applies to all sessions without exemption for content type. No exemption exists.

> **Three blockers before close:**
>
> **Blocker 1 — required-crew will block.** The fidelity-reviewer handoff is absent. The crew gate (`vajra next --check-crew 147`) exits 1.
>
> **Blocker 2 — fidelity-review-accept will block.** `sessions/session-147-review.md` does not exist.
>
> **Blocker 3 — verify-demo-scripts-present will block.** Neither `scripts/verify-session-147.sh` nor `scripts/demo-session-147.sh` exists. S147 is a CODE session (147 % 5 ≠ 0). No exemption.

> **Ordered ship steps:** verify-closeout.sh exits 0 on branch → open PR → merge → checkout main → pull → prune merged session-* branches.

> **Most likely to be forgotten:** `scripts/demo-session-147.sh`. The demo-producer was deferred with "No demo AC" — but the gate does not read the AC list. It reads N%5. Without the script or `VAJRA_CLOSEOUT_WAIVER=147`, the gate blocks.

**Judgment: Changed**

The finding that `scripts/demo-session-147.sh` is required by the closeout gate (N%5 check, not AC-based) adds a deliverable that was not in the original session plan. Without this finding, the session would have blocked at `verify-closeout.sh`. Ordered ship steps are also useful reference.

---

## Summary Table

| Role | Judgment | Key finding | S148 updated? |
|---|---|---|---|
| **plan-advisor** | **Changed** | Context growth (not subagents) is the cost driver; test-runner truncation is the S148 target | Yes — S148 structured around rec 12 |
| **researcher** | **Changed** | Root cause is plausible but unconfirmed; S144 JSONL per-turn usage must be measured first | Yes — measurement step added as AC6 |
| **requirements-analyst** | **Changed** | 8 testable ACs + 7 gaps in the plan-advisor's description that the prompt must resolve | Yes — ACs and gap resolutions incorporated |
| **demo-producer** | **Changed** | Existing heuristics already cover cargo/pytest/npm; actual gap = bare jest + fail-path 30–399 lines | Yes — S148 scope corrected from "implement" to "close the gaps" |
| **release-coordinator** | **Changed** | demo-session-147.sh required by gate (N%5); document-only session still needs a PR | Yes — demo script added to S147 deliverables |

**All 5 roles: Changed.** No role returned Hollow. No dispatch died mid-flight (INCOMPLETE not applicable).

---

## Design

`design-significant: no`
Covering record: `docs/decisions/DECISION-007-agent-fleet.md` (S135 addendum — "phase 1b: the all-nine observation, deferred until the budget allows")

Rejected alternatives:
1. Put audit under `.ai/` — rejected. `.ai/` is the governance spine; session deliverable reports go in `sessions/`.
2. Combine audit with S148 prompt — rejected. Audit is evidence; prompt is a directive. Mixing makes each harder to gate independently.
3. Skip verify script for document-only session — rejected. The QA station requires a verify script for every CODE session; documents-only sessions have structural checks just as real as code checks.

---

## DECISION-007 S147 Addendum

Phase 1b of DECISION-007 (S135) is now executed. Evidence: all five dispatches returned signal. No role is confirmed hollow at this sample size (n=1, one task, one afternoon). The off switch (phase 2 discretion) requires more evidence. Next recommended observation: dispatch all five on a CODE session to see if advice on Rust implementation differs from advice on documentation.
