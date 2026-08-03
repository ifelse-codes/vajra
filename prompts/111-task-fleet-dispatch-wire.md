# Session 111 — CODE: close the fleet's def-vs-dispatch wire

> **Status:** APPROVED (founder pick A at S110 GT closeout — "close the def-vs-dispatch wire").
> Written at S110 closeout per `end_of_session.must_write_next_prompt_before_close`.

## Type
CODE — one story, ≤3 files per atomic commit, ~2h cap.

## Goal
S109 shipped the fleet's first slice as **two facts proven separately**: (1) `vajra init` scaffolds
`.claude/agents/researcher.md` from the canonical `fleet::ROLES`, and (2) a real subagent ran via the
orchestrator handing the Task tool a canonically-generated prompt. **Nothing today proves the Task
tool actually reads the scaffolded file by name** — the S109 cold reviewer flagged this as the
delivery's central fakest-green, and the S110 GT confirmed it's still open. Close that wire: make the
live dispatch path **read `.claude/agents/researcher.md` by name** (the real Claude Code subagent
mechanism), not a duplicated in-process prompt string, so the scaffolded definition IS the dispatch
contract, not a parallel copy of it.

## Secondary goal (same session, same mechanism)
Itemize the subagent's cost. Today `cost_usd: null` in the handoff — it rolls into the parent
session's receipt, unpriced per-call. If Claude Code's Task-tool invocation surfaces a per-subagent
cost (check the transcript/JSONL the same way `vajra meter` already parses the parent session), wire
it into the handoff. If it genuinely does not expose one, **do not fake a number** — keep the honest
null (S77 pattern) but document precisely why, so this isn't re-flagged as unexplored next time.

## Non-goals (do not build this session)
- A second fleet role (S110 candidate C) — stays deferred until this wire is proven.
- Downstream handoff-consumption (S110 candidate B) — stays deferred; don't blur the two.
- An unattended `claude -p` / `ANTHROPIC_API_KEY` dispatch mode — still DECISION-007-deferred.
- No 8th top-level command. Rides `init` + `next`.

## Acceptance criteria
1. The live dispatch path demonstrably reads `.claude/agents/researcher.md` by name (cite the
   mechanism — Claude Code's own subagent-by-file convention, not a Vajra-side string match).
2. A real subagent run (not a mock) proves it: same falsifiable bar as S109 — fail-closed smoke on
   unknown role / missing `--from` / empty findings still holds.
3. Cost is either itemized into the handoff with a cited source, or the `null` is kept with a
   specific, checked reason (not "unclear") for why no per-call cost is available.
4. `cargo test --lib` green; CI both OS; `verify-session-111.sh` green; `demo-session-111.sh` exit 0.
5. Independent cold review (fed only prompt + diff) — SHIPPED/PARTIAL/NOT-BUILT per numbered
   requirement above, plus the fakest green, disclosed.

## Guardrails
- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Branch: `session-111-<slug>`. Approval token required before any commit.
- Communicate in the plainest English (founder standing request).
- New chat for S111 (one session per chat).
