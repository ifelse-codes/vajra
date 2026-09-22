---
role: design-advisor
session: 173
agent: claude-code-subagent (verified: toolu_01H1zG8YWCUHrsLseuy8NYAH)
source-sha: 79d49e861f41acc296ecad4f1c5c24b2d324ed7cf6f96cb28bca008b0696de07
captured: 2026-09-22T03:46:51Z
cost_usd: null
---

# Design-advisor handoff — session 173

# Design-advisor brief — session 173 (guard changes F55, F52)

Read the code; ran nothing (no shell).

Q1. `design-significant: yes` is right (F55 changes who may publish; F52 changes --advance with no terminal). The DEVIATION sentence mis-cited DECISION-005: that record never mentions VAJRA_ALLOW_PUBLISH or pushing — it names VAJRA_ALLOW_COMMIT as the env-marker COMMIT path and keeps guards ON. The publish-only-with-ALLOW_PUBLISH rule lives in the S37 hook, not a record. DECISION-005 is SUPERSEDED (S103); the live home for session branches + VAJRA_ALLOW_COMMIT is DECISION-007 (S172 addendum, the 2026-09-21 branch-name decision). Rejected alternatives are real.

Q2. The push check was a block-list text match. Open with the approval: `HEAD:session-05-y` / `session-NN-x:session-05-y` (another session's branch — contradicts AC7), `:session-05-y` / `:feature-x` (delete by empty source), `HEAD:feature-x`, `feature-x`, `-uf`/`-fu`/`-ud`, quoted `+refspec`, `--branches`, `--follow-tags`, tag names, glob refspecs, URL remotes / `--repo`, GitLab `-o merge_request.*` (a merge through the push), `cd ../other && git push`, and `--no-verify` plus an upstream/config redirect to main. Never classified as a push at all (pre-existing): `git -c k=v push`, `git -C . push`, quoted `"git"`, `eval`/`sh -c`, aliases; `gh api …/merge`. The pre-push hook is a second lock for main only, needs core.hooksPath=.githooks, and is skipped by --no-verify.

Q3. Dropping the [y/N] without a terminal is mostly honest — the question was answered by the agent. But "an agent's shell" is not the only no-terminal case (CI, scripts), and "the human's approval is the plan they OK'd" claims an approval nothing checks. The real control in a chat is the session guard.

Q4. The addendum's "does NOT claim" must name: the text-match classes still open; pre-push as main-only and --no-verify-skippable; gh pr create with any --base; unreviewed branches becoming visible; publish_guard: off in Vajra's own repo so the path is exercised only in scaffolded projects; --advance now proceeding for CI/scripts and the unchecked "plan they OK'd".

## Recommendations
rec 1 — Record the S173 addendum in DECISION-007 (next to the 2026-09-21 branch-name decision), not in the SUPERSEDED DECISION-005; keep DECISION-005 as a citation only for "guards ON".
rec 2 — Correct the DEVIATION sentence: DECISION-005 never mentions VAJRA_ALLOW_PUBLISH; the real deviation is that the env-marker commit path now also publishes, overriding the S37 hook's rule.
rec 3 — Replace the block-list with a positive allow-list of exact `git push` shapes (no --no-verify, -o, --repo, URLs, colon refspecs, combined flags) — pushes it cannot express fall back to the human.
rec 4 — Fix AC7's claim or the code: `HEAD:session-05-y` and `:session-05-y` pass as shipped; add those forms to verify-session-173.sh so the claim can fail.
rec 5 — Reword the no-terminal message to state only what the code knows (drop "an agent's shell" and "the plan they OK'd"), and put the six Q4 disclosures in the addendum's "does NOT claim".

## Handoff Delta
- `~` re-run: design-advisor handoff replaced (3097 bytes now vs 2973 bytes prior)
- prior stage: this session's earlier design-advisor handoff
