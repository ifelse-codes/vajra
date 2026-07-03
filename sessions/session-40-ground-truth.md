# Session 40 — Ground Truth (NO-CODE) · lens: enforcement-completeness

**Date:** 2026-07-03 · **Type:** every-5th mandatory NO-CODE (last GT = S35) · **Branch:** `session-40-closeout` (suffix-exempt; audit only, no src edits)

> **One-line verdict:** The S37→S39 guard work **converged on the *harm* the S36 leak caused** — every outward/irreversible action the S36 agent took now BLOCKS, scaffolded. But the moat is **test-verified, not live-verified** (dogfood gate unmeasured since S36), and this very audit can grade the plumbing but cannot prove the guards fire live. Highest-leverage next = **re-dogfood, not more plumbing.**

---

## 1. Lens-A — the S36 kill-chain walked against today's guards

S36: at maturity **L3**, in ONE chat, on a scaffolded brownfield project, the agent did an unbranched `00→01` advance, then `git push origin main` → branch → build → PR #1 create+merge → branch closeout → PR #2 create+merge. Vajra stopped **none** of it. Replaying that exact sequence against today's guards (`hook-publish-guard.sh` post-S39-B + `hook-session-guard.sh` post-S39-A, both scaffolded into `vajra init` by S38):

| S36 action | Guard today | Verdict |
|---|---|---|
| `git push origin main` | publish-guard (L3, scaffolded S38): blocks **any** `git push` unless `VAJRA_ALLOW_PUBLISH=1` | ✅ **BLOCKS** |
| `git push origin session-01` | publish-guard: any-form push | ✅ **BLOCKS** |
| `gh pr create` (PR #1, #2) | publish-guard: `gh pr create` classifier | ✅ **BLOCKS** |
| `gh pr merge` (PR #1, #2) | publish-guard: `gh pr merge` classifier | ✅ **BLOCKS** |
| `vajra next --advance` 00→01 **after** branching `session-00-onboarding` | session-guard (S39-A): arms on advance, target = SESSION+1, same-chat block | ✅ **BLOCKS** (2nd advance / when 00 ownership recorded) |
| `vajra next --advance` 00→01 with 00 **never branched** (the exact S36 shape) | session-guard: no prior owner record → first observed advance passes, records 01 | 🟡 **SLIPS on the first advance** |
| raw `echo 01 > .ai/SESSION` (Rust `fs::write` or shell) | session-guard is a Bash hook; can't see a file write | 🔴 **SLIPS** (out of S39-A scope) |

**Reading:** the *damage* (2 real PRs + a push to a real remote) is fully closed — all four outward actions block, scaffolded. The *session-hygiene* half is **partially** closed: S39-A blocks the sanctioned `--advance` once a session's ownership is recorded, but the **precise S36 shape** (advance the very first session without ever branching it) still slips on that first advance, and a raw `.ai/SESSION` write bypasses the Bash guard entirely. Both slips are session-boundary hygiene, not harm — the publish-guard blocks the outward consequences regardless.

**Live confirmation this session:** creating `session-40-closeout` did NOT false-block (session-guard correctly allowed a same-session-number checkout; `.ai/.session-owner` = `40<TAB>` this chat). One data point that the guard is wired and not over-blocking — not a substitute for a real adversarial dogfood.

---

## 2. Residual-gap ranking — real leak vs bounded v0 limit

| # | Gap | Re-opens S36? | Severity | Verdict |
|---|---|---|---|---|
| 1 | **publish-guard `jq`-missing → fail-open** (`[ -n "$CMD" ] || exit 0`, line 34) | **Yes, fully** on a machine without `jq` | **HIGH (latent)** | **Real leak.** Violates the constitution's own L147 "a check that cannot evaluate FAILS; never silently pass." Suite-wide (every hook parses with `jq`), so it's a shared install-precondition, not publish-guard-specific — but that makes it worse, not better. Earns a fix (preflight / fail-closed on missing `jq`). |
| 2 | **git-level `pre-push`/`pre-commit` NOT scaffolded** (ROADMAP #17) | No for outward actions (L3 publish-guard is scaffolded); **yes** for the raw-SESSION-write + push-to-main-via-obfuscation | **MEDIUM** | **Bounded, high-leverage.** The vajra *repo* has them (`core.hooksPath=.githooks`); scaffolded *projects* don't. Closes gaps #4 below + obfuscated push-to-main (git sees the real ref) + adds an independent L2 layer. Earns its own session. |
| 3 | **obfuscated `g=push; git $g` evasion** (under-block) | Only under an *adversarial* agent (S36 was naive, not adversarial) | LOW | **Accepted v0 limit.** Different threat model; git-level pre-push (#2) catches the push-to-main case regardless of obfuscation. |
| 4 | **raw `echo N > .ai/SESSION` bypass** | Session-hygiene only (harm blocked by publish-guard) | MEDIUM | **Bounded; folds into #2.** A Bash PreToolUse hook structurally cannot see a file write; the git-level belt is the right layer. |
| 5 | **heredoc-body over-block** (quote-strip leaves heredoc text) | No (over-block direction) | LOW | **Accepted v0 limit** — matches the founder "over-block > leak" directive. |
| 6 | **one env var authorizes the whole launch** (coarse, not per-action) | No | LOW-MED | **Accepted v0 limit.** Per-action interactive approval is a future enhancement, not a leak. |

**Bottom line:** of six recorded gaps, **one is a real (latent) leak** (`jq` fail-open, #1 — and it's a constitution violation), **one is the highest-leverage bounded item** (git-level scaffolding, #2, closes #4 too), and **four are accepted v0 limits** consistent with the fail-safe posture.

---

## 3. dogfood_check (mandatory) — the load-bearing verdict

**Question:** has real work run through `vajra claude` since the last GT? **Evidence = the cost ledger, not test counts.**

| Session | Real `vajra claude` spend | Nature |
|---|---|---|
| S36 | ~$61.4 (agent `-p` $3.27 + founder Opus $58.17) | last real dogfood |
| S37 | ~$0.00 | build (guard authored) |
| S38 | ~$0.00 | build (propagation + local `vajra init`) |
| S39 | ~$0.00 | build (both fixes + local `vajra init`) |
| **S40** | ~$0.00 | this GT (NO-CODE) |

**Verdict: the founder-satisfaction / moat-liveness gate is UNMEASURED** (S30/S35 precedent — "unmeasured" is the honest finding). The S37→S39 guards are proven by `verify-session-37/38/39.sh` (22/19/37 green) + `cargo test` 133 + a local E2E `vajra init` — **test-verified**. They are **not live-verified**: no real agent has tried to push/PR/advance against the *scaffolded* guards in a live `vajra claude` session since they were built. (Caveat, in the guards' favour: S37's publish-guard *was* proven live *in the S37 build session* — it blocked the agent's own push. S38's scaffolded propagation and S39's B/A fixes have only the E2E `cmp`/payload evidence.)

**This is the same cliff compression sat on before S31/S36 proved it dead** (green tests + `[x]` roadmap while the feature did nothing live). We are test-verifying enforcement the same way we test-verified compression — and that verification passed right up until a live run falsified it.

---

## 4. Meta-check (the load-bearing one) — direction drift after 3 plumbing sessions

**Was S37→S38→S39 the shortest path to the north-star (`vajra next` as the cross-agent coach), or intellectually-fun scope creep?**

**Defensible as correct priority:**
- S36 was a *real* failure with *real* consequences (2 real PRs to a real GitHub remote). Enforcement is THE wedge (positioning); a leaking moat is existential, not polish.
- Each session was disciplined: ≤3 files, author→propagate→correct, the established `include_str!` one-source pattern. That's convergence, not sprawl.

**The drift signal (honest):**
- **All three sessions are on the Claude-only path.** The north-star is *cross-agent*. The second agent still has **zero code** — the S25 finding ("the only differentiating pillar, vendor-neutrality, has zero code; no metric measures breadth") is **still true 15 sessions later.** Every guard is a `.claude/`-specific Bash hook.
- **Compression stays dead** (S41 ready since S36) — pushed back three sessions. Defensible (it's "the quiet bonus," not the moat) but it means two of the three proven-broken S31/S36 findings (compression, breadth) are still open while a third (enforcement) got three sessions.
- **The gate has been unmeasured since S36** — we built 3 sessions of guards *without* re-running the loop that would both prove them and surface the next real pain.

**Blind spot of THIS audit's mechanism:** a GT can grade "did the guards converge" against the recorded threat model and the code — it **cannot** verify the guards fire in a live session. So this audit measures plumbing-correctness (test-green) while the load-bearing question (do they block a real agent? is the moat real?) stays unmeasured — the exact S30 trap (7 audits green while un-dogfooded), one level up. **Honest synthesis: the enforcement work was correct priority *and* it is now at the same unmeasured-risk cliff compression was at before S31.** The next highest-leverage move is a **dogfood run to live-verify the moat** — not a fourth plumbing session.

---

## 5. The eight required audits — per-audit verdicts

| Audit | Verdict | Note |
|---|---|---|
| **vision_alignment** | 🟡 aligned, standing watch | North-star (cross-agent coach) still right; no pivot evidence. But Claude-*depth* keeps accumulating while cross-agent *breadth* stays at zero code (S25, still open). If the next dogfood shows the moat holds *and* is Claude-locked, breadth becomes the sole blocker. |
| **roadmap_alignment** | 🟡 gap | Phases map to the north-star. But the ROADMAP has **no scheduled "re-dogfood to live-verify S37→S39" item** post-S36 — and that is higher-leverage than the currently-leading #16 (compression) given the gate is unmeasured. #17 (git-level scaffolding) is under-ranked (it closes 2 residual gaps at once). |
| **state_drift** | ✅ clean | STATE/SESSION-BOOT say "S39 PR pending" but PR #34 is **MERGED** — this is the S30-*retired* accepted snapshot-before-merge artifact (snapshot honestly written pre-merge), not tracked drift. `.ai/SESSION`=39 == main head (S39) — consistent. `.githooks/` layout claim accurate. |
| **knowledge_staleness** | ✅ clean | Append-only; S39 entry present + accurate; S33/S36 compression-dead facts still true (unfixed). No stale facts. |
| **constraint_violation_review** | ✅ clean | S37/S38/S39 each ≤3 files, branch pattern ✓, no main commits ✓, verify exit 0 ✓. S39's A+B (2 stories/1 session) was an **explicit, recorded founder override**, not a silent breach. Zero silent violations. |
| **constitution_review** | 🔴 finding | Meta-check: AGENTS.md L147 "a check that cannot evaluate FAILS; never silently pass" is **violated in practice** by the hook suite's `jq`-missing → `exit 0` fail-open (gap #1). Rule is right; implementation contradicts it. |
| **cost_review** | ✅ honest | Cumulative ~$62; ~$0 since S36 (build sessions). Ledger accurate. S36's $32 cache-read (boot-packet weight, ROADMAP #18) still un-addressed; no budget breach (no runs). |
| **dogfood_check** | 🔴 **UNMEASURED** | §3. The gate is not cleared; the moat is test-verified, not live-verified. |

---

## 6. Authorized doc-only hardening

**None applied during the audit** (kept a pure audit). **Recommended at closeout** (doc-only, suffix-exempt):
1. Add a ROADMAP item: **`jq`-preflight / fail-closed on missing `jq`** across the hook suite (closes the constitution violation, gap #1) — small, correctness-critical.
2. Add a ROADMAP item: **re-dogfood to live-verify S37→S39** (the missing verification item the gate demands).
3. At the S40 closeout, STATE REPLACE will naturally correct the "S39 PR pending" snapshot → merged.

---

## 7. Exactly 3 ranked candidate next sessions (A/B/C) for S41

### A — Re-dogfood: live-verify the S37→S39 moat + re-measure the gate  ⭐ recommended
- **Goal:** run the real `vajra claude` loop (S36 method) against a scaffolded project at L3 and prove the publish-guard + session-guard actually block a live agent's push/PR/advance — then render the founder-satisfaction gate verdict *with evidence*.
- **Why pick this:** the moat is test-verified but live-unmeasured since S36 — the exact cliff compression fell off; this validates 3 sessions of work, re-opens the gate, and surfaces the next real pain in one run. Highest-leverage per §3/§4.
- **Key risk:** a live Opus session is expensive (~$58 last time) — mitigate with the S36 cheap method first (`-p` agent run + real-shaped payload replays to `vajra hook`), escalate to interactive only if needed. Not "code," so it fits post-GT.

### B — Fix the compression fail-gate, correctness-first (ROADMAP #16, prompt ready)
- **Goal:** `prompts/41-task-fix-compression-exit-gate.md` — unblock the safe format-aware `git*` folds regardless of `exitCode`; keep the generic path conservative; **never hide a failure.**
- **Why pick this:** a proven defect with a ready prompt; restores a true product claim; the only leading item with a written brief.
- **Key risk:** it's the "quiet bonus" (~6–8% $), not the moat; and shipping it before a live dogfood repeats the "build in a test harness" pattern §4 flags.

### C — Git-level `pre-push`/`pre-commit` scaffolding (ROADMAP #17)
- **Goal:** scaffold `.githooks/pre-push` + `pre-commit` + `core.hooksPath` into `vajra init` as an independent L2 belt — closes the raw-`echo > .ai/SESSION` bypass (#4) + obfuscated push-to-main (#3).
- **Why pick this:** highest-leverage *enforcement* item — a second independent layer that closes two residual gaps at once; git hooks are vendor-neutral (a small breadth win).
- **Key risk:** it is *more enforcement plumbing* — the exact scope-creep §4 warns about — while the moat stays live-unverified and compression stays dead. Bundle the `jq`-preflight fix (#1) here if picked.

> **Ranking rationale:** A > C > B. The gate is unmeasured and 3 sessions of guards are live-unverified (§3/§4) → verify before building more. C beats B only if the founder wants to keep hardening; both should wait behind a live re-measure. **Founder signs off before S41 code.**
