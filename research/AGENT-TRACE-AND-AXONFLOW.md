# Vajra — agent-trace spec + AxonFlow deep-dive

**Date:** 2026-06-15 · **Author:** parallel research session (feeds governance design)
**Purpose:** (1) the exact provenance format Vajra should *emit*; (2) the closest competitor's
internals — what to copy and the weaknesses to beat. *Does not edit master/ADRs/memory.*

> **Punchline:** adopt `agent-trace` as the provenance format (don't invent one), and beat
> AxonFlow on its own published weaknesses — **in-process Rust engine, local-first, git-native
> permanent tamper-evident ledger, free-unlimited, uniform cross-agent.** That stack is a
> coherent, defensible position.

---

## PART 1 — agent-trace (the format Vajra should emit)

**What it is:** an **open, vendor-neutral spec for tracing AI-generated code** — published by
Cursor, **CC BY 4.0**, reference TypeScript impl at `github.com/cursor/agent-trace`, site
`agent-trace.dev`, announced ~Feb 2026 (InfoQ). It's a *spec*, not a product.

### The schema (JSON Trace Record)
```
Trace Record
├── version, id, timestamp          # required identity
├── vcs { type: git|jj|hg|svn, revision }
├── tool { name, version }          # the recorder (e.g. vajractl)
├── files[]
│   ├── path
│   └── conversations[]
│       ├── url                      # link to the AI conversation/session
│       ├── contributor { type: human|ai|mixed|unknown, model_id? }
│       ├── ranges[] { start, end }  # LINE-level
│       └── related[]                # links to resources
└── metadata                        # vendor-specific, reverse-domain keys (e.g. dev.vajra.*)
```

**Key properties:**
- **Granularity:** line-level (ranges), classified `human | ai | mixed | unknown`, optional `model_id`.
- **Provider-neutral:** attribution isn't tied to a vendor; any compliant tool reads/writes it.
- **Storage is NOT mandated:** typical = `.agent-trace/traces.jsonl` per PR/commit/session,
  **but git notes or a DB are explicitly allowed.** Records live **committed alongside the code** —
  "same lifecycle as the code: ships with it, reviewable in PRs, survives forks/rebases."
- **Extensible:** vendor data under reverse-domain `metadata` keys (`dev.cursor`, `com.github.copilot`).

### Why this is perfect for Vajra
- Vajra (the shim/launcher) **sees the agent's `Edit`/`Write` tool calls in real time** → it can
  produce **accurate line-range attribution at write-time**, across any agent — exactly what the
  spec wants and what post-hoc fingerprinting can't do reliably.
- **Interop > NIH:** emit the standard, compete on the *recorder + ledger*, not a rival schema.
- The spec leaves storage open → Vajra's differentiator is the **storage choice**: a **git-native,
  tamper-evident** ledger (git notes / committed JSONL + a hash chain) — see Part 2.

### What the bare spec does NOT give you (Vajra's value-add on top)
- No **enforcement** (it's attribution, not policy/blocking).
- No **tamper-evidence** (a plain JSONL can be edited; add a hash chain / signing).
- No **prompt→action causal linkage** beyond a `url`.
- No **cross-agent uniform recorder** — it's a format; someone has to *be* the neutral recorder. ← Vajra.

---

## PART 2 — AxonFlow deep-dive (the benchmark to beat)

`getaxonflow/axonflow-claude-plugin` — MIT + freemium SaaS. The closest thing to Vajra's
governance/audit vision, shipped today.

### Architecture
- **Hook-based** (not proxy). Modifies `~/.claude/settings.json`; defs in `hooks/hooks.json`.
- Scripts: `pre-tool-check.sh` (enforce), `post-tool-audit.sh` (audit + PII scan),
  `mcp-auth-headers.sh`, `telemetry-ping.sh`. **All Bash.**
- Governs Bash, Write, Edit, NotebookEdit, `mcp__*`. Read-only tools (Read/Glob/Grep) not governed.
- Exposes **15 MCP tools** via `/api/v1/mcp-server`.

### Enforcement flow
```
PreToolUse → check_policy("claude_code.Bash", input) → BLOCKED(decision_id, risk_level) | ALLOWED
PostToolUse → audit_tool_call(tool, input, output)  [non-blocking] + PII scan/redact
```
- **Policies:** 80+ built-in (dangerous cmds `rm -rf /`/`nc -e`/`bash -i`, SQLi 30+ patterns,
  PII/secrets, SSRF, prompt-injection). Custom via `POST /api/v1/dynamic-policies` or
  `axonflow_create_tenant_policy` MCP tool.
- **Decision UX:** block → `decision_id` → `explain_decision(decision_id)` returns which policies
  matched + whether overridable. `create_override` (justification required, audited).

### Audit record
`tool, args, input/output snapshots, matched policies, decision_id, risk_level, duration,
timestamp, tenant`. Searchable (`search_audit_events`), export CSV/JSON on paid tiers.

### Storage / deployment
- Local: `~/.config/axonflow/try-registration.json` (0600), telemetry stamp, `AXONFLOW_LICENSE_TOKEN`.
- Remote: community SaaS `try.getaxonflow.com` (zero-config); self-host `AXONFLOW_ENDPOINT`; `/health`.
- Auth: `base64(client-id:secret)`.

### Performance / limits
- Overhead **3–10 ms**/tool (pre-check 2–5, PII 1–3, SQLi 1–2, audit async 0). Timeouts:
  Pre 8s / Post 5s. Community rate limit 20/min · 500/day. **Retention: free 3 days**, eval 14d, ent 10y.

### Published weaknesses → Vajra's exact openings
| AxonFlow weakness | Vajra's counter |
|---|---|
| **Fail-open on network loss** (DoS the endpoint → governance off) | **In-process Rust engine** — no network in the decision path; fail-closed option |
| **Community SaaS data egress** (args/outputs → their cloud) | **Local-first / air-gapped by default** — zero egress (matches our 5 trust commitments) |
| **Free tier throttled** (200/day → users disable governance) | **Free, unlimited, local** — governance is never rate-limited |
| **Bash hook scripts** (injection/priv-esc risk) | **Single compiled Rust binary** — no shell scripts in the trust path |
| **3-day free retention** (attacker waits out the logs) | **Git-native permanent ledger** — lives in the repo forever, can't expire |
| **Plain audit log, tenant-scoped** | **Tamper-evident, hash-chained, repo-portable** ledger in `agent-trace` format |
| **Override = self-serve on free tier** | Approval gates available in the open tier |
| **Claude-Code-primary**, per-integration cross-agent | **One engine, uniform across agents**, emitting the neutral standard |
| Audit records still hold raw PII | Optional encryption-at-rest / tokenization |

### What to COPY from AxonFlow (it's good)
- **Zero-config auto-enforcement** (80+ policies on by default — no setup friction).
- The **`decision_id` → `explain_decision` → `create_override`** inline UX (don't make devs leave the session).
- **Async/non-blocking audit write** (0 ms perceived).
- **Low-latency budget** (<10 ms/tool is the bar to meet).
- Built-in policy categories as a **starter policy pack** (dangerous cmds, secrets, etc.).

---

## PART 3 — The synthesized competitive position for Vajra

**The recorder + ledger nobody else has:**
1. **In-process Rust** governance + provenance engine (beats fail-open, egress, bash, latency).
2. **Emits `agent-trace`** (open standard) for **line-level, cross-agent, write-time** attribution.
3. **Git-native, permanent, tamper-evident ledger** (hash-chained JSONL or git notes, committed
   to the repo) — survives forks/rebases, no SaaS retention cliff.
4. **Local-first & free-unlimited** for the solo dev (the on-ramp), team policy distribution via
   repo-committed config (the pre-commit.com pattern) as the paid layer.
5. **Copy AxonFlow's zero-config enforcement + inline explain/override UX**, beat it on
   architecture + portability + neutrality.

**One-line moat (sharpened):** *"the local-first, git-native, tamper-evident flight recorder for
AI-written code — uniform across every agent, in the open agent-trace format — that also enforces
policy, with no cloud and no retention cliff."*

---

## Sources
- [cursor/agent-trace (GitHub)](https://github.com/cursor/agent-trace) · [spec README](https://github.com/cursor/agent-trace/blob/main/README.md) · [agent-trace.dev](https://agent-trace.dev/) · [DeepWiki](https://deepwiki.com/cursor/agent-trace) · [InfoQ coverage](https://www.infoq.com/news/2026/02/agent-trace-cursor/) · [Axiom explainer](https://axiomstudio.ai/blog/cursor-agent-trace-explainer)
- [AxonFlow Claude plugin (GitHub)](https://github.com/getaxonflow/axonflow-claude-plugin)
