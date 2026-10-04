# Session 187 — Independent Fidelity Review

One cold pass by a fresh fidelity-reviewer dispatch, not the builder. Recorded verbatim through `vajra next --role fidelity-reviewer` (`.ai/handoffs/session-187-fidelity-reviewer.md`). Its recs are answered in the prompt's `## Advice`.

## Fidelity review: Session 187 (cold, adversarial)

**How I reviewed it.** I read `reviewer/SKILL.md` first. Then I read the prompt, the code at HEAD, and the 0071dca text of the guard and of verify-133. The 0071dca copies came from a checkout that was on disk at `/private/var/folders/0s/snr36g_x5kb47p7lrp7j38dh0000gn/T/vajra-old-checkouts/66612-0071dca/`. It vanished while I was reading, which fits a concurrent verify run cleaning up after itself. I read the summary last. I had only Read/Grep/Glob, so I ran nothing. I did not run verify-187, cargo test or any probe. Every behaviour claim below comes from reading code, not from a run.

**Verdict:** ACCEPT

**10 of 13 SHIPPED** (3 PARTIAL, 0 NOT-BUILT). D2 is left out of the count: the founder moved it to S188.

Real scope: this is a faithful build of the whole contract, not one slice dressed up as the whole. The weak spots are edge cases in F97's text edit, a partial N7 retrofit (disclosed in the summary, but its table still says SHIPPED), and one AC6 check that is too narrow.

| Req | Verdict | Evidence |
|---|---|---|
| D1 guard message, fix C | SHIPPED | I compared `scripts/hook-approvals-guard.sh` with the 0071dca copy line by line. Every decision line is identical: `NAMES`, `STRIPPED`, the redirect grep, `S182_WRITERS`/`S182_INTERP`, `AT` and all four program greps. The only new code is three comment lines and one string assignment (`SPLIT=...`, line 125), which cannot fail. Four reason strings changed (lines 132, 136, 149, 155). The redirect message (line 119) is unchanged. The live case is blocked by the `git ... checkout` program grep, so it now prints `$SPLIT`. Nothing lets more through. |
| D2 N2 let-through | NOT-BUILT (moved to S188 by the founder, so not counted) | The prompt records the move at line 28 ("MOVED TO S188 (founder, 2026-10-05)") and in Design line 81. No change to `hook-pre-write.sh` is in scope. |
| D3 N4 approval step | SHIPPED | `src/nextstep/mod.rs:95-104` adds the step from `session_rules_from` on. It is ✓ through `approval::approved` and its "how" says `vajra approve {session}`. Unit test `the_list_names_a_missing_approval_record` covers missing, present and below-threshold. The how is printed only when this is the NEXT step. The Analyst station passes on a Delta alone, so in practice it does become the next step. The code comment saying "the Analyst step stays open with no approval record" is wrong. |
| D4 F97 sync adds audits and question blocks | PARTIAL | `add_missing_ground_truth` (init.rs:993) handles the clean shape correctly. Lines keep their CRLF endings, the list keeps its trailing comment, names insert by canonical predecessor or in front, and `--dry-run` never writes (init.rs:588). DECISION-007 S187 addendum is present. DECISION-011 lines 83 and 123 are amended. The S142 test was renamed, not deleted. **Missing from the stated design:** (a) for a shape it does not recognise, it does not "print the line to add"; it only says to copy from a fresh init. (b) Some shapes it does not truly recognise still get written: see rec 1 (duplicate key, items moved to another block, quoted names). |
| D5 verify-133 re-pointed | SHIPPED | 15 `run_check` calls at 0071dca and 15 now. `real-dispatch-passes` now reads `toolu_01REALDESIGN[;)]`: honest, it allows S181's `; text-sha`. Bypass C now targets `dispatch::reverify_handoff(root, role.name, &h)`, which exists at `src/mandate/mod.rs:349`. Same rung, same red test. k-of-8 changed 8→7, but it also pins that the ONE non-PASSED row is the Demo-er with "missing elements: complete". That is a narrow re-baseline, not a check made empty. |
| D6 N6 ROADMAP header | SHIPPED | `.ai/ROADMAP.md` lines 3-5 point at `.ai/SESSION-BOOT.md` and `vajra next --steps`. The old "Updated:" paragraphs were moved under `## Session notes, S121–S166 (history…)` rather than deleted. That is acceptable: they are no longer the header. |
| D7 N7 one folder + N5 | PARTIAL | `scripts/lib-old-checkout.sh` is real, and verify-184/186/187 plus demo-187 use it. **verify-176, verify-178 and verify-179, and demo-176/178/179/184/186, still make their own `$T/old`, `$T.old` or `$DK_TMP/old` checkouts.** The deliverable says "the old-version checkouts verify scripts make", so the retrofit is incomplete. The summary's "What I did NOT build" says so, but its fidelity table still marks N7 SHIPPED. N5 is only the label `THIS repo only` (`src/dogfood/mod.rs:106`), honestly reported as "named, not closed". |
| AC1 live case + corpus | SHIPPED | verify-187 runs the live command through both the new guard and the 0071dca guard (`git show`): exit 2 both times, and only the new one says "as its own command". `s187_blocks_exactly_what_0071dca_blocked` (`tests/approvals_guard.rs:543`) checks the same exit code on reads, writes, s186, f110_open and s187 commands, with at least 40 blocked. It covers a list, not every command; the summary says so. |
| AC3 ✗/✓ approval line | SHIPPED | verify-187 runs the new and old binaries in a real `vajra init` project and writes a real record for ✓. The `vajra approve NN` text is checked only in the unit test; the verify comment says so. |
| AC4 sync, byte rule, dry run, second run | SHIPPED | verify-187 runs the real binary and the 0071dca binary on a real project. It checks the dry run writes nothing, that undoing the additions gives the file back byte for byte, that the old binary leaves the file unchanged, and that a second run adds nothing. |
| AC5 verify-133 exit 0, same count | SHIPPED | verify-187 checks the count is 15 in both versions, that the old text is red against today's code, and that it is red on k-of-8. |
| AC6 no hand-typed session number in header | PARTIAL | The header still contains "S166", "S185" and "S187" (line 4-5). The check's regex `Session [0-9]+` cannot see them, so it would also pass a header reading "current: S190". The summary names this as a known allowance. The harm today is nil, but the check is weaker than the AC. |
| AC7 killed checkout cleared + dogfood label | SHIPPED | verify-187 kills a run with `kill -9 $$`, sees one leftover checkout, and the next run clears it and its worktree entry. The dogfood row compares the old and new binary output. |
| AC8 each fix red at 0071dca, no source greps | SHIPPED (one caveat) | Most rows run the 0071dca binary, guard, script or file. Caveat: the N7 row's "at 0071dca" side is `! git cat-file -e 0071dca:scripts/lib-old-checkout.sh`. That checks whether a source file existed; it is not a real run. |

