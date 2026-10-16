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
<the S199 agent writes this after the tech-lead>

## Delta
- `~` F126: a late founder change has a stated place
- `+` the review-only sign-off line in the step list
- `~` N19/N20: the advance keeps CRLF and leaves Prior entries alone
- `~` N21: two prompts for one session are named, not coin-tossed
- `+` N14: a ground-truth question on whether the close was reported truthfully
- `~` `latest` link, `gt_cadence_shared`, the rest of N7

## Advice
