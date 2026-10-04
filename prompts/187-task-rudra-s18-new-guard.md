# Session 187 — rudra session 18 with the new guard

> **Status:** DRAFT — written by the S186 agent from the founder's pick (2026-10-04: "rudra S18 (Recommended)").
> He approves it with `vajra approve 187` in his own terminal; the gate reads the approval record, not this line.

## Type
session_type: INTERACTIVE
- **INTERACTIVE** (gets the CODE checks). Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The founder runs rudra S18 himself under `vajra claude` and brings what happened; this session lists the findings with him and fixes what he says yes to.

## Goal
S186's changes get their first real use in rudra S18: the approvals guard that reads where a redirect really writes (F110 b), unchecked `obeyed:` claims that warn instead of blocking at rudra's own session numbers (F113), hook block reasons on stderr (N1), and the `--sync-fleet` merge that adds no hook twice. Every finding gets evidence and the founder's call; every fix he says yes to gets a check that fails without it.

## Before rudra S18 starts (founder, in order)
1. Merge S186's PR. Then `cargo install --path .` in `~/playground/vajra` (the installed Vajra is pre-S186).
2. In rudra: `vajra init --sync-fleet` (brings the new guard and the S186 close gate). Look at the `.claude/settings.json` diff: no hook should appear twice. Commit what it writes as S18's first commit, on S18's branch.
3. Approve rudra S18 from his own terminal: `vajra approve 18`. rudra's prompt: `prompts/18-task-futures-measurement.md`.

## What to watch in rudra S18
Read every close log for `WAIVED`, `N/A` and `WARN` FIRST, never just PASS (S178).
- **The guard:** every `[HOOK BLOCK]` naming `.ai/approvals` — was it a real write, or an over-block (a quote after `>`, an arrow `->` in a commit message, a heredoc line)? Did the agent see the reason and use `git commit -F`?
- **Obeyed claims:** the `obeyed-judgments` row should WARN and say "no `obeyed_blocks_from:`" — never block.
- **Ground-truth blocks** (if any): the reason reaches the agent, not "No stderr output".
- **Time + cost** (the receipt is still F67-overstated ~5×).

## Deliverables
1. A findings list from rudra S18 (F116 on), each with evidence and the founder's call, in the summary.
2. A fix for every finding the founder says yes to, each with a check that fails without it.

## Acceptance
| AC | Check |
|---|---|
| AC1 | Every finding has evidence (a log line, a transcript time, a command) and the founder's call, recorded in the summary. |
| AC2 | Every fix has a real-run check in `scripts/verify-session-187.sh` (no source greps) that is red at the commit S187 starts from. |
| AC3 | No Vajra commit touches rudra; rudra's commits are the founder's or his agent's under his launch-time approval. |

## Design
design-significant: no
- Interactive test session; any fix the founder approves is designed in-session and recorded here.

## Carried in
- **From S186's cold review:** the guard reads text — a path built at run time and any writer no list names still get past; over-blocks (a quote after `>`) are expected. If rudra hits either, it is a finding.
- **verify-session-133 is red at main** (3–4 checks, stale since S181) → backlog, on the S190 ground-truth checklist with S185 N3.
- **S185 N2, N4–N7** → backlog, on the S190 checklist. **Parked by the founder:** F67, non-Claude tools (F91, F94, F95), release.

## Guardrails
- ≤3 files per commit; every fix has a check red at the start commit for the named reason.
- Guard changes only add (S173); never hide text from the guard.

## Plan
<the S187 agent writes this after the tech-lead, each step citing `covers: N`>

## Delta
- `+` rudra S18 findings and the founder's calls
- `+` fixes he says yes to, each with a failing-before check
