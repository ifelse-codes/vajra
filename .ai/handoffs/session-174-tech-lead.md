---
role: tech-lead
session: 174
agent: claude-code-subagent (verified: toolu_01HmRrAG1TKyGekrCzMFw2rg)
source-sha: 2b5f6866266e66bb8895f28a06747455e233db03dcaad59dc086351ea25878e6
captured: 2026-09-22T16:55:38Z
cost_usd: null
---

# Tech-lead handoff — session 174

Session 174 needs three of the nine roles: implementation-advisor, qa-specialist and fidelity-reviewer. The other six are held back because of cost. These are five small changes to what the agent is told. Only F59/F62 changes how something behaves: which session's to-do list `vajra next --steps` shows. That is the only fix that needs an outside check before code is written.

Every budget below is an instruction I am trusting the role to follow. Vajra cannot stop a role partway through a run, so these are not hard limits.

crew researcher — deferred-budget — budget: 150000 tokens — Money: in S134, broad dispatches used about 6M raw tokens each, and three of them hit the $20/mo plan's cap at 19.2M. The three required roles below already take about 1.3M. Adding this one brings it to about 1.45M. Every finding already names its own cause (F45–F51), so research would only confirm what is written.
crew requirements-analyst — deferred-budget — budget: 100000 tokens — Money: about 0.1M on top of the ~1.3M the required crew already takes. The founder's "fix all of it" plus the seven-row table already serve as the requirements. The cost is small, but it buys a second copy of a scope that is already written down.
crew design-advisor — deferred-budget — budget: 150000 tokens — Money: about 0.15M more on top of ~1.3M. No new part or design choice is proposed; each change is a message or a which-session-to-show choice inside code that already exists. If the author writes `design-significant: no`, the Architect gate accepts that without this dispatch.
crew plan-advisor — deferred-budget — budget: 100000 tokens — Money: about 0.1M more. The plan is already the numbered list of five in the brief. A plan review costs the same and returns a list we already have.
crew implementation-advisor — required — budget: 300000 tokens — F59/F62 is the one HIGH fix that changes behaviour: working out "session N is closed and merged, so show N+1's start steps" can go wrong (for example, if the branch doesn't exist yet or the close gate is green but the merge hasn't happened). Brief it on the `--steps` code path and how it finds session N only. Do not let it read the repo.
crew qa-specialist — required — budget: 300000 tokens — Each fix changes text that the agent reads when something is blocked or at boot. QA has to prove each new message actually appears in the real situation: allow-list miss with VAJRA_ALLOW_COMMIT set, the file-count block, a sha-trailered file left modified at session start, a mismatched SESSION number, and `--steps` after merge. It must also prove that no check got looser (F58 must still block; only the wording changes).
crew demo-producer — deferred-budget — budget: 150000 tokens — Money: about 0.15M more on top of ~1.3M. The visible result is five messages. QA's before/after output of those messages is the demo at no extra dispatch.
crew fidelity-reviewer — required — budget: 700000 tokens — The close gate requires a cold review of record. S173 needed 9 passes, and at S134's rate that is the biggest cost risk in the session. Brief it on the prompt, the diff, and the five fixes with their Findings rows. Aim for one pass.
crew release-coordinator — deferred-budget — budget: 100000 tokens — Money: about 0.1M more. The agent can already push and open its own PR under VAJRA_ALLOW_COMMIT (S173), and after F58 it will be told how. The ship-gate is covered by the close path without this dispatch.

rec 1 — Require only three roles this session: implementation-advisor (F59/F62 only), qa-specialist and fidelity-reviewer.
All five fixes change messages. The one fix that changes behaviour gets an advisor, and the checks that cost almost nothing to run stay as they are.

rec 2 — Brief the implementation-advisor on the F59/F62 code path only, and decide first what "closed and merged" means.
The risk is that the new rule shows N+1 while N is closed but not merged, or hides N's list while N is still open. Reading merged-ness from git (N's branch merged into main) is safer than trusting SESSION, which F63 shows can fall out of step.

rec 3 — Keep F58 a block. Rewrite the message and do not widen the allow-list.
When VAJRA_ALLOW_COMMIT matches the branch, the message should start with "you ARE approved; put the body in a file and use `--body-file`". VAJRA_ALLOW_PUBLISH should only be mentioned after that. This follows the S173 lesson: only add, and never hide text from a guard.

rec 4 — F60's message must say "commit with this session's first commit" and must never suggest `git checkout`/revert for sha-trailered files.
Identify Vajra's own files by the `vajra-render-sha` trailer, not by a hand-kept path list. A path list is the kind of exclusion list the S122 lesson warns becomes the hole.

rec 5 — QA should record the before and after text of every changed message, and use that record as the demo.
This replaces a separate demo dispatch and gives the fidelity-reviewer concrete evidence, which should keep the review to one pass.

rec 6 — Treat F64 as watch-only and say so in the prompt. No code this session.

Files:
- /Users/suman/playground/vajra/prompts/174-task-keep-testing.md (Findings table, lines 45–51)

## Handoff Delta
- `+` new: first tech-lead handoff for this session (5248 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
