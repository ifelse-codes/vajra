# Session 201 — the S200 small fixes + the README "tested with" line

**Branch:** `session-201-small-fixes` · **Type:** CODE · **Start commit:** `edb92e3` · **Prompt:** `prompts/201-task-small-fixes.md`

## Goal achieved?

Yes. All four items are done, in the prompt's order, and none was moved out under the split rule. Each has a verify
row that runs the real thing. Where a binary is involved, the row runs again with the binary from `edb92e3`, and
there it goes red. The README line is the founder's own words: he picked the "Short" draft in this chat on
2026-10-17.

## What shipped

| Fix | What a user sees now | Commits |
|---|---|---|
| **N24 — the report first** | On a review-only session, while `sessions/session-NN-ground-truth.md` does not exist, the sign-off step's how starts "write sessions/session-NN-ground-truth.md (every audit, live), then show it to the founder; …". Once the report exists, the how is the old "show the founder …". | `e78b02a` |
| **N24 — verify/demo steps** | On a review-only session, "the checks run and pass" and "a demo script exists…" are ✓ and read "— not needed: the close passes it N/A on a review-only session (no session scripts expected)". The answer comes from the same shared helper (`review_only()` → `vajra_is_ground_truth`) that the close's `is_ground_truth_session` uses. That makes it the gate's own rule (`check_verify_demo_scripts`), not a new one. A CODE session keeps both steps ✗ until it has its scripts. | `e78b02a` |
| **N22 — retired** | `scripts/verify-session-178.sh` and `scripts/demo-session-178.sh` now open with a RETIRED (superseded) block. It names the later wording changes that break their rows (S181 Part 5, S184 F107, S186 F113, each with commits), the S200 evidence, and where S178's own fixes still live (F83 `src/fleet/mod.rs`, F86 `src/fidelity` + `src/mandate`, F87 `src/crew`). Every changed line is an added comment. ROADMAP's N22 entry says RETIRED S201. | `55e5d14` |
| **N25 — reinstall** | The text that hands the founder the after-merge steps is the merge step's how ("the work is merged and the branch is gone", `src/nextstep/mod.rs`, `reinstall_note` at line 357). In Vajra's own repo it now adds "If the merged branch touched src/, tell the human to run `cargo install --path . --locked` on main after pulling — or the next boot runs the old vajra." Vajra's own repo is detected from `Cargo.toml`'s `[package]` `name = "vajractl"`, read as a key, never from prose. Another project (rudra) never sees the line, and neither does a project that only depends on `vajractl`. A note, not a gate. | `d5ff467` |
| **README** | After the Current Status table, in the founder's words: "**Tested with:** Claude Code on Opus and on Haiku 4.5. On Opus the agent followed Vajra's steps; on Haiku it skipped every step that is only an instruction — only what Vajra blocks (the 3-file cap, a push to main) held." | `5c1c295` |

**The founder's words, quoted (AC4):** three drafts were offered in this chat (Short / With evidence / With the RED
close). He picked **"Short"** on 2026-10-17, and that text went in unchanged. His reply, as the chat's question
tool recorded it: `"Short" selected` (with the Short preview text). Verify row 5 checks only that this text is in the
README; who picked it rests on this record (review rec 3).

**Evidence:** `scripts/verify-session-201.sh` 5/5 (`1a8b7d0`).
- Row 1 uses a `vajra init` project on review-only session 10, with the earlier steps done (a recorded tech-lead, a
  filled Delta, the approval record), so the sign-off step is the first open one, as it was in S200. With no report,
  "▶ YOUR NEXT STEP … how: write sessions/session-10-ground-truth.md (every audit, live)…". With the report, "show
  the founder …". `edb92e3`'s binary says "show the founder" with no report.
- Row 2: the same project. Session 10 shows both script steps ✓ "not needed". CODE session 9 shows both ✗.
  `edb92e3` showed both ✗ on session 10.
- Row 3: the unit test `only_vajras_own_repo_is_told_to_reinstall_after_the_merge` runs: no Cargo.toml, a `rudra`
  package with a `vajractl` dependency, and a `vajractl` package. It also checks the file line, and that the text is
  absent at `edb92e3`.
- Row 4: the diff since `edb92e3` of both 178 scripts holds only added comment lines (0 others). Both headers and
  the ROADMAP entry say RETIRED.
- Row 5: the README line is there, and absent at `edb92e3`.

`scripts/demo-session-201.sh`: 6/6 live checks. Full `cargo test`: 745 passed / 0 failed (summed from `^test result` lines only). `scripts/ci-lint.sh` exit 0.

