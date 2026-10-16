# Session 199 — CODE: fix every pending known bug

> **Status:** DRAFT — written in the S198 chat after the merge, from the founder's pick (2026-10-16: option 3, "fix all
> pending bugs if any"). It replaces the reviewer-design prompt, which the founder dropped (2026-10-15: "if the model
> cuts short and writes the review, it is ok — at least it is reviewing"; today's close check stays as is). The
> founder reads it and runs `vajra approve 199` in his own terminal; the gate reads the record, not this line.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story (the known-bug list) · new chat.
- **Split rule:** do the items in the order below. If the session nears ~2h, stop after the item in progress; what is
  left goes to S201 (S200 is review-only) with the founder's yes, written in the summary.

## Goal
Empty ROADMAP's "🐞 KNOWN BUGS — TO FIX" list of real bugs a user can meet, so S200 (the next review-only session)
judges a clean slate. Each fix gets a real-run check that fails without it. Named limits of the guards (F123/F127
routes) are not bugs and stay named (founder, 2026-09-15: no more policing); F97's opt-out key waits for a real
request (S195).

## Deliverables
1. **F126 — a founder change after the review has a place.** In rudra S21 the founder re-scoped the next session after
   the close + stamp; the agent kept the old next prompt in git ("changing it now would undo today's sign-off") and
   saved the new plan only in Claude Code's private memory. First find out, by a real run, which edits after the
   stamp really break it (the next session's prompt? the summary? `.ai/` notes?). Then make the step list / boot say
   plainly where a late founder change goes and whether a re-stamp is needed. **Ask the founder before building if the
   answer needs a new rule.**
2. **The review-only sign-off line (S197 design-advisor rec 10).** On a review-only session `vajra next --steps` has a
   line for the founder's `vajra approve NN --close`, and F116's "not in git yet" note also names
   `.ai/approvals/session-NN-close.json`.
3. **N19 — `vajra next --advance` keeps a CRLF SESSION-BOOT's line endings** (or refuses to move on `\r` and says
   why — fail closed). Today `str::lines()` + `join("\n")` rewrites every line.
4. **N20 — the advance's prompt-pointer rewrite stays out of `## Prior Session`.** `update_prompt_pointer` today
   rewrites any SESSION-BOOT line containing "read prompt", including one inside the entry F118 just moved down.
5. **N21 — two prompt files for one session are refused, not coin-tossed.** `find_next_prompt` (`src/cli/next.rs`)
   returns the first `NN-task-*.md` in `read_dir` order; with two (as happened here: the dropped
   `199-task-design-vajra-runs-the-reviewer.md` and this file) the pick is arbitrary. Name both and refuse, or pick by
   a stated rule. (Found 2026-10-16 writing this prompt.)
6. **N14 — the review-only session reads whether the agent told the founder the truth at close.** One question in an
   existing ground-truth audit (S195 pick): read `.ai/verify/closeout/<stamp>/result` for the last sessions and
   compare with what the summary claimed. A question, not a new gate. Ships to projects via `--sync-fleet` like F97.
7. **Vajra's own `.ai/verify/closeout/latest` is a real folder** (since 2026-08-03; `ln -sfn` cannot repoint it). The
   one-time hand fix the founder approved at S195 — show him the folder first, then replace it with the link.
8. **`tests/gt_cadence_shared.rs`'s loose assertion** — `announces_gt()` matches any substring of the whole hook
   output, so the `[REMINDER] … GROUND TRUTH` line can make a false alarm (S190). Tighten to the exact announcement.
9. **The rest of N7** — `scripts/verify-session-176/178/179.sh` and `scripts/demo-session-176/178/179/184/186.sh` still
   make their own old-version checkouts; move them to `scripts/lib-old-checkout.sh`. Last, and the first to move out
   under the split rule.