### Specific probes (from reading code)
- **F97, things that are safe:**
  - `ground_truth:  # c` and an empty `ground_truth:` are reported as unrecognised and nothing is written.
  - Two `required_audits:` lines, a block-style list, or a missing `]` are also unrecognised.
  - A comment after the list is kept.
  - Duplicate names already in the line are not re-added.
  - CRLF endings on original lines are kept. Inserted blocks use LF, so the file ends up with mixed line endings (cosmetic).
  - Blocks always land inside `ground_truth:`, and no key a gate reads is touched.
- **F97, defects:** see rec 1.
- **N7 sweep:**
  - It cannot remove a live run's checkout from the same user: a live owner makes `kill -0` succeed, so the checkout is skipped.
  - It can wrongly treat a live run as dead when the owner pid belongs to another user: `kill -0` fails with EPERM. This matters only with a shared `/tmp` fallback (Linux, or `TMPDIR` unset). On macOS, TMPDIR is per user.
  - It matches only `<digits>-*`. So if someone sets `VAJRA_OLD_CHECKOUTS` to a general folder, it will `rm -rf` any `2024-notes`-style folder there whose "pid" is not running.
  - No check proves a live run's checkout survives a sweep.

### The fakest green
**AC4's "remove the added names and you get the original byte for byte".** Any edit that only inserts lines passes that test, even one that changes what the YAML means. It is checked only on a clean fixture with no blank lines, no comments after `_questions:` keys and no quoted names. So it would still pass if sync:
- moved a project's own questions into another audit's block (a blank line inside a block), or
- added a second `vision_questions:` key (a comment after the key), where many YAML readers take the last copy and the project's own questions are lost.

The summary does not name this. Its own "fakest green" list covers D1's corpus, N5's label and AC6, which are all real but smaller.

### Recommendations
rec 1 — Make `add_missing_ground_truth` refuse, not write, any `ground_truth:` it cannot read exactly. That means a `_questions:` key with something after the colon, a blank line or a 2-space line inside a question block, a quoted name in the list, or items at 2-space indent. Add a test for each shape.
Why: today these shapes are written. The result is a duplicate key, or a project's questions moved under another audit, while the byte-undo test stays green. That breaks the design's own rule that a shape it does not recognise is never written.

rec 2 — For a shape it does not recognise, print the exact `required_audits:` line and the missing block names to add, as the S187 design and design-advisor rec 4 promise.
Why: today it only says "copy from a fresh `vajra init`", which leaves the user to work out the difference by hand.

rec 3 — Either move verify-176/178/179 (and the demos) onto `lib-old-checkout.sh`, or change the fidelity table's N7 row from SHIPPED to PARTIAL and carry the rest to S188 by name.
Why: the table and the "What I did NOT build" section disagree. A label is not a fix.

rec 4 — Make the sweep stricter. Only remove `^[0-9]+-[0-9a-f]{7,40}$` folders that hold a `.git` worktree file, and treat a `kill -0` failure caused by EPERM as alive. Add a verify row showing a live owner's checkout survives a sweep.
Why: "a live run's checkout is never removed" is claimed but never checked. With the env override, the loose pattern can `rm -rf` unrelated folders.

rec 5 — Widen the AC6 check to catch any session number in the header (`S[0-9]+` or `Session [0-9]+`). Either drop "S166 / S185 / S187" from the pointer line or exempt only that exact sentence.
Why: the current regex would pass a stale "current: S190" header, which is exactly what N6 was about.

rec 6 — Fix the comment at `src/nextstep/mod.rs:92-94`. The Analyst station passes on a substantive Delta whether or not an approval record exists.
Why: the comment explains the new step with something that is not true, and the next reader will reason from it.

rec 7 — Run the AC1 0071dca-vs-now exit comparison also on the extra commands verify-186 used to probe the guard (backslash-newline, zsh `>>!`, a full-path awk), not just the unit-test corpus.
Why: "only the reason changed" is proven over a list. I found no decision change by reading, but a bigger list is cheap and is the only proof this check offers.

