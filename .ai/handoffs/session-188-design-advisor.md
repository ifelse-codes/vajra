---
role: design-advisor
session: 188
agent: claude-code-subagent (verified: toolu_01A66fHVmEgu74x417fhAVGb; text-sha: ceb230a119695e793f74f234bfd359add56a2b669df1b7f3d121de02307d4682)
source-sha: 4b05c89504c4bf4656d49c5d605d10acbb51c78276b57a6fea465163d71bf0fb
captured: 2026-10-05T15:29:59Z
cost_usd: null
---

# Design-advisor handoff — session 188

# Design-advisor brief — Session 188 (the approvals folder: check what changed, not the words)

**Marker: `design-significant: yes`.** There are three reasons. It wires two new hook events (PostToolUse and PostToolUseFailure) into every project's `.claude/settings.json`. It changes what `approved()` reads: a new file inside the folder. And it reverses a locked rule: DECISION-011's S182 and S186 addenda, plus the S173 rule that a guard change "only adds".

**Record cited:** `docs/decisions/DECISION-011-controls-the-agent-cannot-type.md`. I checked that it exists. This needs an **S188 addendum, not a new DECISION**: the control is the same (who may write an approval record) and so is the bar-raising posture. The addendum must say up front that it **deviates** from the record it extends. The gate checks the citation's form, not whether the design obeys it.

Files read: the brief, the tech-lead handoff, `scripts/hook-approvals-guard.sh`, `src/approval/mod.rs`, DECISION-011, and in `src/cli/init.rs` `TPL_CLAUDE_SETTINGS` (2154) and `merge_claude_settings` (1236). I also ran a few targeted greps and short reads beyond that list, because they bear on the design:
- `scripts/hook-pre-bash.sh` (1–50): line 37 is `|| exit $?`.
- `scripts/hook-pre-write.sh`: the guard call is at line 36.
- `.claude/settings.json`: Vajra's own Pre matchers are `Bash` and `Edit|Write|MultiEdit`, with no NotebookEdit.
- ADR-0003 §2.1.4: the merge algorithm.
- The readers of `approved()`: `src/nextstep/mod.rs:97` and `src/analyst/mod.rs:663`. Nothing in `verify-closeout.sh` reads the records.
- The `.ai/approvals` and gitignore greps.

## Verdict on the builder's shape

It is sound. Keep one script, branch on `hook_event_name`, keep the before record in TMPDIR keyed by root checksum and `tool_use_id`, and use **void option B**. Five things need changing:
1. **The after hook deleting the before record makes a double run void a clean command.** See rec 2.
2. **Pairing only Bash leaves a write through a link reachable through the Write tools.** See rec 3.
3. **A snapshot failure exiting 1 at Pre skips later checks in Vajra's own hooks.** See rec 4.
4. **`git hash-object` without `--no-filters`, and an exact-case name compare, each open a hole.** See recs 5 and 7.
5. **Two lost cases are missing from the gaps list:** the swap-run-restore case and the cross-project write. See recs 13 and 14.

## Answers to the open questions

- **(a) Where the before record lives:** the builder's choice, `${TMPDIR:-/tmp}/vajra-approvals-UID/ROOTCKSUM-TOOLUSEID`, created with `mkdir -m 700`. It sits outside the folder and outside the tracked tree (tech-lead rec 2). Claude Code starts the Pre and Post hooks with the same environment, so both see the same TMPDIR. The after hook never deletes it; the Pre hook prunes records older than a day.
- **(b) How the void works:** option B. Option A has a real hole: a record forged for a later session counts again. B keys on file names, not times, so a same-second approve cannot race it. The allow-all record is covered because `allow-all.launch` is just another listed name. Two details are needed: names compared lower-cased (rec 7), and an unreadable marker rebuilt rather than deleted (rec 8). B leaves one hole, and it should be named: un-listing every session below NN means a record forged for a session that is still open counts again if the founder approves a later session before closing that one.
- **(c) Running next to the other hooks:** assume no order between hooks. The one ordering relied on is documented: every PreToolUse hook returns before the tool starts, and the after events run once it ends. No other Vajra hook writes the folder. That covers the copilot loader, the session, publish and commit guards, `hook-pre-bash.sh`, `hook-pre-write.sh` and the compression PostToolUse hook. Under `vajra claude`, ADR-0003 §2.1.4 copies the project's PostToolUse entries into the `--settings` temp file, so the after check may be listed twice. Claude Code may remove the duplicate, but do not rely on that: rec 2 makes a double run harmless. Keep stdout empty on the after path; the compression hook speaks JSON on stdout.
- **(d) No before record:** at L2/L3, void, with a "could not compare" message. A missing `tool_use_id` is treated the same way, and the message says to update Claude Code. At L1, write one report line, exit 0, and write no void (rec 6).
- **(e) The docs facts:** the builder has confirmed them. Wiring both after events settles tech-lead rec 6's question (`cp …; false`) as long as each completed call fires exactly one of the two. Only a live run proves it (rec 11).

