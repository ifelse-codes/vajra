# S126 — the last five roles, each dispatched BY NAME from a fresh session

## Method, and why it is a fresh session
S111 established the harness limit this evidence has to work around: Claude Code resolves
`.claude/agents/*.md` into available subagent types **once, at session boot**, so a role file
written mid-conversation is invisible to that same conversation's Task tool. S116's roles could
only be dispatched at S117, one session later.

This session did not wait. After the five role definitions were committed, each role was
dispatched from a **separate, headless `claude -p` process** started from the command line — a
brand-new session with its own session id, which boots and reads `.claude/agents/` from scratch.
That is the same session boundary S111 crossed with a new terminal, taken five times.

Each parent was told to dispatch the role BY NAME and to do no work itself
(`--allowedTools "Agent,Read,Grep,Glob"`), then to relay the subagent's brief verbatim.

## The two-file cross-check (S111), re-run for each of the five
A single copied `.meta.json` is trivially hand-typed. The proof is a cross-reference between two
files Claude Code itself wrote in two different places, which must agree on a random tool-call id
that neither Vajra nor this note chose: the **parent session's own transcript** records
`{"type":"tool_use","name":"Agent","input":{"subagent_type":"<role>"}}` with an `id`, and the
**subagent's own `meta.json`**, written into a separate `subagents/` directory, records
`{"agentType":"<role>","toolUseId":"<the same id>"}`. The third file is the subagent's raw
transcript, required to carry a real assistant `usage` line so a stub cannot pass.

`sessions/session-126-artifacts/dispatch/harvest.py` performs the check and FAILS closed on any
mismatch; `scripts/verify-session-126.sh` re-runs it over all five at verification time.

## The five dispatches, verbatim from the harvested files

| role | `subagent_type` requested | `agentType` resolved | shared tool-call id | parent session | subagent transcript |
|---|---|---|---|---|---|
| `requirements-analyst` | `requirements-analyst` | `requirements-analyst` | `toolu_01SfgRfiAhabAdGMAYcPkMfB` | `1168e5a5-ad73-4b3a-a46e-cb5f0f9944fe` | `2175aca8c826262e…` (32 lines) |
| `design-advisor` | `design-advisor` | `design-advisor` | `toolu_01F1yrota4N93FNBPJDPgKTa` | `046e9d26-7ab6-40f6-8955-76a36225b1ec` | `cf0212dac32fda65…` (34 lines) |
| `implementation-advisor` | `implementation-advisor` | `implementation-advisor` | `toolu_012UNWMhHGnE1ADFWHcEtt8b` | `5a275ec4-111a-4aec-9f1c-3db93a2454ce` | `1e1f40c5b84c7a5b…` (17 lines) |
| `demo-producer` | `demo-producer` | `demo-producer` | `toolu_01CqTSrCttnAy1asrpV7ECtb` | `01223128-b9a6-47b4-8faf-b434a8ab50ca` | `01d1a8678e878d8e…` (25 lines) |
| `release-coordinator` | `release-coordinator` | `release-coordinator` | `toolu_01TW1uiDPzVcJKStip3G8iMk` | `3464dd78-d7e2-4205-a52c-2c9fdc557f05` | `08ef1a11bf728dd8…` (36 lines) |

Timestamps, as recorded by the parent sessions:

- `requirements-analyst` — 2026-08-21T11:18:21.219Z, cwd `/Users/suman/playground/vajra`, run cost `$1.0489`
- `design-advisor` — 2026-08-21T11:20:17.059Z, cwd `/Users/suman/playground/vajra`, run cost `$0.7662`
- `implementation-advisor` — 2026-08-21T11:22:25.450Z, cwd `/Users/suman/playground/vajra`, run cost `$0.9156`
- `demo-producer` — 2026-08-21T11:15:28.098Z, cwd `/Users/suman/playground/vajra`, run cost `$0.9932`
- `release-coordinator` — 2026-08-21T11:24:14.953Z, cwd `/Users/suman/playground/vajra`, run cost `$0.7243`

**Total metered cost of the five dispatches: `$4.4482`** (each figure is the headless run's own `total_cost_usd`, the authoritative source S78 wired up — not a token estimate).

## What this proves, and what it does not
**Proves:** every one of the five new roles is resolvable and dispatchable by its registered
`name:` from a fresh session — the wire from `fleet::ROLES` → `vajra init` → a rendered
`.claude/agents/<name>.md` → Claude Code's own dispatcher is closed for all five, at n=5 in one
session rather than one per session.

**Does not prove:** that the briefs are good, that anything depends on them, or that a real
session would reach for these roles unprompted. Each parent was *told* to dispatch by name. Per
S124, a dispatched agent's own report is not evidence — that is exactly why the evidence here is
the runtime's two files agreeing on an id, and not any agent's account of what it did.

The five briefs were landed as governed handoffs through the unchanged S109 path
(`vajra next --role <name> --from <brief>`), and `vajra next --stations 126` still reports the
same `K of 8` with all five present.
