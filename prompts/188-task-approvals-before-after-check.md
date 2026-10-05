# Session 188 — the approvals folder: check what changed, not what the words say

> **Status:** DRAFT — written at the end of S187 from the founder's approved plan (2026-10-05).
> He approves it with `vajra approve 188` in his own terminal; the gate reads the approval record, not this line.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The one story: **an AI that only reads the approvals folder is never blocked; an AI that writes to it is
  always caught.** Replace the word-guessing Bash guard with a before/after check.

## Goal
Today the approvals guard (`scripts/hook-approvals-guard.sh`, shipped to every project as
`.ai/hooks/hook-approvals-guard.sh`) reads the WORDS of every AI command and blocks when they name
`.ai/approvals` and look like writing — it false-blocked harmless reads 5 times in S187 alone (F110 class)
and can still be fooled by spelling. The founder's plan (2026-10-05): the AI is told never to write there;
Vajra looks at the folder **before and after** each AI command; if it changed, the AI did it — Vajra stops,
says so plainly, and that approval stops counting until the founder approves again. No sandbox, no chasing
tricks ("we say it not to write; once it uses the folder, even if it tricks us, we enforce it and ask again
not to").

## Deliverables
1. **N2 → backlog as a known issue** (founder, 2026-10-05): the ground-truth Write guard blocks writes
   outside the project; fixed some time in a future session. ROADMAP + STATE say so; S187's "N2 → S188"
   wording is replaced. (Design input kept: the S187 design-advisor's recs 12–20.)
2. **The before/after check (Bash).** Before each AI Bash command, Vajra records the folder's state (each
   file's name and content hash); after it, compares. Same → silent, exit 0. Changed → the AI is told, in
   plain words, that only the founder writes there and that the session's approval no longer counts until
   the founder runs `vajra approve NN` again — and the approval really stops counting (the gate, and
   `vajra next --steps`, read it as missing).
3. **The Bash word-guessing checks go.** The Write/Edit/MultiEdit/NotebookEdit block on a path inside the
   folder stays (it reads the real file path, not words). The AGENTS.md rule "the AI never writes to
   `.ai/approvals`" stays, and says what happens if it does.
4. **Projects get it.** `vajra init` scaffolds it and `vajra init --sync-fleet` ships it and wires the
   after-command hook into an existing project's `.claude/settings.json` (add-only, as S182). rudra gets it
   on its next sync.
5. **The founder is never flagged:** `vajra approve NN` typed in his own terminal changes the folder BETWEEN
   AI commands, so no before/after pair sees it.

## Acceptance
| AC | Check |
|---|---|
| AC1 | Every read the old guard false-blocked now passes (exit 0): S187's live case (`git checkout -b X main && cd … && ls .ai/approvals/`), `s187_split`, `f110_open` (heredoc / commit message naming the folder). Red at the start commit: they block. |
| AC2 | Every real write into the folder from the old guard's corpus (cp, mv, rm, `echo >`, tee, python, awk, `find -delete`, `git checkout --`, a path built at run time), run as an AI Bash command, is caught AFTER it runs: exit 2, the plain message, and the session's approval reads as missing in `vajra next --steps`. |
| AC3 | A change to the folder made between two AI commands (the founder's `vajra approve NN`) raises nothing, and the new record counts. |
| AC4 | A Write/Edit tool call aimed at a file in the folder is still blocked before it runs (unchanged). |
| AC5 | A fresh `vajra init` project and an existing one after `--sync-fleet` both run the check; `--sync-fleet` adds the hook once, never twice. |
| AC6 | Every fix has a real-run check in `scripts/verify-session-188.sh` (no source greps) that is red at the commit S188 starts from; the FULL `cargo test` passes locally before the PR is pushed (S187 lesson). |

## Design
design-significant: yes
- Reverses DECISION-011's S182/S186 choice for Bash (block by reading the command's text) in favour of
  detecting the RESULT. Recorded as a DECISION-011 S188 addendum; the design-advisor names the shape
  (where the "before" state is kept, how the approval is made not to count, the hook pair's order with the
  existing hooks).
- Accepted gaps (founder: no policing): a change undone within the same command is not seen; the "before"
  record itself can be edited by a determined AI. Both bar-raising, not tamper-proof — the same posture as
  DECISION-011.

## Carried in
- From S187 (`sessions/session-187-summary.md`): F110's false blocks are this session's reason; the S187
  corpus (`tests/approvals_guard.rs`) is the test list for AC1/AC2.
- **Rejected by the founder (2026-10-05):** Claude Code's sandbox (A1) and Vajra's own OS box (A2).
- **Backlog, S190 checklist (from S187):** the rest of N7; F97's opt-out key; `--advance` number-swaps
  SESSION-BOOT; the session guard reads a session number in edit text; verify-133 not safe to run twice at
  once; `tests/gt_cadence_shared.rs` reads the real repo's summary. **Parked:** F67, non-Claude tools, release.

## Guardrails
- ≤3 files per commit; every fix has a check red at the start commit for the named reason.
- This session REMOVES text checks on purpose (founder's call) — say plainly in the summary what the old
  guard blocked BEFORE a command that the new check only catches AFTER it.
- Run the full `cargo test` before pushing.

## Plan
<the S188 agent writes this after the tech-lead, each step citing `covers: N`>

## Delta
- `-` the approvals guard's Bash word checks (redirect, writer, interpreter and program lists)
- `+` a before/after check of `.ai/approvals` around every AI Bash command; a changed folder voids the approval
- `~` `vajra init` / `--sync-fleet` ship and wire the new hook
- `~` N2 → backlog as a known issue
