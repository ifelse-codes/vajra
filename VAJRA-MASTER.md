# Vajra — Master Brainstorm Document

**The single source of truth. Consolidates the full brainstorm phase (vision + S1–S4 + process).**
**Date:** 2026-06-14 (rev. 2026-06-15; Headroom lessons added 2026-06-22) · **Author:** Suman · **Status:** Design phase IN PROGRESS — Session 1 done → [ADR-0001](docs/adr/0001-compression-delivery-mechanism.md) ✅ Accepted. Brainstorm CLOSED.

> **Vajra is the vendor-neutral control plane for agent-written code: it audits and governs
> what your coding agent does — and makes it cheaper on the way in.** Open-source. Works over
> any coding agent (Claude Code, Codex, Kimi, Cursor, Aider…). Greenfield — no reuse of the
> old `akrti` prototype.

---

## Table of contents
1. The thesis (what Vajra is, in one breath)
2. The problems it kills
3. The one idea that makes it work
4. The build process & specialist-panel method
5. S1 — Is the idea sound? (expert review)
6. S2 — What exactly is v1? (scope)
7. S3 — Trust & token economics (the pivotal finding)
8. S4 — Positioning, moat & OSS launch
9. The net thesis (locked decisions)
10. Open decisions & what to do next

---

## 1. The thesis

You already use a coding agent. **Vajra wraps it** — it doesn't replace your agent and
doesn't care which one you picked. It makes the **agent better** (no drift/amnesia/bad-commits),
makes **you better** (one branch, one session, one story), and makes you **deliver** (verified
work, fewer tokens). Usage is simple: `vajra claude`, `vajra codex`, `vajra kimi`.

But the brainstorm phase sharpened this from "make any agent better" into a precise wedge +
moat (see §7–§9): **ship free compression to land users and prove the rail; bet the company on
a cross-agent governance + audit ledger.**

**Agents worth wrapping (the surface):** Claude Code · Codex · Kimi · Cursor · Aider · Gemini
CLI · Cline · Continue · Windsurf · Kilo Code · Goose · Roo Code / OpenHands. The list grows;
the promise doesn't change.

---

## 2. The problems it kills

| # | Developer pain | How Vajra owns it |
|---|---|---|
| 1 | Cross-session amnesia | Agent-native memory file Vajra writes (cache-safe) |
| 2 | Silent drift (state lies vs. repo) | Drift checks in the environment, not the context window |
| 3 | Mid-session scope creep | 1 story / few files / time cap, enforced at the action boundary |
| 4 | Bad/autonomous commits to `main` | Git-hook + shim guards (silent) |
| 5 | Token waste on noisy output | Failure-aware shell-output compression (the v1 feature) |
| 6 | Token waste on ceremony | Discipline lives in the env, not the prompt — ~0 context tax |
| 7 | "Which session am I in?" | Single-integer session state |
| 8 | No idea what a session cost | Honest, cache-adjusted meter |
| 9 | **No record of what the agent actually did** | **The cross-agent audit ledger — the moat (§8)** |
| 10 | Cross-agent lock-in | Wrapper sits below all agents via per-agent adapters |

---

## 3. The one idea that makes it work

> **Put the discipline in the environment, not in the prompt.**

Most "agent workflows" are rules you paste into the agent — re-read every session (burning
tokens) and ignorable. Vajra enforces them **around** the agent (in the wrapper that launches
it), so the agent can't misbehave, the rules cost ~0 tokens, and it works for **any** agent.
This also dissolves the old "discipline *or* token savings?" dilemma — discipline isn't paid
for in tokens.

---

## 4. Build process & specialist-panel method

**Greenfield → open source, via a deliberate 5-phase pipeline. Don't advance until each
phase's "done when" is true.**

| Phase | Goal | Done when |
|---|---|---|
| **1. Brainstorm** ✅ | Explore from many expert lenses; surface risks & the real wedge | Thesis + wedge agreed; no major unknown unnamed |
| **2. Design** ◀ next | Turn conclusions into concrete designs + trade-off decisions | Every key choice has a decided option + rationale |
| **3. Lock Architecture** | Freeze decomposition + decisions (ADRs) | ADRs signed; no "TBD" in the critical path |
| **4. Code** | Implement against the locked architecture | Killer feature ships, measured net-cheaper |
| **5. Ship** | Public OSS release | Show HN / public release live |

