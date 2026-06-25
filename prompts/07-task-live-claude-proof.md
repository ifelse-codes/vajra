# Session 07 — Live `vajra claude` Proof

## Trigger
User picked Option A from `sessions/session-06-summary.md`.

## Goal
Run a real Claude Code session through `vajra claude`, prove or falsify that `claude --settings` behaves additively with Vajra's injected hook, and harden the product only if the evidence demands it.

## Deliverables
- Real-session evidence that shows whether `vajra claude` works as claimed.
- A documented conclusion in `sessions/session-06-summary.md`: confirmed, falsified, or partially confirmed.
- If a real gap is found, the smallest code/test/doc fix needed to address it.
- Updated README / `.ai/` state if the evidence changes what we can honestly claim.

## Evidence To Capture
- Exact command used to launch Claude through Vajra.
- Whether existing Claude settings/hooks still work.
- Whether Vajra hook injection is active.
- Whether compression / receipt behavior appears in a real session.
- Any error, warning, or mismatch between docs and actual behavior.

## Constraints Operative
- Evidence first. Do not patch speculatively.
- Keep scope on real-session proof for `vajra claude`.
- Max 2 assumptions. Max 2 retries.
- If auth / permission prompts block automation, record the blocker exactly.

## Exit Criteria
- Real-session proof captured.
- Additive `--settings` behavior conclusion written down.
- If code changed: `cargo test`, `cargo clippy`, and session verify pass.
- Exactly 3 Session 08 options presented.

## Explicit Non-Goals
- Installer / release path
- Making `vajra next` advance the workflow
- Multi-agent launchers