**Tech-lead recs 2–6:**
- Rec 2: agree on where the record lives, **disagree** that the after hook should delete it (rec 2 below).
- Rec 3: agree. B meets it, plus recs 7 and 8.
- Rec 4: agree. Fleet subagents running in the background widen this window, so the message matters more.
- Rec 5: agree. The cases are sorted in the addendum below.
- Rec 6: agree. Add rec 11's live run.

## Recommendations

rec 1 — Keep the builder's shape (one script branching on `hook_event_name`, before record in `${TMPDIR:-/tmp}/vajra-approvals-UID/`, mode 700, pruned after a day) and pick void option B over A.
Why: it stays one source (S182), it sits outside the folder and the tree, and B closes A's "a forged later-session record counts again" hole without a new crate. B's own small remaining hole (un-listing sessions below NN) is the right trade for the closeout flow: approving the next session also clears the current one. Name it in the addendum.

rec 2 — The after hook must not delete the before record; the Pre hook's one-day prune is the only cleanup.
Why: the after check can run twice for one call. One way is the ADR-0003 injector copying the project's PostToolUse entries into `vajra claude`'s `--settings`; another is a project wiring the guard under two covering matchers. If the first run deletes the record, the second finds none and, failing closed, voids a clean command, possibly on every command. If the record is never deleted, two runs give the same answer.

rec 3 — Pair every tool that reaches the guard's Pre path, not Bash only. The after groups use exactly the Pre matcher of that settings file: `Bash|Edit|Write|MultiEdit|NotebookEdit` in the scaffold, and `Bash` plus `Edit|Write|MultiEdit` in Vajra's own `.claude/settings.json`, which has no NotebookEdit Pre hook. Never wider.
Why: the Write-tool block reads the path's text. A harmless-looking `ln -s ../.ai/approvals/session-189.json docs/x` no longer blocks, because it changes nothing in the folder. A later Write to `docs/x` then lands in the folder between pairs and looks like the founder. Pairing the write tools catches it at no cost, by the founder's own argument (check the result, not the spelling). The after matcher must never be wider than the Pre matcher: an after event with no Pre hook finds no before record and voids every time.

rec 4 — In the Pre path, save the state first, before the Write-tool block decides. If the state cannot be saved, exit 0 with no record, never 1.
Why: `hook-pre-bash.sh:37` and `hook-pre-write.sh:36` run `… | bash "$_AG" || exit $?`. A guard exit of 1 (for example from `set -e`) skips everything after it, including the ground-truth commit block. The missing record is caught at Post anyway (rec 6). Saving first means that if PostToolUseFailure fires for a call another hook blocked (not documented), it finds a record and stays silent.

rec 5 — Make the snapshot exact. Hash with `git hash-object --no-filters`. Separate entries with NUL and compare the two files with `cmp`. Put the folder's own type (dir, link, absent, unreadable) first. Record an unreadable entry as a state. At Post, any error while saving counts as "changed".
Why: without `--no-filters`, `core.autocrlf` or a `.gitattributes` clean filter makes two different files hash the same, and it runs a filter program inside the hook. A newline in a file name can make two different states print the same list. A failed hash under `set -e` at Post exits 1, which voids nothing, so the check would fail open.

rec 6 — If there is no before record, or no `tool_use_id`, at L2/L3: write the void with its own "could not compare" message. At L1, for both the changed case and the could-not-compare case, write one report line, exit 0, and no void. Add a test for each.
Why: deleting the before record is the cheapest dodge, and failing closed catches it. That leaves "edit the before record" as the only way round, and it is a named gap. The innocent causes are machine faults the message can name: a Pre hook that timed out, a full TMPDIR, a pruned record, an old Claude Code. L1 is report-only everywhere else in this guard.

