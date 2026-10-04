---
role: fidelity-reviewer
session: 186
agent: claude-code-subagent (verified: toolu_01R4tsxToBaYNpN2AnZfKBXx; text-sha: ce7fb1b6f1bdc4a60d1fe69a7ed0509b671a9ebf91faa20c13e9af1bca6b15bf)
source-sha: a68bfc4e8503cbbcd83fb9fb9bfca061a13db3e4e478560b370f27d7db0617af
captured: 2026-10-04T09:24:09Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 186

(condensed) — the builder recorded this from the subagent's report: the verdict, the per-requirement grades, the three probes and recs 1–8 are as given; the table's evidence cells and some reasoning are shortened.

## Fidelity review: Session 186 (cold, adversarial) — pass 1

**Verdict:** REJECT

Count: 12 of 15 SHIPPED, 3 PARTIAL, 0 NOT-BUILT.

The work is mostly a faithful build of the contract. One part is not: the guard's headline promise. The guardrail says the guard changes "ADD-only except the listed proven non-writes", and AC3 asks for the same. DECISION-011's S186 addendum states it as fact: "every other command the S182 guard blocked still blocks". That is false: three kinds of command name `.ai/approvals` literally, really write into it, were blocked by the S182 guard, and now exit 0. None are in `reads()`.

| Req | Verdict | Evidence (condensed) |
|---|---|---|
| D1 F113 | SHIPPED | strict reader `src/obeyed/mod.rs:84-116`; error pushed every run `:485-488`; three wordings `:566-579`; constant gone; `.ai/CONSTRAINTS.yaml:22`; mandate words fixed |
| D2 F110 (b) | PARTIAL | backslash-newline after `>` read as "no next word" (`:104-105`); the cd check is a word match (`:151`); symlinks in the parent path are followed, not refused (disclosed deviation) |
| D3 S182 recs 1, 5, 2 | SHIPPED | rec 1 `:51`, `:68-70`; rec 5 `:186-197`; rec 2 `src/cli/init.rs:956-998`, `matcher_covers` |
| D4 F114 | SHIPPED | both close scripts print the line, exit 0 |
| D5 F115 | SHIPPED | `scripts/verify-session-132.sh:324-394` |
| D6 N1 | SHIPPED | four lines `>&2`; neither hook ships with `vajra init` |
| AC1 | SHIPPED | verify-186 `:25-51` + verify-132 7(c) |
| AC2 | SHIPPED | `reads()`, `s186_writes()`, verify-186 `:76-86` |
| AC3 | PARTIAL | `every_command_the_s182_guard_blocked_still_blocks` covers a hand-picked list; the property it names is false (P1–P3) |
| AC4 | SHIPPED | `tests:172-173` and Bash; `s186_writes` |
| AC5 | SHIPPED | `init.rs:3095`; red at b10a1a6 "runs it twice" |
| AC6 | SHIPPED | verify-186 `:112-119` |
| AC7 | SHIPPED | fixture reaches the gate (13/13 is the builder's claim; not run) |
| AC8 | SHIPPED | verify-186 `:124-140` |
| Guardrail ADD-only | PARTIAL | broken by P1–P3 |

### Probes — name the folder, really write into it, exit 0 (all blocked by the S182 guard)
- P1 (high): `echo x > \` newline `.ai/approvals/y` — `NAMED` drops the `\`, the scan meets a newline, `w==""`, continues; the shell joins the lines and writes.
- P2 (high): `awk -v f=.ai/approvals/x 'BEGIN{print 1 > f }'` — `> f` read as a shell redirect to `$CWD/f`; awk writes into the folder.
- P3 (high): `${x}cd .ai/approvals && echo x > y`, `"$x"cd …`, `$'\x63d' …` — the cd check needs a separator before `cd`. zsh-only (medium): `chdir .ai/approvals && echo x > y`; `echo x >! .ai/approvals/y` (target read as `!`).
- Older hole, not a regression: `cd .ai/approvals` in one call, `echo x > y` in the next.

### Probes 3–4
- F113 reader matches the brief; a mistyped key name or a deleted CONSTRAINTS file reads as "no key" (minor).
- Merge (rec 2): correct, safe direction.

### Probe 5 — `obeyed:` answers doubted (for the judge)
- tech-lead rec 2 → ef560a6 is the DECISION addenda; the skip line landed in ac1b5da.
- tech-lead rec 3 → 3a4fca9: corpus and guard in one commit; "every command e1c348e blocks" premise false (P1–P3).
- design rec 7 → 3a4fca9: the build follows symlinks; a reasoned refusal recorded as `obeyed:`.
- tech-lead rec 1 → 4c34e51: (b) shipped bundled with recs 1/5, so the clean cut was never possible. Minor.

### Fakest green
`every_command_the_s182_guard_blocked_still_blocks` — a universal name over a finite builder-written list. The summary overclaims AC3 SHIPPED; its fakest-green omits P1–P3; `## Execution` step 11 claims closeout and the next prompt done; `.ai/SESSION-BOOT.md:7` reads "186 — CLOSED. NO-CODE ground truth".

rec 1 — In `hook-approvals-guard.sh`, block when a `>` is followed (after spaces) by a backslash-newline in the command as written, instead of treating it as "no next word", and add P1 to `s186_writes()`.
rec 2 — Restore the S182 floor for `>` signs the shell may not own: block on a leftover `>` when a non-shell program that writes with `>` runs, or add awk and its relatives to the interpreter list. Put P2 in the corpus.
rec 3 — Make the cd check fail closed: block if a command word could expand (`$`, `{`, a backtick), or match `cd`/`pushd`/`popd`/`chdir` after any non-letter. Add P3 (incl. zsh `chdir` and `>!`) to the corpus.
rec 4 — Widen the rec 5 command-start pattern: `.`, `if`/`while`/`until`/`!`, leading `NAME=value`; let `git` skip options that take a value (`-c k=v`, `-C dir`); let `curl -o` match a path stuck to the flag.
rec 5 — Rename or re-scope the AC3 test and the DECISION-011 S186 sentence "every other command the S182 guard blocked still blocks" to what is proven ("every command in this corpus"), and list the known open classes beside the run-time-path limit.
rec 6 — Change the `obeyed:` answers for tech-lead rec 2 (wrong sha), tech-lead rec 3 (ordering not visible; premise false) and design rec 7 (built the opposite) to the sha or `refused:` reason that matches what was built.
rec 7 — Fix `.ai/SESSION-BOOT.md` lines 4 and 7, and either write the next prompt or mark step 11 not done until it exists.
rec 8 — Optional, an older hole: run the redirect scan also when the hook's `cwd` resolves inside `.ai/approvals`, even if the command does not name the folder.

## Handoff Delta
- `+` new: first fidelity-reviewer handoff for this session (5550 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
