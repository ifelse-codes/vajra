# Vajra — Crystal Clear

> Status: target product vision. The current repo implements the enforcement floor today;
> the full pipeline + buyer-facing ledger are not built yet (stated plainly below — no overclaim).
> **Reframed 2026-07-09 (S53):** the product is **provable agent governance**, and its shape is a
> **governed multi-agent SDLC pipeline.** See `docs/decisions/DECISION-001-governance-as-product.md`
> (governance-as-product + the pipeline refinement) for why this supersedes the S46 "better work" lock.

## One sentence

**Vajra is one command-line tool that makes any AI coding agent follow your rules — provably — and gives you an auditable record of what it did, while the agent does the actual coding.**

## The simple picture

- **The AI agent** = the driver (writes code, makes branches, creates files)
- **Vajra** = the governor + co-pilot (enforces the rules at the moment of action, feeds the right context, records what happened — never drives itself)
- **You** = the team principal (you set the policy; Vajra makes the agent honor it and proves it did)

**Guardrail *and* co-pilot.** Vajra rides along: it guides the agent to the next step *and* stops the actions your policy forbids — before they happen, not after — then leaves a record you can audit.

## What Vajra actually is (the reframe)

The thing that worked, live, every session across two months of dogfooding is **governance / drift-prevention**: the agent provably followed the rules. The thing we tried to lead with — "your AI does better work" — was measured twice (S51 README, S52 dist-build) and came back **n=2 null** (no measurable work-quality win; +12–19% cost; on the hard task both arms produced the *same solution and the same bug*). So we lead with what's real.

| | Status |
|---|---|
| **Provable rule-following** (enforced, not advised) | ✅ real today — live-verified S46; fired live S51/S52 |
| **Drift-prevention** (agent stays on the goal + the process) | ✅ real today — governed GT caught real drift (S52) |
| **"Does better work"** | ⚠ **hypothesis, not the pitch** — n=2 null; kept, not led |
| **Cross-agent tamper-evident audit ledger** (the moat) | 🔴 **aspirational — 0 cross-agent code today** |

## The shape — a governed multi-agent SDLC pipeline

Vajra's session loop generalises into a **pipeline of specialised agents**, one per SDLC stage — each with a single duty and a scoped context. They don't chatter; they **hand off through governed artifacts** (a blackboard), and Vajra **enforces every handoff**: preflight → entry gate → run the specialist → exit gate (verify exit-0 / human token) → write the artifact → **record a delta (+added / ~changed / −removed)** → log the decision → checkpoint.

| Stage | Specialist | Duty | Artifact | Gate |
|---|---|---|---|---|
| Requirements | **Analyst** | vague intent → structured spec + acceptance | `spec.md` | human ✋ |
| Architecture | **Architect** | design + ADR | `design.md` + ADR | human ✋ |
| Plan | **Planner** | design → tasks | `tasks.md` | verify: covers the spec |
| Build | **Developer** | code per task | code | verify: builds |
| QA | **QA** | tests · lint · types · security | results | verify: exit 0 |
| Review | **Reviewer** | review + score | `review.md` | score ≥ bar |
| Demo | **Demo-builder** | prove it runs | demo | human 👁 |
| Deploy | **Releaser** | guarded release + rollback | runbook | human ✋ |
| Monitor | **Monitor** | watch + alert | — | later |

**Why this is a product and BMAD/Spec Kit aren't:** they *describe* these stages (role prompts / markdown); **neither enforces or proves the handoff.** Vajra's version = the same pipeline with **gates + a delta ledger = provable, and cross-agent.** That is the governance wedge, given a shape. It also closes the two gaps we found vs Spec Kit/OpenSpec: **delta tracking** (every handoff emits +/~/−) and **SDLC breadth** (the stages *are* the breadth).

**Own the spine, borrow the polish.** Vajra's `.ai/` already *is* spec-driven development *with teeth* — so **Spec Kit / OpenSpec / BMAD are reference designs, not runtime dependencies** (borrow their artifact ideas: structured spec + acceptance criteria, Kiro EARS, OpenSpec delta markers — you have the pattern, not the polish). **Serena** *is* a real dependency (code-index / LSP — a capability Vajra lacks). The **Borrow Engine**: each stage we build starts by studying how the incumbents do that stage's artifact, and adopting the best.

**Build path:** **S54 = the Analyst stage** (vague intent → `spec.md` + acceptance + first delta), then **one governed stage per session.** The cross-stage delta ledger arrives once stages produce deltas to record.

## What it does

| # | Job | Plain meaning | Real today? |
|---|---|---|---|
| 1 | **Enforces discipline at action-time** | Blocks the forbidden action (push to main, `gh pr create`, session drift) *before* it runs — exit 2 | ✅ |
| 2 | **Keeps memory + feeds context** | The agent never forgets the vision, roadmap, rules between chats; the co-pilot surfaces the right rule at the right corner | ✅ |
| 3 | **Delta-tracks each stage** | Every handoff records +added/~changed/−removed → a provable trail across the pipeline | 🔴 not shipped (the pipeline build, S54+) |
| 4 | **Works across agents** | One governance layer over Claude, Cursor, Codex, others | 🔴 Claude-only today |
| 5 | **Saves a few tokens** *(bonus)* | Trims long successful output; failures pass through | ✅ (small $) |

