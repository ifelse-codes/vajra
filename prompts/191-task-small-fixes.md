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
- The heredoc fix (AC4) is a bug fix against the EXISTING S173 quote-stripping design, not a new guard class —
  no new ADR needed, just the fix plus a `.ai/KNOWLEDGE.md` permanent-fact line.
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
- AC4's guard change is ADD-only in effect (ADD a strip step) but must not REMOVE any existing block — the old-
  vs-new corpus test is mandatory before it ships (S173/S186 precedent: guard-parsing changes get it wrong on
  the first pass more often than not).
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
5. `scripts/verify-session-191.sh` (each fix red at the start commit for its named reason) and the demo script.
   — covers: 1, 2, 3, 4
6. Summary with 3 next options; closeout sync; next prompt; one cold review; the `--inputs-sha 191` stamp last.
   — covers: 1, 2, 3, 4

Cut line (prompt guardrail, repeated from above): if step 4 is not green with its corpus by ~1h30, ship steps
1–2 and whatever of step 3 is done, skip step 4's build, and split it into its own session.

## Delta
- `+` the ground-truth write guard's physical-resolution outside-pass (N2) + DECISION-011 S191 addendum
- `~` `update_session_boot` (anchors the number replace on the field, not the line)
- `~` `scripts/verify-session-133.sh`'s fixture (per-invocation worktree path)
- `~` `hook-session-guard.sh` (strips heredoc bodies from `$SCAN`, unless piped into a shell)
