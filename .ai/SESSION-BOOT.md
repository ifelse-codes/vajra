# Session Boot

## Current Session
- **Number:** 111 — COMPLETE
- **Type:** CODE — close the fleet's def-vs-dispatch wire (founder pick A at S110 GT closeout).
- **Goal:** prove the live subagent dispatch reads `.claude/agents/researcher.md` **by name** (Claude
  Code's own subagent mechanism), not a hand-typed copy of the canonical prompt; itemize the
  subagent's cost or document precisely why not.
- **Verdict:** **SHIPPED.** Two-step proof: (1) inside the live build session, dispatching by name
  **failed** — Claude Code snapshots `.claude/agents/*.md` into available subagent types once, at
  session boot, so a file written mid-conversation is invisible to that same conversation (a real,
  disclosed finding, not a workaround). (2) A **fresh** `vajra claude` session in a freshly-`vajra
  init`'d repo, asked to "use the researcher subagent," dispatched it **by that name** — proven not by
  a single copyable JSON blob but by two independently-written Claude Code files (the parent session's
  tool-call record and the subagent's own `meta.json`) agreeing on the same random tool-call ID. Cost:
  `cost_usd: null` kept, for a checked, re-runnable reason (`scripts/check-subagent-cost-fields.sh` —
  zero of every local subagent transcript carries a cost key; same root cause as S77/S78). No
  dispatch-path code changed — S109 had already built it correctly; S111 supplied the missing proof.
  verify 9/9; demo exit 0; 304 lib tests; cold review **ACCEPT** (13/14 SHIPPED, 1 PARTIAL —
  CI-both-OS unevidenced pre-merge; one disclosed residual fakest-green: the cross-file check is still
  internal to this commit's own artifact set), attested `f98808bc…`.
- **Report:** `sessions/session-111-summary.md` + `sessions/session-111-review.md` · next prompt:
  `prompts/112-task-handoff-consumption.md`. **Date last updated:** 2026-08-03.

## Repo State Snapshot
- `.ai/SESSION` = 111. CODE session: no dispatch-path `src/` changes (one doc-comment edit in
  `src/fleet/mod.rs`); new evidence artifacts under `sessions/session-111-artifacts/`, a governed
  handoff at `.ai/handoffs/session-111-researcher.md`, a DECISION-007 addendum, and two new scripts
  (`scripts/verify-session-111.sh`, `scripts/demo-session-111.sh`, `scripts/check-subagent-cost-fields.sh`).
- **No PR opened yet this session** — branch `session-111-fleet-dispatch-wire`, 8 atomic commits, all
  pushed to the local branch only at write time. S110 closeout **#116** merged 2026-08-03; main synced
  at branch-cut. Remote: `origin` → `https://github.com/ifelse-codes/vajra`.

## Next Session
- **Number:** 112 — **CODE (proposed): downstream handoff-consumption** — nothing today reads
  `.ai/handoffs/session-NN-researcher.md` automatically; it's written and governed but orphaned.
  Recommended over a second fleet role (S110 candidate C) because a lone unread handoff gets *more*
  orphaned, not less, if a second role doubles the count before anything consumes the first. Prompt:
  `prompts/112-task-handoff-consumption.md` (drafted, pending founder confirmation at kickoff).
- **Deferred (S110 GT candidate C, still not S112 by default):** a second fleet role — wait until
  handoff-consumption is proven, unless the founder redirects.

## Carry-Forwards
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S112.
- **Communicate in the plainest English** (founder request S103) — translate all jargon.
- **Fleet dispatch = native Claude Code subagents (DECISION-007), now proven end-to-end (S111):**
  `vajra init` scaffolds the role file; a fresh session's Task tool resolves `subagent_type` against it
  by name; `vajra next --role --from` governs the brief. No `claude -p` spawning. An unattended mode
  is still deferred (`ANTHROPIC_API_KEY` is the only auth that survives a fresh no-TTY/no-keychain
  shell — per the S109 handoff's own research).
- **`scripts/check-subagent-cost-fields.sh` is now the house pattern for the cost-null finding** — a
  re-runnable, local-machine-only check (same class of limitation as `--dogfood-age`), not a magic
  number. Reuse it rather than re-deriving the same grep if this comes up again.
- **v0.1 installs FOUR ways, all measured, CONFIRMED stranger-shippable at S110 GT.** Residual 🟡s
  carried in STATE.md (brew smoke tests a local formula copy · x86_64 prebuilt never executed, etc.).
- **crates.io is PUBLISHED — `vajractl` name BURNED.** Any future crates.io action stays founder-gated.
- **Launcher dogfood is stale (🔴, since S110 GT)** — zero `vajra claude` runs since S103, other than
  this session's own scratch-repo dispatch test (which doesn't count — no paid governed session ran).
  Not S112's job to fix by default, but should not run much longer without a real paid call.
- **Untracked stragglers** (standing founder call): `sessions/session-9*-artifacts/*`,
  `sessions/session-10{2,3,7,8,9}-artifacts/*`; `vajra-cto-audit-*.html` + `first-mate.html`.
