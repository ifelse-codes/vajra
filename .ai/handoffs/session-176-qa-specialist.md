---
role: qa-specialist
session: 176
agent: claude-code-subagent (verified: toolu_016fCRZhj3KT2yHyfL2UZHpP)
source-sha: a513a2a7e2ec3be212a3a048982bdf0701b5b88cdd09935f6812123308e03fb5
captured: 2026-09-23T17:13:08Z
cost_usd: null
---

# Qa-specialist handoff — session 176

# QA evidence brief — session 176 (F70, the Planner's Dangling state)

Worked at 4b1df85; mutations in a separate scratch worktree; tree left as found.

## 1. verify-session-176.sh — real run
Exit 0, 10 pass / 0 fail. All 10 checks execute a binary or `cargo test` — none hollow, none structural grep. Weak spots: check 1 only tests the old binary exists (I rebuilt it independently from cd4302b in a fresh worktree — byte-identical); the rudra sweep silently NOTEs when ~/playground/rudra is absent; the sweep compares only the verdict line.

## 2. Independent old-vs-new sweep
By session number (175 vajra + 10 rudra files, verdict + exit + full output): 3 flips, 0 output-only changes, 0 rudra flips. Per file in isolation (185 files — 00/01 each have two files and `--check-plan N` reads one, so `00-task-brownfield-onboarding.md` and `01-task-kickoff.md` are shadowed): again exactly 3.
- 155 READY/0 → NOT READY/1 — no `## Acceptance` at all; 4 steps cite `covers: 1`. REAL brief defect (closed GT session).
- 157 READY/0 → NOT READY/1 — table now read; no step covers AC5. REAL plan gap, never checked before.
- 166 READY/0 → NOT READY/1 — table read; no step covers AC1. REAL plan gap.
Table parsing was necessary: without it (mutant M3) 12 flip (155 + all 11 table prompts) — 9 false blocks.
Live case from rudra's own git: `bc58af3` is the literal wiped state — old READY/0, new NOT READY/1 naming 1–7; restored `8014a94` READY on both. The author's fixture is a reconstruction from a later revision, not the literal wipe; same verdict.

## 3. Mutations (against full verify)
M1 drop Dangling from blocks() — caught only by the unit test: `PlanState::blocks()` has NO production caller (the real gate is `PlanVerdict::blocked()` = reasons non-empty, from the exhaustive match in plan_gate). M2 never return Dangling — caught (8 fail). M3 no table rows — caught (3). M4 stations Dangling→passed — caught (2). M5 Dangling only when list empty — caught. M6 drop dedup — survived, harmless (push_citations dedups). M7 drop lowercase `ac` arm — SURVIVED (untested). M8 drop "`N.` lines" cause — caught. M9 Uncovered wins — caught. Every PlanState consumer is an exhaustive match, no wildcard.

## 4. Odd inputs + false blocks
Correct: `covers: 0` blocks naming 0; `| AC01 |` → 1; `| ac2 |` works; table row outside Acceptance ignored; a missing number cited twice named once; no criteria + no citations READY; Acceptance after Plan works; `AC1a` ignored.
NEW FALSE BLOCKS (old READY; real criteria correctly cited): `| Ac1 |`, `| **AC1** |`, `| AC 1 |`, `| AC-1 |`, numeric `| 1 | x |`, `1)`, `**1.**`, `- AC1: x`, a `### sub-heading` inside Acceptance (any `#` closes the section — and the message "not written as `N.` lines" is WRONG there), a code fence with a `# comment` inside Acceptance ("1 numbered item found, cites 2" — misleading). None occur in either repo today. Doc mismatch: `ac_table_row` claims case-insensitive but only AC/ac matched. Small hole: `covers: 99999999999` overflows u32 → silently dropped → READY.

## 5. Never exercised
The session-advance command on a dangling plan (the session-guard blocked my attempt; not worked around; by source it uses the same plan_gate().blocked()). The `--steps` Planner hint for Dangling still says "mark each step `covers: N`" — wrong fix for a deleted list. Lowercase labels.

rec 1 — Stop false blocks on real-user shapes: keep `###` sub-headings (and `#` lines inside code fences) from closing Acceptance, and make the Dangling message name the actual cause instead of always "not `N.` lines".
rec 2 — Make `ac_table_row` truly case-insensitive (or fix its doc) and unit-test a lowercase/mixed label (kills M7).
rec 3 — Change the `--steps` Planner hint for a Dangling plan to point at restoring `## Acceptance` from git, not "mark each step `covers: N`".
rec 4 — Delete `PlanState::blocks()` or route plan_gate and the session-advance path through it; it has no production caller, so the non-exhaustive-blocks() guard protects dead code.
rec 5 — Make the rudra sweep FAIL or a counted SKIP when ~/playground/rudra is absent, not a silent NOTE.
rec 6 — Add a fixture-level session-advance run on a dangling plan to verify (outside a session-owning chat).
rec 7 — In the sweep compare exit code and reason too, and check each prompt file in isolation so the shadowed 00/01 files are included. Low priority: tightens Vajra's own paperwork.

## Handoff Delta
- `+` new: first qa-specialist handoff for this session (4480 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
