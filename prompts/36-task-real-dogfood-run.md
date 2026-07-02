# Session 36 — Real Dogfood Run (default pick: option A from S35 GT)

> Pre-authored per `must_write_next_prompt_before_close`. This is the S35 GT's
> **recommended** option (A). If the founder picks B or C instead at session start,
> write a fresh prompt for that option before branching — do not force this one.

## Why this, not the second agent or a code fix
S35 ground truth (`sessions/session-35-ground-truth.md`) found the second-agent gate still
**unmeasured**: zero `vajra claude` spend since S31, so the S32–S34 fixes (Darshan enforcement,
compression schema, brownfield onboarding) are test-verified but not daily-use-verified. Every
other candidate (`.claude/settings.json` merge, `exit_code` heuristic) is speculative until
someone actually sits inside a live session and feels whether the fixes hold.

## Scope (1 story)
1. Run `vajra claude` on a real task in a real repo (brownfield, not a toy fixture) —
   full multi-turn session, not a `--version`/smoke check.
2. Observe, don't just log: does Darshan actually surface at boot and get followed? Does
   compression actually fold real tool output? Does onboarding/auth actually feel guided?
3. Capture the receipt (cost + savings) — this directly feeds the next `dogfood_check`.
4. Record findings honestly, including a 4th core breakage if one surfaces — that's the
   point of dogfooding, not a failure of the session.

## Guardrails
- Branch `session-36-real-dogfood-run` from `main`.
- Max 2 assumptions, max 2 retries, ≤3 files per commit, ~2h cap — standard constitution rules
  (this is a CODE-adjacent session: real usage + findings write-up, not necessarily a feature).
- If findings demand a code fix, that's a *separate* future session (1-story rule) unless the
  fix is trivial and squarely in-scope.

## Output
- `sessions/session-36-summary.md` (or a dogfood-specific report) — what was run, what worked,
  what didn't, updated cost ledger entry.
- `.ai/STATE.md` "What Currently Works" gets real (not test-only) confirmation language for
  whichever of S32/S33/S34 held up.
- Re-ask the second-agent gate explicitly: cleared, still unmeasured, or newly blocked.
