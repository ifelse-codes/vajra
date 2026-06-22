# Vajra — Competitor Teardown (governance/audit focus)

**Date:** 2026-06-15 · **Author:** parallel research session (feeds the governance design phase)
**Scope:** deep teardown of the tools nearest Vajra's *governance + audit moat*, with what to reuse and where the real gap is.

> ⚠ **Headline:** the cross-agent governance/audit white space Vajra claimed in S4 is **less
> empty than we thought.** Two direct entrants exist (AxonFlow, Endor Labs) and a **neutral
> cross-agent attribution spec is already published (Cursor agent-trace)**. The moat needs a
> sharper edge than "nobody does cross-agent." Details + implications below. *This file does not
> edit the master/ADRs — it's input for the design session to reconcile.*

---

## 1. Direct competitors (governance/audit for coding agents)

### AxonFlow (`getaxonflow/axonflow-claude-plugin`) — closest competitor
| Aspect | Finding |
|---|---|
| What | Runtime governance + audit for Claude Code: 80+ built-in policies (rm -rf, reverse shells, SQLi, PII/secrets, SSRF, prompt-injection), audit trail, PII redaction of tool outputs |
| Mechanism | **Hook-based** (PreToolUse blocks via policy check → `decision_id`; PostToolUse audits + scans). Fail-open on network, fail-closed on config error. **Not a proxy.** |
| Scope | **Claude Code-primary**, with *separate* "sister integrations" for Cursor, Codex, Computer Use → reaching toward cross-agent but **per-integration, not one neutral plane** |
| Audit | Records tool name, args, outputs, matched policies, decision, duration; search + export (CSV/JSON) on paid tiers |
| Policy-as-code | Yes — custom policies via API (`POST /api/v1/dynamic-policies`) + portal |
| Attribution | Session / `client_id` / tenant — **not developer identity** |
| Business | **MIT** + SaaS tiers: free (200 events/day, 3-day retention), Pro $9.99/90d (2k/day, 30-day), self-host option |

**Why it matters:** this is ~80% of Vajra's governance vision, *already shipped*, open-source,
with a working freemium model. It validates demand **and** crowds the lane.
**Where it's weak (Vajra's opening):** Claude-Code-primary (cross-agent is bolted-on, not
native/uniform); attribution stops at session/tenant, not **developer + agent + diff hunk**; no
sign of a portable, repo-native, tamper-evident ledger that travels with git.

### Endor Labs — "Agent Governance using Hooks"
Security vendor bringing visibility to AI coding agents via hooks. Enterprise AppSec angle
(supply-chain heritage). Signals the **security incumbents are entering** agent governance —
they'll have the compliance/buyer relationships Vajra won't.

### Checkmarx One Assist / Truefoundry / Superblocks (AI code governance lists)
Enterprise "secure the AI-generated code" plays — IDE-time guardrails, pre-commit prevention
for human + AI code. Adjacent (security scanning), not cross-agent audit-ledger, but competing
for the same "govern agent code" budget and narrative.

### Headroom (`chopratejas/headroom`) — compression/context benchmark, not the moat
| Aspect | Finding |
|---|---|
| What | Local context compression layer for agents: wrapper, proxy, library, MCP, memory, reversible retrieval, output shaping |
| Why it matters | It crowds the "token/context savings wrapper" story and proves that broad compression is not enough for Vajra differentiation |
| Vajra response | Learn from wrapper UX, reversible recovery, cache safety, benchmarks, memory/MCP, and output-token framing; do not copy code, docs, names, claims, or dependencies |
| Source note | See `research/HEADROOM-LESSONS.md` before designing raw recovery, benchmark harness, memory/MCP, or output policy |

---

## 2. The attribution layer (this is the surprise)

### Cursor `agent-trace` — an OPEN cross-agent attribution spec
- Published 2026 as a **neutral** spec to record **AI-vs-human code attribution** across Cursor,
  Copilot, Claude Code, etc. Described as "the only neutral way to compare what each agent is
  producing."
- **This sits squarely in Vajra's claimed white space** ("cross-agent attribution"). Part of the
  moat may already be a public standard.
- **Implication:** Vajra should likely **adopt/emit `agent-trace`** rather than invent a rival
  format — interop > NIH. Differentiate on the **ledger + policy enforcement**, not the attribution schema.

### Behavioral fingerprinting (arXiv 2601.17406)
Research IDs which agent submitted a PR with **97.2% F1** from commit/PR/code features. Means
attribution can be done **post-hoc, without a wrapper** — weakening "you need us to know which
agent did it." Vajra's edge must be *real-time enforcement + provenance at write-time*, not
just "we can tell which agent."

---

## 3. The enforcement substrate (universal, agent-blind — to assemble on)

| Tool | Role | Reuse for Vajra |
|---|---|---|
| **pre-commit.com** | Polyglot, YAML, **versioned + distributable** hooks (`.pre-commit-config.yaml` in VCS) | The model for **team policy distribution** — policy travels with the repo, updates via code review |
| **lefthook** | Go, fast, parallel, no runtime dep, YAML | Architecture reference for a fast multi-lang hook runner (Vajra is Rust — same posture) |
| **husky + lint-staged** | Node-standard pre-commit | Ubiquity baseline; what devs already expect |
| **OPA / Conftest** | Policy-as-code (Rego); "GitHub App runs Conftest on every commit" | The **policy-as-code engine** pattern + the **server-side enforcement** model |
| **Gitleaks** | Secret detection pre-commit | A ready policy to bundle (secrets in agent output) |
| **Semgrep** | Static analysis, plain-English rules | Policy authoring UX reference |

