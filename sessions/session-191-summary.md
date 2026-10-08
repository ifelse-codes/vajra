# Session 191 — Summary (CODE: four small, bounded fixes from the S190 review)

**Branch:** `session-191-small-fixes` · **Prompt:** `prompts/191-task-small-fixes.md` (founder-approved,
`vajra approve 191`) · **Record:** DECISION-011 S191 addendum (§1 N2, §2 the heredoc shape) · **Verify:**
`scripts/verify-session-191.sh` (65/65) · **Demo:** `scripts/demo-session-191.sh` (8/8 live checks) · full
`cargo test` 699 passed / 0 failed · **Review:** `sessions/session-191-review.md` (one cold pass, ACCEPT 9/9; 4 of 5 recs fixed) · cost $0 (no paid run).

## Goal achieved?

Yes — all four fixes shipped, each with a check that is red at the start commit (f37b0fe) for its named reason
and green now. Item 4 (the risky one) was green with its corpus well inside the cut line; nothing was split out.

- **N2 — a review-only session can write outside the project.** The ground-truth Write guard lets a write through
  when it can show the target is outside: root and target folder resolved through every symlink, then the folder
  walked up comparing by inode (catches macOS's `/System/Volumes/Data/…` spelling — the review's find), absolute plain-ASCII
  paths only, no `.`/`..` part, a link / hard link / non-file leaf refused, lower-cased `/`-boundary compare, every
  step fail-closed. A missing folder blocks and says "mkdir -p it first". It also closes an old hole:
  `/proj/.ai/../src/x.rs` passed as `*/.ai/*` at f37b0fe; now it blocks.
- **N13 — the heredoc hole.** The one-session-per-chat guard no longer reads the body of ONE shape: a whole
  command that is a single `cat`/`tee` file write with a QUOTED delimiter and nothing after the terminator. Every
  other shape is read exactly as before (66 commands from S173's list give the same result old and new).
- **`--advance`'s number swap.** Only the number right after `**Number:**` moves; the real S188 line (which names
  188 five more times — the prompt said six; six in all) keeps the other five.
- **verify-133 twice at once.** Each run gets its own fixture checkout (under `target/`, pid in the name, removed by
  an EXIT trap) and its own log folder. At f37b0fe two runs at once both fail; now 3 rounds by hand, all green.

## Fidelity map

| # | Requirement | Status | Evidence |
|---|---|---|---|
| D1 | N2 outside-pass per S187 recs 12–20 + DECISION-011 S191 addendum | SHIPPED | 64248b9 (`hook-pre-write.sh` `gt_plain_path` + `gt_outside`; addendum §1) + 23971d5 (the inode walk, review rec 1); verify AC1, 22 rows |
| D2 | `update_session_boot` swaps only the token after `**Number:**` | SHIPPED | c44bbd6 (`swap_boot_number` + 2 tests); verify AC2 (the same test RED at f37b0fe: "session-189-summary" written into the S188 line) |
| D3 | verify-133 safe to run twice at once | SHIPPED | 96d4b86; verify AC3 (old pair exits `1 1` on the fixture check; new pair `0 0`; no checkout left) |
| D4 | the session guard stops reading a heredoc body, unless fed to a shell | SHIPPED (narrower than worded) | 1d43183; verify AC4. Narrower on purpose (design-advisor rec 7): only a quoted-delimiter `cat`/`tee` file write passes — an UNQUOTED `<<EOF` note still blocks, because the shell expands `$( )` in it |
| AC1 | inside blocks via physical / linked / `..` paths; outside passes; rec 19's cases, red at start where they apply | SHIPPED | verify AC1: 4 outside cases block at f37b0fe, pass now; `..` passes at f37b0fe, blocks now; every inside spelling blocks at both |
| AC2 | the real S188 line advances with the other 188s untouched | SHIPPED | `update_session_boot_leaves_prose_numbers_alone` (the line copied from `.ai/SESSION-BOOT.md` at 976ba05, checked by verify) |
| AC3 | two concurrent runs both pass | SHIPPED | verify AC3 (one round in verify — the 600 s close bound; three rounds by hand) |
| AC4 | the plain-file heredoc passes; typed checkout and `| bash` heredoc block; old-vs-new corpus | SHIPPED | verify AC4: 7 shape rows pass now/blocked before; 25 must-block rows; 66-command corpus unchanged; no-perl and L1 rows |
| AC5 | verify-191 green; `cargo test` in full | SHIPPED | verify 65/65; `cargo test` 699/0 (after the review fixes) |

