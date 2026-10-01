---
role: plan-advisor
session: 182
agent: claude-code-subagent (verified: toolu_01K6vCs5vFHJxTH25oH4UA9o; text-sha: 7ffd2ca58a16b581be23fbea455a517df5b7254fe6d7ebe751b033b786f47a2f)
source-sha: b36622232bddbea92a6d544f1bf0b6605d3a842c1cbff6122f96f79b14ccbd48
captured: 2026-10-01T07:38:50Z
cost_usd: null
---

# Plan-advisor handoff — session 182

# Plan-advisor handoff — session 182

All 8 acceptance criteria are covered. I kept the tech-lead's order (rec 3) and split Part 3 into two commits so each stays at 3 files or fewer.

Sources: `prompts/182-task-finish-s181-gaps.md`, `.ai/handoffs/session-182-tech-lead.md`, and the step format from `prompts/181-task-close-the-loopholes.md` (`(covers: N)` at the end of the line).

## Proposed plan

1. Part 6: the approvals guard in `scripts/hook-pre-bash.sh` blocks on where a write lands, not on any `>` token — `2>&1`/`>&N` are not writes; redirect targets (`>`, `>>`, `2>`, also after a `2>&1`) and write-command arguments (`tee`, `cp`, `mv`, `rm`, `touch`, `sed -i`) into the folder block; an interpreter (`python3`/`perl`/`node`/`ruby`) naming the folder still blocks, with a message naming the read-only alternative; fixture test drives the hook with real JSON payloads (covers: 7)
2. Part 1: `scripts/verify-session-181.sh:75` whole-suite check becomes positive (at least one `test result: ok`, no `FAILED`, non-zero cargo exit fails); fixture runs the check against a stub `cargo` on PATH that fails to compile and proves the check goes red for that reason (covers: 1)
3. Part 2: gate-level obeyed-handoff test in `tests/stamp_gate.rs` — scratch repo, valid obeyed-check handoff passes `vajra next --check-obeyed`, edit its findings, same command blocks (covers: 2)
4. Part 3a: the scaffold ships the Write/Bash approvals guards into `.ai/hooks/`, stamped, built from the same source as the step-1 guard (one copy, `include_str!`); test scaffolds a scratch project and drives its hook with an agent Write and an agent Bash into `.ai/approvals/` → exit 2 (covers: 3)
5. Part 3b: `vajra init --sync-fleet` adds or upgrades those stamped hooks in an old project (skip-if-edited per S136); test makes an old-style scratch project with no hooks, runs `--sync-fleet`, asserts the hooks are present and block (covers: 3)
6. Part 4: `--sync-fleet` on a project with no `session_rules_from` prints the exact line to add and the session to use, and writes nothing to the settings file (test compares the settings file bytes before and after, in a scratch repo) (covers: 4)
7. Part 7: build vajra from this branch; in rudra record `git -C /Users/suman/playground/rudra log -1`, run `<branch-build>/vajra init --sync-fleet`, add `session_rules_from: N` exactly as the report says, pipe a simulated agent write into rudra's approvals hook → exit 2; keep the raw capture in the scratchpad, confirm rudra HEAD is unchanged; no commit in rudra (covers: 8)
   --- CUT LINE: if the ~2h cap bites, Part 5 (step 8) is carried to S183 in writing ---
8. Part 5: the `--allow-all` record is tied to one session number (the design-advisor picks branch vs session named at launch, citing DECISION-011); `tests/approval_cli.rs` proves a record for session A does not approve session B (`src/approval/mod.rs`, `src/cli/launch.rs`) (covers: 5)
9. `scripts/verify-session-182.sh` re-runs the real things (the step 1–6 and 8 tests by name, the step-1 hook fixture, the step-2 stub-cargo fixture, the positive whole-suite check) with no source greps; the rudra check prints SKIPPED, never PASS, when rudra is absent; `scripts/demo-session-182.sh` shows the guard passing a read and blocking a write, and the `--sync-fleet` report (covers: 6)
10. Close: `sessions/session-182-summary.md` records the rudra command, report text, hook exit-2 output and HEAD before/after; a fresh cold fidelity review recorded with `--inputs-sha 182`; `scripts/verify-closeout.sh` exits 0 on the branch before merge (covers: 6, 8)

## Coverage

| Acceptance | Steps |
|---|---|
| 1 | 2 |
| 2 | 3 |
| 3 | 4, 5 |
| 4 | 6 |
| 5 | 8 (below the cut line) |
| 6 | 9, 10 |
| 7 | 1 |
| 8 | 7, 10 |

## Ambiguities flagged

- Who wires the shipped hooks in an old project? Part 3 says `--sync-fleet` ships them; Part 4 says `--sync-fleet` never edits the project's settings file. Which file registers them as hooks must be settled before step 4, or acceptance 3 and 8 could pass by calling the script directly while a real agent session never runs it.
- "The session to use" in Part 4 — where the number comes from is unstated.
- Part 5's design question belongs to the design-advisor.

rec 1 — Adopt the 10-step plan in the order 6 → 1 → 2 → 3a → 3b → 4 → 7 → 5 → close, with the cut line between step 7 (rudra live) and step 8 (Part 5).
This is the tech-lead's order. Part 3 is split so each commit stays at 3 files or fewer. Step 7 needs steps 1, 4, 5 and 6 committed and built first.

rec 2 — If the cut line is used, change the prompt in writing before the cold review: mark Deliverable 5 / Acceptance 5 as carried to S183 by name. Don't leave step 8 cited but unbuilt.
Otherwise the Planner gate still sees acceptance 5 as covered, and the reviewer finds it NOT-BUILT.

rec 3 — Keep one copy of the guard. Build the scaffolded `.ai/hooks/` guards from the same source file as `scripts/hook-pre-bash.sh` (via `include_str!`), never as a second hand-kept copy.
A second copy would drift ("derive, don't hand-copy").

rec 4 — Before step 4, settle which settings file registers the shipped hooks in an old project, given that Part 4 forbids editing it. Prove acceptance 3 and 8 through that real path, not only by piping JSON into the script.
A hook file on disk that no agent session runs is "registered ≠ run" (S129).

rec 5 — Prove acceptance 1 with a stub `cargo` on PATH that fails to compile and exits non-zero. Never break the real build to do it.
The fixture must fail for the right reason (S122).

rec 6 — In step 1's fixture, also test that `2>` aimed at a path inside the folder still blocks (as do `2>&1 > <folder>/x`, `>>`, `tee` and `cp`), alongside `cat <folder>/x 2>&1` passing.
Treating `2>&1` as harmless must not let `2><folder>/x` through (S173).

rec 7 — In the verify script, report the rudra check as SKIPPED, never PASS, when rudra is absent. The evidence for acceptance 8 is the summary's recorded live output plus rudra's unchanged HEAD.
A check that passes because nothing was there is the fake pass S178 caught.

rec 8 — In step 7, call the branch build of vajra by its absolute path, not the `vajra` on PATH, and record rudra's `git log -1` before and after.
The installed vajra may be stale; rudra's unchanged HEAD is the only proof the no-commit rule held.

## Handoff Delta
- `+` new: first plan-advisor handoff for this session (6388 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