rec 7 — `approved()` compares the names in the marker lower-cased.
Why: on macOS's default case-insensitive disk, an AI that writes `SESSION-189.json` is read by `approved(189)` as `session-189.json`. An exact-case compare misses the listed name and the forged record counts. The Write-tool block lowercases for the same reason (guard line 48).

rec 8 — When `vajra approve NN`, `record_launch_env` or `record_allow_all` finds an unreadable marker, rebuild it from the records present, minus the ones it un-lists. Never just delete it.
Why: an unreadable marker makes every approval read as missing. If approve ignores it, the founder can never approve again. If approve deletes it, every forged record counts again at once.

rec 9 — Gitignore `.ai/approvals/voided.json` (in Vajra's `.gitignore` and the scaffold's ignore block). The snapshot compares it but the marker never lists itself.
Why: a committed marker travels with `git checkout` and `git pull`. Checking out main removes it, and the hook writes it again as an untracked file. The later `git pull` of the merged branch then refuses to overwrite that untracked file, which breaks the return-to-main at closeout. The marker is this machine's state, like `.ai/.session-owner`. Existing projects already have the ignore block and will show it as untracked; that is named, and rare.

rec 10 — The gate and `vajra next --steps` should say why: "session NN's approval does not count — the AI changed .ai/approvals; run `vajra approve NN`", not just "missing".
Why: the founder will run `ls`, see `session-188.json` sitting there, and be told it is missing. That message contradicts what he can see. Both readers call `approved()` (`nextstep/mod.rs:97`, `analyst/mod.rs:663`), so one small helper serves both.

rec 11 — Before the PR, do one recorded live run on the installed Claude Code, launched through `vajra claude` in a scratch project on the cheapest model. Show that `cp x .ai/approvals/y; false` brings the message exactly once and that `ls .ai/approvals` brings nothing. Cite the run in the addendum.
Why: the test corpus cannot prove two facts. One is that a non-zero exit fires one of the two after events (tech-lead rec 6). The other is that the after check still fires, and only once, when `vajra claude`'s `--settings` file also carries PostToolUse entries. It costs cents; otherwise the founder finds out on rudra.

rec 12 — Convert the old Bash-block assertions in `tests/approval_cli.rs` (about lines 150–163) and `tests/approvals_scaffold.rs` (about line 79), not only `tests/approvals_guard.rs`. Run the start-commit guard from `git show 43305fd:scripts/hook-approvals-guard.sh` into a temp file, never by checking out the real tree.
Why: three test files assert "Bash write blocked before it runs", and tech-lead rec 7 names only one. Checking out the old script in the real tree swaps a live hook in the middle of a command: Pre runs one version and Post another, which gives a false "could not compare" void.

rec 13 — Name the swap-run-restore case in the addendum and the summary as the sharpest gap, and do not close it this session. The case: put a forged record in place, run the gate, remove the record, all in one command.
Why: the brief says "a change undone within the same command is not seen". That is true, but the consequence is worse: the gate running inside that command reads the forged record as an approval. The old guard blocked the plain spelling. If the founder wants a fix later, the approval reader could compare the folder against the open before record. Naming the consequence is what "named, not closed" means.

rec 14 — Name the cross-project write as a case that is lost, not one that moved from "blocked" to "caught". A write into another project's `.ai/approvals` (`cd ~/playground/rudra && cp x .ai/approvals/y`) is no longer blocked and is never caught.
Why: the hook watches only `$CLAUDE_PROJECT_DIR`. The guardrail asks the summary to say what the old guard blocked that the new one handles differently; this case it never handles. S187's live case is exactly this Vajra-to-rudra shape.

rec 15 — Put the rule "the AI never writes to `.ai/approvals`", with what happens if it does, in two places: `TPL_AGENTS_BODY` in `src/cli/init.rs` (the governed constitution body `--sync-fleet` ships) and Vajra's own `.ai/AGENTS.md` hard rules. Add a new KNOWLEDGE.md fact after lines 341–361 saying S188 replaces them, rather than editing them.
Why: no such line exists today. Neither `.ai/AGENTS.md` nor `TPL_AGENTS_BODY` mentions the folder, so "stays" in the brief is really "add". Projects get the governed body; Vajra's own constitution is written by hand. The old KNOWLEDGE facts would teach the next agent to split reads it no longer needs to split. Adding a superseding fact is how that file already handles the S181 to S182 change.

