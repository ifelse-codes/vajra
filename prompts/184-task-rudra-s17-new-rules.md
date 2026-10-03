# Session 184 — rudra session 17 under the new rules, plus F103 / F107 / F108

> **Status:** DRAFT — written by the S183 agent from the founder's pick (option A, 2026-10-03: "A . and yes F103 fix, F107 fix, F108 fix"). He approves it with `vajra approve 184` in his own terminal; the gate reads the approval record, not this line.

## Type
session_type: INTERACTIVE
- **INTERACTIVE** (gets the CODE checks). Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The founder runs rudra S17 himself under `vajra claude` and brings what happened; this session lists the findings with him and fixes what he says yes to. F103, F107 and F108 are already a yes.

## Goal
S183's changes (the WARN row for unchecked `obeyed:` claims, the session-type step at the start, a project's `lint_command:`) get their first real use in rudra S17, and three small known defects are fixed — each with a check that fails without it.

## Before rudra S17 starts (founder, in order)
1. Merge S183's PR (#220) — `main`'s CI goes green with it (F102). Then `cargo install --path .` in `~/playground/vajra` (the installed Vajra is pre-S183).
2. In rudra: `vajra init --sync-fleet` (brings the S183 close gate: the WARN row, the lint row). Commit what it writes as S17's first commit, on S17's branch.
3. Optional, rudra's call: add `lint_command: <the command rudra's checks use>` (or `lint_command: none`) to rudra's `.ai/CONSTRAINTS.yaml`; without it the close table shows a WARN row.
4. Approve rudra S17 from his own terminal: `vajra approve 17`. rudra's prompt: `prompts/17-task-tradeable-data.md` (already has `session_type: CODE`).

## What to watch in rudra S17
Read every close log for `WAIVED`, `N/A` and `WARN` FIRST, never just PASS (S178).
- **The step list:** did `vajra next --steps` name the session type at the start (F105)?
- **Obeyed claims:** does the `obeyed-judgments` row read WARN with a count, and did anyone act on it (F104)?
- **Lint:** the `project-lint-clean` row — WARN (no `lint_command:`), N/A, PASS or FAIL?
- **Approval, guard, waivers, stamps:** as in S183's list.
- **Time + cost** (the receipt is still F67-overstated ~5×; rudra S16 read ~$83.54 for ~55 minutes of work).

## Findings already recorded (founder yes, 2026-10-03)
- **F103 — `vajra init` waits forever on an open, silent, non-terminal stdin.** Found in S183: verify-183's first draft hung 600 s. Piping answers in is a supported use (`demo-session-08/09/143`, `verify-session-46/143`), so "not a terminal → use defaults" is NOT the fix. Candidate (plan-advisor S183 rec 4): when stdin is not a terminal, wait a short fixed time per answer (reader thread + `recv_timeout`); on timeout or end of input, use that default and every later one, and print the default used to stderr. Test: `sleep 60 | vajra init` finishes in ~10 s with `my-project`; piped answers still land (`acme-app`); verify-session-143 still green.
- **F107 — the obeyed WARN text quotes Vajra's own numbering to projects.** `src/obeyed/mod.rs` ~520: "session NN predates this gate (threshold: session 132)". In rudra that is meaningless. Fix: words a project understands; Vajra's own gate keeps its threshold. Test: the project close log for an unchecked claim does not say "132".
- **F108 — `--ledger` / `--ledger-verify` leave an empty dated close folder.** Same class as F106 (S183). Fix both close scripts the same way. Test: folder count unchanged after each mode.

## Question for the founder (S183 cold review rec 7)
- **Should Vajra's own close check also run `cargo test`?** S183 made it run CI's lint on CI's Rust version, but CI also runs `cargo test`, on Linux too — so a test that is green on a Mac and red on Linux (exactly F102) still closes green. Options: run `cargo test` in the close check (slower close), or have the close check say plainly that it does not. His call, given "no new ceremony".

## Carried in
1. **S182 pass-2 recs 1, 2, 5** — still parked for the S185 ground truth; fix only if rudra S17 hits one.
2. **Parked by the founder:** F67 (receipt ~5×), non-Claude tools (F91, F94, F95), release/publish.
3. **Next ground truth: S185** (derived, `scripts/lib-ground-truth.sh`).

## Deliverables
1. F103, F107, F108 fixed, and a findings list from rudra S17 (`F109…`), each with evidence (log line, file, commit) and the founder's call (fix / park / not a problem).
2. Fixes for every finding the founder says yes to, each with a test that fails without it.

## Acceptance
1. Every finding has evidence and a founder call recorded in the summary.
2. Every fix has a real-run check in `scripts/verify-session-184.sh` (no source greps) that fails without it.
3. No Vajra commit touches rudra; rudra's own commits are the founder's.
4. `verify-closeout.sh` exits 0 on the branch before merge (it now runs `scripts/ci-lint.sh`, so the branch's CI should match); one fresh cold review at close.

## Design
design-significant: _to be decided by the design-advisor once the findings are known (F103's wait time and default rule is a behaviour choice to record)_

## Plan
_(written with the plan-advisor after the findings are listed; every step cites `covers: N`.)_

## Execution
_(step N — done: <sha> as work lands.)_

## Guardrails
- No autonomous commits: the founder runs them, or launches with `VAJRA_ALLOW_COMMIT=184`.
- ≤3 files per commit; ≤2 assumptions; ≤2 retries. Guard changes only add (S173). No new ceremony; nothing that polices Vajra's own paperwork (2026-09-15).
- Answer a founder "why" with evidence; propose a fix only if he calls it a problem (S176).

## Delta
- `+` F103 (init waits a bounded time on silent piped input), F107 (project-facing obeyed WARN wording), F108 (no empty folder from `--ledger`/`--ledger-verify`); findings F109… from rudra S17 and the fixes the founder approves
- `~` whatever the findings touch
- `-` nothing planned
