---
role: fidelity-reviewer
session: 173
agent: claude-code-subagent (verified: toolu_01AtCcea4XDuBjmdcTvq6Lxd)
source-sha: 90bcce36461cf6e28490a0b213cba27926066bc8a33e327170baa04e346891b3
captured: 2026-09-22T03:27:11Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 173

# Fidelity review, pass 1 — session 173 (cold, read-only)

**Verdict:** REJECT — 13 SHIPPED · 4 PARTIAL · 0 NOT-BUILT.

PARTIAL: D4 (the guards' new stripping hides what bash RUNS — the rest of a heredoc's first line, unquoted backticks, multi-line `bash -c` strings), D6 (`gh pr create --head` bypassable: joined `-Hsession-03-y`, repeated `--head`, `--he\ad`), A5 (real advances hide: same-line heredoc, backticks — verify line 106 expects pass), A7 (with NO approval, `echo \`git push -f --no-verify origin HEAD:main\`` and `cat <<EOF >/dev/null; git push -f --no-verify origin HEAD:main` exit 0 — both blocked before S173). The push allow-list itself held.

Fakest green: `scripts/verify-session-173.sh:106` "backticked-mention-passes" — bash runs backticks; the check records a real advance becoming invisible as a PASS.

## Recommendations
1. In both guards' heredoc strip, keep the rest of the heredoc's first line and strip only the body lines.
2. Stop stripping unquoted backticks in both guards, and change verify line 106 to expect exit 2.
3. Add publish-guard verify cases, with and without VAJRA_ALLOW_COMMIT, that must exit 2: a backticked push, a push on the heredoc's first line, a multi-line `bash -c "⏎git push -f origin main⏎"`.
4. Tighten the `gh pr create` head check: refuse any backslash, any joined `-H<value>`, and more than one head flag.
5. Correct the DECISION-007 S173 addendum's "were open before S173" list: close the forms S173 introduced or list them as introduced.
6. Before computing the review stamp, record the real sha for Execution step 7 and commit the summary, the demo and the prompt edit.
7. Anchor the ` 2>&1` removal to just before the optional `| head`/`| tail` at the end.

## Handoff Delta
- `+` new: first fidelity-reviewer handoff for this session (1737 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
