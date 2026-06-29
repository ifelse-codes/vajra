# Session 26 — Enforce one-session-per-chat (CODE)

## Goal
Make AGENTS.md step 10 / `one_session_per_chat: true` real: block starting vajra-session N+1 in the same chat that closed N. Picked at S25 ground-truth (option B).

## Achieved? — YES
- New `scripts/hook-session-guard.sh` (PreToolUse Bash) records which Claude `session_id` owns each vajra-session (gitignored `.ai/.session-owner`) and **blocks `git checkout -b session-(N+1)-*` from the owning chat** (exit 2).
- Only the N→N+1 boundary blocks; same-session re-checkout, non-session branches, and fresh chats all pass. Maturity-gated (L1 advise / L2-L3 block); gated on `one_session_per_chat: true`. No 8th command, no new dep.

## Evidence
- `scripts/verify-session-26.sh` — **13/13 green** (fresh-allows, same-chat-blocks, new-chat-allows, same-session-reallowed, nonsession-ignored, l1-advises, flag-off-noop, cargo fmt/clippy/test, wiring + gitignore).
- `scripts/demo-session-26.sh` — live: chatA owns 26 → chatA blocked from 27 → chatB allowed.
- Dogfooded: the S21 co-pilot fired on this session's first `git commit` (STATE.md surface).
- [PR #17](https://github.com/ifelse-codes/vajra/pull/17). `cargo test` + clippy clean.

## Decision logged
Scaffold propagation to `vajra init` **deferred to S27** (kept this to 1 story, per prompt). Guard lives in this repo's hooks today; `vajra init` does not yet emit it.

## Cost
~$0.00 (code session, no API calls).

## Next — founder decision (overrides the original A/B/C)

The three options below were drawn from ROADMAP per the loop. **At closeout the founder overrode them:** the second agent's "deferral condition met" was the **S25 audit's** judgment, not the founder's — and the founder is **not yet satisfied with Vajra-on-Claude.** So the second agent is **parked back in the backlog** (owner-gated), and the founder named the real next leap: **Darshan**, the human's glanceable output lane.

- **→ S27 = Darshan** (the human's lane; pairs with Varta — agent talks ↔ user sees). Vajra's default, surface-adaptive, glanceable way of *showing* the human instead of dumping walls of text. Skill, not a renderer. Fixes AI cognitive-overload / burnout. `prompts/27-task-darshan.md`. (memory `vajra-second-agent-gate`)

Original ROADMAP-drawn options, for the record:

### A — Second agent launcher (Codex or Cursor) — **PARKED** (owner-gated on Claude satisfaction)
- Wire a 2nd agent behind `vajra <agent>`; prove ADR-0002 is vendor-neutral. The north-star gap (S25), but the founder gates it on being satisfied with Claude first.

### B — Propagate session-guard into `vajra init`
- Emit `hook-session-guard.sh` + wiring from `vajra init` so every scaffolded repo inherits S26 enforcement (the S22 lesson). Small; may ride with Darshan's propagation (S28).

### C — North-star breadth indicator (S25 meta-finding)
- RED-until-≥2-agents signal in `vajra check`. Cheap, answers the false-green risk; deferred with the second agent.