## The differentiator — the make-or-break

**"Isn't this just a good `CLAUDE.md` + git hooks + a linter?"** The honest answer:

| Layer | What it enforces | The gap Vajra closes |
|---|---|---|
| `CLAUDE.md` / `AGENTS.md` | nothing — **advisory, the agent skims and ignores it** (proven S31) | Vajra's hooks *intercept*; the rule is enforced, not requested |
| git hooks (`pre-commit`/`pre-push`) | only at **git boundaries**; `--no-verify` bypasses; **blind to `gh pr create` / `gh pr merge`** (GitHub API, no git hook fires) and to the agent's mid-turn Edit/Write/Bash | Vajra fires on the **tool call**, before it runs — including non-git outward actions and mid-turn edits |
| a linter | code style/correctness | Vajra governs **agent behavior + process** (session state, one-chat-per-session, N→N+1) |

**Also real, and git-hooks don't have it:** a **session/process state machine**, a **context co-pilot** (`⚡on` surfaces the right file at the right action), and a **fail-closed** posture (*a check that cannot evaluate FAILS* — jq-missing blocks, S42; linters/hooks usually fail open).

**Honest verdict (the gate):** the reframe **PASSES on enforcement-depth** — Vajra assembles a governance layer that `CLAUDE.md` + git hooks + a linter cannot. It does **NOT** yet win on the *headline* moat (the cross-agent, tamper-evident **ledger**), because that is unbuilt. So today Vajra is a *better-enforced governance layer*; the thing a buyer would **pay to keep** — the provable, delta-tracked pipeline record — is the pipeline build (S54 = the Analyst stage). We record that tension rather than paper over it.

## Who pays, and for what pain (ICP)

**Teams running AI agents on client or regulated code who must *prove* the agent behaved.**

- An **agency / consultancy** running Claude Code on a client's codebase: *"I need to show the client my AI didn't push to main, didn't touch out-of-scope files, followed the change process."*
- A **multi-agent shop** (Claude + Cursor + Codex): *"I need one governance layer and one audit trail across all of them."*
- A **regulated team** (fin/health): *"I need an auditable record that agent-written changes followed policy."*

**Job-to-be-done:** *give me a provable, enforced, auditable record that my agent followed the rules* — not a prompt that asks it to.
**Honest caveat:** the pain is real and enforcement is real, but the artifact they'd pay for (the audit ledger) doesn't ship yet — which is exactly why it's the next build.

## What "better work" becomes

Not disproven — **under-tested.** Two single-shot bounded tasks (README, dist-build) can't test the long-horizon claim that governed context prevents drift and re-work over a *whole project*. So we **keep it as a stated hypothesis**, revisited only with a longer-horizon test — never as the pitch. Memory `vajra-direction-b-copilot`.

## The two speaking skills (unchanged, still shipped)

- **Varta** *(the agent's lane)* — a compact `⚡` language the agent internalizes at boot and speaks all session over the live `.ai/`. The co-pilot lives here: `⚡on(cond) ⚡include "files"` — right rule, right corner. Skill, not a compiler.
- **Darshan** *(the human's lane)* — one rule: *render the richest visual this surface can handle; always glanceable; never drop meaning.* Skill, not a renderer.

## What makes it different

- **Enforced, not advised** — the agent follows the rules provably; `CLAUDE.md` only asks
- **Action-time, not git-boundary** — catches `gh pr create` and mid-turn edits that git hooks can't see
- **Fail-closed** — a check that cannot evaluate blocks; no silent pass
- **Local-first, git-native** — no cloud, no retention cliff (vs SaaS governance)
- **Honest** — modest token savings, "better work" unproven, cross-agent unbuilt — all stated

## Rules

- Vajra **guides + governs**, the agent **does the work** — Vajra never touches code itself
- It is **not done until it runs** on your machine — never trust code that only *looks* done
- The **pipeline** — starting with the **Analyst stage** (S54), one governed stage per session — is the next build; everything else is decoration

## Honest truth

- The enforcement floor is real and live-verified; the moat (cross-agent tamper-evident ledger) is not built
- Competitors exist (AxonFlow ships ~80% of the vision; Cursor's `agent-trace` spec occupies cross-agent attribution) — the edge is local-first + git-native + fail-closed + the open format
- This is a strong, honest project with a clear next build: make governance *sellable* by making it *visible*

## In one breath

*Vajra is a governed multi-agent SDLC pipeline: every stage a specialised agent, every handoff enforced, delta-tracked, and provable — on top of any coding agent.*