rec 16 — Record this as a DECISION-011 S188 addendum whose first lines say it deviates from DECISION-011 §2, the S182 addendum §2, the S186 addendum §1–2 and the S173 only-add rule. No new DECISION file.
Why: it is the same control under the same posture. S186 asked for "a class-level argument" before any loosening, and S188 has one: it reads the folder, not the spelling. A deviation not written into the cited record passes the gate silently.

## Proposed `## Design` text (no angle brackets, so the gate does not read it as a placeholder)

```
## Design
design-significant: yes
- **Record:** docs/decisions/DECISION-011-controls-the-agent-cannot-type.md — this session writes its S188 addendum. No new DECISION file: same control (who may write an approval record), same bar-raising posture.
- **Deviates from that record, on purpose (founder, 2026-10-05):** §2 ("the agent's Bash hook refuses to write there"), the S182 addendum §2 (block a command by whether its text can write), the S186 addendum §1–2 (the S182 rule stands; a guard change only adds) and the S173 only-add rule. For Bash the guard stops reading the command and checks the result. The class-level argument S186 asked for: every write the shell can make — any spelling, a path built at run time, an interpreter — changes the folder, and the check reads the folder.
- **Shape.** One script, as today (scripts/hook-approvals-guard.sh, shipped as .ai/hooks/hook-approvals-guard.sh), branching on hook_event_name.
  - PreToolUse, every tool that reaches the guard: first save the folder's state — the folder's own type, then each entry's name, type and `git hash-object --no-filters` hash (a link's target), NUL-separated — under ${TMPDIR:-/tmp}/vajra-approvals-UID/, named by a checksum of the project root plus the tool_use_id (folder mode 700; records older than a day pruned here). Then the unchanged Write-tool path block. A state that cannot be saved exits 0 with no record, never 1 (hook-pre-bash.sh and hook-pre-write.sh skip their later checks on a non-zero exit).
  - PostToolUse and PostToolUseFailure, with exactly the Pre matcher of that settings file: save the state again and compare byte for byte. Same: silent, exit 0. Different, no before record, or no tool_use_id: write the void, plain message on stderr, exit 2 (on these events exit 2 cannot block; it is how the AI is told). The after hook never deletes the before record. L1: one report line, exit 0, no void.
- **The void (option B).** .ai/approvals/voided.json (gitignored) lists every record name present after the change. approved(n) returns None when the file it reads — session-NN.json, or allow-all.launch for the allow-all branch — is listed (names compared lower-cased); an unreadable marker makes every approval missing. `vajra approve NN` rewrites session-NN.json and un-lists it and every session-MM.json with MM below NN; the launch-time writers un-list what they write; an empty list removes the marker; an unreadable one is rebuilt from what is present, never deleted. The marker is inside the folder, so removing or editing it is itself a change the next pair catches and re-lists. Keyed on names, not times: a same-second approve cannot race it.
- **Order with the other hooks: none assumed.** Relied on only: Claude Code starts the tool after every PreToolUse hook returns and runs the after events once it ends. No other Vajra hook writes the folder. A double run of the after check (ADR-0003's injector copies project PostToolUse entries into vajra claude's --settings) gives the same answer twice, because neither run deletes the before record.
- **Rejected:** option A, one marker voiding everything until the next approve (a forged record for a LATER session counts again once the founder approves this one); a void kept outside the folder (one more unwatched command deletes it); the before record inside the folder or the tracked tree (changes what it checks; can be committed); keeping the Bash word checks too (F110's false blocks are why this session exists); pairing Bash only (a Write through a link into the folder lands between pairs); Claude Code's sandbox and Vajra's own OS box (founder, 2026-10-05); a hash crate (git is already required).
- **Accepted gaps (founder: no policing) — named, not closed:** a change undone within one command, including a forged record put in place, a gate run and the record removed in ONE command, which the gate reads as approved; the before record edited during the command; a write landing between pairs (a background job, run_in_background, an interrupted command, a hook killed by its timeout) looks like the founder; a write into ANOTHER project's folder is no longer blocked and never caught; tools outside the paired ones (MCP servers) are not watched; the founder's own `vajra approve` while an AI or background-subagent command runs is flagged (the message says to run it again); a git checkout, pull or stash that moves a committed record counts as a change.
```

