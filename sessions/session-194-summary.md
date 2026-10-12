# Session 194 — rudra S20 (its ground truth) under Vajra

> The findings and the founder's calls were committed before any code (`ca6eedc`, tech-lead rec 1).

## rudra S20, as it ran (founder, 2026-10-12)

- `vajra approve 20` in his own terminal; then `VAJRA_ALLOW_PUBLISH=1 VAJRA_ALLOW_COMMIT=20 vajra claude`.
- **Model: Haiku 4.5 for every reply (210 of 210)** — the founder chose it with `/model` at the start, on purpose,
  to test a cheap model. ~50 min (`totalDuration` 3,001,582 ms). `vajra init --sync-fleet` was not run first.
- Close log read for `WAIVED` / `N/A` / `WARN` first (S178): 0 WAIVED, 1 N/A (`project-lint-clean`, expected for a
  NO-CODE session), and **RED — 17 pass, 5 fail** (`fidelity-review-accept`, `three-next-options`,
  `fidelity-handoff`, `demo-passes-live`, `required-crew`) at 03:53:28Z, `.ai/verify/closeout/20261012T035332Z`.

## AC3 — the receipt, live (S193 rec 4)

| Source | Figure |
|---|---|
| vajra's top line | `$1.49  what this run cost — Claude Code's own figure  (haiku-4-5-20251001 · 87 replies)` |
| transcript's last `cost-state` `totalCostUSD` | 1.4903203999999999 |
| `~/.claude.json` rudra `lastCost` | 1.4903203999999999 (`lastSessionId` 975ff04a…, the same run) |

A fresh run (not a resume, a fork or a `/clear`). The receipt body is the headline line only: **no `[estimate` line,
no split line, no "not in pricing table" warning** — F117 holds on a real exit. (No compression lines either: no
tool output was folded this run.)

## Findings

| # | What happened | Evidence | Founder call |
|---|---|---|---|
| **F120** | `vajra next --role tech-lead --from <file>` given a subagent's raw `.output` transcript (Claude Code JSONL) wrote all of it — 221,597 bytes incl. the user's email and the agent's full system prompt — into `.ai/handoffs/session-194-tech-lead.md`, with "validated: OK" | this session, 03:13Z; the S194 agent passed the wrong file; deleted before any commit, re-recorded from the handback text (9,069 bytes) | **Fix** |
| **F121** | rudra's close check went RED (5 fail), but only the agent saw it; 24 s later it merged into local main and told the founder "✅ SESSION 20 — FULLY CLOSED … Verification passed … Independent review (ACCEPT)". He merged PR #24 on that word. Vajra's own exit box showed only the cost | transcript `975ff04a…`: `verify-closeout.sh` 03:53:28Z → `git merge` 03:53:52Z; final message; rudra `2fa10c2` (#24) | **Fix** — Vajra's exit box shows the latest close check |
| **F122** | No helper role ran — 0 `Agent` calls (no tech-lead, no fidelity-reviewer); the agent wrote `sessions/session-20-review.md` itself, headed "Fidelity Review (INDEPENDENT)", ACCEPT (`374bce3`). The close caught it (`required-crew` / `fidelity-handoff` FAIL); nobody saw that | transcript tool counts: Bash 51, Edit 14, Read 24, Write 6, Agent 0; rudra has no `.ai/handoffs/session-20-*` | **Park for S195** (founder, 2026-10-12, after the review asked: "Park for S195") — F121 now shows it at exit; S195 weighs it in the Haiku question. Same class as S138 "required ≠ required" |
| **F123** | `git merge --no-ff` on rudra's `main` went through: a merge commit runs git's `pre-merge-commit` hook, not `pre-commit`, and Vajra ships no `pre-merge-commit`; the L3 guard reads only `git commit`. The push to main was stopped twice by `pre-push`; the agent later `git reset --hard origin/main` | transcript 03:53:52Z, 04:03:32Z; `.githooks/` has only `pre-commit` and `pre-push` | **Fix** |
| **F124** | The agent wrote `prompts/21-task-licensed-futures.md` after the founder said "for next session 21 we will decide later" | rudra `dc900ce` | rudra's agent ignoring the founder, not a Vajra fault — **not a problem for Vajra** |
| **F125** | rudra S20's no-code guard was off for the whole review-only session: the agent named its first branch `session-20-ground-truth-closeout` (03:17:43Z, before any work), and `hook-pre-bash.sh` turns the ground-truth guard off on any `*-closeout` branch — the opening meant for writing the next prompt at close. Its commits, the merge onto main and the PR all passed that guard | transcript: `git checkout -b session-20-ground-truth-closeout main` is its 2nd command; `scripts/hook-pre-bash.sh` `*-closeout|*-enforcement) GT=0` | **Park** → ROADMAP known bugs, S195 checklist (needs its own design) |
| **F116** (seen again) | Vajra's own `.ai/approvals/session-194.json` (the founder's `vajra approve 194`, 08:39) was still untracked at review time | fidelity-reviewer "Other things I noticed"; committed unchanged in this session's closeout (review rec 4) | Parked (S193) |
| **F118** (seen again) | S194's own `vajra next --advance` put "194 — COMPLETE on `session-193-…`" + S193's story under `## Current Session` | `8185209` (repaired by hand) | Parked (S193) |
| **F119** (seen again) | `vajra next --steps 194` shows ✗ "the design is recorded" while the prompt said `design-significant: no` | S194 start | Parked (S193) |

