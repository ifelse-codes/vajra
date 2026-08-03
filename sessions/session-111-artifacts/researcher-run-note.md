# S111 — the def-vs-dispatch wire, closed with on-disk evidence

## What S109/S110 flagged
`vajra init` scaffolds `.claude/agents/researcher.md`, and a real subagent ran in S109 — but the
S109 subagent was dispatched by the orchestrator handing the Task tool a hand-typed copy of the
canonical role prompt, **not** by the Task tool resolving `subagent_type: "researcher"` against the
scaffolded file. Two facts, proven separately. This session closes that gap with a real, falsifiable,
on-disk proof.

## Step 1 — same-session negative result (a real finding, not a workaround)
Inside the *live* S111 build session, `.claude/agents/researcher.md` was scaffolded (via the compiled
`vajra` binary's own `fleet::render_subagent_definition`, not hand-typed) directly into the
already-running repo, then dispatch was attempted immediately with `subagent_type: "researcher"`.
It failed:
```
Agent type 'researcher' not found. Available agents: claude, claude-code-guide, Explore,
general-purpose, Plan, statusline-setup
```
**Why:** Claude Code resolves `.claude/agents/*.md` into available subagent types once, at session
boot — a file written mid-conversation is invisible to that same conversation's Task tool until a
new session starts. This is a real constraint of the harness, not a bug in the scaffold. It means the
wire can only be proven end-to-end **across a session boundary**, matching how a real Vajra user would
actually experience it (they scaffold with `vajra init`, then start a session with `vajra claude`).

## Step 2 — fresh-session positive proof (the headline evidence)
A pristine scratch repo was scaffolded with `vajra init` (clean — 28 files created, 0 merged/skipped
collisions, unlike running `init` against an already-initialized repo). The founder then opened a
**brand-new terminal**, ran the real launcher — `vajra claude` — inside that scratch repo, and asked
it to "use the researcher subagent" to look up what Rust's `anyhow` crate is for.

Live transcript (verbatim):
```
❯ Use the researcher subagent to find out what Rust's anyhow crate is used for.
1 skill available

⏺ researcher(Research Rust anyhow crate)
Done (0 tool uses · 6.7k tokens · 30s)
```

**The on-disk proof — and why it isn't just a hand-typed JSON blob.** A single copied `.meta.json`
would be trivial to fake by typing the same string. So the proof here is a **cross-reference between
two independently-written files that Claude Code itself produced, in two different directories, that
must agree on a random-looking ID neither Vajra nor this write-up chose**:

1. **The parent session's own transcript** (`sessions/session-111-artifacts/researcher-parent-tooluse.json`,
   extracted verbatim from `~/.claude/projects/<scratch-repo-slug>/7b14e2d2-…jsonl`) records the actual
   tool call Claude Code made:
   ```json
   {"type": "tool_use", "id": "toolu_01BUEtCmRmk3psxJ349LMY9H", "name": "Agent",
    "input": {"description": "Research Rust anyhow crate", "subagent_type": "researcher", ...}}
   ```
   — `subagent_type: "researcher"` is the literal parameter Claude Code's own dispatcher resolved,
   at `timestamp: "2026-08-03T11:57:10.576Z"`, `sessionId: "7b14e2d2-…"`.
2. **The subagent's own metadata file**, written by Claude Code into a *separate* `subagents/`
   subdirectory (`sessions/session-111-artifacts/researcher-subagent-meta.json`):
   ```json
   {"agentType":"researcher","description":"Research Rust anyhow crate","toolUseId":"toolu_01BUEtCmRmk3psxJ349LMY9H"}
   ```
   — `toolUseId` here is the **exact same ID** as the parent's tool-call `id` above. Two files, written
   by two different parts of Claude Code's own runtime, independently agree that tool call
   `toolu_01BUEtCmRmk3psxJ349LMY9H` both **requested** `subagent_type: "researcher"` and **resolved to**
   `agentType: "researcher"`. Forging this would mean fabricating two matching random IDs across two
   files in Claude Code's exact internal JSONL schema — not typing one JSON line.
3. **The full raw subagent transcript** (`sessions/session-111-artifacts/researcher-subagent-transcript.jsonl`,
   copied byte-for-byte, sha256 `76116db0d4cc8bbe4e84423bcb160e8f1268e916b0239831f0adabb539aabf80`) —
   the real 2-line JSONL Claude Code wrote for the subagent's own turn (model `claude-opus-4-8`, real
   `usage` token counts, its own `uuid`/`sessionId`/`timestamp` fields) — reproducible evidence, not a
   summary of it.

`agentType: "researcher"` and `subagent_type: "researcher"` are the exact `name:` key from the
scaffolded `.claude/agents/researcher.md` frontmatter. This is the mechanism, confirmed by two
cross-referencing files, not asserted in prose: Claude Code's Task tool auto-discovers project-level
`.claude/agents/<name>.md` files at session start and dispatches them by that `name:` field — not a
Vajra-side string match, not a duplicated prompt.

## Step 3 — governed handoff, from the real brief
The real brief text above was fed to the existing S109 governance path, unchanged:
```
vajra next --role researcher --from sessions/session-111-artifacts/researcher-subagent-brief.md
```
→ `.ai/handoffs/session-111-researcher.md`, `source-sha 756bdbc6…`, `fleet::validate_handoff` OK.

## Cost — the null is now a CHECKED, RE-RUNNABLE reason, not a guess
S109 recorded `cost_usd: null` and reasoned "a subagent's cost rolls into the parent session
receipt." S111 checked this directly with a real, reusable script —
`scripts/check-subagent-cost-fields.sh` — that scans every `~/.claude/projects/*/*/subagents/*.jsonl`
on this machine (the same files `vajra meter`'s `subagent_dir` folding already reads) for
`total_cost_usd` / `cost_usd`. This is not a claim baked into a doc-comment: it is a script anyone —
the founder, a future session, a reviewer — can run themselves and get the same falsifiable answer.
At the time of this session's final run it found **zero of the scanned transcripts** carry either
key (see the script's own output in `verify-session-111.sh`'s `subagent-cost-check` step log). A
subagent transcript carries full token usage (`usage.input_tokens`, `output_tokens`, `cache_*` —
confirmed present in `researcher-subagent-transcript.jsonl`) but never a dollar figure. Root cause,
same as S77/S78: `total_cost_usd` is only ever emitted on the terminal `type:"result"` line of a
headless `-p` run's own stdout stream. A Task-tool subagent is not a separate `-p` invocation — it
never produces that stream. So `cost_usd: null` stays, but for a checked, specific, falsifiable,
**re-runnable** reason: the field structurally does not exist anywhere Vajra could read it, not
"unclear" (the token totals do roll in via `meter`'s existing `subagent_dir` folding — the dollar
figure does not, because it never exists standalone). `--assert-null` on the script turns this into a
regression check: it will start failing the day Claude Code ever does emit a per-subagent cost.
