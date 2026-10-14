# Session 196 — rudra S21 on Opus, and F127: no push until the close is GREEN

> The findings and the founder's calls were written before any code (tech-lead rec 1).

## rudra S21, as it ran (founder, 2026-10-12 → 13)

- `vajra init --sync-fleet` first (rudra `ddfc769`, "S21: vajra sync (S194 fixes: close-check line, merge guard)").
- **Model: Opus 5.5 for every reply (312 of 312, + 1 `<synthetic>`)** — transcript
  `~/.claude/projects/-Users-suman-playground-rudra/f85ffdb0-….jsonl`, 18:05:14Z → 03:24:56Z (one launch, with a
  long pause overnight). The task was re-scoped by the founder to the AI Council design (rudra ADR-020, DOCUMENT).
- Close log read for `WAIVED` / `N/A` / `WARN` first (S178), `rudra/.ai/verify/closeout/20261013T021539Z`:
  0 WAIVED · 1 N/A (`required-crew`: "session 21 is not a CODE session — tech-lead file not required here") ·
  2 WARN (14 `obeyed:` claims never checked by an independent role; no `lint_command:`) · **GREEN — 21 pass, 0 fail**.
  The `result` file: `vajra-closeout-result: 1 · session: 21 · verdict: GREEN · pass: 21 · fail: 0 · warn: 2 · failed:`.

## AC2 — F121 and F123, live

| Fix | Live result | Evidence |
|---|---|---|
| **F121** (exit box shows the close) | The line the binary prints for that result is `close check: GREEN with 2 WARN — 21 passed; read the WARN rows · .ai/verify/closeout/20261013T021539Z` (`src/cli/launch.rs` format for a GREEN-with-WARN v1 result). **The founder did not paste his screen, so the on-screen line is not confirmed word for word.** Timing: close 02:15:39Z · PR #25 merged ~03:17Z · the chat closed after 03:24:56Z → **the box can only have appeared after the merge** (S195 design-advisor rec 3's "only at exit" limit, live). Named, not closed; the founder's answer to it is F127 below. | rudra close folder above; transcript timestamps; `73d4c2a` |
| **F123** (pre-merge-commit) | **Not exercised.** rudra's main moved only by fast-forward (`main@{0}: merge origin/main: Fast-forward`, from the agent's `git merge -q --ff-only origin/main`); no merge commit was attempted. | `git reflog main` in rudra |

## AC3 — Opus (S21) vs Haiku (S20)

| | S20 · Haiku 4.5 | S21 · Opus 5.5 | Source |
|---|---|---|---|
| Helper (`Agent`) calls | 0 | 4 — tech-lead, design-advisor, qa-specialist, fidelity-reviewer (+ 3 `SendMessage` follow-ups) | S194 summary F122 · S21 transcript tool counts |
| `vajra next` used | no | 18 calls (`--steps` ×5, `--role` ×5, `--advice` ×3, `--check-*` ×4, bare ×1, plus `--help`) | S194 summary · S21 transcript Bash commands |
| Review | written by the main agent, headed "INDEPENDENT" | real subagent — all 4 handoffs carry `verified: toolu_…` | S194 F122 · `rudra/.ai/handoffs/session-21-*.md` |
| Close verdict | RED 17/5 | GREEN 21/0, 2 WARN | close folders |
| Agent's last claim | "✅ SESSION 20 — FULLY CLOSED … Independent review (ACCEPT)" | "Session 21 is fully closed … Nothing is left half-done." | S194 F121 · S21 transcript 03:17:30Z / 03:24:55Z |
| Claim vs close | false | true for S21 itself; "nothing half-done" is not (F126) | — |
| Cost | $1.49 | $19.21 | S194 summary AC3 (cost-state 1.4903) · the receipt table below |

**Answer:** on Opus every instruction-only step ran and the end claim matched the close. On Haiku none ran. The
close half of "can the founder be confident?" is **yes on Opus, no on Haiku** — and on either model a RED close
still stopped nothing, which is F127.

## The receipt (tech-lead rec 4)

| Source | Figure |
|---|---|
| vajra's top line | not pasted by the founder — not recorded |
| transcript's last `cost-state` `totalCostUSD` | 19.2086772 |
| `~/.claude.json` rudra `lastCost` | 19.2086772 (`lastSessionId` f85ffdb0…, the same run) |

A fresh launch (not a resume, fork or `/clear`).

## Findings

| # | What happened | Evidence | Founder call |
|---|---|---|---|
| **F126** | After the close and the review stamp, the founder changed S22's direction ("no vendor research … lets build something real"). The agent kept the old S22 prompt in git ("changing it now would undo today's sign-off"), saved the new plan only in Claude Code's private memory, then told him "Everything is saved … Nothing is left half-done." The stamp binds the next prompt, so a founder change after the review has no place in the project. | S21 transcript 02:46:18Z, 02:51:54Z, 03:24:55Z · `~/.claude/projects/-Users-suman-playground-rudra/memory/s22-council-pipeline-plan.md` · `rudra/prompts/22-task-council-model-adr.md` still "model, vendor and API terms" | **Park** (2026-10-14) → ROADMAP known bugs, S200 checklist |
| **F127** | A RED close stops nothing. rudra S20's close was RED (5 fail) and its branch was still pushed, a PR opened and merged on GitHub, and S21 started on top with no word from Vajra. The only reader of the close result is the exit box, which shows after the merge (F121 row above). | `rudra/.ai/verify/closeout/20261012T035332Z/result` (RED) · rudra PR #24 merged · no code outside `src/cli/launch.rs` reads the result | **Fix** (2026-10-14: "no pr creation till it is not green, till all review is pass from agents") — session branches only; the agent is stopped, the founder's own push is warned, not stopped |
| **F116** (seen again) | rudra's `.ai/approvals/session-21.json` still untracked after the merge | `git status` in rudra | Parked (S193) → S197 |

