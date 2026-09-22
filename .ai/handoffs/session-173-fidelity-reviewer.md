---
role: fidelity-reviewer
session: 173
agent: claude-code-subagent (verified: toolu_015kYaEhdRkd83Ws8VBR8Emd)
source-sha: 9d5bc9dee5e2b20498217bf13a664cb91452260ef415fb9a3738fe8118fb8436
captured: 2026-09-22T03:39:54Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 173

# Fidelity review, pass 2 — session 173 (fresh cold reviewer, read-only)

**Verdict:** REJECT — 14 SHIPPED · 3 PARTIAL · 0 NOT-BUILT.

PARTIAL: D4 (the bash-like `vajra_scan` still hides code bash runs: an unquoted heredoc body's `$( )`/backticks; a heredoc fed to a shell as `cat <<EOF | bash`, `bash -s <<EOF`, `sh /dev/stdin <<EOF`, `source /dev/stdin <<EOF`; an empty heredoc whose regex end skips to a later EOF; `<<` inside quotes/comments/here-strings opening a fake heredoc; an apostrophe in a `#` comment read as a quote — all blocked by the pre-S173 sed), D6 and A7 (with VAJRA_ALLOW_COMMIT, `gh pr create --body "$(cat <<EOF … $(gh pr merge 5 --admin) … EOF)"` is ALLOWED because `$(cat H)` is deleted before the shape check; `-R other/repo` allowed).

Fakest green: the "S173 regression, rec 3" block in verify-session-173.sh plus the addendum sentence "anything bash would RUN stays visible" — it proves pass 1's four named examples were patched, not the property.

## Recommendations
1. Hide a heredoc body only when its end marker is quoted; for an unquoted `<<EOF` keep `$( )` and backticks in the body visible.
2. Keep a heredoc body visible whenever the line sends it to a shell in any form (`| bash`, `bash -s`, `/dev/stdin`, `source`).
3. Move heredoc detection into the left-to-right scanner, drop `#` comments, and match end markers exactly as bash does.
4. In the F55 allow path, stop deleting `$(cat H)` to nothing; refuse anything whose raw command holds an unquoted heredoc or a newline outside a quoted heredoc; refuse `-R`/`--repo` on `gh pr create`.
5. Add a before/after property fixture: every hole × git push, gh pr merge, vajra next --advance, git checkout -b session-05-x, with no approval, through the f02d8e1 hook and today's; fail if anything goes from blocked to allowed.
6. Correct the DECISION-007 S173 addendum: drop "anything bash would RUN stays visible" until rec 5 proves it; list the heredoc and comment limits that remain.
7. Before stamping, replace `step 7 — done: <sha>` with a real commit and add the prompt's `## Advice` answers for the tech-lead and design-advisor handoffs.
8. Once recs 1-4 land, run a fresh cold review against the new diff, not a patch-check of this list.

## Handoff Delta
- `~` re-run: fidelity-reviewer handoff replaced (2245 bytes now vs 1654 bytes prior)
- prior stage: this session's earlier fidelity-reviewer handoff
