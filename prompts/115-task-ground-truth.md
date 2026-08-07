# Session 115 — GROUND TRUTH (mandatory NO-CODE)

> **Status: MANDATORY** — `115 % 5 == 0`. No source-code edits, no code commits, no PRs beyond the
> GT artifact. Hook-enforced (`hook-pre-bash.sh`, `hook-pre-write.sh`). Authorized hardening, if any
> is truly unavoidable, goes on a `session-115-closeout` branch (exempt by suffix).

## Goal

The fifth ground truth since the S103 founder pivot. Catch **both** classes of drift — *are we
building the right thing* (vision + roadmap) and *did we honour the contract, and does the contract
still serve the vision* (rules, constitution, state, cost, usage) — then meta-check whether this
audit's own mechanism has a blind spot.

Run every audit in `CONSTRAINTS.yaml#ground_truth.required_audits`, answering its question list:
`vision_alignment` · `roadmap_alignment` · `state_drift` · `knowledge_staleness` ·
`constraint_violation_review` · `constitution_review` · `cost_review` · `dogfood_check` ·
`pipeline_advance_check` · `dogfood_staleness`.

## The one live opportunity — dispatch the new role BY NAME

S114 built the fleet's second role, the **Fidelity Reviewer**, and could not dispatch it: Claude Code
snapshots `.claude/agents/*.md` at boot, so a role written mid-session is invisible to that session
(S111, unchanged and still true). **S115 is the first session that can call it by name.**

Dispatching an agent and reading its findings is **evidence-gathering, not code** — it fits a NO-CODE
session, and it is the only way to learn whether the brief actually works on a real agent rather than
on a grep. So:

1. Dispatch this GT's own independent pass with `subagent_type: "fidelity-reviewer"` — by name, not
   as an ad-hoc `general-purpose` subagent. Record the tool call.
2. Govern its verdict with `vajra next --role fidelity-reviewer --from <file>` (writing a handoff is
   `.ai/` spine work, not source code).
3. **Report what the brief got right and what it got wrong.** Specifically: did the returned verdict
   carry a real `|`-row per-requirement table, a canonical `**Verdict:**` line, and an `X of N
   SHIPPED` count — i.e. would it pass `verify-closeout.sh` unedited? S114 fixed that gap on paper;
   this is the first chance to see it on a live agent.
4. Confirm `vajra next --stations 115` reports the fleet line, and record whether the honest limit
   still holds ("a contract-valid handoff exists", never "an agent was dispatched" — though this
   time a dispatch DID occur, and the transcript is the proof, not the handoff).

If the dispatch fails or the role resolves to nothing, **that is the finding** — report it plainly.
Do not fall back to a `general-purpose` subagent and describe it as the role having run.

## Required outputs

- `sessions/session-115-ground-truth.md` — every audit, its question list answered, the meta-check,
  and a lens-A verdict (PASS / PARTIAL PASS / FAIL) with reasons.
- The live-query evidence, pasted, never summarised from memory:
  - `vajra next --stations NN` for **every** session since the last GT (S111–S114) — read the SHAPE,
    not just the number. A station ABSENT across many sessions is a systemic gap; name it.
  - `vajra next --dogfood-age` — record session, git-derived date, sessions-since, calendar-days-since,
    and reconcile against STATE.md. **It has been 🔴 since S103 (12 sessions by S115).** An
    "is Vajra-on-Claude satisfying?" verdict is unmeasured by definition until a real paid run happens.
  - `verify-closeout.sh --ledger-verify` — INTACT or not.
- Exactly **3** candidate next sessions (A/B/C) drawn from ROADMAP, each with title, one-sentence
  goal, why-pick-this, key risk. Founder picks; then write `prompts/116-task-<slug>.md`.

## Carry-ins the audit must confront (do not let these slide a sixth time)

- **🔴 Paid dogfood, stale since S103.** Twelve sessions of mechanism tests do not reset it.
- **🟡 The Fidelity Reviewer's TEXT is guarded by presence-greps only** — S114's disclosed fakest
  green: a cold pass swapped the whole system prompt for rubber-stamp token soup and the entire
  suite (17/17 verify, 10/10 demo, 322 tests) stayed green. Is that acceptable, or does it need a
  mechanism? Say which, and why.
- **🟡 `no-eighth-command` is a grep for a hardcoded usage banner** — flagged at S111, S112, S113 and
  S114 and never fixed. Four sessions of "flagged, not fixed" is itself a finding.
- **🟡 KNOWLEDGE §6 bloat** — chronic since S60, prune still queued.
- **A premise inside an approved prompt is not evidence** (S114: the prompt asserted the reviewer's
  brief lived nowhere, while `reviewer/SKILL.md` had stated it all along). **Meta-check: does any
  audit here check the PROMPTS' premises, or only the code's behaviour?**

## Non-goals

- No source-code changes, no `cargo` edits, no new scripts, no new commands.
- Do not build a third fleet role, a blocking gate, or the dogfood run itself — those are S116
  candidates, decided by the founder at this session's close.

## Guardrails

- Max 2 assumptions, max 2 retries, 1 story, ~2h cap. Branch: `session-115-ground-truth`.
- Communicate in the plainest English (founder standing request). Darshan every human reply.
- **Attest LAST if any review artifact is produced:** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖
  diff) and the prompt is itself an input — recompute after the prompt is final and committed, then
  confirm two consecutive `--inputs-sha` runs agree (S69; hit twice at S114).
- Own the `.ai/` spine — no second store.
