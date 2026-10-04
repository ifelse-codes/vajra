# Session 186 — Summary (CODE: the fixes from the S185 ground truth)

**Branch:** `session-186-s185-fixes` · **Brief:** `prompts/186-task-s185-fixes.md` (approved: `vajra approve 186`, founder's own terminal; record committed in 160cf05) · **Review:** `sessions/session-186-review.md` · **Design:** the brief's `## Design`; DECISION-007 and DECISION-011 S186 addenda (ef560a6)

## Goal achieved?
Partly — by the founder's call, after three cold-review REJECTs. F113, F114, F115, N1 and S182 recs 1/2/5 are built, each with a check that runs the real thing and goes red at the start commit (b10a1a6) for its named reason. **F110 (b) is NOT shipped:** I built the target-reading guard; the first cold review REJECTED it (P1 a backslash-newline after `>`, P2 awk's own `>`, P3 a disguised `cd` — all writes into the folder that the S182 guard blocks); I fixed those exact spellings; the fresh second review REJECTED again on their cousins (P4 zsh `>>!`/`>&|`, P5 a hidden `cd` after `if`/`{`/`builtin`, P6 `/usr/bin/awk`, P7 a link made earlier in the command). The founder chose to split (b) out (2026-10-04): the S182 redirect rule is back (fb467a0), so F110's false blocks remain, and the block message now names `git commit -F`. A third review found my P1 fix (joining backslash-newlines) had broken "only adds" (R1–R3); fixed in 33235cd so every S182 check reads the original command unchanged. `scripts/verify-session-186.sh` passes 31/31, `scripts/verify-session-132.sh` 13/13 (first time since S135), the demo 8/8, demo-132 8/8, 569 lib tests + every integration suite (guard tests under bash 3.2.57 and 5), `scripts/ci-lint.sh` clean.

