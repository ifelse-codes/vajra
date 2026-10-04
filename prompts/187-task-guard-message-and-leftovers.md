# Session 187 — the guard says how to get past a harmless block, and the S190 leftovers

> **Status:** APPROVED — rewritten in-session with the founder (2026-10-04; "approved" in chat, record `vajra approve 187`). rudra S18 is paused until rudra's
> data API is ready (founder), so S187 is no longer the rudra run. Founder picks: guard fix **C** (a clearer
> message, no change to what blocks) + every leftover offered (N2, N4, verify-133, N6, F97, N5, N7).
> The approval record `.ai/approvals/session-187.json` was written before this rewrite; the founder confirms
> this text in chat.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The one story: **clear the small things that make Vajra annoying or wrong to use day to day** — one guard
  message and seven leftovers from the S185 ground truth. Ordered by who feels it: the users first (1–4),
  then us (5–7). What does not fit in the session is carried to S188 by name, never dropped.

## Goal
An agent blocked by the approvals guard for a harmless command is told exactly how to get past it; the step list says when the founder's approval is
missing; an existing project gets new review questions from `--sync-fleet`; and four leftovers that only
we feel (verify-133 red, a stale ROADMAP header, `--dogfood-age` blind to rudra, leftover test checkouts)
are fixed or honestly named.

## Deliverables
1. **Guard message (F110 class, fix C).** When the approvals guard blocks a command that names the folder
   AND runs a writer or a program elsewhere in it, the reason tells the agent: reading is fine on its own
   (`ls`/`cat`/`jq`), run the other part as a separate command; a commit message about the folder → `git
   commit -F <file>`. **What blocks does not change** (S173: guard changes only add; founder: C).
   Live case: `git checkout -b X main && cd ~/playground/rudra && ls .ai/approvals/` (blocked 2026-10-04).
2. **N2 — MOVED TO S188 (founder, 2026-10-05).** The design-advisor found it is Vajra's own guard only
   (no project has a ground-truth Write guard) and the one let-through needs ten holes closed (a symlinked
   root, a linked leaf, case, `/var` vs `/private/var`, relative paths, `..`, a crash exiting 1, …: its
   recs 12–20). This session keeps to changes that only add blocks; S188 builds it from those recs.
3. **N4 — `vajra next --steps` names a missing approval.** A line "the founder has approved this session"
   — ✓ when `.ai/approvals/session-NN.json` exists, ✗ with "how: `vajra approve NN` in the founder's own
   terminal" when it does not.
4. **F97 — `--sync-fleet` brings an existing project its missing review questions.** It adds the ground-
   truth audits and question blocks a project's `.ai/CONSTRAINTS.yaml` lacks: the one `required_audits:`
   line gains the missing names in their canonical place, missing question blocks are inserted whole
   inside `ground_truth:`, nothing else moves, and it prints what it added. Narrowly reverses
   DECISION-007's S142/S143 "Out permanently: CONSTRAINTS.yaml" (logged as F97 at S179) — a DECISION-007
   S187 addendum.
5. **verify-133 green at main.** Its 3 stale checks (`real-dispatch-passes`,
   `fixture-red-on-bypass-green-on-rename`, `k-of-8-unchanged-and-not-a-ninth-station`) read today's
   behaviour; no check is deleted to make it green — each is re-pointed, or kept and named if it found a
   real regression.
6. **N6 — the ROADMAP header is stale** (says "Session 166"). Replace the hand-kept "Updated:" paragraphs
   at the top with one line that points at where the live state is (`.ai/SESSION-BOOT.md`,
   `vajra next --steps`) — derive or delete, never re-type.
7. **N7 + N5 (us only).** N7: the old-version checkouts verify scripts make go under one known folder,
   and a run clears the stale ones it finds there. N5: `--dogfood-age` either reads the project runs it is
   blind to (if a rudra run leaves a record on disk) or its output says "this repo only" — and if it is
   only the label, the summary says **named, not closed**.

## Acceptance
| AC | Check |
|---|---|
| AC1 | The 2026-10-04 live command fed to the approvals guard still exits 2, and its stderr names the split-the-command way past. Every command that blocked before S187 still blocks (the S186 old-vs-new run over the guard corpus). |
| AC3 | `vajra next --steps` in a fixture with no approval record shows the ✗ approval line with `vajra approve NN`; with the record it shows ✓. |
| AC4 | `vajra init --sync-fleet` in a fixture project with an old `CONSTRAINTS.yaml` adds the missing ground-truth audits and question blocks and prints what it added; every original line is byte-identical except the one `required_audits:` line, which equals the original once the added names are removed (founder, 2026-10-05); `--dry-run` writes nothing; a second run adds nothing. |
| AC5 | `bash scripts/verify-session-133.sh` exits 0 at the S187 head, with the same number of checks it had at the start commit. |
| AC6 | `.ai/ROADMAP.md` has no hand-typed session number in its header. |
| AC7 | A verify run that is killed leaves its checkout in the one known folder, and the next run removes it. `--dogfood-age` output either counts a rudra run or says "this repo only". |
| AC8 | Every fix has a real-run check in `scripts/verify-session-187.sh` (no source greps) that is red at the commit S187 starts from (0071dca) for the named reason. |

