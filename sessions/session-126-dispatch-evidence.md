# S126 — dispatch evidence record (the five roles, each dispatched BY NAME)

> **Why this file exists, and what it replaced.** The raw runtime evidence — five subagent
> transcripts and five headless run results, ~810 KB of Claude-Code-written JSONL — was committed
> at first and then **removed from git at the founder's call**: session artifacts do not belong in
> the repo. This record is what git carries instead: every field the cross-check reads, derived
> from those files before they were untracked, plus a `sha256` of each raw file so a local copy can
> still be matched against what was recorded here.
>
> **Say plainly what that costs.** A clean clone can no longer re-derive these ids from the
> runtime's own files; it can only check this record. That loss is smaller than it sounds, and the
> S126 cold review is the reason: it named this cross-check the session's **fakest green** because
> it always proved *internal consistency, not provenance* — the committed copies were never bound
> to the originals under `~/.claude/projects/`. Binding evidence to the runtime is S127's
> candidate B. Until that exists, this record is a record, not a proof.

## Method — and why five headless runs are five fresh sessions

S111 established the harness limit: Claude Code resolves `.claude/agents/*.md` into available
subagent types **once, at session boot**, so a role file written mid-conversation is invisible to
that same conversation. S116's roles could only be dispatched at S117, a session later.

S126 did not wait. After the five role definitions were committed, each role was dispatched from a
**separate headless `claude -p` process** — a brand-new session with its own id, which boots and
reads `.claude/agents/` from scratch. That is the S111 session boundary, crossed five times in one
session. Each parent was told to dispatch the role BY NAME and do no work itself
(`--allowedTools "Agent,Read,Grep,Glob"`), then relay the subagent's brief verbatim; the five
briefs were landed as governed handoffs through the unchanged S109 path
(`vajra next --role <name> --from <brief>`).

## The two-file cross-check (S111), as recorded

For each role, two files Claude Code itself wrote — the parent session's transcript and the
subagent's own `meta.json`, in two different directories — agreed on the same random tool-call id:
the parent **requested** `subagent_type: <role>` and the subagent **resolved to**
`agentType: <role>` on that id.

| role | requested | resolved | shared tool-call id | parent session | transcript |
|---|---|---|---|---|---|
| `requirements-analyst` | `requirements-analyst` | `requirements-analyst` | `toolu_01SfgRfiAhabAdGMAYcPkMfB` | `1168e5a5-ad73-4b3a-a46e-cb5f0f9944fe` | `2175aca8c826262e…` (32 lines) |
| `design-advisor` | `design-advisor` | `design-advisor` | `toolu_01F1yrota4N93FNBPJDPgKTa` | `046e9d26-7ab6-40f6-8955-76a36225b1ec` | `cf0212dac32fda65…` (34 lines) |
| `implementation-advisor` | `implementation-advisor` | `implementation-advisor` | `toolu_012UNWMhHGnE1ADFWHcEtt8b` | `5a275ec4-111a-4aec-9f1c-3db93a2454ce` | `1e1f40c5b84c7a5b…` (17 lines) |
| `demo-producer` | `demo-producer` | `demo-producer` | `toolu_01CqTSrCttnAy1asrpV7ECtb` | `01223128-b9a6-47b4-8faf-b434a8ab50ca` | `01d1a8678e878d8e…` (25 lines) |
| `release-coordinator` | `release-coordinator` | `release-coordinator` | `toolu_01TW1uiDPzVcJKStip3G8iMk` | `3464dd78-d7e2-4205-a52c-2c9fdc557f05` | `08ef1a11bf728dd8…` (36 lines) |

**Total metered cost of the five dispatches: `$4.4482`** — each figure is the headless run's own `total_cost_usd`, the authoritative source (S78), never a token estimate.

## The machine-readable record (what `verify-session-126.sh` parses)

