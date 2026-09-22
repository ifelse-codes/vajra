# Fidelity review — session 173 (`session-173-keep-testing`)

Independent cold review by the `fidelity-reviewer` role, fed the prompt and the diff — never the
builder's account. Nine passes: eight REJECT, then ACCEPT. Passes 6–9 were scoped to the last fix
only, as each previous pass recommended. The handoff of record is
`.ai/handoffs/session-173-fidelity-reviewer.md` (pass 9); passes 1–8 are in git at 37c8043,
695e32e, 3bad781, f5d6682, 9146a15, 5351bf6, 59c5b84 and 16a495d.

## Per-requirement verdicts (pass 9, carrying pass 8's full grade)

| # | Requirement | Verdict | Evidence (reviewer's file:line) |
|---|---|---|---|
| D1 | Boot survives a handover naming no prompt (F45) | SHIPPED | `scripts/hook-session-start.sh:42-43` — `|| true` on the reads and the grep; branch, approval and checklist lines reached |
| D2 | Merged session not sent back, walled or re-graded (F46, F51) | SHIPPED | `src/nextstep/mod.rs:59-64`; `src/cli/next.rs:1494-1498` heading; `print_reasons`/`print_warnings` one counted line when merged |
| D3 | No fake question (F52) | SHIPPED | `src/cli/next.rs` `confirm`: asks only at a real terminal; a piped `n` still aborts; no step says `echo y` (unit test) |
| D4 | Guards not loosened; F50 handled by the block message | SHIPPED | session guard: the old line-by-line SCAN alone decides the number and the owner record; the extra reads only add block reasons; no perl → the old rule; both block messages name `git commit -F <file>` |
| D5 | Close in order up front (F53, F54) | SHIPPED | `src/nextstep/mod.rs:156-176` — advice step with exact formats, stamp LAST, only the merge after |
| D6 | Agent ships its own branch (F55) | SHIPPED | `scripts/hook-publish-guard.sh`: branch read from the hook input's `cwd`, only when its toplevel is the project root; allow-list of exact shapes; merge stays human |
| D7 | Sync says whose files it wrote (F49) | SHIPPED | `src/cli/init.rs:503-509` |
| D8 | F48 checked, not built | SHIPPED | the next-prompt step precedes the stamp; rudra's S05 prompt existed before its S04 merge |
| AC1 | No-prompt boot prints branch, approval, checklist; exit 0 | SHIPPED | verify runs the real hook with the built binary on PATH |
| AC2 | Merged ACCEPT not the next step; REJECT never done | SHIPPED | unit test + live rudra clone |
| AC3 | Merged S04: no per-item ✗; S05 reasons in full | SHIPPED | real binary on rudra pinned at 3c401ec |
| AC4 | No terminal: no question, says so; no `echo y` | SHIPPED | live no-terminal advance; piped `n` aborts; unit test |
| AC5 | Session guard allows nothing it blocked before; blocks the listed forms; names `-F` | SHIPPED | old-vs-new on 120 listed commands; decoy owner-record checks at L2/L1; no-perl loop |
| AC6 | Advice step, stamp LAST with `--inputs-sha`, only merge after | SHIPPED | live `--steps` order + unit test |
| AC7 | Publish allow/deny matrix under the approval | SHIPPED | ~45 real hook runs incl. worktree, nested clone, `/tmp`, no `cwd`; merge/main forms never ride the approval |
| AC8 | Sync ends with a whose-files line | SHIPPED | real `init --sync-fleet` on a rudra clone |
| AC9 | cargo test, fmt, clean rudra sync | SHIPPED | live in the verify (87 pass, 0 fail, re-run on the branch after the last change) |

**17 of 17 SHIPPED · 0 PARTIAL · 0 NOT-BUILT.**

## What the nine passes found

1. **REJECT** — the F50 fix hid what bash runs (heredoc first lines, backticks, `bash -c`); a force-push to main passed with no approval. The fakest green was a check labelled "backticked-mention-passes".
2. **REJECT** — the bash-like scanner that replaced it still hid code (unquoted heredoc `$( )`, `| bash`, empty heredoc, an apostrophe in a comment); a merge rode the new permission inside a PR body.
3. **REJECT** — the one remaining exception's body could run past an early delimiter line.
4. **REJECT** — its "balanced quotes" test only counted quote marks; `-R` glued to its value opened a PR in another repo.
5. **REJECT** — on macOS `/bin/bash` 3.2 the exception still hid a push (confirmed on this machine), and the permission read the project folder's branch, not the command's. The exception was removed.
6. **REJECT** — a decoy `$(echo checkout -b session-01-a)` displaced the real session number; no perl made both guards exit 127.
7. **REJECT (17/17 SHIPPED)** — two false claims: "nine fixed" (eight), "never writes the owner record" (it could at L1).
8. **REJECT (17/17 SHIPPED)** — one stale count in the summary.
9. **ACCEPT** — the last two recs were optional and taken.

## The independent judge of the `obeyed:` answers

The close check requires a role other than the advisor and the builder to confirm each `obeyed:`
answer against its commit. The implementation-advisor did (`.ai/handoffs/session-173-implementation-advisor.md`):
10 confirmed, and two honest mismatches — tech-lead rec 3 (it asked for one review; there were
nine) and fidelity-reviewer rec 2 (a verify run leaves no commit). Both are now `refused:` with the
reason, not claimed; tech-lead rec 4 was re-pointed at the commit that actually did it (5351bf6).

## The fakest green

The before/after check covers **120 listed commands** (30 shapes × 4 triggers), with and without
perl — far stronger than the example lists passes 1 and 2 caught, and it went red for the right
reason at passes 3–6. But it is a list: a spelling no one has tried is not covered. The shipped rule
is safe by construction only in one direction — it reads everything the pre-S173 rule read, plus
more — and the list is the evidence for that, not a proof over bash's grammar.

## What was NOT built

**F50 is not fixed in code.** A commit message that mentions a guarded command still blocks, as it
did before S173; the block now names `git commit -F <file>` / `--body-file`. F47, F56 and F57 are
parked LOW. The F55 `cwd` assumption (Claude Code reports the Bash tool's current directory) is
unverified live — S174 checks it.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** `ff387536ce987046cbe4a63d5a88708173553c7be3a6a0f1c9a86e421aa4de64`
