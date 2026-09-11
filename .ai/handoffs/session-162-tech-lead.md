# Session 162 — Tech Lead Handoff

**Brief:** Narrow CODE session (~2h) closing two pre-ship audit findings. Finding 07: `VAJRA_CLOSEOUT_WAIVER` used in production (S161 ×2) but correctness never proven by a live behavioral test — correct-session bypass, wrong-session rejection, and waiver-reason recording are all untested. Finding 14: `vajra init` on a fresh empty repo may emit a misleadingly green signal before any session has closed. Six ACs: AC1/AC2/AC3 are behavioral tests (actual `verify-closeout.sh` invocations, not source grep), AC4 is an investigation run, AC5 is the narrowest possible fix for any false green found, AC6 is the verify script.

---

## Required Roles

**crew qa-specialist — required** — budget: 60000 tokens  
The primary deliverable IS behavioral tests (AC1/AC2/AC3); the guardrail explicitly names hollow-test as the failure mode; QA must confirm the fixture forces a real block and the exit-code assertions are on actual subprocess invocations, not source grep.

**crew fidelity-reviewer — required** — budget: 60000 tokens  
Mandatory per DECISION-002/AGENTS.md (no self-cert); two deliverables (behavioral tests + fresh-init investigation) means two independent verdicts needed; reviewer reads prompt + diff only.

## Deferred Roles

**crew design-advisor — deferred-budget**: prompt marks design-significant: no; no ADR or interface decision in scope.

**crew plan-advisor — deferred-budget**: plan has 4 explicit steps with `covers:` tags; nothing to clarify.

**crew implementation-advisor — deferred-budget**: scope is narrow bash scripting + a small possible Rust tweak; the plan is specific enough; account is under 15M remaining.

**crew researcher — deferred-budget**: all facts are in the local codebase; no external research needed.

**crew requirements-analyst — deferred-budget**: AC table in the prompt is complete and unambiguous.

**crew demo-producer — deferred-budget**: demo-session-162.sh is step 1 of the builder's own plan; no separate producer needed.

**crew release-coordinator — deferred-budget**: no publish or release gate in scope.

---

## Key Risks / Watch-Outs

1. **Guardrail is explicit**: a verify script that greps source for "waiver" does NOT prove AC1/AC2. The test must actually invoke `verify-closeout.sh` with a synthetic fixture that forces a known block, then set/unset `VAJRA_CLOSEOUT_WAIVER` and check exit codes. Source-proximity grep = the hollow-green this session exists to kill.

2. **AC4 first, AC5 second**: the fix scope is unknown until investigation runs. Prompt says "if the fresh init gives no signal at all, that may be correct — document it and close the finding."

3. **`waiver_ok()` checks exact session number** (`${VAJRA_CLOSEOUT_WAIVER} = "$N"`). The fixture for AC2 must set `VAJRA_CLOSEOUT_WAIVER=M` where M ≠ N, and the SESSION file in the fixture must contain N. Getting this wrong (fixture SESSION = M = N accidentally) will produce a false pass.

4. **AC3 checks artifact log contents**, not just exit code. The recording happens at `check_fidelity_review()` (line 420/452) — echoed into `.ai/verify/closeout/<ts>/fidelity-review-accept.log`. The test must grep that log for the VAJRA_CLOSEOUT_WAIVER_REASON string.

5. **Scope cap**: max 3 files per atomic commit. Demo script, verify script, and any source fix are separate commits.

---

## Builder Recs

**rec 1** — For AC1/AC2 fixtures: create a minimal synthetic tmpdir with `vajra init`, override `.ai/SESSION` to N=999, use a missing required artifact (e.g. no review file) to force a known block. Use `CLAUDE_PROJECT_DIR=<tmpdir>` so `verify-closeout.sh` runs in the fixture without affecting the live repo.

**rec 2** — For AC3: after running the waiver-pass case, grep `.ai/verify/closeout/*/fidelity-review-accept.log` for the VAJRA_CLOSEOUT_WAIVER_REASON string. An exit-code check alone does not prove the reason was recorded.

**rec 3** — For AC4: run in the scratchpad directory, not in /tmp, to get isolated state. Use `CLAUDE_PROJECT_DIR` env var.
