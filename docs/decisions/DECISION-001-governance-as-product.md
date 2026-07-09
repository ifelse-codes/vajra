# DECISION-001 — Lead with governance as the product (reverses the S46 "better work" lock)

- **Date:** 2026-07-09 (Session 53)
- **Status:** Accepted
- **Supersedes:** the S46 founder direction lock on direction **B** ("your AI does better work").
  That lock is **not erased** — it is recorded below and downgraded to a hypothesis.
- **Type:** direction / positioning decision (not an architecture ADR)
- **Gate:** accepted **iff** governance beats "just git hooks + `CLAUDE.md`" (Q2). Verdict below: **PASSES on
  enforcement-depth; the headline ledger moat is unbuilt.** Recorded honestly, not papered over.

## Context — what S46 decided, and why we reverse it

**S46 (2026-07-05):** offered (A) *"your AI can't go rogue"* — safety/guardrail — vs (B) *"your AI does better
work"* — the founder picked **B**. Rationale (kept, verbatim intent): after S46 proved the enforcement guard
holds live, "basically all we've done is stop it from commit/push" felt thin; a tool that only says "no" is not a
product; the co-pilot that makes the AI do better work is the valuable thing.

**Then we measured B — twice, honestly:**

| Session | Task | Result |
|---|---|---|
| S51 | Sharpen `@chitra/core` README (easy) | **n=1 null** — arms equal on core API; Vajra **+19%** cost; Vajra arm mirrored chitra's *own broken* CONTRIBUTING |
| S52 | Publishable `dist/` build for `@chitra/core` (hard, convention-heavy) | **n=2 null** — both arms produced the *same solution AND the same `.tsbuildinfo` bug*; Vajra **+11.7%** cost; constraint-adherence tie |

**"Does better work" is UNPROVEN across n=2 (easy + hard).** Not rescued.

**What kept working, live, the whole time = governance / drift-prevention:**
- **S46:** the enforcement moat live-verified — isolation harness, agent ran `git push -u origin …`, publish-guard
  blocked it exit-2 in the nested JSONL (`sessions/session-46-live-hook-fire.txt`).
- **S51/S52:** `dogfood_check` 🟢 — guards fired live (co-pilot blocked a real `git commit`; session-guard blocked
  a branch; the governed arm **refused to code** in chitra's NO-CODE ground-truth slot).
- **S52:** the governed ground-truth run caught chitra's *own* real discipline drift (stale STATE/SESSION,
  a story shipped skipping verify/demo/closeout).

## Decision

**Lead with governance as the product.** Reposition the north-star from *"your AI does better work"* to
**"your AI provably follows your rules — and you get the auditable record."** Keep "better work" as a stated,
under-tested hypothesis, not the pitch.

## The differentiator test (Q2) — the make-or-break

**"Isn't provable agent governance just a good `CLAUDE.md` + git hooks + a linter?"**

**REAL today (demonstrated live), that those three cannot assemble:**
1. **Action-time interception.** Vajra's PreToolUse hooks block the agent's action *before* it runs (exit 2),
   including **`gh pr create` / `gh pr merge`** — GitHub-API actions **no git hook can fire on** — and mid-turn
   Edit/Write/Bash a `pre-commit` never sees. `--no-verify` bypasses a git hook; it does not bypass a PreToolUse hook.
2. **Session / process state machine.** one-chat-per-session, N→N+1 advance guard, session-owner tracking.
   git hooks have no concept of a session.
3. **Context co-pilot.** `⚡on(cond) ⚡include "files"` surfaces the right rule at the moment of the relevant action
   — not a static doc the agent skims once (S31 proved `CLAUDE.md`-as-prose is ignored).
4. **Fail-closed posture.** *A check that cannot evaluate FAILS* — jq-missing **blocks** (S42). Linters and git
   hooks typically fail open.

**NOT real today (must be stated plainly):**
- The **headline moat** — a **cross-agent, tamper-evident, hash-chained audit ledger in the open `agent-trace`
  format** — is **0 cross-agent code.** Enforcement is **Claude-only.** **No buyer-facing audit artifact ships.**
- Competitive reality (`vajra-competitive-landscape`): AxonFlow already ships ~80% of the ledger vision; Cursor's
  `agent-trace` spec occupies cross-agent attribution.

**VERDICT: PARTIAL PASS.** Governance beats "just git hooks + `CLAUDE.md`" on **enforcement-depth** — a real,
demonstrated, defensible layer today. It does **NOT** yet win on the **ledger** (the thing a buyer pays to keep),
because that is unbuilt. So the reframe **holds** — but its differentiation is currently *enforcement-depth*, and
the product only becomes *sellable* when the **ledger output** makes governance **visible** to a buyer. That is
the S54 MVP, and the honest condition on this whole decision.

## The honest risks (do not hide)

- **n=2 is small.** The B-null is a real signal but not a proof; a longer-horizon test could still find work-quality value.
- **Cross-agent is unbuilt.** The moat's headline claim is aspirational; the reframe leans on it but cannot yet cash it.
- **"Enforcement-depth" alone risks reading as a *feature*, not a *product*** — a slightly-better git hook. The
  ledger is what makes it a product; until it ships, the skeptic's objection is partly fair, and we say so.
- **Governance demand is still an unvalidated assumption** (`vajra-positioning`): dogfooding was the plan; no
  external buyer has validated the pain.

## Consequences

- `VISION.md` rewritten to lead with governance (this decision's companion).
- `.ai/ROADMAP.md` re-ranked around **"make governance sellable"** — the ledger OUTPUT is the new #1.
- Memory `vajra-direction-b-copilot` + `vajra-positioning` updated.
- "Better work" survives as a hypothesis with a revisit condition (longer-horizon test), not as the lead.

## Revisit if

- a longer-horizon (multi-session, whole-project) test shows a real work-quality win → re-weight B; **or**
- the ledger MVP ships and **still** can't be distinguished from git hooks + a log file → the reframe fails its
  own gate, and governance is a feature, not a product. Keep the door open.