```json
{
  "session": 126,
  "dispatches": [
    {
      "role": "requirements-analyst",
      "subagent_type_requested": "requirements-analyst",
      "agent_type_resolved": "requirements-analyst",
      "tool_use_id": "toolu_01SfgRfiAhabAdGMAYcPkMfB",
      "meta_tool_use_id": "toolu_01SfgRfiAhabAdGMAYcPkMfB",
      "parent_session_id": "1168e5a5-ad73-4b3a-a46e-cb5f0f9944fe",
      "parent_timestamp": "2026-08-21T11:18:21.219Z",
      "transcript_sha256": "2175aca8c826262e219a68b2307803f35fbdc7bffbf2e0a0bac25ea9b121bf30",
      "transcript_lines": 32,
      "run_cost_usd": 1.048901,
      "brief_sha256": "d769b9dd80633064e7531950c9aa6d8d020491f874585a8eda6928d8ee7a638b",
      "handoff": ".ai/handoffs/session-126-requirements-analyst.md"
    },
    {
      "role": "design-advisor",
      "subagent_type_requested": "design-advisor",
      "agent_type_resolved": "design-advisor",
      "tool_use_id": "toolu_01F1yrota4N93FNBPJDPgKTa",
      "meta_tool_use_id": "toolu_01F1yrota4N93FNBPJDPgKTa",
      "parent_session_id": "046e9d26-7ab6-40f6-8955-76a36225b1ec",
      "parent_timestamp": "2026-08-21T11:20:17.059Z",
      "transcript_sha256": "cf0212dac32fda65b4b9bd95bbf1e14a84b64696c7fd078ec1cc7967f2cdd39a",
      "transcript_lines": 34,
      "run_cost_usd": 0.7662328,
      "brief_sha256": "9a784d8aef38a90f65df764fc8487b3cbf873b05c8ae44d65e33384e982f6722",
      "handoff": ".ai/handoffs/session-126-design-advisor.md"
    },
    {
      "role": "implementation-advisor",
      "subagent_type_requested": "implementation-advisor",
      "agent_type_resolved": "implementation-advisor",
      "tool_use_id": "toolu_012UNWMhHGnE1ADFWHcEtt8b",
      "meta_tool_use_id": "toolu_012UNWMhHGnE1ADFWHcEtt8b",
      "parent_session_id": "5a275ec4-111a-4aec-9f1c-3db93a2454ce",
      "parent_timestamp": "2026-08-21T11:22:25.450Z",
      "transcript_sha256": "1e1f40c5b84c7a5bde066ade21acf7e89b99fe8e8afe37f15925def62c98e7ae",
      "transcript_lines": 17,
      "run_cost_usd": 0.915599,
      "brief_sha256": "917a5da7cd8867374cdc347fd8157d835f93481cc4be15527facb13d0d741fdf",
      "handoff": ".ai/handoffs/session-126-implementation-advisor.md"
    },
    {
      "role": "demo-producer",
      "subagent_type_requested": "demo-producer",
      "agent_type_resolved": "demo-producer",
      "tool_use_id": "toolu_01CqTSrCttnAy1asrpV7ECtb",
      "meta_tool_use_id": "toolu_01CqTSrCttnAy1asrpV7ECtb",
      "parent_session_id": "01223128-b9a6-47b4-8faf-b434a8ab50ca",
      "parent_timestamp": "2026-08-21T11:15:28.098Z",
      "transcript_sha256": "01d1a8678e878d8e988a91613c89f8b1db4d4f7abf65119e308a6eeec580c56c",
      "transcript_lines": 25,
      "run_cost_usd": 0.9931572,
      "brief_sha256": "e4802cbf55835afbcf7b1d06621a2ea6cd249feb6ef8d68abb802738378b2762",
      "handoff": ".ai/handoffs/session-126-demo-producer.md"
    },
    {
      "role": "release-coordinator",
      "subagent_type_requested": "release-coordinator",
      "agent_type_resolved": "release-coordinator",
      "tool_use_id": "toolu_01TW1uiDPzVcJKStip3G8iMk",
      "meta_tool_use_id": "toolu_01TW1uiDPzVcJKStip3G8iMk",
      "parent_session_id": "3464dd78-d7e2-4205-a52c-2c9fdc557f05",
      "parent_timestamp": "2026-08-21T11:24:14.953Z",
      "transcript_sha256": "08ef1a11bf728dd8fa930fcb18ba7f444ca79595e63940d398989f866f2705f2",
      "transcript_lines": 36,
      "run_cost_usd": 0.7243063,
      "brief_sha256": "4b30914a70f79e0e04667652c9353ba28d0c83a85eda1207a8fe999c8cc67005",
      "handoff": ".ai/handoffs/session-126-release-coordinator.md"
    }
  ],
  "total_cost_usd": 4.4481962
}
```

## What this record proves, and what it does not

**Proves (as a record):** each of the five roles was dispatched by its registered `name:` from a
fresh session, with the runtime's two files agreeing on an id neither Vajra nor the session chose,
and each dispatch's real metered cost.

**Does not prove:** that anything depends on these roles, that a session would reach for one
unprompted, or — since the raw files are no longer in git — that this record was derived from them
rather than written. Per S124, a dispatched agent's own report is never the evidence; per the S126
cold review, neither is a copy checking itself.

