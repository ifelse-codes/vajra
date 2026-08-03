# Session 111 — closing the fleet's def-vs-dispatch wire

**Type:** CODE (evidence + documentation, no dispatch-path code change) · **Branch:**
`session-111-fleet-dispatch-wire` · **Date:** 2026-08-03 · **Founder pick A at S110 GT.**

## Goal — achieved?

**YES.** S109 proved two facts separately: (1) `vajra init` scaffolds `.claude/agents/researcher.md`,
and (2) a real subagent ran. Nothing proved the live dispatch actually *reads that file by name*. S111
proves it, on disk, and discloses a real structural finding along the way.

## What actually happened (plain English)

1. Inside this live build session, `.claude/agents/researcher.md` was scaffolded (the compiled
   `vajra` binary's own renderer, not hand-typed) and dispatch was attempted immediately by name.
   **It failed** — Claude Code only scans `.claude/agents/` once, at session start; a file written
   mid-conversation is invisible to that same conversation. Real finding, not a bug in the approach.
2. A pristine scratch repo was scaffolded with `vajra init` (clean: 28 created, 0 collisions). The
   founder opened a **new terminal**, ran the real launcher (`vajra claude`) there, and asked it to
   use the researcher subagent. It worked: `⏺ researcher(Research Rust anyhow crate)`.
3. **The proof isn't the transcript text — it's the file Claude Code itself wrote.** Its own
   `agent-<id>.meta.json` for that run records `"agentType":"researcher"` — the exact `name:` key
   from the scaffolded file's frontmatter. That is the mechanism, confirmed: Claude Code auto-discovers
   project-level `.claude/agents/<name>.md` at session start and dispatches by that name.
4. The real brief (`anyhow` findings) was governed into `.ai/handoffs/session-111-researcher.md` via
   the unchanged S109 path (`vajra next --role researcher --from`).
5. Cost: grepped **49 real subagent JSONL transcripts** across every local project (this session's own
   dispatch included) for `total_cost_usd`/`cost_usd`. **Zero of 49 carry either key.** A subagent
   never produces the headless `-p` result stream that field lives on. `cost_usd: null` stays, now
   for a checked, specific, falsifiable reason — cited directly in `src/fleet/mod.rs`'s doc-comment.

## Fidelity map

| # | Requirement | Status | Evidence |
|---|---|---|---|
| 1 | Live dispatch demonstrably reads the scaffolded file by name, mechanism cited | **SHIPPED** | `sessions/session-111-artifacts/researcher-subagent-meta.json` (`agentType:"researcher"`, Claude Code's own record); `DECISION-007` S111 addendum |
| 2 | Real subagent run proves it; fail-closed smoke still holds | **SHIPPED** | Live `vajra claude` run (founder-run, real); `fleet-smoke.sh` 7/7 unchanged |
| 3 | Cost itemized or `null` kept with a checked reason | **SHIPPED (kept null, checked)** | 49/49 subagent JSONL files sampled, zero carry a cost key; cited in `src/fleet/mod.rs` and `verify-session-111.sh` |
| 4 | `cargo test --lib` green; CI both OS; verify + demo scripts green | **SHIPPED (CI pending)** | 304 lib tests, fmt+clippy clean; `verify-session-111.sh` 8/8; `demo-session-111.sh` exit 0, 4 markers |
| 5 | Independent cold review | **SHIPPED** | `sessions/session-111-review.md` |

## What I did NOT build (stated plainly)

- **No dispatch-path code change.** S109's scaffold + governance code was already correct; what was
  missing was the proof. This session ships evidence + a doc-comment/decision update, not new runtime
  logic.
- **No automated same-session re-proof.** The fresh-session step needs a real human-run `vajra claude`
  session (a founder action) — it cannot be scripted headlessly without an unattended `claude -p` +
  `ANTHROPIC_API_KEY` mode, which stays DECISION-007-deferred.
- **No downstream handoff-consumption, no second role** — both still deferred per S110.

## Fakest green (disclosed)

The fresh-session proof is **real but not re-runnable by CI** — it depended on the founder manually
opening a terminal and typing a prompt. `verify-session-111.sh` checks that the *evidence* (the meta.json,
the run note, the handoff) is present and internally consistent, and re-runs everything that CAN run
headlessly (build/test/fmt/clippy, fleet-smoke). It cannot re-prove the dispatch itself on every CI run
— that would need the deferred unattended mode. This is disclosed, not hidden.

## Evidence index

- Code (doc-only): `src/fleet/mod.rs` (cost doc-comment).
- Design: `docs/decisions/DECISION-007-agent-fleet.md` (S111 addendum).
- Live proof: `sessions/session-111-artifacts/` (run note, subagent brief, subagent meta.json).
- Governed handoff: `.ai/handoffs/session-111-researcher.md`.
- Gates: `scripts/verify-session-111.sh`, `scripts/demo-session-111.sh` (fleet-smoke.sh unchanged).

## Next — candidate for S112

S110's deferred backlog stands: **B — downstream handoff-consumption** (nothing reads
`.ai/handoffs/session-NN-researcher.md` automatically yet) or **C — a second fleet role**. Both were
explicitly parked until the dispatch wire was proven; it now is. Recommend **B** next: a lone handoff
nobody reads is still an orphan artifact, and it's cheaper to fix before a second role doubles the
orphan count.
