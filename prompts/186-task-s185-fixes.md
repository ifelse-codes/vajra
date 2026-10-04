# Session 186 — CODE: the fixes from the S185 ground truth (F113, F110, F114, F115, N1)

> **Status:** APPROVED by the founder's approval record (`vajra approve 186`), written from the founder's
> S185 picks (2026-10-04: report "approved", option A, F110 option b).

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story (the S185 fix list) · ≤3 files per commit · new chat.

## Goal
Build the designs the S185 ground truth picked (`sessions/session-185-ground-truth.md`, Goal 0 + F114/F115 +
N1), each with a test that fails without it. If F110 (b) grows past the session, ship everything else and
split (b) into its own session — say so; do not ship half a guard.

## Deliverables
1. **F113 — `obeyed_blocks_from: N`.** A strict key in `.ai/CONSTRAINTS.yaml`; only Vajra's own file sets it
   (132); `vajra init` never scaffolds it. Absent → unchecked `obeyed:` claims WARN forever, and the warning
   says so ("this project does not block on unchecked `obeyed:` claims (no `obeyed_blocks_from:` in
   .ai/CONSTRAINTS.yaml)"). Malformed, empty or duplicated → BLOCK naming the line (never a quiet default).
   Replaces `OBEYED_JUDGMENT_FROM_SESSION` as the blocking switch (`src/obeyed/mod.rs:76, :499`); restore the
   honest comment at ~517, and make verify-132's `pre-threshold-warns-and-names-the-exemption` check the new
   words say WHY it does not block (line 241 today checks only that it says it does not block).
   The design-advisor threshold (133) keeps its number; only its printed words stop quoting Vajra's numbering
   (`src/mandate/mod.rs:428`).
