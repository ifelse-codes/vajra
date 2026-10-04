---
role: tech-lead
session: 185
agent: claude-code-subagent (verified: toolu_01QHaFLTYj3oVqQQG8P6858p; text-sha: 9d666d9f88774d0d64230f975f7f4e827acef66a2e8ad0c7bf8736f48acbdf3d)
source-sha: aa4f9fcff32ef5408cbb0435980bc219dab191a24276388fa2ce1549dc828fef
captured: 2026-10-04T05:17:32Z
cost_usd: null
---

# Tech-lead handoff — session 185

Tech-lead handoff for session 185 (GROUND_TRUTH, no code)

You asked for required / optional / not needed. The gate accepts only `required` and `deferred-budget`, so that is what I used. Each budget is an instruction I am trusting the role to follow. Vajra cannot enforce it partway through a run. The money facts: about 6M raw tokens per broadly briefed dispatch (S134); the plan hit its cap (F82); S184 used 6 dispatches. The two required roles come to about 0.13M if each keeps to its narrow brief. S180, the last ground truth, used no fleet roles at all.

crew researcher — deferred-budget — budget: 40000 tokens — F115 is one script run at two commits, which the main session can do itself. About 0.04M on top of ~0.13M on a capped plan (F82) buys nothing new.
crew requirements-analyst — deferred-budget — budget: 30000 tokens — The prompt already lists every item. About 0.03M would be spent on nothing on a capped plan (F82).
crew design-advisor — required — budget: 100000 tokens — The session's only real output is the F113 and F110 design picks. Brief: src/obeyed/mod.rs 70-80 and 490-530, src/mandate/mod.rs 61-72, the DECISION-007 S134 addendum, scripts/hook-approvals-guard.sh, merge_claude_settings, and the ROADMAP S182 row.
crew plan-advisor — deferred-budget — budget: 30000 tokens — There is no `## Plan` in a ground truth. About 0.03M on a capped plan (F82).
crew implementation-advisor — deferred-budget — budget: 100000 tokens — No code this session. About 0.1M would almost double the required total on a capped plan (F82).
crew qa-specialist — deferred-budget — budget: 60000 tokens — The F115 check is something the main session can run. About 0.06M on a capped plan (F82).
crew demo-producer — deferred-budget — budget: 30000 tokens — Nothing to demo. About 0.03M on a capped plan (F82).
crew fidelity-reviewer — deferred-budget — budget: 150000 tokens — The founder signs off the report himself, and S180 had no cold review. About 0.15M would double the total on a capped plan (F82).
crew release-coordinator — required — budget: 30000 tokens — This is the one judge of any `obeyed:` answers to my recs (S184 pattern). The tech-lead cannot judge its own recs.

rec 1 — F113: take the session number out of the binary for projects, so Vajra's own close script supplies its own threshold. Decide the design-advisor threshold (133) in the same pick, and restore the disclosure at mod.rs ~517 and the verify-132 check for it.
rec 2 — F110: block only when the redirect's actual target resolves into the approvals folder. Heredoc bodies and `<…>` are not targets. Handle `..` (S182 rec 1) in the same path resolution. List rec 2 and rec 5 with a severity but do not design new blocking for them ("no more policing").
rec 3 — F115: run verify-session-132.sh at e1c348e^ and at e1c348e and record "stale" or "regression" with the output. Size F114 as a first-run fix for S186.

## Handoff Delta
- `+` new: first tech-lead handoff for this session (2958 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
