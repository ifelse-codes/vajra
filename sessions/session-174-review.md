# Fidelity review — session 174 (`session-174-keep-testing`)

Independent cold review by the `fidelity-reviewer` role, fed the prompt and the diff — never the
builder's account. Two passes: pass 1 (the whole session, `f170e1c...3bcc981`) ACCEPT 12/13; its
recs 1, 3 and 4 were fixed in 5e509bb; pass 2 re-checked that commit only and carried the full grade:
ACCEPT 12/13 (D3 PARTIAL — synced role files are not named; rec 2 deferred). The handoff of record is
`.ai/handoffs/session-174-fidelity-reviewer.md` (pass 2). After pass 2 one verify pass-line was
reworded as its rec 6 asked ("shell-stamped files … role files: not covered").

**Verdict:** ACCEPT

---

## Pass 2 — re-check of 5e509bb, full grade carried


**Method.** I only read files; I ran nothing. I read `scripts/hook-session-start.sh` lines 59–93, `scripts/verify-session-174.sh` lines 93–124, `src/cli/next.rs` around lines 459 and 1395, and the stamp formats in `src/fleet/mod.rs`. I worked from the prior review at `/private/tmp/claude-501/-Users-suman-playground-vajra/245ba149-3e52-4018-90fe-cd15e59c74a9/scratchpad/s174-review.md`. I did not re-derive rows that 5e509bb does not touch.

## (1) Does 5e509bb do what it says?

**Rec 1 (hook): yes.** When the last line is not a stamp, the hook now does one of two things:
- **The file has a stamp line anywhere, or its HEAD copy had one:** the file goes to `HAND_EDITED`.
- **Neither:** the file is skipped, because it is not a Vajra file.

This check sits at lines 68–76 and ends in `continue`, so it can never add a file to `VAJRA_CHANGED`. The only way into "Vajra's own update" is still the old rule: the last line is a stamp and the hash of the body matches it (lines 77–78). So no hand edit is ever labelled as Vajra's, and nothing got looser. The stamp regex is anchored and needs all 64 hex characters, so script source that merely contains the pattern cannot match it by accident.

Edge cases that are still silent:
- The stamp line is edited in place, and the HEAD copy had no stamp (a file stamped for the first time).
- A sync adds a new file. It is untracked, and `git diff --name-only HEAD` does not list untracked files.

Neither case is a regression.

**Rec 3 (verify): yes, with one catch.**
- **Append fixture (line 111):** it adds a line to `hook-publish-guard.sh` and checks that the file appears in the "changed by hand" section. That section is only printed by the new code, so this check would fail before 5e509bb. It is now a live case.
- **Exact-set check (lines 106–109):** it replaces "at least one" as its own check, but `CH >= 1` is still there at line 101, next to it rather than removed. Nothing got looser.
- **The catch:** the "expected" set (`WANT`) is picked by the hook's own rule: the last line is a shell-style stamp. So it checks exactly what the hook sees, not everything the sync changed. That is the fakest green below.

**Rec 4 (next.rs): yes.** Line 1395 now calls `nextstep::render(&root, n, &current_branch(&root))`, the same call `--steps` makes at line 459. After a merge, bare `vajra next` hands over to the next session instead of re-grading the merged one with ✗ lines. I could not compile or run it; the call matches the existing one exactly.

## (2) Does D3 now grade SHIPPED?

**No. It stays PARTIAL, but the gap is narrower.**
- **Half (a) is closed:** a hand edit of a hook, whether inserted, appended or with the stamp deleted, is now named as a hand edit.
- **Half (b) is still open:** role files (`.claude/agents/*.md`) carry a bare `vajra-render-sha:` line inside their frontmatter (`fleet/mod.rs` 697). Markdown stamps use the `<!-- … -->` form (703). Neither matches `^# vajra-render-sha:`. So when `--sync-fleet` changes a role file, boot says nothing: the file is named neither as Vajra's update nor as a hand edit.

D3 says "boot names Vajra's own uncommitted update", and a synced role file is part of that update. Deferring rec 2 is a legitimate choice, but a deferral does not earn SHIPPED. The rudra case itself (three hooks) is fully covered.

