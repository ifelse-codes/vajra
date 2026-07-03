# Session 39 — Harden the guards (publish-guard over-block + session-boundary arming)

**Type:** CODE · **Branch:** `session-39-harden-guards` · **Date:** 2026-07-03
**Owner override:** two stories in one session (deliberate `max 1 story` override), ordered B→A so B banks first.

## Goal achieved? — YES (both stories)

Make the enforcement moat *correct*, not just present. S37 shipped the publish-guard, S38 propagated it; building S38 surfaced a live over-block bug (B) and the S36 root-cause boundary gap (A) was still open. Both fixed.

### Story B — publish-guard no longer over-blocks
- **Bug:** `hook-publish-guard.sh` classified against the *entire* command string, so a trigger phrase inside a message/arg (`git commit -m "…git push…"`, `echo "gh pr create"`, `--body`) false-blocked even when nothing published. Hit live in S38 (worked around with `git commit -F`).
- **Fix:** strip quoted spans (`'…'`, `"…"`) before classifying. Real invocations place the command name **outside** quotes, so this never hides a genuine push/PR — fail-safe (over-block > leak). Unbalanced quotes/heredocs leave text in place → over-block, the safe direction.
- **Commit:** `08c1cfe` (2 files: hook + verify).

### Story A — session-guard arms on advance, not just `checkout -b`
- **Gap (S36 root cause):** the guard armed only on `git checkout -b session-(N+1)`. The S36 brownfield agent advanced 00→01 **without ever branching**, so nothing armed and it ran two vajra-sessions in one chat, unstopped.
- **Fix:** also fire on `vajra next --advance` — Vajra's one sanctioned advance command. It bumps `.ai/SESSION` via Rust `fs::write` (invisible to a Bash hook as a file write), so the invocation is the observable common-denominator signal; target session = current `.ai/SESSION` + 1, reusing the same same-chat N→N+1 ownership block. Also quote-strips (the B lesson) so the phrase in a message can't false-arm.
- **Bounded:** raw manual `echo N > .ai/SESSION` stays out of scope (git-level pre-commit follow-on) — fail-safe: unrecognised advances simply don't arm. No `src/` change (`--advance` already exists).
- **Commit:** `c87d302` (2 files: hook + verify).

## Evidence
- `scripts/verify-session-39.sh`: **37/37 GREEN** — B now-pass (5) + B zero-regression block (8) + B approval/advise (3) + A advance-block/fresh-pass/L1-advise/non-arm (7) + A checkout no-regression (3) + byte-identical scaffold cmp (both hooks) + Rust gates (fmt/clippy/test) + shellcheck.
- `cargo test` green — the existing scaffold **drift** unit tests confirm both hooks stay byte-identical inside `vajra init` after the edits.
- **3 files** changed vs `main` (2 hooks + verify); each commit ≤3 files, B before A.
- PR: **pending — founder pushes** (`VAJRA_ALLOW_PUBLISH` unset → the guard blocks the agent, by design). Push: `VAJRA_ALLOW_PUBLISH=1` then `git push -u origin session-39-harden-guards` + open PR to `main`.

## Residual limits (recorded, not fixed)
- Publish-guard: heredoc-body phrase still over-blocks (fail-safe); jq-missing → fail-open; obfuscated `g=push; git $g` evades; one env var authorizes the whole launch (coarse).
- Session-guard: raw `echo > .ai/SESSION` bypass (out of A's bounded scope) → belongs to the git-level pre-commit belt.

## Next session — S40 is MANDATORY NO-CODE ground-truth (every 5th; last = S35)
Pick the ground-truth **lens** (S40 runs every `required_audits` regardless; the lens sets the sharp question):

- **A — Enforcement-completeness lens.** *Goal:* now that S37→S39 closed, propagated, and corrected the guards, is the moat actually complete or are the remaining gaps (git-level pre-commit belt, jq fail-open, per-launch approval) real leaks? *Why pick:* three sessions of guard work — verify it converged. *Key risk:* auditing rule-plumbing while the vision drifts (the S20 trap) — must meta-check.
- **B — Dogfood-gate lens.** *Goal:* re-measure the second-agent gate — has real `vajra claude` run since S36? (~$0 spend since; guards are test-verified, not live-verified against a real agent.) *Why pick:* the gate is unmeasured by definition until a real run; the cost ledger is the proof. *Key risk:* no paid run this cycle → verdict stays "unmeasured," same honest call as S30/S35.
- **C — Direction/north-star lens.** *Goal:* S37–S39 were all enforcement plumbing — is that still the shortest path to the north-star (`vajra next` as cross-agent coach), or fun scope creep while compression stays dead and only Claude is wired? *Why pick:* force the "are we building the right thing" question before S41. *Key risk:* re-litigating settled direction; must tie to concrete roadmap re-rank, not vibes.