**The specialist panel (the brain trust):** spawned agents with sharp, narrow mandates.
Core 4 = Systems Architect · Principal Engineer · Agent-Practitioner · Investor. Expansion =
DevTools PM · DevEx/CLI designer · Security & Privacy · OSS/DevRel · LLM Cost Economist ·
Red-Team · Competitive Analyst. Pick 3–5 per session.

**Method — 3 rounds per topic:** (1) **Divergent** — each lens writes blind to the others;
(2) **Cross-examine** — feed each the others' briefs, attack/defend → consensus & real
disagreements surface; (3) **Synthesize** — a chair produces the decision doc. Always end with
**Red-Team**. Force one wedge / one decision per session.

**Roles:** Suman = product owner (picks the wedge, approves phase transitions, signs ADRs).
Claude Code = facilitator (spawns the panel, runs rounds, synthesizes, writes docs, codes phase 4).

---

## 5. S1 — Is the idea sound? (Architect · Principal Eng · Investor · Practitioner)

**Unanimous engineering finding (the most important early takeaway):**
> Mutating the request prefix to "inject memory" or "dedup" almost certainly **breaks
> Anthropic prompt caching → RAISES cost.** The old `akrti` S01 dedup is a footgun. **Delete
> the prompt-mutation path.** Free savings come from elsewhere.

**The six decisions that emerged (D1–D6):**
- **D1 — Proxy is read-only** (meter + budget tripwire only; never rewrites the body).
- **D2 — No prompt-prefix mutation** (kills the cache-invalidation footgun).
- **D3 — Memory via agent-native context file** Vajra writes, not injection.
- **D4 — Per-agent base-URL adapters** (`ANTHROPIC_BASE_URL`/`OPENAI_BASE_URL`), not `HTTP_PROXY`/MITM.
- **D5 — Lead feature = failure-aware shell-output compression**, lossless-on-demand.
- **D6 — Governance/audit is the moat layer**, built after the compression hook lands.

**Investor verdict at S1:** WATCH. As a "universal token-saving wrapper" it's a feature
vendors absorb. The durable company = a **vendor-neutral governance/audit control plane** for
agent-written code. (This thesis was vindicated by the S3 economics.)

---

## 6. S2 — What exactly is v1? (PM chair · Practitioner · Principal Eng · Red-Team)

**v1, one line:**
> `vajra claude` — a **Rust** PATH-shim launcher (**no proxy**), Claude Code only, whose lead
> feature is **failure-aware, lossless-on-demand shell-output compression**, proven to
> net-save **blended/cache-adjusted dollars** on a realistic task mix with **zero task-success
> regression**. Nothing else.
>
> **⟳ Amended by [ADR-0001](docs/adr/0001-compression-delivery-mechanism.md) (2026-06-15):** v1 delivers
> compression via the Claude Code **`PostToolUse` hook** (session-scoped `claude --settings`), **not** a
> PATH-shim. The shim is re-scoped to the future **cross-agent governance/audit rail**. Everything else stands.

**Strong consensus:**
- **No proxy in v1** — compression lives entirely in the shim; measure tokens from Claude
  Code's own session JSONL. (Cuts the project's riskiest component.)
- **Rust** — single static binary; sub-ms shim startup (we're on the hot path of every
  command). Node disqualified (~80ms startup × thousands of calls).
- **Claude Code first** — prove net-cheaper on one before any 2nd adapter.
- **Compress success/logs; pass failures verbatim;** `VAJRA_RAW=1` lossless escape; **fail-open**.
- **Day-1 killer to avoid:** silently dropping a line the agent needed → agent loops → blamed →
  uninstall. Lossless-on-demand + visible `[N lines hidden]` breadcrumb is non-negotiable.
- **Out of v1:** proxy, memory, governance, 2nd agent, MCP — all v2+.

**In / Out of scope:**

