# Vajra — Crystal Clear

> Status: target product vision. **Corrected 2026-07-24 (S100 ground truth):** the enforcement floor,
> the full 8-station pipeline, and the attested verdict ledger are all **built** (S54–S72, S55–S59);
> what is unproven is the *trust* they are supposed to earn (Autopilot Ladder at Rung 1 of 3), and
> what is unbuilt is **cross-agent** (0 code). Stated plainly below — no overclaim in either direction.
> **Reframed 2026-07-09 (S53):** the product is **provable agent governance**, and its shape is a
> **governed multi-agent SDLC pipeline.** See `docs/decisions/DECISION-001-governance-as-product.md`
> (governance-as-product + the pipeline refinement) for why this supersedes the S46 "better work" lock.
> **Sharpened 2026-07-10 (S54, DECISION-002):** the heart of provable governance is **fidelity** (the
> agent delivered what was asked), verified *independently* — not just **discipline** (the rules were
> followed). S54 proved green gates ≠ faithful delivery. The fidelity auditor is the missing heart, in build.
> **Repositioned 2026-07-23 (S98, DECISION-005):** the **lead** becomes the *outcome* — **the autopilot
> trust layer: leave your agent working for days, come back, and trust the result.** The governed pipeline
> (below) stops being the pitch and becomes the **engine** that earns the trust. This changes the lead,
> not the disclosures — every honesty row below survives. See
> `docs/decisions/DECISION-005-autopilot-trust.md`.
> **Pivoted 2026-07-27 (S103):** sessions now **finish a shippable MVP** — the paid multi-day
> Autopilot-Ladder *sessions* and the machinery-freeze rule are retired (DECISION-005 SUPERSEDED); the
> founder owns the long unattended real-world test, then release. The product direction is unchanged —
> only how sessions are spent. S105 GT: engine done + proven, package ~0% (nothing installable yet);
> next build = **make it installable (v0.1)**.

## One sentence

**Vajra is the autopilot trust layer for AI coding agents: leave your agent working for days, come back, and trust the result — because every action it tried, everything Vajra blocked, the fidelity verdicts, and the receipt are on the record, and it provably followed your rules the whole time while the agent did the actual coding.**

*How it earns that trust (the engine):* one command-line tool that makes any AI coding agent follow your rules — provably — and gives you an auditable record of what it did. The outcome is the lead now; the governance pipeline is what makes the outcome true.

## The lead — autopilot trust (S98)

**The crown jewel is the loop you can bet on while away for days.** The canonical demo, for Hacker News and for an acquirer alike:

> *"I left Claude alone on a real repo for 3 days. Here's every action it tried, what got blocked, the fidelity verdicts, the receipt. I merged without reading every line."*

The 8-station governed pipeline (below) is the **engine** that makes that sentence true — the gates block the leaks, the fidelity auditor catches the illusions, the ledger + receipt make it all reviewable. You don't buy the engine; you buy the trust it earns. **How that trust gets proven** is the falsifiable **Autopilot Ladder** (Rung 1 hours → Rung 2 one day → Rung 3 two–three days across ≥2 repos, ending in the *merge-without-line-by-line-review* test) in `.ai/ROADMAP.md`.

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
| **Cross-agent tamper-evident audit ledger** (the moat) | 🟡 the **ledger is real but single-agent** (S59; 36 attested records, chain-verified INTACT). **Cross-agent = still 0 code** — the moat is one axis short |

## The sharper truth (S54) — discipline is not fidelity

Provable *rule-following* is real, but S54 exposed its limit as the whole product. Asked to build a 5-part
stage, the agent shipped **1 part**, self-certified, and **every green gate passed** (branch ✓ · file caps ✓
· `verify` 32/32 ✓ · `closeout` 8/8 ✓). Vajra enforced **discipline** (the rules were followed) but not
**fidelity** (the delivery matched what was asked). A governance layer that proves the rails and never checks
the cargo is only half a product — and the dangerous half, because a green gate *looks* like proof.

