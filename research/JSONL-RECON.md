# Vajra — Claude Code session JSONL recon

**Date:** 2026-06-15 · Source: live files on this machine (Claude Code **v2.1.177**)
**Purpose:** ground the cost-meter / `bench` harness in the REAL log format. *Read-only recon;
only structure + numeric token fields captured — no code/prompt content.* Does not edit master/ADRs/memory.

> **The real schema is richer than S3 assumed — three corrections to the cost math below.**

---

## 1. Where the files live
```
~/.claude/projects/<cwd-slug>/<session-uuid>.jsonl          # main session
~/.claude/projects/<cwd-slug>/<session-uuid>/subagents/agent-<id>.jsonl   # EACH subagent
```
- `<cwd-slug>` = working dir with `/`→`-` (e.g. `-Users-suman-playground-vajra`).
- One JSONL per session; **subagents get their own JSONL files in a `subagents/` subfolder.**

## 2. Line types (only `assistant` carries token usage)
`assistant` · `user` · `attachment` · `last-prompt` · `queue-operation` · `ai-title`
- Usage lives on `assistant` lines at **`.message.usage`** (not top-level).
- Per-line fields useful to us: `.message.model`, `.version` (CC version), `.gitBranch`,
  `.cwd`, `.sessionId`, `.timestamp`, `.isSidechain`, `.requestId`, `.uuid`/`.parentUuid`.

## 3. The real `usage` object (one sample, numbers only)
```json
{
  "input_tokens": 10,
  "cache_creation_input_tokens": 6928,
  "cache_read_input_tokens": 11586,
  "output_tokens": 132,
  "cache_creation": { "ephemeral_5m_input_tokens": 0, "ephemeral_1h_input_tokens": 6928 },
  "server_tool_use": { "web_search_requests": 0, "web_fetch_requests": 0 },
  "service_tier": "standard",
  "speed": "standard",
  "inference_geo": "not_available",
  "iterations": [ { ...per-iteration breakdown... } ]
}
```

## 4. ⚠ Three corrections to the S3 cost formula

S3 assumed a single cache-write price (1.25×). The real data shows more:

1. **Two cache-write TTL tiers, different prices.** `cache_creation` splits into
   `ephemeral_5m_input_tokens` (**1.25×** base) and `ephemeral_1h_input_tokens` (**2×** base).
   `cache_creation_input_tokens` is the *sum*. **The meter must price the two tiers separately**
   — using a flat 1.25× under-counts 1h-cache writes (which this session actually used: 6928 @ 1h).
2. **Server tool use is billed separately.** `server_tool_use.web_search_requests` /
   `web_fetch_requests` are per-request line items (not token-priced). Add them to the bill.
3. **Mixed models per session → price per line by `.message.model`.** Real data: the main
   session is `claude-opus-4-8` (163 lines) but titles/subagents use `claude-haiku-4-5`. A
   flat-model price is wrong.

**Corrected per-line cost (sum over all assistant lines, across main + subagent files):**
```
$line = ( input_tokens               · price[model].input
        + output_tokens              · price[model].output
        + ephemeral_5m_input_tokens  · price[model].input · 1.25
        + ephemeral_1h_input_tokens  · price[model].input · 2.0
        + cache_read_input_tokens    · price[model].input · 0.10 ) / 1e6
        + web_search_requests · price.web_search
        + web_fetch_requests  · price.web_fetch
```

## 5. Gotchas the harness MUST handle (each is a silent-miscount trap)
- **`<synthetic>` model lines exist** (saw 1 in the main session) — **filter them out**; they're
  non-billable placeholders and have no real price.
- **Subagent costs are in separate files** — aggregate `*/subagents/*.jsonl` or you undercount a
  whole session's spend.
- **`.version` is sometimes `null`** on non-assistant lines — read CC version from a line that has it.
- **`cache_creation_input_tokens` double-counts** if you also add the 5m+1h split — use the split,
  not both.
- **`iterations[]`** repeats the same numbers as a sub-breakdown — **don't double-add**; use the
  top-level usage fields.
- Confirms S3: pin a CC version (this fixture = **2.1.177**) and a fixture file; fail loud if keys move.

## 6. Sanitized fixture (commit to `bench/fixtures/`)
A real assistant `usage` is in §3. For the harness fixture, store a few such `{model, usage}`
records + a hand-computed expected dollar total at a pinned `pricing.toml`. The fixture's job:
**CI goes red if the schema drifts** (e.g. Anthropic renames `ephemeral_1h_input_tokens`).

Minimal fixture shape:
```jsonl
{"type":"assistant","version":"2.1.177","message":{"model":"claude-opus-4-8","usage":{"input_tokens":10,"output_tokens":132,"cache_read_input_tokens":11586,"cache_creation_input_tokens":6928,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":6928},"server_tool_use":{"web_search_requests":0,"web_fetch_requests":0}}}}
{"type":"assistant","version":"2.1.177","message":{"model":"<synthetic>","usage":{}}}   # must be skipped
```

## 7. Implication for the meter (good news)
- The shim doesn't need a proxy to know cost — **everything is in these files**, including the
  cache-tier split, per-model breakdown, and subagent spend. The "no-proxy v1" decision holds.
- The richer fields let Vajra report an **honest blended-dollar P&L** (the S3 requirement) more
  precisely than the simplified formula — strengthens the "honest meter" trust play.

## 8. Provenance bonus (feeds the agent-trace work)
Lines carry `gitBranch`, `cwd`, `sessionId`, `timestamp`, `uuid`/`parentUuid` → enough to link a
session to a branch and (with tool-call lines) to attribute edits. Useful when Vajra emits
`agent-trace` records (see `AGENT-TRACE-AND-AXONFLOW.md`).