| IN (v1) | OUT (v2+) |
|---|---|
| `vajra claude` launcher (single Rust binary) | Proxy / any network interception |
| PATH-shim capturing stdout/stderr/exit | Prompt-prefix mutation, dedup (deleted — D2) |
| Failure-aware compression + heuristics (§6.2) | Memory / native context-file generation |
| `VAJRA_RAW=1` + `[N lines hidden]` breadcrumb | Governance: commit-block, file-cap, verify |
| Per-tool off-switch | Policy/audit dashboard (the paid moat) |
| Token measurement from CC session JSONL | `vajra codex` / 2nd agent · adapter generalization |
| `--report` blended-dollar P&L | MCP `ctx_read` / AST outlines |
| `curl \| bash` install · Apache-2.0 OSS repo | Read-only metering proxy (→ v1.1) |

### 6.1 User journey (6 steps)
1. `curl -fsSL vajra.sh | bash` → single binary on PATH.
2. `vajra claude` in any repo — no config, no flags.
3. Claude Code boots normally; Vajra invisible.
4. Agent runs `cargo test`/`git log` → noisy **success** returns compressed (`142 passed`).
5. Agent hits a real failure → full traceback passes through **verbatim**.
6. Session ends → honest receipt: *"~$0.18 vs ~$0.24 bare (−25%), 0 raw-recoveries. `VAJRA_RAW=1` for full."*

### 6.2 Compression heuristics (v1 default rules)

| Command class | Rule |
|---|---|
| Test runners (`pytest`/`jest`/`go test`/`cargo test`) | exit 0 → summary line only · exit≠0 → failing tracebacks verbatim + collapse passing to `N passed` · >400 failing lines → head+tail+RAW |
| Build/compile (`cargo build`/`tsc`/`make`) | exit 0 → `build ok` · exit≠0 → error lines + context, drop "Compiling X" spam |
| `git log` / `git diff` / `git status` | log: cap N entries, drop body · diff: passthrough if agent narrowed it, else head+tail · status: passthrough |
| `ls -R` / `find` / `tree` | always → count + sampled paths + RAW |
| Package installs (`npm/pip install`) | exit 0 → final line · exit≠0 → keep error |
| **Cross-cutting** | **Never compress small failing output (exit≠0 AND <~400 lines)** — agent is mid-debug. Fail-open if unsure. |