**Close-log notes, not findings** (the founder was asked once and did not call them; agent's notes, S196 review
rec 5): rudra S21's 2 WARN — 14 `obeyed:` claims never checked by an independent role (`obeyed-judgments.log`;
rudra's tech-lead did not require a release-coordinator) and no `lint_command:` (`project-lint-clean.log`, rudra's
own setting). F127 lets a GREEN with WARN push: a WARN is not a fail.

## F127 — the fix (DECISION-007 + ADR-0004 S196 addenda)

**The rule.** A pull request needs a pushed branch, so `.githooks/pre-push` stops an **agent's** push of a
`session-NN-…` branch unless the close check said GREEN for **that exact commit**, with tracked files clean, for
session NN. GREEN with WARN passes. A person gets a `Note:` and the push goes on (founder's call). A branch not named
`session-NN-…` is not checked (founder, 2026-09-21, kept). No new override.

| Part | Commit | Proof |
|---|---|---|
| The close result says which commit it checked (format 2: `head:`, `clean:`, taken at start and end), in both close scripts | `5c2f840` | `tests/push_belt.rs` last case: the scaffold's own close script writes `head:` = HEAD, `clean: yes` |
| The exit box reads formats 1 and 2 | `5c2f840` | `s196_a_format_2_result_is_read_like_format_1`; verify-196 row 9 (59719f8's binary: "result unreadable") |
| `.githooks/pre-push`: refuses RED / older / unclean / other-session / missing / old-format, each with its reason and the way through; fails closed | `08024f3` | `tests/push_belt.rs` 9 real `git push` runs to a bare remote; verify-196 rows 1–8 |
| The two readers agree on the 15 format-2 cases tested (incl. `+30` and CRLF, review rec 4) | `c1aa1d6` + the rec-4 commit | `s196_the_push_belt_and_the_exit_box_agree_on_every_format_2_result` (13 cases) |
| Records + the close-step text | `604cd29`, `dba3721` | DECISION-007 / ADR-0004 S196 addenda; Releaser step: "run it LAST … until GREEN" |
| verify + demo | `c6545ee`, `f300f4b` | verify-196 **10/10** (each fix row red at 59719f8) · demo 5/5 · `cargo test` **734 / 0** at the tip after the review fixes (732 / 0 before them) |

**What it does not do (named, not closed):** an agent set on it could write a fake GREEN result file, or type
`git push --no-verify` (bar-raising, not a lock) · untracked files are not counted in `clean:` · a waiver typed
inline is a GREEN · a non-session branch name skips it (N17 → S197) · your own RED push goes through with a note —
and a PR can then be opened from it · rudra gets it only after `vajra init --sync-fleet`.

## Fidelity map

| Item | Status | Evidence |
|---|---|---|
| D1 / AC1 every finding has evidence and a founder call | SHIPPED | Findings table above (F126, F127, F116 sighting), written before code (`64695d3`); the 2 WARN are agent's notes, not findings |
| D2 / AC2 F121 + F123 live | PARTIAL | F121: the result file and the line the binary prints for it are recorded, and the timing (after the merge) — **the founder's on-screen line was not pasted, so it is not confirmed word for word**. F123: not exercised (fast-forward only, reflog) |
| D2 / AC3 Opus-vs-Haiku table, every cell sourced | SHIPPED | AC3 table above |
| D3 / AC4 every fix has a real-run check, red at the start commit | SHIPPED | verify-196 10/10, each F127 row red at 59719f8; no source greps |
| AC5 no Vajra commit touches rudra; full `cargo test` before push | SHIPPED | `git diff --stat main` lists only Vajra files; rudra read, never written |
| The receipt (watch item) | PARTIAL | cost-state = lastCost = $19.2087; **vajra's top line not pasted**, so "nothing else in the box" is not confirmed |

**Fakest green:** the push belt trusts a file. A GREEN result the agent writes by hand passes, and `--no-verify`
skips the hook. It stops an agent that follows the steps; it does not stop one that sets out to cheat.

## Process

Crew: tech-lead (mandatory, first) → design-advisor (narrow, once the founder said yes to F127 — tech-lead rec 6)
→ fidelity-reviewer (one cold pass) → release-coordinator (the one judge of every `obeyed:` answer). Each handoff
recorded from the handback text. Founder calls taken with one question set (branches · his own push · F126).

## Next — 3 ranked options

1. **(Recommended) S197 — the known-bug session.** F125 first (the `-closeout` opening needs `vajra approve NN
   --close`; N17 with it), then F116, F118, F119, N10. Why: each is a thing a user meets, and N17 is the one way
   around the new push belt (a branch not named for a session). Risk: F125's design could grow — split F118 out.
2. **rudra S22, synced — the push belt's first real run.** `vajra init --sync-fleet` in rudra, then a real session
   to close: does the agent's push wait for GREEN? Why: F127 has only run in temp projects. Risk: S22 is a real
   build (the AI research pipeline) — long and paid.
3. **Design: Vajra runs the required reviewer itself (Haiku answer d),** plus the README "tested with" line in the
   founder's words (c). Why: the root fix for "the agent graded itself" on a cheap model. Risk: design only; every
   close then costs money.
