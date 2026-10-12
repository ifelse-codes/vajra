# Session 194 — INTERACTIVE: rudra session 20 (its ground truth) under Vajra

> **Status:** DRAFT — written by the S194 agent from the founder's pick (chat 2026-10-12: option 1 of
> `sessions/session-193-summary.md`, "rudra S20"). The approval record `.ai/approvals/session-194.json` was written
> by his `vajra approve 194` at 08:39 the same day, BEFORE this file existed; he reads this prompt and re-runs
> `vajra approve 194` if he wants the record to follow it. The gate reads the record, not this line.

## Type
session_type: INTERACTIVE
- **INTERACTIVE** (gets the CODE checks). Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The founder runs rudra S20 himself under `vajra claude` and brings what happened; this session lists the findings
  with him and fixes what he says yes to.

## Goal
rudra S20 is a ground-truth (review-only, NO-CODE) session — a path a real project has walked under Vajra only once
(rudra S15). It is also the first real run since S193's F117 fix, so it is the live proof S193's review asked for
(rec 4): with Claude Code's own figure, the receipt shows only that figure. Find what real work shows that fixtures
cannot; fix what the founder says yes to, each with a check that fails without it.

## Before rudra S20 starts (founder, in order)
1. Already done: S193 merged (#231), main synced, `vajra` installed from it (binary 2026-10-10 00:20, after the
   00:10 merge).
2. In rudra: `vajra init --sync-fleet`; commit what it writes as S20's first commit, on S20's branch.
3. `vajra approve 20` in rudra, from his own terminal. rudra's prompt: `prompts/20-task-ground-truth.md`
   (`session_type: GROUND_TRUTH`).

## What to watch in rudra S20
Read every close log for `WAIVED`, `N/A` and `WARN` FIRST, never just PASS (S178).
- **The receipt (S193 rec 4, the live proof):** the top line equals Claude Code's own `cost-state` total; NO
  `[estimate` line, NO split line, NO "not in pricing table" warning beside it. A resume shows only its own share; a
  `/clear` skips (named, founder 2026-10-09).
- **The ground-truth path:** does Vajra treat S20 as NO-CODE (the guard, the close checks a GT session gets), and does
  the derived cadence (`ground_truth_every_n_sessions: 5`) agree that S20 is a GT session?
- **The three parked bugs (F116, F118, F119):** if seen again, record it on the existing entry — do not fix unless
  the founder says so.
- **Approvals, the session guard, waivers, stamps:** as in S184's list.
- **Time + cost** for the session, from the trusted figure.

## Deliverables
1. A findings list from rudra S20 (`F120…`), each with evidence (log line, file, commit) and the founder's call
   (fix / park / not a problem).
2. Fixes for every finding the founder says yes to, each with a test that fails without it.

## Acceptance
| AC | Check |
|---|---|
| AC1 | Every finding has evidence and a founder call recorded in the summary. |
| AC2 | Every fix has a real-run check in `scripts/verify-session-194.sh` (no source greps), red at the start commit. |
| AC3 | The rudra S20 receipt is recorded against Claude Code's own total, and whether it shows the estimate lines. |
| AC4 | No Vajra commit touches rudra; rudra's own commits are the founder's. `cargo test` passes in full. |

## Design
design-significant: yes

Cites docs/adr/0004-meter-receipt-design.md (§2.8 receipt format; S193 addendum) for F121, and
docs/decisions/DECISION-007-agent-fleet.md (§2 the handoff contract; the S172 addendum and the
2026-09-21 founder decision on the git belt) for F120 and F123. Recorded as an S194 addendum in each.