## The cold review (one pass, ACCEPT 9/9) and what it changed

- **rec 1 — a real hole, confirmed live then fixed (23971d5):** `cd -P` resolves symlinks, not macOS firmlinks. An
  inside file spelled `/System/Volumes/Data/…/proj/src/x.rs` passed the first N2 build (exit 0). The guard now also
  walks the target's folder up to `/` and refuses any step that IS the root by inode (`-ef`). Verify row: red at 64248b9.
- **rec 2 (23971d5):** the addendum says "every symlink", names the inode walk, and says the non-ASCII refusal
  covers only the typed path.
- **rec 3 — worse than reported, fixed:** the two verify-133 runs shared one build folder. A lock made BOTH runs red —
  cargo judged "fresh" from the other checkout's file times and tested the other run's binary. Each run now gets its
  own build folder, cloned copy-on-write from the shared one. A concurrent pair now takes ~3 min, not ~80 s.
- **rec 5 (b0ef01b):** `--advance` warns when no `**Number:** NN` line moved, instead of saying "updated".
- **rec 4 — refused:** a `/` or unresolvable root never reaches the ground-truth branch through the real hook
  (no `.ai/`, no session branch there), so a row would test a path the hook never takes.

## What was NOT built / limits (named, not closed)

- **The write guard is a speed bump, not a sandbox.** In a review-only session Bash could already write anywhere.
  A parallel call can swap a checked folder for a link between the check and the write; another worktree or clone
  of the repo counts as "outside"; a non-ASCII path blocks even outside. `hook-pre-write.sh` is Vajra's own — no
  project gets it.
- **The heredoc rule trusts `cat` and `tee`.** A shell function or alias of that name is not seen. A backticked or
  `$( )` checkout inside even the quoted shape still blocks (kept on purpose). zsh was not exercised.
- **Reaching rudra:** `hook-session-guard.sh` ships to projects. An unedited copy is rewritten by
  `vajra init --sync-fleet` — but only with a vajra built from S191 or later; nothing here installs it.
  (The tech-lead's rec 6 said "only new projects"; that was checked and is wrong — refused in `## Advice`.)
- verify-191 runs the verify-133 race once, not three times.
- **A fifth S190 pick was not in this prompt:** S190's report and review picked `find_session_jsonl`'s folder
  naming (`src/meter/mod.rs:879`; a project path with `.`, `_` or a space gets no receipt) "→ S191", but the
  approved S191 prompt names four items. Not built; put to the founder at the S191 check-in.

## Fakest green

AC4's "nothing blocked before passes now" is proven on a LIST — S173's forms, the design-advisor's 25 shapes and
three heredoc-then-run shapes. A command shape nobody listed is not covered. What makes the list more than examples:
the strip only fires on one exact opener regex plus "nothing after the terminator", so any listed or unlisted
command outside that shape is read byte-for-byte as before. The risk sits only inside the shape itself, and there
the argument is the shell's own rule (a quoted delimiter expands nothing).

## Process

- Crew per the tech-lead: design-advisor → build → one fidelity-reviewer → one release-coordinator. Five roles
  deferred on budget (skip lines in `## Advice`).
- `vajra next --advance` refused at first: S190's merged local branch `session-190-closeout` was not yet pruned
  (the founder's step).

## Next — 3 ranked candidates

1. **(Recommended) Prove the receipt live (S189 carries).** One tiny paid interactive `vajra claude` run with
   `/clear`, `--continue` and a fork, to settle the fork start-time assumption and the SessionStart session-id gap.
   Why: S189's fix is proven only on recorded lines; this is the last 🟡 on the receipt. Risk: needs the founder's
   yes and a few cents; it may surface a gap the stand-in could not.
2. **rudra S18 under the new rules.** Install the S191 vajra, `--sync-fleet` rudra, and run a real session —
   the first real use of S188's approvals check, S189's receipt and S191's guard. Why: real use finds what fixtures
   cannot. Risk: waits on rudra's own work (its data API).
3. **The non-Claude tools brainstorm (F91, F94, F95).** Promised since S179: OpenCode's agent and the founder look
   the same to the git guards. Why: the next user may not use Claude Code. Risk: a design session — nothing a user
   runs comes out of it.
