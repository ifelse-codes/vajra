---
role: fidelity-reviewer
session: 196
agent: claude-code-subagent (verified: toolu_01VPh9kbvJWh2t5H6CQ6rzQq; text-sha: c4eedb2af1bc2a2df581e5982fcb7ce1fd18cbce19f0d3339c58231853543e70)
source-sha: 02d0b47c43b1e5683c7da6dcf06851b5694e152bdf4f28440567372d22046917
captured: 2026-10-14T12:24:46Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 196

**Verdict:** ACCEPT

# Session 196 — cold fidelity review (rudra S21 on Opus · F127 the push belt)

## Method controls
- **Inputs:** `prompts/196-task-rudra-s21.md` (the contract), `sessions/session-196-summary.md` (read only as a list of claims to check, never as evidence), and the delivered files themselves. These include `.githooks/pre-push`, `scripts/verify-closeout.sh`, `scripts/verify-closeout-scaffold.sh`, `src/cli/launch.rs` (`parse_close_result` and the S196 tests), `tests/push_belt.rs`, `scripts/verify-session-196.sh`, `scripts/demo-session-196.sh`, `src/nextstep/mod.rs:221`, the DECISION-007 and ADR-0004 S196 addenda, and `.githooks/README.md`.
- **Limit I must state plainly:** this pass had only Read, Grep and Glob. No shell. **I could not run `git diff 59719f8..HEAD`, `bash scripts/verify-session-196.sh`, `cargo test` or the demo.** Every grade below comes from reading the delivered code, not from running it. The "10/10", "5/5" and "732/0" figures are the builder's numbers, and I have not seen them happen (see rec 6).
- I did not read rudra. Its transcript, close folder and reflog are on the founder's machine (S126). So the rudra-side evidence (timestamps, counts, the `result` file contents) is checked only for whether it is consistent with itself and properly labelled, not against the source.

