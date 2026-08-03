# Session 112 — CODE (proposed): downstream handoff-consumption

> **Status:** PROPOSED at S111 closeout, NOT YET founder-approved. S111 closed the fleet's
> def-vs-dispatch wire; the remaining S110 GT backlog is downstream handoff-consumption (this
> candidate, "B") or a second fleet role ("C"). This session recommends **B**, on the reasoning that a
> lone unread handoff gets more orphaned, not less, if a second role doubles the count before anything
> reads the first. Confirm or redirect at S112 kickoff before executing.

## Goal

`vajra next --role researcher --from <findings>` writes a governed, validated handoff to
`.ai/handoffs/session-NN-researcher.md` — but nothing downstream reads it. The 8-station pipeline and
the fleet are, right now, two overlapping stories that never actually touch: a founder (or a future
agent) has to know to go look in `.ai/handoffs/` by hand. Make at least ONE existing station
(recommend: the Analyst, since a researcher's findings naturally feed the WHAT stage) surface a
session's researcher handoff automatically when one exists for that session — so the fleet's output
actually feeds the pipeline it claims to be part of, not just a filed-away artifact.

## Non-goals (do not build this session, pending founder confirmation)

- A second fleet role — stays deferred (S110 candidate C) until this is proven, unless the founder
  picks C instead at kickoff.
- Changing the handoff format itself (frontmatter contract, `## Handoff Delta`) — S109/S111 both
  treat that as locked; this session only adds a READER, not a new WRITER contract.
- An unattended `claude -p` dispatch mode — still DECISION-007-deferred.
- No 8th top-level command. This should ride an existing surface (`next`), not add one.

## Acceptance criteria (draft — refine at kickoff)

1. At least one existing station's `vajra next` output visibly surfaces the current session's
   researcher handoff when one exists (e.g., the Analyst packet includes a "Researcher findings
   available: .ai/handoffs/session-NN-researcher.md" line, or inlines a summary).
2. Absence is silent and harmless — a session with no handoff behaves exactly as today, no new
   warnings or failures.
3. A real end-to-end proof: govern a real (or realistic fixture) handoff, then show the consuming
   station's output actually changed because of it — not just "the file exists, trust me."
4. `cargo test --lib` green; CI both OS; a `verify-session-112.sh` + `demo-session-112.sh` pair.
5. Independent cold review (fed only prompt + diff) — SHIPPED/PARTIAL/NOT-BUILT per numbered
   requirement, plus the fakest green, disclosed.

## Guardrails

- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Branch: `session-112-<slug>`. Approval token required before any commit.
- Communicate in the plainest English (founder standing request).
- New chat for S112 — confirm scope (B vs C, or something else) before building.