## Proposed DECISION-011 S188 addendum wording

```
## S188 addendum — the approvals folder: check what changed, not what the words say (2026-10-05)

**Follows** this record (§2: only the founder's own process writes an approval record). **Reverses, for Bash,**
the S182 addendum §2 and the S186 addendum §1–2 — block a command by reading its text; a guard change only adds
(the S173 rule). Founder's decision, 2026-10-05: in S187 alone the text guard blocked plain reads five times (F110),
and S186's two cold reviews kept finding spellings it missed. The class-level argument S186 asked for before any
loosening: the check no longer reads the command, it reads the folder — so every write the shell can make, by any
spelling, a path built at run time, or an interpreter, changes what it sees.

1. **Before and after every AI tool call the guard sees.** PreToolUse saves the folder's state under
   `${TMPDIR:-/tmp}/vajra-approvals-UID/`, named by a checksum of the project root plus the call's `tool_use_id`:
   the folder's own type, then each entry's name, type and `git hash-object --no-filters` hash (a link's target),
   NUL-separated. PostToolUse (the call succeeded) and PostToolUseFailure (it failed) save it again and compare
   byte for byte. Same → silent. Different → the void (2), a plain message on stderr, exit 2. On these two events
   exit 2 cannot block — the tool already ran — it is how the agent is told. The before record lives outside the
   folder and the tracked tree; the after hook never deletes it (two after runs for one call give the same answer);
   records older than a day are pruned. The after groups use exactly the Pre matcher of their settings file:
   an after event with no Pre hook would void every call.
2. **The void is a file inside the folder.** `.ai/approvals/voided.json` — gitignored, this machine's state like
   `.ai/.session-owner` — lists every record present after the change. `approved()` reads a listed record
   (`session-NN.json`, or `allow-all.launch` for the allow-all branch) as missing, comparing names lower-cased
   (macOS's disk is case-insensitive); an unreadable marker makes every approval missing. `vajra approve NN`
   rewrites `session-NN.json` and un-lists it and every `session-MM.json` with MM below NN; the launch-time writers
   un-list what they write; an empty list removes the marker; an unreadable one is rebuilt from what is present.
   Removing or editing the marker is itself a change, so the next pair re-lists everything present. Keyed on names,
   not times: a same-second approve cannot race it. Only record-based approvals are voided; sessions below
   `session_rules_from` still read the dated fallback.
3. **No before record → counted as a change** (L2/L3). Deleting the before record, the cheapest dodge, is caught;
   the message says Vajra could not compare. A call with no `tool_use_id` is treated the same, and the message says
   to update Claude Code. A state that cannot be saved at PreToolUse exits 0 — Vajra's hook-pre-bash.sh and
   hook-pre-write.sh skip their later checks on a non-zero exit — and the after hook counts it. **L1:** one report
   line, exit 0, no void — the report-only posture of the rest of this guard.
4. **The Bash word checks are removed** (the redirect rule, the writer, interpreter and program lists, the
   "names the folder" test). The Edit/Write/MultiEdit/NotebookEdit path block stays, unchanged, and still blocks
   before the tool runs; a write through a link the path check cannot see is caught by (1).
5. **Order with the other hooks: none assumed.** Relied on only: Claude Code starts the tool after every
   PreToolUse hook returns, and runs the after events once it ends. No other Vajra hook writes the folder.
6. **Projects.** `vajra init` ships the same bytes; `--sync-fleet` adds the PostToolUse and PostToolUseFailure
   groups through the S182 add-only merge. Claude Code reads hooks when it starts: the after check runs from the
   next launch.

**Docs facts relied on** (code.claude.com/docs/en/hooks, read 2026-10-05; Claude Code 2.1.280): PostToolUse
fires on success and PostToolUseFailure after a tool call fails; PreToolUse, PostToolUse and PostToolUseFailure
inputs all carry `tool_use_id`; exit 2 on the two after events shows stderr to Claude and cannot block; hooks fire
for subagent tool calls; matching hooks run in parallel with no order between them; hooks are read once at start.
Not documented: when PostToolUse fires for `run_in_background`. Checked live: [the S188 live run — command, result].

**What moves from before to after.** Every write the old guard blocked before it ran — cp, mv, rm, a redirect,
tee, an interpreter, `find -delete`, `git checkout --` — now runs and is caught after it: the record may be
changed or gone, the approval stops counting, and the founder runs `vajra approve NN` again. Vajra undoes nothing.

**Rejected:** one marker that voids everything until the next approve (a forged record for a later session counts
again once the founder approves this one); a void kept outside the folder (one more unwatched command deletes it);
the before record inside the folder or the tracked tree; keeping the word checks too (F110); pairing Bash only
(a Write through a link into the folder lands between pairs); Claude Code's sandbox and Vajra's own OS box
(founder, 2026-10-05); a hash crate (git is already required).

**Limit — bar-raising, not tamper-proof. Named, not closed:**
- A change undone within one command is not seen — including putting a forged record in place, running a gate and
  removing the record in ONE command: the gate inside that command reads it as approved. The old guard blocked that
  command's plain spelling.
- The before record can be edited during the command.
- A write between pairs looks like the founder: a background job (`(sleep 5; cp …) &`, `run_in_background`), what
  an interrupted command or a child it left behind writes after the call returns, a hook killed by its own timeout.
  Caught only if it lands inside a later pair; otherwise missed.
- Only this project's folder is watched: a write into another project's `.ai/approvals` (`cd ../rudra && cp …`),
  once blocked by its text, is now neither blocked nor caught.
- Tools outside the paired ones (an MCP server that writes files) are not watched.
- Pairs overlap (subagents, parallel reads): a change is reported by every open pair, sometimes against an innocent
  command; the void is the same.
- Un-listing every session below NN means a forged record for a session still open counts again if the founder
  approves a later session before closing it.
- The founder is flagged when his `vajra approve` lands while an AI command or a background subagent's command is
  running — the message tells him to run it again; and a `git checkout`/`pull`/`stash` that moves a committed
  record counts as a change (`git checkout main && git pull --ff-only` as one command does not).
```

