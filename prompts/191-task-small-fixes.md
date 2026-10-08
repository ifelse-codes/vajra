# Session 191 — CODE: four small, bounded fixes from the S190 ground truth

> **Status:** DRAFT — written from the founder's S190 pick (2026-10-07: "Approved as written, option A").
> He approves it with `vajra approve 191` in his own terminal; the gate reads the approval record.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story (this fix list) · ≤3 files per commit · new chat.

## Goal
Build the four fixes the S190 ground truth picked (`sessions/session-190-ground-truth.md`, Goal 2, items 1/4/5/6),
each with a test that fails without it. The heredoc fix (item 4 below) is the one with real risk — keep it to its
own commit with an old-vs-new corpus test, and if it is not green by the cut line, ship the other three and split
it into its own session rather than rush a guard change.

## Deliverables
1. **N2 — the ground-truth write guard no longer blocks writes outside the project** (`scripts/hook-pre-write.sh`,
   the `GT_PW=1` branch). Per `.ai/handoffs/session-187-design-advisor.md` recs 12–20 (already fully specified,
   not yet built):
   - Resolve `$ROOT` physically (`cd -P "$ROOT" && pwd -P`); block if that fails (rec 12).
   - Only an absolute target path earns a pass; block on empty, relative, a control character/newline, or a
     path ending in `.`/`..` (rec 13).
   - If the leaf exists and is a symlink (`[ -L ]`) or has more than one hard link (`find "$f" -links +1`),
     block (rec 14).
   - Compare with a `/` folder boundary, case-folded on both sides; pass only when the folded target is neither
     the folded ROOT nor under `ROOT/` (rec 15).
   - Every resolution step must survive `set -euo pipefail` (`X=$(CDPATH= cd -P -- "$d" 2>/dev/null && pwd -P) || X=""`)
     — a crash must block (exit 2), never silently pass (rec 16).
   - The outside-pass lives only inside the existing `GT_PW=1` branch, after today's allowlist match for inside
     paths; a path with a `..` segment still blocks before the allowlist runs (rec 17).
   - A folder that does not exist yet still blocks; the message says the way past (create it in Bash first,
     then write) (rec 18).
   - Record the design and its stated limit (speed bump, not a sandbox; Bash still blocks only commit/push/PR;
     a parallel-call check-then-write gap remains) as a **DECISION-011 S191 addendum** (rec 20).
2. **`vajra next --advance`'s SESSION-BOOT rewrite no longer corrupts prose** (`src/cli/next.rs:1951`,
   `update_session_boot`). Today `line.replace(&current_str, &next_str)` rewrites every occurrence of the
   two-digit session number on the `**Number:**` line, corrupting any other mention of the same digits in that
   line's prose (confirmed live at S190 against `.ai/SESSION-BOOT.md`'s real S188 line, which names "188" six
   more times). Fix: locate `**Number:**`, then replace only the number token immediately following it
   (skipping leading whitespace), leaving everything else on the line byte-for-byte untouched.
3. **`scripts/verify-session-133.sh` is safe to run twice at once.** Its `fixture_fails_for_the_right_reason`
   check hardcodes one fixed worktree path (`$ROOT/target/s133-fixture-wt`); any two concurrent invocations
   collide on its `index.lock`, not just the one path S187's `V133_LOCK` serializes for its own nested call.
   Fix: give the fixture a per-invocation path (`mktemp -d`, or a PID/timestamp suffix), matching the pattern
   `vajra_old_checkout` already uses elsewhere in this repo.
4. **`hook-session-guard.sh` no longer reads a heredoc body as command text.** The one-session-per-chat guard
   already strips `'...'`/`"..."` quoted spans (S173), but a heredoc body (`cat > file <<'EOF' … EOF`) is
   unquoted multi-line text that lands straight into `$SCAN` — so writing or copying prose that happens to
   contain "checkout -b session-NN-" (including Vajra's own AGENTS.md boilerplate, or this hook's own block
   message) via a heredoc can trip the same-chat boundary check. Fix: strip heredoc bodies from `$SCAN` the
   same way quotes are stripped (it is data being written to a file, not executed) — UNLESS the heredoc is
   piped into a shell (`<<EOF | bash`), which must stay scanned under the existing "extra text only adds" rule.

