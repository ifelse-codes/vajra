# Session 186 — Summary (CODE: the fixes from the S185 ground truth)

**Branch:** `session-186-s185-fixes` · **Brief:** `prompts/186-task-s185-fixes.md` (approved: `vajra approve 186`, founder's own terminal; record committed in 160cf05) · **Review:** `sessions/session-186-review.md` · **Design:** the brief's `## Design`; DECISION-007 and DECISION-011 S186 addenda (ef560a6)

## Goal achieved?
Yes. All six deliverables the S185 ground truth picked are built, each with a check that runs the real thing and goes red at the commit S186 started from (b10a1a6) for the reason it names. F110 (b) finished inside the cut line — no split. `scripts/verify-session-186.sh` passes 25/25 (≈2m15s), `scripts/verify-session-132.sh` 13/13 for the first time since S135, the demo 8/8 live checks, demo-132 8/8 again, 569 lib tests + every integration suite pass, `scripts/ci-lint.sh` clean, and the guard tests pass under macOS's bash 3.2.57 and bash 5.

## Fidelity map (prompt `prompts/186-task-s185-fixes.md`)
| # | Requirement | Status | Evidence |
|---|---|---|---|
| D1 | F113 `obeyed_blocks_from:` — strict key, Vajra only, absent → WARN forever saying why, malformed → BLOCK naming the line; design-advisor words drop the number | SHIPPED | 62bfe63, 2f4c59d, 9ef5c65, 596db24; unit tests in `src/obeyed/mod.rs`; verify-186 rows 1–4 |
| D2 | F110 (b) — the guard reads where a redirect really writes; fail closed on the listed cases; (a)'s message | SHIPPED | 3a4fca9; verify-186 F110 rows; `tests/approvals_guard.rs` |
| D3 | S182 recs 1 (`..`), 5 (writers, shells), 2 (merge) — add-only | SHIPPED | 3a4fca9 (1, 5), 9dcec17 (2) |
| D4 | F114 — fresh project `--ledger` says "no reviewed sessions yet", exit 0 (both scripts) | SHIPPED | 0dd33f1; also `--ledger-verify` (exit 128 before) |
| D5 | F115 — verify-132's `--advance` fixture records a real tech-lead; both sides of F113 | SHIPPED | 4c34e51 |
| D6 | N1 — `[HOOK BLOCK]` lines on stderr | SHIPPED | c6bbeb9; the two hooks are Vajra-only (not in `vajra init`'s list), so there is no scaffold copy |
| AC1 | fresh project at 132: WARN "does not block" and advances; key 132 refuses; `x` refuses naming the line; Vajra still blocks from 132 | SHIPPED | verify-186 rows 1–4 (the b10a1a6 binary BLOCKS the no-key case); verify-132 check 7(c) advances |
| AC2 | heredoc / commit `<…>` / `> quote` pass; the six listed writes block | SHIPPED | verify-186: 3 pass now (all 3 blocked at b10a1a6), 10 still block |
| AC3 | every command the S182 guard blocked still blocks, except a listed set | SHIPPED | `every_command_the_s182_guard_blocked_still_blocks` (git show e1c348e guard); the listed set is `reads()`: `cat <folder>/x > /tmp/copy`, `cat .ai//approvals/x > y`, the three AC2 texts, a commit message naming `hook-approvals-guard.sh` |
| AC4 | `.ai/hooks/../approvals/x` blocked for Write and Bash; `find -delete`, `git checkout --`, `sh x.sh` blocked | SHIPPED | verify-186 (the Write case passed at b10a1a6) |
| AC5 | `--sync-fleet` adds no duplicate when a hook is wired under another matcher; test red before | SHIPPED | 9dcec17; verify-186 lifts the test into a b10a1a6 worktree: fails "runs it twice" |
| AC6 | fresh project `--ledger` exit 0 + the line | SHIPPED | verify-186 (b10a1a6: exit 1, prints nothing) |
| AC7 | verify-132 fully green incl. `advance-really-binds-on-an-unjudged-obeyed` | SHIPPED | verify-186 runs it: 13/13 |
| AC8 | GT-blocked Write and `git commit` carry `[HOOK BLOCK]` on stderr | SHIPPED | verify-186 N1 rows: new = exit 2, stderr; b10a1a6 = exit 2, stdout |

## What I did NOT build
- No scaffold copy of `hook-pre-bash.sh` / `hook-pre-write.sh` exists, so D6's "and their scaffold copies" changed nothing — said, not hidden.
- The brief said "a symlink in the target's parent path → fail closed". Built instead: the existing part of the path is resolved by the kernel (`cd -P`), so a symlink is FOLLOWED to where the write would really go; only a linked LAST component (symlink or hard link) blocks. Reason: refusing every symlink blocks every `/tmp` target on macOS (`/tmp` → `/private/tmp`), including AC3's own read. Recorded in DECISION-011's S186 addendum.
- rudra does not have any of this until the founder runs `vajra init --sync-fleet` there after merge.

## Fakest green
The guard is still a text reader. AC2/AC4 are green on the commands listed; a path assembled while the command runs (`d=.ai; … $d/appr…`) still gets past, and so does anything that writes without naming the folder. The new rule also **over-blocks** in a new way: a quote right after a `>` in a command naming the folder blocks (`-m "a -> b"`), and I hit the guard four times myself while building it. Second: F113's key is agent-editable — Vajra's own repo can switch its blocking off by deleting one line, and only the diff shows it.

## Found on the way (not fixed)
- **`scripts/verify-session-133.sh` is red at main** — the same 3 checks red at b10a1a6 (`real-dispatch-passes`, `fixture-red-on-bypass-green-on-rename` — its probe patches a line S181's 4addc3a rewrote, `k-of-8-unchanged…`) plus `s133-passes-its-own-gate-by-real-use` at main. Same class as F115 / S185 N3: a gate's old verify script went red and nobody re-ran it. → backlog, on the S190 ground-truth checklist with N3.
- **`scripts/demo-session-132.sh` case 7** had the same S135 staleness as F115 — fixed in cfd7f86 because F113 touched it.
- **The design-advisor's rec 12 was wrong:** it read the working tree after N1 had landed and reported the lines "already on stderr at HEAD". Refused with `git show b10a1a6` evidence; the AC8 test it asked for was built anyway.

## Cost
$0 in paid runs. Fleet: tech-lead (~31k subagent tokens), design-advisor (~145k), then the cold fidelity review and the release-coordinator at close.

## Next — 3 options (ranked)
1. **(Recommended) rudra S18 with the new guard — interactive.** You run `vajra init --sync-fleet` in rudra and use it; we fix what you hit. Why: the guard now judges real commands, and only real use shows its new over-blocks. Risk: new over-blocks show up mid-session.
2. **F67 — the receipt reads the tool's own cost for interactive runs.** The one wrong number every user sees (~5× high). Risk: Claude Code may not write a cost into an interactive run's transcript.
3. **The non-Claude tools brainstorm (F91, F94, F95).** Promised since S179. Risk: a design session — nothing a user runs comes out of it.