## Per-requirement table

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| D1 | Findings list from rudra S21 (F126…), each with evidence and a founder call | SHIPPED | Summary Findings table: F126 (transcript timestamps, the memory file path, rudra prompt 22 left unchanged → **Park**, 2026-10-14) and F127 (rudra S20 RED `result`, PR #24 merged, "no reader outside launch.rs" → **Fix**, with the founder's words quoted). F116 sighting recorded on its existing entry and not fixed, as the contract said. |
| D2 | F121 and F123 live results against the result file and git state; the Opus-vs-Haiku comparison | PARTIAL | F123 "not exercised", from `git reflog main` (fast-forward only): done. Opus-vs-Haiku table: done. **F121's line from the real run is missing.** What is recorded is the line the binary *would* print for that result (I checked the format against `src/cli/launch.rs:346`), and it is honestly labelled "not confirmed word for word". The "only after the merge" timing is reasoned from timestamps; nobody watched the screen. |
| D3 | A fix, with a test that fails without it, for every finding the founder said yes to | SHIPPED | F127 is the only yes. `.githooks/pre-push` (`read_result`, `close_check_refusal`) blocks an agent's push of `session-NN-*` unless the newest result whose head matches says GREEN, `clean: yes` and session NN. Format 2 is written by both close scripts (lines 1399–1415 and 1244–1260). The exit box reads both formats (`parse_close_result` v2 branch). `tests/push_belt.rs` has 9 real `git push` runs to a bare remote, and they would fail at 59719f8 because there was no belt then. One weak spot: the `clean:` writer (see fakest green). |
| AC1 | Every finding has evidence and a founder call in the summary | SHIPPED | F126, F127 and F116 each have both. Caveat: the two **WARN** rows in the same table have "Founder call" cells written by the agent ("Shown as WARN…", "rudra's own setting"), not by the founder (rec 5). |
| AC2 | F121's exit line from the real run beside the result file (verdict, counts, names); F123 fired / not exercised | PARTIAL | The result file's contents (GREEN 21/0/2 WARN, format 1) sit beside a line derived from them, not one seen on screen. The builder's own fidelity map says PARTIAL too, and the label is honest. F123: "not exercised", with reflog evidence. |
| AC3 | Opus-vs-Haiku table (Agent calls, `vajra next`, review real/self-written, last claim vs close verdict), from S21 logs and S194's summary | SHIPPED | All four required rows are present, each with a named source (S194 F121/F122; S21 transcript tool counts and Bash commands; `rudra/.ai/handoffs/session-21-*.md` `verified: toolu_…`; close folders). Caveats: "Claim vs close" is derived from the rows above (source "—"). The extra Cost row's S20 figure **$1.49 points to "below", but below holds only S21's $19.21**, so that one cell has no source (rec 5). |
| AC4 | Every fix has a real-run check in verify-196 (no source greps), red at the start commit | SHIPPED | By reading `scripts/verify-session-196.sh`: 10 rows, all using a real `vajra init` project, the project's own close script, a real `git push` to a bare remote, and a real `vajra claude` exit box. The four fix rows go red at 59719f8 because F127 is missing there: (1) the RED branch arrives at the remote; (2) a branch with no close check arrives; (3) the founder's RED push says nothing about RED; (4) the old binary calls format 2 "result unreadable". No grep of Vajra's source. RECORD lines print as RECORD and do not count as checks. **Not executed by me.** |
| AC5 | No Vajra commit touches rudra; rudra's commits are the founder's; full `cargo test` before push | PARTIAL | Nothing in the session-196 file set is a rudra path, transcript or run capture. `.ai/verify/` is gitignored, and the verify RECORDs are `echo` lines, not committed captures. **But the only `cargo test` figure (732/0) is labelled "before the cross-reader test; re-run below", and no re-run appears below.** c1aa1d6 added a test to `src/cli/launch.rs` after that count, so no full-suite result is recorded for the code at the tip (rec 1). |

**5 of 8 SHIPPED** (3 PARTIAL, 0 NOT-BUILT).

## Adversarial checks asked for

**F127 verify rows red at 59719f8 for F127's own reason:** yes, all four (see AC4). The GREEN-passes row and the `quick-fix` row have no old-commit pair. That is correct: they test that existing behaviour did not break, not the fix.

**`.githooks/pre-push`, looking for ways it lets a push through (fail-open).** If the agent is detected, and the result file is real and not forged, I found no path that lets a session-branch push through without a readable format-2 GREEN for that exact sha. What I checked:
- `why="$(close_check_refusal … || true)"` lets the push through only on the exact string `OK`. Empty or partial output becomes a refusal (lines 129–131).
- `read_result` reads its file through its own `< "$f"` redirect, so it cannot use up the hook's stdin list of refs. Line count, key order, digit fields and head pattern are all strict. GREEN needs fail 0 and no names; RED needs as many names as failures.
- A delete (all-zero local sha) is skipped. A session number in either the remote or the local ref name triggers the check. Session numbers are compared in base 10 after a digits check.
- When several results share the sha, the newest wins, so a later RED beats an earlier GREEN (tested).
- The writer saves through a temp file and `mv`, so a half-written result cannot exist. The partial modes (`--fidelity-only`, `--inputs-sha`, etc.) `exit` before the result is written, so a partial run can never leave a GREEN behind.

Ways around it that remain:
- **(a) Not on any named-limits list:** the hook knows it is an agent only from `CLAUDECODE` / `CLAUDE_CODE_ENTRYPOINT` / `CURSOR_TRACE_ID` / `VAJRA_AGENT`. `env -u CLAUDECODE git push`, or any agent tool that sets none of these, is treated as a person: it gets a `Note:` and the push goes on. This is the same strength as `--no-verify`, but `--no-verify` is on the list and this is not (rec 3). The main/master rule has the same hole.
- **(b)** `git push origin HEAD:refs/heads/anything` and a bare `session-196` name with no trailing `-` both escape the branch-name pattern. These belong to the named N17 "non-session branch name" class.
- **(c)** Already named: a forged result file, `--no-verify`, `core.hooksPath`.

The founder's "only the agent" call (a person gets a note) is by design, as noted in the brief.

**The writer's `clean:` logic** (both scripts, identical). It takes HEAD and `git status --porcelain --untracked-files=no` at the start and again at the end. It writes `yes` only if both snapshots are empty, HEAD is not `none`, and HEAD has not moved. A failing `git` gives `unreadable` or `none`, which means `clean: no`. The logic reads correctly. Untracked files are excluded, and that is disclosed. **But nothing ever runs the real writer into `clean: no`** (next section).

**The two readers.** The test name `s196_the_push_belt_and_the_exit_box_agree_on_every_format_2_result` claims more than it covers. Rust's `u32` parse accepts `pass: +5`, and `str::lines()` strips `\r`. The hook rejects both. So the exit box can say GREEN while the push says "unreadable". The difference is in the safe direction (the hook is the stricter one), but it is a real disagreement the 13 cases do not include (rec 4).

## The fakest green

**The "tracked files clean" guarantee.** Every proof that `clean:` protects anything uses a result file someone typed with `clean: no`: `tests/push_belt.rs` `result(…, "no", …)` and the hand-written `green()` helpers in verify-196 and the demo. The real close script is only ever seen writing `clean: yes`, on a pristine fresh project whose verdict is RED anyway, so `clean:` decides nothing there. Replace lines 1399–1404 of either close script with `CLOSE_CLEAN=yes` and every test, verify row and demo check stays green. The rule "a close that ran with uncommitted tracked changes, or while a commit landed, cannot open a PR" is written but never proven. This is a separate gap from the builder's own named fakest green (the agent can write the file). That one is a disclosed limit; this one is a check that passes with the feature deleted.

Runner-up: the "re-run below" `cargo test` line in the summary. It points to a full-suite result that does not exist.

## Is the real scope a narrow slice or the whole?

A faithful build of the whole contract. The findings came first with the founder's calls. The one approved fix is real and is checked with real pushes and red at the start commit. The records and the Releaser step text exist (`src/nextstep/mod.rs:221–222`). The two observational PARTIALs (F121's on-screen line, the receipt's top line) come from what the founder did not paste, and they are labelled as missing, not guessed. The one PARTIAL caused by the builder is the missing cargo-test record at the tip, and it can be fixed before the push.

## Recommendations

rec 1 — Run the full `cargo test` at the final tip and write its count into the summary in place of the dangling "re-run below".
Why: 732/0 predates c1aa1d6, which added a test to `src/cli/launch.rs`. AC5 needs a full pass before push, and tech-lead rec 7's `obeyed:` cites that stale figure.

rec 2 — Add a real-writer test: run the scaffold's own close script with a modified tracked file, and assert the result says `clean: no` and the agent's push is refused with "uncommitted changes". If it is cheap, add one where HEAD moves during the run.
Why: this is the fakest green. As things stand, hard-coding `CLOSE_CLEAN=yes` passes every check.

rec 3 — Add to the DECISION-007 S196 "named, not closed" list (and the hook header): an agent shell that has none of `CLAUDECODE`/`CLAUDE_CODE_ENTRYPOINT`/`CURSOR_TRACE_ID`/`VAJRA_AGENT` (unset with `env -u`, or a non-Claude tool) is treated as a person and only gets a note.
Why: it is a way past the belt that is not disclosed, the same class as `--no-verify`, which is listed.

rec 4 — Make `parse_close_result` reject a leading `+` in digit fields and `\r` line endings the way the hook does, and add `pass: +5` and a CRLF case to the cross-reader test. Otherwise rename the test and the summary's "cannot drift" to what the 13 cases actually prove.
Why: the two readers do disagree on those inputs today, and the test name says they never do.

rec 5 — Give the S20 Haiku cost ($1.49) in the AC3 table a real source, and mark the two WARN rows' "Founder call" cells as agent notes (or get the founder's call).
Why: AC3 asks that every cell be sourced and AC1 asks for a founder call on every finding. Those cells meet neither, as written.