**Reference impl + test corpus (study, DON'T copy — Vajra is greenfield):** the abandoned `akrti` repo already implements these exact heuristics with passing tests — `akrti/src/hooks/{cargo,git,pytest,npm,docker,generic}.rs` + `src/ctx/compress.rs`. ⚠ **`akrti/src/proxy/optimizer.rs` is the cache footgun** — the dedup / orphan-strip logic D2 (§5) says to delete; study what NOT to carry forward. A real captured corpus (6 commands, raw→ideal) lives in `research/compression-fixtures/` (e.g. `cargo build` 181→1 line; `cargo test` 86→3; passthrough gates proven on small `git status`/`diff`). **Net:** the folding heuristics are a near-solved problem with a working reference next door; the *novel* v1 work is the delivery hook (ADR-0001) + honest meter + lossless-on-demand discipline.

**Headroom learning note (2026-06-22):** `research/HEADROOM-LESSONS.md` is now a mandatory
learn-only reference before changing wrapper UX, raw recovery, benchmark methodology,
memory/MCP surfaces, or output-token policy. The boundary is explicit: learn design lessons,
do not copy code, docs, names, benchmark claims, or dependencies. The key implication is that
Vajra must not become "another compression platform"; compression remains the wedge, while
governance/audit/cost control remains the product identity.

### 6.3 The kill-or-confirm experiment
Fixed noisy-failing test repo; agent must diagnose + fix. Same task **×5 per arm**, interleaved,
median. **PASS** iff `median$(Vajra) < median$(bare)` AND identical task success AND
`raw_recoveries == 0`. **KILL** if it saves ~nothing, ever fails a task bare passed, or routinely
forces `VAJRA_RAW=1`.

---

## 7. S3 — Trust & token economics (Cost Economist · Security Eng · Principal Eng)

### 7.1 The pivotal finding
> Failure-aware shell-output compression honestly saves **~6–8% blended dollars** (range 5–12%,
> ~3% floor on output-bound tasks) — **real, but too small to be the company's value prop.**

**Why:** a compressed tool result is billed full-price **once**, then at 0.1× (cache-read)
forever. "Cut 90% of bytes" ≈ single-digit % of dollars — compression saves the *cheapest* bytes.
This confirms the Red-Team and **forces the pivot to governance.**

**Honest cost formula** — CORRECTED 2026-06-15 by live JSONL recon (`research/JSONL-RECON.md`, CC v2.1.177): the S3 model assumed ONE cache-write tier; the real schema has **two**, plus separately-billed server tools and mixed models. Price PER `assistant` line BY `.message.model` (sessions mix models — opus main, haiku titles/subagents), summed across the main JSONL **and every `*/subagents/*.jsonl`**:
```
$line = ( input_tokens              · in
        + output_tokens             · out
        + ephemeral_5m_input_tokens · in · 1.25     # 5-min cache write
        + ephemeral_1h_input_tokens · in · 2.0      # 1-hour cache write — NOT 1.25×
        + cache_read_input_tokens   · in · 0.10 ) / 1e6
        + web_search_requests · price.web_search    # server_tool_use billed PER-REQUEST,
        + web_fetch_requests  · price.web_fetch      #   not token-priced — add on top
```
| Component | Rate | Compression effect |
|---|---|---|
| `cache_read` | 0.1× | ~zero (most tool output lives here after its turn) |
| `cache_write` | **5m 1.25× / 1h 2×** (two tiers) | real, one-time; price the tiers separately |
| `server_tool_use` | per-request | web_search/web_fetch — separate line items, not token-priced |
| `input_uncached` | 1.0× | real, full-price, one turn only |
| `output` | **25×** | **the real lever** — but not a byte-count saving |

**Five silent-miscount traps:** (1) `cache_creation_input_tokens` = the 5m+1h **sum** — use the split, never both; (2) **aggregate subagent JSONL files** or undercount a whole session; (3) **skip `<synthetic>` model lines** (non-billable); (4) `iterations[]` repeats top-level usage — don't double-add; (5) usage lives at `.message.usage` on `assistant` lines only. **Good news:** everything the meter needs is in these files — the **no-proxy v1 decision holds**, and the richer fields enable a *more* precise honest P&L.

**What v1 should actually optimize for real dollars:** (1) prevent failure-induced **re-run/loop
turns** (output tokens, 25×); (2) **cache-write avoidance** (never perturb the prefix); (3)
position compression as honest **proof-of-rail + meter**, not the value prop.

### 7.2 The benchmark task distribution (so the number isn't cherry-picked)

| Category | Weight | Why |
|---|---|---|
| Test-fix loop (noisy suite + 1 real failure) | 25% | compression's best case |
| Feature add w/ build+test cycles | 20% | mixed |
| Debug from stack trace | 15% | failures pass verbatim → ~0 win (honesty check) |
| Greenfield codegen (little shell output) | 15% | output-bound → ~3% floor |
| Repo exploration (`ls -R`/`find`/`git log`) | 15% | cherry-pick zone — *capped* |
| Dependency install / migration | 10% | install spam compresses well |

Headline = weighted blended-$ delta; per-category deltas disclosed.

### 7.3 Measurement traps & controls (locked into the harness)
Interleave arms (kill cache-cold inflation); headline in blended `$` only; any `VAJRA_RAW=1`
re-run = per-task FAIL; count turns (turn regression = FAIL even if $ lower); split direct-byte-$
vs output-$; identical binary task success or KILL; lock denominator = bare-arm dollars.

### 7.4 Trust & privacy posture (proxy gone → trust = install + local data)

**Surfaces by blast radius:** (1) `curl|bash` install (worst — arbitrary code) · (2) session
JSONL reader (code+prompts+secrets) · (3) PATH shim · (4) shim correctness.

**PATH-shim mitigations:** scope the shim dir to the child process env only (never edit shell
rc); resolve the real binary excluding the shim dir + loop-guard; **fail-open** (`exec` real
binary unmodified on any error, exit code verbatim); `execv` with original argv — never `sh -c`.

**Install trust:** pinned/versioned/SHA-256-checked installer; signed releases (minisign/cosign)
+ public key in README; `cargo install` + Homebrew + raw release binaries as first-class
alternatives (never *require* `curl|bash`); reproducible builds / provenance as stated intent.

**Data rule:** JSONL + command output are **read-only, in-memory, in-process, aggregate-only**
(numeric counts, not content) — never persisted, never transmitted.

**The 5 day-0 trust commitments:** (1) zero runtime network calls (verifiable offline) · (2) no
telemetry without explicit opt-in · (3) code/prompts never leave the machine or hit disk · (4)
fail-open by design · (5) verifiable, signed, reproducible.

### 7.5 The measurement harness (`bench/`, Python — offline)
```
bench/
  run.py          # interleaved A1/A2 ×5, resets repo@sha, `claude -p --output-format json`
  parse_jsonl.py  # main + */subagents/*.jsonl -> per-model token sums; split 5m/1h cache tiers; skip <synthetic>; (schema-guarded)
  pricing.toml    # per-model $/MTok (in/out, 5m=1.25x, 1h=2x, read=0.1x) + per-request web_search/web_fetch; versioned
  oracle.py       # tasks/<id>/verify.sh -> bool (tests green AND source changed, not deleted)
  detect.py       # raw_recoveries, turns_delta, lines_hidden
  report.py       # -> report.json + report.md
  fixtures/session_v<ver>.jsonl + expected.json   # drift tripwire (CI red = schema changed)
```
**Three trust pillars:** fixture tripwire (catches silent JSONL schema drift — never coerce a
missing key to 0) · interleaved arms (kills cache-cold inflation) · exit-code oracle (success
isn't a vibe). Pin Claude Code version + `--model` + frozen prompt + `git reset --hard <sha>`
before each run. ×5/arm, median + min/max.

---

## 8. S4 — Positioning, moat & OSS launch (Investor · OSS-DevRel · Competitive Analyst)

### 8.1 The moat (the central strategic insight)
> **Not** "block a commit" (commodity — git hooks & Claude Code hooks already do it), and **not just
> "cross-agent"** (AxonFlow + Cursor's open `agent-trace` spec already reach for that — see §8.1a). The
> defensible, **structurally vendor-proof** moat is the **local-first, git-native, tamper-evident,
> cross-agent AUDIT LEDGER:** *"prove what your agents did — which agent, session, prompt and **line/diff
> hunk** — in one trail that **lives in your repo** (survives forks/rebases, no retention cliff, no cloud),
> emitted in the open `agent-trace` format."*

Why vendors can't take it: a single-agent vendor **can't credibly self-audit** (independence),
and **neutrality across competitors is a conflict of interest** for them. Lead governance with
*"prove what your agents did,"* not "block a commit."

**§8.1a Competitive reality (REVISED 2026-06-15 by teardown — `research/COMPETITOR-TEARDOWN.md` + `AGENT-TRACE-AND-AXONFLOW.md`):** the S4 "empty intersection" is **less empty than claimed.**
- **AxonFlow** (`getaxonflow/axonflow-claude-plugin`, MIT + freemium) already ships ~80% of the governance vision: hook-based (PreToolUse blocks, PostToolUse audits + PII scan), 80+ built-in policies, policy-as-code, search/export. **Closest competitor — the benchmark to beat.**
- **Cursor `agent-trace`** (CC BY 4.0, open) is a **neutral, line-level, cross-agent attribution spec** — it already occupies part of the "cross-agent attribution" white space *as a public standard*.
- **Endor Labs / Checkmarx** etc. — security incumbents entering agent governance; they own the enterprise compliance buyer.
- Post-hoc **behavioral fingerprinting** (arXiv 2601.17406, 97.2% F1) can attribute an agent *without a wrapper* → our edge must be **real-time, write-time provenance + enforcement**, not merely "we can tell which agent."

**So neutrality + "cross-agent" alone is no longer the moat.** The sharper, defensible wedge:
1. **Adopt — don't reinvent — `agent-trace`** as the emitted provenance format (interop > NIH); compete on the **recorder + ledger**, not a rival schema. *(Becomes a governance-phase ADR.)*
2. **A git-native, permanent, tamper-evident ledger** (hash-chained JSONL / git notes, committed to the repo) — survives forks/rebases, no SaaS retention cliff. None of the above does this cleanly.
3. **Write-time provenance at line/hunk granularity** (which agent+session+prompt produced *this* diff) — what post-hoc fingerprinting can't reliably do.
4. **Beat AxonFlow on its own published weaknesses:** in-process **Rust** engine (no network in the decision path; fail-closed option) vs its **fail-open-on-network**; **local-first / zero egress** vs community-SaaS data egress; **free + unlimited local** vs its throttled 200/day free tier; **permanent repo ledger** vs its **3-day** free retention; single compiled binary vs Bash hook scripts.
5. **Copy what AxonFlow gets right:** zero-config auto-enforcement (policies on by default), the inline `decision_id → explain_decision → create_override` UX, async/non-blocking audit writes, a **<10 ms/tool** latency budget, and its built-in categories as a starter policy pack.

**Sharpened one-line moat:** *"the local-first, git-native, tamper-evident flight recorder for AI-written code — uniform across every agent, in the open `agent-trace` format — that also enforces policy, with no cloud and no retention cliff."*

**Defensibility ranking (most→least durable):** (1) git-native portable tamper-evident ledger · (2) write-time line-level provenance · (3) audit/compliance trail · (4) cross-agent uniformity · (5) policy-as-code runtime · (6) honest meter (credibility, not a moat).

### 8.2 Positioning (locked)
> "Vajra is the vendor-neutral control plane for agent-written code: it audits and governs what
> your coding agent does — and makes it cheaper on the way in."

**On-ramp → moat journey:** Land (free compression installs the rail) → Trust (honest meter) →
Reveal pain (the session log is a proto-audit trail) → Convert (paid policy + cross-agent audit
ledger) → Lock (team adds a 2nd agent; Vajra is the one place policy + audit live).

### 8.3 Business model (don't overreach)
| Tier | What | Posture |
|---|---|---|
| **OSS — free forever** | Shim, compression, heuristics, honest meter, solo local git guards, `VAJRA_RAW` | Apache-2.0, never gated |
| **Team (paid)** | Shared policy config, persistent cross-agent audit log, fail-closed verify gates, CI/PR integration | Per-seat |
| **Enterprise** | SSO, audit retention/export, compliance attestation, central policy, SIEM export | Annual |

**Rule:** helps one developer = free; lets an org govern many = paid. **Never paywall the
compression on-ramp.**

### 8.4 OSS launch
- **License: Apache-2.0** open rail (patent grant + trademark non-grant); governance layer
  separate under commercial/BSL-1.1 (3-yr Apache conversion).
- **Hero artifact:** the honest receipt + a ~15s asciinema GIF. Own the small number —
  *"~6–8%, here's why it's not more; run the benchmark yourself."* Disclosing the weak
  categories is the viral move on a skeptical crowd. **Honesty is the brand.** Public hard
  rule: any forced `VAJRA_RAW=1` re-run = a bug.
- **Contributor funnel:** `heuristics/` = declarative TOML rules, one per tool + golden fixture.
  "Add your favorite tool" = good-first-issue, no Rust needed. Gate every heuristic PR on the
  fail-open + lossless invariant test.

### 8.5 Naming (DECIDED 2026-06-15)
- **Brand = "Vajra"; binary/crate = `vajractl`** (crates.io `vajra` is taken → `cargo install vajractl`).
- Homebrew `vajra` free; use a GitHub org; **confirm `vajra.sh` ownership** before public launch.
- SEO note: collides with a pentest framework (`r3curs1v3-pr0xy/vajra`) + Vajra-Tech/Systems —
  acceptable; the `vajractl` binary name disambiguates.

### 8.6 Traction metric
**Day-30 retained installs with ≥1 governance policy actively enforcing** (blocking/logging real
actions) — the observable proof the compression on-ramp recruited a governance user. Not stars,
not tokens-saved.

---

## 9. The net thesis (locked)

- **v1 (ship):** `vajra claude`, Rust PATH-shim, failure-aware compression, honest meter. Proves
  the rail; ~6–8% honest savings; the trojan horse — **not** the product.
- **The company (bet):** vendor-neutral, attributable, **cross-agent audit ledger** + policy
  plane for agent-written code. Lead with *"prove what your agents did."*
- **Hard technical rules:** read-only/no-mutation of the request prefix (cache); no proxy in v1;
  fail-open shim; lossless-on-demand compression; per-agent adapters; Rust single binary.
- **Trust:** 5 day-0 commitments; `curl|bash` is the #1 surface to harden; zero runtime network.

---

## 10. Open decisions & what to do next

**Both gates resolved (2026-06-15):**
1. **Naming — DECIDED.** Brand = Vajra; binary/crate = `vajractl`. (§8.5)
2. **Validation — DEFERRED by founder.** Build v1 and **dogfood it daily / ship first, validate
   later** — dogfooding is the validation. The governance-demand assumption is an accepted known
   risk, not a pre-build gate. **Build proceeds.**

**Live design tensions (for the Design phase):**
- **Tension A — product vs proof-of-rail:** resolved in principle — compression proves the rail
  + emits an honest meter; the company is bet on governance. Confirmed by S3/S4.
- **Tension B — PATH-shim vs Claude Code `PostToolUse` hook** for delivering compression:
  **✅ RESOLVED by [ADR-0001](docs/adr/0001-compression-delivery-mechanism.md) (2026-06-15) → HOOK.**
  Design Session 1 (Architect · Principal Eng · Practitioner, closed by Red-Team) chose the hook: it
  compresses at the *final tool-result boundary* (the shim sits at an inner per-binary boundary and would
  corrupt pipelines like `cargo test | tail`), and a live experiment confirmed `updatedToolOutput` reduces
  *billed* tokens (cache-creation 21081→6734), not just the transcript. The shim is re-scoped to the future
  cross-agent rail; compression logic becomes a reusable engine behind the adapter trait. See the ADR for the
  mandated guardrails (contract-pinning/fail-safe, settings-merge, keep-the-rail-real) and the one reversal condition.

**Phase — Design (in progress).** ✅ Session 1 (Tension B) → [ADR-0001](docs/adr/0001-compression-delivery-mechanism.md). ✅ Session 2 (Engine trait + adapter contract) → [ADR-0002](docs/adr/0002-engine-trait-adapter-contract-module-layout.md) (2026-06-16).

ADR-0002 locked: `Engine` trait (`process()` → `EngineDecision` enum), `ClaudeCodeHookAdapter<E>` concrete struct (no adapter trait in v1), `{}` passthrough wire signal, compound-command dispatch fallback to generic heuristic, single-crate module layout, four adapter pre-checks (`tool_name`, `isImage`, `noOutputExpected`, `VAJRA_RAW`), and two new guardrails (G5 `tool_name` check, G6 confirmed-success-only compression). Settings merge deferred to DS3 with a stated minimum contract (G8).

**Remaining recommended order:**
- ✅ DS3 — `--settings` injector + compression heuristics → [ADR-0003](docs/adr/0003-settings-injector-and-compression-heuristics.md) (2026-06-16). Decided: tempfile + `spawn()+wait()`, merge algorithm (global+project+local hooks → dedup on `"vajractl"` substring → append Vajra entry), G9 schema validation, LINE_CAP=30, FAIL_PASSTHROUGH_CAP=400, per-tool heuristic contracts (cargo/git/pytest/npm/docker/generic), breadcrumb as header line, `git diff` content always passthrough.
- ✅ DS4 — meter/receipt → [ADR-0004](docs/adr/0004-meter-receipt-design.md) (2026-06-16). Decided: on-exit receipt to stderr (after `child.wait()`), session JSONL discovered by modified-time after `session_start`, `VAJRA_SESSION_STATS` sidecar env var for compression stats (first token + lines_in/out, no content), pricing compiled-in via `include_str!`, compact 3-row receipt by default (`VAJRA_VERBOSE=1` for breakdown), warn+estimate on schema drift (not hard error), G10 (cwd-slug conformance test), G11 (tripwire release gate), G12 (no content in sidecar).
- Research note — Headroom lessons → [research/HEADROOM-LESSONS.md](research/HEADROOM-LESSONS.md) (2026-06-22). Decided: learn only, do not copy. Feed raw-output recovery, wrapper UX, cache safety, benchmark, governed-memory, MCP, and output-policy design.
- DS5 — measurement harness (`bench/`, Python, offline benchmark protocol from §7.5). **Design phase is COMPLETE after DS4 — DS5 may proceed straight to implementation of the Python harness since §7.5 specifies it fully.**
- (v2) governance/audit data model + the cross-agent shim rail.

---

*This master replaces the separate brainstorm docs (VISION, EXPERT-REVIEW, V1-SCOPE,
S3-TRUST-ECONOMICS, S4-POSITIONING, BUILD-PLAN). Lean by design — the doc obeys the same
discipline the product sells.*