## Design
design-significant: yes
- AC4 narrowly reverses DECISION-007's S142/S143 addenda ("Out permanently: CONSTRAINTS.yaml", logged as
  F97 at S179) — recorded as a DECISION-007 S187 addendum; DECISION-011's S182 §4 and S183 §3 sentences
  ("never written" / "never edits") are amended to match. `--sync-fleet` may do two things and nothing
  else: add missing audit names to the one `ground_truth.required_audits:` line (the project's entries
  keep their bytes and order; each missing name goes after its nearest canonical predecessor), and insert
  whole missing `<audit>_questions:` blocks inside `ground_truth:`. The canonical list is the build-derived
  scaffold one (OMIT_AUDITS excluded — one source, S129). Text edit, never a YAML round-trip; never
  creates the file; an unrecognised shape prints the line to add and writes nothing. Every key a gate
  reads (`session_rules_from`, `ground_truth_next_session`, `obeyed_blocks_from`, `maturity`,
  `lint_command`) stays report-only (S182). No gate in a project reads `required_audits` or
  `*_questions`, so adding them mid-session cannot flip a gate. Limit: an audit a project removed on
  purpose comes back, and the output says so.
- Rejected: appending names at the end of the line (undoes S179's project-first order); a second key or
  a second `required_audits:` line (two lists that drift / a duplicate key `grep -m1` hides); a YAML
  round-trip (drops comments, reorders keys).
- N2's let-through moved to S188 (founder), so this session only ever adds blocks.

## Carried in
- **rudra S18 → when rudra's data API is ready** (founder, 2026-10-04). Its watch-list (the guard's
  `.ai/approvals` blocks, obeyed WARNs, ground-truth reasons on stderr) moves with it.
- **F110 (b)** stays split out (backlog, S190 checklist). The founder chose C over A (Claude Code's own
  sandbox locks the folder — found this session, `sandbox.filesystem.denyWrite` + `allowUnsandboxedCommands:
  false`) and B (more word patterns). A is recorded for the S190 ground truth.
- **Parked by the founder:** F67, non-Claude tools (F91, F94, F95), release.

## Guardrails
- ≤3 files per commit; every fix has a check red at 0071dca for the named reason.
- Guard changes only add (S173); never hide text from a guard. Nothing in this session lets more through.
- Anything not finished in ~2h → S188 by name in the summary, never silently dropped.

## Plan
1. The approvals guard's writer / interpreter / program blocks name the split-the-command way past;
   tests: the live case + three joined reads block and say so, and every corpus command exits the same
   as at 0071dca (`scripts/hook-approvals-guard.sh`, `tests/approvals_guard.rs`). covers: 1
2. `vajra next --steps` gets "the founder has approved this session" from `session_rules_from` on, with
   a unit test (`src/nextstep/mod.rs`). covers: 3
3. `--sync-fleet` adds missing ground-truth audits + question blocks (the one-line rule), from the
   build-derived scaffold list; the S142 test renamed, not deleted; DECISION-007 S187 addendum;
   DECISION-011 S182 §4 / S183 §3 and the printed "never edits this file" corrected. covers: 4
4. verify-133's three stale checks re-pointed to today's behaviour, 15 checks before and after. covers: 5
5. ROADMAP's hand-kept header replaced by a pointer to the derived state. covers: 6
6. Old-version checkouts under one known folder, stale ones cleared; `--dogfood-age` reads a rudra run
   or says "this repo only". covers: 7
7. `scripts/verify-session-187.sh` (each check red at 0071dca for its reason) + `scripts/demo-session-187.sh`.
   covers: 1, 3, 4, 5, 6, 7, 8

## Execution

## Delta
- `~` approvals guard block reason (writer/program case) names the split-the-command way past
- `+` `vajra next --steps` approval line
- `+` `--sync-fleet` adds missing ground-truth audits/questions to a project's CONSTRAINTS.yaml (add-only)
- `~` verify-session-133.sh re-pointed to today's behaviour
- `-` ROADMAP's hand-kept "Updated:" header
- `~` verify scripts' old checkouts under one folder; `--dogfood-age` reads rudra or says "this repo only"