**Pattern to steal:** *policy-as-code committed to the repo + a server/App that enforces it on
every commit and reports violations back.* That's the team-distribution + CI-gate half of
Vajra's paid layer.

---

## 4. Claude Code native hooks (the deep-but-single-agent baseline)

- **12 lifecycle events**; **PreToolUse is the only blocker** (exit 2). Governs Bash, Write,
  Edit, NotebookEdit, and all `mcp__*` tools.
- Handler types: **Command** (shell), **Prompt** (single-turn LLM eval), **Agent** (subagent
  verification). Hooks read JSON on stdin, signal via exit code + stdout JSON.
- This is exactly the surface AxonFlow rides. **It's powerful but Claude-only, per-machine, and
  produces no portable cross-agent ledger.** Confirms S4: the *enforcement primitive* is
  commodity; the *neutral cross-agent ledger* is the differentiator — **if it survives §2.**

---

## 5. Market context (2026)

- Industry shift from 2025 "productivity" → 2026 **"quality, attribution, governance."**
- Guardrails moving to the **gateway layer** for unified audit trails (a structural competitor
  to a per-dev wrapper — gateways are org-wide).
- **EU AI Act**: most rules apply from **Aug 2026**, penalties up to 7% global turnover →
  compliance is a real buyer for audit trails. (Favors the audit-ledger thesis — *if* Vajra can
  be compliance-grade.)

---

## 6. Updated white-space read (honest revision of S4)

| S4 claimed gap | Reality after teardown |
|---|---|
| "agent-aware + cross-agent + auditable is empty" | **Partly filled.** AxonFlow (agent-aware + audit, reaching cross-agent); agent-trace (cross-agent attribution, neutral, open). |
| "nobody offers cross-agent attribution" | **False** — `agent-trace` exists and is positioned as the neutral standard. |
| "vendors can't self-audit → neutrality is our moat" | **Still true & still good** — but a *third-party* (AxonFlow, Endor) can also be neutral. Neutrality alone isn't unique. |

**The remaining, sharper gap (the defensible wedge):**
1. **Repo-native, portable, tamper-evident ledger that travels with git** (not a SaaS-tenant log) — none of the above does this cleanly.
2. **Write-time provenance at hunk granularity** (which agent+session+prompt produced *this diff*), emitted in the open `agent-trace` format — interop, not a rival schema.
3. **One uniform policy + ledger across agents from day one** (AxonFlow's cross-agent is per-integration afterthought).
4. **The honest-meter + governance bundle** — cost P&L *and* policy/audit in one local-first tool, no SaaS lock-in.

---

## 7. Implications for Vajra (for the design session to reconcile)

- **Don't reinvent attribution — adopt/emit `agent-trace`.** Differentiate on ledger + enforcement.
- **Moat re-sharpened:** "repo-native, portable, tamper-evident, cross-agent policy+audit ledger,
  local-first" — not just "cross-agent."
- **AxonFlow is the benchmark to beat** — study its policy model + freemium; beat it on
  cross-agent uniformity, git-native portability, and hunk-level provenance.
- **Watch the gateway players + security incumbents (Endor/Checkmarx)** — they own the enterprise
  compliance buyer. Vajra's wedge is the **developer/local-first** entry (the compression on-ramp),
  growing up into team governance — the opposite direction from the top-down incumbents.
- **Possible v-next reprioritization:** the dogfood path (founder using it daily) favors
  local-first ledger + git-native provenance over a SaaS dashboard. Aligns with the deferred-
  validation / build-first call.

---

## Sources
- [AxonFlow Claude plugin](https://github.com/getaxonflow/axonflow-claude-plugin)
- [Claude Code hooks reference (Morph)](https://www.morphllm.com/claude-code-hooks) · [Hooks complete guide](https://hidekazu-konishi.com/entry/claude_code_hooks_complete_guide.html)
- [Endor Labs — Agent Governance using Hooks](https://www.endorlabs.com/learn/introducing-agent-governance-using-hooks-to-bring-visibility-to-ai-coding-agents)
- [Cursor agent-trace explainer (Axiom)](https://axiomstudio.ai/blog/cursor-agent-trace-explainer)
- [Fingerprinting AI Coding Agents (arXiv 2601.17406)](https://arxiv.org/pdf/2601.17406)
- [AI Code Governance Tools 2026 (Superblocks)](https://www.superblocks.com/blog/ai-code-governance-tools) · [Best AI Code Security 2026 (Truefoundry)](https://www.truefoundry.com/blog/best-ai-code-security) · [Top 12 AI dev tools 2026 (Checkmarx)](https://checkmarx.com/learn/ai-security/top-12-ai-developer-tools-in-2026-for-security-coding-and-quality/)
- [AI Guardrails Implementation Guide 2026 (Maxim)](https://www.getmaxim.ai/articles/the-complete-ai-guardrails-implementation-guide-for-2026/)
- [pre-commit-opa](https://github.com/anderseknert/pre-commit-opa) · [OPA vs Semgrep (ScaleSec)](https://scalesec.com/blog/battle-of-policy-as-code-tools-opa-vs-semgrep/) · [Git hook frameworks comparison](https://www.andymadge.com/2026/03/10/git-hooks-comparison/)