## Per-requirement table

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| D1 | F58: an approved agent whose PR command is off the allow-list is told it IS approved and given `--body-file`; boot note says the same | SHIPPED | Unchanged: `hook-publish-guard.sh` 182–193 still ends in `exit 2`; boot note in `hook-session-start.sh`. |
| D2 | F59/F62: after a merge, `--steps` shows the next session's start, never the merged one's ✗ lines; every open list says to re-run | SHIPPED | Unchanged `nextstep::session_to_show` / `render` plus unit tests. 5e509bb also routes bare `vajra next` through `render` (`next.rs` 1395), so the second screen agrees. |
| D3 | F60: boot names Vajra's own uncommitted update (proved by its trailer) as "commit first, never revert"; a hand-edited Vajra file is named as a hand edit | PARTIAL | Hooks are now fully covered: an edit inside the body, a line after the stamp, a moved stamp, or a deleted stamp all come out as hand edits (`hook-session-start.sh` 67–78). Still missing: synced role files (`.claude/agents/*.md`, stamp in frontmatter) are never named. Rec 2 is deferred. |
| D4 | F61: the 3-file block says the files are still staged and to run `git reset -q` first | SHIPPED | Unchanged: `.githooks/pre-commit` 78. |
| D5 | F63: the SESSION vs SESSION-BOOT block names the line to set; the counter step says both move together | SHIPPED | Unchanged: `pre-commit` 88; the `nextstep` counter step plus its unit test. |
| D6 | Carried, not fixed: F47, F56, F57 (LOW), F64 (watch), each still in the findings table | SHIPPED | Unchanged: rows in the prompt's findings table. |
| AC1 | Heredoc PR under approval still exit 2 with "NOT THIS SPELLING" and `--body-file`; the `--body-file` form passes; a merge and an unapproved launch print the old message | SHIPPED | Unchanged: verify 54–73 against the real hook. |
| AC2 | `--steps` on rudra main (S05 merged) hands over to session 06; a green close still on its branch keeps its own list | SHIPPED | Unchanged: verify 78–92 with the real binary on the pinned rudra clone. |
| AC3 | Boot on rudra lists its 3 changed hooks as Vajra's update with "Never revert"; a copy with one hook hand-edited names that one instead | SHIPPED | Stronger now: exact-set check (106–109), a live append-after-stamp fixture (111–114), and the insert-at-line-2 fixture (115–123). Still no literal check for "3"; the expected set is chosen by the hook's own rule. |
| AC4 | 5-file agent commit blocked with "STILL STAGED — unstage first: git reset -q" | SHIPPED | Unchanged: verify 123–126 (prior numbering). |
| AC5 | SESSION 05 with BOOT 04 blocked, naming `- **Number:** 05` | SHIPPED | Unchanged: verify 128–131 (prior numbering). |
| AC6 | No check got looser: same exit codes from publish guard and pre-commit, old vs new, in every mode | SHIPPED | Unchanged: `DIFF == 0`, `SAME >= 500`. 5e509bb does not touch either guard, and its hook change only adds hand-edit labels. |
| AC7 | Findings table still lists F47, F56, F57, F64 with a severity | SHIPPED | Unchanged: verify 190–192. |

**12 of 13 SHIPPED** (1 PARTIAL, 0 NOT-BUILT). Same count as before; D3's gap is smaller.

Pass 2 verdict: ACCEPT

5e509bb does what its message says for recs 1, 3 and 4. It loosens no check, and it adds no path that could put a hand-edited file under "Vajra's own update". The whole session stays ACCEPT. D3 stays PARTIAL until rec 2 lands.

## The fakest green

**AC3's new "exact set" check picks its expected answer with the same rule the hook uses.** `WANT` is "changed files whose last line is a `# vajra-render-sha:` stamp", and that is the hook's own filter. So "the notice names exactly the N stamped files the sync changed" only proves the hook's hash check agrees with itself on shell-stamped files. It would pass unchanged if the sync also rewrote five role files that boot never mentions, which is exactly the rec 2 gap. The pass line's wording ("the stamped files the sync changed") suggests everything the sync touched is covered, and it is not.

## New recs

rec 6 — Build AC3's expected set from everything `vajra init --sync-fleet` changed (all of `git diff --name-only HEAD` after the sync, plus untracked files), not from the hook's own last-line rule, and name every file that is left out.
When rec 2 lands, this turns the role-file gap into a check that fails. Until then, word the pass line as "shell-stamped files" so it does not claim more than it checks.

rec 7 — Have the boot notice also look at untracked files (`git ls-files --others --exclude-standard`), so a hook or role file that a sync adds for the first time is named as Vajra's update and not silently left out.
This is not a regression from 5e509bb. It is the same F60 failure for a file added rather than changed.

---

## Pass 1 — the whole session


**Method.** I had only read access and no shell. So I read the delivered files at HEAD and did not run `git diff` or any script. The inputs were the prompt `/Users/suman/playground/vajra/prompts/174-task-keep-testing.md` and the changed files: `scripts/hook-publish-guard.sh`, `scripts/hook-session-start.sh`, `src/nextstep/mod.rs`, `src/cli/next.rs`, `.githooks/pre-commit`, `scripts/verify-session-174.sh`, `scripts/demo-session-174.sh`. I also read `src/releaser/mod.rs` (`shipped_close`) and `src/fleet/mod.rs` (the stamp format) for context. I did not read the summary, STATE or SESSION-BOOT. I took nothing from the builder's own story.