## Acceptance
| AC | Check |
|---|---|
| AC1 | A Write targeting a path under the real project root (via its physical path, a symlinked ancestor, or a `..`-containing path that resolves back inside) still blocks during a ground-truth session. A Write targeting a path genuinely outside the project (e.g. `/tmp/...`, not a symlink into the project) passes. Each of design-advisor rec 19's listed fixture cases is covered, each red at the start commit where it applies. |
| AC2 | `.ai/SESSION-BOOT.md`'s real S188 "**Number:** 188" line (which names "188" six more times in surrounding prose) advances to "189" with every other occurrence of "188" on that line left untouched — used as the regression fixture, since it already exists on disk at a known commit. |
| AC3 | Two concurrent `bash scripts/verify-session-133.sh` invocations (no `V133_LOCK` wrapper) both pass, run in parallel in the test. |
| AC4 | The guard passes: a heredoc body containing "checkout -b session-191-x" written to a plain file (`cat > notes.md <<'EOF' ... EOF`, not piped to a shell). It still blocks: `git checkout -b session-191-x` typed directly, and a heredoc piped into a shell (`cat <<'EOF' | bash`) containing the same text. Every command the pre-S191 guard blocked still blocks (an old-vs-new corpus test, same discipline as S173/S186). |
| AC5 | `bash scripts/verify-session-191.sh` is green; `cargo test` passes in full. |