## Acceptance
| AC | Check |
|---|---|
| AC1 | F126: a real run shows which post-stamp edits break the stamp; the step list (or boot) tells the agent where a late founder change goes; the founder's call quoted if a rule changed. |
| AC2 | Sign-off: `vajra next --steps NN` on a review-only session shows the `vajra approve NN --close` line (✗ before the record, ✓ after); the not-in-git note names the close record. |
| AC3 | N19: an advance on a CRLF Vajra-shaped SESSION-BOOT keeps CRLF on every line (or refuses with the reason) — real run. |
| AC4 | N20: an old entry containing "Read prompt `prompts/NN-…`" is byte-for-byte unchanged after the advance; the Current/Next pointer still moves. |
| AC5 | N21: with two `NN-task-*.md` files, `--advance` / `--steps` / boot name both and do not pick one silently. |
| AC6 | N14: the question is in `.ai/CONSTRAINTS.yaml`'s ground-truth questions and reaches a fresh `vajra init` project; `scaffold-drift.sh` stays green. |
| AC7 | `latest` is a symlink to the newest closeout run after the founder's yes; the close check still writes and F121 still reads. |
| AC8 | `tests/gt_cadence_shared.rs` passes and fails only on the exact announcement (a test that would fail on the old loose match). |
| AC9 | The N7 scripts use `lib-old-checkout.sh`; each still runs (or the split rule moved it out, in writing). |
| AC10 | `scripts/verify-session-199.sh`: every row a real run, red at the start commit for its own reason. Full `cargo test` before the push; the push goes through the S196 belt. |

## Design
design-significant: no
- Fixes inside existing records: DECISION-011 (S191 advance, S197 close record), DECISION-007 (step list, S196 push
  belt), ADR-0004 (closeout result). If F126 needs a new rule, flip this to `yes` and run the design-advisor first.