**Re-run at the tip after the review (review rec 4), real final lines:** `=== verify-session-201: 5 passed, 0 failed ===` ·
`cargo test: passed=745 failed=0` · `ci-lint exit=0` · demo `✓ demo complete — all 6 live checks passed`.

**The "before" binary (review rec 5):** AC1 names `0caedc3` (S199's merge); the scripts pin `edb92e3`, the commit S201
started from (S200's merge on top of it). `git diff 0caedc3 edb92e3 -- src build.rs Cargo.toml Cargo.lock` is empty
(0 lines), so the two binaries are built from the same code.

## Fidelity map

| Prompt item | Grade | Evidence |
|---|---|---|
| D1 / AC1 N24 | SHIPPED | verify rows 1–2; unit test `a_review_only_session_writes_the_report_first_and_needs_no_scripts` |
| D2 / AC2 N22 | SHIPPED | verify row 4. **Precedent, said plainly (tech-lead rec 3):** verify-182/186/187 were retired in `sessions/session-190-ground-truth.md:53` and ROADMAP, not in their own headers, and verify-175 has only an inline note. A header block goes one step past that precedent, as this prompt asked. |
| D3 / AC3 N25 | SHIPPED (a test and the file line, not a live merge) | verify row 3; `src/nextstep/mod.rs:357`. `--steps` prints a step's how only for the first open step, and the merge step is last, so no real run of a whole session was made to show it. |
| D4 / AC4 README | SHIPPED | verify row 5; the founder's pick quoted above |
| AC5 verify + demo, cargo test, close GREEN, push via the belt | PARTIAL until the push | verify 5/5, demo 6/6, cargo test above. The close and the push come after this file, and are recorded at S202's start. |
| Carried: S200's push recorded | SHIPPED | PR #239 head `09002d8` = `.ai/verify/closeout/20261016T181319Z/result` (`verdict: GREEN`, 25/0, `clean: yes`) |

**Not built:** nothing in the prompt. **In-session change to the approved prompt:** it had no `## Guardrails`, so
`vajra next --advance` refused it. A Guardrails section was added (`b527493`) that restates the prompt's own rules
and adds none. The founder should know this happened.

**Fakest green:** N25. The test proves the line appears in a Vajra-shaped project, but nothing proves the founder
reads it at the right moment. It shows only when the merge step is the next open one, and the agent must pass it on.
S200's hand-written SESSION-BOOT line did the same job. Next: verify-178/demo-178 still fail when run. "Retired"
means history, not fixed.

## New findings (filed, not fixed)

- **N28** (LOW): `vajra next --advance` with an open, non-terminal stdin (an agent's shell that does not close it)
  waits forever at `confirm()`'s `read_line` (`src/cli/next.rs:2200-2203`). It hung once here, for 2 minutes, until
  re-run with `</dev/null` (KNOWLEDGE line 239 already says so). The S173 "no terminal → advance" path cannot tell a
  slow pipe from one nobody will write to.

## Process

- Crew: tech-lead (mandatory, first); fidelity-reviewer (one cold pass); release-coordinator (the one judge of every
  `obeyed:` answer). The other six were deferred on budget, each with a reasoned skip line in `## Advice`.
- $0 agent spend. No paid run.

## 3 ranked next candidates

**The founder's decision (2026-10-17, in this chat, after seeing every open item):** "I think we should stop
development of Vajra and use it in some other project to see if it actually helpful … I feel it does not impact."
Then: "finish all now and close it". So the pick is 1. Which project is still his to choose.

1. **(Founder's pick) S202 — pause Vajra development; use it on another project.** No Vajra code. The founder runs
   Vajra on a real project (rudra or a new one, his choice) and judges it by that project's own goals: did Vajra
   catch a real mistake, what did it cost, would he keep it on. Vajra changes only when something blocks that
   project's work. **Why:** 30 sessions of fixes were mostly found by Vajra watching itself, there are 0 outside
   users, and ~62% of commits are paperwork (S200). Whether it helps another project is the open question.
   **Risk:** a test with no stated measure turns into "it felt fine". Write the measure down before the first session.
2. **rudra S22, synced.** Reinstall, `--sync-fleet`, then a real rudra session to close. **Why:** today's fixes on a
   real project. **Risk:** it is still Vajra-centred, and long and paid.
3. **Cut the start cost (boot diet F4).** **Why:** every session loads ~95 KB at start. **Risk:** more Vajra
   development, which is what the founder just paused.
