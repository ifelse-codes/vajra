---
role: fidelity-reviewer
session: 173
agent: claude-code-subagent (verified: toolu_019rHwvdzhtCzS7VWzCSWtTZ)
source-sha: 43e06d8ca200e1cc3299684a7a1a9b268e0d2b08c5f0a2f6410db1333e2a2654
captured: 2026-09-22T04:14:18Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 173

# Fidelity review, pass 4 — session 173 (fresh cold reviewer, from scratch, read-only)

**Verdict:** REJECT — 13 SHIPPED · 4 PARTIAL · 0 NOT-BUILT.

Blocking, introduced by S173: (a) the exception hides the `"$(cat <<'EOF' … EOF)"` span only when everything before it "has balanced quotes", but the test counts quote characters instead of tracking bash's quoting state — an apostrophe inside double quotes, an escaped quote, a quote in a comment or in an earlier heredoc can make the count even while bash is inside an open quote at the span, and then a body line with an odd `'` runs as shell code; the added reads come from the stripped copy and cannot catch it. (b) The F55 allow path refuses `-R`/`--repo` only when followed by space, `=` or end — a glued `-R<value>` or a short-flag cluster with R opens a PR in another repo.

Not blocking (predate S173 or disclosed): `git -c`, aliases, redirected upstream, `--no-verify`; F56 and F57 parked.

Fakest green: "AC5+AC7 property: 0 of 72 …" — labelled a property but run over 18 hand-written shapes, none with an even-count prefix while bash is inside a quote.

## Recommendations
rec 1 — Replace the quote-count check on the text before the span with a real left-to-right quote-state walk, and refuse the exception outright if that prefix contains `#`, a backslash or an earlier `<<`.
rec 2 — Add the start-of-span mismatch cases to `forms()` (a quote of one kind inside the other, an escaped quote, a quote in a comment, a quote in an earlier heredoc body), each with an odd-quote body line; show them red on 3bad781 and green after rec 1.
rec 3 — Make the allow path's repo refusal match every spelling gh accepts: `-R` glued, `-R` inside a short-flag cluster, `--repo=`; add fixtures next to verify:259.
rec 4 — Make the AC1 check assert that the checklist actually printed, running the hook with the built binary first on PATH.
rec 5 — Relabel the "property" PASS lines as "N listed shapes compared, old vs new", and fix the hook comments that say an earlier open quote cannot change the span's meaning.
rec 6 — Decide in writing whether a non-terminal `--advance` piped an explicit `n` should still advance.

## Handoff Delta
- `~` re-run: fidelity-reviewer handoff replaced (2194 bytes now vs 2107 bytes prior)
- prior stage: this session's earlier fidelity-reviewer handoff