## Suggested message (covers tech-lead rec 4 and rec 10)

`[vajra] .ai/approvals changed during this command. Only the founder writes there (`vajra approve NN`, in his own terminal). Vajra cannot undo it. These approvals no longer count until he approves again: session-188.json. Stop and tell the founder what you ran. Founder: if you ran `vajra approve` yourself while this command was running, or this was a git checkout/pull that moved a record, just run it again.`

The listed names come from the marker itself; do not read them from `.ai/SESSION`.

## Relevant files
- /Users/suman/playground/vajra/prompts/188-task-approvals-before-after-check.md
- /Users/suman/playground/vajra/.ai/handoffs/session-188-tech-lead.md
- /Users/suman/playground/vajra/scripts/hook-approvals-guard.sh
- /Users/suman/playground/vajra/scripts/hook-pre-bash.sh (line 37) and /Users/suman/playground/vajra/scripts/hook-pre-write.sh (line 36)
- /Users/suman/playground/vajra/.claude/settings.json (Pre matchers: `Bash`, `Edit|Write|MultiEdit`)
- /Users/suman/playground/vajra/src/approval/mod.rs
- /Users/suman/playground/vajra/src/nextstep/mod.rs (line 97) and /Users/suman/playground/vajra/src/analyst/mod.rs (line 663), the only `approved()` readers
- /Users/suman/playground/vajra/src/cli/init.rs: `merge_claude_settings` (1236), `TPL_CLAUDE_SETTINGS` (2154), `TPL_AGENTS_BODY` (1883), the gitignore block (about 2285)
- /Users/suman/playground/vajra/docs/decisions/DECISION-011-controls-the-agent-cannot-type.md
- /Users/suman/playground/vajra/docs/adr/0003-settings-injector-and-compression-heuristics.md (§2.1.4)
- /Users/suman/playground/vajra/tests/approvals_guard.rs, /Users/suman/playground/vajra/tests/approval_cli.rs, /Users/suman/playground/vajra/tests/approvals_scaffold.rs
- /Users/suman/playground/vajra/.ai/KNOWLEDGE.md (lines 341–361)

## Handoff Delta
- `+` new: first design-advisor handoff for this session (27515 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
