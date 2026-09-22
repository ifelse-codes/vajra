---
role: fidelity-reviewer
session: 173
agent: claude-code-subagent (verified: toolu_01Kcu9zaTDsM8cDyyfT9dBQW)
source-sha: a67fac564fa59604039fe8b6ca6301e6c3467cb4c68ed30fd28746dcc784e6ec
captured: 2026-09-22T03:53:11Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 173

# Fidelity review, pass 3 — session 173 (fresh cold reviewer, from scratch, read-only)

**Verdict:** REJECT — 12 SHIPPED · 5 PARTIAL · 0 NOT-BUILT.

The flaw, as a rule: the one exception in `vajra_heredoc` hides `"$(cat <<'EOF' … EOF … )"`, but its body pattern is lazy and spans lines and is accepted only where the closing line is followed by `)"`. Bash ends a heredoc at the FIRST delimiter line; when that line is not followed by `)"`, the pattern runs on to a later one and hides everything between — lines bash runs inside the `$( )`. With no approval the pre-S173 guard blocked those lines; today they vanish. The additions extractor reads the already-stripped text, so "adding text can only block more" is false for this case. With VAJRA_ALLOW_COMMIT=NN the same span becomes `Q` before the `$`/backtick/newline checks, so a merge or a force-push to main can ride a `gh pr create` body of that shape.

PARTIAL: D4, D6, AC5, AC7, AC9 (step 7 was still `done: <sha>` at the time read).

Fakest green: the "property" check — 15 hand-picked shapes, none with a mid-body delimiter; it would stay green with the regression live.

## Recommendations
rec 1 — Fix the heredoc exception so it ends where bash ends: the body must not contain a line equal to the delimiter, and the match is accepted only if that first closing line is followed by `)"`; otherwise leave the text visible.
rec 2 — Run the "additions" extractor (`$( )`, backticks, `eval`/`sh -c`) on the ORIGINAL command, not on the text the exception has already stripped.
rec 3 — On the F55 allow path, replace a heredoc span with `Q` only after checking that its body has no line equal to the delimiter; otherwise send the command to the human.
rec 4 — Add a mid-body-delimiter shape to `forms()` in both loops, and confirm it goes red on the current hooks before the fix and green after.
rec 5 — Reword the DECISION-007 S173 addendum: drop "cannot regress anything", describe the property check as "N named shapes", and fix the out-of-order list numbering.
rec 6 — Fill `## Execution` step 7 with the real commit sha before closing.
rec 7 — Restate Deliverable 4 in the prompt to match what shipped, or else build what it says.

## Handoff Delta
- `~` re-run: fidelity-reviewer handoff replaced (2220 bytes now vs 2147 bytes prior)
- prior stage: this session's earlier fidelity-reviewer handoff