rec 6 — Before the push, the orchestrator (not the builder) runs `bash scripts/verify-session-196.sh` and the full close at the tip, and confirms GREEN with `head:` equal to the commit being pushed.
Why: this reviewer had no shell, so AC4 and D3 are graded from reading code only. And the new belt will itself refuse the agent's push of `session-196-rudra-s21` unless that last close is GREEN on the exact tip.

## Files referenced
- /Users/suman/playground/vajra/prompts/196-task-rudra-s21.md
- /Users/suman/playground/vajra/sessions/session-196-summary.md
- /Users/suman/playground/vajra/.githooks/pre-push
- /Users/suman/playground/vajra/scripts/verify-closeout.sh (lines 51–55, 1394–1416)
- /Users/suman/playground/vajra/scripts/verify-closeout-scaffold.sh (lines 51–55, 1239–1261)
- /Users/suman/playground/vajra/src/cli/launch.rs (lines 465–519, 746–827)
- /Users/suman/playground/vajra/tests/push_belt.rs
- /Users/suman/playground/vajra/scripts/verify-session-196.sh
- /Users/suman/playground/vajra/scripts/demo-session-196.sh
- /Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md (line 1787 onward)
- /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md (line 618 onward)

## Handoff Delta
- `+` new: first fidelity-reviewer handoff for this session (13309 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
