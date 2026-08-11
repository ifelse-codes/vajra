# S117 — proving the Plan Advisor dispatches by name

## What S116 left open
S116 shipped the fleet's third role, `plan-advisor`, as a scaffolded `.claude/agents/plan-advisor.md`
and a governed `vajra next --role plan-advisor --from` path — but per the S111 mid-creating-session
limit, the agent file S116 wrote was invisible to S116's own Task tool. The role had never actually
been dispatched by name. This session is the first fresh session after the S116 commit landed on
`main`, so it is the earliest point the wire could be tested.

## Result: resolved by name on the first try — no workaround needed
Exactly the S115 finding (the Fidelity Reviewer, second role), now confirmed on the **third** role.
Dispatching `subagent_type: "plan-advisor"` inside this live S117 session worked immediately — no
`general-purpose` fallback, no restart, no ad-hoc prompt copy.

## The two-file cross-check (mirroring S111's researcher proof)
A single copied `.meta.json` would be trivial to fake by typing the same string by hand. The proof
here is a cross-reference between two files Claude Code itself wrote, in two different locations,
that must independently agree on a random tool-call ID neither Vajra nor this write-up chose:

1. **This session's own transcript** (`87bcd7e1-22ce-4cfb-b4a3-536c21c126e7.jsonl`, extracted verbatim
   into `plan-advisor-parent-tooluse.json`) records the actual tool call:
   ```json
   {"type": "tool_use", "id": "toolu_017CTj78kC3TWjD8E4zKL8s9", "name": "Agent",
    "input": {"description": "Propose plan for --list-roles flag", "subagent_type": "plan-advisor", ...}}
   ```
   — `subagent_type: "plan-advisor"` is the literal parameter Claude Code's own dispatcher resolved,
   at `parent_timestamp: "2026-08-11T12:21:12.949Z"`, on branch `session-117-plan-advisor-dispatch`.

2. **The subagent's own metadata file**, written by Claude Code into a separate `subagents/`
   subdirectory (`plan-advisor-subagent-meta.json`):
   ```json
   {"agentType":"plan-advisor","description":"Propose plan for --list-roles flag",
    "toolUseId":"toolu_017CTj78kC3TWjD8E4zKL8s9","spawnDepth":1}
   ```
   — `toolUseId` here is the **exact same ID** as the parent's tool-call `id` above. Two files, written
   by two different parts of Claude Code's own runtime, independently agree that tool call
   `toolu_017CTj78kC3TWjD8E4zKL8s9` both **requested** `subagent_type: "plan-advisor"` and **resolved
   to** `agentType: "plan-advisor"`.

3. **The full raw subagent transcript** (`plan-advisor-subagent-transcript.jsonl`, copied byte-for-byte,
   sha256 `f877b7353ca9df227004f1852b9cdb57bbf91d2480ee2b8360c931678a5b7cbd`, 26 lines) — the real JSONL
   Claude Code wrote for the subagent's own turn, with its own `uuid`/`sessionId`/`agentId`/`timestamp`
   fields, `isSidechain: true`, and `cwd` matching this repo.

`agentType: "plan-advisor"` and `subagent_type: "plan-advisor"` are the exact `name:` key from
`.claude/agents/plan-advisor.md`'s frontmatter — confirmed by tracing the mechanism, not asserted:
Claude Code's Task tool auto-discovers project-level `.claude/agents/<name>.md` files at session boot
and dispatches them by that `name:` field, same as S111 (Researcher) and S115 (Fidelity Reviewer).

## The task given
A small, real, plan-only task in this repo: propose plan steps for a read-only `vajra next
--list-roles` flag (not yet built — the task's whole point is a plan proposal, not code; per the
prompt's non-goals, this proposal is not implemented this session). Three numbered acceptance
criteria were given; the returned brief (`plan-advisor-brief.md`) cites `covers: N` on every one of
its 8 proposed steps, covering all three criteria, and — correctly, per its own contract — declined
to guess on two real ambiguities (the exact shape of the criterion-1 drift check, and which "existing
verify script" criterion 3 means) rather than silently picking one.

## Governed handoff
The real brief was fed to the existing S109/S112 governance path, unchanged:
```
vajra next --role plan-advisor --from sessions/session-117-artifacts/plan-advisor-brief.md
```
→ `.ai/handoffs/session-117-plan-advisor.md`.

## Finding vs S115's canonical-verdict gotcha
This dispatch is a plan proposal, not a fidelity verdict — the S115 table-wrapped-verdict-line gate
gotcha does not apply here (no `**Verdict:**` line is expected from the Plan Advisor's contract). No
analogous formatting break was found in this role's output: every `covers:` marker landed as the
Planner station's parser (`src/planner/mod.rs::cited_criteria`) actually requires — a bare `covers:`
token followed by a digit list, one per line, no table-wrapping.
