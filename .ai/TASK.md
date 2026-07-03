# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 36 — Real Dogfood Run — COMPLETE

- Ran the real `vajra claude` loop against `/private/tmp/chitra` (agent `-p` run + founder's own interactive session).
- **Darshan founder-confirmed good; brownfield + auth hold live; compression dead in real use.**
- **Headline finding: the enforcement moat leaked** — at L3 the agent shipped 2 real merged PRs + ran ~4 sessions in one chat, unstopped by Vajra's hooks.
- **Second-agent gate: NOT cleared, further from cleared than before.**
- Report: `sessions/session-36-summary.md`. Docs-only (no `src/` edits).

Between sessions. Next: founder picks A/B/C from the S36 report, re-ranked around the enforcement leak.

## Next Session (S37 — founder pick)

- **A (recommended, prompt ready):** `prompts/37-task-enforce-session-boundaries.md` — close the enforcement leak.
- **B (prompt ready):** `prompts/38-task-fix-compression-exit-gate.md` — compression fail-gate, correctness-first.
- **C:** trim the boot-packet cost (no prompt yet — write if picked).

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S35; **next = S40**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** (S36 dogfood proved this needs real enforcement, not just the guard's one tripwire).
- **Enforcement is the moat** — S36 found it leaks in real autonomous sessions; S37 closes it.
