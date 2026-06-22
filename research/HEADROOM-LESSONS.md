# Headroom Lessons for Vajra

**Status:** research note  
**Date:** 2026-06-22  
**Rule:** learn from Headroom; do not copy code, assets, docs, benchmarks, or naming.

## Purpose

Headroom is a useful public reference because it has already explored context
compression, reversible retrieval, wrappers, proxy delivery, memory, MCP tools,
and output-token reduction for AI agents.

Vajra should use Headroom as a competitor/teacher, not as a source tree.
Vajra's product identity remains:

> Vendor-neutral governance, audit, and cost control for AI-written code.

Compression is Vajra's wedge and proof-of-rail. Governance and audit are the
moat.

## Non-Copy Policy

| Boundary | Rule |
|---|---|
| Source code | Do not copy Headroom code into Vajra. Reimplement only from Vajra ADRs and local design. |
| Docs/wording | Do not copy phrasing, diagrams, benchmark claims, or marketing text. |
| Names | Do not reuse Headroom feature names such as CCR, CacheAligner, SmartCrusher, or Kompress. |
| Claims | Do not reuse Headroom's savings numbers. Vajra must measure its own workloads. |
| Dependencies | Do not add Headroom as a dependency unless explicitly approved in a future ADR. |
| Attribution | If a future ADR studies a specific Headroom idea, cite the repo and explain the independent Vajra design. |

## Strategic Read

| Headroom Position | Vajra Response |
|---|---|
| Broad context compression layer | Vajra should not compete as only a compressor. |
| Library/proxy/MCP/wrapper ecosystem | Vajra should stay narrower until the governance rail works. |
| Reversible local retrieval | Vajra should provide raw recovery for trust, but with Vajra-native storage. |
| Cross-agent memory | Vajra can learn the value, but memory must be governed and auditable. |
| Output shaping | Useful cost lever, but risky for agent behavior; defer until meter proves need. |
| Public benchmark suite | Vajra needs its own honest benchmark harness and receipts. |

## What Vajra Can Learn Now

### 1. Reversible Compression Is Trust Infrastructure

Learning:
- Users trust compression more when original content is recoverable.
- A visible breadcrumb is necessary but not sufficient for large real workflows.
- Recovery should be local, fast, and explicit.

Vajra application:
- Keep `VAJRA_RAW=1` as the simplest full-bypass path.
- Add a local raw-output cache only after the hook and launcher are stable.
- Make compressed output point to a recovery command or receipt ID.
- Never transmit raw command output.

Possible future shape:

```text
[143 lines hidden by Vajra: raw=vjraw:20260622T121433Z:7f3a]
vajra raw 7f3a
VAJRA_RAW=1 cargo test
```

Open design questions:
- TTL: per session, per repo, or user configurable?
- Storage: temp dir, `.vajra/`, OS cache dir, or encrypted local store?
- Privacy: should raw cache default to disabled for sensitive repos?
- Hook limit: does Claude Code allow a recovery tool path, or only text?

### 2. Wrapper UX Must Be Boring

Learning:
- Adoption depends on a wrapper that feels identical to the wrapped agent.
- Flags, cwd, env, stdio, exit codes, and failures must behave like the original.
- The wrapper should not require the user to learn a new workflow on day 1.

Vajra application:
- `vajra launch <args>` should behave like `claude <args>`.
- Use `spawn() + wait()` for temp settings cleanup, per ADR-0003.
- Propagate child exit code exactly.
- Fail open to bare `claude` where the ADR says to fail open.
- Print only actionable warnings.

### 3. Cache Safety Is Product Safety

Learning:
- Prompt or system-prefix mutation can destroy provider cache economics.
- Compression savings are weaker if cache writes/reads are mispriced.
- Stable configuration and minimal prompt mutation are core design constraints.

Vajra application:
- Keep compression in `PostToolUse` hook output for v1.
- Do not mutate user prompts.
- Do not add memory text to prompts in v1.
- Meter cache write/read tiers separately.
- Treat cache misses as a regression in benchmarks.

### 4. Compression Needs Routing, Not One Algorithm

Learning:
- Different content types need different treatment.
- Shell output, JSON, code, prose, logs, and images are not equivalent.
- A router makes the system extensible without bloating each compressor.

Vajra application:
- Continue using tool/command-specific heuristics in `src/engine/heuristic/`.
- Keep `Engine` as the stable decision boundary.
- Add new heuristics only when backed by fixture evidence.
- Prefer conservative passthrough over clever lossy compression.

Future heuristic candidates:
- `go test`
- `jest` / `vitest`
- `pnpm` / `yarn`
- `pip` / `uv`
- `mvn` / `gradle`
- `docker build`
- `terraform plan`
- long `find` / `tree` / `ls -R`

### 5. Output Tokens Matter

Learning:
- Input compression is not the only cost lever.
- Model output is often more expensive than input.
- Terseness and effort routing can save money, but can also alter behavior.

