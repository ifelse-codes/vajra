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

**The on-disk proof (not a screenshot, the actual JSONL record Claude Code itself wrote):**
`~/.claude/projects/<scratch-repo-slug>/<session-uuid>/subagents/agent-a65d477773e0d2269.meta.json`:
```json
{"agentType":"researcher","description":"Research Rust anyhow crate","toolUseId":"toolu_01BUEtCmRmk3psxJ349LMY9H"}
```
`agentType: "researcher"` is Claude Code's own record of which subagent definition it resolved and
ran — the exact `name:` key from the scaffolded `.claude/agents/researcher.md` frontmatter. This is
the mechanism: Claude Code's Task tool auto-discovers project-level `.claude/agents/<name>.md` files
at session start and offers/dispatches them by their `name:` field — not a Vajra-side string match,
not a duplicated prompt. Copies of the meta.json and the full findings brief are in this directory
(`researcher-subagent-meta.json`, `researcher-subagent-brief.md`).

## Step 3 — governed handoff, from the real brief
The real brief text above was fed to the existing S109 governance path, unchanged:
```
vajra next --role researcher --from sessions/session-111-artifacts/researcher-subagent-brief.md
```
→ `.ai/handoffs/session-111-researcher.md`, `source-sha 756bdbc6…`, `fleet::validate_handoff` OK.

## Cost — the null is now a CHECKED reason, not a guess
S109 recorded `cost_usd: null` and reasoned "a subagent's cost rolls into the parent session
receipt." S111 checked this directly: every subagent JSONL on this machine — **49 files across all
projects, including this session's own `agent-a65d477773e0d2269.jsonl`** — was grepped for
`total_cost_usd` / `cost_usd`. **Zero of 49 contain either key.** A subagent transcript carries full
token usage (`usage.input_tokens`, `output_tokens`, `cache_*` — confirmed present) but never a dollar
figure. Root cause, same as S77/S78: `total_cost_usd` is only ever emitted on the terminal
`type:"result"` line of a headless `-p` run's own stdout stream. A Task-tool subagent is not a
separate `-p` invocation — it never produces that stream, on this session or any other sampled here.
So `cost_usd: null` stays, but for a checked, specific, falsifiable reason: **the field structurally
does not exist anywhere Vajra could read it**, not "unclear" and not "rolls into the receipt"
(the token totals do roll in via `meter`'s existing `subagent_dir` folding — the dollar figure does
not, because it never exists standalone).