## Fidelity map (prompt `prompts/186-task-s185-fixes.md`)
| # | Requirement | Status | Evidence |
|---|---|---|---|
| D1 | F113 `obeyed_blocks_from:` — strict key, Vajra only, absent → WARN forever saying why, malformed → BLOCK naming the line; design-advisor words drop the number | SHIPPED | 62bfe63, 2f4c59d, 9ef5c65, 596db24; unit tests in `src/obeyed/mod.rs`; verify-186 rows 1–4 |
| D2 | F110 (b) — the guard reads where a redirect really writes; fail closed on the listed cases; (a)'s message | NOT-BUILT (split out by the founder) | built 3a4fca9 → pass 1 REJECT → 1409a3c → pass 2 REJECT → founder split, S182 rule restored fb467a0. Only (a)'s message shipped: the redirect block names `git commit -F`. Design + P1–P7 recorded in DECISION-011 S186 addendum and `tests/approvals_guard.rs` for the (b) session |
| D3 | S182 recs 1 (`..`), 5 (writers, shells), 2 (merge) — add-only | SHIPPED | 3a4fca9 + 1409a3c + fb467a0 (1, 5: `..`, a cwd inside the folder, new writers/shells/awk at command position with or without a path, the S182 lists on the de-quoted copy), 9dcec17 (2) |
| D4 | F114 — fresh project `--ledger` says "no reviewed sessions yet", exit 0 (both scripts) | SHIPPED | 0dd33f1; also `--ledger-verify` (exit 128 before) |
| D5 | F115 — verify-132's `--advance` fixture records a real tech-lead; both sides of F113 | SHIPPED | 4c34e51 |
| D6 | N1 — `[HOOK BLOCK]` lines on stderr | SHIPPED | c6bbeb9; the two hooks are Vajra-only (not in `vajra init`'s list), so there is no scaffold copy |
| AC1 | fresh project at 132: WARN "does not block" and advances; key 132 refuses; `x` refuses naming the line; Vajra still blocks from 132 | SHIPPED | verify-186 rows 1–4 (the b10a1a6 binary BLOCKS the no-key case); verify-132 check 7(c) advances |
| AC2 | heredoc / commit `<…>` / `> quote` pass; the six listed writes block | PARTIAL (split) | the six writes block (verify-186); the three passes do NOT pass — F110 (b) split out; they block with the `git commit -F` message (`f110_still_blocks_and_names_the_way_past`) |
| AC3 | every command the S182 guard blocked still blocks, except a listed set | SHIPPED (after pass 3) | pass 3 found it FALSE at fb467a0: the backslash-newline join replaced the text the S182 checks read (R1: `true #x\<NL>rm …` passed) and an unenterable folder made the guard exit 1 (R3). 33235cd: every S182 check reads the command exactly as written, and the joined copy is only extra lines, so a line-by-line grep can only match more; the folder lookup never exits. Corpus incl. P1–P7 and R1–R3 |
| AC4 | `.ai/hooks/../approvals/x` blocked for Write and Bash; `find -delete`, `git checkout --`, `sh x.sh` blocked | SHIPPED | verify-186 (the Write case passed at b10a1a6) |
| AC5 | `--sync-fleet` adds no duplicate when a hook is wired under another matcher; test red before | SHIPPED | 9dcec17; verify-186 lifts the test into a b10a1a6 worktree: fails "runs it twice" |
| AC6 | fresh project `--ledger` exit 0 + the line | SHIPPED | verify-186 (b10a1a6: exit 1, prints nothing) |
| AC7 | verify-132 fully green incl. `advance-really-binds-on-an-unjudged-obeyed` | SHIPPED | verify-186 runs it: 13/13 |
| AC8 | GT-blocked Write and `git commit` carry `[HOOK BLOCK]` on stderr | SHIPPED | verify-186 N1 rows: new = exit 2, stderr; b10a1a6 = exit 2, stdout |

## What I did NOT build
- **F110 (b)** — split out by the founder after two REJECTs (above). F110's false blocks remain; the message names the way past. Recorded for its own session: the design, both passes' probes P1–P7 (in the corpus), and the lesson — loosening a text guard is a removal and needs a class-level argument, not a corpus grown one probe at a time.
- No scaffold copy of `hook-pre-bash.sh` / `hook-pre-write.sh` exists, so D6's "and their scaffold copies" changed nothing.
- rudra does not have any of this until the founder runs `vajra init --sync-fleet` there after merge.

## Fakest green
I twice called the guard "only adds" when it did not: the fix for pass 1's P1 (joining backslash-newlines) silently changed what the S182 checks read, and only the third cold review saw it. The argument for "only adds" now is structural (the S182 checks read the original text, unchanged, plus extra lines), checked by a corpus — still a corpus. And the hard part, F110 (b), was taken back out. The session's headline fix for the founder's own daily annoyance (the commit-message false block) did not ship. Second: F113's key is agent-editable — Vajra's own repo can switch its blocking off by deleting one line, and only the diff shows it.

## Found on the way (not fixed)
- **`scripts/verify-session-133.sh` is red at main** — the same 3 checks red at b10a1a6 (`real-dispatch-passes`, `fixture-red-on-bypass-green-on-rename` — its probe patches a line S181's 4addc3a rewrote, `k-of-8-unchanged…`) plus `s133-passes-its-own-gate-by-real-use` at main. Same class as F115 / S185 N3: a gate's old verify script went red and nobody re-ran it. → backlog, on the S190 ground-truth checklist with N3.
- **`scripts/demo-session-132.sh` case 7** had the same S135 staleness as F115 — fixed in cfd7f86 because F113 touched it.
- **The design-advisor's rec 12 was wrong:** it read the working tree after N1 had landed and reported the lines "already on stderr at HEAD". Refused with `git show b10a1a6` evidence; the AC8 test it asked for was built anyway.

## Cost
$0 in paid runs. Fleet: tech-lead (~31k subagent tokens), design-advisor (~145k), fidelity-reviewer pass 1 (~143k), pass 2 (~119k), pass 3, release-coordinator as the one judge of every `obeyed:` answer.

## Next — 3 options (ranked)
1. **(Recommended — the founder's pick) rudra S18 with the S186 fixes — interactive.** You run `vajra init --sync-fleet` in rudra and use it; we fix what you hit. Why: F113 changes rudra's close, and the guard blocks more. Risk: F110 false blocks still happen (workaround: `git commit -F`).
2. **F67 — the receipt reads the tool's own cost for interactive runs.** The one wrong number every user sees (~5× high). Risk: Claude Code may not write a cost into an interactive run's transcript.
3. **The non-Claude tools brainstorm (F91, F94, F95).** Promised since S179. Risk: a design session — nothing a user runs comes out of it.
