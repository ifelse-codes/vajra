# Session 197 — the known-bug session: the review-only guard reaches every project, only the founder opens it

**Branch:** `session-197-known-bugs` · **Type:** CODE · **Start commit:** `eceb6d5` · **Prompt:** `prompts/197-task-known-bugs.md`

## Goal achieved?

Yes for F125 (+N17), F116, F119 and N10. F118 was moved out by the founder in-session (2026-10-14) and stays on
ROADMAP's known-bug list (next ground-truth checklist).

## The finding that changed F125 (founder call, 2026-10-14)

F125 was filed (S194) as "rudra S20's agent switched off its review-only guard by naming its branch `-closeout`".
Checked at the start of S197: **user projects never had the guard.** It lived only in Vajra's own
`scripts/hook-pre-bash.sh` / `hook-pre-write.sh`; `vajra init` / `--sync-fleet` shipped neither, and rudra's
`.claude/settings.json` + `.ai/hooks/` had no ground-truth block at all — while every scaffold's Hard Rules said
"No code in Ground Truth — Hook-enforced". Fixing only Vajra's copy would have been new policing of Vajra's own
paperwork. The founder chose: **ship the guard to every project**, with `vajra approve NN --close` as the only
opening, and **move F118 out**.

## What shipped

| Fix | What a user sees now | Commits |
|---|---|---|
| **F125** | Every project gets `.ai/hooks/hook-ground-truth-guard.sh` (init + `--sync-fleet`, wired in the PreToolUse `Bash\|Edit\|Write\|MultiEdit\|NotebookEdit` group). In a review-only session: code edits, commits, pushes, PRs are blocked; the report and `.ai/` notes are written. No branch name opens it (`-closeout` / `-enforcement` exemptions and `VAJRA_GT_WAIVER` retired). Only the founder's `vajra approve NN --close` opens it; a forged record is voided by the S188 check; an older `vajra` that ignores the flag stays closed. | `efd7ad2` (DECISION-011 S197 addendum) · `140542b` · `09b7c39` · `0c41f5f` · `8f32889` · `9c494c7` |
| **N17** | A branch with no `session-NN` uses HEAD's committed `.ai/SESSION` + 1 (the agent cannot move it while commits are blocked); unreadable → guard on. | `09b7c39` |
| **F116** | `vajra next --steps` says "approved — `.ai/approvals/session-NN.json` is not in git yet; commit it" until it is in the last commit (a reminder; the step stays ✓). Proven live on this branch (`3b50dc9`). | `946a967` |
| **F119** | `--steps` ticks design on `design-significant: no`, as `--check-design` says READY; an unrecorded marker still does not. | `336786d` |
| **N10** | `scaffold-drift.sh` check 6 skips a line carrying `# source-claim: <why>` (non-empty why); the three false alarms carry it; drift 20/0. | `34cebf4` · `cd13fc6` |

**Evidence:** `scripts/verify-session-197.sh` 11/11 — every row a real run (real `vajra init` projects, the
scaffolded hook fed Claude Code's JSON, `vajra approve` in a pseudo-terminal, real `vajra next`, the real drift
script), and each red at `eceb6d5` for its own reason. `scripts/demo-session-197.sh` 5/5 live checks. Full
`cargo test` 735 passed / 0 failed; `scripts/ci-lint.sh` clean.

## Fidelity map

| Prompt item | Grade | Evidence |
|---|---|---|
| D1 / AC1 F125 + N17 | SHIPPED | verify rows 1–7: blocked in a fresh project on `session-05-closeout` (commit/push/PR), red at `eceb6d5` (no guard file, no wiring); Vajra's own hook no longer exempts `-closeout`; report allowed, `src/` blocked; record opens it, old `vajra` does not; forged record voided; N17 blocked as session 5; `--sync-fleet` on an old project wires it |
| D2 / AC2 F116 | SHIPPED | verify row 8; live on this branch before/after `3b50dc9` |
| D3 / AC3 F118 | MOVED OUT (founder) | ROADMAP known bugs: still open, founder's call, next GT checklist (`b3695d4`); seen again at this session's own advance (`aad6381`) |
| D4 / AC4 F119 | SHIPPED | verify row 9 |
| D5 / AC5 N10 | SHIPPED | verify row 10: exit 0 here; an unmarked grep and a reason-less marker both still fail |
| AC6 real-run checks, cargo test, push via the S196 belt | SHIPPED except the push, which happens after the close (below) | verify 11/11; cargo test 735/0 |

**Not built:** F118. rec 10 of the design-advisor (a `--steps` line for the close record) — see `## Advice`.

**Fakest green:** row 4's "the founder's terminal" is `script -q /dev/null` — a pseudo-terminal any agent can
also start. The record is bar-raising, not tamper-proof (DECISION-011 already names "fake a terminal"). Also: the
guard reads command TEXT (`g=git; $g commit` gets through), and the agent can edit `.ai/hooks/` or put another
`vajra` first on PATH — all named in the addendum's Limit.

## New finding (filed, not fixed)

- **N18 — `scaffold-drift.sh` check 6 sorts verify scripts by the 3rd `-`-separated field of the FULL path.** In a
  folder whose path has dashes (e.g. the old-version checkouts, `…/vajra-old-checkouts/<pid>-<sha>/`) it picks the
  wrong "last 10". Found writing verify row 10. LOW.

## Process

- Crew: tech-lead (required: design-advisor, fidelity-reviewer, release-coordinator) · design-advisor (12 recs, the
  addendum text) · fidelity-reviewer and release-coordinator at close.
- The session guard read "S200" inside a command once (the known heredoc/mention class); worked around with a
  script file + `git commit -F`.
- After merge, rudra needs `vajra init --sync-fleet` and a Claude Code restart to get the guard.

## Next — 3 ranked candidates

1. **(Recommended) rudra S22, synced — the push belt and the review-only guard on a real project.** `vajra init
   --sync-fleet` in rudra, restart Claude Code, run a real session to close. Why: F127 and F125 have only run in temp
   projects. Risk: S22 is a real build (the AI research pipeline) — long and paid.
2. **The known-bug leftovers: F118 + N18.** `--advance` moves the old entry to `## Prior Session`; check 6 sorts by
   file name, not path. Why: small, each one a user meets. Risk: little user-visible value on its own.
3. **Design: Vajra runs the required reviewer itself (Haiku answer d),** plus the README "tested with" line in the
   founder's words (c). Why: the root fix for "the agent graded itself" on a cheap model. Risk: design only; every
   close then costs money.