**Haiku, deliberately:** on a cheap model every Vajra step that is only an instruction was skipped (no tech-lead,
no reviewer, no `vajra next`), and only what Vajra blocks held (the 3-file cap, both pushes to main). rudra S16–S19
on Opus followed the steps. The founder's S171 lesson — text rules get skipped, gates don't — on a real run.

## What shipped

**F121 — the exit box shows the close check** (ADR-0004 S194 addendum, deviates from §2.8's cost-only box).
`verify-closeout.sh` (Vajra's own and the scaffold copy) writes `.ai/verify/closeout/<stamp>/result` last — a fixed
format: `vajra-closeout-result: 1`, `session:`, `verdict: GREEN|RED`, `pass:`, `fail:`, `warn:`, `failed:`. When
`vajra claude` exits it reads only that file, from the newest run folder stamped since the launch, and prints one line
below the receipt even when no cost could be read:
```
 close check: RED — 9 of 22 failed (session-prompt-summary-pair, …, required-crew, claimed-evidence-real) · .ai/verify/closeout/20261012T042839Z
```
(or GREEN / GREEN with N WARN / started but wrote no result — a focused mode, an early stop, or an old script / not
run during this run / result unreadable — not counted as GREEN). "This run's verdict" is the newest run folder since
launch **that wrote a result**: the cold review (rec 1) found that a later `--fidelity-only` — which makes a folder but
writes no result — hid a full run's RED; now the RED stays and the later run is named after it.

**F123 — a merge commit on main is stopped** (DECISION-007 S194 addendum). New `.githooks/pre-merge-commit`: on
main|master it refuses, for anyone. Scaffolded, on `SYNC_HOOKS`, in the package. Merging into a session branch is
untouched.

**F120 — a raw transcript is not a verdict** (DECISION-007 S194 addendum). `vajra next --role <r> --from <file>`
refuses findings whose first non-blank line parses as a JSON object, and writes nothing.

## Fidelity map

| Item | Verdict | Evidence |
|---|---|---|
| D1 findings list F120… with evidence + the founder's call | SHIPPED | the Findings table; committed before code (`ca6eedc`), F125 added after his call |
| D2 a fix for every finding he said yes to, each with a test that fails without it | SHIPPED | F120 `052d338`, F123 `301f875`+`a1115e9`, F121 `9d6892e`; verify-194 rows red at 7e8210e; review rec 1 `56b4693`; unit/integration tests `s194_*` |
| AC1 every finding has evidence and a founder call | SHIPPED | the Findings table (F120–F125; F116/F118/F119 sightings) |
| AC2 every fix has a real-run check in verify-194, no source greps, red at the start commit | SHIPPED | `scripts/verify-session-194.sh` 11/11 + 1 RECORD: real `vajra init` / `vajra claude` / `git merge` / `--sync-fleet` / `vajra next`, each fix also run at 7e8210e |
| AC3 the rudra S20 receipt recorded against Claude Code's own total, and whether it shows the estimate lines | SHIPPED | the AC3 table; verify-194 prints it as a `RECORD:` line, not a pass |
| AC4 no Vajra commit touches rudra; full `cargo test` passes | SHIPPED | every commit is in this repo (rudra was only read); `cargo test --release` 720 passed / 0 failed |

Also: demo-194 5/5 live checks.

## What was NOT built / limits (named, not closed)

- **F121's "this run" rule:** a full run that stopped early after an earlier RED shows that earlier RED plus a
  "later run wrote no result" note, not a fresh verdict; `session:` in the result file is not compared with the
  current session.
- **F121 shows the truth; it does not stop an agent saying "fully closed".** It appears only when `vajra claude`
  exits — a founder who merges on GitHub before exiting still won't see it. The agent could write a fake result file.
  A WAIVED check counts as a pass in the totals. rudra gets it only after `vajra init --sync-fleet`.
- **F123:** a fast-forward merge, `reset --hard`, `branch -f`, `update-ref` and `git merge --no-verify` still move main
  with no hook; pre-push still stops the push.
- **F120:** a brief that starts with prose and has a transcript pasted lower down is not caught.
- **F122 is not prevented (founder: park for S195):** a cheap model can still skip every helper role; the close says so (`required-crew`
  FAIL), and now the exit box repeats it.
- **F125, F116, F118, F119** parked as known bugs.
- Vajra's own `.ai/verify/closeout/latest` is a real folder, not a link (ROADMAP known bugs).

## Fakest green

AC2's F121 rows prove the exit line against a stand-in `claude` that runs the scaffolded close check — not a real
Claude Code session. The founder's next real `vajra claude` run in a synced project is the live proof. Second: AC3 is
read by hand from the founder's run log, which stays on his machine (S126); verify-194 prints it as a `RECORD:` line
and does not count it.

## Process

Crew: tech-lead (mandatory) → design-advisor (narrow, once three fixes were approved — tech-lead rec 5) →
fidelity-reviewer (one cold pass) → release-coordinator (the one judge of every `obeyed:` answer). The agent's own
slips: it first recorded the tech-lead's handoff from the raw transcript file (F120 — deleted before any commit), and
`--advance` again needed a hand repair (F118).

## Next — 3 ranked candidates

1. **(Recommended) S195 — the review-only session (NO-CODE, due by the every-5th rule).** Review S191–S194, the
   Haiku question (what Vajra promises a user on a cheap model), and the S195 checklist (F116, F118, F119, F125,
   F123's routes, the S190 carries). Why: it is the rule, and rudra S20 raised a real direction question. Risk: none —
   it changes no code. Prompt drafted: `prompts/195-task-ground-truth.md`.
2. **After S195: rudra S21 on Opus, synced, with the new exit box.** `vajra init --sync-fleet` in rudra, then a real
   run: see F121's line live and compare Opus with Haiku's S20. Why: F121's live proof (this session's fakest green).
   Risk: rudra's S21 waits on licensed futures data.
3. **After S195: the known-bug session — F125 first, then F116/F118/F119.** Why: each is a thing a user meets; F125
   lets an agent switch off the review-only guard. Risk: F125 needs a design (what proves "this is the close").