F121 — the exit box shows the latest close check. verify-closeout.sh (Vajra's own and the scaffold copy)
also writes one fixed-format file, `.ai/verify/closeout/<stamp>/result` (a version line, `verdict:
GREEN|RED`, `pass:`, `fail:`, `warn:`, `failed:`), as its last step. On exit `vajra claude` reads only that
file — never screen text, logs or the transcript. "This run" = the newest run folder stamped at or after
the launch second. The line prints below the receipt box (§2.8), from src/cli/launch.rs, even when the cost
cannot be read: RED with the failed names / GREEN / started but wrote no result / not run during this run.
A file that does not parse exactly is unreadable, never GREEN. VAJRA_QUIET=1 hides it with the receipt.

F123 — a merge commit on main is stopped. New standalone `.githooks/pre-merge-commit` that checks only
main|master and blocks everyone (the 2026-09-21 rule); it does not call pre-commit. Ships like pre-commit
and pre-push (include_str!, `fxs`, SYNC_HOOKS, executable, Cargo.toml `!` line). Closes the S172 addendum's
"Vajra does not ship pre-merge-commit".

F120 — `--role --from` refuses a transcript: if the first non-blank line parses as a JSON object
(serde_json), nothing is written, it exits non-zero, and says to pass the helper's handback text. A fourth
fail-closed case on DECISION-007 §2's list.

Deviation: the receipt box (ADR-0004) was cost-only; it now carries one line that is not about cost. The
meter API and format_receipt do not change.

Rejected: reading stdout/logs/transcript for "RED (" (text guessing); trusting the `latest` link; re-running
the close at exit; a Stop hook judging the agent's words; calling pre-commit from the merge hook (its cap and
approval check would police merging main into a session branch); `git merge` in the L3 text match;
reference-transaction (fires on the human's ff pull); extracting the handback from the transcript (a guess
tied to Claude Code's format); key-name detection; a size cap; warn-and-write.

Named, not closed: F121 shows the truth, it does not stop an agent saying "fully closed"; the box appears
only at exit (a GitHub merge before exit misses it); the agent can write a fake result file; WAIVED counts as
a pass in the totals; after a resume only runs since this launch count. F123: fast-forward, `reset --hard`,
`branch -f`, `update-ref`, `git merge --no-verify`, and a repo without `core.hooksPath` fire no hook; pre-push
still stops the push to main. F120: a brief that starts with prose and has a transcript pasted lower down
is not caught.
(From the design-advisor, `.ai/handoffs/session-194-design-advisor.md`.)

## Carried in
- **From S193:** fidelity-reviewer rec 4 (live proof of F117 on the next real run) — this session. F116, F118, F119
  parked as known bugs (ROADMAP backlog, S195 checklist).
- **Founder calls (2026-10-09):** `/clear` gets no receipt and a fork's own share is not shown — named, not closed
  (ADR-0004 S192 addendum).
- **Founder rulings:** read the tool's own cost, never grow the price list; one release-coordinator judges all
  `obeyed:` answers; the close does not run `cargo test` separately (run it in full before pushing); no new policing
  of Vajra's own paperwork.
- **Kept in backlog:** the rest of N7; F97's opt-out key; `tests/gt_cadence_shared.rs`'s loose assertion; S188's
  named gaps; N10; N11; S192 review rec 6. **Parked:** non-Claude tools (F91/F94/F95); release.
- **Next ground truth: S195** (derived, `scripts/lib-ground-truth.sh`).

## Guardrails
- No paid run by the agent without the founder's yes. No transcript or run capture committed (S126).

## Plan
1. The founder syncs and runs rudra S20; read its close logs and receipt with him. — covers: 1, 3
2. Fix each finding he says yes to, with a check red at the start commit. — covers: 2
3. `scripts/verify-session-194.sh`, the demo, the full `cargo test`. — covers: 2, 4
4. Summary with 3 next options; closeout sync; next prompt; one cold review; the `--inputs-sha 194` stamp last.
   — covers: 1, 2, 3, 4

## Delta
- `+` rudra S20 findings (F120…) with the founder's calls
- `+` the live receipt check for F117
- `~` whatever they show is wrong

## Execution
- step 1 — done: ca6eedc
- step 2 — done: 9d6892e
- step 3 — done: cb39ba7
- step 4 — done: f0279e0

## Advice
Roles dispatched: `tech-lead` (mandatory, first). Required at close: `fidelity-reviewer` (the one cold review),
`release-coordinator` (the one judge of every `obeyed:` answer). `design-advisor` only if an approved finding changes
a shared rule (tech-lead rec 5).

researcher: skipped — the tech-lead deferred it on budget: the evidence is rudra S20's own close logs, receipt and transcript on this machine, read with the founder, and S192/S193 already proved the receipt live (~0.4M saved, crew ~1.6M → ~2.0M otherwise).
requirements-analyst: skipped — the tech-lead deferred it on budget: the founder picked this session and AC1–AC4 copy S193's accepted shape (~0.3M would restate a prompt he chose).
plan-advisor: skipped — the tech-lead deferred it on budget: the Plan covers AC1–AC4 with `covers: N`; the real order depends on findings that do not exist yet (~0.3M).
implementation-advisor: skipped — the tech-lead deferred it on budget: no code is approved yet; its recs 4 and 6 name the traps (red for the right reason, the full cargo test before push) (~0.6M).
qa-specialist: skipped — the tech-lead deferred it on budget: AC2 makes every fix's check real-run and red at the start commit, and the fidelity-reviewer re-runs verify-194 at both ends (~0.6M).
demo-producer: skipped — the tech-lead deferred it on budget: the founder watches his own rudra run and its receipt; the summary records both (~0.3M).

**tech-lead** (`.ai/handoffs/session-194-tech-lead.md`):
- tech-lead rec 1 — obeyed: ca6eedc (F120–F124 filed with evidence and the founder's calls before any code; rudra S20's close log read for WAIVED / N/A / WARN first: 0 waived, 1 N/A, RED 17/5; F118 and F119 sightings added to their existing entries, no new numbers)
- tech-lead rec 2 — obeyed: ca6eedc (the AC3 table: receipt $1.49 · cost-state 1.4903203999999999 · `~/.claude.json` lastCost 1.4903203999999999; a fresh run; no `[estimate` line, no split, no pricing warning) and 2cb027d (printed as a `RECORD:` line, not counted)
- tech-lead rec 3 — obeyed: f5801dd (the ground-truth path checked from the transcript: the cadence agreed S20 is review-only, but the guard was off all session on a `-closeout` branch — F125, reported and parked on the founder's call, not fixed)
- tech-lead rec 4 — obeyed: 2cb027d (every fix's check runs the real binary in a temp project — `vajra init`, `vajra claude` with a stand-in `claude`, `git merge`, `vajra next` — red at 7e8210e with that finding's own result; rudra is never the fixture)
- tech-lead rec 5 — obeyed: 08fedd8 (F121/F123/F120 change the receipt box, the git belt and the handoff contract for every project → design-significant: yes, the design-advisor dispatched narrowly, ADR-0004 and DECISION-007 cited) and b014bf5 (the S194 addenda)
- tech-lead rec 6 — obeyed: 9d6892e (the full `cargo test --release` ran before any push: 719 passed / 0 failed; run again after review rec 1's code change 56b4693: 720 passed / 0 failed, d6e73f5; not added to the close; CI on the PR is the evidence the founder waits for)
- tech-lead rec 7 — obeyed: f0279e0 (not triggered — the founder approved three fixes; the summary still says what F121 cannot do, and verify-194 keeps AC3 as a RECORD line)
- tech-lead rec 8 — obeyed: 168564f (the six skip lines carry the money reasons) and 08fedd8 (the design-advisor only after rec 5 triggered); then the build, one fidelity-reviewer, one release-coordinator after this section

**design-advisor** (`.ai/handoffs/session-194-design-advisor.md`):
- design-advisor rec 1 — obeyed: 08fedd8 (design-significant: yes; ADR-0004 for F121, DECISION-007 for F120/F123) and b014bf5 (an S194 addendum in each; the ADR one says the box now carries a line that is not about cost)
- design-advisor rec 2 — obeyed: 9d6892e (both `verify-closeout.sh` and `verify-closeout-scaffold.sh` write `<stamp>/result` last, via a temp file, beside the `latest` line; the binary reads only that file) and 2cb027d (verify-194 row 2: the scaffolded script in a temp project writes `verdict: RED` and a `failed:` line whose count equals `fail:`; at 7e8210e no file)
- design-advisor rec 3 — obeyed: 9d6892e (newest folder whose fixed-width stamp is at or after the launch second; RED / GREEN / GREEN with WARN / no result / not run / unreadable; unit tests `s194_*` cover cases a–e, plus the stamp format)
- design-advisor rec 4 — obeyed: 9d6892e (reader and printing in `src/cli/launch.rs` after `print_receipt`, printed even with no transcript; `meter::format_receipt` unchanged) and 2cb027d (verify-194 row 1 has no cost log at all and still shows `close check: RED`)
- design-advisor rec 5 — obeyed: b014bf5 (the ADR-0004 addendum's "Named, not closed" list: shows not stops, only at exit, the agent can write the file, WAIVED counts as a pass, a resume counts only since its launch, a project needs `--sync-fleet`)
- design-advisor rec 6 — obeyed: 301f875 (standalone `.githooks/pre-merge-commit`, branch check only, blocks everyone, no `--no-verify` in its message) and a1115e9 (`tests/commit_belt.rs`: on main, agent and human, main unchanged; a 5-file branch merged into a session branch with `CLAUDECODE=1` passes)
- design-advisor rec 7 — obeyed: 301f875 (`TPL_GITHOOK_PRE_MERGE_COMMIT` include_str!, `fxs` in `files()`, `SYNC_HOOKS`, executable via `fxs`, `!.githooks/pre-merge-commit` in Cargo.toml; the init tests list it — the 0o755 mode is checked by verify-194 row 3's `-x`) and 2cb027d (verify-194 row 4: `--sync-fleet` on a 7e8210e project writes it executable and it stops the merge; row 5: `cargo package --list`)
- design-advisor rec 8 — obeyed: b014bf5 (the S172 sentence struck through, pointing at the S194 addendum, which names fast-forward, `reset --hard`, `branch -f`, `update-ref`, `--no-verify`, no `core.hooksPath`; the L3 guard not touched) and 2cb027d (verify-194 prints the KNOWN GAP line)
- design-advisor rec 9 — obeyed: 052d338 (`starts_with_json_object` runs before `repo_root()` and any write; `tests/role_refuses_transcript.rs`: file and stdin refused, an existing handoff byte-for-byte, a brief with a fenced json block still records — 3 of 4 red at the start)

**fidelity-reviewer** (`.ai/handoffs/session-194-fidelity-reviewer.md`) — one cold pass, ACCEPT 4 SHIPPED / 2 PARTIAL:
- fidelity-reviewer rec 1 — obeyed: 56b4693 (the reader takes the newest run since launch that WROTE a result and names a later result-less run after it; verify-194 row 1b — a full RED close, then `--fidelity-only` a second later — red before this commit with "started … but wrote no result", passes after; unit test `s194_a_later_partial_run_does_not_hide_the_red`)
- fidelity-reviewer rec 2 — obeyed: 97fac97 (ADR-0004 S194 addendum: "this run" = newest run with a result, the focused modes named as a cause, the early-stop limit named) and 6aea9bf (the summary's state list and limits say the same)
- fidelity-reviewer rec 3 — obeyed: 6aea9bf (F122's call in the asked form, the founder's words: "Park for S195", 2026-10-12)
- fidelity-reviewer rec 4 — obeyed: 6aea9bf (`.ai/approvals/session-194.json` committed unchanged; the F116 sighting added to the summary's findings)
- fidelity-reviewer rec 5 — deferred: .ai/SESSION-BOOT.md
- fidelity-reviewer rec 6 — obeyed: 6aea9bf (the demo's next slide lists the summary's three ranked options, in order) and 8c48fac (its rule slide names the partial-run case)
- fidelity-reviewer rec 7 — obeyed: 97fac97 (DECISION-007: "every route that makes a merge commit"; a human's non-fast-forward `git pull` on local main is named as refused too)

**release-coordinator** (`.ai/handoffs/session-194-release-coordinator.md`) — the one judge: 23 implemented, 0 mismatch:
- release-coordinator rec 1 — deferred: sessions/session-194-review.md
- release-coordinator rec 2 — deferred: sessions/session-194-review.md
- release-coordinator rec 3 — deferred: .ai/SESSION-BOOT.md
- release-coordinator rec 4 — deferred: .ai/SESSION-BOOT.md
- release-coordinator rec 5 — deferred: .ai/SESSION-BOOT.md
