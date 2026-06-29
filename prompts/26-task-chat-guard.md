# Session 26 — Enforce one-session-per-chat (CODE)

> CODE session. Branch `session-26-chat-guard` from `main`. Normal loop (BOOT→…→CLOSE).
> Chosen at S25 ground-truth (option B). S25 verdict: Varta is done; this hardens the *existing* loop while S27+ takes the cross-agent leap (the north-star gap stays #1 on the backlog — do not let this become a detour).

## Why this session
- **Hard Rule today is convention-only:** AGENTS.md step 10 / `CONSTRAINTS.yaml#session.one_session_per_chat: true` say "new vajra-session = new chat," but nothing enforces it. An agent can begin session N+1's BRANCH/PLAN in the same chat that just closed session N. (S23 finding; re-confirmed S25.)
- **The wedge is enforcement, not prompts.** This closes a gap where Vajra currently relies on agent goodwill — exactly the failure mode Vajra exists to fix.

## The mechanism (PLAN-time decision — pick one, ≤2 assumptions)
The signal is the Claude **`session_id`** (already available in hook payloads — the co-pilot loader keys its debounce on it). Record which chat "owns" the current vajra-session; refuse cross-session work from a *different state* than expected. Two candidate enforcement points:

| Option | Fires when | Note |
|---|---|---|
| **A — guard `vajra next --advance`** | agent advances N→N+1 | record the advancing chat's `session_id`; a fresh `.ai/` field (e.g. `session_owner`) stores it. Block if the same chat then tries session N+1 BRANCH work. |
| **B — PreToolUse hook on branch creation** | `git checkout -b session-NN-*` | hook reads the recorded owner `session_id` for the *current* `.ai/SESSION`; if the new branch's NN was opened by the same chat that closed NN-1, block with "open a new chat first." |

Recommend a **hook-based block** (consistent with `hook-copilot-loader.sh` / `hook-pre-bash.sh`; maturity-gated L1 advise / L2-L3 exit 2) reading/writing a small owner record. Keep it bash + hand-parsed (no new deps — honors S19/S21). The Rust side (if any) stays minimal.

## Constraints / guardrails
- **Max 7 commands** — do NOT add an 8th. Ride existing surfaces (a hook + maybe a field in `next`/`check`).
- **≤3 files per atomic commit**, max 1 story. Likely files: a new/edited `scripts/hook-*.sh`, `.ai/CONSTRAINTS.yaml` (or a state file), and wiring (`.claude/settings.json` and/or `src/cli/*`). If it exceeds 1 story, split (guard-only this session; scaffold-propagation next).
- **Scaffold propagation:** whatever enforces here must also be emitted by `vajra init` (the S22 lesson — don't enforce only in this repo). If propagation pushes past 1 story, defer it to S27 and say so in PLAN.
- **Maturity-gated:** L1 advises (exit 0), L2/L3 block (exit 2) — same pattern as every other Vajra hook.
- **Debounce / false-positive care:** must not block legitimate same-chat work *within* one session (only the N→N+1 boundary). Define "owns this session" precisely before coding.

## Definition of done
- A real same-chat attempt to start the next session is **blocked** (demoed live, like S21's `git commit` block).
- `scripts/verify-session-26.sh` exits 0; demo script shows the block + the allowed cross-chat path.
- `cargo test` green; clippy clean.
- Decide + document: does this also propagate into `vajra init` now, or is that S27?

## Output
- Working enforcement + verify/demo + `sessions/session-26-summary.md` ending in exactly 3 S27 candidates — **at least one must be the second agent launcher** (the north-star gap S25 flagged as #1).

## Carry-forwards from S25 ground-truth
- **North-star gap is still #1:** second agent launcher (Codex/Cursor) — must lead the S27 options.
- **False-green risk (S25 meta):** consider whether a "north-star gap" indicator (RED until ≥2 agents) belongs on the S27 menu.
- **Recurring low drift:** STATE.md writes PR status as "pending merge" before the merge (flagged S15/S20/S25). Fix opportunistically at closeout (write "open (merge after closeout)" instead).
- **Resolve at closeout:** retire "grammar frozen at 9 (provisional)" → validated by S24 render. `vajra estimate` 3:1 ratio still unvalidated (carry).
