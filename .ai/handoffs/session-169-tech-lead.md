---
role: tech-lead
session: 169
agent: claude-code-subagent (verified: toolu_01J7kTbYqgSNpfMw6MxGpLhx)
source-sha: 48eb75d696c4448915da95480ff220be64a50d5ee092ac9da7cd7d5032e9c824
captured: 2026-09-15T03:20:19Z
cost_usd: null
---

# Tech-lead handoff — session 169

**Brief:** S169 is a small change to one bash file, with fixtures, so the crew should be small too. Most of the work is already known. The regex needs a word boundary, a 7–40 length limit and a `git cat-file` check. The review and tech-lead checks already exist; the real hole is that `VAJRA_CLOSEOUT_WAIVER=N` lets every check pass. The one real design question is AC5: how to record a step that can only land after the merge, without a skip env var. So only the design-advisor and the fidelity-reviewer are required. The budgets below are instructions I trust each role to follow; Vajra cannot stop a role mid-run.

crew researcher — deferred-budget — budget: 40000 tokens — S134 measured about 6M raw tokens per broad dispatch; with two required roles plus this one, S169 has $0 for paid runs and room for about two dispatches; S166's review already did the research.
crew requirements-analyst — deferred-budget — budget: 30000 tokens — Same arithmetic: a third dispatch goes past the two-dispatch room; the five ACs are already testable (EARS-style) and come straight from S166's recs.
crew design-advisor — required — budget: 80000 tokens — Mandatory, and AC5 needs a recorded decision; read only the S169 prompt and the four named functions.
crew plan-advisor — deferred-budget — budget: 30000 tokens — A four-step plan already covers every AC; a third dispatch goes past the two-dispatch room.
crew implementation-advisor — deferred-budget — budget: 60000 tokens — It would help with the `set -e` trap and the waiver carve-out, but a third dispatch goes past the two-dispatch room.
crew qa-specialist — deferred-budget — budget: 60000 tokens — It would help prove the fixtures fail for the right reason, but a third dispatch goes past the two-dispatch room; rec 4 moves that duty to the fidelity-reviewer.
crew demo-producer — deferred-budget — budget: 30000 tokens — A third dispatch goes past the two-dispatch room; `verify-session-169.sh` is the proof the founder can see.
crew fidelity-reviewer — required — budget: 120000 tokens — Mandatory, and S166 closed on a review that never happened; one cold pass over the prompt plus the diff.
crew release-coordinator — deferred-budget — budget: 30000 tokens — No release this session; a third dispatch goes past the two-dispatch room.

rec 1 — Make the new checks refuse the waiver itself, not only add checks: a claimed verdict with no review file, or a CODE session with no `.ai/handoffs/session-NN-tech-lead.md`, must BLOCK even when `VAJRA_CLOSEOUT_WAIVER=N` is set.
Check the tech-lead file with plain bash so it still works when the binary is not built. Keep the waiver for "binary not built" only.

rec 2 — In `check_execution_shas`, match `done:[[:space:]]+([0-9a-fA-F]{7,40})` followed by a non-word character or end of line, then run `git cat-file -e <sha>^{commit}`. Report each failing line and sha in the log.

rec 3 — For AC5, the design-advisor should pick a recorded marker for post-merge steps (for example `step N — post-merge: <what>`). The next `--advance` then checks that it landed on main, so no `VAJRA_SKIP_CODER_GATE` is needed.

rec 4 — Each fixture must check the exact BLOCK reason in the log, not just a non-zero exit, so it cannot pass for the wrong reason. The fidelity-reviewer should probe this, including `done: defaced prose`.

rec 5 — Find where `vajra init` gets its close gate (`include_str!`) before editing, so one file carries both copies. If there is a second copy, that is a fourth file and needs a separate commit.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (3582 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