- design-advisor: skipped — every item follows an existing record (DECISION-011 S191/S197, DECISION-007's step list,
  ADR-0004's close result) and changes no shared rule; the tech-lead (`.ai/handoffs/session-199-tech-lead.md`) defers
  it until F126's run shows a new rule is needed, which then goes to the founder first.

## Carried in
- **From S198 (merged #236, 2026-10-15):** F118 + N18 fixed; N19, N20 filed from its review. **Its tech-lead rec 5:**
  record in `sessions/session-198-summary.md` that S198's push went through the S196 belt — PR #236 head `a3068d2`
  = `.ai/verify/closeout/20261015T100751Z/result` (`verdict: GREEN`, 25/0, `clean: yes`); do it at this session's
  start.
- **Founder calls after S198 (2026-10-15/16):** the reviewer design (Haiku answer d) is dropped; the README "tested
  with" line (answer c) stays open — offer it at the end if time allows, in his own words. S199 = this bug list
  (option 3 of the sprint review; rudra S22 and the boot diet were the other two).
- **This file replaces** `prompts/199-task-design-vajra-runs-the-reviewer.md`, deleted in the same follow-up PR that
  added this file (after S198's merge). It was N21's live example; S198's merged `## Advice` names it, which a merged
  session only reports.
- **rudra:** S197's sync files are uncommitted there (5 modified) — the founder commits them; never revert.
- **Founder rulings:** no new policing of Vajra's own paperwork; guard changes only add; read the tool's own cost;
  one release-coordinator judges all `obeyed:` answers (its own recs by a narrow fidelity-reviewer); the close does
  not run `cargo test` (run it in full before pushing); release not yet.
- **Next ground truth: S200** — the review-only guard blocks its commits until the founder's `vajra approve 200 --close`.

## Guardrails
- No paid run by the agent without the founder's yes. No transcript or run capture committed (S126).
- Only the items listed; a new bug found on the way is filed, not fixed.
- Item 7 touches only Vajra's own `.ai/verify/closeout/latest`, after the founder sees it.

## Plan
1. F126: on a scratch copy, stamp + close, then make four edits (a new next-session prompt, a summary edit, a `.ai/`
   note, this session's own prompt) and close again, recording which break the stamp (tech-lead rec 1). Then the
   step list's stamp / close lines say where a late founder change goes and what it costs. Ask the founder first if
   the answer needs a new rule.
   covers: 1
2. Sign-off line: on a review-only session `vajra next --steps` shows a `vajra approve NN --close` step (✗/✓ from
   `approval::close_record`); the F116 not-in-git note also names `session-NN-close.json`.
   covers: 2
3. N19: the three SESSION-BOOT/TASK rewriters in `src/cli/next.rs` keep each line's own ending (tech-lead rec 2).
   covers: 3
4. N20: `update_prompt_pointer` rewrites only lines above the first `## Prior Session` heading; no such heading →
   today's behaviour (tech-lead rec 3).
   covers: 4
5. N21: one sorted lookup returns every `NN-task-*.md`; with more than one, `--advance` refuses naming all, the
   `--steps` prompt line is ✗ naming all, boot says so (tech-lead rec 4).
   covers: 5
6. N14: one question in `.ai/CONSTRAINTS.yaml`'s ground-truth questions; reaches a fresh `vajra init`;
   `scaffold-drift.sh` green (tech-lead rec 5).
   covers: 6
7. `latest`: show the founder the folder (732 broken self-links + 12 logs from 2026-08-03, 52K), and on his yes
   replace it with a link to the newest run; one close proves it writes and F121 reads (tech-lead rec 6).
   covers: 7
8. `tests/gt_cadence_shared.rs`: `announces_gt()` matches only the exact announcement line.
   covers: 8
9. N7 rest: verify-176/178/179 and demo-176/178/179/184/186 use `scripts/lib-old-checkout.sh` (first out under the
   split rule).
   covers: 9
10. `scripts/verify-session-199.sh` — every row a real run, red at `027e70f`; the demo; full `cargo test` before the
    push; the push through the S196 belt.
    covers: 10

## Execution
- step 1 — done: b63e349
- step 2 — done: b63e349
- step 3 — done: df7bc11
- step 4 — done: df7bc11
- step 5 — done: e572057
- step 6 — done: c2a11bd
- step 7 — done: c3cad24
- step 8 — done: c19800d
- step 9 — done: 93b706b, c38ea5b, 8216bf5
- step 10 — done: c3cad24

## Delta
- `~` F126: a late founder change has a stated place
- `+` the review-only sign-off line in the step list
- `~` N19/N20: the advance keeps CRLF and leaves Prior entries alone
- `~` N21: two prompts for one session are named, not coin-tossed
- `+` N14: a ground-truth question on whether the close was reported truthfully
- `~` `latest` link, `gt_cadence_shared`, the rest of N7

## Advice
Roles dispatched: `tech-lead` (mandatory, first). Required at close: `fidelity-reviewer` (the one cold review),
`release-coordinator` (the one judge of every `obeyed:` answer). `design-advisor`: the recorded skip in `## Design`.

researcher: skipped — the tech-lead deferred it on budget: each item's evidence and code site was already in the prompt and ROADMAP's known-bug list (~0.15M; crew ~1.9M → ~2.05M).
requirements-analyst: skipped — the tech-lead deferred it on budget: the founder picked the list and AC1–AC10 give each item a real-run check (~0.1M would restate them).
plan-advisor: skipped — the tech-lead deferred it on budget: the prompt fixed the order and the split rule (~0.1M).
implementation-advisor: skipped — the tech-lead deferred it on budget: its recs 2–5 named the traps (three `lines()` rewriters, the section limit, many prompts) (~0.3M).
qa-specialist: skipped — the tech-lead deferred it on budget: AC10 makes every verify row a real run, red at 027e70f, and the fidelity-reviewer reads them (~0.3M).
demo-producer: skipped — the tech-lead deferred it on budget: bug fixes shown in verify output and the summary; the demo is the template's seven sections with live runs (~0.15M).

**tech-lead** (`.ai/handoffs/session-199-tech-lead.md`):
- tech-lead rec 1 — obeyed: b63e349 (a real stamp run first — a throwaway checkout, stamp, edit, commit, stamp again: next prompt, summary, TASK/STATE/ROADMAP leave it, own prompt / a handoff / code move it; then the step list's stamp and push lines say where a late founder change goes; no rule changed, so no founder question and no design-advisor) and c3cad24 (verify row 1 repeats the run)
- tech-lead rec 2 — obeyed: df7bc11 (`lines_with_endings` in `swap_boot_numbers`, `move_current_entry` and `update_prompt_pointer`; kept, not refused; unit test on both shapes) and c3cad24 (verify row 3: a CRLF Vajra-shaped and a CRLF init-shaped SESSION-BOOT, every line still CRLF after `--advance`)
- tech-lead rec 3 — obeyed: df7bc11 (`update_prompt_pointer` stops at the first `## Prior Session` heading; a file with none is read whole; no text guessing)
- tech-lead rec 4 — obeyed: e572057 (`analyst::prompts_for` returns every match, sorted; `--advance` refuses on more than one naming all; `--steps` — and so the boot, which prints it — leads with a ✗ naming all, live and at hand-over)
- tech-lead rec 5 — obeyed: c2a11bd (one question block for the existing `constraint_violation_review` audit, no check or gate) and c3cad24 (verify row 6: a fresh init has it, `--sync-fleet` adds it back, scaffold-drift exit 0)
- tech-lead rec 6 — obeyed: c3cad24 (the founder was shown the folder — 732 broken self-links + 12 logs — and said yes before it was replaced; verify row 7; no run capture committed; the close-writes proof is this session's own close run, graded PARTIAL until then in the summary, a85470d)
- tech-lead rec 7 — obeyed: 8216bf5 (every commit has ≤3 files — N7 split into 93b706b, c38ea5b, 8216bf5; built in the prompt's order; nothing moved out under the split rule)
- tech-lead rec 8 — obeyed: 6fc23c3 (S198's push recorded at the start) and ec2432d (full `cargo test` 743/0 in the summary; N22 filed, not fixed) and a85470d (N23 filed); the crew ran build → one fidelity-reviewer → one release-coordinator; handoffs recorded from handback text; `## Delta` above `## Advice`

**fidelity-reviewer** (`.ai/handoffs/session-199-fidelity-reviewer.md`, ACCEPT 9 SHIPPED / 2 PARTIAL):
- fidelity-reviewer rec 1 — obeyed: a85470d (the summary's AC7 line says PARTIAL until this session's close runs — "not yet shown"; `latest` is checked again after the close)
- fidelity-reviewer rec 2 — obeyed: a85470d (AC10 graded PARTIAL in the summary's fidelity map)
- fidelity-reviewer rec 3 — obeyed: a85470d (N23 filed in ROADMAP's known bugs next to N22, and on the next session's checklist)
- fidelity-reviewer rec 4 — obeyed: 5f6e232 (the next session's prompt committed with the summary's pick line, before the review's stamp)
- fidelity-reviewer rec 5 — deferred: prompts/200-task-ground-truth.md
  Why: it can only be checked on S200's own first `vajra next --steps`; that prompt's checklist now holds it (a85470d). S200 is review-only, so a bug it finds is filed for S201, not fixed there.
- fidelity-reviewer rec 6 — obeyed: 37ff65f (traced: verify row 2's PASS message had `vajra approve 10 --close` in backticks inside double quotes, so bash ran it — refused here by the agent mark, but from the founder's terminal it would have written a stray close record into Vajra's repo; none was written; the message now names no command)

**release-coordinator** (`.ai/handoffs/session-199-release-coordinator.md`, the one judge — 13 implemented, 0 mismatch; the deferral judged acceptable):
- release-coordinator rec 1 — deferred: prompts/200-task-ground-truth.md
  Why: the `latest` relink can only be seen after this session's close run, which is after its last commit; that prompt's checklist now holds the check and the record (with S199's push record), the same way S198's push was recorded at S199's start.