## The four probes

1. **Can the new "you are approved" message (`APPROVED_HERE`) let anything through?** No.
   - The flag is only set when the branch is `session-NN-*`, `VAJRA_ALLOW_COMMIT` equals NN, and no `gh pr merge` / `glab mr merge` appears anywhere in the scanned command (lines 131–133). A merge, or an approval for another session, never reaches it.
   - Its block always ends in `exit 2` (line 192). It sits after the L1 advise exit and after every allow exit, so it only changes the words on a command that was already blocked.
   - Pushing to main under approval gets the new wording but is still blocked, and the message says main stays with the human.
2. **Can `session_to_show` show the wrong session or loop forever?** No.
   - "Merged" means `shipped_close`: the session's summary file exists on `origin/main` (or on `main` when there is no remote ref). An open session, or one closed but not merged, has no summary on main, so it keeps its own list. The unit test `a_green_but_unmerged_close_keeps_its_own_list` and the real rudra clone both show this.
   - The loop stops at the first session with no summary on main, and there are only so many summaries, so it always ends.
   - Small edge: a stale `origin/main` delays the hand-over until the next fetch. That is safe.
3. **Can the F60 notice call a hand-edited file "Vajra's update"?** No.
   - It hashes everything above the last line and compares that to the `# vajra-render-sha:` value on the last line. This matches `stamp_render`'s shell-comment form exactly. A changed body gives a different hash and the file is listed as a hand edit.
   - But it is silent in two cases, covered in D3 below.
4. **Is any verify check hollow?** No check decides a pass by grepping source.
   - AC1, AC4 and AC5 feed real commands to the real hooks.
   - AC2 and AC3 run the real binary and a real `vajra init --sync-fleet` on a clone of rudra pinned at 512c71a.
   - AC6 runs the old hooks (from f170e1c) and the new ones side by side and compares exit codes: 40 commands × 3 approvals × 5 modes, plus pre-commit.
   - The only grep of the repo is AC7, which checks the prompt's findings table. That is the right thing for AC7.

## Per-requirement table

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| D1 | F58: an approved agent whose PR command is off the allow-list is told it IS approved and given `--body-file`; boot note says the same | SHIPPED | `hook-publish-guard.sh` 182–193: "NOT THIS SPELLING", "You ARE approved", `gh pr create --title "<title>" --body-file <file>`, then `exit 2`. `hook-session-start.sh` 124–126 adds the boot note. |
| D2 | F59/F62: once the close is on main, `--steps` shows the next session's start (branch, prompt, then the normal list), never the merged one's ✗ lines; every open list says to re-run | SHIPPED | `nextstep::session_to_show`, `start_steps` and `render` (249–314); `run_steps` now calls `render`; the re-run line is at 235–237; 5 unit tests plus the live rudra run. |
| D3 | F60: boot names Vajra's own uncommitted update (proved by its trailer) as "commit first, never revert"; a hand-edited Vajra file is named as a hand edit | PARTIAL | `hook-session-start.sh` 64–85 works for files whose stamp is the last line (hooks). Missing: (a) a hand edit that adds a line after the stamp, or deletes it, gets no notice at all, even though the deliverable says a hand edit is named; (b) `--sync-fleet`'s role files (`.claude/agents/*.md`) carry their stamp inside the header block, not on the last line, so a synced role file is never named as Vajra's update. That is the F60 failure again, for a different kind of file. |
| D4 | F61: the 3-file block says the files are still staged and to run `git reset -q` first | SHIPPED | `.githooks/pre-commit` line 78; the block decision (73–79) is unchanged. |
| D5 | F63: the SESSION vs SESSION-BOOT block names the line to set; the counter step says both move together | SHIPPED | `pre-commit` line 88 prints `` - **Number:** $n ``; `nextstep` 104–108 "moves .ai/SESSION and SESSION-BOOT's Number together"; unit test `the_counter_step_says_session_and_boot_move_together`. |
| D6 | Carried, not fixed: F47, F56, F57 (LOW), F64 (watch), each still in the findings table | SHIPPED | Prompt findings table, rows F64 and F47–F57, each with a severity. |
| AC1 | Heredoc PR under `VAJRA_ALLOW_COMMIT=05` still exit 2, message starts "NOT THIS SPELLING" and names `--body-file`; the `--body-file` form passes; a merge and an unapproved launch print the old message | SHIPPED | verify 54–73 on the real hook: exit 2 plus the new text and no "relaunch" line; the body-file form exits 0; merge and unapproved get the old text; a session-06 approval is not called approved; the boot note is checked. |
| AC2 | `--steps` on rudra main (S05 merged) prints "session 05 is merged — session 06 starts here", branch step first, no S05 list; a green close still on its branch keeps its own list | SHIPPED | verify 78–92 on the real binary against the rudra clone at 512c71a (`origin/main` pinned); unmerged case is a unit test. |
| AC3 | Boot on rudra lists its 3 changed hooks as Vajra's update with "Never revert"; a copy with one hook hand-edited names that one instead | SHIPPED | verify 97–115: real sync into the clone, then a line inserted at line 2 of `hook-session-guard.sh`. Weaker than written: it asserts `CH >= 1` and that one named file appears, not the 3 hooks. |
| AC4 | 5-file agent commit blocked with "STILL STAGED — unstage first: git reset -q" | SHIPPED | verify 123–126 runs the real pre-commit with `CLAUDECODE=1`. |
| AC5 | SESSION 05 with BOOT 04 blocked, naming `- **Number:** 05` | SHIPPED | verify 128–131. |
| AC6 | No check got looser: same exit codes from publish guard and pre-commit, old vs new, at every maturity, with and without publish approval, and with the guard off | SHIPPED | verify 139–185: `DIFF == 0` and `SAME >= 500`. The command list includes the known tricky allow-path spellings (`-Hsession-05-y`, a repeated `--head`, `+refspec`, `-uf`, `git -c`, `cd /tmp && git push`). Pre-commit runs across file counts 1/3/4/8 and boot 05/04. |
| AC7 | Findings table still lists F47, F56, F57, F64 with a severity | SHIPPED | verify 190–192 matches `^\| Fxx \|.*\| (⚪\|🟡\|🔴)` against the prompt. |