2. **F110 (b) — the approvals guard reads where a redirect really writes** (`scripts/hook-approvals-guard.sh`).
   On the de-quoted copy, for each `>`, `>>`, `>|`, `&>`, `<>`, `>&word`: no next word at all (end, `;&|`) →
   not a redirect; a literal target → normalised (`//`, `./`, `..`, case) and resolved against the hook
   input's `cwd` → block only if inside `$ROOT/.ai/approvals`. **Fail closed (block as today)** on a target
   holding `$` `` ` `` `(` `{` `*` `?` `[` `~`, on `>(…)`, on any `cd`/`pushd`/`popd`/`-C`/`--chdir`/`env -C`
   in the command, on a symlink in the target's parent path. Whatever still blocks gets (a)'s message: "put
   the text in a file with the Write tool, then `git commit -F <file>`".
3. **S182 guard recs (all ADD-only):** rec 1 — `..` segments + `approvals` count as the folder in BOTH the
   Write branch and the names test; delete the "a spelling cannot step around it" comment · rec 5 — add
   `git (checkout|restore|clean|reset|stash|apply)`, `find … -delete|-exec|-execdir`, `rsync`, `curl -o`,
   `wget`, `tar`, `unzip`, `patch` to the writers and `sh`, `bash`, `zsh`, `dash`, `eval`, `source`, `xargs`
   to the interpreters · rec 2 — `merge_claude_settings` (`src/cli/init.rs:988`) pushes a matcher with only
   the missing hooks, never a hook already wired under another matcher.
4. **F114** — a fresh project's `scripts/verify-closeout.sh --ledger` with no review files prints "ledger: no
   reviewed sessions yet" and exits 0 (this repo's script and the scaffold's).
5. **F115** — verify-132's `advance-really-binds-on-an-unjudged-obeyed` fixture records a real tech-lead (a
   `tech-lead: skipped` line is refused by the Crew gate — design-advisor rec 13) so the obeyed gate gets its
   turn, and tests both sides of F113: no key → WARN and advances; `obeyed_blocks_from: 132` → blocks with
   `[vajra obeyed]`.
6. **N1** — every `[HOOK BLOCK]` line in `scripts/hook-pre-bash.sh` (39, 77) and `scripts/hook-pre-write.sh`
   (38, 72), and their scaffold copies, goes to stderr, so the agent sees why it was blocked.

## Acceptance
| AC | Check |
|---|---|
| AC1 | A fresh `vajra init` project at session 132 with an unjudged `obeyed:` advances with a WARN naming "does not block"; the same project with `obeyed_blocks_from: 132` refuses; `obeyed_blocks_from: x` refuses naming the line. Vajra's own repo still blocks from 132. |
| AC2 | The guard passes: a heredoc body naming the folder written to `notes.md`; `git commit -m "… .ai/approvals … <noreply@x>"`; a markdown `> quote` line. It still blocks: `echo x > .ai/approvals/y`, `echo x >> .AI//Approvals/../approvals/y`, `cd .ai && echo x > approvals/y`, `echo x > $D/y` naming the folder, `env -C .ai/approvals sh -c 'echo > x'`, `sh -c "echo >"' .ai/approvals/x'`. |
| AC3 | Every command the S182 guard (e1c348e) blocks still blocks with the new guard, except a named, listed set of proven non-writes (a corpus test, design-advisor S185 rec 11). |
| AC4 | `.ai/hooks/../approvals/x` is blocked for the Write tool and for Bash; `find .ai/approvals -delete`, `git checkout -- .ai/approvals`, `sh x.sh .ai/approvals` are blocked. |
| AC5 | `--sync-fleet` on a project whose hook is already wired under another matcher adds no duplicate (a test that fails at e1c348e). |
| AC6 | Fresh project: `bash scripts/verify-closeout.sh --ledger` exits 0 and prints the "no reviewed sessions yet" line. |
| AC7 | `bash scripts/verify-session-132.sh` is fully green, including `advance-really-binds-on-an-unjudged-obeyed`. |
| AC8 | A GT-blocked Write and a GT-blocked `git commit` reach the agent with their `[HOOK BLOCK]` reason on stderr (not "No stderr output"). |

## Design
design-significant: yes
- Why yes: a new `.ai/CONSTRAINTS.yaml` key changes when the Obeyed gate blocks in every project; the
  approvals guard changes what it blocks; `--sync-fleet`'s merge changes its output.
- Cites `docs/decisions/DECISION-007-agent-fleet.md` — S186 addendum: F113 DEVIATES from the S133 addendum §6
  (the S132 precedent: one built-in threshold for every project) and REVERSES the S134 addendum's rejection of
  a per-project `.ai/` marker, for the Obeyed gate only (absent key = never blocks, the founder's 2026-10-03
  rule). Honest limit: an opted-in repo can opt out by editing the key; only the diff shows it.
- Cites `docs/decisions/DECISION-011-controls-the-agent-cannot-type.md` — S186 addendum: FOLLOWS its S183
  strict-key rule; AMENDS the S182 addendum §2 (block a redirect only when it lands in the folder or cannot be
  proven not to; "`cat <folder>/x > /tmp/y` still blocks" is reversed) and corrects "never lists a hook twice".
- F110 (b): redirects are found on the de-quoted copy (heredocs and quotes read, never skipped — S173), the
  target is read from it and from the command as written at the same `>` (a quote there blocks), literal
  targets resolved by the kernel against `cwd`; links, `..` past a missing folder and no `cwd` block.
- Picked in S185 (`sessions/session-185-ground-truth.md`); this session's design-advisor checked the picks
  against the code (`.ai/handoffs/session-186-design-advisor.md`), not re-opened them.

## Carried in
- **Founder rulings to respect:** no per-claim `obeyed:` judge (2026-10-03); Vajra's close does not run
  `cargo test` (2026-10-04); no new policing of Vajra's own paperwork (2026-09-15); obeyed claims are not a
  blocking gate for projects (2026-10-03).
- **S185 findings NOT in this session:** N2 (GT guards block work outside the project, F56 class) · N3
  checklist line (re-run the verify script of any gate touched since the last GT) · N4 (`--steps` names a
  missing approval record) · N5 (`--dogfood-age` blind to rudra) · N6 (hand-kept headers) · N7 (verify
  checkouts in one known folder). Parked: F67, non-Claude tools (F91/F94/F95), release.
- **rudra:** after merge, `vajra init --sync-fleet` in rudra ships the new guard and messages (founder runs it).

## Guardrails
- ≤3 files per commit; every fix has a test that goes red on e1c348e/8e22f16 for the NAMED reason.
- Guard: ADD-only except the listed proven non-writes (AC3). No hiding text from the guard.
- If (b) is not green with its corpus by the ~1h30 mark, stop it, ship 1 + 3–6, and split (b).

## Plan
1. F114: both close scripts list an empty ledger as empty — `--ledger` prints "ledger: no reviewed sessions yet" and exits 0; `--ledger-verify` stops exiting 128 with no commit. — covers: 6
2. N1: the four `[HOOK BLOCK]` lines in `hook-pre-bash.sh` / `hook-pre-write.sh` go to stderr (neither hook is shipped by `vajra init`, so there is no scaffold copy). — covers: 8
3. F113: `obeyed_blocks_from:` strict reader replaces the constant; Vajra's own CONSTRAINTS sets 132; the warning says why it does not block; unit tests for absent / set / malformed / twice. — covers: 1
4. F113 sibling: the design-advisor exemption stops quoting Vajra's session number; verify-133's wording check follows. — covers: 1
5. F115: verify-132's `--advance` fixture records a real tech-lead (dispatch fixture, every role deferred-budget) so the Obeyed gate gets its turn; both sides of F113 plus a malformed key. — covers: 7, 1
6. Guard corpus first (tech-lead rec 3): the S186 commands, the declared non-writes, and an old-vs-new test against e1c348e's guard. — covers: 3, 2, 4
7. S182 recs 1 and 5: `..` segments count as the folder (Write tool and Bash); the added writers and interpreters. — covers: 4
8. F110 (b): the guard reads each redirect's real target, resolved against the hook's `cwd`; fail closed on the brief's list; the block message names `git commit -F <file>`. — covers: 2, 3
9. S182 rec 2: `merge_claude_settings` adds no hook already wired under another matcher (a test red at e1c348e). — covers: 5
10. `scripts/verify-session-186.sh` (each fix red at e1c348e for its named reason) and the demo. — covers: 1, 2, 3, 4, 5, 6, 7, 8
11. DECISION-007 and DECISION-011 addenda (S185 design-advisor rec 12); summary with 3 next options; closeout sync; next prompt; one cold review; the `--inputs-sha 186` stamp last. — covers: 1, 2

Cut line (prompt guardrail): if step 8 is not green with its corpus by ~1h30, ship 1–7 and 9–11 and split (b) into its own session.

## Execution
- step 1 — done: 0dd33f1
- step 2 — done: c6bbeb9
- step 3 — done: 62bfe63
- step 4 — done: b7232d3
- step 5 — done: 4c34e51
- step 6 — done: 3a4fca9
- step 7 — done: 3a4fca9
- step 8 — done: 1409a3c
- step 9 — done: 9dcec17
- step 10 — done: 2c0b576
- step 11 — done: fe1ed46

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `design-advisor` (required), `fidelity-reviewer` (required;
the one cold close review), `release-coordinator` (required; the one judge of every `obeyed:` answer).
implementation-advisor: skipped — the tech-lead deferred it on budget (its rec 2): a guard-code dispatch reads the shell scripts, about 1.5M tokens, and the AC3 corpus test (every command the S182 guard blocked, run through both guards) stands in for its review of F110 (b).

**tech-lead** (`.ai/handoffs/session-186-tech-lead.md`):
- tech-lead rec 1 — refused: in part — F114 → N1 → F113 with F115 landed in the asked order (0dd33f1, c6bbeb9, 62bfe63, 4c34e51), but F110 (b) landed in the same commit as S182 recs 1/5 (3a4fca9) and before rec 2 (9dcec17), so the clean cut the rec wanted was never available; it did not matter because (b) finished inside the cut line (cold review pass 1, probe 5).
- tech-lead rec 2 — obeyed: ac1b5da (no implementation-advisor dispatch; the reasoned skip line is in this section. Its second half — "more than one review pass on (b) → split" — was weighed after pass 1 REJECT: the three holes were small and concrete, so they were fixed in 1409a3c with one fresh pass, as its rec 5 allows, rather than split)
- tech-lead rec 3 — refused: in part — the corpus was written and run red before the guard changed (in-session only: corpus and guard share commit 3a4fca9, so history cannot show the order), and "every command e1c348e blocks" is not a set a test can enumerate. The test is now named for what it proves, a listed corpus (`every_listed_command_the_s182_guard_blocked_still_blocks`, 1409a3c), and the cold review's three missed classes were added to it.
- tech-lead rec 4 — obeyed: 651d174 (the design-advisor brief named the files and asked "do the picks fit the code", not a redesign)
- tech-lead rec 5 — deferred: sessions/session-186-review.md
  why: the one cold fidelity review runs at close on the finished branch; its verdict and the live re-runs it did are recorded in that file.
- tech-lead rec 6 — deferred: sessions/session-186-review.md
  why: the release-coordinator is dispatched once, after this section answers every rec; its judgments land in its own handoff and the review file names them.

**design-advisor** (`.ai/handoffs/session-186-design-advisor.md`):
- design-advisor rec 1 — obeyed: 62bfe63 (one strict reader; a bad key is pushed into `reasons` on every run, whatever the session holds)
- design-advisor rec 2 — obeyed: 2f4c59d (only `NotFound` means no key; any other read error is a blocking reason naming the file)
- design-advisor rec 3 — obeyed: 9ef5c65 (a third wording when the key cannot be read; the `[vajra obeyed]` heading and refusal in 2f4c59d and the close log's BLOCK line in both close scripts name an unreadable key)
- design-advisor rec 4 — obeyed: cfd7f86 (demo-132's subject declares the key, and its case 7 records a real tech-lead — it had the same S135 staleness as F115; demo-132 green 8/8. The kept phrases are unchanged)
- design-advisor rec 5 — obeyed: 596db24 (only "(threshold N)" removed; "predates the design-advisor mandate" kept; verify-133's wording check and its rename probe updated in the same commit)
- design-advisor rec 6 — obeyed: 3a4fca9 (redirects found on the de-quoted copy; the target read from both copies at the same `>`; any difference, quote or backslash in the written one blocks)
- design-advisor rec 7 — refused: in part — its core ask (refuse a symlink in any path component) was not built: refusing every symlink blocks every `/tmp` target on macOS (`/tmp` → `/private/tmp`), including AC3's own read. Built instead (3a4fca9): `cd -P` resolves the existing part as the kernel would, so a symlink is FOLLOWED to where the write really goes; a symlinked or hard-linked last component, a `..` past a missing folder, and no/empty `cwd` block (`a_linked_target_or_a_missing_cwd_is_not_provable`). Recorded in DECISION-011's S186 addendum.
- design-advisor rec 8 — obeyed: 3a4fca9 (heredoc bodies and quoted text are scanned; `> quote` in a body resolves to a harmless literal)
- design-advisor rec 9 — obeyed: 3a4fca9 (new writers and shells match only at a command start or after a wrapper; the S182 lists are unchanged; a commit message naming `hook-approvals-guard.sh` and "source" is in the corpus and passes)
- design-advisor rec 10 — obeyed: 3a4fca9 (bash 3.2 + BSD tools only: `tr`, `cd -P`, `ls -ld`, awk with ENVIRON; the guard tests pass under `/bin/bash` 3.2.57 and bash 5)
- design-advisor rec 11 — obeyed: 9dcec17 (a hook counts as wired only under a covering matcher; the pushed group carries only the missing hooks; AC5 fixture red at b10a1a6 ("runs it twice"); the loader is still added for Bash when wired only for Edit)
- design-advisor rec 12 — refused: the premise is wrong — at main (b10a1a6) the four lines print to stdout (`git show b10a1a6:scripts/hook-pre-bash.sh` line 77 has no `>&2`); the advisor read the working tree after c6bbeb9 had landed. The AC8 test it asked for was built anyway (verify-186: new on stderr, b10a1a6 on stdout, both hooks).
- design-advisor rec 13 — obeyed: 4c34e51 (the fixture records a real, provenance-verified tech-lead; the brief's skip-line option removed in ef560a6)
- design-advisor rec 14 — obeyed: ef560a6 (DECISION-007 S186 addendum names the deviation against the S133 addendum §6 and the S134 rejection, with the opt-out limit)
- design-advisor rec 15 — obeyed: ef560a6 (DECISION-011 S186 addendum: follows S183's strict-key rule, amends S182 §2, reverses its over-block sentence, corrects "never lists a hook twice")

**fidelity-reviewer** (`.ai/handoffs/session-186-fidelity-reviewer.md`; pass 1 REJECT 12/15 — its recs are answered here; pass 2's handoff replaces pass 1's, both are in `sessions/session-186-review.md`):
- fidelity-reviewer rec 1 — obeyed: 1409a3c (a backslash-newline is joined first, as the shell does; P1 in `s186_writes()`)
- fidelity-reviewer rec 2 — obeyed: 1409a3c (awk, gawk, mawk, nawk, editors, sqlite3, php, lua and similar block at a command start while naming the folder; P2 in the corpus)
- fidelity-reviewer rec 3 — obeyed: 1409a3c (`cd`/`pushd`/`popd`/`chdir` after any non-letter, and a command word holding `$`, a backtick or `{`, count as a directory change; zsh `>!` read as `>|`; P3 in the corpus)
- fidelity-reviewer rec 4 — obeyed: 1409a3c (command starts after `if`/`while`/`then`/`do`/`!`/`{` and `NAME=value`; `.`; `git` with any options before the subcommand; `curl -o<path>`; plus `sponge`)
- fidelity-reviewer rec 5 — obeyed: a20c94b (DECISION-011 says "every LISTED command" and names the three found classes and the open "a writer no list names" class; the test renamed in 1409a3c)
- fidelity-reviewer rec 6 — obeyed: fe1ed46 (tech-lead recs 1 and 3 and design rec 7 are now `refused: in part` with reasons; tech-lead rec 2 re-cited to ac1b5da — this section, landed after fe1ed46)
- fidelity-reviewer rec 7 — obeyed: fe1ed46 (SESSION-BOOT names S187 next and S186 as CODE; `prompts/187-task-rudra-s18-new-guard.md` exists; step 11 re-pointed to fe1ed46)
- fidelity-reviewer rec 8 — obeyed: 1409a3c (a hook `cwd` inside `.ai/approvals` counts as naming it; `a_cwd_inside_the_folder_blocks_a_redirect`)

## Delta
- `+` `obeyed_blocks_from:` key (Vajra's own CONSTRAINTS only) and its strict reader
- `+` a target-reading approvals guard with a fail-closed list; `..`, writer and interpreter additions
- `+` F114 first-run ledger fix · F115 fixture rebuilt · hook block messages on stderr
- `-` `OBEYED_JUDGMENT_FROM_SESSION` as the blocking switch for every project