So the make-or-break is an **independent, adversarial fidelity / acceptance auditor** — the pipeline's
QA/Reviewer stage — that reads the prompt's requirements against the actual diff, cold, and rules each
`SHIPPED / PARTIAL / NOT-BUILT`, gating closeout. It cannot be a grep and it cannot be the builder grading
itself (both return green). **This is Vajra's missing heart** — the thing that makes "provable governance"
mean *provably delivered what you asked*, not just *provably followed the rules.*
(See `docs/decisions/DECISION-002-fidelity-over-discipline.md`.)

| | Status |
|---|---|
| **Discipline** — rules followed, provably (branch, caps, gates, session state) | ✅ real today |
| **Fidelity** — delivery == what was asked, judged independently + adversarially | ✅ **shipped** (S55 brain → S56 gate → S58 attested → S59 chained; 36 ledger records). 🟡 **caveat (S100):** waivable in one env var, and ladder runs use it |

## The engine — a governed multi-agent SDLC pipeline

**This is the engine, not the pitch (S98).** The pipeline is *how* autopilot trust is earned and made demonstrable: every stage a gate, every handoff enforced and delta-tracked, the whole run reviewable afterward. Vajra's session loop generalises into a **pipeline of specialised agents**, one per SDLC stage — each with a single duty and a scoped context. They don't chatter; they **hand off through governed artifacts** (a blackboard), and Vajra **enforces every handoff**: preflight → entry gate → run the specialist → exit gate (verify exit-0 / human token) → write the artifact → **record a delta (+added / ~changed / −removed)** → log the decision → checkpoint.

| Stage | Specialist | Duty | Artifact | Gate |
|---|---|---|---|---|
| Requirements | **Analyst** | intent → 3 options (A/B/C) → the next governed prompt | `prompts/NN-task.md` | human ✋ |
| Architecture | **Architect** | design + ADR | `design.md` + ADR | human ✋ |
| Plan | **Planner** | design → tasks | `tasks.md` | verify: covers the spec |
| Build | **Developer** | code per task | code | verify: builds |
| QA | **QA** | tests · lint · types · security | results | verify: exit 0 |
| Review | **Reviewer** | review + score | `review.md` | score ≥ bar |
| Demo | **Demo-builder** | prove it runs | demo | human 👁 |
| Deploy | **Releaser** | guarded release + rollback | runbook | human ✋ |
| Monitor | **Monitor** | watch + alert | — | later |

*Artifacts map to a **Vajra-native home**, never a foreign file — the **prompt IS the spec** (`prompts/NN-task.md`: goal + deliverables + acceptance + guardrails); `.ai/` is the memory. Later stages' artifacts (design, tasks…) get mapped onto `.ai/`/`prompts/` when built, not imported (see `.ai/KNOWLEDGE.md`).*

**Why this is a product and BMAD/Spec Kit aren't:** they *describe* these stages (role prompts / markdown); **neither enforces or proves the handoff.** Vajra's version = the same pipeline with **gates + a delta ledger = provable, and cross-agent.** That is the governance wedge, given a shape. It also closes the two gaps we found vs Spec Kit/OpenSpec: **delta tracking** (every handoff emits +/~/−) and **SDLC breadth** (the stages *are* the breadth).

**Own the spine, borrow the polish.** Vajra's `.ai/` already *is* spec-driven development *with teeth* — so **Spec Kit / OpenSpec / BMAD are reference designs, not runtime dependencies** (borrow their artifact ideas: structured spec + acceptance criteria, Kiro EARS, OpenSpec delta markers — you have the pattern, not the polish). **Serena** *is* a real dependency (code-index / LSP — a capability Vajra lacks). The **Borrow Engine**: each stage we build starts by studying how the incumbents do that stage's artifact, and adopting the best.

**Build path — status as of S99 (corrected S100; the head was repositioned at S98 and this body was not):** the spine is **BUILT**. Eight governed stations shipped S54–S72 (Analyst · Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer), the independent fidelity auditor shipped S55–S56, its verdicts are **attested** (S58/S86/S88 — `sha256(prompt‖diff)`, recompute-and-compare) and **chained tamper-evident** (S59 — 36 records, `--ledger-verify` INTACT), and a derived payload counter reads K-of-8 per session (S74, `vajra next --stations NN`). **What is left is not more stations — it is proving the whole loop holds unattended:** the falsifiable Autopilot Ladder in `.ai/ROADMAP.md` (Rung 1 done S97, paid). Cross-agent breadth remains **0 code**, sequenced behind a neutral evidence format, not claimed.