Vajra application:
- Do not shape model output in v1.
- Use the meter to quantify output-token share first.
- Consider policy-only nudges later, with explicit opt-in.
- Avoid any change that reduces debugging quality.

Possible future feature:

```text
vajra policy set output_style terse
```

But only after:
- benchmark evidence,
- rollback switch,
- task-success regression tests,
- clear user consent.

### 6. Memory Must Be Governed

Learning:
- Cross-agent memory is valuable because users switch agents.
- Auto-learning from failed sessions can reduce repeated mistakes.
- Ungoverned memory can also preserve bad assumptions forever.

Vajra application:
- Memory belongs after the audit ledger, not before it.
- Every memory write should have provenance: session, file, command, reason.
- Memory should be reviewable, diffable, and removable.
- Do not silently write project rules from inferred behavior.

Vajra-native direction:

```text
vajra learn --from session-07
vajra memory diff
vajra memory approve
```

### 7. MCP Is A Useful Interface, Not The Core

Learning:
- MCP can expose retrieval, stats, memory, and diagnostics to many agents.
- MCP is strongest when it wraps a stable local capability.

Vajra application:
- Do not start with MCP.
- Add MCP after local CLI commands exist.
- Candidate tools:
  - `vajra_get_receipt`
  - `vajra_get_raw_output`
  - `vajra_get_audit_events`
  - `vajra_check_policy`
  - `vajra_session_state`

### 8. Benchmarks Must Be Vajra-Specific

Learning:
- Public savings claims need reproducible methodology.
- Token reduction alone is insufficient; task success must remain unchanged.
- Output-token savings can be estimated, but measured holdouts are stronger.

Vajra application:
- Keep ADR-0004's honest meter design.
- Measure blended dollars, not just token counts.
- Count raw recoveries as trust failures.
- Count turn regressions as behavioral failures.
- Publish workload mix and failure cases.

Required benchmark dimensions:
- bare agent vs Vajra,
- same task success,
- same repo start SHA,
- interleaved runs,
- cache tier pricing,
- main + subagent JSONL,
- raw recovery count,
- hidden line count,
- turns delta,
- wall-clock overhead.

## What Vajra Should Avoid

| Temptation | Why Avoid |
|---|---|
| Become a general compression library | Headroom is already stronger there; it dilutes Vajra. |
| Add a proxy in v1 | Higher trust burden and outside current ADR scope. |
| Add ML compression early | Adds dependencies, latency, and reproducibility risk. |
| Claim huge generic savings | Vajra's own research says blended savings are smaller. |
| Auto-write memory/rules | Can create hidden drift and stale project assumptions. |
| Compress failures aggressively | Debug loops are more expensive than saved lines. |
| Optimize before meter | Without receipts, savings claims are not defensible. |

## Product Boundary

| Layer | Vajra v1 | Vajra Later |
|---|---|---|
| Compression | Yes, shell-output hook | More heuristics, raw cache |
| Meter | Yes, honest receipt | Benchmark dashboard |
| Launcher | Yes, Claude Code | Codex / Cursor / Aider adapters |
| Governance | Minimal hooks today | Policy engine |
| Audit | Session files today | Tamper-evident ledger |
| Memory | No | Governed memory |
| MCP | No | Audit/retrieval tools |
| Proxy | No | Only if separately justified |

## Direct Backlog Ideas

### Near Term

1. Finish `vajra launch` without changing the user workflow.
2. Fix `LINE_CAP` / `FAIL_PASSTHROUGH_CAP` per ADR-0003.
3. Build the meter before making savings claims.
4. Add more command fixtures before adding more heuristics.
5. [x] Document Headroom as a competitor in `research/COMPETITOR-TEARDOWN.md`.

### Medium Term

1. Add raw-output recovery with local-only storage.
2. Add `vajra raw <id>` or equivalent recovery command.
3. Add receipt fields for hidden lines and raw recoveries.
4. Add benchmark harness with turn/task success controls.
5. Add policy events to the receipt format.

### Long Term

1. Cross-agent adapter model.
2. Tamper-evident audit ledger.
3. Governed memory with review/approval.
4. MCP interface over audit and recovery.
5. Optional output-token policy after measurement proves value.

## ADR Candidates

| ADR | Question |
|---|---|
| Raw Recovery | Should Vajra store raw command output locally? Where, how long, and under what privacy defaults? |
| Multi-Agent Rail | What is the stable adapter contract across Claude Code, Codex, Cursor, Aider, and others? |
| Audit Ledger | What event schema makes agent work verifiable without leaking sensitive content? |
| Governed Memory | How does Vajra learn from sessions without silently creating stale or wrong rules? |
| MCP Surface | Which Vajra capabilities deserve MCP tools, and when? |
| Output Policy | Can Vajra reduce model output tokens without task-success regression? |

## Unique Vajra Thesis

Headroom answers:

> How do we fit more useful context into fewer tokens?

Vajra should answer:

> How do we make AI-written code governed, auditable, verifiable, and cheaper without changing the agent developers already use?

That is the product line to protect.