## Design
design-significant: yes
- Why yes: AC1 loosens the ground-truth write guard (a design change per DECISION-011's own rule: "loosening a
  text/path guard is a REMOVAL; it needs a class-level argument" — S186 lesson); AC4 changes what the
  one-session-per-chat guard reads as command text.
- Cites `docs/decisions/DECISION-011-controls-the-agent-cannot-type.md` — **S191 addendum** (new, per
  design-advisor rec 20 from `.ai/handoffs/session-187-design-advisor.md`): records the outside-pass's physical
  resolution (ROOT and target both `cd -P`'d, absolute-only, symlink/hard-link leaf check, case-folded `/`
  boundary, fail-closed on any resolution error) and its stated limit — a speed bump, not a sandbox; Bash still
  blocks only commit/push/PR in a ground truth, and a parallel-call check-then-write gap remains (the design
  was fully specified at S187 but never built or recorded; this session builds and records it together).
- The heredoc fix (AC4) DEVIATES from the S173 rule that this guard's reading may only ever add — for this one
  guard and one declared shape (a whole-command quoted-delimiter `cat`/`tee` file write, nothing after the
  terminator). Recorded in the same DECISION-011 S191 addendum (§2), with its class-level argument and limits,
  plus a `.ai/KNOWLEDGE.md` line (S191 design-advisor rec 11 corrected the earlier "bug fix, no ADR" wording).
- The SESSION-BOOT and verify-133 fixes (AC2, AC3) are implementation bugs against existing, unchanged
  behavior — no design change, no ADR.

## Carried in
- **Founder rulings to respect:** no per-claim `obeyed:` judge (2026-10-03); Vajra's close does not run
  `cargo test` separately from `verify-closeout.sh`'s own gate (2026-10-04); no new policing of Vajra's own
  paperwork (2026-09-15).
- **From S190, dropped — do not re-open without a new founder ask:** F110(b) (built for a Bash text-reading
  guard S188 retired — a dead branch) and F110 option A (Claude Code's sandbox `denyWrite` — already rejected,
  DECISION-011 S188 addendum's Rejected list).
- **From S190, kept in backlog (not this session):** the rest of N7 (old verify/demo scripts' own checkouts);
  F97's opt-out key; `tests/gt_cadence_shared.rs`'s loose `announces_gt()` assertion (N7-class, LOW); S188's
  three named before/after-check gaps (accepted risk, no incremental fix); the older verify checks superseded
  by S188 (verify-182/186/187 — formally RETIRED per S190, left as history).
- **Parked:** non-Claude tools (F91/F94/F95), release (`cargo publish` is the founder's own call, not a routine
  step).

## Guardrails
- ≤3 files per commit; every fix has a test that goes red on the start commit for the NAMED reason.
- AC4's guard change removes blocks for ONE declared shape; every other old block must still block — the old-
  vs-new corpus test is mandatory before it ships (S173/S186 precedent: guard-parsing changes get it wrong on
  the first pass more often than not). (Corrected per S191 design-advisor rec 11; was "ADD-only in effect".)
- Cut line: if AC4 is not green with its corpus by the ~1h30 mark, ship items 2/3 (and item 1 if already done)
  and split the heredoc fix into its own session — say so; do not ship a half-tested guard change.

## Plan
1. Item 2 (SESSION-BOOT number-swap): anchor `update_session_boot`'s replace on the token after `**Number:**`;
   regression test using the real S188 line. — covers: 2
2. Item 3 (verify-133 concurrency): per-invocation fixture worktree path; a concurrent-run test. — covers: 3
3. Item 1 (N2, the outside-project write guard): build the physical-resolution outside-pass per design-advisor
   recs 12–19; the rec 19 fixture cases; the DECISION-011 S191 addendum (rec 20). — covers: 1
4. Item 4 (heredoc hole): strip heredoc bodies from `$SCAN` unless piped into a shell; the old-vs-new corpus
   test (every pre-existing block must still block) plus the new heredoc-passes / heredoc-piped-still-blocks
   cases. — covers: 4
5. `scripts/verify-session-191.sh` (each fix red at the start commit for its named reason) and the demo script;
   the full `cargo test`. — covers: 1, 2, 3, 4, 5
6. Summary with 3 next options; closeout sync; next prompt; one cold review; the `--inputs-sha 191` stamp last.
   — covers: 1, 2, 3, 4

Cut line (prompt guardrail, repeated from above): if step 4 is not green with its corpus by ~1h30, ship steps
1–2 and whatever of step 3 is done, skip step 4's build, and split it into its own session.

## Execution
- step 1 — done: c44bbd6
- step 2 — done: 96d4b86
- step 3 — done: 64248b9
- step 4 — done: 1d43183
- step 5 — done: 1445896
- step 6 — done: 17d49a3

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `design-advisor` (required; design-significant: yes),
`fidelity-reviewer` (required; the one cold close review), `release-coordinator` (required; the one judge of every
`obeyed:` answer).
researcher: skipped — the tech-lead deferred it on budget: no open facts (N2 fully specified at S187, items 2 and 3 local bugs with the cause named); ~0.4M would take the ~3.6M crew to ~4.0M without answering anything new.
requirements-analyst: skipped — the tech-lead deferred it on budget: the 4 deliverables and AC1–AC5 restate the founder's S190 pick ("option A, approved as written"); ~0.4M would buy only a restatement.
plan-advisor: skipped — the tech-lead deferred it on budget: the Plan already covers every AC with `covers: N` and has a cut line; its rec 1 gave the one order that mattered (~0.4M more).
implementation-advisor: skipped — the tech-lead deferred it on budget: ~0.8M takes the crew to ~4.4M; the design-advisor's exact heredoc shape (recs 7–8), the mandatory old-vs-new corpus and the cut line stood in for it.
qa-specialist: skipped — the tech-lead deferred it on budget: AC5 already makes verify-191 run every fix red at the start commit; the fidelity-reviewer re-runs it (~0.8M saved).
demo-producer: skipped — the tech-lead deferred it on budget: the only on-screen change is one guard message, which the fidelity-reviewer reads (~0.4M saved).

**tech-lead** (`.ai/handoffs/session-191-tech-lead.md`):
- tech-lead rec 1 — obeyed: c44bbd6 (item 2), 96d4b86 (item 3), 64248b9 (item 1), 1d43183 (item 4, its own commit); item 4 and its corpus were green well inside the cut line, so nothing was split out
- tech-lead rec 2 — obeyed: 1d43183 (an allow-list of one exact shape — the design-advisor's rec 7 made it stricter: a quoted delimiter only, nothing after the terminator; every other shape, `| bash` / `bash <<` / `sh -s` / `source /dev/stdin` / `| xargs` / `ssh`, stays read; EXTRA still from the raw command; no perl → nothing removed)
- tech-lead rec 3 — obeyed: 1445896 (verify-191 AC4: S173's whole list, incl. the bash 3.2 `)"` case and the `git commit -m "$(cat <<'EOF' …)"` form, under /bin/bash 3.2; both keep blocking)
- tech-lead rec 4 — obeyed: c44bbd6 (the real S188 line as a literal; a line with no `**Number:**` and the same digits before the field, both unchanged)
- tech-lead rec 5 — obeyed: 96d4b86 (one checkout per run, removed by an EXIT trap on every way out, then `git worktree prune`; three concurrent rounds run by hand, all green, no leftovers — on the 96d4b86 version; after the build-folder fix, aecfd25, two rounds: one by hand and verify-191's own). refused in part: `mktemp -d` — the checkout stays under `target/` with the pid in its name, because verify-133's own note measured its `cargo test` at >10 min in a checkout under $TMPDIR vs ~12 s under `target/`; and verify-191 runs one concurrent round, not three, to stay inside the 600 s close bound (a round is ~80 s; three were run by hand)
- tech-lead rec 6 — refused: the rec said item 4 reaches only NEW projects. Checked (design-advisor rec 12): `hook-session-guard.sh` is in `SYNC_HOOKS` (src/cli/init.rs:25), and `--sync-fleet` rewrites an unedited stamped copy (`StaleRender`, src/cli/init.rs:226). So an existing project gets it on its next sync with a vajra built from S191+; the summary and DECISION-011 S191 addendum §2 (1d43183) say that instead
- tech-lead rec 7 — obeyed: 8effeb1 (design-advisor → build → one fidelity-reviewer → one release-coordinator after this section; the skip lines above carry the budget reasons)

**design-advisor** (`.ai/handoffs/session-191-design-advisor.md`):
- design-advisor rec 1 — obeyed: 64248b9 and 1d43183 (one "S191 addendum" inside DECISION-011, §1 N2 and §2 heredoc; §1 says it records the guard's outside-pass for the first time)
- design-advisor rec 2 — obeyed: 64248b9 (inside `GT_PW=1`; the bad-path check first; the allowlist pass arm unchanged; the outside test only in `*)`; an outside write falls through to the main/master warning; `gt_refuse` keeps the L1 rule in one place)
- design-advisor rec 3 — obeyed: 64248b9 (`gt_plain_path`: absolute only; `..`, `.` segments and a trailing `/` refused; a newline refused; any byte outside space..`~` refused — grep exit 1 is the only pass, so a grep failure refuses)
- design-advisor rec 4 — obeyed: 64248b9 (`gt_outside` (a)–(e): root resolved and not `/`; parent/leaf split; leaf link / hard link / not-a-plain-file refuse; `LC_ALL=C tr` lower-case; quoted `case` on a `/` boundary). Fixtures assert exit exactly 2: 1445896
- design-advisor rec 5 — obeyed: 64248b9 (the missing-folder message names `mkdir -p`, no walking up) and 1445896 (passing: /tmp, /private/tmp, $TMPDIR; blocking: the root under /var with the file via /private/var, and the reverse)
- design-advisor rec 6 — obeyed: 64248b9 (DECISION-011 S191 addendum §1, the rec's text edited for the built code — e.g. "a non-ASCII path refuses")
- design-advisor rec 7 — obeyed: 1d43183 (exactly the six opener shapes, a quoted `[A-Za-z_][A-Za-z0-9_]*` delimiter, a `[A-Za-z0-9_./-]` path with an optional `~/`; opener and terminator kept in SCAN)
- design-advisor rec 8 — obeyed: 1d43183 (one perl step; it walks the lines and stops at the FIRST line exactly equal to the delimiter; what follows must be whitespace). refused in part: the byte-for-byte test — perl never re-prints a command: any other shape makes it print nothing and fail, and SCAN is built from the command itself, so there is no copy to compare; 1445896 proves the same thing by result (66 commands, same exit old and new)
- design-advisor rec 9 — obeyed: 1d43183 (EXTRA unchanged, from the raw command; the KNOWLEDGE line names the kept false block: a backticked or `$( )` checkout inside even the quoted shape)
- design-advisor rec 10 — obeyed: 1445896 ((a)–(d), (f) and (g) as named cases and S173's list × both triggers; (e) the pass-6 decoy forms are in S173's list, and the pass-7 L1 case is two rows: a `$( )` checkout and the declared shape, from another chat at L1, record no owner)
- design-advisor rec 11 — obeyed: 1d43183 (DECISION-011 S191 addendum §2) and this commit (`## Design` and `## Guardrails` corrected above)
- design-advisor rec 12 — obeyed: 1d43183 (checked src/cli/init.rs (`SYNC_HOOKS` + `StaleRender`); hook-pre-write.sh is not shipped to projects (§1 says so), hook-session-guard.sh is, on the next `--sync-fleet` (§2 says so))

**fidelity-reviewer** (`.ai/handoffs/session-191-fidelity-reviewer.md`):
- fidelity-reviewer rec 1 — obeyed: 23971d5 (confirmed live first: an inside file spelled `/System/Volumes/Data/…` exited 0 at 64248b9; `gt_outside` now also walks the target's folder up to `/` and refuses any step that `-ef` the root; the string compare stays as a first check; the firmlink verify row that shows the hole, on a /private/tmp project, landed in aecfd25; 3952a6d makes the walk compare against the as-resolved root, not the lower-cased copy)
- fidelity-reviewer rec 2 — obeyed: 23971d5 (DECISION-011 S191 addendum §1 says "every symlink", names the inode walk and the firmlink find, and says the non-ASCII refusal covers only the typed path) and the summary (corrected at closeout)
- fidelity-reviewer rec 3 — obeyed: aecfd25 (each verify-133 run builds into its OWN `target/s133-probes-<pid>`, seeded by a copy-on-write clone of `target/s133-probes` and removed by the EXIT trap; the sweep no longer touches the pre-S191 `target/s133-fixture-wt`). The first try, a lock round each build-and-run (b0ef01b), made BOTH concurrent runs red: the two checkouts share one cargo fingerprint and cargo judges "fresh" by the mtimes of the other checkout's files, so a run tested the other's binary. The rec's own first option was the right one; the lock is gone
- fidelity-reviewer rec 4 — refused: the rec asked for AC1 rows with `CLAUDE_PROJECT_DIR=/` and an unresolvable root, wanting exit 2. Through the real hook neither can reach the ground-truth branch: ground truth is decided from `$ROOT/.ai/CONSTRAINTS.yaml` and the git branch at `$ROOT`, and `/` (or a root `cd -P` cannot enter) has neither, so the hook exits 0 before `gt_outside` runs (tried live: both exit 0 as "not a ground truth"). A row would test a path the hook never takes; the `[ "$r" != "/" ]` line stays as defence in depth
- fidelity-reviewer rec 5 — obeyed: b0ef01b (`update_session_boot` returns whether a line moved; `--advance` prints a warning naming the missing `**Number:** NN` line instead of "updated"; the unit test asserts a second call moves nothing)

**release-coordinator** (`.ai/handoffs/session-191-release-coordinator.md` — the one judge; it cannot judge its own recs, so each is answered here and left unjudged):
- release-coordinator rec 1 — deferred: prompts/191-task-small-fixes.md
  why: done — tech-lead rec 7 now leads with 8effeb1 and design-advisor rec 12 with 1d43183, the exact shas its judgment lines name.
- release-coordinator rec 2 — deferred: prompts/191-task-small-fixes.md
  why: done at closeout — `## Execution` step 6 names the closeout-sync commit.
- release-coordinator rec 3 — deferred: sessions/session-191-summary.md
  why: done in 3952a6d (DECISION-011's Rejected bullet, the hook comment, verify-191's timing note) and the review header (aecfd25 named for rec 3). The same commit fixed a bug found while doing it: the inode walk compared against the lower-cased root (would fail open on a case-sensitive disk).
- release-coordinator rec 4 — deferred: sessions/session-191-summary.md
  why: done — the summary and tech-lead rec 5's answer say the three hand rounds were on 96d4b86, and two rounds (one by hand, one in verify-191) ran on aecfd25.
- release-coordinator rec 5 — deferred: .ai/SESSION-BOOT.md
  why: done — the founder pruned `session-190-closeout` with `-d`; `--advance` ran with this branch's binary; the SESSION-BOOT diff moved only `**Number:** 190 → 191`; committed with `.ai/approvals/session-191.json`.
- release-coordinator rec 6 — deferred: sessions/session-191-review.md
  why: the order followed: this handoff recorded, closeout sync, S192 prompt, these answers, then `verify-closeout.sh --inputs-sha 191` last.
- release-coordinator rec 7 — deferred: sessions/session-191-summary.md
  why: the full `verify-closeout.sh 191` runs on this branch before the PR is merged (verify-191 ~5 min of the 600 s bound).
- release-coordinator rec 8 — deferred: .ai/SESSION-BOOT.md
  why: the founder's steps — push, PR, merge with a merge commit; written in SESSION-BOOT's Next Session.
- release-coordinator rec 9 — deferred: .ai/SESSION-BOOT.md
  why: the founder's steps after the merge — fetch, `git checkout main && git pull --ff-only`, `git branch -d session-191-small-fixes`; the four local files stay out of git.

## Delta
- `+` the ground-truth write guard's physical-resolution outside-pass (N2) + DECISION-011 S191 addendum
- `~` `update_session_boot` (anchors the number replace on the field, not the line)
- `~` `scripts/verify-session-133.sh`'s fixture (per-invocation worktree path)
- `~` `hook-session-guard.sh` (strips heredoc bodies from `$SCAN`, unless piped into a shell)