## What it does

| # | Job | Plain meaning | Real today? |
|---|---|---|---|
| 1 | **Enforces discipline at action-time** | Blocks the forbidden action (push to main, `gh pr create`, session drift) *before* it runs — exit 2 | ✅ |
| 2 | **Keeps memory + feeds context** | The agent never forgets the vision, roadmap, rules between chats; the co-pilot surfaces the right rule at the right corner | ✅ |
| 3 | **Delta-tracks each stage** | Every handoff records +added/~changed/−removed → a provable trail across the pipeline | 🟡 **partly real (S100 correction)** — the 8 stations record and gate their own evidence, and the attested verdict ledger chains it (36 records); the full +/~/− delta triple exists only at the Analyst stage |
| 4 | **Works across agents** | One governance layer over Claude, Cursor, Codex, others | 🔴 Claude-only today |
| 5 | **Saves a few tokens** *(bonus)* | Trims long successful output; failures pass through | 🔴 **measured $0 / 0 folds on a real run (S63)** — make it real (compression and/or Varta token-efficiency) before ever claiming it; never in README/marketing until measured (S70 founder decision) |

## The differentiator — the make-or-break

**"Isn't this just a good `CLAUDE.md` + git hooks + a linter?"** The honest answer:

| Layer | What it enforces | The gap Vajra closes |
|---|---|---|
| `CLAUDE.md` / `AGENTS.md` | nothing — **advisory, the agent skims and ignores it** (proven S31) | Vajra's hooks *intercept*; the rule is enforced, not requested |
| git hooks (`pre-commit`/`pre-push`) | only at **git boundaries**; `--no-verify` bypasses; **blind to `gh pr create` / `gh pr merge`** (GitHub API, no git hook fires) and to the agent's mid-turn Edit/Write/Bash | Vajra fires on the **tool call**, before it runs — including non-git outward actions and mid-turn edits |
| a linter | code style/correctness | Vajra governs **agent behavior + process** (session state, one-chat-per-session, N→N+1) |

**Also real, and git-hooks don't have it:** a **session/process state machine**, a **context co-pilot** (`⚡on` surfaces the right file at the right action), and a **fail-closed** posture (*a check that cannot evaluate FAILS* — jq-missing blocks, S42; linters/hooks usually fail open).

**Honest verdict (the gate; corrected S100):** the reframe **PASSES on enforcement-depth** — Vajra assembles a governance layer that `CLAUDE.md` + git hooks + a linter cannot. The provable pipeline record a buyer would **pay to keep** now **exists** (8 stations + attested, chained verdict ledger — S54–S72, S55–S59). What it is **not** yet is **cross-agent** — 0 code, Claude-only — so the headline moat is still one axis short, and the trust it earns is proven only at **Ladder Rung 1** (S97, one paid run, partial). We record that tension rather than paper over it.

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
- The **pipeline is built** (8 stations, S54–S72). The next work is **climbing the Autopilot Ladder** — proving the loop holds unattended for days. Under the **machinery-freeze rule** (S98) a session either runs the ladder or fixes what a run broke; everything else is frozen

## Honest truth

- The enforcement floor is real and live-verified; the moat (cross-agent tamper-evident ledger) is not built
- Competitors exist (AxonFlow ships ~80% of the vision; Cursor's `agent-trace` spec occupies cross-agent attribution) — the edge is local-first + git-native + fail-closed + the open format
- The independent fidelity auditor **shipped** (S55–S56), is **attested** (S58/S86/S88) and **chained** (S59) — green gates now prove discipline *and* an independently-judged delivery. **The honest gap S100 found:** that gate can be waived wholesale by one founder env var, and DOGFOOD/ladder sessions close under it — so the runs that are meant to be the *proof* are the ones currently self-certified (`sessions/session-100-ground-truth.md` §6)

## In one breath

*Vajra is a governed multi-agent SDLC pipeline: every stage a specialised agent, every handoff enforced, delta-tracked, and checked for **fidelity** — that the agent delivered what was asked, not merely followed the rules — on top of any coding agent.*