**12 of 13 SHIPPED** (1 PARTIAL, 0 NOT-BUILT).

No check got looser. Every changed block keeps its allow/deny decision, the only thing that grew is the words after it, and AC6 proves this by running old and new side by side rather than claiming it. This is a faithful build of the whole contract, not one narrow slice presented as the whole. The one gap is D3's coverage beyond hooks: it is not the rudra incident itself, it does not make anything worse than before S174, and it never mislabels a hand edit as Vajra's.

Pass 1 verdict: ACCEPT

## The fakest green

**The AC3 hand-edit check.** It proves the one edit shape the design can handle and skips the one it cannot.

- The fixture inserts `# a hand edit` at line 2, so the stamp stays on the last line and the hash mismatch fires.
- Verify lines 105–106 prepare an append-a-blank-line path (`printf '\n' >> "$F"`) for the case where the file was not synced. If that path ran, the stamp would stop being the last line. `tail -n 1` would then find nothing, and the file would be listed nowhere, so the AC would fail.
- The path is dead because the pinned sync always rewrites `hook-session-guard.sh`. The hole it would have exposed is real: an agent or human who adds a line to the end of a hook gets no F60 notice.
- The same check asserts `CH >= 1` where the AC says "its 3 changed hooks".

## Recommendations

rec 1 — Make the F60 boot notice find the stamp the way `fleet::extract_render_stamp` does (the last line that matches, not simply the last line), and treat a changed Vajra file whose stamp is missing or moved as a hand edit instead of skipping it.
The safety property "never call a hand edit Vajra's" already holds. What fails is the other half of D3, "a hand-edited Vajra file is named as a hand edit", for append-style edits.

rec 2 — Cover `--sync-fleet`'s role files (`.claude/agents/*.md`, stamp inside the header block) and any governed markdown region in the "Vajra's own update" notice. The simplest way is to ask the binary (`render_stamp_verifies` with the right stamp style) rather than re-doing the check in shell.
Without this, the next sync that touches a role file repeats F60 for that file.

rec 3 — Tighten AC3's verify to assert the exact set of hooks the sync changed. Add a fixture that appends after the stamp, so the dead branch at verify lines 105–106 becomes a live case that fails today.

rec 4 — Route the plain `vajra next` packet (`src/cli/next.rs` 1394–1395) through `nextstep::render` too.
It still prints `format_steps(steps(n))` for `.ai/SESSION`'s session, so after a merge an agent running bare `vajra next` still sees the merged session re-graded with ✗ lines (F62). D2 only named `--steps`, so this is not a miss against the contract, but it is the same wrong answer on a second screen.

rec 5 — Keep F64 (a `deferred:` answer changed to `obeyed:` to pass the advice check) on watch with a concrete trigger: next run, compare each `obeyed:` sha against what its rec asked.

**Review-Inputs-SHA:** `a6bf81a35a36b0f626f9d724243314a35185d3cbb893dc296cdbd5d746b92f75`
