---
role: design-advisor
session: 167
agent: claude-code-subagent (verified: toolu_01PwFgNqPDJbBBSo35y1YM8P)
source-sha: bad2f4315e12ffbf7b08e1193a63b815f572b1c5f4a9c34abcedbc1b5a7b0a18
captured: 2026-09-14T08:09:41Z
cost_usd: null
---

# Design-advisor handoff — session 167

**Brief:** Design advice for S167 (the terminal demo is the human demo). design-significant: yes. New record DECISION-009. Open question decided: option (ii), kept narrow — an unstamped demo template whose sha256 exactly matches a template Vajra once shipped is a provable old render (StaleRender); anything else stays Drifted.

Recommendations:
1. rec 1 — Record `design-significant: yes`: a new scaffolded file, a rewritten inherited template, two files added to the --sync-fleet set, and interactive_html retired are interface changes.
2. rec 2 — Write a new record `docs/decisions/DECISION-009-terminal-demo.md` (next free number); do not only cite DECISION-007/008.
3. rec 3 — Do not cite a "DECISION-007 S146 addendum": it does not exist (addenda stop at S143). Cite S136, S141, S142, S143 only.
4. rec 4 — Design bullets (condensed): rests on DECISION-007 S136/S141/S142/S143 (kit + template join SYNC_HOOKS, shell-comment stamp, no new sync command) and DECISION-008 (four markers + gate logic unchanged; kit prints each marker where its section renders, only when not in a terminal); the demo script stays the one source; an unfilled outline fails by name; deck mode only when stdin AND stdout are terminals.
5. rec 5 — Option (ii): frozen sha256 list of shipped template versions → StaleRender. Safe (identical bytes = nothing customised; no match falls back to Drifted). (i) is worse: --overwrite-drifted also overwrites every other drifted file. Not "invented provenance" (exact byte match is a pure function of bytes, unlike git blame/timestamps). Not a hand-typed copy of a live value: closed history, cannot grow once renders are stamped. Derive the list once from git history, record the command, add a test that re-derives from git when .git exists. Apply only to this template. Risk: a copy from an unlisted source commit stays Drifted — incomplete, never unsafe.
6. rec 6 — State plainly in DECISION-009 that (ii) departs from the S141/S142 limit "smooth going forward, never retroactively", and why.
7. rec 7 — Rejected alternatives with reasons: keep agent-made HTML (the split is the root cause; the gate re-runs a script the human never sees); a renderer inside the binary (8th command or dependency, a second source, older vajra loses its demo); Vajra-built slides now (changes the Demo-er gate logic; S168's job).

## Handoff Delta
- `+` new: first design-advisor handoff for this session (2358 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
