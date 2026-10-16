# Session 198 — the known-bug leftovers: F118 and N18

**Branch:** `session-198-known-bug-leftovers` · **Type:** CODE · **Start commit:** `2830bb2` · **Prompt:** `prompts/198-task-known-bug-leftovers.md`

## Goal achieved?

Yes. Both bugs left on ROADMAP's known-bug list after S197 are fixed, each proven by a real run that goes red at
`2830bb2`. F118 was also proven on this session's own start: `vajra next --advance` 197 → 198 moved S197's entry
to `## Prior Session` with no hand repair (`1f77083`) — S193, S194 and S197 each needed one.

## What shipped

| Fix | What a user sees now | Commits |
|---|---|---|
| **F118** | `vajra next --advance` on Vajra's SESSION-BOOT shape (exactly one `## Current Session`; under it one `- **Number:** NN` line, its indented continuation lines, then blanks; the next heading `## Prior Session`) writes `- **Number:** NN+1 — IN PROGRESS` and puts the old entry, byte-for-byte, as the first `## Prior Session` block. Stderr: "session NN's entry is now the first `## Prior Session`". Any other shape (the `vajra init` one, two entries, no Prior heading, two Current headings) keeps the S191 number swap, and stderr says "only the session number moved; the old entry was NOT moved …: <why>". No heading is invented. | `e26d59a` |
| **N18** | `scaffold-drift.sh` check 6 picks the last 10 verify scripts by the number in the file NAME, so a folder with dashes in its path scans the same 10 as one without; it prints `scanned: <names>` so a run can be compared. A first cut used `case … )` inside `$( )`, which macOS bash 3.2 cannot parse — verify row 3 caught it; fixed with the leading-`(` pattern. | `bbc2948` · `0087c2a` |

**Evidence:** `scripts/verify-session-198.sh` 4/4 (`31e92e7`). Row 1 (AC1): the built `vajra next --advance` on a
`vajra init` project given Vajra's shape — `cmp` against the expected file; at `2830bb2` session 06's story sat under
07. Row 2 (AC2): the `vajra init` shape and a two-entry shape — number swapped, nothing else changed, stderr says why;
at `2830bb2` it said only "updated". Row 3 (AC3): the real `scaffold-drift.sh` from a checkout under `…/n-1-8/` and
one under a dash-free `/tmp` folder, each with a planted hollow `verify-session-199.sh` — both scan the same 10
(equal to an independent `ls | sort -n`) and both catch 199; at `2830bb2` the dashed run missed it. Row 4: the five
SESSION-BOOT unit tests (incl. S191's prose-number case). `scripts/demo-session-198.sh` 5/5 live checks.
`scripts/scaffold-drift.sh` on this repo: 20/0, `scanned:` ends at verify-session-198. Full `cargo test` 737 passed /
0 failed, exit 0 (at `c2b936c`, and again after the review's fixes); `scripts/ci-lint.sh` clean. (An earlier "739" here
was my miscount: the sum also caught two demo-kit lines a test prints, "✗ 1 of 1 live checks FAILED". Corrected after
the review; the cold reviewer could not run commands, so the builder re-ran both — review rec 5.)

## Fidelity map

| Prompt item | Grade | Evidence |
|---|---|---|
| D1 / AC1 F118 Vajra's shape | SHIPPED | verify row 1 (byte-for-byte `cmp`, continuation line included); live on S198's own advance (`1f77083`) |
| D1 / AC2 F118 other shapes | SHIPPED | verify row 2 (the `vajra init` shape + two entries); unit test `update_session_boot_only_swaps_other_shapes` (4 shapes) |
| D2 / AC3 N18 | SHIPPED | verify row 3 (dashed vs dash-free checkout, same 10, planted 199 caught; red at `2830bb2`) |
| AC4 real-run checks, red at start; cargo test; push via the S196 belt | PARTIAL — the push half happens after the close; deferred to the next session's prompt (tech-lead rec 5; review rec 2) | rows 1–3 run the old binary/script too; no source greps (the two `src/main.rs` lines write a fixture and carry `# source-claim:`); `cargo test` 737/0 |
| Carried: S197's push recorded | SHIPPED | `2830bb2` (S197 summary: PR #235 head `2f83693` = the GREEN, `clean: yes` close result; who pushed is not recorded — the hook keeps no log) |

**The push (recorded at S199's start):** PR #236's head is `a3068d2` (`gh pr view 236`, 17 commits, merged
2026-10-15T11:06Z), and `.ai/verify/closeout/20261015T100751Z/result` records that exact commit as
`verdict: GREEN` (25 pass, 0 fail), `clean: yes` — the condition the S196 push belt checks. The pre-push hook
keeps no log, so whether the agent pushed (belt checked) or the founder did (note only) is not recorded.

**Not built:** nothing in the prompt. **Not moved:** a project's own SESSION-BOOT (rudra's) is still only
number-swapped — by design; it is now told so.

**Fakest green:** row 4 counted "5 passed" as a substring, so "15 passed" would also match (review rec 1 — now
anchored to `test result: ok. 5 passed;`); it still counts tests rather than running the fix — rows 1–3 are the proof.
The bigger one: F118's shape test is Vajra's
own file layout, so the fix reaches users only if their SESSION-BOOT copies that layout; the `vajra init` one does not.

## New findings (filed, not fixed)

- **N19** — `--advance` turns a CRLF SESSION-BOOT into LF (pre-dates S198; breaks "byte-for-byte" on CRLF files).
- **N20** — the advance's prompt-pointer rewrite can change a "read prompt `…`" line inside the just-moved Prior entry.
- Both from the cold review (recs 3, 4); ROADMAP known bugs, S200 checklist.

## Process

- Crew: tech-lead (required: fidelity-reviewer, release-coordinator; design-advisor as a recorded skip) ·
  fidelity-reviewer and release-coordinator at close.
- The session guard read a session number in a command's text once (the known mention class); worked around with a
  script file.

## Next — 3 ranked candidates

1. **(Recommended) rudra S22, synced — the push belt and the review-only guard on a real project.** `vajra init
   --sync-fleet` in rudra, restart Claude Code, run a real session to close. Why: F127 and F125 have still only run in
   temp projects; this is the only way to learn whether they help a user. Risk: S22 is a real build (the AI research
   pipeline) — long and paid.
2. **Design: Vajra runs the required reviewer itself (Haiku answer d),** plus the README "tested with" line in the
   founder's words (c). Why: the root fix for "the agent graded itself" on a cheap model. Risk: design only; every
   close then costs money.
3. **The review-only sign-off in the step list (S197 design-advisor rec 10) + F126 (a founder change after the review
   has no place).** Why: both are met by every user in every review-only session and after every late change. Risk:
   small; S200 (the next review-only session) may re-rank them anyway.

**Founder pick (2026-10-15): option 2** — the design session; prompt written:
`prompts/199-task-design-vajra-runs-the-reviewer.md`.
