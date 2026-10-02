# Session 183 — rudra session 16 under the new rules: use S181/S182's controls for real, fix what breaks

> **Status:** DRAFT — written by the S182 agent as summary option 1 (recommended). The founder had not picked when it was written. He approves it with `vajra approve 183` in his own terminal, or picks option 2/3 and this file is rewritten. The gate reads the approval record, not this line.

## Type
session_type: INTERACTIVE
- **INTERACTIVE** (gets the CODE checks). Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The founder runs rudra S16 himself under `vajra claude` and brings what happened; this session lists the findings with him and fixes what he says yes to (the S171–S179 loop).

## Why this session
S181 made the founder's controls hard for the agent to type, and S182 shipped them into rudra. Nothing has used them in real work yet. rudra S16 is the first session to start at or after rudra's `session_rules_from: 16`.

## Before rudra S16 starts (founder, in order)
1. Merge S182's PR, then rebuild the installed Vajra so it carries S182: `cargo install --path .` in `~/playground/vajra` (the installed copy is pre-S182 — it has no `--allow-all=NN` and its `--sync-fleet` does not wire settings).
2. In rudra: commit the 6 uncommitted files S182 left (5 Vajra files + `.ai/CONSTRAINTS.yaml` with the F93 edit and `session_rules_from: 16`) as S16's first commit, on S16's branch.
3. In rudra: prune the three merged local branches (`session-14-ordering-witness`, `session-15-ground-truth`, `session-15-ground-truth-closeout`) — the release check counts them.
4. Approve rudra S16 from his own terminal: `vajra approve 16` (or launch with `VAJRA_APPROVE=16` / `vajra claude --allow-all=16`). rudra's prompt: `prompts/16-task-measure-an-edge.md`.

## What to watch in rudra S16
Read every close log for `WAIVED` and `N/A` FIRST, never just PASS (S178).
- **Approval:** did the analyst gate read the record, and refuse the brief's own `Status:` words? Did the agent try to write the approvals folder, and did the block message reach it (stderr, S182)?
- **False blocks:** any read or ordinary command the approvals guard blocked (it still blocks a command that names the folder AND redirects anywhere, and commit-message text that names it).
- **Waivers:** if the founder waived, was it `VAJRA_WAIVE=<check>` + a reason, logged launch-time or set-later? Any `VAJRA_CLOSEOUT_WAIVER=N` use (still works, loudly)?
- **Stamps:** any `verified:` stamp refused as "changed after it was captured"? Was it a real edit or a false refusal?
- **`session_type:`** on rudra's S16 brief — present and strict, or the dated legacy fallback?
- **Time + cost** (the receipt is still F67-overstated ~5× for Opus 5.5; note the real figure if the founder has it).

## Finding already recorded (founder yes, 2026-10-01)
- **F101 — the close check never runs clippy the way CI does.** S182 closed 24/24 green on its branch, then CI on PR #219 failed `cargo clippy --all-targets -- -D warnings` (clippy 1.99, `useless_format` in `tests/approvals_guard.rs`). The local toolchain was older and the close gate only runs `cargo fmt --check`, so a branch can close "done" and still fail CI. That cost a fix, a re-attestation and a second push after close. Fix: the close gate (and the scaffold's) runs the same lint command CI runs, and names the toolchain it used. Test: a fixture with a lint error must fail the close check.

## Carried in
1. **S182 pass-2 recs 1, 2, 5** — parked to backlog for the S185 ground truth (the S182 row of `.ai/ROADMAP.md`): `..` path segments past the guard and its overclaiming comment; the whole-group append with no same-matcher group (`src/cli/init.rs:980`); write commands the word list misses. Fix only if rudra S16 actually hits one.
2. **Parked by the founder:** F67 (receipt ~5×, wants the permanent fix), non-Claude tools (F91, F94, F95), release/publish.
3. **Next ground truth: S185** (derived, `scripts/lib-ground-truth.sh`).

## Deliverables
1. F101 fixed (above), and a findings list from rudra S16 (`F102…`), each with evidence (log line, file, commit) and the founder's call (fix / park / not a problem).
2. Fixes for every finding the founder says yes to, each with a test that fails without it.

## Acceptance
1. Every finding has evidence and a founder call recorded in the summary.
2. Every fix has a real-run check in `scripts/verify-session-183.sh` (no source greps) that fails without it.
3. No Vajra commit touches rudra; rudra's own commits are the founder's.
4. `verify-closeout.sh` exits 0 on the branch before merge; one fresh cold review at close.

## Design
design-significant: yes

Cites `docs/decisions/DECISION-011-controls-the-agent-cannot-type.md` — its S183 addendum records this design (a project switch is one strict field in `.ai/CONSTRAINTS.yaml`, never worked out from text). Design-advisor handoff: `.ai/handoffs/session-183-design-advisor.md` (F101 only; a rudra S16 finding that needs design gets its own addendum).

- **F101, Vajra's own gate — one toolchain, written once.** `rust-toolchain.toml` pins `1.99.0`; CI and Release run `rustup toolchain install`, which reads it. `scripts/ci-lint.sh` is the one lint command CI and the close gate's `cargo-clippy-clean` both run; it names the toolchain and FAILS when the running rustc is not the pinned one. Adding the clippy command alone would have passed S182 on its older clippy.
- **F101, a project's gate — the project names its lint.** `lint_command:` in `.ai/CONSTRAINTS.yaml`: set → run, FAIL on non-zero; `none` → N/A; missing → a WARN row in the table. Never guessed from CI files (S177).
- **Fakest green:** the agent can type `lint_command: true` or `none`; "matches CI" means "matches the pinned version", not today's stable; `#[allow]` still silences any lint. Release's toolchain step runs only on a tag — not checked live.

## Plan
_(written with the plan-advisor after the findings are listed; every step cites `covers: N`.)_

## Execution
_(step N — done: <sha> as work lands.)_

## Guardrails
- No autonomous commits: the founder runs them (one throwaway script per batch), or launches with `VAJRA_ALLOW_COMMIT=183`.
- ≤3 files per commit; ≤2 assumptions; ≤2 retries. Guard changes only add (S173). No new ceremony; nothing that polices Vajra's own paperwork (2026-09-15).
- Answer a founder "why" with evidence; propose a fix only if he calls it a problem (S176).

## Delta
- `+` F101 (close gate runs CI's clippy); findings F102… from rudra S16 and the fixes the founder approves
- `~` whatever the findings touch
- `-` nothing planned
